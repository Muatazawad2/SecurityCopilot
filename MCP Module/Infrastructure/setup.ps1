# setup.ps1 — One-time Azure infrastructure setup for all MCP servers
# Developer: Dr Muataz Awad
#
# Run this ONCE. It creates:
#   1. Azure Container Registry (ACR) — stores Docker images for all MCP servers
#   2. Azure Container Apps environment — shared runtime for all MCP servers
#
# After this runs once, deploy individual servers using their own deploy.ps1 scripts.

param(
    [string]$SubscriptionId  = "",              # Your Azure subscription ID
    [string]$ResourceGroup   = "SecurityCopilot",
    [string]$Location        = "eastus",
    [string]$AcrName         = "",              # Must be globally unique, lowercase, 5-50 chars
    [string]$EnvironmentName = "soc-mcp-environment"    # Container Apps environment name
)

$ErrorActionPreference = "Stop"

Write-Host "=== MCP Infrastructure Setup ===" -ForegroundColor Cyan
Write-Host "Subscription : $SubscriptionId"
Write-Host "Resource Group: $ResourceGroup"
Write-Host "Location      : $Location"
Write-Host "ACR Name      : $AcrName"
Write-Host "Environment   : $EnvironmentName"
Write-Host ""

# ── Authenticate and set subscription ────────────────────────────────────────
Write-Host "[1/4] Setting Azure subscription..." -ForegroundColor Yellow
az account set --subscription $SubscriptionId
az account show --query "name" -o tsv

# ── Install Container Apps extension if not present ──────────────────────────
Write-Host "`n[2/4] Ensuring required Azure CLI extensions are installed..." -ForegroundColor Yellow
az extension add --name containerapp --upgrade --yes 2>$null
az provider register --namespace Microsoft.App --wait 2>$null
az provider register --namespace Microsoft.OperationalInsights --wait 2>$null

# ── Create Azure Container Registry ──────────────────────────────────────────
Write-Host "`n[3/4] Creating Azure Container Registry: $AcrName" -ForegroundColor Yellow

$acrExists = az acr show --name $AcrName --resource-group $ResourceGroup --query "name" -o tsv 2>$null
if ($acrExists) {
    Write-Host "  ACR already exists — skipping creation." -ForegroundColor Gray
} else {
    az acr create `
        --resource-group $ResourceGroup `
        --name $AcrName `
        --location $Location `
        --sku Basic `
        --admin-enabled true

    Write-Host "  ACR created: $AcrName.azurecr.io" -ForegroundColor Green
}

# ── Create Container Apps Environment ────────────────────────────────────────
Write-Host "`n[4/4] Creating Container Apps environment: $EnvironmentName" -ForegroundColor Yellow

$envExists = az containerapp env show --name $EnvironmentName --resource-group $ResourceGroup --query "name" -o tsv 2>$null
if ($envExists) {
    Write-Host "  Environment already exists — skipping creation." -ForegroundColor Gray
} else {
    az containerapp env create `
        --name $EnvironmentName `
        --resource-group $ResourceGroup `
        --location $Location

    Write-Host "  Environment created: $EnvironmentName" -ForegroundColor Green
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host "`n=== Infrastructure ready! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Container Registry : $AcrName.azurecr.io" -ForegroundColor Cyan
Write-Host "Container Apps Env : $EnvironmentName" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next step: deploy individual MCP servers using their deploy.ps1 scripts."
Write-Host "Example:"
Write-Host "  cd '../SOC IOC Enricher'"
Write-Host "  .\deploy.ps1"
