# deploy.ps1 — Deploy Daily Risky User Digest Logic App
# Developer: Dr Muataz Awad
#
# What this deploys:
#   A Logic App that runs daily and sends an email listing all HIGH and MEDIUM
#   risk users from Entra ID Identity Protection. Uses Microsoft Graph API with
#   Managed Identity — no credentials or connectors needed.
#
# Prerequisites:
#   1. Azure CLI installed and logged in (az login)
#   2. A valid sender mailbox in your tenant (e.g. security-alerts@company.com)
#   3. An existing resource group in Azure
#
# Usage:
#   .\deploy.ps1 -SenderEmail "security-alerts@company.com" `
#                -RecipientEmail "soc-team@company.com"

param(
    [Parameter(Mandatory = $true)]
    [string]$SenderEmail,                               # Mailbox to send FROM (must exist in your tenant)

    [Parameter(Mandatory = $true)]
    [string]$RecipientEmail,                            # Email address to send TO (user or DL)

    [string]$SubscriptionId  = "",                      # Your Azure subscription ID
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,                             # Resource group name (must exist)
    [string]$Location        = "eastus",                # Azure region
    [string]$LogicAppName    = "daily-risky-user-digest",
    [int]$ScheduleHour       = 8,                       # Hour (UTC) to send digest. 8 = 8:00 AM UTC
    [string]$RiskLevelFilter = "high,medium"            # "high" or "high,medium"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Daily Risky User Digest — Deploy ===" -ForegroundColor Cyan
Write-Host "Sender Email  : $SenderEmail"
Write-Host "Recipient     : $RecipientEmail"
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
                 scheduleHour=$ScheduleHour `
                 riskLevelFilter=$RiskLevelFilter `
    --query "properties.outputs" `
    -o json | ConvertFrom-Json

$principalId = $deployment.managedIdentityPrincipalId.value
$logicAppId  = $deployment.logicAppId.value

Write-Host "  Logic App deployed: $logicAppId" -ForegroundColor Green
Write-Host "  Managed Identity:   $principalId" -ForegroundColor Green

# ── Grant Graph permissions via Microsoft Graph API ───────────────────────────
Write-Host "`n[3/3] Granting Microsoft Graph permissions to Managed Identity..." -ForegroundColor Yellow
Write-Host "  Principal ID: $principalId" -ForegroundColor Gray

# Get the Microsoft Graph service principal ID in this tenant
$graphSpId = az ad sp show --id "00000003-0000-0000-c000-000000000000" --query "id" -o tsv

# Permissions needed:
#   IdentityRiskyUser.Read.All   — read risky users from Identity Protection
#   User.Read.All                — read user sign-in activity
#   AuditLog.Read.All            — read sign-in logs (for future expansion)
$requiredPermissions = @(
    @{ Name = "IdentityRiskyUser.Read.All"; Id = "dc5007c0-2d7d-4c42-879c-2dab87571379" },
    @{ Name = "User.Read.All";              Id = "df021288-bdef-4463-88db-98f22de89214" },
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

    Write-Host "    ✓ $($perm.Name)" -ForegroundColor Green
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host "`n=== Deployment complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Logic App    : $LogicAppName" -ForegroundColor Cyan
Write-Host "Schedule     : Daily at $ScheduleHour`:00 UTC" -ForegroundColor Cyan
Write-Host "Email         : $SenderEmail → $RecipientEmail" -ForegroundColor Cyan
Write-Host "Graph Access : Granted ✓" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Test the Logic App manually: Azure Portal → Logic Apps → $LogicAppName → Run Trigger"
Write-Host "  2. Check your inbox ($RecipientEmail) for the first digest email"
Write-Host "  3. If no risky users exist, create a test: Entra → Identity Protection → Simulate risk"
Write-Host ""
Write-Host "To view runs: https://portal.azure.com/#resource$logicAppId/overview"
