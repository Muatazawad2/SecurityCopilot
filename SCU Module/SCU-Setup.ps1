<#
.SYNOPSIS
    ONE-TIME setup for the Security Copilot SCU reporting solution.
    Registers an Entra app, grants consent, signs you in via device code,
    and saves a DPAPI-encrypted refresh token for silent daily runs.

.DESCRIPTION
    Run this once per user per tenant. After this succeeds, use SCU-Run.ps1
    every day to pull data + build the Power BI and HTML dashboards.

    What this script does:
      1. Checks prereqs (PowerShell 7, Azure CLI, ImportExcel)
      2. Signs into Azure CLI (browser opens once)
      3. Creates an Entra app named 'SCU-Usage-Puller' in the current tenant
         (or reuses an existing one via -AppId)
      4. Adds Purview.DelegatedAccess permission and grants admin consent
      5. Prompts device-code sign-in and saves an encrypted refresh token
         to $env:USERPROFILE\.scu-puller\

    Refresh token stays valid ~90 days. If it expires, just run SCU-Setup.ps1 again.

.PARAMETER AppName
    Display name for the Entra app. Default: SCU-Usage-Puller

.PARAMETER AppId
    If your admin pre-registered the app, pass its Client ID here to skip creation.

.PARAMETER Capacity
    Name of your Security Copilot capacity resource in this tenant. If omitted,
    the script prompts for it. Saved to config.json and used to build the
    usage API URL.

.PARAMETER ConfigDir
    Where the config + encrypted refresh token are stored.
    Default: $env:USERPROFILE\.scu-puller

.EXAMPLE
    .\SCU-Setup.ps1
    # Runs the full end-to-end setup: creates app, grants consent, signs in.
    # Prompts for your Security Copilot capacity name.

.EXAMPLE
    .\SCU-Setup.ps1 -AppId 1a2b3c4d-5e6f-7890-abcd-ef1234567890
    # Uses an existing app your admin registered; skips creation.
#>
[CmdletBinding()]
param(
    [string]$AppName    = 'SCU-Usage-Puller',
    [string]$AppId,
    [string]$Capacity,
    [string]$ConfigDir  = "$env:USERPROFILE\.scu-puller"
)

$ErrorActionPreference = 'Stop'

# ---- Constants (same for every tenant) ----
$PurviewAppId     = '73c2949e-da2d-457a-9607-fcc665198967'  # Microsoft Purview SPN
$DelegatedScopeId = '817468d0-81dd-4cb5-94ac-07ca133fbbf6'  # Purview.DelegatedAccess
$AppRoleId        = '8d48872e-7710-4001-bfd0-7dac15c28f69'  # Purview app role
$PodId            = 'ee221a39-3ce7-48ee-8b63-18bd56c52288'  # Security Copilot US pod
$Workspace        = 'default'

function Write-Step($m) { Write-Host "`n===  $m  ===" -ForegroundColor Cyan }
function Write-OK($m)   { Write-Host "  [OK]   $m" -ForegroundColor Green }
function Write-Warn($m) { Write-Host "  [WARN] $m" -ForegroundColor Yellow }
function Write-Fail($m) { Write-Host "  [FAIL] $m" -ForegroundColor Red }

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  Security Copilot SCU Reporting - Setup" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

# ---- 1. Prereqs ----
Write-Step "1/5  Checking prerequisites"

if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Fail "PowerShell 7+ required (you have $($PSVersionTable.PSVersion))."
    Write-Fail "Install: winget install Microsoft.PowerShell"
    exit 1
}
Write-OK "PowerShell $($PSVersionTable.PSVersion)"

$azOk = $false
try {
    $ver = az version 2>&1 | ConvertFrom-Json
    $azOk = $true
    Write-OK "Azure CLI $($ver.'azure-cli')"
} catch { Write-Verbose "az version failed: $_" }
if (-not $azOk) {
    Write-Fail "Azure CLI missing. Install: winget install Microsoft.AzureCLI"
    exit 1
}

if (-not (Get-Module -ListAvailable ImportExcel)) {
    Write-Warn "ImportExcel module missing - installing..."
    Install-Module ImportExcel -Force -Scope CurrentUser -AcceptLicense | Out-Null
}
Write-OK "ImportExcel installed"

# ---- 2. Azure login ----
Write-Step "2/5  Azure sign-in"
$acct = az account show 2>$null | ConvertFrom-Json
if (-not $acct) {
    Write-Host "  A browser will open. Sign in with an account that has access to Security Copilot."
    az login --allow-no-subscriptions | Out-Null
    $acct = az account show | ConvertFrom-Json
}
$tenantId = $acct.tenantId
Write-OK "Signed in as $($acct.user.name) in tenant $tenantId"

# ---- Security Copilot capacity (per-tenant; provide via -Capacity or prompt) ----
if (-not $Capacity) {
    $Capacity = (Read-Host "  Enter your Security Copilot capacity name").Trim()
}
if (-not $Capacity) {
    Write-Fail "Capacity name is required. Re-run with -Capacity <name>."
    exit 1
}
Write-OK "Using capacity '$Capacity'"

# ---- 3. App registration ----
Write-Step "3/5  Entra app registration"
$isNew = $false
if ($AppId) {
    Write-Host "  Using provided AppId: $AppId"
    $app = az ad app show --id $AppId --only-show-errors 2>$null | ConvertFrom-Json
    if (-not $app) { Write-Fail "AppId $AppId not found in this tenant."; exit 1 }
    $clientId = $app.appId
    Write-OK "Reusing app '$($app.displayName)' (AppId $clientId)"
} else {
    $existing = az ad app list --display-name $AppName --only-show-errors -o json | ConvertFrom-Json
    if ($existing -and $existing.Count -gt 0) {
        $clientId = $existing[0].appId
        Write-OK "Found existing app '$AppName' (AppId $clientId) - reusing"
    } else {
        Write-Host "  Creating new app '$AppName'..."
        $created = az ad app create --display-name $AppName --sign-in-audience AzureADMyOrg --only-show-errors -o json | ConvertFrom-Json
        $clientId = $created.appId
        $isNew = $true
        Write-OK "Created app (AppId $clientId)"
    }
}

# Ensure the app is fully configured - idempotent, runs for BOTH new and reused apps
# so any AppId (even a bare one handed over by an admin) ends up correctly set up.
Write-Host "  Ensuring Purview permissions + public-client (device-code) flow..."
az ad app permission add --id $clientId --api $PurviewAppId --api-permissions "$DelegatedScopeId=Scope" --only-show-errors 2>&1 | Out-Null
az ad app permission add --id $clientId --api $PurviewAppId --api-permissions "$AppRoleId=Role" --only-show-errors 2>&1 | Out-Null
az ad app update --id $clientId --is-fallback-public-client true --only-show-errors 2>&1 | Out-Null

# Ensure a service principal exists (az ad sp create errors if one already exists, so check first)
$spJson = az ad sp show --id $clientId --only-show-errors 2>$null
$sp = if ($spJson) { $spJson | ConvertFrom-Json } else { $null }
if (-not $sp) {
    if ($isNew) { Start-Sleep -Seconds 3 }  # give a brand-new app time to replicate
    az ad sp create --id $clientId --only-show-errors 2>&1 | Out-Null
    Write-OK "Service principal created"
} else {
    Write-OK "Service principal already present"
}
Write-OK "App configuration ensured (permissions + public-client flow)"

# ---- 4. Admin consent ----
Write-Step "4/5  Admin consent"
Write-Host "  Requesting admin consent for Purview.DelegatedAccess..."
Start-Sleep -Seconds 3
$consentOk = $true
try {
    az ad app permission admin-consent --id $clientId --only-show-errors 2>&1 | Out-Null
    Start-Sleep -Seconds 8
    $sp = az ad sp show --id $clientId --only-show-errors | ConvertFrom-Json
    $grants = az rest --method get --uri "https://graph.microsoft.com/v1.0/oauth2PermissionGrants?`$filter=clientId eq '$($sp.id)'" --only-show-errors | ConvertFrom-Json
    if ($grants.value.Count -gt 0) {
        Write-OK "Consent granted ($($grants.value[0].scope))"
    } else {
        Write-Warn "Consent may still be propagating - continuing"
    }
} catch {
    Write-Warn "Consent failed (you may not be a privileged admin)."
    Write-Warn "Ask an admin to visit:"
    Write-Warn "  https://login.microsoftonline.com/$tenantId/adminconsent?client_id=$clientId"
    $consentOk = $false
}

# ---- 5. Config + refresh token ----
Write-Step "5/5  Sign-in / refresh-token seed"
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null
$config = @{
    tenantId    = $tenantId
    clientId    = $clientId
    apiAudience = $PurviewAppId
    podId       = $PodId
    workspace   = $Workspace
    capacity    = $Capacity
} | ConvertTo-Json
[System.IO.File]::WriteAllText((Join-Path $ConfigDir 'config.json'), $config)
Write-OK "Config saved to $ConfigDir\config.json"

$scope = "$PurviewAppId/Purview.DelegatedAccess offline_access"
$tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$rtPath = Join-Path $ConfigDir 'refresh_token.dat'

$tok = $null
if (Test-Path $rtPath) {
    try {
        $encRt = (Get-Content $rtPath -Raw).Trim()
        $secRt = ConvertTo-SecureString $encRt
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secRt)
        $rtVal = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        $tok = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body @{
            grant_type = 'refresh_token'
            client_id = $clientId
            refresh_token = $rtVal
            scope = $scope
        } -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
        Write-OK "Existing refresh token still valid - no sign-in needed"
    } catch {
        Write-Warn "Existing refresh token expired or invalid - re-signing in"
        $tok = $null
    }
}

if (-not $tok) {
    $dc = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/devicecode" -Body @{
        client_id = $clientId
        scope = $scope
    } -ContentType 'application/x-www-form-urlencoded'
    Write-Host ""
    Write-Host "  +---------------------------------------------------------+" -ForegroundColor Yellow
    Write-Host "  |  Open:  $($dc.verification_uri)" -ForegroundColor Yellow
    Write-Host "  |  Code:  $($dc.user_code)" -ForegroundColor Yellow
    Write-Host "  +---------------------------------------------------------+" -ForegroundColor Yellow

    try { Start-Process $dc.verification_uri } catch { Write-Verbose "Could not auto-open browser: $_" }

    $deadline = (Get-Date).AddSeconds($dc.expires_in)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Seconds $dc.interval
        try {
            $tok = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body @{
                grant_type = 'urn:ietf:params:oauth:grant-type:device_code'
                client_id = $clientId
                device_code = $dc.device_code
            } -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
            break
        } catch {
            $err = ($_.ErrorDetails.Message | ConvertFrom-Json).error
            if ($err -eq 'authorization_pending' -or $err -eq 'slow_down') { continue }
            Write-Fail "Sign-in failed: $err"
            exit 1
        }
    }
    if (-not $tok) { Write-Fail "Sign-in timed out"; exit 1 }
}

if ($tok.refresh_token) {
    $secure = ConvertTo-SecureString $tok.refresh_token -AsPlainText -Force
    [System.IO.File]::WriteAllText($rtPath, ($secure | ConvertFrom-SecureString))
}
$jwtParts = $tok.access_token.Split('.')
$pad = $jwtParts[1].PadRight($jwtParts[1].Length + (4 - $jwtParts[1].Length % 4) % 4, '=').Replace('-','+').Replace('_','/')
$upn = ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($pad)) | ConvertFrom-Json).upn
Write-OK "Signed in as $upn (refresh token cached for silent renewal)"

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Config:  $ConfigDir"
Write-Host "  AppId:   $clientId"
Write-Host "  Tenant:  $tenantId"
Write-Host ""
Write-Host "  Next step: run the daily one-liner:" -ForegroundColor Cyan
Write-Host "    .\SCU-Run.ps1" -ForegroundColor White
Write-Host ""
if (-not $consentOk) {
    Write-Warn "REMINDER: admin consent was not granted automatically."
    Write-Warn "Have an admin visit the URL above before running SCU-Run.ps1."
}
