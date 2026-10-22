# Grant-ManagedIdentityGraphPermissions.ps1
#
# Grants the Microsoft Graph application permissions a Logic App's system-assigned
# managed identity needs to resolve Azure RBAC principals (users, groups, service
# principals) to human-readable display names.
#
# The Azure Portal does not expose an "API permissions" blade for a managed identity
# the way it does for an App Registration, so this step must be done via Microsoft
# Graph PowerShell/CLI/API. Run this once, after the Logic App's system-assigned
# identity has been enabled.
#
# Prerequisites:
#   - Az CLI logged in as (or PowerShell authenticated as) a Global Administrator /
#     Privileged Role Administrator able to grant admin consent.
#
# Usage:
#   $miPrincipalId = "<Object (principal) ID from the Logic App's Identity blade>"
#   .\Grant-ManagedIdentityGraphPermissions.ps1 -ManagedIdentityPrincipalId $miPrincipalId

param(
    [Parameter(Mandatory = $true)]
    [string]$ManagedIdentityPrincipalId,

    [string[]]$GraphAppRoles = @("User.Read.All", "Group.Read.All", "Application.Read.All")
)

$graphToken = az account get-access-token --resource "https://graph.microsoft.com" --query accessToken -o tsv
$headers = @{ Authorization = "Bearer $graphToken"; "Content-Type" = "application/json" }

# Microsoft Graph's own service principal (well-known appId, same in every tenant)
$graphSp = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '00000003-0000-0000-c000-000000000000'" -Headers $headers
$graphSpId = $graphSp.value[0].id

foreach ($roleName in $GraphAppRoles) {
    $role = $graphSp.value[0].appRoles | Where-Object { $_.value -eq $roleName -and $_.allowedMemberTypes -contains "Application" }
    if (-not $role) {
        Write-Warning "App role '$roleName' not found on Microsoft Graph service principal."
        continue
    }

    $body = @{
        principalId = $ManagedIdentityPrincipalId
        resourceId  = $graphSpId
        appRoleId   = $role.id
    } | ConvertTo-Json

    try {
        $result = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/servicePrincipals/$ManagedIdentityPrincipalId/appRoleAssignments" -Headers $headers -Method Post -Body $body
        Write-Output "Granted: $roleName (assignment id $($result.id))"
    } catch {
        Write-Output "FAILED: $roleName - $($_.Exception.Message)"
    }
}
