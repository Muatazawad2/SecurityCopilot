# deploy.ps1 — Deploy SOC IOC Enricher to Azure Container Apps
# Developer: Dr Muataz Awad
#
# Run this from inside the SOC IOC Enricher folder:
#   cd "MCP Module/SOC IOC Enricher"
#   .\deploy.ps1
#
# Prerequisites: Run Infrastructure/setup.ps1 ONCE first to create the shared environment.

param(
    [string]$SubscriptionId  = "",              # Your Azure subscription ID
    [string]$ResourceGroup   = "SecurityCopilot",
    [string]$AcrName         = "",              # Must be globally unique, lowercase, 5-50 chars
    [string]$AppName         = "soc-ioc-enricher",
    [string]$EnvironmentName = "soc-mcp-environment",
    [string]$AbuseIpdbKey    = "",        # Free key: https://www.abuseipdb.com/register
    [string]$VirusTotalKey   = "",        # Free key: https://www.virustotal.com/gui/sign-in
    [string]$OtxApiKey       = "",        # Free key: https://otx.alienvault.com/api
    [string]$UrlscanApiKey   = ""         # Free key: https://urlscan.io/user/signup
)

$ErrorActionPreference = "Stop"

Write-Host "=== SOC IOC Enricher — Deploy to Azure Container Apps ===" -ForegroundColor Cyan

# Set subscription
az account set --subscription $SubscriptionId

# ── Step 1 & 2: Build and push image directly in Azure 
$imageTag = "$AcrName.azurecr.io/$AppName`:latest"
Write-Host "`n[1/4] Building image in Azure Container Registry: $imageTag" -ForegroundColor Yellow
Write-Host "  (Using ACR Tasks — no local Docker required)" -ForegroundColor Gray
az acr build `
    --registry $AcrName `
    --image "$AppName`:latest" `
    --platform linux/amd64 `
    .

# ── Step 3: Get ACR credentials ─────────────────────────────────────────────
$acrUser = az acr credential show --name $AcrName --query "username" -o tsv
$acrPass = az acr credential show --name $AcrName --query "passwords[0].value" -o tsv

# ── Step 4: Create or update Container App ───────────────────────────────────
Write-Host "`n[3/4] Deploying Container App: $AppName..." -ForegroundColor Yellow

# Build environment variable string
$envVars = @("PORT=3000")
if ($AbuseIpdbKey)      { $envVars += "ABUSEIPDB_API_KEY=$AbuseIpdbKey" }
if ($VirusTotalKey)     { $envVars += "VIRUSTOTAL_API_KEY=$VirusTotalKey" }
if ($OtxApiKey)         { $envVars += "OTX_API_KEY=$OtxApiKey" }
if ($UrlscanApiKey)     { $envVars += "URLSCAN_API_KEY=$UrlscanApiKey" }

# Check if app already exists
$exists = az containerapp show --name $AppName --resource-group $ResourceGroup --query "name" -o tsv 2>$null

if ($exists) {
    Write-Host "  Updating existing Container App..." -ForegroundColor Gray
    az containerapp update `
        --name $AppName `
        --resource-group $ResourceGroup `
        --image $imageTag `
        --set-env-vars ($envVars -join " ")
} else {
    Write-Host "  Creating new Container App..." -ForegroundColor Gray
    az containerapp create `
        --name $AppName `
        --resource-group $ResourceGroup `
        --environment $EnvironmentName `
        --image $imageTag `
        --registry-server "$AcrName.azurecr.io" `
        --registry-username $acrUser `
        --registry-password $acrPass `
        --target-port 3000 `
        --ingress external `
        --min-replicas 0 `
        --max-replicas 5 `
        --cpu 0.25 `
        --memory 0.5Gi `
        --env-vars ($envVars -join " ")
}

# ── Output the endpoint ──────────────────────────────────────────────────────
Write-Host "`n[4/4] Retrieving endpoint..." -ForegroundColor Yellow
$fqdn = az containerapp show `
    --name $AppName `
    --resource-group $ResourceGroup `
    --query "properties.configuration.ingress.fqdn" -o tsv

Write-Host "`n=== Deployment complete! ===" -ForegroundColor Green
Write-Host "  MCP SSE endpoint: https://$fqdn/sse" -ForegroundColor Cyan
Write-Host "  Health check:     https://$fqdn/health" -ForegroundColor Cyan
Write-Host "`nConfigure Security Copilot to connect to: https://$fqdn/sse"
