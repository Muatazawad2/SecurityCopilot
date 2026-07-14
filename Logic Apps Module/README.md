# Logic Apps Module

Automated security workflows built with Azure Logic Apps that integrate with Microsoft Entra ID, Microsoft Graph API, and Microsoft Security Copilot. These Logic Apps require no OAuth connectors — authentication is handled entirely via System-Assigned Managed Identity.

**Developer**: Dr Muataz Awad

---

## Available Logic Apps

| Logic App | Trigger | Description |
|-----------|---------|-------------|
| [Daily Risky User Digest](#daily-risky-user-digest) | Daily schedule | Sends a daily HTML email digest of all at-risk users from Entra ID Protection |
| [Password Spray Auto-Alert](#password-spray-auto-alert) | Polling every 30 min | Detects `passwordSpray` risk events in Entra ID Protection and immediately emails SOC with affected accounts, source IPs, and response actions |
| [Token Theft Response Alert](#token-theft-response-alert) | Polling every 15 min | Detects `anomalousToken` and `tokenIssuerAnomaly` risk events and immediately emails SOC with affected accounts, detection type, and token revocation guidance |

---

## Daily Risky User Digest

### Overview

A Logic App that runs every day and emails a formatted HTML report of all risky users (`riskState: atRisk`, `riskLevel: high or medium`) from Microsoft Entra ID Protection. Uses **System-Assigned Managed Identity** — no stored credentials, no OAuth connectors.

**What it sends:**

![Email Result](Images/20.png)

---

### Architecture

![Architecture](Images/architecture.png)

---

### How It Works

![How It Works](Images/how-it-works.png)

---

### Prerequisites

- Azure subscription with Global Administrator or Security Administrator role
- Microsoft Entra ID P2 license (required for Identity Protection risky users)
- Exchange Online license on the sender mailbox
- Azure Logic Apps (Standard) resource

---

### Deployment

#### Option A — Deploy to Azure (one-click)

Click the button below to deploy the Logic App directly to your Azure subscription:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMuatazawad2%2FSecurityCopilot%2Fmain%2FLogic%2520Apps%2520Module%2FRisky%2520User%2520Management%2FDaily%2520Risky%2520User%2520Digest%2Fazuredeploy.json)

You will be prompted to enter:
- **Resource Group**
- **Sender Email** (the mailbox that sends the digest)
- **Recipient Email** (who receives the digest)

> After deployment, complete [Step 3](#step-3--grant-microsoft-graph-permissions) to grant Graph API permissions to the Managed Identity.

#### Option B — PowerShell Script

```powershell
cd "Logic Apps Module/Risky User Management/Daily Risky User Digest"
.\deploy.ps1 -SenderEmail "admin@yourtenant.onmicrosoft.com" `
             -RecipientEmail "soc-team@yourtenant.onmicrosoft.com" `
             -SubscriptionId "your-subscription-id" `
             -ResourceGroup "your-resource-group"
```

#### Option C — Manual Portal Setup (recommended for learning)

Follow the step-by-step guide below.

---

### Step-by-Step Manual Setup Guide

#### Step 1 — Create the Logic App

1. Go to [portal.azure.com](https://portal.azure.com) → search **Logic Apps** → click **+ Create**
2. Select your **Resource Group**, enter name `daily-risky-user-digest`, choose **Standard** plan, **East US** (or your preferred region)
3. Click **Review + Create** → **Create**

![Logic App Creation](Images/1.png)

---

#### Step 2 — Enable System-Assigned Managed Identity

1. Open the Logic App → left menu → **Settings** → **Identity**
2. Under **System assigned**, toggle **Status** to **On**
3. Click **Save** → note the **Object (principal) ID** — you will need it for the permission grant step

![Enable Managed Identity](Images/4.png)

---

#### Step 3 — Grant Microsoft Graph Permissions

You must grant 3 Graph API permissions to the Managed Identity. Choose one method:

---

##### Option A — Graph Explorer (browser, no setup required)

1. Go to [https://developer.microsoft.com/en-us/graph/graph-explorer](https://developer.microsoft.com/en-us/graph/graph-explorer)
2. Sign in with your **Global Administrator** account
3. First, get the Microsoft Graph service principal ID — run this GET request:
   ```
   GET https://graph.microsoft.com/v1.0/servicePrincipals?$filter=appId eq '00000003-0000-0000-c000-000000000000'&$select=id,appRoles
   ```
   Note the `id` value — this is your **graphSpId**

4. Then get the app role IDs for each permission by looking through the `appRoles` array in the response for entries where `value` equals `IdentityRiskyUser.Read.All`, `User.Read.All`, and `Mail.Send`. Note each `id`.

5. For each of the 3 permissions, run this POST request (replacing the placeholder values):
   ```
   POST https://graph.microsoft.com/v1.0/servicePrincipals/{graphSpId}/appRoleAssignedTo
   ```
   **Request body:**
   ```json
   {
     "principalId": "YOUR-MANAGED-IDENTITY-OBJECT-ID",
     "resourceId": "GRAPH-SP-ID",
     "appRoleId": "APP-ROLE-ID-FOR-PERMISSION"
   }
   ```
   Repeat for all 3 permissions.

---

##### Option B — Azure Cloud Shell (browser-based PowerShell, no local install needed)

1. Go to [https://shell.azure.com](https://shell.azure.com) and select **PowerShell**
2. Paste and run:

```powershell
$token = (az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv)
$headers = @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }

$graphSp   = Invoke-RestMethod -Method GET -Uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '00000003-0000-0000-c000-000000000000'" -Headers $headers
$graphSpId = $graphSp.value[0].id
$principalId = "YOUR-MANAGED-IDENTITY-OBJECT-ID"  # from Step 2

$permissionNames = @("IdentityRiskyUser.Read.All", "User.Read.All", "Mail.Send")
$appRoles = $graphSp.value[0].appRoles
$uri = "https://graph.microsoft.com/v1.0/servicePrincipals/$graphSpId/appRoleAssignedTo"

foreach ($name in $permissionNames) {
    $appRoleId = ($appRoles | Where-Object { $_.value -eq $name }).id
    $body = @{ principalId = $principalId; resourceId = $graphSpId; appRoleId = $appRoleId } | ConvertTo-Json
    try {
        $null = Invoke-RestMethod -Method POST -Uri $uri -Headers $headers -Body $body
        Write-Host "GRANTED: $name" -ForegroundColor Green
    } catch {
        Write-Host "ALREADY EXISTS or ERROR: $name" -ForegroundColor Yellow
    }
}
```

---

##### Option C — Local PowerShell

Same script as Option B, but run from your local machine after running `az login`.

---

**Verify in the portal:** Entra ID → Enterprise Applications → search `daily-risky-user-digest` → Security → Permissions — you should see all 3 permissions listed under **Admin consent**.

![Graph Permissions](Images/21.png)

---

#### Step 4 — Open the Logic App Designer

1. In the Logic App → left menu → **Logic app designer** (under Favorites)
2. Click **+ Add trigger**

![Logic App Designer](Images/5.png)

---

#### Step 5 — Add Recurrence Trigger

1. Select **"On a schedule"** → **Recurrence**
2. Set: **Interval** = `1`, **Frequency** = `Day`
3. Set your **Time zone**, optionally set a **Start time** (e.g., `2026-01-01T08:00:00Z` for 8 AM daily)

![Recurrence Trigger](Images/7.png)

---

#### Step 6 — Add Initialize Variables Action

1. Click **+** below Recurrence → **Add an action**
2. Search `Initialize variable` → select **Initialize variables** (Built-in)

![Search Initialize Variable](Images/9.png)

3. Configure:
   - **Name**: `UserReport`
   - **Type**: `Array`
   - **Value**: leave empty

![Initialize Variables Config](Images/10.png)

---

#### Step 7 — Add HTTP Action (Get Risky Users)

1. Click **+** below Initialize variables → **Add an action**
2. Search `HTTP` → select **HTTP** (Built-in)

![Search HTTP](Images/11.png)

3. Configure:
   - **Method**: `GET`
   - **URI**: `https://graph.microsoft.com/v1.0/identityProtection/riskyUsers`
   - **Queries** section — add these 4 rows:

| Key | Value |
|-----|-------|
| `$filter` | `riskState eq 'atRisk' and (riskLevel eq 'high' or riskLevel eq 'medium')` |
| `$select` | `id,userDisplayName,userPrincipalName,riskLevel,riskDetail,riskLastUpdatedDateTime` |
| `$orderby` | `riskLevel desc` |
| `$top` | `50` |

4. Scroll down → **Advanced parameters** → add **Authentication**:
   - **Authentication type**: `Managed identity`
   - **Managed identity**: `System-assigned managed identity`
   - **Audience**: `https://graph.microsoft.com`

---

#### Step 8 — Add Parse JSON Action

1. Click **+** → **Add an action** → search `Parse JSON` → select **Parse JSON** (Built-in)

![Search Parse JSON](Images/12.png)

2. Configure:
   - **Content**: click the expression field → select `Body` from the HTTP step output
   - **Schema**: click **"Use sample payload to generate schema"**, paste the sample below, click **Done**

```json
{
  "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#identityProtection/riskyUsers",
  "value": [
    {
      "id": "00000000-0000-0000-0000-000000000000",
      "userDisplayName": "Test User",
      "userPrincipalName": "user@domain.com",
      "riskLevel": "high",
      "riskDetail": "none",
      "riskLastUpdatedDateTime": "2026-01-01T08:00:00Z"
    }
  ]
}
```

![Parse JSON with Schema](Images/14.png)

---

#### Step 9 — Add For Each Loop

1. Click **+** → **Add an action** → search `For each` → select **For each** (Built-in)
2. In **"Select an output from previous steps"**, enter the expression:

```
body('Parse_JSON')?['value']
```

![For Each with Body Value](Images/16.png)

---

#### Step 10 — Add Append to Array Variable (inside For Each)

1. Inside the For Each loop, click **+** → **Add an action** → search `Append to array variable`
2. Configure:
   - **Name**: `UserReport`
   - **Value**: paste this expression (switch to expression mode using the `fx` button):

```
concat('<tr><td style="padding:8px;border-bottom:1px solid #eee">',
items('For_each')?['userDisplayName'],
'<br/><small style="color:#666">',
items('For_each')?['userPrincipalName'],
'</small></td><td style="padding:8px;border-bottom:1px solid #eee;color:',
if(equals(items('For_each')?['riskLevel'], 'high'), '#C41E3A', '#E67E22'),
'"><strong>',
toUpper(items('For_each')?['riskLevel']),
'</strong></td><td style="padding:8px;border-bottom:1px solid #eee">',
items('For_each')?['riskDetail'],
'</td><td style="padding:8px;border-bottom:1px solid #eee">',
items('For_each')?['riskLastUpdatedDateTime'],
'</td></tr>')
```

---

#### Step 11 — Add Send Email Report Action (HTTP POST to Graph sendMail)

1. Outside the For Each loop, click **+** → **Add an action** → search `HTTP` → select **HTTP** (Built-in)
2. Rename it to **"Send Email Report"** (click ⋯ → Rename)
3. Configure:
   - **Method**: `POST`
   - **URI**: `https://graph.microsoft.com/v1.0/users/SENDER@yourtenant.onmicrosoft.com/sendMail`
   - **Headers**: `Content-Type` = `application/json`
   - **Body**: paste the JSON below (replacing expressions as needed)

```json
{
  "message": {
    "subject": "[SECURITY] Daily Risk Report — <length(variables('UserReport'))> risky user(s) — <formatDateTime(utcNow(), 'yyyy-MM-dd')>",
    "importance": "High",
    "body": {
      "contentType": "HTML",
      "content": "<html><body><h2>Daily Security Risk Report</h2><p><formatDateTime(utcNow(), 'dddd, MMMM d yyyy')></p><table border='1' cellpadding='8' style='border-collapse:collapse;width:100%'><thead><tr style='background:#C41E3A;color:white'><th>User</th><th>Risk Level</th><th>Risk Reason</th><th>Last Updated</th></tr></thead><tbody><join(variables('UserReport'), '')></tbody></table></body></html>"
    },
    "toRecipients": [
      {
        "emailAddress": {
          "address": "RECIPIENT@yourtenant.onmicrosoft.com"
        }
      }
    ]
  }
}
```

> **Note**: In the Logic Apps designer, use dynamic content tokens for `length(...)`, `formatDateTime(...)`, and `join(...)` rather than typing them as plain text.

4. Scroll down → **Advanced parameters** → add **Authentication**:
   - **Authentication type**: `Managed identity`
   - **Managed identity**: `System-assigned managed identity`
   - **Audience**: `https://graph.microsoft.com`

![Send Email Report Authentication](Images/18.png)

---

#### Step 12 — Publish and Test

1. Click **Publish** at the top right
2. Click **Run draft** to trigger an immediate test run
3. Click **Run history** tab to monitor the execution

![Complete Published Workflow](Images/19.png)

**Expected email result:**

![Email Digest](Images/20.png)

---

### Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `Whitespaces must be encoded for URIs` | Space in the URI field | Move OData query params to the **Queries** section instead of the URI |
| `ValidationFailed` on Parse JSON | Schema doesn't match actual response | Click "Use sample payload to generate schema" with actual Graph API response |
| `Forbidden` (403) on sendMail | Token not yet propagated after permission grant | Wait 5 minutes and re-run; permissions need time to propagate |
| Publish button greyed out | Red `!` on an action indicates a validation error | Fix all actions with error indicators first |

---

### Files

| File | Description |
|------|-------------|
| [azuredeploy.json](Risky%20User%20Management/Daily%20Risky%20User%20Digest/azuredeploy.json) | ARM template for automated deployment |
| [deploy.ps1](Risky%20User%20Management/Daily%20Risky%20User%20Digest/deploy.ps1) | PowerShell deployment script |

---

### Security Notes

- **No stored credentials** — Managed Identity eliminates the need for API keys or OAuth connection secrets
- **Least privilege** — Only `IdentityRiskyUser.Read.All`, `User.Read.All`, and `Mail.Send` are granted
- **Admin consent** — All permissions require explicit admin consent, visible in Entra ID Enterprise Applications

---

## Password Spray Auto-Alert

### Overview

A Logic App that polls Entra ID Protection every 30 minutes for `passwordSpray` risk detections and immediately sends a critical HTML alert email when spray activity is detected. Includes affected accounts, source IPs, geographic locations, risk levels, Quick Actions, a 3-phase analyst response guide aligned to the Microsoft Password Spray playbook, and an embedded Security Copilot investigation prompt.

**What it detects:** `riskEventType: passwordSpray` from the Microsoft Graph `identityProtection/riskDetections` API

**What it sends:** An immediate alert email with a detection table, Quick Actions box, and full phased analyst response guide. **No email is sent if no detections are found** — this is an event-driven alert, not a digest.

**Developer**: Dr Muataz Awad

---

### How It Works

```
Every 30 minutes
    │
    ▼
Compute time window start  →  utcNow() - 30 min  →  "2026-07-13T09:00:00Z"
    │
    ▼
GET /identityProtection/riskDetections
    $filter: riskEventType eq 'passwordSpray'
             and createdDateTime ge {timeWindowStart}
    │
    ├─ No detections  →  Exit silently (no email)
    │
    └─ Detections found
           │
           ▼
       For each detection
           └─> Format HTML table row (Account, Source/Location, Risk, Time, Actions)
           │
           ▼
       Compose full HTML alert email
       (Quick Actions + 3-phase analyst guide + Security Copilot prompt)
           │
           ▼
       POST /users/{senderEmail}/sendMail
```

---

### Prerequisites

- Azure subscription with Global Administrator or Security Administrator role
- Microsoft Entra ID P2 license (required for Identity Protection risk detections)
- Exchange Online license on the sender mailbox

---

### Deployment

#### Option A — Deploy to Azure (one-click)

Click the button below to deploy directly to your Azure subscription:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMuatazawad2%2FSecurityCopilot%2Fmain%2FLogic%2520Apps%2520Module%2FPassword%2520Spray%2520Detection%2FPassword%2520Spray%2520Auto-Alert%2Fazuredeploy.json)

You will be prompted to enter:
- **Resource Group** — existing resource group in your subscription
- **Sender Email** — mailbox the alert comes FROM (must exist in your tenant)
- **Recipient Email** — mailbox or distribution list to send TO
- **Polling Interval Minutes** — how often to check (default: `30`)

After deployment, grant the Managed Identity the required Graph permissions (see Step 3 in the manual setup guide below).

#### Option B — PowerShell

```powershell
.\deploy.ps1 -SenderEmail "security-alerts@company.com" `
             -RecipientEmail "soc-team@company.com" `
             -ResourceGroup "rg-security"
```

The script deploys the ARM template and automatically grants all required Graph permissions.

---

### Required Graph Permissions

| Permission | App Role ID | Purpose |
|------------|-------------|---------|
| `IdentityRiskEvent.Read.All` | `9e4862a5-b68f-479e-848a-4e07e25c9916` | Read password spray risk detections |
| `AuditLog.Read.All` | `b0afded3-3588-46d8-8b3d-9842eff778da` | Read sign-in logs for investigation context |
| `Mail.Send` | `b633e1c5-b582-4048-a93e-9f11b44c7e96` | Send alert emails via Microsoft Graph |

---

### Step-by-Step Manual Setup Guide

#### Step 1 — Create the Logic App

1. Go to [portal.azure.com](https://portal.azure.com) → search **Logic Apps** → click **+ Create**
2. Select your **Resource Group**, enter name `password-spray-auto-alert`, choose **Consumption** plan, select your region
3. Click **Review + Create** → **Create**

---

#### Step 2 — Enable System-Assigned Managed Identity

1. Open the Logic App → left menu → **Settings** → **Identity**
2. Under **System assigned**, toggle **Status** to **On**
3. Click **Save** → note the **Object (principal) ID** — you will need it for Step 3

---

#### Step 3 — Grant Microsoft Graph Permissions

##### Option A — Azure Cloud Shell (recommended)

1. Go to [shell.azure.com](https://shell.azure.com) → select **PowerShell**
2. Paste and run the script below, replacing the principal ID with your value from Step 2:

```powershell
$token = (az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv)
$headers = @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }

$graphSp   = Invoke-RestMethod -Method GET -Uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '00000003-0000-0000-c000-000000000000'" -Headers $headers
$graphSpId = $graphSp.value[0].id
$principalId = "YOUR-MANAGED-IDENTITY-OBJECT-ID"   # from Step 2

$permissions = @(
    @{ Name = "IdentityRiskEvent.Read.All"; Id = "9e4862a5-b68f-479e-848a-4e07e25c9916" },
    @{ Name = "AuditLog.Read.All";          Id = "b0afded3-3588-46d8-8b3d-9842eff778da" },
    @{ Name = "Mail.Send";                  Id = "b633e1c5-b582-4048-a93e-9f11b44c7e96" }
)

$uri = "https://graph.microsoft.com/v1.0/servicePrincipals/$graphSpId/appRoleAssignedTo"
foreach ($perm in $permissions) {
    $body = @{ principalId = $principalId; resourceId = $graphSpId; appRoleId = $perm.Id } | ConvertTo-Json
    try {
        $null = Invoke-RestMethod -Method POST -Uri $uri -Headers $headers -Body $body
        Write-Host "GRANTED: $($perm.Name)" -ForegroundColor Green
    } catch { Write-Host "ALREADY EXISTS or ERROR: $($perm.Name)" -ForegroundColor Yellow }
}
```

##### Option B — Graph Explorer

1. Go to [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer) → sign in as Global Administrator
2. Run a GET request to find the Graph service principal ID:
   ```
   GET https://graph.microsoft.com/v1.0/servicePrincipals?$filter=appId eq '00000003-0000-0000-c000-000000000000'&$select=id
   ```
3. For each permission in the table above, run:
   ```
   POST https://graph.microsoft.com/v1.0/servicePrincipals/{graphSpId}/appRoleAssignedTo
   ```
   Body:
   ```json
   {
     "principalId": "YOUR-MANAGED-IDENTITY-OBJECT-ID",
     "resourceId": "{graphSpId}",
     "appRoleId": "{App Role ID from table above}"
   }
   ```

**Verify:** Entra ID → Enterprise Applications → search `password-spray-auto-alert` → Security → Permissions — all 3 permissions should appear under Admin consent.

---

#### Step 4 — Open the Logic App Designer

1. Open the Logic App → left menu → **Logic app designer**
2. Click **+ Add trigger**

---

#### Step 5 — Add Recurrence Trigger

1. Select **Schedule** → **Recurrence**
2. Configure:
   - **Interval**: `30`
   - **Frequency**: `Minute`
3. This polls every 30 minutes. Adjust to `15` for higher frequency if needed.

---

#### Step 6 — Add Compose Action (Compute Time Window)

1. Click **+** → **Add an action** → search `Compose` → select **Compose** (Built-in)
2. Rename it to `Compute_TimeWindow_Start`
3. In the **Inputs** field, switch to expression mode (`fx`) and enter:
   ```
   formatDateTime(addMinutes(utcNow(), -30), 'yyyy-MM-ddTHH:mm:ssZ')
   ```
   > This produces a timestamp 30 minutes in the past (e.g. `2026-07-13T09:00:00Z`) used to filter only new detections each run.

---

#### Step 7 — Add HTTP Action (Get Password Spray Detections)

1. Click **+** → **Add an action** → search `HTTP` → select **HTTP** (Built-in)
2. Rename it to `Get_PasswordSpray_Detections`
3. Configure:
   - **Method**: `GET`
   - **URI**: `https://graph.microsoft.com/v1.0/identityProtection/riskDetections`
   - **Queries** — add these 4 rows:

| Key | Value |
|-----|-------|
| `$filter` | `riskEventType eq 'passwordSpray' and createdDateTime ge @{outputs('Compute_TimeWindow_Start')}` |
| `$select` | `id,userId,userDisplayName,userPrincipalName,riskLevel,riskState,ipAddress,detectedDateTime,location` |
| `$orderby` | `detectedDateTime desc` |
| `$top` | `50` |

4. Scroll down → **Advanced parameters** → **Authentication**:
   - **Authentication type**: `Managed identity`
   - **Audience**: `https://graph.microsoft.com`

---

#### Step 8 — Add Parse JSON Action

1. Click **+** → **Add an action** → search `Parse JSON` → select **Parse JSON** (Built-in)
2. Configure:
   - **Content**: select `Body` from the `Get_PasswordSpray_Detections` HTTP step output
   - **Schema**: click **Use sample payload to generate schema**, paste the sample below, click **Done**

```json
{
  "value": [
    {
      "id": "00000000-0000-0000-0000-000000000000",
      "userId": "00000000-0000-0000-0000-000000000001",
      "userDisplayName": "John Smith",
      "userPrincipalName": "john.smith@contoso.com",
      "riskLevel": "high",
      "riskState": "atRisk",
      "riskEventType": "passwordSpray",
      "ipAddress": "185.220.101.45",
      "detectedDateTime": "2026-07-13T09:15:00Z",
      "location": {
        "city": "Moscow",
        "state": "Moscow",
        "countryOrRegion": "RU"
      }
    }
  ]
}
```

---

#### Step 9 — Add Condition (Check If Detections Exist)

1. Click **+** → **Add an action** → search `Condition` → select **Condition** (Built-in)
2. Configure the expression:
   - Left value: `length(body('Parse_JSON')?['value'])`
   - Operator: `is greater than`
   - Right value: `0`

All remaining steps go inside the **True** branch.

---

#### Step 10 — Initialize Variable (Spray Report Array)

1. Inside the **True** branch → **Add an action** → search `Initialize variable`
2. Configure:
   - **Name**: `SprayReport`
   - **Type**: `Array`
   - **Value**: leave empty

---

#### Step 11 — Add For Each Loop

1. Click **+** → **Add an action** → search `For each` → select **For each** (Built-in)
2. In **Select an output from previous steps**, enter the expression:
   ```
   body('Parse_JSON')?['value']
   ```

---

#### Step 12 — Inside For Each: Format Detection Row

1. Inside the For Each → **Add an action** → search `Compose`
2. Rename to `Format_Detection_Row`
3. In **Inputs**, enter this expression (switch to expression mode with `fx`):
   ```
   concat(
     '<tr style=''border-bottom:1px solid #f0f0f0''>',
     '<td style=''padding:8px 10px''>',
       '<div style=''font-weight:500;font-size:13px''>',items('For_each')?['userDisplayName'],'</div>',
       '<div style=''font-size:12px;color:#777;margin-top:2px''>',items('For_each')?['userPrincipalName'],'</div>',
     '</td>',
     '<td style=''padding:8px 10px''>',
       '<div style=''font-family:monospace;font-size:12px''>',coalesce(items('For_each')?['ipAddress'],'Unknown'),'</div>',
       '<div style=''font-size:12px;color:#777;margin-top:2px''>',
         coalesce(items('For_each')?['location']?['city'],''),' ',
         coalesce(items('For_each')?['location']?['countryOrRegion'],'-'),
       '</div>',
     '</td>',
     '<td style=''padding:8px 10px;font-weight:bold''>',toUpper(coalesce(items('For_each')?['riskLevel'],'NONE')),'</td>',
     '<td style=''padding:8px 10px;font-size:12px;color:#888''>',
       formatDateTime(items('For_each')?['detectedDateTime'],'yyyy-MM-dd HH:mm'),' UTC',
     '</td>',
     '</tr>'
   )
   ```

---

#### Step 13 — Inside For Each: Append Row to Report Array

1. Inside the For Each → **Add an action** → search `Append to array variable`
2. Configure:
   - **Name**: `SprayReport`
   - **Value**: `@{outputs('Format_Detection_Row')}`

---

#### Step 14 — Compose Email Body

1. Outside the For Each loop → **Add an action** → search `Compose` → rename to `Compose_Email_Body`
2. This action assembles the full HTML email. Use the ARM template as the reference for the complete HTML, or simply use the Logic App created by Option A deployment and inspect the designer.

---

#### Step 15 — Send Alert Email

1. **Add an action** → search `HTTP` → rename to `Send_Alert_Email`
2. Configure:
   - **Method**: `POST`
   - **URI**: `https://graph.microsoft.com/v1.0/users/SENDER@yourtenant.com/sendMail`
   - **Headers**: `Content-Type` = `application/json`
   - **Body**:
     ```json
     {
       "message": {
         "subject": "[CRITICAL] Password Spray Detected",
         "importance": "High",
         "body": { "contentType": "HTML", "content": "@{outputs('Compose_Email_Body')}" },
         "toRecipients": [{ "emailAddress": { "address": "RECIPIENT@yourtenant.com" } }]
       },
       "saveToSentItems": false
     }
     ```
   - **Authentication**: Managed identity / `https://graph.microsoft.com`

---

#### Step 16 — Save and Test

1. Click **Save** at the top
2. Click **Run Trigger** → **Run** to trigger an immediate test run
3. Open **Run history** to monitor the execution
4. If no `passwordSpray` detections exist in your tenant yet, the run completes silently (no email). This is correct behaviour — the Logic App only emails when a real detection fires.
5. To generate a test detection: Entra ID → Identity Protection → Simulate risk events

---

### Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `Forbidden (403)` on riskDetections | `IdentityRiskEvent.Read.All` permission not yet propagated | Wait 5 minutes after granting and re-run |
| `Forbidden (403)` on sendMail | `Mail.Send` permission not granted or sender mailbox does not exist | Verify sender UPN exists as a real mailbox in your tenant |
| No email received but run succeeds | No `passwordSpray` detections in the polling window | Correct behaviour — Logic App is silent when no detections found |
| `InvalidTemplate` on Parse JSON | Schema mismatch | Click "Use sample payload" and regenerate schema from a live Graph API response |
| `BadRequest` on the HTTP GET | OData filter syntax error | Ensure the `$filter` query value uses single quotes around `passwordSpray` and the time format is ISO 8601 |

---

### Security Notes

- **No stored credentials** — Managed Identity eliminates API keys and OAuth connection secrets
- **Least privilege** — Only the three permissions required are granted; no `User.ReadWrite` or admin-level access
- **No data stored** — The Logic App reads detections, composes an email, sends it, and discards everything. Nothing is written to storage
- **Admin consent required** — All three Graph permissions require explicit Global Administrator consent

---

### Files

| File | Description |
|------|-------------|
| [azuredeploy.json](Password%20Spray%20Detection/Password%20Spray%20Auto-Alert/azuredeploy.json) | ARM template — one-click deployment |
| [deploy.ps1](Password%20Spray%20Detection/Password%20Spray%20Auto-Alert/deploy.ps1) | PowerShell deployment + auto permission grant |
| [email-preview.html](Password%20Spray%20Detection/Password%20Spray%20Auto-Alert/email-preview.html) | Browser-viewable preview of the alert email |

---

## Token Theft Response Alert

### Overview

A Logic App that polls Entra ID Protection every 15 minutes for token theft risk detections (`anomalousToken` and `tokenIssuerAnomaly`) and immediately sends a critical HTML alert email. Includes detection type, affected accounts, source IPs, risk levels, Quick Actions, a 3-phase analyst response guide (including token type determination and AiTM phishing investigation), and an embedded Security Copilot investigation prompt.

**What it detects:**
- `riskEventType: anomalousToken` — token replayed from a device/IP inconsistent with issuance — indicates **pass-the-cookie** attack
- `riskEventType: tokenIssuerAnomaly` — token issuer metadata is anomalous — primary signal of **AiTM phishing proxy** (Evilginx, Modlishka)

**What it sends:** An immediate alert email with a detection table, Quick Actions box, and phased analyst guide. **No email is sent if no detections are found.**

**Developer**: Dr Muataz Awad

---

### How It Works

```
Every 15 minutes
    │
    ▼
Compute time window start  →  utcNow() - 15 min
    │
    ▼
GET /identityProtection/riskDetections
    $filter: (riskEventType eq 'anomalousToken'
              or riskEventType eq 'tokenIssuerAnomaly')
             and createdDateTime ge {timeWindowStart}
    │
    ├─ No detections  →  Exit silently (no email)
    │
    └─ Detections found
           │
           ▼
       For each detection
           ├─> Format detection type label (anomalousToken → "Anomalous Token")
           └─> Format HTML table row (Account, Detection, Source/Location, Risk, Time, Actions)
           │
           ▼
       Compose full HTML alert email
       (Quick Actions + token type guide + 3-phase analyst response guide)
           │
           ▼
       POST /users/{senderEmail}/sendMail
```

---

### Prerequisites

- Azure subscription with Global Administrator or Security Administrator role
- Microsoft Entra ID P2 license (required for Identity Protection risk detections)
- Exchange Online license on the sender mailbox

---

### Deployment

#### Option A — Deploy to Azure (one-click)

Click the button below to deploy directly to your Azure subscription:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMuatazawad2%2FSecurityCopilot%2Fmain%2FLogic%2520Apps%2520Module%2FToken%2520Theft%2520Detection%2FToken%2520Theft%2520Response%2520Alert%2Fazuredeploy.json)

You will be prompted to enter:
- **Resource Group** — existing resource group in your subscription
- **Sender Email** — mailbox the alert comes FROM (must exist in your tenant)
- **Recipient Email** — mailbox or distribution list to send TO
- **Polling Interval Minutes** — how often to check (default: `15`)

After deployment, grant the Managed Identity the required Graph permissions (see Step 3 in the manual setup guide below).

#### Option B — PowerShell

```powershell
.\deploy.ps1 -SenderEmail "security-alerts@company.com" `
             -RecipientEmail "soc-team@company.com" `
             -ResourceGroup "rg-security"
```

The script deploys the ARM template and automatically grants all required Graph permissions.

---

### Required Graph Permissions

| Permission | App Role ID | Purpose |
|------------|-------------|---------|
| `IdentityRiskEvent.Read.All` | `9e4862a5-b68f-479e-848a-4e07e25c9916` | Read anomalous token and token issuer anomaly detections |
| `AuditLog.Read.All` | `b0afded3-3588-46d8-8b3d-9842eff778da` | Read sign-in logs for session context |
| `Mail.Send` | `b633e1c5-b582-4048-a93e-9f11b44c7e96` | Send alert emails via Microsoft Graph |

---

### Step-by-Step Manual Setup Guide

#### Step 1 — Create the Logic App

1. Go to [portal.azure.com](https://portal.azure.com) → search **Logic Apps** → click **+ Create**
2. Select your **Resource Group**, enter name `token-theft-response-alert`, choose **Consumption** plan, select your region
3. Click **Review + Create** → **Create**

---

#### Step 2 — Enable System-Assigned Managed Identity

1. Open the Logic App → left menu → **Settings** → **Identity**
2. Under **System assigned**, toggle **Status** to **On**
3. Click **Save** → note the **Object (principal) ID** — you will need it for Step 3

---

#### Step 3 — Grant Microsoft Graph Permissions

##### Option A — Azure Cloud Shell (recommended)

1. Go to [shell.azure.com](https://shell.azure.com) → select **PowerShell**
2. Paste and run the script below, replacing the principal ID with your value from Step 2:

```powershell
$token = (az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv)
$headers = @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }

$graphSp   = Invoke-RestMethod -Method GET -Uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '00000003-0000-0000-c000-000000000000'" -Headers $headers
$graphSpId = $graphSp.value[0].id
$principalId = "YOUR-MANAGED-IDENTITY-OBJECT-ID"   # from Step 2

$permissions = @(
    @{ Name = "IdentityRiskEvent.Read.All"; Id = "9e4862a5-b68f-479e-848a-4e07e25c9916" },
    @{ Name = "AuditLog.Read.All";          Id = "b0afded3-3588-46d8-8b3d-9842eff778da" },
    @{ Name = "Mail.Send";                  Id = "b633e1c5-b582-4048-a93e-9f11b44c7e96" }
)

$uri = "https://graph.microsoft.com/v1.0/servicePrincipals/$graphSpId/appRoleAssignedTo"
foreach ($perm in $permissions) {
    $body = @{ principalId = $principalId; resourceId = $graphSpId; appRoleId = $perm.Id } | ConvertTo-Json
    try {
        $null = Invoke-RestMethod -Method POST -Uri $uri -Headers $headers -Body $body
        Write-Host "GRANTED: $($perm.Name)" -ForegroundColor Green
    } catch { Write-Host "ALREADY EXISTS or ERROR: $($perm.Name)" -ForegroundColor Yellow }
}
```

##### Option B — Graph Explorer

1. Go to [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer) → sign in as Global Administrator
2. Run a GET request to find the Graph service principal ID:
   ```
   GET https://graph.microsoft.com/v1.0/servicePrincipals?$filter=appId eq '00000003-0000-0000-c000-000000000000'&$select=id
   ```
3. For each permission in the table above, run:
   ```
   POST https://graph.microsoft.com/v1.0/servicePrincipals/{graphSpId}/appRoleAssignedTo
   ```
   Body:
   ```json
   {
     "principalId": "YOUR-MANAGED-IDENTITY-OBJECT-ID",
     "resourceId": "{graphSpId}",
     "appRoleId": "{App Role ID from table above}"
   }
   ```

**Verify:** Entra ID → Enterprise Applications → search `token-theft-response-alert` → Security → Permissions — all 3 permissions should appear under Admin consent.

---

#### Step 4 — Open the Logic App Designer

1. Open the Logic App → left menu → **Logic app designer**
2. Click **+ Add trigger**

---

#### Step 5 — Add Recurrence Trigger

1. Select **Schedule** → **Recurrence**
2. Configure:
   - **Interval**: `15`
   - **Frequency**: `Minute`
3. Token theft is higher urgency than password spray — 15 minutes minimises the window between detection and analyst notification.

---

#### Step 6 — Add Compose Action (Compute Time Window)

1. Click **+** → **Add an action** → search `Compose` → select **Compose** (Built-in)
2. Rename it to `Compute_TimeWindow_Start`
3. In the **Inputs** field, switch to expression mode (`fx`) and enter:
   ```
   formatDateTime(addMinutes(utcNow(), -15), 'yyyy-MM-ddTHH:mm:ssZ')
   ```
   > This produces a timestamp 15 minutes in the past used to filter only new detections each run, ensuring no detection is reported twice.

---

#### Step 7 — Add HTTP Action (Get Token Theft Detections)

1. Click **+** → **Add an action** → search `HTTP` → select **HTTP** (Built-in)
2. Rename it to `Get_TokenTheft_Detections`
3. Configure:
   - **Method**: `GET`
   - **URI**: `https://graph.microsoft.com/v1.0/identityProtection/riskDetections`
   - **Queries** — add these 4 rows:

| Key | Value |
|-----|-------|
| `$filter` | `(riskEventType eq 'anomalousToken' or riskEventType eq 'tokenIssuerAnomaly') and createdDateTime ge @{outputs('Compute_TimeWindow_Start')}` |
| `$select` | `id,userId,userDisplayName,userPrincipalName,riskLevel,riskState,riskEventType,ipAddress,detectedDateTime,location` |
| `$orderby` | `detectedDateTime desc` |
| `$top` | `50` |

4. Scroll down → **Advanced parameters** → **Authentication**:
   - **Authentication type**: `Managed identity`
   - **Audience**: `https://graph.microsoft.com`

---

#### Step 8 — Add Parse JSON Action

1. Click **+** → **Add an action** → search `Parse JSON` → select **Parse JSON** (Built-in)
2. Configure:
   - **Content**: select `Body` from the `Get_TokenTheft_Detections` HTTP step
   - **Schema**: click **Use sample payload to generate schema**, paste the sample below, click **Done**

```json
{
  "value": [
    {
      "id": "00000000-0000-0000-0000-000000000000",
      "userId": "00000000-0000-0000-0000-000000000001",
      "userDisplayName": "Jane Doe",
      "userPrincipalName": "jane.doe@contoso.com",
      "riskLevel": "high",
      "riskState": "atRisk",
      "riskEventType": "anomalousToken",
      "ipAddress": "104.21.44.12",
      "detectedDateTime": "2026-07-13T09:42:00Z",
      "location": {
        "city": "Amsterdam",
        "state": "North Holland",
        "countryOrRegion": "NL"
      }
    }
  ]
}
```

---

#### Step 9 — Add Condition (Check If Detections Exist)

1. Click **+** → **Add an action** → search `Condition` → select **Condition** (Built-in)
2. Configure the expression:
   - Left value: `length(body('Parse_JSON')?['value'])`
   - Operator: `is greater than`
   - Right value: `0`

All remaining steps go inside the **True** branch.

---

#### Step 10 — Initialize Variable (Token Report Array)

1. Inside the **True** branch → **Add an action** → search `Initialize variable`
2. Configure:
   - **Name**: `TokenReport`
   - **Type**: `Array`
   - **Value**: leave empty

---

#### Step 11 — Add For Each Loop

1. Click **+** → **Add an action** → search `For each` → select **For each** (Built-in)
2. In **Select an output from previous steps**, enter the expression:
   ```
   body('Parse_JSON')?['value']
   ```

---

#### Step 12 — Inside For Each: Format Detection Type Label

1. Inside the For Each → **Add an action** → search `Compose`
2. Rename to `Format_Detection_Type`
3. In **Inputs**, enter the expression:
   ```
   replace(replace(coalesce(items('For_each')?['riskEventType'], 'unknown'), 'anomalousToken', 'Anomalous Token'), 'tokenIssuerAnomaly', 'Token Issuer Anomaly')
   ```
   > This converts the raw camelCase value to a readable label shown in the Detection column.

---

#### Step 13 — Inside For Each: Format Detection Row

1. **Add an action** → search `Compose` → rename to `Format_Detection_Row`
2. Runs after `Format_Detection_Type`
3. In **Inputs**, build the HTML table row including all columns: Account (name + UPN), Detection (from Step 12 output), Source/Location (IP + city/country), Risk, Detected At, and the two action links per user. Reference the ARM template for the complete expression.

---

#### Step 14 — Inside For Each: Append Row to Report Array

1. **Add an action** → search `Append to array variable`
2. Configure:
   - **Name**: `TokenReport`
   - **Value**: `@{outputs('Format_Detection_Row')}`

---

#### Step 15 — Compose Email Body

1. Outside the For Each → **Add an action** → search `Compose` → rename to `Compose_Email_Body`
2. This action assembles the full HTML email with the purple header, detection table, Quick Actions box, token type guide, 3-phase analyst response guide, Security Copilot prompt, and footer links. Reference the ARM template for the complete HTML.

---

#### Step 16 — Send Alert Email

1. **Add an action** → search `HTTP` → rename to `Send_Alert_Email`
2. Configure:
   - **Method**: `POST`
   - **URI**: `https://graph.microsoft.com/v1.0/users/SENDER@yourtenant.com/sendMail`
   - **Headers**: `Content-Type` = `application/json`
   - **Body**:
     ```json
     {
       "message": {
         "subject": "[CRITICAL] Token Theft Detected",
         "importance": "High",
         "body": { "contentType": "HTML", "content": "@{outputs('Compose_Email_Body')}" },
         "toRecipients": [{ "emailAddress": { "address": "RECIPIENT@yourtenant.com" } }]
       },
       "saveToSentItems": false
     }
     ```
   - **Authentication**: Managed identity / `https://graph.microsoft.com`

---

#### Step 17 — Save and Test

1. Click **Save** at the top
2. Click **Run Trigger** → **Run** for an immediate test run
3. Open **Run history** to monitor the execution
4. If no token theft detections exist in your tenant, the run completes silently (no email). This is correct behaviour.
5. Token theft detections (`anomalousToken`, `tokenIssuerAnomaly`) are generated automatically by Entra ID Protection's ML engine when anomalous token replay is identified.

---

### Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `Forbidden (403)` on riskDetections | `IdentityRiskEvent.Read.All` not yet propagated | Wait 5 minutes after granting and re-run |
| `Forbidden (403)` on sendMail | `Mail.Send` not granted or sender mailbox doesn't exist | Verify sender UPN is a real mailbox in your tenant |
| No email received but run succeeds | No `anomalousToken` or `tokenIssuerAnomaly` detections in window | Correct behaviour — silent when no detections found |
| `BadRequest` on OData filter | Parentheses missing around the `or` condition | Ensure filter is `(riskEventType eq 'anomalousToken' or riskEventType eq 'tokenIssuerAnomaly') and createdDateTime ge ...` |
| Detection type shows raw value | `Format_Detection_Type` compose step not connected | Ensure `Format_Detection_Row` runs after `Format_Detection_Type` in the For Each loop |

---

### Security Notes

- **No stored credentials** — Managed Identity eliminates API keys and OAuth connection secrets
- **Least privilege** — Only three read permissions and `Mail.Send` are granted; no write access to user accounts
- **No data stored** — The Logic App reads detections, composes an email, sends it, and discards everything
- **Admin consent required** — All three Graph permissions require explicit Global Administrator consent

---

### Files

| File | Description |
|------|-------------|
| [azuredeploy.json](Token%20Theft%20Detection/Token%20Theft%20Response%20Alert/azuredeploy.json) | ARM template — one-click deployment |
| [deploy.ps1](Token%20Theft%20Detection/Token%20Theft%20Response%20Alert/deploy.ps1) | PowerShell deployment + auto permission grant |
| [email-preview.html](Token%20Theft%20Detection/Token%20Theft%20Response%20Alert/email-preview.html) | Browser-viewable preview of the alert email |
