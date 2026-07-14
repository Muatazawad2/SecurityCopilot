# deploy.ps1 — Deploy Password Spray Auto-Alert Logic App
# Developer: Dr Muataz Awad
#
# What this deploys:
#   A Logic App that polls Entra ID Protection every N minutes for password spray
#   risk detections (riskEventType: passwordSpray). When detections are found, it
#   immediately sends an HTML alert email with affected accounts, source IPs,
#   locations, and response action guidance.
#   Uses System-Assigned Managed Identity — no stored credentials or OAuth connectors.
#
# Prerequisites:
#   1. Azure CLI installed and logged in (az login)
#   2. A valid sender mailbox in your tenant (e.g. security-alerts@company.com)
#   3. An existing resource group in Azure
#   4. Entra ID P2 license (required for Identity Protection risk detections)
#
# Usage:
#   .\deploy.ps1 -SenderEmail "security-alerts@company.com" `
#                -RecipientEmail "soc-team@company.com" `
#                -ResourceGroup "rg-security"

param(
    [Parameter(Mandatory = $true)]
    [string]$SenderEmail,                                   # Mailbox to send FROM (must exist in your tenant)

    [Parameter(Mandatory = $true)]
    [string]$RecipientEmail,                                # Email address to send alerts TO (user or DL)

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,                                 # Resource group name (must already exist)

    [string]$SubscriptionId          = "",                  # Your Azure subscription ID (optional)
    [string]$Location                = "eastus",            # Azure region
    [string]$LogicAppName            = "password-spray-auto-alert",
    [int]$PollingIntervalMinutes     = 30                   # Polling interval in minutes (5–60). Default: 30
)

$ErrorActionPreference = "Stop"

Write-Host "=== Password Spray Auto-Alert — Deploy ===" -ForegroundColor Cyan
Write-Host "Sender Email     : $SenderEmail"
Write-Host "Recipient        : $RecipientEmail"
Write-Host "Polling Interval : Every $PollingIntervalMinutes minutes"
Write-Host ""

# ── Set subscription ──────────────────────────────────────────────────────────
if ($SubscriptionId) {
    Write-Host "[1/3] Setting subscription..." -ForegroundColor Yellow
    az account set --subscription $SubscriptionId
}
az account show --query "{subscription:name}" -o table

# ── Deploy ARM template ───────────────────────────────────────────────────────
Write-Host "`n[2/3] Deploying Logic App..." -ForegroundColor Yellow

$templateFile = Join-Path $PSScriptRoot "azuredeploy.json"

$deployment = az deployment group create `
    --resource-group $ResourceGroup `
    --template-file $templateFile `
    --parameters logicAppName=$LogicAppName `
                 location=$Location `
                 senderEmail=$SenderEmail `
                 recipientEmail=$RecipientEmail `
                 pollingIntervalMinutes=$PollingIntervalMinutes `
    --query "properties.outputs" `
    -o json | ConvertFrom-Json

$principalId = $deployment.managedIdentityPrincipalId.value
$logicAppId  = $deployment.logicAppId.value

Write-Host "  Logic App deployed : $logicAppId" -ForegroundColor Green
Write-Host "  Managed Identity   : $principalId" -ForegroundColor Green

# ── Grant Graph permissions via Microsoft Graph API ───────────────────────────
Write-Host "`n[3/3] Granting Microsoft Graph permissions to Managed Identity..." -ForegroundColor Yellow
Write-Host "  Principal ID: $principalId" -ForegroundColor Gray

# Get the Microsoft Graph service principal ID in this tenant
$graphSpId = az ad sp show --id "00000003-0000-0000-c000-000000000000" --query "id" -o tsv

# Permissions needed:
#   IdentityRiskEvent.Read.All  — read password spray risk detections from Identity Protection
#   AuditLog.Read.All           — read sign-in logs for investigation context
#   Mail.Send                   — send alert emails via Microsoft Graph
$requiredPermissions = @(
    @{ Name = "IdentityRiskEvent.Read.All"; Id = "9e4862a5-b68f-479e-848a-4e07e25c9916" },
    @{ Name = "AuditLog.Read.All";          Id = "b0afded3-3588-46d8-8b3d-9842eff778da" },
    @{ Name = "Mail.Send";                  Id = "b633e1c5-b582-4048-a93e-9f11b44c7e96" }
)

foreach ($perm in $requiredPermissions) {
    Write-Host "  Granting: $($perm.Name)..." -ForegroundColor Gray

    $body = @{
        principalId = $principalId
        resourceId  = $graphSpId
        appRoleId   = $perm.Id
    } | ConvertTo-Json

    az rest --method POST `
        --url "https://graph.microsoft.com/v1.0/servicePrincipals/$principalId/appRoleAssignments" `
        --body $body `
        --headers "Content-Type=application/json" 2>$null | Out-Null

    Write-Host "    v $($perm.Name)" -ForegroundColor Green
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host "`n=== Deployment complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Logic App        : $LogicAppName"                                              -ForegroundColor Cyan
Write-Host "Polling Interval : Every $PollingIntervalMinutes minutes"                      -ForegroundColor Cyan
Write-Host "Alert Email      : $SenderEmail -> $RecipientEmail"                            -ForegroundColor Cyan
Write-Host "Graph Permissions: Granted v"                                                  -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Test the Logic App manually:"
Write-Host "     Azure Portal -> Logic Apps -> $LogicAppName -> Run Trigger"
Write-Host "  2. If no passwordSpray detections exist yet, the run will complete silently (no email)."
Write-Host "     To generate a test detection: Entra Portal -> Identity Protection -> Simulate risk."
Write-Host "  3. When a real detection fires, check $RecipientEmail for the alert email."
Write-Host ""
Write-Host "To view runs: https://portal.azure.com/#resource$logicAppId/overview"
