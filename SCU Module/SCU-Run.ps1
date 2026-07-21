<#
.SYNOPSIS
    Daily one-liner for the Security Copilot SCU reporting solution.
    Pulls fresh data, rebuilds the Power BI template + HTML dashboard, opens both.

.DESCRIPTION
    Run this every time you want to refresh your SCU dashboards. Must run SCU-Setup.ps1
    first to register the Entra app and sign in.

    What this script does end-to-end:
      1. Pulls fresh SCU data from the Security Copilot portal API +
         Azure Cost Management + Microsoft Graph.
         Writes: scu-output\SCU-Report.xlsx + scu-output\SCU-Report.json
      2. Rebuilds the Power BI template with 9 pages of visuals.
         Writes: scu-output\SCU-Dashboard.pbit
      3. Rebuilds the self-contained HTML dashboard (9 tabs, Chart.js).
         Writes: scu-output\SCU-Dashboard.html
      4. Opens Power BI Desktop + the HTML in your default browser.

.PARAMETER OutDir
    Where all output files land. Default: .\scu-output next to this script.

.PARAMETER Days
    Data window in days. Default: 90.

.PARAMETER ConfigDir
    Where the encrypted refresh token + config live.
    Default: $env:USERPROFILE\.scu-puller (must match what SCU-Setup.ps1 used)

.PARAMETER NoRefresh
    Skip the data pull - just rebuild dashboards from the existing SCU-Report.xlsx/json.

.PARAMETER SkipPbit
    Skip regenerating the .pbit template (faster; useful when template hasn't changed).

.PARAMETER SkipHtml
    Skip regenerating the HTML dashboard.

.PARAMETER HtmlOnly
    Skip everything Power BI: don't rebuild PBIT, don't launch Power BI Desktop.
    Still refreshes data + regenerates HTML + opens it in the browser.

.PARAMETER NoOpen
    Regenerate everything, but don't open Power BI / browser. Great for scheduled runs.

.EXAMPLE
    .\SCU-Run.ps1
    # Full refresh - pull data, rebuild both dashboards, open both.

.EXAMPLE
    .\SCU-Run.ps1 -HtmlOnly
    # Skip Power BI entirely (Mac users, restricted machines).

.EXAMPLE
    .\SCU-Run.ps1 -NoRefresh -NoOpen
    # Rebuild visuals from cached data, do not open anything (CI/scheduled use).
#>
[CmdletBinding()]
param(
    [string]$OutDir    = (Join-Path $PSScriptRoot 'scu-output'),
    [int]$Days         = 90,
    [string]$ConfigDir = "$env:USERPROFILE\.scu-puller",
    [switch]$NoRefresh,
    [switch]$SkipPbit,
    [switch]$SkipHtml,
    [switch]$HtmlOnly,
    [switch]$NoOpen
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

function Write-Section($msg) {
    Write-Host ""
    Write-Host "==> $msg" -ForegroundColor Cyan
}
function Write-Ok($msg)   { Write-Host "    OK: $msg" -ForegroundColor Green }
function Write-Warn2($msg) { Write-Host "    !!  $msg" -ForegroundColor Yellow }


# ============================================================
#region Puller (from Get-SCUUsage.ps1)
# ============================================================
function Invoke-ScuPull {
    param(
        [int]$Days,
        [string]$OutDir,
        [string]$ConfigDir
    )
# ---------- Load config ----------
$configPath = Join-Path $ConfigDir 'config.json'
$refreshTokenPath = Join-Path $ConfigDir 'refresh_token.dat'
if (-not (Test-Path $configPath)) { throw "Config not found at $configPath. Run seed step first." }
$cfg = Get-Content $configPath -Raw | ConvertFrom-Json
$tokenEndpoint = "https://login.microsoftonline.com/$($cfg.tenantId)/oauth2/v2.0/token"
$deviceEndpoint = "https://login.microsoftonline.com/$($cfg.tenantId)/oauth2/v2.0/devicecode"
$scope = "$($cfg.apiAudience)/Purview.DelegatedAccess offline_access"

# ---------- Token acquisition ----------
function Save-RefreshToken([string]$rt) {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText','')]
    $secure = ConvertTo-SecureString $rt -AsPlainText -Force
    $enc = $secure | ConvertFrom-SecureString
    [System.IO.File]::WriteAllText($refreshTokenPath, $enc)
}
function Read-RefreshToken {
    if (-not (Test-Path $refreshTokenPath)) { return $null }
    $enc = (Get-Content $refreshTokenPath -Raw).Trim()
    if (-not $enc) { return $null }
    $secure = ConvertTo-SecureString $enc
    $b = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try { [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($b) }
    finally { [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b) }
}
function Invoke-DeviceCodeLogin {
    Write-Host "  No usable refresh token; starting device-code login..." -ForegroundColor Yellow
    $dc = Invoke-RestMethod -Method Post -Uri $deviceEndpoint -Body @{
        client_id = $cfg.clientId; scope = $scope
    } -ContentType 'application/x-www-form-urlencoded'
    Write-Host "  --> Open $($dc.verification_uri) and enter $($dc.user_code)" -ForegroundColor Cyan
    $deadline = (Get-Date).AddSeconds($dc.expires_in)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Seconds $dc.interval
        try {
            return Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body @{
                grant_type = 'urn:ietf:params:oauth:grant-type:device_code'
                client_id = $cfg.clientId; device_code = $dc.device_code
            } -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
        } catch {
            $err = ($_.ErrorDetails.Message | ConvertFrom-Json).error
            if ($err -eq 'authorization_pending' -or $err -eq 'slow_down') { continue }
            throw
        }
    }
    throw "Device-code login timed out."
}
function Get-AccessToken {
    $rt = Read-RefreshToken
    if ($rt) {
        try {
            $t = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body @{
                grant_type = 'refresh_token'; client_id = $cfg.clientId
                refresh_token = $rt; scope = $scope
            } -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
            if ($t.refresh_token) { Save-RefreshToken $t.refresh_token }
            return $t.access_token
        } catch {
            Write-Host "  Refresh token failed; falling back to device code." -ForegroundColor Yellow
        }
    }
    $t = Invoke-DeviceCodeLogin
    if ($t.refresh_token) { Save-RefreshToken $t.refresh_token }
    return $t.access_token
}

# ---------- API calls ----------
$base = "https://us.api.securityplatform.microsoft.com/pods/$($cfg.podId)/workspaces/$($cfg.workspace)/securitycopilot/usage/$($cfg.capacity)"
$baseRoot = "https://us.api.securityplatform.microsoft.com/pods/$($cfg.podId)/workspaces/$($cfg.workspace)/securitycopilot"
Write-Host "SCU Puller | capacity=$($cfg.capacity) | window=${Days}d | out=$OutDir" -ForegroundColor Green
Write-Host "Acquiring token..."
$token = Get-AccessToken
$H = @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' }
$end   = (Get-Date).ToUniversalTime()
$start = $end.AddDays(-$Days)
$fmt   = "yyyy-MM-ddTHH:mm:ss.fffZ"
$window = @{ startDate = $start.ToString($fmt); endDate = $end.ToString($fmt) }

function Invoke-SCUPost([string]$path, [hashtable]$extraBody = @{}) {
    $body = ($window + $extraBody) | ConvertTo-Json -Depth 5
    Invoke-RestMethod -Method Post -Uri "$base/$path" -Headers $H -Body $body -ErrorAction Stop
}

Write-Host "`nPulling hourly aggregates..."
$hourly = (Invoke-SCUPost 'aggregates/hourly').value
Write-Host "  $($hourly.Count) rows, total SCU: $([math]::Round(($hourly|Measure-Object usedCapacity -Sum).Sum,3))"

Write-Host "Pulling per-session table (paginated)..."
$sessions = @()
$page = 1
while ($true) {
    $r = Invoke-SCUPost 'aggregates/dimensional' @{
        users=@(); experiences=@(); invocationTypes=@(); plugins=@();
        categories=@(); invocationCategories=@();
        pageSize=200; pageNumber=$page; sortingDirection='descending'
    }
    if (-not $r.value -or $r.value.Count -eq 0) { break }
    $sessions += $r.value
    Write-Host "  page $page -> $($r.value.Count) rows"
    if ($r.value.Count -lt 200) { break }
    $page++
    if ($page -gt 500) { break }
}
Write-Host "  Total: $($sessions.Count) sessions"

Write-Host "Pulling facets..."
$null = Invoke-RestMethod -Method Get -Uri "$base/facets?startDate=$([uri]::EscapeDataString($window.startDate))&endDate=$([uri]::EscapeDataString($window.endDate))" -Headers $H

# ---------- NEW: Additional data sources ----------
Write-Host "Pulling session catalog (rich context /sessions endpoint)..."
$sessionCatalog = @()
try {
    $sc = Invoke-RestMethod -Method Get -Uri "$baseRoot/sessions?limit=200&sortBy=UpdatedAt&sortDirection=desc&enablePagination=true" -Headers $H -ErrorAction Stop
    $sessionCatalog = if ($sc.value) { $sc.value } else { @($sc) }
    Write-Host "  $($sessionCatalog.Count) session catalog entries"
} catch { Write-Host "  Skipped: $($_.Exception.Message)" }

Write-Host "Pulling skillset catalog (available plugins)..."
$skillsetCatalog = @()
try {
    $sk = Invoke-RestMethod -Method Get -Uri "$baseRoot/skillsets" -Headers $H -ErrorAction Stop
    $skillsetCatalog = if ($sk.value) { $sk.value } elseif ($sk -is [array]) { $sk } else { @($sk) }
    Write-Host "  $($skillsetCatalog.Count) skillsets/plugins in catalog"
} catch { Write-Host "  Skipped: $($_.Exception.Message)" }

Write-Host "Pulling promptbooks..."
$promptbookCatalog = @()
try {
    $pb = Invoke-RestMethod -Method Get -Uri "$baseRoot/promptbooks" -Headers $H -ErrorAction Stop
    $promptbookCatalog = if ($pb.value) { $pb.value } elseif ($pb -is [array]) { $pb } else { @($pb) }
    Write-Host "  $($promptbookCatalog.Count) promptbooks"
} catch { Write-Host "  Skipped: $($_.Exception.Message)" }

Write-Host "Pulling workspace settings..."
$workspaceSettings = $null
try {
    $workspaceSettings = Invoke-RestMethod -Method Get -Uri "$baseRoot/WorkspaceSettings" -Headers $H -ErrorAction Stop
    Write-Host "  Workspace settings retrieved"
} catch { Write-Host "  Skipped: $($_.Exception.Message)" }

# ---------- Flatten & save ----------
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

# ---------- AAD user resolution (resolve agent GUIDs to real user context) ----------
Write-Host "Resolving user identities via Microsoft Graph..."
$userLookup = @{}
$uniqueUsers = $sessions | Select-Object -ExpandProperty userName -Unique
foreach ($u in $uniqueUsers) {
    if (-not $u) { continue }
    $friendly = $u
    $isAgentUser = $u -match '^SecurityCopilotAgentUser-([0-9a-f\-]{36})'
    if ($isAgentUser) {
        # Agent identities represent an agent, not a person - label them as such
        $agentGuid = $Matches[1]
        $friendly = "Agent-$($agentGuid.Substring(0,8))"
    } else {
        # Try to resolve to display name via Graph
        try {
            $upn = if ($u -match '@') { $u } else { $null }
            if ($upn) {
                $graphToken = az account get-access-token --resource 'https://graph.microsoft.com' --query accessToken -o tsv 2>$null
                if ($graphToken) {
                    $person = Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/users/$upn" -Headers @{ Authorization = "Bearer $graphToken" } -ErrorAction Stop
                    if ($person.displayName) { $friendly = $person.displayName }
                }
            }
        } catch { Write-Verbose "Graph lookup failed for $u : $_" }
    }
    $userLookup[$u] = @{
        FriendlyName = $friendly
        IsAgentUser  = $isAgentUser
        AgentGuid    = if ($isAgentUser) { $Matches[1] } else { $null }
    }
}
Write-Host "  Resolved $($userLookup.Count) unique identities"

$sessFlat = $sessions | ForEach-Object {
    $dt = [datetime]$_.aggregateStartTime
    $u = $_.userName
    $lu = if ($userLookup.ContainsKey($u)) { $userLookup[$u] } else { @{ FriendlyName=$u; IsAgentUser=$false } }
    [pscustomobject]@{
        Date         = $dt.ToString('yyyy-MM-dd HH:mm:ss')
        SessionId    = $_.sessionId
        SCU_Used     = [math]::Round([double]$_.usedCapacity, 4)
        User         = $u
        UserFriendly = $lu.FriendlyName
        IsAgent      = $lu.IsAgentUser
        Department   = $_.userDepartment
        Category     = $_.invocationCategory
        Type         = $_.invocationType
        Experience   = $_.copilotExperience
        Plugins      = ($_.skillSetNames -join '; ')
        PluginCount  = ($_.skillSetNames | Measure-Object).Count
        Skills       = ($_.skillNames -join '; ')
        SkillCount   = ($_.skillNames | Measure-Object).Count
        UsageType    = $_.usageType
        Workload     = $_.workload
        EvaluationId = $_.evaluationId
        Status       = $_.status
        SourceApp    = $_.unauthenticatedSourceApplicationId
    }
}
$hourFlat = $hourly | ForEach-Object {
    $dt = [datetime]$_.aggregateStartTime
    [pscustomobject]@{
        Hour           = $dt.ToString('yyyy-MM-dd HH:mm')
        Day            = $dt.ToString('yyyy-MM-dd')
        HourOfDay      = $dt.Hour
        DayOfWeek      = $dt.DayOfWeek.ToString()
        DayOfWeekNum   = [int]$dt.DayOfWeek
        SCU_Used       = [math]::Round($_.usedCapacity, 4)
        ProvisionedSCU = $_.provisionedSCUUsed
        OverageSCU     = [math]::Round($_.overageSCUUsed, 4)
        OverageState   = $_.overageState
    }
} | Sort-Object Hour

# ---------- Daily rollup with rolling averages + anomaly flags ----------
Write-Host "Computing daily rollup with rolling averages..."
$dailyGroups = $hourFlat | Group-Object Day
$dailyRows = $dailyGroups | ForEach-Object {
    [pscustomobject]@{
        Day          = $_.Name
        SCU_Total    = [math]::Round(($_.Group | Measure-Object SCU_Used -Sum).Sum, 4)
        Overage_SCU  = [math]::Round(($_.Group | Measure-Object OverageSCU -Sum).Sum, 4)
        Hours_Active = ($_.Group | Where-Object { $_.SCU_Used -gt 0 }).Count
    }
} | Sort-Object Day

# Compute rolling averages + anomaly flags
$sortedDays = $dailyRows
$mean = ($sortedDays | Measure-Object SCU_Total -Average).Average
$stdev = if ($sortedDays.Count -gt 1) {
    [math]::Sqrt((($sortedDays | ForEach-Object { [math]::Pow($_.SCU_Total - $mean, 2) }) | Measure-Object -Sum).Sum / ($sortedDays.Count - 1))
} else { 0 }
$anomalyThreshold = $mean + (2 * $stdev)

$dailyEnriched = @()
for ($i = 0; $i -lt $sortedDays.Count; $i++) {
    $d = $sortedDays[$i]
    $roll7  = if ($i -ge 6) { $sortedDays[($i-6)..$i] | Measure-Object SCU_Total -Average | Select-Object -ExpandProperty Average } else { $null }
    $roll30 = if ($i -ge 29) { $sortedDays[($i-29)..$i] | Measure-Object SCU_Total -Average | Select-Object -ExpandProperty Average } else { $null }
    $prevDay = if ($i -gt 0) { $sortedDays[$i-1].SCU_Total } else { $null }
    $delta = if ($null -ne $prevDay) { [math]::Round($d.SCU_Total - $prevDay, 4) } else { $null }
    $dailyEnriched += [pscustomobject]@{
        Day             = $d.Day
        SCU_Total       = $d.SCU_Total
        Overage_SCU     = $d.Overage_SCU
        Hours_Active    = $d.Hours_Active
        Rolling_7d_Avg  = if ($null -ne $roll7) { [math]::Round($roll7, 4) } else { $null }
        Rolling_30d_Avg = if ($null -ne $roll30) { [math]::Round($roll30, 4) } else { $null }
        Prev_Day        = $prevDay
        Delta_vs_Prev   = $delta
        Is_Anomaly      = ($d.SCU_Total -gt $anomalyThreshold)
        Anomaly_Sigma   = if ($stdev -gt 0) { [math]::Round(($d.SCU_Total - $mean) / $stdev, 2) } else { 0 }
        Est_Cost_USD    = [math]::Round($d.SCU_Total * 6.0, 2)
    }
}

# ---------- Optional: Azure Cost Management (actual billed $) ----------
Write-Host "Pulling Azure Cost Management daily $ (if signed in)..."
$costDaily = @()
try {
    $sub = az account show --query id -o tsv 2>$null
    if ($sub -and $sub.Length -gt 10) {
        $today = (Get-Date).ToString('yyyy-MM-dd')
        $startWin = (Get-Date).AddDays(-$Days).ToString('yyyy-MM-dd')
        $body = @{
            type       = "ActualCost"
            timeframe  = "Custom"
            timePeriod = @{ from = "$startWin" + "T00:00:00Z"; to = "$today" + "T23:59:59Z" }
            dataset    = @{
                granularity = "Daily"
                aggregation = @{
                    totalCost  = @{ name = "Cost";          function = "Sum" }
                    totalUsage = @{ name = "UsageQuantity"; function = "Sum" }
                }
                grouping = @( @{ type = "Dimension"; name = "Meter" } )
                filter   = @{ dimensions = @{ name = "ServiceName"; operator = "In"; values = @("Microsoft Security Copilot") } }
            }
        } | ConvertTo-Json -Depth 10 -Compress
        $bf = [System.IO.Path]::GetTempFileName()
        Set-Content -Path $bf -Value $body -Encoding utf8
        $uri = "https://management.azure.com/subscriptions/$sub/providers/Microsoft.CostManagement/query?api-version=2023-11-01"
        $raw = az rest --method post --uri $uri --body "@$bf" -o json 2>&1
        $azExit = $LASTEXITCODE
        Remove-Item $bf -Force -ErrorAction SilentlyContinue
        if ($azExit -eq 0 -and $raw) {
            $resp = $raw | ConvertFrom-Json
            if ($resp.properties.rows -and $resp.properties.rows.Count -gt 0) {
                $cols = $resp.properties.columns.name
                $costDaily = $resp.properties.rows | ForEach-Object {
                    $r = $_
                    $obj = [ordered]@{}
                    for ($i=0; $i -lt $cols.Count; $i++) { $obj[$cols[$i]] = $r[$i] }
                    $ud = "$($obj.UsageDate)"
                    [pscustomobject]@{
                        Day         = ([datetime]::ParseExact($ud, 'yyyyMMdd', $null)).ToString('yyyy-MM-dd')
                        Actual_Cost = [math]::Round([double]$obj.Cost, 4)
                        Actual_SCU  = [math]::Round([double]$obj.UsageQuantity, 4)
                        Meter       = $obj.Meter
                        Currency    = $obj.Currency
                    }
                }
                Write-Host "  Pulled $($costDaily.Count) daily billing rows from Azure Cost Management"
            } else {
                Write-Host "  Cost API returned no rows (no Security Copilot billing in window)"
            }
        } else {
            Write-Host "  Cost API call failed (exit=$azExit)"
        }
    } else {
        Write-Host "  Skipped: az CLI not signed in (run: az login)"
    }
} catch {
    Write-Host "  Cost Management skipped: $($_.Exception.Message)"
}

$xlsxFinal = Join-Path $OutDir "SCU-Report.xlsx"

# Optional Excel workbook (if ImportExcel present)
if (Get-Module -ListAvailable ImportExcel) {
    Import-Module ImportExcel
    # Write to a temp file first, then atomically replace the final file to avoid
    # locking issues when Power BI is refreshing / OneDrive is syncing.
    $xlsx = Join-Path $OutDir "SCU-Report.building.xlsx"
    if (Test-Path $xlsx) { Remove-Item $xlsx -Force -ErrorAction SilentlyContinue }
    $totalScu = [math]::Round(($sessFlat | Measure-Object SCU_Used -Sum).Sum, 3)
    $sum = [pscustomobject]@{
        "Generated"      = (Get-Date).ToString('yyyy-MM-dd HH:mm')
        "Window"         = "Last $Days days"
        "Capacity"       = $cfg.capacity
        "Sessions"       = $sessFlat.Count
        "Total SCU"      = $totalScu
        "Est Cost USD"   = [math]::Round($totalScu * 6.0, 2)
        "Distinct Users" = ($sessFlat | Select-Object -ExpandProperty User -Unique).Count
        "Peak Session"   = [math]::Round(($sessFlat | Measure-Object SCU_Used -Maximum).Maximum, 3)
    }
    $sum | Export-Excel -Path $xlsx -WorksheetName "Summary" -AutoSize -MoveToStart
    $sessFlat | Export-Excel -Path $xlsx -WorksheetName "Sessions" -AutoSize -FreezeTopRow
    $hourFlat | Export-Excel -Path $xlsx -WorksheetName "Hourly"   -AutoSize -FreezeTopRow
    $dailyEnriched | Export-Excel -Path $xlsx -WorksheetName "Daily" -AutoSize -FreezeTopRow
    if ($costDaily) { $costDaily | Export-Excel -Path $xlsx -WorksheetName "Actual-Cost" -AutoSize -FreezeTopRow }

    # By-Plugin aggregate (with avg / max)
    $sessFlat | Group-Object Plugins | ForEach-Object {
        [pscustomobject]@{
            Plugin    = $_.Name
            Sessions  = $_.Count
            SCU       = [math]::Round(($_.Group | Measure-Object SCU_Used -Sum).Sum, 3)
            Avg_SCU   = [math]::Round(($_.Group | Measure-Object SCU_Used -Average).Average, 4)
            Max_SCU   = [math]::Round(($_.Group | Measure-Object SCU_Used -Maximum).Maximum, 3)
        }
    } | Sort-Object SCU -Descending | Export-Excel -Path $xlsx -WorksheetName "By-Plugin" -AutoSize -FreezeTopRow

    # By-User aggregate (with avg / max / distinct plugins)
    $sessFlat | Group-Object User | ForEach-Object {
        [pscustomobject]@{
            User          = $_.Name
            Department    = ($_.Group | Select-Object -First 1 -ExpandProperty Department)
            Sessions      = $_.Count
            SCU           = [math]::Round(($_.Group | Measure-Object SCU_Used -Sum).Sum, 3)
            Avg_SCU       = [math]::Round(($_.Group | Measure-Object SCU_Used -Average).Average, 4)
            Max_SCU       = [math]::Round(($_.Group | Measure-Object SCU_Used -Maximum).Maximum, 3)
            Distinct_Plugins = ($_.Group | Select-Object -ExpandProperty Plugins -Unique).Count
        }
    } | Sort-Object SCU -Descending | Export-Excel -Path $xlsx -WorksheetName "By-User" -AutoSize -FreezeTopRow

    # By-Experience aggregate
    $sessFlat | Group-Object Experience | ForEach-Object {
        [pscustomobject]@{
            Experience = $_.Name
            Sessions   = $_.Count
            SCU        = [math]::Round(($_.Group | Measure-Object SCU_Used -Sum).Sum, 3)
            Avg_SCU    = [math]::Round(($_.Group | Measure-Object SCU_Used -Average).Average, 4)
        }
    } | Sort-Object SCU -Descending | Export-Excel -Path $xlsx -WorksheetName "By-Experience" -AutoSize -FreezeTopRow

    # By Category × Type
    $sessFlat | Group-Object Category, Type | ForEach-Object {
        $parts = $_.Name -split ', '
        [pscustomobject]@{
            Category = $parts[0]
            Type     = $parts[1]
            Sessions = $_.Count
            SCU      = [math]::Round(($_.Group | Measure-Object SCU_Used -Sum).Sum, 3)
        }
    } | Sort-Object SCU -Descending | Export-Excel -Path $xlsx -WorksheetName "By-Category" -AutoSize -FreezeTopRow

    # Skill-level detail (unpivot Skills field - one row per skill invocation)
    $skillRows = $sessions | ForEach-Object {
        $sess = $_
        $dt = [datetime]$_.aggregateStartTime
        if ($_.skillNames) {
            foreach ($skill in $_.skillNames) {
                [pscustomobject]@{
                    Date      = $dt.ToString('yyyy-MM-dd HH:mm:ss')
                    SessionId = $sess.sessionId
                    User      = $sess.userName
                    Category  = $sess.invocationCategory
                    Type      = $sess.invocationType
                    Experience = $sess.copilotExperience
                    Plugin    = ($sess.skillSetNames -join '; ')
                    Skill     = $skill
                    SCU_Session = [math]::Round([double]$sess.usedCapacity, 4)
                }
            }
        }
    }
    if ($skillRows) {
        $skillRows | Export-Excel -Path $xlsx -WorksheetName "Skills" -AutoSize -FreezeTopRow

        # By-Skill aggregate
        $skillRows | Group-Object Skill | ForEach-Object {
            [pscustomobject]@{
                Skill        = $_.Name
                Invocations  = $_.Count
                Sessions     = ($_.Group | Select-Object -ExpandProperty SessionId -Unique).Count
                SCU_Attributed = [math]::Round(($_.Group | Measure-Object SCU_Session -Sum).Sum, 3)
            }
        } | Sort-Object Invocations -Descending | Export-Excel -Path $xlsx -WorksheetName "By-Skill" -AutoSize -FreezeTopRow
    }

    # Hourly heatmap data (Day × HourOfDay)
    $hourFlat | Group-Object DayOfWeek, HourOfDay | ForEach-Object {
        $parts = $_.Name -split ', '
        [pscustomobject]@{
            DayOfWeek = $parts[0]
            HourOfDay = [int]$parts[1]
            SCU_Total = [math]::Round(($_.Group | Measure-Object SCU_Used -Sum).Sum, 4)
            Hours     = $_.Count
        }
    } | Sort-Object DayOfWeek, HourOfDay | Export-Excel -Path $xlsx -WorksheetName "Heatmap" -AutoSize -FreezeTopRow

    # === NEW: Plugin/Skillset catalog ===
    if ($skillsetCatalog -and $skillsetCatalog.Count -gt 0) {
        $skillsetFlat = $skillsetCatalog | ForEach-Object {
            [pscustomobject]@{
                Namespace      = $_.namespace
                Name           = $_.name
                DisplayName    = $_.displayName
                Description    = $_.description
                Category       = $_.category
                CatalogScope   = $_.catalogScope
                PreviewState   = $_.previewState
                Enabled        = $_.enabled
                Hidden         = $_.hidden
                UserVisibility = $_.userVisibility
                Compliance     = $_.compliance
                HasMcp         = $_.hasMcp
                Version        = $_.version
                CreatorUserId  = $_.creatorUserId
                CanToggle      = $_.canToggle
                SkillCount     = if ($_.skills) { $_.skills.Count } else { 0 }
                SuggestedPromptCount = if ($_.fallbackSuggestedPrompts) { $_.fallbackSuggestedPrompts.Count } else { 0 }
            }
        }
        $skillsetFlat | Export-Excel -Path $xlsx -WorksheetName "Plugin-Catalog" -AutoSize -FreezeTopRow
        Write-Host "  Added Plugin-Catalog sheet ($($skillsetFlat.Count) rows)"

        # Sessions × plugin enabled/preview state join (usage vs available)
        $enabledSet = @{}
        foreach ($sk in $skillsetCatalog) {
            $displayKey = if ($sk.displayName) { $sk.displayName } else { $sk.name }
            $enabledSet[$displayKey] = @{
                Enabled = $sk.enabled
                Preview = $sk.previewState
                HasMcp  = $sk.hasMcp
                Category = $sk.category
            }
        }
    }

    # === NEW: Promptbook catalog + individual prompts ===
    if ($promptbookCatalog -and $promptbookCatalog.Count -gt 0) {
        $pbFlat = $promptbookCatalog | ForEach-Object {
            [pscustomobject]@{
                PromptbookId = $_.promptbookId
                Name         = $_.name
                Description  = $_.description
                Visibility   = $_.visibility
                PromptCount  = if ($_.prompts) { $_.prompts.Count } else { 0 }
            }
        }
        $pbFlat | Export-Excel -Path $xlsx -WorksheetName "Promptbooks" -AutoSize -FreezeTopRow
        Write-Host "  Added Promptbooks sheet ($($pbFlat.Count) rows)"

        # Unroll individual prompts within promptbooks
        $promptRows = $promptbookCatalog | ForEach-Object {
            $pb = $_
            if ($_.prompts) {
                foreach ($p in $_.prompts) {
                    [pscustomobject]@{
                        PromptbookId    = $pb.promptbookId
                        PromptbookName  = $pb.name
                        PromptId        = $p.promptbookPromptId
                        PromptSequence  = $p.promptSequenceId
                        PromptType      = $p.promptType
                        Title           = $p.title
                        Content         = if ($p.content) { $p.content.Substring(0, [Math]::Min(500, $p.content.Length)) } else { '' }
                        SkillName       = $p.skillName
                        HasSkillInputs  = ($null -ne $p.skillInputDescriptors)
                        PluginCount     = if ($p.plugins) { $p.plugins.Count } else { 0 }
                    }
                }
            }
        }
        if ($promptRows) {
            $promptRows | Export-Excel -Path $xlsx -WorksheetName "Promptbook-Prompts" -AutoSize -FreezeTopRow
            Write-Host "  Added Promptbook-Prompts sheet ($($promptRows.Count) prompts)"
        }
    }

    # === NEW: Session Catalog (rich context - which sessions exist regardless of SCU) ===
    if ($sessionCatalog -and $sessionCatalog.Count -gt 0) {
        $scFlat = $sessionCatalog | ForEach-Object {
            [pscustomobject]@{
                SessionId    = $_.sessionId
                Name         = $_.name
                Source       = $_.source
                CreatedAt    = if ($_.createdAt) { ([datetime]$_.createdAt).ToString('yyyy-MM-dd HH:mm:ss') } else { '' }
                UpdatedAt    = if ($_.updatedAt) { ([datetime]$_.updatedAt).ToString('yyyy-MM-dd HH:mm:ss') } else { '' }
                UserId       = $_.userId
                TenantId     = $_.tenantId
                ApplicationId = $_.applicationId
                Public       = $_.public
                SourceAppId  = $_.unauthenticatedSourceApplicationId
                UseAssistant = $_.useAssistant
                AgentIds     = if ($_.agentIds) { ($_.agentIds -join '; ') } else { '' }
                Skillsets    = if ($_.skillsets) { ($_.skillsets -join '; ') } else { '' }
                HasSummary   = ($null -ne $_.sessionSummary)
                HasReplay    = ($null -ne $_.sessionReplay)
                SubscriberCount = if ($_.subscribers) { $_.subscribers.Count } else { 0 }
            }
        }
        $scFlat | Export-Excel -Path $xlsx -WorksheetName "Session-Catalog" -AutoSize -FreezeTopRow
        Write-Host "  Added Session-Catalog sheet ($($scFlat.Count) rows)"
    }

    # Atomic swap: move the freshly-built workbook into place, replacing any older copy.
    # Retry a few times in case Power BI or OneDrive holds a lock briefly.
    $attempt = 0
    $swapped = $false
    while (-not $swapped -and $attempt -lt 5) {
        try {
            if (Test-Path $xlsxFinal) { Remove-Item $xlsxFinal -Force -ErrorAction Stop }
            Move-Item -Path $xlsx -Destination $xlsxFinal -Force -ErrorAction Stop
            $swapped = $true
        } catch {
            $attempt++
            Start-Sleep -Seconds 2
        }
    }
    if (-not $swapped) {
        Write-Warning "Could not replace $xlsxFinal (file locked). New copy left at: $xlsx"
    } else {
        Write-Host "  $xlsxFinal"
    }

    # === HTML companion JSON ===
    # Plain text files sync through OneDrive without the placeholder-header issue that .xlsx has.
    # The HTML generator (New-SCUDashboardHTML.ps1) prefers this over the .xlsx for reliable reads.
    $jsonFinal = Join-Path $OutDir 'SCU-Report.json'
    try {
        # Re-materialize the same aggregates we wrote to Excel sheets
        $agByPlugin = @($sessFlat | Group-Object Plugins | ForEach-Object { [pscustomobject]@{
            Plugin=$_.Name; Sessions=$_.Count
            SCU=[math]::Round(($_.Group | Measure-Object SCU_Used -Sum).Sum, 3)
            Avg_SCU=[math]::Round(($_.Group | Measure-Object SCU_Used -Average).Average, 4)
            Max_SCU=[math]::Round(($_.Group | Measure-Object SCU_Used -Maximum).Maximum, 3)
        } } | Sort-Object SCU -Descending)
        $agByUser = @($sessFlat | Group-Object User | ForEach-Object { [pscustomobject]@{
            User=$_.Name
            Department=($_.Group | Select-Object -First 1 -ExpandProperty Department)
            Sessions=$_.Count
            SCU=[math]::Round(($_.Group | Measure-Object SCU_Used -Sum).Sum, 3)
            Avg_SCU=[math]::Round(($_.Group | Measure-Object SCU_Used -Average).Average, 4)
            Max_SCU=[math]::Round(($_.Group | Measure-Object SCU_Used -Maximum).Maximum, 3)
            Distinct_Plugins=($_.Group | Select-Object -ExpandProperty Plugins -Unique).Count
        } } | Sort-Object SCU -Descending)
        $agByExperience = @($sessFlat | Where-Object Experience | Group-Object Experience | ForEach-Object { [pscustomobject]@{
            Experience=$_.Name; Sessions=$_.Count
            SCU=[math]::Round(($_.Group | Measure-Object SCU_Used -Sum).Sum, 3)
        } } | Sort-Object SCU -Descending)
        $agByCategory = @($sessFlat | Where-Object Category | Group-Object Category | ForEach-Object { [pscustomobject]@{
            Category=$_.Name; Sessions=$_.Count
            SCU=[math]::Round(($_.Group | Measure-Object SCU_Used -Sum).Sum, 3)
        } } | Sort-Object SCU -Descending)
        $agHeatmap = @($hourFlat | Group-Object DayOfWeekNum, HourOfDay | ForEach-Object {
            $parts = $_.Name -split ', '
            [pscustomobject]@{
                DayOfWeek=[int]$parts[0]
                HourOfDay=[int]$parts[1]
                'Hourly SCU'=[math]::Round(($_.Group | Measure-Object SCU_Used -Sum).Sum, 4)
            }
        } | Sort-Object DayOfWeek, HourOfDay)

        $pack = [ordered]@{
            Generated          = (Get-Date).ToString('yyyy-MM-dd HH:mm')
            Window             = "Last $Days days"
            Capacity           = $cfg.capacity
            Summary            = @($sum)
            Sessions           = $sessFlat
            Hourly             = $hourFlat
            Daily              = $dailyEnriched
            ActualCost         = $costDaily
            ByPlugin           = $agByPlugin
            ByUser             = $agByUser
            ByExperience       = $agByExperience
            ByCategory         = $agByCategory
            Skills             = $skillRows
            Heatmap            = $agHeatmap
            PluginCatalog      = $skillsetFlat
            Promptbooks        = $pbFlat
            PromptbookPrompts  = $promptRows
            SessionCatalog     = $scFlat
        }
        $json = $pack | ConvertTo-Json -Depth 12 -Compress
        [System.IO.File]::WriteAllText($jsonFinal, $json, [System.Text.UTF8Encoding]::new($false))
        Write-Host "  $jsonFinal ($([math]::Round((Get-Item $jsonFinal).Length/1KB,1)) KB - HTML companion)"
    } catch {
        Write-Warning "Could not write JSON companion: $($_.Exception.Message)"
    }
}

Write-Host "`nDone." -ForegroundColor Green
}
#endregion

# ============================================================
#region PBIT Builder (from New-SCUDashboardPBIT.ps1)
# ============================================================
function Invoke-ScuPbit {
    param(
        [string]$OutDir,
        [string]$OutputPath
    )
if (-not $OutputPath) { $OutputPath = Join-Path $OutDir 'SCU-Dashboard.pbit' }
Write-Host "Output PBIT: $OutputPath"

$modelGuid = [guid]::NewGuid().ToString()

function New-Guid2 { [guid]::NewGuid().ToString() }

# ===== BUILD DATAMODELSCHEMA =====
$sessMQuery = @(
    'let',
    '    ResolvedPath = if Text.EndsWith(Text.Lower(SCUReportPath), ".xlsx") then SCUReportPath else (if Text.EndsWith(SCUReportPath, "\") then SCUReportPath else SCUReportPath & "\") & "SCU-Report.xlsx",',
    '    Source = Excel.Workbook(File.Contents(ResolvedPath), null, true),',
    '    Sheet = Source{[Item="Sessions",Kind="Sheet"]}[Data],',
    '    Prom = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),',
    '    Typed = Table.TransformColumnTypes(Prom, {{"Date", type datetime},{"SessionId", type text},{"SCU_Used", type number},{"User", type text},{"UserFriendly", type text},{"IsAgent", type logical},{"Department", type text},{"Category", type text},{"Type", type text},{"Experience", type text},{"Plugins", type text},{"PluginCount", Int64.Type},{"Skills", type text},{"SkillCount", Int64.Type},{"UsageType", type text},{"Workload", type text},{"EvaluationId", type text},{"Status", type text},{"SourceApp", type text}})',
    'in',
    '    Typed'
)
$hourMQuery = @(
    'let',
    '    ResolvedPath = if Text.EndsWith(Text.Lower(SCUReportPath), ".xlsx") then SCUReportPath else (if Text.EndsWith(SCUReportPath, "\") then SCUReportPath else SCUReportPath & "\") & "SCU-Report.xlsx",',
    '    Source = Excel.Workbook(File.Contents(ResolvedPath), null, true),',
    '    Sheet = Source{[Item="Hourly",Kind="Sheet"]}[Data],',
    '    Prom = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),',
    '    Typed = Table.TransformColumnTypes(Prom, {{"Hour", type datetime},{"Day", type date},{"HourOfDay", Int64.Type},{"DayOfWeek", type text},{"SCU_Used", type number},{"ProvisionedSCU", type number},{"OverageSCU", type number},{"OverageState", type text}})',
    'in',
    '    Typed'
)
$pluginMQuery = @(
    'let',
    '    ResolvedPath = if Text.EndsWith(Text.Lower(SCUReportPath), ".xlsx") then SCUReportPath else (if Text.EndsWith(SCUReportPath, "\") then SCUReportPath else SCUReportPath & "\") & "SCU-Report.xlsx",',
    '    Source = Excel.Workbook(File.Contents(ResolvedPath), null, true),',
    '    Sheet = Source{[Item="By-Plugin",Kind="Sheet"]}[Data],',
    '    Prom = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),',
    '    Typed = Table.TransformColumnTypes(Prom, {{"Plugin", type text},{"Sessions", Int64.Type},{"SCU", type number},{"Avg_SCU", type number},{"Max_SCU", type number}})',
    'in',
    '    Typed'
)
$userMQuery = @(
    'let',
    '    ResolvedPath = if Text.EndsWith(Text.Lower(SCUReportPath), ".xlsx") then SCUReportPath else (if Text.EndsWith(SCUReportPath, "\") then SCUReportPath else SCUReportPath & "\") & "SCU-Report.xlsx",',
    '    Source = Excel.Workbook(File.Contents(ResolvedPath), null, true),',
    '    Sheet = Source{[Item="By-User",Kind="Sheet"]}[Data],',
    '    Prom = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),',
    '    Typed = Table.TransformColumnTypes(Prom, {{"User", type text},{"Department", type text},{"Sessions", Int64.Type},{"SCU", type number},{"Avg_SCU", type number},{"Max_SCU", type number},{"Distinct_Plugins", Int64.Type}})',
    'in',
    '    Typed'
)
$skillsMQuery = @(
    'let',
    '    ResolvedPath = if Text.EndsWith(Text.Lower(SCUReportPath), ".xlsx") then SCUReportPath else (if Text.EndsWith(SCUReportPath, "\") then SCUReportPath else SCUReportPath & "\") & "SCU-Report.xlsx",',
    '    Source = Excel.Workbook(File.Contents(ResolvedPath), null, true),',
    '    Sheet = Source{[Item="Skills",Kind="Sheet"]}[Data],',
    '    Prom = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),',
    '    Typed = Table.TransformColumnTypes(Prom, {{"Date", type datetime},{"SessionId", type text},{"User", type text},{"Category", type text},{"Type", type text},{"Experience", type text},{"Plugin", type text},{"Skill", type text},{"SCU_Session", type number}})',
    'in',
    '    Typed'
)
$pluginCatalogMQuery = @(
    'let',
    '    ResolvedPath = if Text.EndsWith(Text.Lower(SCUReportPath), ".xlsx") then SCUReportPath else (if Text.EndsWith(SCUReportPath, "\") then SCUReportPath else SCUReportPath & "\") & "SCU-Report.xlsx",',
    '    Source = Excel.Workbook(File.Contents(ResolvedPath), null, true),',
    '    Sheet = try Source{[Item="Plugin-Catalog",Kind="Sheet"]}[Data] otherwise #table({},{}),',
    '    Prom = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),',
    '    Typed = Table.TransformColumnTypes(Prom, {{"Namespace", type text},{"Name", type text},{"DisplayName", type text},{"Description", type text},{"Category", type text},{"CatalogScope", type text},{"PreviewState", type text},{"Enabled", type logical},{"Hidden", type logical},{"UserVisibility", type text},{"Compliance", type text},{"HasMcp", type logical},{"Version", type text},{"CreatorUserId", type text},{"CanToggle", type logical},{"SkillCount", Int64.Type},{"SuggestedPromptCount", Int64.Type}}, "en-US")',
    'in',
    '    Typed'
)
$promptbookMQuery = @(
    'let',
    '    ResolvedPath = if Text.EndsWith(Text.Lower(SCUReportPath), ".xlsx") then SCUReportPath else (if Text.EndsWith(SCUReportPath, "\") then SCUReportPath else SCUReportPath & "\") & "SCU-Report.xlsx",',
    '    Source = Excel.Workbook(File.Contents(ResolvedPath), null, true),',
    '    Sheet = try Source{[Item="Promptbooks",Kind="Sheet"]}[Data] otherwise #table({},{}),',
    '    Prom = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),',
    '    Typed = Table.TransformColumnTypes(Prom, {{"PromptbookId", type text},{"Name", type text},{"Description", type text},{"Visibility", type text},{"PromptCount", Int64.Type}})',
    'in',
    '    Typed'
)
$promptbookPromptsMQuery = @(
    'let',
    '    ResolvedPath = if Text.EndsWith(Text.Lower(SCUReportPath), ".xlsx") then SCUReportPath else (if Text.EndsWith(SCUReportPath, "\") then SCUReportPath else SCUReportPath & "\") & "SCU-Report.xlsx",',
    '    Source = Excel.Workbook(File.Contents(ResolvedPath), null, true),',
    '    Sheet = try Source{[Item="Promptbook-Prompts",Kind="Sheet"]}[Data] otherwise #table({},{}),',
    '    Prom = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),',
    '    Typed = Table.TransformColumnTypes(Prom, {{"PromptbookId", type text},{"PromptbookName", type text},{"PromptId", type text},{"PromptSequence", Int64.Type},{"PromptType", type text},{"Title", type text},{"Content", type text},{"SkillName", type text},{"HasSkillInputs", type logical},{"PluginCount", Int64.Type}})',
    'in',
    '    Typed'
)
$sessionCatalogMQuery = @(
    'let',
    '    ResolvedPath = if Text.EndsWith(Text.Lower(SCUReportPath), ".xlsx") then SCUReportPath else (if Text.EndsWith(SCUReportPath, "\") then SCUReportPath else SCUReportPath & "\") & "SCU-Report.xlsx",',
    '    Source = Excel.Workbook(File.Contents(ResolvedPath), null, true),',
    '    Sheet = try Source{[Item="Session-Catalog",Kind="Sheet"]}[Data] otherwise #table({},{}),',
    '    Prom = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),',
    '    Typed = Table.TransformColumnTypes(Prom, {{"SessionId", type text},{"Name", type text},{"Source", type text},{"CreatedAt", type datetime},{"UpdatedAt", type datetime},{"UserId", type text},{"TenantId", type text},{"ApplicationId", type text},{"Public", type logical},{"SourceAppId", type text},{"UseAssistant", type logical},{"AgentIds", type text},{"Skillsets", type text},{"HasSummary", type logical},{"HasReplay", type logical},{"SubscriberCount", Int64.Type}})',
    'in',
    '    Typed'
)

$heatmapMQuery = @(
    'let',
    '    ResolvedPath = if Text.EndsWith(Text.Lower(SCUReportPath), ".xlsx") then SCUReportPath else (if Text.EndsWith(SCUReportPath, "\") then SCUReportPath else SCUReportPath & "\") & "SCU-Report.xlsx",',
    '    Source = Excel.Workbook(File.Contents(ResolvedPath), null, true),',
    '    Sheet = Source{[Item="Heatmap",Kind="Sheet"]}[Data],',
    '    Prom = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),',
    '    Typed = Table.TransformColumnTypes(Prom, {{"DayOfWeek", type text},{"HourOfDay", Int64.Type},{"SCU_Total", type number},{"Hours", Int64.Type}})',
    'in',
    '    Typed'
)

$dailyMQuery = @(
    'let',
    '    ResolvedPath = if Text.EndsWith(Text.Lower(SCUReportPath), ".xlsx") then SCUReportPath else (if Text.EndsWith(SCUReportPath, "\") then SCUReportPath else SCUReportPath & "\") & "SCU-Report.xlsx",',
    '    Source = Excel.Workbook(File.Contents(ResolvedPath), null, true),',
    '    Sheet = try Source{[Item="Daily",Kind="Sheet"]}[Data] otherwise #table({},{}),',
    '    Prom = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),',
    '    Typed = Table.TransformColumnTypes(Prom, {{"Day", type date},{"SCU_Total", type number},{"Overage_SCU", type number},{"Hours_Active", Int64.Type},{"Rolling_7d_Avg", type number},{"Rolling_30d_Avg", type number},{"Prev_Day", type number},{"Delta_vs_Prev", type number},{"Is_Anomaly", type logical},{"Anomaly_Sigma", type number},{"Est_Cost_USD", type number}})',
    'in',
    '    Typed'
)
$actualCostMQuery = @(
    'let',
    '    ResolvedPath = if Text.EndsWith(Text.Lower(SCUReportPath), ".xlsx") then SCUReportPath else (if Text.EndsWith(SCUReportPath, "\") then SCUReportPath else SCUReportPath & "\") & "SCU-Report.xlsx",',
    '    Source = Excel.Workbook(File.Contents(ResolvedPath), null, true),',
    '    Sheet = try Source{[Item="Actual-Cost",Kind="Sheet"]}[Data] otherwise #table({},{}),',
    '    Prom = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),',
    '    Typed = Table.TransformColumnTypes(Prom, {{"Day", type date},{"Actual_Cost", type number},{"Actual_SCU", type number},{"Meter", type text},{"Currency", type text}})',
    'in',
    '    Typed'
)

function New-Column($name, $dataType, $summarizeBy = 'none', $formatString = $null) {
    $c = [ordered]@{
        name = $name
        dataType = $dataType
        sourceColumn = $name
        lineageTag = (New-Guid2)
        summarizeBy = $summarizeBy
        annotations = @(
            @{ name = 'SummarizationSetBy'; value = 'Automatic' }
        )
    }
    if ($formatString) { $c.formatString = $formatString }
    $c
}
function New-Measure($name, $expression, $formatString) {
    [ordered]@{
        name = $name
        expression = $expression
        formatString = $formatString
        lineageTag = (New-Guid2)
        annotations = @( @{ name = 'PBI_FormatHint'; value = '{}' } )
    }
}
function New-Table($name, $columns, $measures, $mQuery) {
    [ordered]@{
        name = $name
        lineageTag = (New-Guid2)
        columns = $columns
        measures = $measures
        partitions = @(
            [ordered]@{
                name = $name
                mode = 'import'
                source = [ordered]@{
                    type = 'm'
                    expression = $mQuery
                }
            }
        )
        annotations = @(
            @{ name = 'PBI_ResultType'; value = 'Table' }
            @{ name = 'PBI_NavigationStepName'; value = 'Navigation' }
        )
    }
}

$sessionsTable = New-Table 'Sessions' @(
    (New-Column 'Date' 'dateTime' 'none' 'General Date')
    (New-Column 'SessionId' 'string' 'none')
    (New-Column 'SCU_Used' 'double' 'sum' '0.0000')
    (New-Column 'User' 'string' 'none')
    (New-Column 'UserFriendly' 'string' 'none')
    (New-Column 'IsAgent' 'boolean' 'none')
    (New-Column 'Department' 'string' 'none')
    (New-Column 'Category' 'string' 'none')
    (New-Column 'Type' 'string' 'none')
    (New-Column 'Experience' 'string' 'none')
    (New-Column 'Plugins' 'string' 'none')
    (New-Column 'PluginCount' 'int64' 'sum')
    (New-Column 'Skills' 'string' 'none')
    (New-Column 'SkillCount' 'int64' 'sum')
    (New-Column 'UsageType' 'string' 'none')
    (New-Column 'Workload' 'string' 'none')
    (New-Column 'EvaluationId' 'string' 'none')
    (New-Column 'Status' 'string' 'none')
    (New-Column 'SourceApp' 'string' 'none')
) @(
    (New-Measure 'Total SCU' 'SUM(Sessions[SCU_Used])' '0.00')
    (New-Measure 'Total Sessions' 'DISTINCTCOUNT(Sessions[SessionId])' '0')
    (New-Measure 'Total Interactions' 'COUNTROWS(Sessions)' '0')
    (New-Measure 'Avg SCU per Session' 'DIVIDE([Total SCU], [Total Sessions])' '0.0000')
    (New-Measure 'Max SCU in a Session' 'MAX(Sessions[SCU_Used])' '0.00')
    (New-Measure 'Distinct Users' 'DISTINCTCOUNT(Sessions[User])' '0')
    (New-Measure 'Distinct Plugins' 'CALCULATE(DISTINCTCOUNT(Sessions[Plugins]), Sessions[Plugins] <> "")' '0')
    (New-Measure 'Est Total Cost USD' '[Total SCU] * 6.0' '"$"#,0.00')
    (New-Measure 'Agent SCU' 'CALCULATE([Total SCU], Sessions[Category] = "Agent")' '0.00')
    (New-Measure 'User Prompt SCU' 'CALCULATE([Total SCU], Sessions[Category] = "User prompt")' '0.00')
    (New-Measure 'Automated SCU' 'CALCULATE([Total SCU], Sessions[Type] = "Automated")' '0.00')
    (New-Measure 'Manual SCU' 'CALCULATE([Total SCU], Sessions[Type] = "Manual")' '0.00')
    (New-Measure 'Agent User %' 'DIVIDE(CALCULATE(COUNTROWS(Sessions), Sessions[IsAgent] = TRUE()), COUNTROWS(Sessions))' '0.0%')
    (New-Measure 'SCU Prev 30d' 'CALCULATE([Total SCU], DATEADD(Sessions[Date], -30, DAY))' '0.00')
    (New-Measure 'SCU vs Prev 30d' '[Total SCU] - [SCU Prev 30d]' '0.00')
    (New-Measure 'SCU vs Prev 30d %' 'DIVIDE([Total SCU] - [SCU Prev 30d], [SCU Prev 30d])' '0.0%')
) $sessMQuery

$hourlyTable = New-Table 'Hourly' @(
    (New-Column 'Hour' 'dateTime' 'none' 'General Date')
    (New-Column 'Day' 'dateTime' 'none' 'Short Date')
    (New-Column 'HourOfDay' 'int64' 'none')
    (New-Column 'DayOfWeek' 'string' 'none')
    (New-Column 'SCU_Used' 'double' 'sum' '0.0000')
    (New-Column 'ProvisionedSCU' 'double' 'sum' '0.0000')
    (New-Column 'OverageSCU' 'double' 'sum' '0.0000')
    (New-Column 'OverageState' 'string' 'none')
) @(
    (New-Measure 'Hourly SCU' 'SUM(Hourly[SCU_Used])' '0.00')
    (New-Measure 'Overage SCU Used' 'SUM(Hourly[OverageSCU])' '0.00')
    (New-Measure 'Overage %' 'DIVIDE([Overage SCU Used], [Hourly SCU])' '0.0%')
    (New-Measure 'Peak Hourly SCU' 'MAX(Hourly[SCU_Used])' '0.00')
) $hourMQuery

$pluginTable = New-Table 'ByPlugin' @(
    (New-Column 'Plugin' 'string' 'none')
    (New-Column 'Sessions' 'int64' 'sum')
    (New-Column 'SCU' 'double' 'sum' '0.00')
    (New-Column 'Avg_SCU' 'double' 'average' '0.0000')
    (New-Column 'Max_SCU' 'double' 'max' '0.00')
) @() $pluginMQuery

$userTable = New-Table 'ByUser' @(
    (New-Column 'User' 'string' 'none')
    (New-Column 'Department' 'string' 'none')
    (New-Column 'Sessions' 'int64' 'sum')
    (New-Column 'SCU' 'double' 'sum' '0.00')
    (New-Column 'Avg_SCU' 'double' 'average' '0.0000')
    (New-Column 'Max_SCU' 'double' 'max' '0.00')
    (New-Column 'Distinct_Plugins' 'int64' 'sum')
) @() $userMQuery

$skillsTable = New-Table 'Skills' @(
    (New-Column 'Date' 'dateTime' 'none' 'General Date')
    (New-Column 'SessionId' 'string' 'none')
    (New-Column 'User' 'string' 'none')
    (New-Column 'Category' 'string' 'none')
    (New-Column 'Type' 'string' 'none')
    (New-Column 'Experience' 'string' 'none')
    (New-Column 'Plugin' 'string' 'none')
    (New-Column 'Skill' 'string' 'none')
    (New-Column 'SCU_Session' 'double' 'sum' '0.0000')
) @(
    (New-Measure 'Skill Invocations' 'COUNTROWS(Skills)' '0')
    (New-Measure 'Distinct Skills' 'DISTINCTCOUNT(Skills[Skill])' '0')
) $skillsMQuery

$heatmapTable = New-Table 'Heatmap' @(
    (New-Column 'DayOfWeek' 'string' 'none')
    (New-Column 'HourOfDay' 'int64' 'none')
    (New-Column 'SCU_Total' 'double' 'sum' '0.0000')
    (New-Column 'Hours' 'int64' 'sum')
) @() $heatmapMQuery

$pluginCatalogTable = New-Table 'PluginCatalog' @(
    (New-Column 'Namespace' 'string' 'none')
    (New-Column 'Name' 'string' 'none')
    (New-Column 'DisplayName' 'string' 'none')
    (New-Column 'Description' 'string' 'none')
    (New-Column 'Category' 'string' 'none')
    (New-Column 'CatalogScope' 'string' 'none')
    (New-Column 'PreviewState' 'string' 'none')
    (New-Column 'Enabled' 'boolean' 'none')
    (New-Column 'Hidden' 'boolean' 'none')
    (New-Column 'UserVisibility' 'string' 'none')
    (New-Column 'Compliance' 'string' 'none')
    (New-Column 'HasMcp' 'boolean' 'none')
    (New-Column 'Version' 'string' 'none')
    (New-Column 'CreatorUserId' 'string' 'none')
    (New-Column 'CanToggle' 'boolean' 'none')
    (New-Column 'SkillCount' 'int64' 'sum')
    (New-Column 'SuggestedPromptCount' 'int64' 'sum')
) @(
    (New-Measure 'Available Plugins' 'COUNTROWS(PluginCatalog)' '0')
    (New-Measure 'Enabled Plugins' 'CALCULATE(COUNTROWS(PluginCatalog), PluginCatalog[Enabled] = TRUE())' '0')
    (New-Measure 'MCP Plugins' 'CALCULATE(COUNTROWS(PluginCatalog), PluginCatalog[HasMcp] = TRUE())' '0')
    (New-Measure 'Preview Plugins' 'CALCULATE(COUNTROWS(PluginCatalog), PluginCatalog[PreviewState] = "Preview")' '0')
) $pluginCatalogMQuery

$promptbookTable = New-Table 'Promptbooks' @(
    (New-Column 'PromptbookId' 'string' 'none')
    (New-Column 'Name' 'string' 'none')
    (New-Column 'Description' 'string' 'none')
    (New-Column 'Visibility' 'string' 'none')
    (New-Column 'PromptCount' 'int64' 'sum')
) @(
    (New-Measure 'Total Promptbooks' 'COUNTROWS(Promptbooks)' '0')
    (New-Measure 'Total Prompts' 'SUM(Promptbooks[PromptCount])' '0')
) $promptbookMQuery

$promptbookPromptsTable = New-Table 'PromptbookPrompts' @(
    (New-Column 'PromptbookId' 'string' 'none')
    (New-Column 'PromptbookName' 'string' 'none')
    (New-Column 'PromptId' 'string' 'none')
    (New-Column 'PromptSequence' 'int64' 'none')
    (New-Column 'PromptType' 'string' 'none')
    (New-Column 'Title' 'string' 'none')
    (New-Column 'Content' 'string' 'none')
    (New-Column 'SkillName' 'string' 'none')
    (New-Column 'HasSkillInputs' 'boolean' 'none')
    (New-Column 'PluginCount' 'int64' 'sum')
) @() $promptbookPromptsMQuery

$sessionCatalogTable = New-Table 'SessionCatalog' @(
    (New-Column 'SessionId' 'string' 'none')
    (New-Column 'Name' 'string' 'none')
    (New-Column 'Source' 'string' 'none')
    (New-Column 'CreatedAt' 'dateTime' 'none' 'General Date')
    (New-Column 'UpdatedAt' 'dateTime' 'none' 'General Date')
    (New-Column 'UserId' 'string' 'none')
    (New-Column 'TenantId' 'string' 'none')
    (New-Column 'ApplicationId' 'string' 'none')
    (New-Column 'Public' 'boolean' 'none')
    (New-Column 'SourceAppId' 'string' 'none')
    (New-Column 'UseAssistant' 'boolean' 'none')
    (New-Column 'AgentIds' 'string' 'none')
    (New-Column 'Skillsets' 'string' 'none')
    (New-Column 'HasSummary' 'boolean' 'none')
    (New-Column 'HasReplay' 'boolean' 'none')
    (New-Column 'SubscriberCount' 'int64' 'sum')
) @() $sessionCatalogMQuery

$dailyTable = New-Table 'Daily' @(
    (New-Column 'Day' 'dateTime' 'none' 'Short Date')
    (New-Column 'SCU_Total' 'double' 'sum' '0.00')
    (New-Column 'Overage_SCU' 'double' 'sum' '0.00')
    (New-Column 'Hours_Active' 'int64' 'sum')
    (New-Column 'Rolling_7d_Avg' 'double' 'none' '0.00')
    (New-Column 'Rolling_30d_Avg' 'double' 'none' '0.00')
    (New-Column 'Prev_Day' 'double' 'none' '0.00')
    (New-Column 'Delta_vs_Prev' 'double' 'sum' '0.00')
    (New-Column 'Is_Anomaly' 'boolean' 'none')
    (New-Column 'Anomaly_Sigma' 'double' 'none' '0.00')
    (New-Column 'Est_Cost_USD' 'double' 'sum' '"$"#,0.00')
) @(
    (New-Measure 'Daily SCU'          'SUM(Daily[SCU_Total])'     '0.00')
    (New-Measure 'Daily Cost'         'SUM(Daily[Est_Cost_USD])'  '"$"#,0.00')
    (New-Measure 'Anomaly Days'       'CALCULATE(COUNTROWS(Daily), Daily[Is_Anomaly] = TRUE())' '0')
    (New-Measure 'Rolling 7d Latest'  'CALCULATE(LASTNONBLANK(Daily[Rolling_7d_Avg], 1), FILTER(Daily, NOT ISBLANK(Daily[Rolling_7d_Avg])))' '0.00')
    (New-Measure 'Rolling 30d Latest' 'CALCULATE(LASTNONBLANK(Daily[Rolling_30d_Avg], 1), FILTER(Daily, NOT ISBLANK(Daily[Rolling_30d_Avg])))' '0.00')
    (New-Measure 'Peak Day SCU'       'MAX(Daily[SCU_Total])'     '0.00')
    (New-Measure 'Avg Day SCU'        'AVERAGE(Daily[SCU_Total])' '0.00')
) $dailyMQuery

$actualCostTable = New-Table 'ActualCost' @(
    (New-Column 'Day' 'dateTime' 'none' 'Short Date')
    (New-Column 'Actual_Cost' 'double' 'sum' '"$"#,0.00')
    (New-Column 'Actual_SCU' 'double' 'sum' '0.00')
    (New-Column 'Meter' 'string' 'none')
    (New-Column 'Currency' 'string' 'none')
) @(
    (New-Measure 'Actual Total Cost' 'SUM(ActualCost[Actual_Cost])' '"$"#,0.00')
    (New-Measure 'Actual Total SCU'  'SUM(ActualCost[Actual_SCU])'  '0.00')
    (New-Measure 'Overage Cost'      'CALCULATE(SUM(ActualCost[Actual_Cost]), ActualCost[Meter] = "Overage Security Compute Unit")' '"$"#,0.00')
    (New-Measure 'Provisioned Cost'  'CALCULATE(SUM(ActualCost[Actual_Cost]), ActualCost[Meter] = "Provisioned Security Compute Unit")' '"$"#,0.00')
) $actualCostMQuery

$model = [ordered]@{
    name = $modelGuid
    compatibilityLevel = 1601
    model = [ordered]@{
        culture = 'en-US'
        dataAccessOptions = [ordered]@{
            legacyRedirects = $true
            returnErrorValuesAsNull = $true
        }
        defaultPowerBIDataSourceVersion = 'powerBI_V3'
        sourceQueryCulture = 'en-US'
        tables = @($sessionsTable, $hourlyTable, $pluginTable, $userTable, $skillsTable, $heatmapTable, $pluginCatalogTable, $promptbookTable, $promptbookPromptsTable, $sessionCatalogTable, $dailyTable, $actualCostTable)
        expressions = @(
            [ordered]@{
                name = 'SCUReportPath'
                description = @(
                    'Path to SCU-Report.xlsx generated by SCU-Run.ps1.',
                    'Accepts either the full file path OR the folder containing SCU-Report.xlsx.',
                    'e.g. C:\path\to\SCU-Module\scu-output\SCU-Report.xlsx'
                )
                kind = 'm'
                expression = 'null meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]'
                queryGroup = 'Parameters'
                lineageTag = (New-Guid2)
                annotations = @(
                    @{ name = 'PBI_NavigationStepName'; value = 'Navigation' }
                    @{ name = 'PBI_ResultType'; value = 'Text' }
                )
            }
        )
        queryGroups = @(
            [ordered]@{ folder = 'Parameters'; annotations = @( @{ name = 'PBI_QueryGroupOrder'; value = '0' } ) }
        )
        annotations = @(
            @{ name = 'PBI_QueryOrder'; value = '["SCUReportPath","Sessions","Hourly","ByPlugin","ByUser","Skills","Heatmap","PluginCatalog","Promptbooks","PromptbookPrompts","SessionCatalog","Daily","ActualCost"]' }
            @{ name = '__PBI_TimeIntelligenceEnabled'; value = '1' }
            @{ name = 'PBIDesktopVersion'; value = '2.156.879.0 (26.05)+9e1feacf1cc7d1f95c6b6d0c66e02e5d0c88bb87' }
            @{ name = 'PBI_ProTooling'; value = '["DevMode"]' }
        )
    }
}
$dataModelSchema = $model | ConvertTo-Json -Depth 40 -Compress

# ===== BUILD REPORT/LAYOUT with visuals =====
function New-Card($x, $y, $w, $h, $tableName, $measureName, $title) {
    $vcName = ([guid]::NewGuid().ToString('N').Substring(0,20))
    $qref = "$tableName.$measureName"
    $cfg = [ordered]@{
        name = $vcName
        layouts = @( [ordered]@{ id = 0; position = [ordered]@{ x = $x; y = $y; z = 0; width = $w; height = $h; tabOrder = 0 } } )
        singleVisual = [ordered]@{
            visualType = 'card'
            projections = [ordered]@{
                Values = @( [ordered]@{ queryRef = $qref } )
            }
            prototypeQuery = [ordered]@{
                Version = 2
                From = @( [ordered]@{ Name = 'm'; Entity = $tableName; Type = 0 } )
                Select = @(
                    [ordered]@{
                        Measure = [ordered]@{
                            Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }
                            Property = $measureName
                        }
                        Name = $qref
                        NativeReferenceName = $measureName
                    }
                )
            }
            drillFilterOtherVisuals = $true
            objects = [ordered]@{
                labels = @( [ordered]@{ properties = [ordered]@{
                    color = [ordered]@{ solid = [ordered]@{ color = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'#50E6FF'" } } } } }
                    fontSize = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "24D" } } }
                    fontFamily = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'Segoe UI Semibold'" } } }
                } } )
                categoryLabels = @( [ordered]@{ properties = [ordered]@{
                    show = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "false" } } }
                } } )
            }
            vcObjects = [ordered]@{
                background = @( [ordered]@{ properties = [ordered]@{
                    show = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "true" } } }
                    color = [ordered]@{ solid = [ordered]@{ color = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'#1E2532'" } } } } }
                    transparency = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "0D" } } }
                } } )
                border = @( [ordered]@{ properties = [ordered]@{
                    show = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "true" } } }
                    color = [ordered]@{ solid = [ordered]@{ color = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'#334155'" } } } } }
                    radius = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "6D" } } }
                } } )
                visualHeader = @( [ordered]@{ properties = [ordered]@{
                    show = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "false" } } }
                } } )
                title = @( [ordered]@{ properties = [ordered]@{
                    show = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "true" } } }
                    text = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'$title'" } } }
                    fontColor = [ordered]@{ solid = [ordered]@{ color = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'#94A3B8'" } } } } }
                    background = [ordered]@{ solid = [ordered]@{ color = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'#1E2532'" } } } } }
                    fontSize = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "10D" } } }
                    fontFamily = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'Segoe UI'" } } }
                } } )
            }
        }
    }
    [ordered]@{
        x = [double]$x; y = [double]$y; z = 0
        width = [double]$w; height = [double]$h
        config = ($cfg | ConvertTo-Json -Depth 20 -Compress)
        filters = '[]'
    }
}

function New-BarChart($x, $y, $w, $h, $tableName, $categoryCol, $measureName, $title) {
    $vcName = ([guid]::NewGuid().ToString('N').Substring(0,20))
    $catRef = "$tableName.$categoryCol"
    $mRef   = "$tableName.$measureName"
    $cfg = [ordered]@{
        name = $vcName
        layouts = @( [ordered]@{ id = 0; position = [ordered]@{ x = $x; y = $y; z = 0; width = $w; height = $h; tabOrder = 0 } } )
        singleVisual = [ordered]@{
            visualType = 'barChart'
            projections = [ordered]@{
                Category = @( [ordered]@{ queryRef = $catRef; active = $true } )
                Y = @( [ordered]@{ queryRef = $mRef } )
            }
            prototypeQuery = [ordered]@{
                Version = 2
                From = @( [ordered]@{ Name = 'm'; Entity = $tableName; Type = 0 } )
                Select = @(
                    [ordered]@{
                        Column = [ordered]@{
                            Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }
                            Property = $categoryCol
                        }
                        Name = $catRef
                        NativeReferenceName = $categoryCol
                    }
                    [ordered]@{
                        Measure = [ordered]@{
                            Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }
                            Property = $measureName
                        }
                        Name = $mRef
                        NativeReferenceName = $measureName
                    }
                )
                OrderBy = @(
                    [ordered]@{
                        Direction = 2
                        Expression = [ordered]@{
                            Measure = [ordered]@{
                                Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }
                                Property = $measureName
                            }
                        }
                    }
                )
            }
            drillFilterOtherVisuals = $true
            vcObjects = [ordered]@{
                title = @( [ordered]@{ properties = [ordered]@{ text = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'$title'" } } } } } )
            }
        }
    }
    [ordered]@{
        x = [double]$x; y = [double]$y; z = 0
        width = [double]$w; height = [double]$h
        config = ($cfg | ConvertTo-Json -Depth 20 -Compress)
        filters = '[]'
    }
}

function New-DonutChart($x, $y, $w, $h, $tableName, $categoryCol, $measureName, $title) {
    $vcName = ([guid]::NewGuid().ToString('N').Substring(0,20))
    $catRef = "$tableName.$categoryCol"
    $mRef   = "$tableName.$measureName"
    $cfg = [ordered]@{
        name = $vcName
        layouts = @( [ordered]@{ id = 0; position = [ordered]@{ x = $x; y = $y; z = 0; width = $w; height = $h; tabOrder = 0 } } )
        singleVisual = [ordered]@{
            visualType = 'donutChart'
            projections = [ordered]@{
                Category = @( [ordered]@{ queryRef = $catRef; active = $true } )
                Y = @( [ordered]@{ queryRef = $mRef } )
            }
            prototypeQuery = [ordered]@{
                Version = 2
                From = @( [ordered]@{ Name = 'm'; Entity = $tableName; Type = 0 } )
                Select = @(
                    [ordered]@{
                        Column = [ordered]@{
                            Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }
                            Property = $categoryCol
                        }
                        Name = $catRef
                        NativeReferenceName = $categoryCol
                    }
                    [ordered]@{
                        Measure = [ordered]@{
                            Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }
                            Property = $measureName
                        }
                        Name = $mRef
                        NativeReferenceName = $measureName
                    }
                )
                OrderBy = @(
                    [ordered]@{
                        Direction = 2
                        Expression = [ordered]@{
                            Measure = [ordered]@{
                                Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }
                                Property = $measureName
                            }
                        }
                    }
                )
            }
            drillFilterOtherVisuals = $true
            vcObjects = [ordered]@{
                title = @( [ordered]@{ properties = [ordered]@{ text = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'$title'" } } } } } )
            }
        }
    }
    [ordered]@{
        x = [double]$x; y = [double]$y; z = 0
        width = [double]$w; height = [double]$h
        config = ($cfg | ConvertTo-Json -Depth 20 -Compress)
        filters = '[]'
    }
}

function New-ColumnChart($x, $y, $w, $h, $tableName, $categoryCol, $measureName, $title) {
    $vcName = ([guid]::NewGuid().ToString('N').Substring(0,20))
    $catRef = "$tableName.$categoryCol"
    $mRef   = "$tableName.$measureName"
    $cfg = [ordered]@{
        name = $vcName
        layouts = @( [ordered]@{ id = 0; position = [ordered]@{ x = $x; y = $y; z = 0; width = $w; height = $h; tabOrder = 0 } } )
        singleVisual = [ordered]@{
            visualType = 'columnChart'
            projections = [ordered]@{
                Category = @( [ordered]@{ queryRef = $catRef; active = $true } )
                Y = @( [ordered]@{ queryRef = $mRef } )
            }
            prototypeQuery = [ordered]@{
                Version = 2
                From = @( [ordered]@{ Name = 'm'; Entity = $tableName; Type = 0 } )
                Select = @(
                    [ordered]@{
                        Column = [ordered]@{
                            Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }
                            Property = $categoryCol
                        }
                        Name = $catRef
                        NativeReferenceName = $categoryCol
                    }
                    [ordered]@{
                        Measure = [ordered]@{
                            Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }
                            Property = $measureName
                        }
                        Name = $mRef
                        NativeReferenceName = $measureName
                    }
                )
            }
            drillFilterOtherVisuals = $true
            vcObjects = [ordered]@{
                title = @( [ordered]@{ properties = [ordered]@{ text = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'$title'" } } } } } )
            }
        }
    }
    [ordered]@{
        x = [double]$x; y = [double]$y; z = 0
        width = [double]$w; height = [double]$h
        config = ($cfg | ConvertTo-Json -Depth 20 -Compress)
        filters = '[]'
    }
}

# Table visual (rich detail rows)
function New-TableVisual($x, $y, $w, $h, $tableName, $columns, $title) {
    $vcName = ([guid]::NewGuid().ToString('N').Substring(0,20))
    $selects = @()
    $projValues = @()
    foreach ($col in $columns) {
        $qref = "$tableName.$col"
        $projValues += [ordered]@{ queryRef = $qref }
        $selects += [ordered]@{
            Column = [ordered]@{
                Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }
                Property = $col
            }
            Name = $qref
            NativeReferenceName = $col
        }
    }
    $cfg = [ordered]@{
        name = $vcName
        layouts = @( [ordered]@{ id = 0; position = [ordered]@{ x = $x; y = $y; z = 0; width = $w; height = $h; tabOrder = 0 } } )
        singleVisual = [ordered]@{
            visualType = 'tableEx'
            projections = [ordered]@{
                Values = $projValues
            }
            prototypeQuery = [ordered]@{
                Version = 2
                From = @( [ordered]@{ Name = 'm'; Entity = $tableName; Type = 0 } )
                Select = $selects
            }
            drillFilterOtherVisuals = $true
            vcObjects = [ordered]@{
                title = @( [ordered]@{ properties = [ordered]@{ text = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'$title'" } } } } } )
            }
        }
    }
    [ordered]@{
        x = [double]$x; y = [double]$y; z = 0
        width = [double]$w; height = [double]$h
        config = ($cfg | ConvertTo-Json -Depth 20 -Compress)
        filters = '[]'
    }
}

# Slicer visual
function New-Slicer($x, $y, $w, $h, $tableName, $columnName, $title) {
    $vcName = ([guid]::NewGuid().ToString('N').Substring(0,20))
    $qref = "$tableName.$columnName"
    $cfg = [ordered]@{
        name = $vcName
        layouts = @( [ordered]@{ id = 0; position = [ordered]@{ x = $x; y = $y; z = 0; width = $w; height = $h; tabOrder = 0 } } )
        singleVisual = [ordered]@{
            visualType = 'slicer'
            projections = [ordered]@{
                Values = @( [ordered]@{ queryRef = $qref; active = $true } )
            }
            prototypeQuery = [ordered]@{
                Version = 2
                From = @( [ordered]@{ Name = 'm'; Entity = $tableName; Type = 0 } )
                Select = @(
                    [ordered]@{
                        Column = [ordered]@{
                            Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }
                            Property = $columnName
                        }
                        Name = $qref
                        NativeReferenceName = $columnName
                    }
                )
            }
            drillFilterOtherVisuals = $true
            vcObjects = [ordered]@{
                title = @( [ordered]@{ properties = [ordered]@{ text = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'$title'" } } } } } )
            }
        }
    }
    [ordered]@{
        x = [double]$x; y = [double]$y; z = 0
        width = [double]$w; height = [double]$h
        config = ($cfg | ConvertTo-Json -Depth 20 -Compress)
        filters = '[]'
    }
}

# Matrix (pivot table with rows × columns × values)
function New-Matrix($x, $y, $w, $h, $tableName, $rowCol, $colCol, $measureName, $title) {
    $vcName = ([guid]::NewGuid().ToString('N').Substring(0,20))
    $rRef = "$tableName.$rowCol"
    $cRef = "$tableName.$colCol"
    $mRef = "$tableName.$measureName"
    $cfg = [ordered]@{
        name = $vcName
        layouts = @( [ordered]@{ id = 0; position = [ordered]@{ x = $x; y = $y; z = 0; width = $w; height = $h; tabOrder = 0 } } )
        singleVisual = [ordered]@{
            visualType = 'pivotTable'
            projections = [ordered]@{
                Rows    = @( [ordered]@{ queryRef = $rRef; active = $true } )
                Columns = @( [ordered]@{ queryRef = $cRef } )
                Values  = @( [ordered]@{ queryRef = $mRef } )
            }
            prototypeQuery = [ordered]@{
                Version = 2
                From = @( [ordered]@{ Name = 'm'; Entity = $tableName; Type = 0 } )
                Select = @(
                    [ordered]@{
                        Column = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }; Property = $rowCol }
                        Name = $rRef; NativeReferenceName = $rowCol
                    }
                    [ordered]@{
                        Column = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }; Property = $colCol }
                        Name = $cRef; NativeReferenceName = $colCol
                    }
                    [ordered]@{
                        Measure = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }; Property = $measureName }
                        Name = $mRef; NativeReferenceName = $measureName
                    }
                )
            }
            drillFilterOtherVisuals = $true
            vcObjects = [ordered]@{
                title = @( [ordered]@{ properties = [ordered]@{ text = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'$title'" } } } } } )
            }
        }
    }
    [ordered]@{
        x = [double]$x; y = [double]$y; z = 0
        width = [double]$w; height = [double]$h
        config = ($cfg | ConvertTo-Json -Depth 20 -Compress)
        filters = '[]'
    }
}

# Line chart
function New-LineChart($x, $y, $w, $h, $tableName, $categoryCol, $measureName, $title, [switch]$Forecast) {
    $vcName = ([guid]::NewGuid().ToString('N').Substring(0,20))
    $catRef = "$tableName.$categoryCol"
    $mRef   = "$tableName.$measureName"
    $singleVisual = [ordered]@{
        visualType = 'lineChart'
        projections = [ordered]@{
            Category = @( [ordered]@{ queryRef = $catRef; active = $true } )
            Y = @( [ordered]@{ queryRef = $mRef } )
        }
        prototypeQuery = [ordered]@{
            Version = 2
            From = @( [ordered]@{ Name = 'm'; Entity = $tableName; Type = 0 } )
            Select = @(
                [ordered]@{
                    Column = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }; Property = $categoryCol }
                    Name = $catRef; NativeReferenceName = $categoryCol
                }
                [ordered]@{
                    Measure = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }; Property = $measureName }
                    Name = $mRef; NativeReferenceName = $measureName
                }
            )
        }
        drillFilterOtherVisuals = $true
        vcObjects = [ordered]@{
            title = @( [ordered]@{ properties = [ordered]@{ text = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'$title'" } } } } } )
        }
    }
    if ($Forecast) {
        $singleVisual.objects = [ordered]@{
            forecast = @(
                [ordered]@{
                    properties = [ordered]@{
                        show = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "true" } } }
                        forecastLength = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "7D" } } }
                        confidenceBand = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "95D" } } }
                        seasonality = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "7L" } } }
                    }
                    selector = [ordered]@{ id = 'default' }
                }
            )
        }
    }
    $cfg = [ordered]@{
        name = $vcName
        layouts = @( [ordered]@{ id = 0; position = [ordered]@{ x = $x; y = $y; z = 0; width = $w; height = $h; tabOrder = 0 } } )
        singleVisual = $singleVisual
    }
    [ordered]@{
        x = [double]$x; y = [double]$y; z = 0
        width = [double]$w; height = [double]$h
        config = ($cfg | ConvertTo-Json -Depth 20 -Compress)
        filters = '[]'
    }
}

# Treemap
function New-Treemap($x, $y, $w, $h, $tableName, $categoryCol, $measureName, $title) {
    $vcName = ([guid]::NewGuid().ToString('N').Substring(0,20))
    $catRef = "$tableName.$categoryCol"
    $mRef   = "Sum($tableName.$measureName)"
    $cfg = [ordered]@{
        name = $vcName
        layouts = @( [ordered]@{ id = 0; position = [ordered]@{ x = $x; y = $y; z = 0; width = $w; height = $h; tabOrder = 0 } } )
        singleVisual = [ordered]@{
            visualType = 'treemap'
            projections = [ordered]@{
                Group = @( [ordered]@{ queryRef = $catRef; active = $true } )
                Values = @( [ordered]@{ queryRef = $mRef } )
            }
            prototypeQuery = [ordered]@{
                Version = 2
                From = @( [ordered]@{ Name = 'm'; Entity = $tableName; Type = 0 } )
                Select = @(
                    [ordered]@{
                        Column = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }; Property = $categoryCol }
                        Name = $catRef; NativeReferenceName = $categoryCol
                    }
                    [ordered]@{
                        Aggregation = [ordered]@{
                            Expression = [ordered]@{
                                Column = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }; Property = $measureName }
                            }
                            Function = 0
                        }
                        Name = $mRef; NativeReferenceName = "Sum of $measureName"
                    }
                )
                OrderBy = @(
                    [ordered]@{
                        Direction = 2
                        Expression = [ordered]@{
                            Aggregation = [ordered]@{
                                Expression = [ordered]@{
                                    Column = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }; Property = $measureName }
                                }
                                Function = 0
                            }
                        }
                    }
                )
            }
            drillFilterOtherVisuals = $true
            vcObjects = [ordered]@{
                title = @( [ordered]@{ properties = [ordered]@{ text = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'$title'" } } } } } )
            }
        }
    }
    [ordered]@{
        x = [double]$x; y = [double]$y; z = 0
        width = [double]$w; height = [double]$h
        config = ($cfg | ConvertTo-Json -Depth 20 -Compress)
        filters = '[]'
    }
}

# Scatter (X, Y, Size — for cost-efficiency)
function New-Scatter($x, $y, $w, $h, $tableName, $labelCol, $xCol, $yCol, $sizeCol, $title) {
    $vcName = ([guid]::NewGuid().ToString('N').Substring(0,20))
    $lRef  = "$tableName.$labelCol"
    $xRef  = "Sum($tableName.$xCol)"
    $yRef  = "Sum($tableName.$yCol)"
    $szRef = "Sum($tableName.$sizeCol)"
    function _agg($t,$c) {
        [ordered]@{
            Aggregation = [ordered]@{
                Expression = [ordered]@{
                    Column = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }; Property = $c }
                }
                Function = 0
            }
            Name = "Sum($t.$c)"; NativeReferenceName = "Sum of $c"
        }
    }
    $cfg = [ordered]@{
        name = $vcName
        layouts = @( [ordered]@{ id = 0; position = [ordered]@{ x = $x; y = $y; z = 0; width = $w; height = $h; tabOrder = 0 } } )
        singleVisual = [ordered]@{
            visualType = 'scatterChart'
            projections = [ordered]@{
                Category = @( [ordered]@{ queryRef = $lRef; active = $true } )
                X        = @( [ordered]@{ queryRef = $xRef } )
                Y        = @( [ordered]@{ queryRef = $yRef } )
                Size     = @( [ordered]@{ queryRef = $szRef } )
            }
            prototypeQuery = [ordered]@{
                Version = 2
                From = @( [ordered]@{ Name = 'm'; Entity = $tableName; Type = 0 } )
                Select = @(
                    [ordered]@{
                        Column = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }; Property = $labelCol }
                        Name = $lRef; NativeReferenceName = $labelCol
                    }
                    (_agg $tableName $xCol)
                    (_agg $tableName $yCol)
                    (_agg $tableName $sizeCol)
                )
            }
            drillFilterOtherVisuals = $true
            vcObjects = [ordered]@{
                title = @( [ordered]@{ properties = [ordered]@{ text = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'$title'" } } } } } )
            }
        }
    }
    [ordered]@{
        x = [double]$x; y = [double]$y; z = 0
        width = [double]$w; height = [double]$h
        config = ($cfg | ConvertTo-Json -Depth 20 -Compress)
        filters = '[]'
    }
}

# Waterfall (Category + Y delta)
function New-Waterfall($x, $y, $w, $h, $tableName, $categoryCol, $measureName, $title) {
    $vcName = ([guid]::NewGuid().ToString('N').Substring(0,20))
    $catRef = "$tableName.$categoryCol"
    $mRef   = "Sum($tableName.$measureName)"
    $cfg = [ordered]@{
        name = $vcName
        layouts = @( [ordered]@{ id = 0; position = [ordered]@{ x = $x; y = $y; z = 0; width = $w; height = $h; tabOrder = 0 } } )
        singleVisual = [ordered]@{
            visualType = 'waterfallChart'
            projections = [ordered]@{
                Category = @( [ordered]@{ queryRef = $catRef; active = $true } )
                Y = @( [ordered]@{ queryRef = $mRef } )
            }
            prototypeQuery = [ordered]@{
                Version = 2
                From = @( [ordered]@{ Name = 'm'; Entity = $tableName; Type = 0 } )
                Select = @(
                    [ordered]@{
                        Column = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }; Property = $categoryCol }
                        Name = $catRef; NativeReferenceName = $categoryCol
                    }
                    [ordered]@{
                        Aggregation = [ordered]@{
                            Expression = [ordered]@{
                                Column = [ordered]@{ Expression = [ordered]@{ SourceRef = [ordered]@{ Source = 'm' } }; Property = $measureName }
                            }
                            Function = 0
                        }
                        Name = $mRef; NativeReferenceName = "Sum of $measureName"
                    }
                )
            }
            drillFilterOtherVisuals = $true
            vcObjects = [ordered]@{
                title = @( [ordered]@{ properties = [ordered]@{ text = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'$title'" } } } } } )
            }
        }
    }
    [ordered]@{
        x = [double]$x; y = [double]$y; z = 0
        width = [double]$w; height = [double]$h
        config = ($cfg | ConvertTo-Json -Depth 20 -Compress)
        filters = '[]'
    }
}

# TextBox with all chrome hidden (no background, no border, no menu dots)
function New-TextBox($x, $y, $w, $h, $text, [int]$fontSize = 12, [string]$color = '#F9FAFB', [string]$weight = 'normal', [string]$align = 'left') {
    $vcName = ([guid]::NewGuid().ToString('N').Substring(0,20))
    # AUTO-CLIP GUARD: ensure box is tall enough for the font (fontSize * 2.0 + 8px padding).
    $minHeight = [int]([Math]::Ceiling($fontSize * 2.0) + 8)
    if ($h -lt $minHeight) { $h = $minHeight }
    $textRun = [ordered]@{
        value = $text
        textStyle = [ordered]@{
            fontSize      = "${fontSize}pt"
            color         = $color
            fontFamily    = 'Segoe UI'
            fontWeight    = $weight
        }
    }
    $paragraph = [ordered]@{
        textRuns = @($textRun)
        horizontalTextAlignment = $align
    }
    $cfg = [ordered]@{
        name = $vcName
        layouts = @( [ordered]@{ id = 0; position = [ordered]@{ x = $x; y = $y; z = 0; width = $w; height = $h; tabOrder = 0 } } )
        singleVisual = [ordered]@{
            visualType = 'textbox'
            drillFilterOtherVisuals = $true
            objects = [ordered]@{
                general = @(
                    [ordered]@{
                        properties = [ordered]@{
                            paragraphs = @($paragraph)
                        }
                    }
                )
            }
            vcObjects = [ordered]@{
                background = @( [ordered]@{ properties = [ordered]@{
                    show = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "false" } } }
                } } )
                border = @( [ordered]@{ properties = [ordered]@{
                    show = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "false" } } }
                } } )
                visualHeader = @( [ordered]@{ properties = [ordered]@{
                    show = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "false" } } }
                } } )
                visualHeaderTooltip = @( [ordered]@{ properties = [ordered]@{
                    show = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "false" } } }
                } } )
                title = @( [ordered]@{ properties = [ordered]@{
                    show = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "false" } } }
                } } )
                padding = @( [ordered]@{ properties = [ordered]@{
                    top    = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "0D" } } }
                    bottom = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "0D" } } }
                    left   = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "0D" } } }
                    right  = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "0D" } } }
                } } )
            }
        }
    }
    [ordered]@{
        x = [double]$x; y = [double]$y; z = 0
        width = [double]$w; height = [double]$h
        config = ($cfg | ConvertTo-Json -Depth 20 -Compress)
        filters = '[]'
    }
}

# Add page header + subtitle + developer footer (shifts visuals down). Compact for 720px canvas.
function Add-PageHeader([string]$title, [string]$subtitle, [array]$visuals, [int]$shift = 60) {
    $result = @(
        (New-TextBox 20 8  1240 32 $title 12 '#FFFFFF' 'bold')
        (New-TextBox 20 34 1240 24 $subtitle 8 '#94A3B8' 'normal')
    )
    foreach ($v in $visuals) {
        $v.y = [double]($v.y + $shift)
        $cfg = $v.config | ConvertFrom-Json
        if ($cfg.layouts -and $cfg.layouts[0].position) {
            $cfg.layouts[0].position.y = [double]($cfg.layouts[0].position.y + $shift)
        }
        $v.config = $cfg | ConvertTo-Json -Depth 20 -Compress
        $result += $v
    }
    # Developer footer bottom-right, small
    $result += (New-TextBox 1060 686 200 22 'Developed by Muataz Awad' 7 '#9CA3AF' 'normal' 'right')
    return $result
}

# Page 0: Cover - MINIMAL & clean - big title, 8 cards, footer only
$coverVisuals = @(
    # Hero title band
    (New-TextBox 30 20 1220 60 'Security Copilot - SCU Usage Dashboard' 20 '#FFFFFF' 'bold')
    (New-TextBox 30 78 1220 30 'Real-time visibility into your Security Compute Unit consumption across sessions, users, plugins and cost' 10 '#94A3B8' 'normal')

    # Row 1: 4 KPI cards (300 wide, 130 tall - card title + value fits neatly)
    (New-Card    30 130 297 130 'Sessions' 'Total SCU'          'Total SCU (90 days)')
    (New-Card   337 130 297 130 'Sessions' 'Total Sessions'     'Total Sessions')
    (New-Card   644 130 297 130 'Sessions' 'Distinct Users'     'Distinct Users')
    (New-Card   951 130 297 130 'Sessions' 'Est Total Cost USD' 'Estimated Cost USD')

    # Row 2
    (New-Card    30 275 297 130 'ActualCost'    'Actual Total Cost' 'Actual Azure Bill USD')
    (New-Card   337 275 297 130 'PluginCatalog' 'Available Plugins' 'Available Plugins')
    (New-Card   644 275 297 130 'Promptbooks'   'Total Promptbooks' 'Promptbooks')
    (New-Card   951 275 297 130 'Daily'         'Anomaly Days'      'Anomaly Days (>2σ)')

    # Getting started strip
    (New-TextBox 30 430 1220 34 'Getting Started' 13 '#50E6FF' 'bold')
    (New-TextBox 30 470 1220 30 'Use the page tabs at the bottom to explore. Start with Guide for definitions, or jump to Overview / Sessions / Trends / Plugins Used / Users / Plugin Catalog / Promptbooks / Analytics.' 10 '#D1D5DB' 'normal')

    # Refresh / source strip
    (New-TextBox 30 510 1220 30 'Data source: Security Copilot portal API + Azure Cost Management. To refresh, run SCU-Run.ps1 then Home ribbon > Refresh.' 9 '#6B7280' 'normal')

    # Developer credit bottom-right
    (New-TextBox 1060 686 200 22 'Developed by Muataz Awad' 7 '#9CA3AF' 'normal' 'right')
)

# Page 0.5: Guide - dedicated page for glossary + navigation help (generous heights, nothing clips)
$guideVisuals = @(
    # HOW TO USE THIS REPORT
    (New-TextBox 30 20 1220 40 'How to Use This Report' 16 '#FFFFFF' 'bold')
    (New-TextBox 30 60 1220 30 'This dashboard gives you a full view of your Security Copilot SCU consumption. Use the tabs below to drill in.' 10 '#D1D5DB' 'normal')

    # PAGE GUIDE section
    (New-TextBox 30 105 1220 34 'Page Guide' 13 '#50E6FF' 'bold')

    # Two-column page descriptions
    (New-TextBox 30 145 390 32 'Cover' 11 '#FFFFFF' 'bold')
    (New-TextBox 30 175 390 30 'Landing page with 8 headline KPIs at a glance.' 9 '#D1D5DB' 'normal')

    (New-TextBox 435 145 390 32 'Overview' 11 '#FFFFFF' 'bold')
    (New-TextBox 435 175 390 30 'Daily SCU trend, SCU by user, and SCU by plugin/agent.' 9 '#D1D5DB' 'normal')

    (New-TextBox 840 145 400 32 'Sessions' 11 '#FFFFFF' 'bold')
    (New-TextBox 840 175 400 30 'Every interaction with filters for user, category, type, experience.' 9 '#D1D5DB' 'normal')

    (New-TextBox 30 215 390 32 'Trends' 11 '#FFFFFF' 'bold')
    (New-TextBox 30 245 390 30 'Daily line + 7-day forecast, hourly heatmap, day-of-week pattern.' 9 '#D1D5DB' 'normal')

    (New-TextBox 435 215 390 32 'Plugins Used' 11 '#FFFFFF' 'bold')
    (New-TextBox 435 245 390 30 'Treemap + scatter of the plugins actually consumed in this window.' 9 '#D1D5DB' 'normal')

    (New-TextBox 840 215 400 32 'Users' 11 '#FFFFFF' 'bold')
    (New-TextBox 840 245 400 30 'User leaderboard, category mix, session count per user.' 9 '#D1D5DB' 'normal')

    (New-TextBox 30 285 390 32 'Plugin Catalog' 11 '#FFFFFF' 'bold')
    (New-TextBox 30 315 390 30 'All 90 plugins available in your tenant with tags, type, provider.' 9 '#D1D5DB' 'normal')

    (New-TextBox 435 285 390 32 'Promptbooks' 11 '#FFFFFF' 'bold')
    (New-TextBox 435 315 390 30 '15 promptbooks with their 84 prompts and estimated SCU cost.' 9 '#D1D5DB' 'normal')

    (New-TextBox 840 285 400 32 'Analytics' 11 '#FFFFFF' 'bold')
    (New-TextBox 840 315 400 30 'Rolling averages, cost estimate detail, anomaly summary.' 9 '#D1D5DB' 'normal')

    # GLOSSARY section
    (New-TextBox 30 365 1220 34 'Glossary' 13 '#50E6FF' 'bold')

    (New-TextBox 30 405 590 32 'SCU (Security Compute Unit)' 11 '#50E6FF' 'bold')
    (New-TextBox 30 437 590 45 'Metering unit for Security Copilot. Billed by the hour at list price 6 USD per SCU-hour.' 9 '#D1D5DB' 'normal')

    (New-TextBox 650 405 590 32 'Anomaly Day' 11 '#50E6FF' 'bold')
    (New-TextBox 650 437 590 45 'A day where SCU consumption exceeded 2 standard deviations above the rolling mean.' 9 '#D1D5DB' 'normal')

    (New-TextBox 30 490 590 32 'Overage' 11 '#50E6FF' 'bold')
    (New-TextBox 30 522 590 45 'SCU billed above your Provisioned capacity. In this tenant, most usage is Overage.' 9 '#D1D5DB' 'normal')

    (New-TextBox 650 490 590 32 'Agent User' 11 '#50E6FF' 'bold')
    (New-TextBox 650 522 590 45 'A machine identity running an autonomous agent (SecurityCopilotAgentUser-{guid}).' 9 '#D1D5DB' 'normal')

    # Footer notes + credit
    (New-TextBox 30 620 1220 28 'Data source: Security Copilot portal API (undocumented) + Azure Cost Management + Microsoft Graph. Refresh: run SCU-Run.ps1 then use Home > Refresh in Power BI.' 8 '#6B7280' 'normal')
    (New-TextBox 30 650 1220 28 'Estimated Cost = SCU x 6 USD (list price). Actual Azure Bill comes from Cost Management and reflects your negotiated rate.' 8 '#6B7280' 'normal')

    (New-TextBox 1060 686 200 22 'Developed by Muataz Awad' 7 '#9CA3AF' 'normal' 'right')
)

# Page 1: Overview (unchanged - 7 KPI visuals)
$overviewVisuals = @(
    (New-Card       20  20 285 130 'Sessions' 'Total SCU'           'Total SCU')
    (New-Card      325  20 285 130 'Sessions' 'Total Sessions'      'Total Sessions')
    (New-Card      630  20 285 130 'Sessions' 'Distinct Users'      'Distinct Users')
    (New-Card      935  20 285 130 'Sessions' 'Est Total Cost USD'  'Estimated Cost USD')
    (New-ColumnChart 20 170 600 250 'Sessions' 'Date' 'Total SCU'   'SCU by Day')
    (New-DonutChart 630 170 600 250 'Sessions' 'User' 'Total SCU'   'SCU by User')
    (New-BarChart    20 440 1200 220 'Sessions' 'Plugins' 'Total SCU' 'SCU by Plugin/Agent')
)

# Page 2: Session Details - big table + slicers
$sessionsVisuals = @(
    (New-Slicer      20  20 250 130 'Sessions' 'User'       'Filter: User')
    (New-Slicer     280  20 250 130 'Sessions' 'Category'   'Filter: Category')
    (New-Slicer     540  20 250 130 'Sessions' 'Type'       'Filter: Type')
    (New-Slicer     800  20 250 130 'Sessions' 'Experience' 'Filter: Experience')
    (New-Card      1060  20 160  130 'Sessions' 'Total SCU' 'SCU (filtered)')
    (New-TableVisual 20 170 1200 490 'Sessions' @('Date','User','Category','Type','Experience','Plugins','Skills','SCU_Used','SessionId') 'All Sessions/Interactions')
)

# Page 3: Trends - hourly/daily patterns (uses Daily table + Hourly table with fixes)
$trendsVisuals = @(
    (New-Card       20  20 285 130 'Hourly' 'Peak Hourly SCU'    'Peak Hourly SCU')
    (New-Card      325  20 285 130 'Daily'  'Rolling 7d Latest'  '7-Day Avg (latest)')
    (New-Card      630  20 285 130 'Daily'  'Rolling 30d Latest' '30-Day Avg (latest)')
    (New-Card      935  20 285 130 'Daily'  'Anomaly Days'       'Anomaly Days (>2σ)')
    (New-LineChart   20 170 1200 250 'Daily' 'Day' 'Daily SCU'   'Daily SCU with 7-day Forecast' -Forecast)
    (New-Matrix     20 440 700 220 'Hourly' 'DayOfWeek' 'HourOfDay' 'Hourly SCU' 'Day-of-Week × Hour Heatmap')
    (New-BarChart  730 440 500 220 'Hourly' 'DayOfWeek' 'Hourly SCU' 'SCU by Day of Week')
)

# Page 4: Plugins Used - detailed drilldown with treemap + scatter
$pluginVisuals = @(
    (New-Card       20  20 285 130 'Sessions' 'Distinct Plugins'      'Distinct Plugins')
    (New-Card      325  20 285 130 'Skills'   'Distinct Skills'       'Distinct Skills')
    (New-Card      630  20 285 130 'Skills'   'Skill Invocations'     'Skill Invocations')
    (New-Card      935  20 285 130 'Sessions' 'Avg SCU per Session'   'Avg SCU / Session')
    (New-Treemap     20 170 600 250 'ByPlugin' 'Plugin' 'SCU' 'Plugin SCU Treemap')
    (New-Scatter    630 170 600 250 'ByPlugin' 'Plugin' 'Sessions' 'Avg_SCU' 'SCU' 'Cost-Efficiency: Sessions (X) vs Avg SCU (Y), bubble=Total')
    (New-TableVisual 20 440 600 220 'ByPlugin' @('Plugin','Sessions','SCU','Avg_SCU','Max_SCU') 'Plugins/Agents Detail')
    (New-TableVisual 630 440 600 220 'Skills' @('Skill','User','Plugin','Date','SCU_Session') 'Skills (raw invocations)')
)

# Page 6: Plugin Catalog - what plugins are available in this workspace
$catalogVisuals = @(
    (New-Card       20  20 285 130 'PluginCatalog' 'Available Plugins'  'Available Plugins')
    (New-Card      325  20 285 130 'PluginCatalog' 'Enabled Plugins'    'Enabled')
    (New-Card      630  20 285 130 'PluginCatalog' 'MCP Plugins'        'MCP-Enabled')
    (New-Card      935  20 285 130 'PluginCatalog' 'Preview Plugins'    'Preview State')
    (New-DonutChart  20 170 400 250 'PluginCatalog' 'Category' 'Available Plugins' 'Plugins by Category')
    (New-DonutChart 430 170 400 250 'PluginCatalog' 'PreviewState' 'Available Plugins' 'Plugins by Preview State')
    (New-DonutChart 840 170 400 250 'PluginCatalog' 'UserVisibility' 'Available Plugins' 'Plugins by Visibility')
    (New-TableVisual 20 440 1200 220 'PluginCatalog' @('DisplayName','Category','Enabled','PreviewState','HasMcp','Compliance','SkillCount','Description') 'All Available Plugins')
)

# Page 7: Promptbooks - what promptbooks exist and their prompts
$promptbookVisuals = @(
    (New-Card       20  20 285 130 'Promptbooks' 'Total Promptbooks' 'Total Promptbooks')
    (New-Card      325  20 285 130 'Promptbooks' 'Total Prompts'     'Total Prompts')
    (New-DonutChart 630 20 590 350 'Promptbooks' 'Visibility' 'Total Promptbooks' 'Promptbooks by Visibility')
    (New-TableVisual 20 170 590 200 'Promptbooks' @('Name','Visibility','PromptCount','Description') 'Available Promptbooks')
    (New-TableVisual 20 390 1200 270 'PromptbookPrompts' @('PromptbookName','PromptSequence','PromptType','Content','SkillName','PluginCount') 'Individual Prompts in Promptbooks')
)

# Page 5: Users - user-level drilldown
$userVisuals = @(
    (New-Slicer      20  20 300 640 'Sessions' 'User' 'Select User')
    (New-Card       340  20 200 130 'Sessions' 'Total SCU'          'Total SCU (filtered)')
    (New-Card       550  20 200 130 'Sessions' 'Total Sessions'     'Total Sessions')
    (New-Card       760  20 200 130 'Sessions' 'Total Interactions' 'Total Interactions')
    (New-Card       970  20 200 130 'Sessions' 'Est Total Cost USD' 'Est. Cost USD')
    (New-TableVisual 340 170 830 250 'ByUser' @('User','Department','Sessions','SCU','Avg_SCU','Max_SCU','Distinct_Plugins') 'Users Summary')
    (New-BarChart    340 440 830 220 'Sessions' 'Plugins' 'Total SCU' 'Plugins used by selected user')
)

# Page 8: Analytics - waterfall + actual vs estimated cost + anomaly table
$analyticsVisuals = @(
    (New-Card       20  20 285 120 'ActualCost' 'Actual Total Cost'  'Actual Cost (Azure bill)')
    (New-Card      325  20 285 120 'Sessions'   'Est Total Cost USD' 'Estimated Cost')
    (New-Card      630  20 285 120 'ActualCost' 'Overage Cost'       'Overage $')
    (New-Card      935  20 285 120 'ActualCost' 'Provisioned Cost'   'Provisioned $')
    # Explanatory note under the cards
    (New-TextBox   20 145 1200 70 'ESTIMATE NOTE: Estimated Cost = Total SCU x 6 USD (published Overage list price). It ignores your small Provisioned baseline and can lag Actual by a day due to billing timing. Use Actual Cost for anything financial.' 9 '#9CA3AF' 'normal')
    (New-Waterfall   20 220 600 190 'Daily' 'Day' 'Delta_vs_Prev' 'Daily SCU Change (Waterfall)')
    (New-LineChart  630 220 600 190 'ActualCost' 'Day' 'Actual Total Cost' 'Actual daily cost trend')
    (New-TableVisual 20 415 1200 220 'Daily' @('Day','SCU_Total','Est_Cost_USD','Rolling_7d_Avg','Rolling_30d_Avg','Delta_vs_Prev','Anomaly_Sigma','Is_Anomaly') 'Daily rollup w/ rolling averages + anomaly flags')
)

function New-Section([int]$id, [string]$name, [string]$displayName, [array]$visuals) {
    $sectionCfg = [ordered]@{
        objects = [ordered]@{
            background = @(
                [ordered]@{
                    properties = [ordered]@{
                        color = [ordered]@{ solid = [ordered]@{ color = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'#0E1116'" } } } } }
                        transparency = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "0D" } } }
                    }
                }
            )
            outspace = @(
                [ordered]@{
                    properties = [ordered]@{
                        color = [ordered]@{ solid = [ordered]@{ color = [ordered]@{ expr = [ordered]@{ Literal = [ordered]@{ Value = "'#0E1116'" } } } } }
                    }
                }
            )
        }
    }
    [ordered]@{
        id = $id
        name = $name
        displayName = $displayName
        filters = '[]'
        ordinal = $id
        visualContainers = $visuals
        config = ($sectionCfg | ConvertTo-Json -Depth 20 -Compress)
        displayOption = 1
        height = 720.0
        width = 1280.0
    }
}

$layout = [ordered]@{
    id = 0
    resourcePackages = @(
        [ordered]@{
            resourcePackage = [ordered]@{
                name = 'SharedResources'
                type = 2
                items = @()
                disabled = $false
            }
        }
        [ordered]@{
            resourcePackage = [ordered]@{
                name = 'RegisteredResources'
                type = 1
                items = @(
                    [ordered]@{ type = 202; path = 'SCU-Theme.json'; name = 'SCU-Theme' }
                )
                disabled = $false
            }
        }
    )
    config = ( [ordered]@{
        version = '5.55'
        themeCollection = [ordered]@{
            customTheme = [ordered]@{
                name = 'SCU-Theme'
                reportVersionAtImport = '5.55'
                type = 'RegisteredResources'
            }
        }
        activeSectionIndex = 0
        defaultDrillFilterOtherVisuals = $true
        settings = [ordered]@{ useStylableVisualContainerHeader = $true; exportDataMode = 1 }
    } | ConvertTo-Json -Depth 20 -Compress )
    layoutOptimization = 0
    sections = @(
        (New-Section 0 'ReportSection0'  'Cover'          $coverVisuals)
        (New-Section 1 'ReportSectionG'  'Guide'          $guideVisuals)
        (New-Section 2 'ReportSection'   'Overview'       (Add-PageHeader 'Overview' 'Big-picture SCU consumption for the current window. Cards show totals. Charts break down by day, user, and plugin.' $overviewVisuals))
        (New-Section 3 'ReportSection1'  'Sessions'       (Add-PageHeader 'Sessions' 'Every session/interaction that consumed SCU. Use slicers to filter by user, category, type, or Copilot experience.' $sessionsVisuals))
        (New-Section 4 'ReportSection2'  'Trends'         (Add-PageHeader 'Trends' 'Time-series patterns with 7-day forecast. Heatmap shows peak hours. Anomaly Days = SCU > 2 standard deviations above 90-day mean.' $trendsVisuals))
        (New-Section 5 'ReportSection3'  'Plugins Used'   (Add-PageHeader 'Plugins Used' 'Which plugins/agents actually consumed SCU. Treemap size = share of total. Scatter: bottom-left = cheap+rare, top-right = frequent+expensive.' $pluginVisuals))
        (New-Section 6 'ReportSection4'  'Users'          (Add-PageHeader 'Users' 'Per-user consumption. Select a user in the left panel to filter all metrics. Agent users are machine identities running autonomous agents.' $userVisuals))
        (New-Section 7 'ReportSection5'  'Plugin Catalog' (Add-PageHeader 'Plugin Catalog' 'All plugins AVAILABLE in your workspace (used or not). Enabled = active. MCP = Model Context Protocol connector. Preview = not yet GA.' $catalogVisuals))
        (New-Section 8 'ReportSection6'  'Promptbooks'    (Add-PageHeader 'Promptbooks' 'Reusable prompt templates registered in your workspace. Visibility: Global (Microsoft-provided), Tenant (org-wide), Private (yours only).' $promptbookVisuals))
        (New-Section 9 'ReportSection7'  'Analytics'      (Add-PageHeader 'Analytics' 'Actual Azure bill vs $6/SCU estimate. Waterfall shows day-over-day change (green=up, red=down). Anomaly Sigma = z-score (>2 = anomaly).' $analyticsVisuals))
    )
}
$layoutJson = $layout | ConvertTo-Json -Depth 30 -Compress

# ===== SUPPORT FILES =====
$version = '1.30'

$metadata = [ordered]@{
    Version = 5
    AutoCreatedRelationships = @()
    FileDescription = 'Security Copilot SCU Dashboard'
    CreatedFrom = 'Desktop'
    CreatedFromRelease = 'June2026'
} | ConvertTo-Json -Compress

$settings = [ordered]@{
    Version = 4
    ReportSettings = [ordered]@{
        IsRelationshipAutodetectionEnabled = $false
        IsQnaEnabledForThisFile = $false
    }
    QueriesSettings = [ordered]@{
        TypeDetectionEnabled = $true
        RelationshipImportEnabled = $true
        Version = '2.132.328.0'
    }
} | ConvertTo-Json -Compress

$connections = '{"Version":3,"RemoteArtifacts":[{"DatasetId":"'+ (New-Guid2) +'","ReportId":"'+ (New-Guid2) +'"}]}'

$diagramLayout = [ordered]@{
    version = 4
    diagrams = @(
        [ordered]@{
            ordinal = 0
            scrollPosition = @{ x = 0; y = 0 }
            nodes = @()
            name = 'All tables'
            zoomValue = 100
            pinKeyFieldsToTop = $false
            showExtraHeaderInfo = $false
            hideKeyFieldsWhenCollapsed = $false
            tablesLocked = $false
        }
    )
    selectedDiagram = 'All tables'
    defaultDiagram = 'All tables'
} | ConvertTo-Json -Depth 10 -Compress

$contentTypes = '<?xml version="1.0" encoding="utf-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="json" ContentType=""/><Default Extension="xml" ContentType=""/><Override PartName="/Version" ContentType=""/><Override PartName="/DataModelSchema" ContentType=""/><Override PartName="/DiagramLayout" ContentType=""/><Override PartName="/Report/Layout" ContentType=""/><Override PartName="/Settings" ContentType="application/json"/><Override PartName="/Metadata" ContentType="application/json"/><Override PartName="/Connections" ContentType=""/></Types>'

$rels = '<?xml version="1.0" encoding="utf-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"></Relationships>'

# ===== WRITE ZIP =====
if (Test-Path $OutputPath) { Remove-Item $OutputPath -Force }
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
$fs = [System.IO.File]::Create($OutputPath)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)

function Add-Entry([string]$name, [byte[]]$bytes) {
    $e = $zip.CreateEntry($name, [System.IO.Compression.CompressionLevel]::Optimal)
    $s = $e.Open(); $s.Write($bytes, 0, $bytes.Length); $s.Dispose()
}
function Add-Utf16LE([string]$name, [string]$text) {
    $enc = New-Object System.Text.UnicodeEncoding($false, $false)  # LE, NO BOM
    Add-Entry $name $enc.GetBytes($text)
}
function Add-Utf8NoBom([string]$name, [string]$text) {
    $enc = New-Object System.Text.UTF8Encoding($false)
    Add-Entry $name $enc.GetBytes($text)
}

Add-Utf16LE   'Version' $version
Add-Utf8NoBom '[Content_Types].xml' $contentTypes
Add-Utf16LE   'DataModelSchema' $dataModelSchema
Add-Utf16LE   'DiagramLayout' $diagramLayout
Add-Utf16LE   'Report/Layout' $layoutJson
Add-Utf16LE   'Metadata' $metadata
Add-Utf16LE   'Settings' $settings
Add-Utf8NoBom 'Connections' $connections
Add-Utf8NoBom '_rels/.rels' $rels

# Theme
$themeSrc = Join-Path $PSScriptRoot 'powerbi-kit\SCU-Theme.json'
if (Test-Path $themeSrc) {
    $themeBytes = [System.IO.File]::ReadAllBytes($themeSrc)
    Add-Entry 'Report/StaticResources/RegisteredResources/SCU-Theme.json' $themeBytes
}

$zip.Dispose(); $fs.Dispose()

$size = [math]::Round((Get-Item $OutputPath).Length/1KB, 1)
Write-Host "PBIT built: $OutputPath ($size KB)" -ForegroundColor Green
}
#endregion

# ============================================================
#region HTML Builder (from New-SCUDashboardHTML.ps1)
# ============================================================
function Invoke-ScuHtml {
    param(
        [string]$InputXlsx  = (Join-Path $OutDir 'SCU-Report.xlsx'),
        [string]$InputJson  = (Join-Path $OutDir 'SCU-Report.json'),
        [string]$OutputHtml = (Join-Path $OutDir 'SCU-Dashboard.html'),
        [string]$OutDir     = (Split-Path $OutputHtml -Parent)
    )
function Read-SheetSafely {
    param([string]$Path, [string]$SheetName)
    try {
        $rows = Import-Excel -Path $Path -WorksheetName $SheetName -ErrorAction Stop
        if ($null -eq $rows) { return @() }
        return @($rows)
    } catch {
        Write-Warning "Could not read sheet '$SheetName': $_"
        return @()
    }
}

function Test-XlsxReadable { param([string]$Path); try { $null = Get-ExcelSheetInfo -Path $Path -ErrorAction Stop; return $true } catch { return $false } }

# ---------- Load data (prefer JSON companion - it hydrates cleanly through OneDrive) ----------
$usedJson = $false
$sessions = @(); $hourly = @(); $daily = @(); $actualCost = @()
$byPlugin = @(); $byUser = @(); $byExperience = @(); $byCategory = @()
$skills = @(); $heatmap = @(); $pluginCatalog = @()
$promptbooks = @(); $promptbookPrompts = @(); $sessionCatalog = @()
$summary = @(); $generatedTs = (Get-Date).ToString('yyyy-MM-dd HH:mm'); $windowLabel = "Last 90 days"

if (Test-Path $InputJson) {
    Write-Host "Reading $InputJson..." -ForegroundColor Cyan
    try {
        $pack = Get-Content -Path $InputJson -Raw | ConvertFrom-Json
        $sessions          = @($pack.Sessions)
        $hourly            = @($pack.Hourly)
        $daily             = @($pack.Daily)
        $actualCost        = @($pack.ActualCost)
        $byPlugin          = @($pack.ByPlugin)
        $byUser            = @($pack.ByUser)
        $byExperience      = @($pack.ByExperience)
        $byCategory        = @($pack.ByCategory)
        $skills            = @($pack.Skills)
        $heatmap           = @($pack.Heatmap)
        $pluginCatalog     = @($pack.PluginCatalog)
        $promptbooks       = @($pack.Promptbooks)
        $promptbookPrompts = @($pack.PromptbookPrompts)
        $sessionCatalog    = @($pack.SessionCatalog)
        $summary           = @($pack.Summary)
        if ($pack.Generated) { $generatedTs = $pack.Generated }
        if ($pack.Window)    { $windowLabel = $pack.Window }
        $usedJson = $true
        Write-Host "  Loaded from JSON companion" -ForegroundColor Gray
    } catch {
        Write-Warning "JSON read failed ($($_.Exception.Message)); falling back to XLSX."
    }
}

if (-not $usedJson) {
    if (-not (Test-Path $InputXlsx)) {
        throw "Neither $InputJson nor $InputXlsx found. Run SCU-Run.ps1 first."
    }
    if (-not (Get-Module -ListAvailable ImportExcel)) {
        throw "ImportExcel module required. Install with: Install-Module ImportExcel -Scope CurrentUser"
    }
    Import-Module ImportExcel

    Write-Host "Reading $InputXlsx..." -ForegroundColor Cyan

    # OneDrive Files On-Demand can hide the real .xlsx bytes behind a placeholder wrapper
    # that fails EPPlus's header sanity check. Strategy: try to read directly first; only
    # fall back to hydration + Excel COM if ImportExcel actually cannot open the file.
    $readPath = $InputXlsx
    $tempXlsx = $null

    if (-not (Test-XlsxReadable $InputXlsx)) {
        Write-Host "  File unreadable via direct path; attempting hydration..." -ForegroundColor Yellow
        $tempXlsx = Join-Path $env:TEMP ("SCU-Report-" + [guid]::NewGuid().ToString('N').Substring(0,8) + ".xlsx")
        try {
            & attrib.exe +P $InputXlsx 2>&1 | Out-Null
            Start-Sleep -Seconds 2
            Copy-Item -Path $InputXlsx -Destination $tempXlsx -Force
        } catch { Write-Verbose "Pin+copy: $_" }

        if (-not (Test-XlsxReadable $tempXlsx)) {
            Write-Host "  Falling back to Excel COM for hydration..." -ForegroundColor Yellow
            try {
                if (Test-Path $tempXlsx) { Remove-Item $tempXlsx -Force }
                $excel = New-Object -ComObject Excel.Application
                $excel.Visible = $false; $excel.DisplayAlerts = $false
                $wb = $excel.Workbooks.Open($InputXlsx, 0, $true)
                $wb.SaveAs($tempXlsx, 51) # xlOpenXMLWorkbook
                $wb.Close($false); $excel.Quit()
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wb) | Out-Null
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
                [GC]::Collect(); [GC]::WaitForPendingFinalizers()
            } catch { Write-Warning "Excel COM: $_" }
        }

        if (Test-XlsxReadable $tempXlsx) {
            Write-Host "  Hydrated to $tempXlsx" -ForegroundColor Gray
            $readPath = $tempXlsx
        } else {
            throw "Could not read $InputXlsx. Try: (1) open the file in Excel and re-save, (2) run SCU-Run.ps1 again to regenerate SCU-Report.json companion."
        }
    }

    $summary            = Read-SheetSafely $readPath 'Summary'
    $sessions           = Read-SheetSafely $readPath 'Sessions'
    $hourly             = Read-SheetSafely $readPath 'Hourly'
    $daily              = Read-SheetSafely $readPath 'Daily'
    $actualCost         = Read-SheetSafely $readPath 'Actual-Cost'
    $byPlugin           = Read-SheetSafely $readPath 'By-Plugin'
    $byUser             = Read-SheetSafely $readPath 'By-User'
    $byExperience       = Read-SheetSafely $readPath 'By-Experience'
    $byCategory         = Read-SheetSafely $readPath 'By-Category'
    $skills             = Read-SheetSafely $readPath 'Skills'
    $heatmap            = Read-SheetSafely $readPath 'Heatmap'
    $pluginCatalog      = Read-SheetSafely $readPath 'Plugin-Catalog'
    $promptbooks        = Read-SheetSafely $readPath 'Promptbooks'
    $promptbookPrompts  = Read-SheetSafely $readPath 'Promptbook-Prompts'
    $sessionCatalog     = Read-SheetSafely $readPath 'Session-Catalog'

    if ($tempXlsx -and (Test-Path $tempXlsx)) { Remove-Item $tempXlsx -Force -ErrorAction SilentlyContinue }

    if ($summary.Count -gt 0 -and $summary[0].Generated) { $generatedTs = $summary[0].Generated }
    if ($summary.Count -gt 0 -and $summary[0].Window)    { $windowLabel = $summary[0].Window }
}

Write-Host "  Sessions:$($sessions.Count) Hourly:$($hourly.Count) Daily:$($daily.Count) By-Plugin:$($byPlugin.Count) By-User:$($byUser.Count) Plugin-Catalog:$($pluginCatalog.Count)" -ForegroundColor Gray

# ---------- Compute derived metrics (mirror the PBIT DAX measures) ----------
$totalScu       = if ($sessions.Count -gt 0) { [math]::Round(($sessions | Measure-Object SCU_Used -Sum).Sum, 2) } else { 0 }
$totalSessions  = $sessions.Count
$distinctUsers  = ($sessions | Where-Object User | Select-Object -ExpandProperty User -Unique).Count
$estCostUSD     = [math]::Round($totalScu * 6.0, 2)
$actualCostTotal = if ($actualCost.Count -gt 0) { [math]::Round(($actualCost | Measure-Object Actual_Cost -Sum).Sum, 2) } else { 0 }
$overageCost    = if ($actualCost.Count -gt 0) { [math]::Round((($actualCost | Where-Object Meter -like '*Overage*') | Measure-Object Actual_Cost -Sum).Sum, 2) } else { 0 }
$provCost       = if ($actualCost.Count -gt 0) { [math]::Round((($actualCost | Where-Object Meter -like '*Provisioned*') | Measure-Object Actual_Cost -Sum).Sum, 2) } else { 0 }
$distinctPlugins = ($sessions | Where-Object Plugins | Select-Object -ExpandProperty Plugins -Unique).Count
$distinctSkills  = ($skills | Where-Object Skill | Select-Object -ExpandProperty Skill -Unique).Count
$skillInvocations = $skills.Count
$avgScuSession  = if ($totalSessions -gt 0) { [math]::Round($totalScu / $totalSessions, 3) } else { 0 }
$peakHourly     = if ($hourly.Count -gt 0) { [math]::Round(($hourly | Measure-Object 'Hourly SCU' -Maximum -ErrorAction SilentlyContinue).Maximum, 3) } else { 0 }
$rolling7d      = if ($daily.Count -gt 0) { [math]::Round(($daily[-1].'Rolling_7d_Avg'), 3) } else { 0 }
$rolling30d     = if ($daily.Count -gt 0) { [math]::Round(($daily[-1].'Rolling_30d_Avg'), 3) } else { 0 }
$anomalyDays    = if ($daily.Count -gt 0) { ($daily | Where-Object Is_Anomaly -eq $true).Count } else { 0 }
$availPlugins   = $pluginCatalog.Count
$enabledPlugins = ($pluginCatalog | Where-Object Enabled -eq $true).Count
$mcpPlugins     = ($pluginCatalog | Where-Object HasMcp -eq $true).Count
$previewPlugins = ($pluginCatalog | Where-Object PreviewState -eq 'Preview').Count
$totalPromptbooks = $promptbooks.Count
$totalPrompts   = $promptbookPrompts.Count
$totalInteractions = if ($sessions -and ($sessions[0].PSObject.Properties.Name -contains 'SkillCount')) {
    ($sessions | Measure-Object SkillCount -Sum).Sum
} else { $sessions.Count }

$generatedTs    = if ($summary.Count -gt 0 -and $summary[0].Generated) { $summary[0].Generated } else { (Get-Date).ToString('yyyy-MM-dd HH:mm') }
$windowLabel    = if ($summary.Count -gt 0 -and $summary[0].Window) { $summary[0].Window } else { "Last 90 days" }

# ---------- Serialize to JSON for embedding ----------
function ConvertTo-CleanJson {
    param($obj)
    if ($null -eq $obj -or ($obj -is [array] -and $obj.Count -eq 0)) { return '[]' }
    ($obj | ConvertTo-Json -Depth 10 -Compress).Replace('</', '<\/')
}

$data = [ordered]@{
    generated        = $generatedTs
    window           = $windowLabel
    totals = [ordered]@{
        totalScu           = $totalScu
        totalSessions      = $totalSessions
        distinctUsers      = $distinctUsers
        estCostUSD         = $estCostUSD
        actualCostTotal    = $actualCostTotal
        overageCost        = $overageCost
        provCost           = $provCost
        distinctPlugins    = $distinctPlugins
        distinctSkills     = $distinctSkills
        skillInvocations   = $skillInvocations
        avgScuSession      = $avgScuSession
        peakHourly         = $peakHourly
        rolling7d          = $rolling7d
        rolling30d         = $rolling30d
        anomalyDays        = $anomalyDays
        availPlugins       = $availPlugins
        enabledPlugins     = $enabledPlugins
        mcpPlugins         = $mcpPlugins
        previewPlugins     = $previewPlugins
        totalPromptbooks   = $totalPromptbooks
        totalPrompts       = $totalPrompts
        totalInteractions  = $totalInteractions
    }
}

$dataJsonBlocks = @()
$dataJsonBlocks += "const DASH = $((ConvertTo-CleanJson $data));"
$dataJsonBlocks += "const SESSIONS         = $(ConvertTo-CleanJson $sessions);"
$dataJsonBlocks += "const HOURLY           = $(ConvertTo-CleanJson $hourly);"
$dataJsonBlocks += "const DAILY            = $(ConvertTo-CleanJson $daily);"
$dataJsonBlocks += "const ACTUAL_COST      = $(ConvertTo-CleanJson $actualCost);"
$dataJsonBlocks += "const BY_PLUGIN        = $(ConvertTo-CleanJson $byPlugin);"
$dataJsonBlocks += "const BY_USER          = $(ConvertTo-CleanJson $byUser);"
$dataJsonBlocks += "const BY_EXPERIENCE    = $(ConvertTo-CleanJson $byExperience);"
$dataJsonBlocks += "const BY_CATEGORY      = $(ConvertTo-CleanJson $byCategory);"
$dataJsonBlocks += "const SKILLS           = $(ConvertTo-CleanJson $skills);"
$dataJsonBlocks += "const HEATMAP          = $(ConvertTo-CleanJson $heatmap);"
$dataJsonBlocks += "const PLUGIN_CATALOG   = $(ConvertTo-CleanJson $pluginCatalog);"
$dataJsonBlocks += "const PROMPTBOOKS      = $(ConvertTo-CleanJson $promptbooks);"
$dataJsonBlocks += "const PROMPTBOOK_PROMPTS = $(ConvertTo-CleanJson $promptbookPrompts);"
$dataJsonBlocks += "const SESSION_CATALOG  = $(ConvertTo-CleanJson $sessionCatalog);"

$dataJs = ($dataJsonBlocks -join "`n")

# ---------- Build HTML ----------
$html = @'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Security Copilot - SCU Usage Dashboard</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/chartjs-chart-matrix@2.0.1/dist/chartjs-chart-matrix.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/chartjs-chart-treemap@2.3.0/dist/chartjs-chart-treemap.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/chartjs-adapter-date-fns@3.0.0/dist/chartjs-adapter-date-fns.bundle.min.js"></script>
  <style>
    :root {
      --bg:            #0E1116;
      --bg-panel:      #1E2532;
      --bg-panel-alt:  #171C25;
      --border:        #334155;
      --border-soft:   #1F2A3A;
      --text:          #F9FAFB;
      --text-muted:    #94A3B8;
      --text-dim:      #6B7280;
      --accent:        #50E6FF;
      --accent-2:      #0078D4;
      --accent-3:      #A78BFA;
      --up:            #22C55E;
      --down:          #EF4444;
      --warn:          #F59E0B;
    }
    * { box-sizing: border-box; }
    html, body {
      background: var(--bg);
      color: var(--text);
      font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
      font-size: 14px;
      margin: 0;
      padding: 0;
      -webkit-font-smoothing: antialiased;
    }
    a { color: var(--accent); text-decoration: none; }

    /* Top hero + tabs */
    .hero {
      padding: 20px 32px 0;
      border-bottom: 1px solid var(--border-soft);
      background: linear-gradient(180deg, #0F1420 0%, #0E1116 100%);
    }
    .hero h1 {
      font-size: 22px;
      font-weight: 600;
      margin: 0 0 4px;
      letter-spacing: -0.02em;
    }
    .hero .subtitle { font-size: 12px; color: var(--text-muted); margin: 0 0 16px; }
    .hero .refresh-strip {
      display: flex; justify-content: space-between; align-items: center;
      font-size: 11px; color: var(--text-dim); margin-bottom: 12px;
    }
    .tabs {
      display: flex; gap: 2px; overflow-x: auto;
      border-bottom: 1px solid var(--border-soft);
      padding: 0;
    }
    .tab {
      padding: 10px 16px; cursor: pointer; font-size: 12px; font-weight: 500;
      color: var(--text-muted); border-bottom: 2px solid transparent;
      transition: all 0.15s ease; user-select: none; white-space: nowrap;
    }
    .tab:hover { color: var(--text); background: rgba(80, 230, 255, 0.05); }
    .tab.active { color: var(--accent); border-bottom-color: var(--accent); background: rgba(80, 230, 255, 0.03); }

    /* Content area */
    .content { padding: 20px 32px 32px; }
    .page { display: none; }
    .page.active { display: block; }
    .page h2 {
      font-size: 16px; font-weight: 600; margin: 0 0 4px;
    }
    .page .page-subtitle { font-size: 11px; color: var(--text-muted); margin-bottom: 16px; }

    /* Cards & grids */
    .card {
      background: var(--bg-panel);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 14px 16px;
      overflow: hidden;
    }
    .kpi { display: flex; flex-direction: column; justify-content: space-between; min-height: 96px; }
    .kpi .label { font-size: 11px; color: var(--text-muted); text-transform: none; letter-spacing: 0; }
    .kpi .value { font-size: 26px; font-weight: 600; color: var(--accent); margin-top: 4px; line-height: 1.1; }
    .kpi .sublabel { font-size: 10px; color: var(--text-dim); margin-top: 2px; }
    .grid { display: grid; gap: 12px; }
    .grid.k4 { grid-template-columns: repeat(4, minmax(0, 1fr)); }
    .grid.k3 { grid-template-columns: repeat(3, minmax(0, 1fr)); }
    .grid.k2 { grid-template-columns: repeat(2, minmax(0, 1fr)); }

    /* Chart panels */
    .panel {
      background: var(--bg-panel);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 12px 14px 14px;
    }
    .panel .title { font-size: 12px; font-weight: 600; color: var(--text-muted); margin: 0 0 6px; }
    .chart-wrap { position: relative; height: 260px; }
    .chart-wrap.tall { height: 320px; }
    .chart-wrap.short { height: 200px; }

    /* Tables */
    table.scu {
      width: 100%; border-collapse: collapse; font-size: 12px;
    }
    table.scu th {
      text-align: left; padding: 8px 10px; font-weight: 600;
      color: var(--text-muted); background: #131923;
      border-bottom: 1px solid var(--border); font-size: 11px;
      position: sticky; top: 0;
    }
    table.scu td {
      padding: 6px 10px; border-bottom: 1px solid var(--border-soft);
      color: var(--text); white-space: nowrap;
      max-width: 320px; overflow: hidden; text-overflow: ellipsis;
    }
    /* Cells that need to show a full identifier - wider + wraps to 2 lines */
    table.scu td.name {
      max-width: 340px; white-space: normal; overflow: visible;
      text-overflow: unset; line-height: 1.3;
    }
    /* Long content cells (prompt bodies, descriptions) - wrap freely */
    table.scu td.wrap {
      max-width: 480px; white-space: normal; overflow: visible;
      text-overflow: unset; line-height: 1.35;
    }
    table.scu tr:hover td { background: rgba(80, 230, 255, 0.04); }
    .table-scroll { max-height: 480px; overflow: auto; border: 1px solid var(--border); border-radius: 8px; }
    .num { text-align: right; font-variant-numeric: tabular-nums; }
    .badge {
      display: inline-block; padding: 1px 6px; border-radius: 3px;
      font-size: 10px; font-weight: 500;
    }
    .badge.up { background: rgba(34,197,94,0.15); color: var(--up); }
    .badge.down { background: rgba(239,68,68,0.15); color: var(--down); }
    .badge.warn { background: rgba(245,158,11,0.15); color: var(--warn); }
    .badge.info { background: rgba(80,230,255,0.15); color: var(--accent); }

    /* Filters */
    .filter-row { display: flex; gap: 10px; align-items: center; margin-bottom: 12px; flex-wrap: wrap; }
    .filter {
      background: var(--bg-panel); border: 1px solid var(--border);
      border-radius: 6px; padding: 6px 10px; color: var(--text);
      font-size: 12px; font-family: inherit; min-width: 150px;
    }
    .filter:focus { outline: 2px solid var(--accent); }
    .search {
      background: var(--bg-panel); border: 1px solid var(--border);
      border-radius: 6px; padding: 6px 10px; color: var(--text);
      font-size: 12px; font-family: inherit; width: 240px;
    }

    /* Cover page */
    .cover-header {
      text-align: center; margin: 20px 0 24px;
    }
    .cover-header h1 {
      font-size: 28px; margin: 0 0 4px; font-weight: 600;
      background: linear-gradient(90deg, #FFFFFF 0%, #50E6FF 100%);
      -webkit-background-clip: text; background-clip: text; color: transparent;
    }
    .cover-header p { font-size: 12px; color: var(--text-muted); margin: 0; }

    /* Guide grid */
    .guide-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px 20px; margin-bottom: 20px; }
    .guide-item h4 { font-size: 12px; margin: 0 0 3px; color: var(--text); font-weight: 600; }
    .guide-item p { font-size: 11px; color: var(--text-muted); margin: 0; line-height: 1.4; }
    .glossary-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 14px 24px; }
    .glossary-item h4 { font-size: 12px; margin: 0 0 3px; color: var(--accent); font-weight: 600; }
    .glossary-item p { font-size: 11px; color: var(--text-muted); margin: 0; line-height: 1.4; }
    .section-title {
      font-size: 12px; font-weight: 600; color: var(--accent);
      text-transform: uppercase; letter-spacing: 0.06em; margin: 20px 0 10px;
    }

    /* Footer */
    footer {
      padding: 14px 32px; text-align: right; font-size: 10px;
      color: var(--text-dim); border-top: 1px solid var(--border-soft);
    }

    /* Small responsive tweaks */
    @media (max-width: 1100px) { .grid.k4 { grid-template-columns: repeat(2, 1fr); } .grid.k3 { grid-template-columns: repeat(2, 1fr); } .guide-grid { grid-template-columns: 1fr 1fr; } }
    @media (max-width: 700px)  { .grid.k4, .grid.k3, .grid.k2, .guide-grid, .glossary-grid { grid-template-columns: 1fr; } }
  </style>
</head>
<body>

<div class="hero">
  <div class="refresh-strip">
    <span>Data refreshed: <b id="ts-refresh"></b> &nbsp;·&nbsp; Window: <b id="ts-window"></b></span>
    <span>Security Copilot - SCU Monitoring</span>
  </div>
  <h1>Security Copilot - SCU Usage Dashboard</h1>
  <p class="subtitle">Real-time visibility into your Security Compute Unit consumption across sessions, users, plugins and cost.</p>
  <div class="tabs" id="tabs">
    <div class="tab active" data-tab="cover">Cover</div>
    <div class="tab" data-tab="guide">Guide</div>
    <div class="tab" data-tab="overview">Overview</div>
    <div class="tab" data-tab="sessions">Sessions</div>
    <div class="tab" data-tab="trends">Trends</div>
    <div class="tab" data-tab="plugins">Plugins Used</div>
    <div class="tab" data-tab="users">Users</div>
    <div class="tab" data-tab="catalog">Plugin Catalog</div>
    <div class="tab" data-tab="promptbooks">Promptbooks</div>
    <div class="tab" data-tab="analytics">Analytics</div>
  </div>
</div>

<div class="content">

<!-- COVER -->
<section class="page active" id="page-cover">
  <div class="cover-header">
    <h1>Security Copilot - SCU Usage Dashboard</h1>
    <p>Real-time visibility into your Security Compute Unit consumption across sessions, users, plugins and cost.</p>
  </div>

  <div class="grid k4" style="margin-bottom: 12px;">
    <div class="card kpi"><div class="label">Total SCU</div><div class="value" data-metric="totalScu"></div><div class="sublabel">Sum of SCU_Used across all sessions in window</div></div>
    <div class="card kpi"><div class="label">Total Sessions</div><div class="value" data-metric="totalSessions"></div><div class="sublabel">Distinct SessionId count</div></div>
    <div class="card kpi"><div class="label">Distinct Users</div><div class="value" data-metric="distinctUsers"></div><div class="sublabel">Unique User principals</div></div>
    <div class="card kpi"><div class="label">Estimated Cost USD</div><div class="value" data-metric="estCostUSD" data-format="$"></div><div class="sublabel">Total SCU x $6 list price</div></div>
  </div>
  <div class="grid k4" style="margin-bottom: 12px;">
    <div class="card kpi"><div class="label">Actual Azure Bill USD</div><div class="value" data-metric="actualCostTotal" data-format="$"></div><div class="sublabel">From Cost Management (your rate)</div></div>
    <div class="card kpi"><div class="label">Available Plugins</div><div class="value" data-metric="availPlugins"></div><div class="sublabel">From workspace catalog</div></div>
    <div class="card kpi"><div class="label">Promptbooks</div><div class="value" data-metric="totalPromptbooks"></div><div class="sublabel">Reusable prompt templates</div></div>
    <div class="card kpi"><div class="label">Anomaly Days (>2 sigma)</div><div class="value" data-metric="anomalyDays"></div><div class="sublabel">Daily SCU above 2 standard deviations</div></div>
  </div>

  <div class="section-title">Getting Started</div>
  <div class="card" style="padding: 12px 16px; font-size: 12px; color: var(--text);">
    Use the tabs at the top to explore. Start with <b>Guide</b> for definitions, or jump to
    <b>Overview</b> / <b>Sessions</b> / <b>Trends</b> / <b>Plugins Used</b> / <b>Users</b> /
    <b>Plugin Catalog</b> / <b>Promptbooks</b> / <b>Analytics</b>.
  </div>
  <div class="card" style="padding: 12px 16px; font-size: 11px; color: var(--text-muted); margin-top: 10px;">
    <b>Data source:</b> Security Copilot portal API (undocumented) + Azure Cost Management + Microsoft Graph.
    To refresh, run <code style="color: var(--accent);">SCU-Run.ps1</code>.
    <br><b>Estimated Cost</b> = Total SCU x 6 USD (published list price). <b>Actual Azure Bill</b> comes from Cost Management and reflects your negotiated rate.
  </div>
</section>

<!-- GUIDE -->
<section class="page" id="page-guide">
  <h2>How to Use This Report</h2>
  <p class="page-subtitle">Every tab, every metric, plain-English explanation.</p>

  <div class="section-title">Page Guide</div>
  <div class="guide-grid">
    <div class="guide-item"><h4>Cover</h4><p>Landing page with 8 headline KPIs at a glance.</p></div>
    <div class="guide-item"><h4>Overview</h4><p>Daily SCU trend, SCU by user, and SCU by plugin/agent.</p></div>
    <div class="guide-item"><h4>Sessions</h4><p>Every interaction with filters for user, category, type, experience.</p></div>
    <div class="guide-item"><h4>Trends</h4><p>Daily line + 7-day forecast, hourly heatmap, day-of-week pattern.</p></div>
    <div class="guide-item"><h4>Plugins Used</h4><p>Treemap + scatter of the plugins actually consumed in this window.</p></div>
    <div class="guide-item"><h4>Users</h4><p>User leaderboard and per-user session count.</p></div>
    <div class="guide-item"><h4>Plugin Catalog</h4><p>All plugins available in your tenant with tags, type, provider.</p></div>
    <div class="guide-item"><h4>Promptbooks</h4><p>Promptbooks with their prompts and estimated SCU cost.</p></div>
    <div class="guide-item"><h4>Analytics</h4><p>Rolling averages, cost estimate detail, anomaly summary.</p></div>
  </div>

  <div class="section-title">Glossary</div>
  <div class="glossary-grid">
    <div class="glossary-item"><h4>SCU (Security Compute Unit)</h4><p>Metering unit for Security Copilot. Billed by the hour at list price 6 USD per SCU-hour.</p></div>
    <div class="glossary-item"><h4>Anomaly Day</h4><p>A day where SCU consumption exceeded 2 standard deviations above the rolling mean.</p></div>
    <div class="glossary-item"><h4>Overage</h4><p>SCU billed above your Provisioned capacity. In this tenant, most usage is Overage.</p></div>
    <div class="glossary-item"><h4>Agent User</h4><p>A machine identity running an autonomous agent (SecurityCopilotAgentUser-{guid}).</p></div>
  </div>
</section>

<!-- OVERVIEW -->
<section class="page" id="page-overview">
  <h2>Overview</h2>
  <p class="page-subtitle">Big-picture SCU consumption for the current window.</p>
  <div class="grid k4" style="margin-bottom: 12px;">
    <div class="card kpi"><div class="label">Total SCU</div><div class="value" data-metric="totalScu"></div></div>
    <div class="card kpi"><div class="label">Total Sessions</div><div class="value" data-metric="totalSessions"></div></div>
    <div class="card kpi"><div class="label">Distinct Users</div><div class="value" data-metric="distinctUsers"></div></div>
    <div class="card kpi"><div class="label">Estimated Cost USD</div><div class="value" data-metric="estCostUSD" data-format="$"></div></div>
  </div>
  <div class="grid k2" style="margin-bottom: 12px;">
    <div class="panel"><div class="title">SCU by Day</div><div class="chart-wrap"><canvas id="ov-scu-day"></canvas></div></div>
    <div class="panel"><div class="title">SCU by User</div><div class="chart-wrap"><canvas id="ov-scu-user"></canvas></div></div>
  </div>
  <div class="panel"><div class="title">SCU by Plugin/Agent</div><div class="chart-wrap tall"><canvas id="ov-scu-plugin"></canvas></div></div>
</section>

<!-- SESSIONS -->
<section class="page" id="page-sessions">
  <h2>Sessions</h2>
  <p class="page-subtitle">Every session/interaction that consumed SCU. Use filters below.</p>
  <div class="filter-row">
    <select class="filter" id="fSessUser"><option value="">All Users</option></select>
    <select class="filter" id="fSessCategory"><option value="">All Categories</option></select>
    <select class="filter" id="fSessType"><option value="">All Types</option></select>
    <select class="filter" id="fSessExperience"><option value="">All Experiences</option></select>
    <input class="search" id="fSessSearch" placeholder="Search all columns...">
    <div class="card kpi" style="min-width: 200px; padding: 8px 14px;"><div class="label">SCU (filtered)</div><div class="value" id="filteredScu" style="font-size: 20px;">0</div></div>
  </div>
  <div class="table-scroll">
    <table class="scu" id="sessionsTable">
      <thead><tr><th>Date</th><th>User</th><th>Category</th><th>Type</th><th>Experience</th><th>Plugins</th><th>Skills</th><th class="num">SCU_Used</th><th>SessionId</th></tr></thead>
      <tbody></tbody>
    </table>
  </div>
</section>

<!-- TRENDS -->
<section class="page" id="page-trends">
  <h2>Trends</h2>
  <p class="page-subtitle">Time-series patterns with hourly and daily breakdown. Anomaly Days = daily SCU exceeding 2 sigma above the rolling mean.</p>
  <div class="grid k4" style="margin-bottom: 12px;">
    <div class="card kpi"><div class="label">Peak Hourly SCU</div><div class="value" data-metric="peakHourly"></div></div>
    <div class="card kpi"><div class="label">7-Day Rolling Avg</div><div class="value" data-metric="rolling7d"></div></div>
    <div class="card kpi"><div class="label">30-Day Rolling Avg</div><div class="value" data-metric="rolling30d"></div></div>
    <div class="card kpi"><div class="label">Anomaly Days (>2 sigma)</div><div class="value" data-metric="anomalyDays"></div></div>
  </div>
  <div class="panel" style="margin-bottom: 12px;"><div class="title">Daily SCU with 7-day Rolling Average (Anomaly days highlighted red)</div><div class="chart-wrap tall"><canvas id="tr-daily"></canvas></div></div>
  <div class="grid k2">
    <div class="panel"><div class="title">Day-of-Week x Hour Heatmap</div><div class="chart-wrap tall"><canvas id="tr-heatmap"></canvas></div></div>
    <div class="panel"><div class="title">SCU by Day of Week</div><div class="chart-wrap tall"><canvas id="tr-dow"></canvas></div></div>
  </div>
</section>

<!-- PLUGINS USED -->
<section class="page" id="page-plugins">
  <h2>Plugins Used</h2>
  <p class="page-subtitle">Which plugins/agents actually consumed SCU. Treemap size = share of total SCU. Scatter: bottom-left = cheap+rare, top-right = frequent+expensive.</p>
  <div class="grid k4" style="margin-bottom: 12px;">
    <div class="card kpi"><div class="label">Distinct Plugins</div><div class="value" data-metric="distinctPlugins"></div></div>
    <div class="card kpi"><div class="label">Distinct Skills</div><div class="value" data-metric="distinctSkills"></div></div>
    <div class="card kpi"><div class="label">Skill Invocations</div><div class="value" data-metric="skillInvocations"></div></div>
    <div class="card kpi"><div class="label">Avg SCU / Session</div><div class="value" data-metric="avgScuSession"></div></div>
  </div>
  <div class="grid k2" style="margin-bottom: 12px;">
    <div class="panel"><div class="title">Plugin SCU Treemap</div><div class="chart-wrap tall"><canvas id="pl-treemap"></canvas></div></div>
    <div class="panel"><div class="title">Cost-Efficiency: Sessions (X) vs Avg SCU (Y), bubble=Total</div><div class="chart-wrap tall"><canvas id="pl-scatter"></canvas></div></div>
  </div>
  <div class="grid k2">
    <div class="panel"><div class="title">Plugins/Agents Detail</div><div class="table-scroll" style="max-height: 240px;"><table class="scu" id="tblByPlugin"><thead><tr><th>Plugin</th><th class="num">Sessions</th><th class="num">SCU</th><th class="num">Avg</th><th class="num">Max</th></tr></thead><tbody></tbody></table></div></div>
    <div class="panel"><div class="title">Skills (raw invocations)</div><div class="table-scroll" style="max-height: 240px;"><table class="scu" id="tblSkills"><thead><tr><th>Skill</th><th>User</th><th>Plugin</th><th>Date</th><th class="num">SCU</th></tr></thead><tbody></tbody></table></div></div>
  </div>
</section>

<!-- USERS -->
<section class="page" id="page-users">
  <h2>Users</h2>
  <p class="page-subtitle">Per-user consumption. Select a user to filter all metrics. Agent users are machine identities running autonomous agents.</p>
  <div class="filter-row">
    <select class="filter" id="fUser"><option value="">All Users</option></select>
    <div class="card kpi" style="min-width: 160px; padding: 8px 14px;"><div class="label">Total SCU</div><div class="value" id="u-totalScu" style="font-size: 20px;">0</div></div>
    <div class="card kpi" style="min-width: 160px; padding: 8px 14px;"><div class="label">Sessions</div><div class="value" id="u-sessions" style="font-size: 20px;">0</div></div>
    <div class="card kpi" style="min-width: 160px; padding: 8px 14px;"><div class="label">Interactions</div><div class="value" id="u-interactions" style="font-size: 20px;">0</div></div>
    <div class="card kpi" style="min-width: 160px; padding: 8px 14px;"><div class="label">Est. Cost USD</div><div class="value" id="u-cost" style="font-size: 20px;">$0</div></div>
  </div>
  <div class="panel" style="margin-bottom: 12px;">
    <div class="title">Users Summary</div>
    <div class="table-scroll" style="max-height: 240px;">
      <table class="scu" id="tblByUser">
        <thead><tr><th>User</th><th>Department</th><th class="num">Sessions</th><th class="num">SCU</th><th class="num">Avg</th><th class="num">Max</th><th class="num">Distinct Plugins</th></tr></thead>
        <tbody></tbody>
      </table>
    </div>
  </div>
  <div class="panel"><div class="title">Plugins used by selected user</div><div class="chart-wrap tall"><canvas id="us-plugins"></canvas></div></div>
</section>

<!-- PLUGIN CATALOG -->
<section class="page" id="page-catalog">
  <h2>Plugin Catalog</h2>
  <p class="page-subtitle">All plugins AVAILABLE in your workspace (used or not). Enabled = active. MCP = Model Context Protocol connector. Preview = not yet GA.</p>
  <div class="grid k4" style="margin-bottom: 12px;">
    <div class="card kpi"><div class="label">Available Plugins</div><div class="value" data-metric="availPlugins"></div></div>
    <div class="card kpi"><div class="label">Enabled</div><div class="value" data-metric="enabledPlugins"></div></div>
    <div class="card kpi"><div class="label">MCP-Enabled</div><div class="value" data-metric="mcpPlugins"></div></div>
    <div class="card kpi"><div class="label">Preview State</div><div class="value" data-metric="previewPlugins"></div></div>
  </div>
  <div class="grid k3" style="margin-bottom: 12px;">
    <div class="panel"><div class="title">Plugins by Category</div><div class="chart-wrap"><canvas id="ct-category"></canvas></div></div>
    <div class="panel"><div class="title">Plugins by Preview State</div><div class="chart-wrap"><canvas id="ct-preview"></canvas></div></div>
    <div class="panel"><div class="title">Plugins by Visibility</div><div class="chart-wrap"><canvas id="ct-visibility"></canvas></div></div>
  </div>
  <div class="panel"><div class="title">All Available Plugins</div><div class="filter-row"><input class="search" id="fCatSearch" placeholder="Search plugins..."></div><div class="table-scroll"><table class="scu" id="tblCatalog"><thead><tr><th>DisplayName</th><th>Category</th><th>Enabled</th><th>PreviewState</th><th>MCP</th><th>Compliance</th><th class="num">Skills</th><th>Description</th></tr></thead><tbody></tbody></table></div></div>
</section>

<!-- PROMPTBOOKS -->
<section class="page" id="page-promptbooks">
  <h2>Promptbooks</h2>
  <p class="page-subtitle">Reusable prompt templates registered in your workspace. Visibility: Global = Microsoft-provided, Tenant = org-wide, Private = yours only.</p>
  <div class="grid k4" style="margin-bottom: 12px;">
    <div class="card kpi"><div class="label">Total Promptbooks</div><div class="value" data-metric="totalPromptbooks"></div></div>
    <div class="card kpi"><div class="label">Total Prompts</div><div class="value" data-metric="totalPrompts"></div></div>
    <div class="panel" style="grid-column: span 2;"><div class="title">Promptbooks by Visibility</div><div class="chart-wrap short"><canvas id="pb-visibility"></canvas></div></div>
  </div>
  <div class="panel" style="margin-bottom: 12px;"><div class="title">Available Promptbooks</div><div class="table-scroll" style="max-height: 220px;"><table class="scu" id="tblPromptbooks"><thead><tr><th>Name</th><th>Visibility</th><th class="num">Prompts</th><th>Description</th></tr></thead><tbody></tbody></table></div></div>
  <div class="panel"><div class="title">Individual Prompts in Promptbooks</div><div class="table-scroll" style="max-height: 260px;"><table class="scu" id="tblPrompts"><thead><tr><th>PromptbookName</th><th class="num">Seq</th><th>Type</th><th>Content</th><th>Skill</th><th class="num">Plugins</th></tr></thead><tbody></tbody></table></div></div>
</section>

<!-- ANALYTICS -->
<section class="page" id="page-analytics">
  <h2>Analytics</h2>
  <p class="page-subtitle">Actual Azure bill vs $6/SCU estimate. Waterfall shows day-over-day change (green=up, red=down). Anomaly Sigma = z-score (>2 = anomaly day).</p>
  <div class="grid k4" style="margin-bottom: 12px;">
    <div class="card kpi"><div class="label">Actual Cost (Azure bill)</div><div class="value" data-metric="actualCostTotal" data-format="$"></div></div>
    <div class="card kpi"><div class="label">Estimated Cost</div><div class="value" data-metric="estCostUSD" data-format="$"></div></div>
    <div class="card kpi"><div class="label">Overage $</div><div class="value" data-metric="overageCost" data-format="$"></div></div>
    <div class="card kpi"><div class="label">Provisioned $</div><div class="value" data-metric="provCost" data-format="$"></div></div>
  </div>
  <div class="card" style="padding: 10px 14px; font-size: 11px; color: var(--text-muted); margin-bottom: 12px;">
    <b style="color: var(--warn);">ESTIMATE NOTE:</b> Estimated Cost = Total SCU x 6 USD (published Overage list price). It ignores your small Provisioned baseline and can lag Actual by a day due to billing timing. Use Actual Cost for anything financial.
  </div>
  <div class="grid k2" style="margin-bottom: 12px;">
    <div class="panel"><div class="title">Daily SCU Change (Waterfall)</div><div class="chart-wrap"><canvas id="an-waterfall"></canvas></div></div>
    <div class="panel"><div class="title">Actual daily cost trend</div><div class="chart-wrap"><canvas id="an-cost"></canvas></div></div>
  </div>
  <div class="panel"><div class="title">Daily rollup with rolling averages + anomaly flags</div><div class="table-scroll" style="max-height: 260px;"><table class="scu" id="tblDaily"><thead><tr><th>Day</th><th class="num">SCU_Total</th><th class="num">Est_Cost_USD</th><th class="num">Rolling_7d</th><th class="num">Rolling_30d</th><th class="num">Delta_vs_Prev</th><th class="num">Anomaly_Sigma</th><th>Anomaly</th></tr></thead><tbody></tbody></table></div></div>
</section>

</div><!-- /content -->

<footer>Developed by Muataz Awad</footer>

<script>
/* ============================================================ */
/* Embedded data (from SCU-Report.xlsx)                          */
/* ============================================================ */
__DATA_JS__

/* ============================================================ */
/* Chart.js global dark styling                                  */
/* ============================================================ */
Chart.defaults.color = '#94A3B8';
Chart.defaults.borderColor = '#334155';
Chart.defaults.font.family = "'Segoe UI', sans-serif";
Chart.defaults.font.size = 11;

const PALETTE = ['#50E6FF','#0078D4','#A78BFA','#F59E0B','#22C55E','#EF4444','#EC4899','#14B8A6','#F97316','#8B5CF6','#06B6D4','#EAB308'];
const chartInstances = {};
function palette(i) { return PALETTE[i % PALETTE.length]; }
function fmtNum(v)  { if (v == null) return ''; return Number(v).toLocaleString('en-US', {maximumFractionDigits: 3}); }
function fmtInt(v)  { if (v == null) return ''; return Number(v).toLocaleString('en-US', {maximumFractionDigits: 0}); }
function fmtUsd(v)  { if (v == null) return '$0'; return '$' + Number(v).toLocaleString('en-US', {maximumFractionDigits: 2, minimumFractionDigits: 2}); }
function truncate(s, n) { if (s == null) return ''; s = String(s); return s.length > n ? s.slice(0, n - 1) + '\u2026' : s; }
function escHtml(s) { if (s == null) return ''; return String(s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }
/* Renders a cell that always shows the FULL value in a tooltip on hover, so identifiers
   with long names (promptbooks, plugins, users) never lose information visually. */
function td(value, klass) {
  const full = value == null ? '' : String(value);
  const cls  = klass ? ' class="' + klass + '"' : '';
  const tip  = full ? ' title="' + escHtml(full).replace(/"/g,'&quot;') + '"' : '';
  return `<td${cls}${tip}>${escHtml(full)}</td>`;
}
function tdTrunc(value, n, klass) {
  const full = value == null ? '' : String(value);
  const cls  = klass ? ' class="' + klass + '"' : '';
  const tip  = full ? ' title="' + escHtml(full).replace(/"/g,'&quot;') + '"' : '';
  return `<td${cls}${tip}>${escHtml(truncate(full, n))}</td>`;
}
function tdNum(value)  { return `<td class="num">${value == null || value === '' ? '' : escHtml(String(value))}</td>`; }

/* Fill top-line "Data refreshed" strip + all KPI cards */
document.getElementById('ts-refresh').textContent = DASH.generated;
document.getElementById('ts-window').textContent = DASH.window;
document.querySelectorAll('[data-metric]').forEach(el => {
  const key = el.dataset.metric;
  const fmt = el.dataset.format;
  const val = DASH.totals[key];
  if (val == null) { el.textContent = '—'; return; }
  if (fmt === '$') el.textContent = fmtUsd(val);
  else if (Number.isInteger(val)) el.textContent = fmtInt(val);
  else el.textContent = fmtNum(val);
});

/* ============================================================ */
/* Tab switcher (lazy-init charts on first activation)           */
/* ============================================================ */
const tabInit = {};
document.querySelectorAll('#tabs .tab').forEach(tab => {
  tab.addEventListener('click', () => {
    document.querySelectorAll('#tabs .tab').forEach(t => t.classList.remove('active'));
    document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
    tab.classList.add('active');
    const id = 'page-' + tab.dataset.tab;
    document.getElementById(id).classList.add('active');
    if (!tabInit[tab.dataset.tab] && renderers[tab.dataset.tab]) {
      try { renderers[tab.dataset.tab](); tabInit[tab.dataset.tab] = true; }
      catch (e) { console.error('Render error for tab ' + tab.dataset.tab, e); }
    }
  });
});

/* ============================================================ */
/* Helpers to aggregate row arrays                               */
/* ============================================================ */
function groupSum(rows, keyProp, valProp) {
  const map = new Map();
  for (const r of rows) {
    const k = r[keyProp] == null ? '(blank)' : String(r[keyProp]);
    const v = Number(r[valProp]) || 0;
    map.set(k, (map.get(k) || 0) + v);
  }
  return [...map.entries()].sort((a,b) => b[1] - a[1]);
}
function groupCount(rows, keyProp) {
  const map = new Map();
  for (const r of rows) {
    const k = r[keyProp] == null ? '(blank)' : String(r[keyProp]);
    map.set(k, (map.get(k) || 0) + 1);
  }
  return [...map.entries()].sort((a,b) => b[1] - a[1]);
}
function baseOpts(extra) {
  return Object.assign({
    responsive: true,
    maintainAspectRatio: false,
    animation: { duration: 400 },
    plugins: {
      legend: { labels: { color: '#94A3B8', boxWidth: 12, font: { size: 11 } } },
      tooltip: { backgroundColor: '#0F1420', titleColor: '#F9FAFB', bodyColor: '#E5E7EB', borderColor: '#334155', borderWidth: 1 }
    },
    scales: {
      x: { grid: { color: '#1F2A3A' }, ticks: { color: '#94A3B8', font: { size: 10 } } },
      y: { grid: { color: '#1F2A3A' }, ticks: { color: '#94A3B8', font: { size: 10 } } }
    }
  }, extra || {});
}

/* ============================================================ */
/* Renderers per tab                                             */
/* ============================================================ */
const renderers = {};

renderers.overview = () => {
  // SCU by Day
  const byDay = groupSum(SESSIONS, 'Date', 'SCU_Used')
    .map(([k, v]) => ({ x: k.slice(0, 10), y: Math.round(v * 1000) / 1000 }));
  const sortedDay = byDay.sort((a,b) => a.x.localeCompare(b.x));
  chartInstances['ov-scu-day'] = new Chart(document.getElementById('ov-scu-day'), {
    type: 'bar',
    data: { labels: sortedDay.map(d => d.x), datasets: [{ label: 'SCU', data: sortedDay.map(d => d.y), backgroundColor: '#50E6FF' }] },
    options: baseOpts({ plugins: { legend: { display: false } } })
  });

  // SCU by User (donut)
  const byUser = groupSum(SESSIONS, 'User', 'SCU_Used').slice(0, 10);
  chartInstances['ov-scu-user'] = new Chart(document.getElementById('ov-scu-user'), {
    type: 'doughnut',
    data: { labels: byUser.map(u => truncate(u[0], 24)), datasets: [{ data: byUser.map(u => Math.round(u[1] * 1000) / 1000), backgroundColor: byUser.map((_, i) => palette(i)) }] },
    options: baseOpts({ scales: {}, plugins: { legend: { position: 'right', labels: { font: { size: 10 }, boxWidth: 10, padding: 6 } } } })
  });

  // SCU by Plugin (bar chart)
  const byPl = groupSum(SESSIONS, 'Plugins', 'SCU_Used').slice(0, 25);
  chartInstances['ov-scu-plugin'] = new Chart(document.getElementById('ov-scu-plugin'), {
    type: 'bar',
    data: { labels: byPl.map(p => truncate(p[0], 30)), datasets: [{ label: 'SCU', data: byPl.map(p => Math.round(p[1] * 1000) / 1000), backgroundColor: '#0078D4' }] },
    options: baseOpts({ indexAxis: 'y', plugins: { legend: { display: false } } })
  });
};

/* SESSIONS - full-featured table with filters + running SCU total */
renderers.sessions = () => {
  const uniq = (arr, prop) => [...new Set(arr.map(r => r[prop]).filter(v => v != null))].sort();
  ['User', 'Category', 'Type', 'Experience'].forEach(prop => {
    const sel = document.getElementById('fSess' + prop);
    uniq(SESSIONS, prop).forEach(v => { const o = document.createElement('option'); o.value = v; o.textContent = v; sel.appendChild(o); });
    sel.addEventListener('change', renderSessTable);
  });
  document.getElementById('fSessSearch').addEventListener('input', renderSessTable);

  function renderSessTable() {
    const fU = document.getElementById('fSessUser').value;
    const fC = document.getElementById('fSessCategory').value;
    const fT = document.getElementById('fSessType').value;
    const fE = document.getElementById('fSessExperience').value;
    const fS = document.getElementById('fSessSearch').value.toLowerCase();
    const rows = SESSIONS.filter(r =>
      (!fU || r.User === fU) &&
      (!fC || r.Category === fC) &&
      (!fT || r.Type === fT) &&
      (!fE || r.Experience === fE) &&
      (!fS || Object.values(r).some(v => String(v || '').toLowerCase().includes(fS)))
    );
    let sum = 0;
    const html = rows.map(r => {
      sum += Number(r.SCU_Used) || 0;
      return '<tr>' +
        td(String(r.Date || '').slice(0, 19)) +
        td(r.User, 'name') +
        td(r.Category) +
        td(r.Type) +
        td(r.Experience) +
        td(r.Plugins, 'name') +
        td(r.Skills, 'name') +
        `<td class="num">${fmtNum(r.SCU_Used)}</td>` +
        tdTrunc(r.SessionId, 12) +
      '</tr>';
    }).join('');
    document.querySelector('#sessionsTable tbody').innerHTML = html;
    document.getElementById('filteredScu').textContent = fmtNum(Math.round(sum * 1000) / 1000);
  }
  renderSessTable();
};

/* TRENDS - line chart with rolling avg + heatmap + day-of-week */
renderers.trends = () => {
  // Daily line
  const daily = [...DAILY].sort((a,b) => String(a.Day).localeCompare(String(b.Day)));
  const labels = daily.map(d => String(d.Day).slice(0, 10));
  const scuData = daily.map(d => Number(d.SCU_Total) || 0);
  const r7Data  = daily.map(d => Number(d.Rolling_7d_Avg) || 0);
  const isAnom  = daily.map(d => !!d.Is_Anomaly);
  chartInstances['tr-daily'] = new Chart(document.getElementById('tr-daily'), {
    type: 'line',
    data: {
      labels,
      datasets: [
        { label: 'Daily SCU', data: scuData, borderColor: '#50E6FF', backgroundColor: 'rgba(80,230,255,0.12)', fill: true, tension: 0.25, pointRadius: (ctx) => isAnom[ctx.dataIndex] ? 6 : 2, pointBackgroundColor: (ctx) => isAnom[ctx.dataIndex] ? '#EF4444' : '#50E6FF' },
        { label: '7-day rolling avg', data: r7Data, borderColor: '#F59E0B', borderDash: [4,4], pointRadius: 0, fill: false, tension: 0.25 }
      ]
    },
    options: baseOpts()
  });

  // Heatmap (matrix chart) - Day of week x Hour of day
  const grid = {};
  for (const r of HEATMAP) {
    const dow = r.DayOfWeek, hr = r.HourOfDay;
    if (dow == null || hr == null) continue;
    grid[dow + ':' + hr] = Number(r['Hourly SCU']) || 0;
  }
  const DOWS = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
  const matrixData = [];
  for (let d = 0; d < 7; d++) {
    for (let h = 0; h < 24; h++) {
      matrixData.push({ x: h, y: d, v: grid[d + ':' + h] || 0 });
    }
  }
  const maxV = Math.max(...matrixData.map(d => d.v), 0.001);
  chartInstances['tr-heatmap'] = new Chart(document.getElementById('tr-heatmap'), {
    type: 'matrix',
    data: {
      datasets: [{
        label: 'SCU',
        data: matrixData,
        backgroundColor: (ctx) => { const v = ctx.raw.v / maxV; return `rgba(80, 230, 255, ${0.08 + 0.9 * v})`; },
        borderColor: '#1F2A3A',
        borderWidth: 1,
        width: (ctx) => (ctx.chart.chartArea || {}).width / 24 - 2,
        height: (ctx) => (ctx.chart.chartArea || {}).height / 7 - 2
      }]
    },
    options: baseOpts({
      plugins: { legend: { display: false }, tooltip: { callbacks: { title: (items) => `${DOWS[items[0].raw.y]} ${String(items[0].raw.x).padStart(2,'0')}:00`, label: (item) => 'SCU: ' + fmtNum(item.raw.v) } } },
      scales: {
        x: { type: 'linear', min: -0.5, max: 23.5, ticks: { stepSize: 3, color: '#94A3B8', callback: (v) => `${String(v).padStart(2,'0')}h` }, grid: { display: false } },
        y: { type: 'linear', min: -0.5, max: 6.5, offset: false, reverse: false, ticks: { stepSize: 1, color: '#94A3B8', callback: (v) => DOWS[v] || '' }, grid: { display: false } }
      }
    })
  });

  // Day of week bar
  const dowSum = new Array(7).fill(0);
  for (const r of HEATMAP) {
    const d = r.DayOfWeek; if (d == null) continue;
    dowSum[d] += Number(r['Hourly SCU']) || 0;
  }
  chartInstances['tr-dow'] = new Chart(document.getElementById('tr-dow'), {
    type: 'bar',
    data: { labels: DOWS, datasets: [{ label: 'SCU', data: dowSum.map(v => Math.round(v * 1000) / 1000), backgroundColor: '#50E6FF' }] },
    options: baseOpts({ plugins: { legend: { display: false } } })
  });
};

/* PLUGINS USED - treemap + scatter + tables */
renderers.plugins = () => {
  // Treemap
  const treeData = BY_PLUGIN.filter(p => (Number(p.SCU) || 0) > 0).sort((a,b) => (b.SCU || 0) - (a.SCU || 0));
  chartInstances['pl-treemap'] = new Chart(document.getElementById('pl-treemap'), {
    type: 'treemap',
    data: {
      datasets: [{
        tree: treeData,
        key: 'SCU',
        groups: ['Plugin'],
        borderColor: '#0E1116', borderWidth: 1,
        backgroundColor: (ctx) => { if (ctx.type !== 'data') return 'transparent'; return palette(ctx.dataIndex); },
        labels: {
          display: true, color: '#0E1116', font: { size: 10, weight: 'bold' },
          formatter: (ctx) => { const d = ctx.raw._data; return [truncate(d.Plugin || '', 22), fmtNum(d.SCU)]; }
        }
      }]
    },
    options: baseOpts({
      scales: { x: { display: false }, y: { display: false } },
      plugins: { legend: { display: false }, tooltip: { callbacks: { title: (items) => items[0].raw._data.Plugin, label: (item) => `SCU: ${fmtNum(item.raw._data.SCU)}  |  Sessions: ${fmtInt(item.raw._data.Sessions)}` } } }
    })
  });

  // Scatter (bubble)
  const bubble = BY_PLUGIN.filter(p => (Number(p.Sessions) || 0) > 0).map(p => ({
    x: Number(p.Sessions) || 0, y: Number(p.Avg_SCU) || 0, r: Math.max(4, Math.sqrt(Number(p.SCU) || 0) * 8), label: p.Plugin
  }));
  chartInstances['pl-scatter'] = new Chart(document.getElementById('pl-scatter'), {
    type: 'bubble',
    data: { datasets: [{ label: 'Plugin', data: bubble, backgroundColor: 'rgba(80,230,255,0.5)', borderColor: '#50E6FF' }] },
    options: baseOpts({
      plugins: { legend: { display: false }, tooltip: { callbacks: { label: (item) => `${item.raw.label}  |  Sessions: ${item.raw.x}  Avg SCU: ${fmtNum(item.raw.y)}` } } },
      scales: {
        x: { title: { display: true, text: 'Sessions', color: '#94A3B8' }, grid: { color: '#1F2A3A' }, ticks: { color: '#94A3B8' } },
        y: { title: { display: true, text: 'Avg SCU', color: '#94A3B8' }, grid: { color: '#1F2A3A' }, ticks: { color: '#94A3B8' } }
      }
    })
  });

  // Tables
  document.querySelector('#tblByPlugin tbody').innerHTML = BY_PLUGIN.map(p =>
    '<tr>' + td(p.Plugin, 'name') + `<td class="num">${fmtInt(p.Sessions)}</td><td class="num">${fmtNum(p.SCU)}</td><td class="num">${fmtNum(p.Avg_SCU)}</td><td class="num">${fmtNum(p.Max_SCU)}</td>` + '</tr>'
  ).join('');
  document.querySelector('#tblSkills tbody').innerHTML = SKILLS.slice(0, 500).map(s =>
    '<tr>' + td(s.Skill, 'name') + td(s.User, 'name') + td(s.Plugin, 'name') + td(String(s.Date || '').slice(0, 19)) + `<td class="num">${fmtNum(s.SCU_Session)}</td>` + '</tr>'
  ).join('');
};

/* USERS - filter + summary table + plugin chart per user */
renderers.users = () => {
  const users = [...new Set(SESSIONS.map(s => s.User).filter(u => u))].sort();
  const sel = document.getElementById('fUser');
  users.forEach(u => { const o = document.createElement('option'); o.value = u; o.textContent = u; sel.appendChild(o); });

  // Summary table (all users)
  document.querySelector('#tblByUser tbody').innerHTML = BY_USER.map(u =>
    '<tr>' + td(u.User, 'name') + td(u.Department) + `<td class="num">${fmtInt(u.Sessions)}</td><td class="num">${fmtNum(u.SCU)}</td><td class="num">${fmtNum(u.Avg_SCU)}</td><td class="num">${fmtNum(u.Max_SCU)}</td><td class="num">${fmtInt(u.Distinct_Plugins)}</td>` + '</tr>'
  ).join('');

  function updateUserView() {
    const u = sel.value;
    const rows = u ? SESSIONS.filter(s => s.User === u) : SESSIONS;
    const scu = rows.reduce((a, r) => a + (Number(r.SCU_Used) || 0), 0);
    document.getElementById('u-totalScu').textContent = fmtNum(Math.round(scu * 1000) / 1000);
    document.getElementById('u-sessions').textContent = fmtInt(rows.length);
    const inter = rows.reduce((a, r) => a + (Number(r.SkillCount) || 1), 0);
    document.getElementById('u-interactions').textContent = fmtInt(inter);
    document.getElementById('u-cost').textContent = fmtUsd(scu * 6);
    // rebuild plugins chart
    if (chartInstances['us-plugins']) chartInstances['us-plugins'].destroy();
    const pl = groupSum(rows, 'Plugins', 'SCU_Used').slice(0, 25);
    chartInstances['us-plugins'] = new Chart(document.getElementById('us-plugins'), {
      type: 'bar',
      data: { labels: pl.map(p => truncate(p[0], 30)), datasets: [{ label: 'SCU', data: pl.map(p => Math.round(p[1] * 1000) / 1000), backgroundColor: '#0078D4' }] },
      options: baseOpts({ indexAxis: 'y', plugins: { legend: { display: false } } })
    });
  }
  sel.addEventListener('change', updateUserView);
  updateUserView();
};

/* PLUGIN CATALOG - 3 donuts + searchable table */
renderers.catalog = () => {
  function donut(canvasId, prop) {
    const data = groupCount(PLUGIN_CATALOG, prop);
    return new Chart(document.getElementById(canvasId), {
      type: 'doughnut',
      data: { labels: data.map(d => d[0]), datasets: [{ data: data.map(d => d[1]), backgroundColor: data.map((_, i) => palette(i)), borderColor: '#0E1116', borderWidth: 1 }] },
      options: baseOpts({ scales: {}, plugins: { legend: { position: 'right', labels: { font: { size: 10 }, boxWidth: 10, padding: 4 } } } })
    });
  }
  chartInstances['ct-category']   = donut('ct-category',   'Category');
  chartInstances['ct-preview']    = donut('ct-preview',    'PreviewState');
  chartInstances['ct-visibility'] = donut('ct-visibility', 'UserVisibility');

  const search = document.getElementById('fCatSearch');
  function renderCat() {
    const q = search.value.toLowerCase();
    const rows = q ? PLUGIN_CATALOG.filter(p => Object.values(p).some(v => String(v || '').toLowerCase().includes(q))) : PLUGIN_CATALOG;
    document.querySelector('#tblCatalog tbody').innerHTML = rows.map(p =>
      '<tr>' + td(p.DisplayName, 'name') + td(p.Category) +
      `<td>${p.Enabled ? '<span class="badge up">Yes</span>' : '<span class="badge">No</span>'}</td>` +
      td(p.PreviewState) +
      `<td>${p.HasMcp ? '<span class="badge info">Yes</span>' : ''}</td>` +
      td(p.Compliance) +
      `<td class="num">${fmtInt(p.SkillCount)}</td>` +
      td(p.Description, 'wrap') +
      '</tr>'
    ).join('');
  }
  search.addEventListener('input', renderCat);
  renderCat();
};

/* PROMPTBOOKS - donut + two tables */
renderers.promptbooks = () => {
  const byVis = groupCount(PROMPTBOOKS, 'Visibility');
  chartInstances['pb-visibility'] = new Chart(document.getElementById('pb-visibility'), {
    type: 'doughnut',
    data: { labels: byVis.map(v => v[0]), datasets: [{ data: byVis.map(v => v[1]), backgroundColor: byVis.map((_, i) => palette(i)), borderColor: '#0E1116' }] },
    options: baseOpts({ scales: {}, plugins: { legend: { position: 'right' } } })
  });
  document.querySelector('#tblPromptbooks tbody').innerHTML = PROMPTBOOKS.map(p =>
    '<tr>' + td(p.Name, 'name') + td(p.Visibility) + `<td class="num">${fmtInt(p.PromptCount)}</td>` + td(p.Description, 'wrap') + '</tr>'
  ).join('');
  document.querySelector('#tblPrompts tbody').innerHTML = PROMPTBOOK_PROMPTS.map(p =>
    '<tr>' + td(p.PromptbookName, 'name') + `<td class="num">${fmtInt(p.PromptSequence)}</td>` + td(p.PromptType) + td(p.Content, 'wrap') + td(p.SkillName, 'name') + `<td class="num">${fmtInt(p.PluginCount)}</td>` + '</tr>'
  ).join('');
};

/* ANALYTICS - waterfall (bar chart with signed deltas) + actual cost line + rollup table */
renderers.analytics = () => {
  const daily = [...DAILY].sort((a,b) => String(a.Day).localeCompare(String(b.Day)));
  const labels = daily.map(d => String(d.Day).slice(0, 10));
  const deltas = daily.map(d => Number(d.Delta_vs_Prev) || 0);
  const cols   = deltas.map(v => v >= 0 ? '#22C55E' : '#EF4444');
  chartInstances['an-waterfall'] = new Chart(document.getElementById('an-waterfall'), {
    type: 'bar',
    data: { labels, datasets: [{ label: 'Delta vs prior day', data: deltas, backgroundColor: cols }] },
    options: baseOpts({ plugins: { legend: { display: false } } })
  });

  const cost = [...ACTUAL_COST].sort((a,b) => String(a.Day).localeCompare(String(b.Day)));
  const clabels = cost.map(c => String(c.Day).slice(0, 10));
  chartInstances['an-cost'] = new Chart(document.getElementById('an-cost'), {
    type: 'line',
    data: { labels: clabels, datasets: [{ label: 'Actual daily cost USD', data: cost.map(c => Number(c.Actual_Cost) || 0), borderColor: '#50E6FF', backgroundColor: 'rgba(80,230,255,0.15)', fill: true, tension: 0.25, pointRadius: 3 }] },
    options: baseOpts({ scales: { y: { grid: { color: '#1F2A3A' }, ticks: { color: '#94A3B8', callback: (v) => '$' + v } } } })
  });

  document.querySelector('#tblDaily tbody').innerHTML = daily.map(d =>
    `<tr><td>${String(d.Day).slice(0,10)}</td><td class="num">${fmtNum(d.SCU_Total)}</td><td class="num">${fmtUsd(d.Est_Cost_USD)}</td><td class="num">${fmtNum(d.Rolling_7d_Avg)}</td><td class="num">${fmtNum(d.Rolling_30d_Avg)}</td><td class="num">${(Number(d.Delta_vs_Prev) || 0) >= 0 ? '<span class="badge up">+' + fmtNum(d.Delta_vs_Prev) + '</span>' : '<span class="badge down">' + fmtNum(d.Delta_vs_Prev) + '</span>'}</td><td class="num">${fmtNum(d.Anomaly_Sigma)}</td><td>${d.Is_Anomaly ? '<span class="badge warn">Yes</span>' : ''}</td></tr>`
  ).join('');
};

/* Kick off Overview render since Overview auto-shows if user clicks its tab; Cover has no charts. */
</script>

</body>
</html>
'@

# Inject the data
$html = $html.Replace('__DATA_JS__', $dataJs)

# Write output
$outDir = Split-Path $OutputHtml -Parent
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
[System.IO.File]::WriteAllText($OutputHtml, $html, [System.Text.Encoding]::UTF8)

$size = [math]::Round((Get-Item $OutputHtml).Length / 1KB, 1)
Write-Host "`nHTML dashboard written: $OutputHtml ($size KB)" -ForegroundColor Green
Write-Host "  - Embeds $($sessions.Count) sessions, $($hourly.Count) hourly rows, $($pluginCatalog.Count) plugins, $($promptbookPrompts.Count) prompts" -ForegroundColor Gray
Write-Host "  - Charts render on-demand when you click each tab (fast initial load)" -ForegroundColor Gray

if ($Open) {
    Write-Host "  Opening in default browser..." -ForegroundColor Cyan
    Start-Process $OutputHtml
}
}
#endregion

# ============================================================
#region MAIN
# ============================================================
$xlsxOut = Join-Path $OutDir 'SCU-Report.xlsx'
$jsonOut = Join-Path $OutDir 'SCU-Report.json'
$pbitOut = Join-Path $OutDir 'SCU-Dashboard.pbit'
$htmlOut = Join-Path $OutDir 'SCU-Dashboard.html'

# --- 1/4  Pull data ---
if ($NoRefresh) {
    Write-Section "Skipping data refresh (-NoRefresh)"
    if (-not (Test-Path $xlsxOut)) {
        throw "-NoRefresh but no existing SCU-Report.xlsx at $xlsxOut. Remove -NoRefresh or run SCU-Setup.ps1 first."
    }
} else {
    Write-Section "1/4  Pulling latest SCU data (last $Days days)"
    Invoke-ScuPull -Days $Days -OutDir $OutDir -ConfigDir $ConfigDir
    if (-not (Test-Path $xlsxOut)) { throw "Data pull did not produce $xlsxOut" }
    Write-Ok "SCU-Report.xlsx + SCU-Report.json written"
}

# --- 2/4  Build PBIT template ---
if ($SkipPbit -or $HtmlOnly) {
    Write-Section "Skipping PBIT regeneration"
} else {
    Write-Section "2/4  Building Power BI template (SCU-Dashboard.pbit)"
    try {
        Invoke-ScuPbit -OutDir $OutDir -OutputPath $pbitOut
        if (Test-Path $pbitOut) { Write-Ok "$([math]::Round((Get-Item $pbitOut).Length / 1KB, 1)) KB  SCU-Dashboard.pbit" }
    } catch {
        Write-Warn2 "PBIT build failed: $($_.Exception.Message)"
    }
}

# --- 3/4  Build HTML dashboard ---
if ($SkipHtml) {
    Write-Section "Skipping HTML regeneration (-SkipHtml)"
} else {
    Write-Section "3/4  Building HTML dashboard (SCU-Dashboard.html)"
    try {
        Invoke-ScuHtml -InputXlsx $xlsxOut -InputJson $jsonOut -OutputHtml $htmlOut -OutDir $OutDir
        if (Test-Path $htmlOut) { Write-Ok "$([math]::Round((Get-Item $htmlOut).Length / 1KB, 1)) KB  SCU-Dashboard.html" }
    } catch {
        Write-Warn2 "HTML build failed: $($_.Exception.Message)"
    }
}

# --- 4/4  Open results ---
if ($NoOpen) {
    Write-Section "Skipping opens (-NoOpen). Outputs in: $OutDir"
    return
}

Write-Section "4/4  Opening dashboards"

try { Start-Process explorer.exe -ArgumentList "`"$OutDir`"" } catch { Write-Verbose "Explorer: $_" }

if ((-not $SkipHtml) -and (Test-Path $htmlOut)) {
    Start-Process $htmlOut
    Write-Ok "HTML dashboard opened in browser"
}

if ($HtmlOnly) {
    Write-Ok "Done. (HTML-only mode)"
    return
}

$pbiExe = @(
    "$env:ProgramFiles\Microsoft Power BI Desktop\bin\PBIDesktop.exe",
    "${env:ProgramFiles(x86)}\Microsoft Power BI Desktop\bin\PBIDesktop.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
$pbiStore = Get-AppxPackage -Name "*PowerBIDesktop*" -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not ($pbiExe -or $pbiStore)) {
    Write-Warn2 "Power BI Desktop not installed. Install: winget install Microsoft.PowerBI"
    Write-Warn2 "HTML dashboard is already open in your browser."
    return
}

$pbix = Get-ChildItem -Path $OutDir -Filter '*.pbix' -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
$fileToOpen = if ($pbix) { $pbix.FullName } elseif (Test-Path $pbitOut) { $pbitOut } else { $null }

if ($fileToOpen) {
    if ($pbiExe) { Start-Process $pbiExe -ArgumentList "`"$fileToOpen`"" }
    else         { Start-Process $fileToOpen }
    Write-Ok "Opening $((Get-Item $fileToOpen).Name) in Power BI Desktop..."
} else {
    Write-Warn2 "No .pbix or .pbit in $OutDir. Opening Power BI Desktop blank."
    if ($pbiExe) { Start-Process $pbiExe }
    else {
        $aumid = "$($pbiStore.PackageFamilyName)!Microsoft.MicrosoftPowerBIDesktop"
        Start-Process "shell:AppsFolder\$aumid"
    }
}

Start-Sleep -Seconds 6
try {
    Add-Type -Name W32 -Namespace SCU -MemberDefinition '
        [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
        [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    ' -ErrorAction SilentlyContinue
    $win = Get-Process -Name 'PBIDesktop*' -ErrorAction SilentlyContinue |
           Where-Object { $_.MainWindowHandle -ne 0 } |
           Sort-Object StartTime -Descending | Select-Object -First 1
    if ($win) {
        [SCU.W32]::ShowWindow($win.MainWindowHandle, 9) | Out-Null
        [SCU.W32]::SetForegroundWindow($win.MainWindowHandle) | Out-Null
        Write-Ok "Power BI window brought to foreground (PID $($win.Id))"
    }
} catch { Write-Verbose "Foreground: $_" }

Write-Host ""
Write-Host "Done. All outputs live in: $OutDir" -ForegroundColor Green
#endregion