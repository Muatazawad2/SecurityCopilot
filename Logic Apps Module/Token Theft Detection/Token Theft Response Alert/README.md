# Token Theft Response Alert

[← Logic Apps Module](../../README.md)

A Logic App that polls Entra ID Protection every 15 minutes for token theft risk detections (`anomalousToken` and `tokenIssuerAnomaly`) and immediately sends a critical HTML alert email. Includes detection type, affected accounts, source IPs, risk levels, Quick Actions, a 3-phase analyst response guide (including token type determination and AiTM phishing investigation), and an embedded Security Copilot investigation prompt.

**What it detects:**
- `riskEventType: anomalousToken` — token replayed from a device/IP inconsistent with issuance — indicates **pass-the-cookie** attack
- `riskEventType: tokenIssuerAnomaly` — token issuer metadata is anomalous — primary signal of **AiTM phishing proxy** (Evilginx, Modlishka)

**What it sends:** An immediate alert email with a detection table, Quick Actions box, and phased analyst guide. **No email is sent if no detections are found.**

**Developer**: Dr Muataz Awad

---

## How It Works

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

## Prerequisites

- Azure subscription with Global Administrator or Security Administrator role
- Microsoft Entra ID P2 license (required for Identity Protection risk detections)
- Exchange Online license on the sender mailbox

---

## Deployment

### Option A — Deploy to Azure (one-click)

Click the button below to deploy directly to your Azure subscription:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMuatazawad2%2FSecurityCopilot%2Fmain%2FLogic%2520Apps%2520Module%2FToken%2520Theft%2520Detection%2FToken%2520Theft%2520Response%2520Alert%2Fazuredeploy.json)

You will be prompted to enter:
- **Resource Group** — existing resource group in your subscription
- **Sender Email** — mailbox the alert comes FROM (must exist in your tenant)
- **Recipient Email** — mailbox or distribution list to send TO
- **Polling Interval Minutes** — how often to check (default: `15`)

After deployment, grant the Managed Identity the required Graph permissions — see **Step 3** in the manual setup guide below.

### Option B — PowerShell

```powershell
.\deploy.ps1 -SenderEmail "security-alerts@company.com" `
             -RecipientEmail "soc-team@company.com" `
             -ResourceGroup "rg-security"
```

The script deploys the ARM template and automatically grants all required Graph permissions.

---

## Required Graph Permissions

| Permission | App Role ID | Purpose |
|------------|-------------|---------|
| `IdentityRiskEvent.Read.All` | `9e4862a5-b68f-479e-848a-4e07e25c9916` | Read anomalous token and token issuer anomaly detections |
| `AuditLog.Read.All` | `b0afded3-3588-46d8-8b3d-9842eff778da` | Read sign-in logs for session context |
| `Mail.Send` | `b633e1c5-b582-4048-a93e-9f11b44c7e96` | Send alert emails via Microsoft Graph |

---

## Step-by-Step Manual Setup Guide

### Step 1 — Create the Logic App

1. Go to [portal.azure.com](https://portal.azure.com) → search **Logic Apps** → click **+ Create**
2. Select your **Resource Group**, enter name `token-theft-response-alert`, choose **Consumption** plan, select your region
3. Click **Review + Create** → **Create**

---

### Step 2 — Enable System-Assigned Managed Identity

1. Open the Logic App → left menu → **Settings** → **Identity**
2. Under **System assigned**, toggle **Status** to **On**
3. Click **Save** → note the **Object (principal) ID** — you will need it for Step 3

---

### Step 3 — Grant Microsoft Graph Permissions

#### Option A — Azure Cloud Shell (recommended)

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

#### Option B — Graph Explorer

1. Go to [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer) → sign in as Global Administrator
2. Find the Graph service principal ID:
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

### Step 4 — Open the Logic App Designer

1. Open the Logic App → left menu → **Logic app designer**
2. Click **+ Add trigger**

---

### Step 5 — Add Recurrence Trigger

1. Select **Schedule** → **Recurrence**
2. Configure:
   - **Interval**: `15`
   - **Frequency**: `Minute`
3. Token theft is higher urgency — 15 minutes minimises the window between detection and analyst notification.

---

### Step 6 — Add Compose Action (Compute Time Window)

1. Click **+** → **Add an action** → search `Compose` → select **Compose** (Built-in)
2. Rename to `Compute_TimeWindow_Start`
3. In **Inputs**, switch to expression mode (`fx`) and enter:
   ```
   formatDateTime(addMinutes(utcNow(), -15), 'yyyy-MM-ddTHH:mm:ssZ')
   ```
   > Produces a timestamp 15 minutes in the past. Ensures no detection is reported twice across consecutive runs.

---

### Step 7 — Add HTTP Action (Get Token Theft Detections)

1. Click **+** → **Add an action** → search `HTTP` → select **HTTP** (Built-in)
2. Rename to `Get_TokenTheft_Detections`
3. Configure:
   - **Method**: `GET`
   - **URI**: `https://graph.microsoft.com/v1.0/identityProtection/riskDetections`
   - **Queries**:

| Key | Value |
|-----|-------|
| `$filter` | `(riskEventType eq 'anomalousToken' or riskEventType eq 'tokenIssuerAnomaly') and createdDateTime ge @{outputs('Compute_TimeWindow_Start')}` |
| `$select` | `id,userId,userDisplayName,userPrincipalName,riskLevel,riskState,riskEventType,ipAddress,detectedDateTime,location` |
| `$orderby` | `detectedDateTime desc` |
| `$top` | `50` |

4. **Authentication**: Managed identity / audience `https://graph.microsoft.com`

---

### Step 8 — Add Parse JSON Action

1. **Add an action** → **Parse JSON**
2. **Content**: Body from the HTTP step
3. **Schema**: Use sample payload → paste the sample below → Done

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
      "location": { "city": "Amsterdam", "state": "North Holland", "countryOrRegion": "NL" }
    }
  ]
}
```

---

### Step 9 — Add Condition (Check If Detections Exist)

1. **Add an action** → **Condition**
2. Expression: `length(body('Parse_JSON')?['value'])` **is greater than** `0`

All remaining steps go inside the **True** branch.

---

### Step 10 — Initialize Variable

1. **Add an action** → **Initialize variable**
2. **Name**: `TokenReport` | **Type**: `Array` | **Value**: empty

---

### Step 11 — Add For Each Loop

1. **Add an action** → **For each**
2. Output: `body('Parse_JSON')?['value']`

---

### Step 12 — Inside For Each: Format Detection Type Label

1. **Add an action** → **Compose** → rename `Format_Detection_Type`
2. **Inputs** expression:
   ```
   replace(replace(coalesce(items('For_each')?['riskEventType'], 'unknown'), 'anomalousToken', 'Anomalous Token'), 'tokenIssuerAnomaly', 'Token Issuer Anomaly')
   ```
   > Converts the raw camelCase API value to a human-readable label for the Detection column.

---

### Step 13 — Inside For Each: Format Detection Row

1. **Add an action** → **Compose** → rename `Format_Detection_Row`
2. Runs **after** `Format_Detection_Type`
3. Build the HTML row including all columns: Account (name + UPN), Detection (output of Step 12), Source/Location (IP + city/country), Risk, Detected At, and User Profile + Sign-in Logs action links per user. See [azuredeploy.json](azuredeploy.json) for the complete expression.

---

### Step 14 — Inside For Each: Append Row to Array

1. **Add an action** → **Append to array variable**
2. **Name**: `TokenReport` | **Value**: `@{outputs('Format_Detection_Row')}`

---

### Step 15 — Compose Email Body

1. Outside the For Each → **Add an action** → **Compose** → rename `Compose_Email_Body`
2. Build the full HTML email with the purple header, detection table, Quick Actions box, token type determination guide, 3-phase analyst response guide, Security Copilot prompt, and footer links. See [azuredeploy.json](azuredeploy.json) for the complete HTML.

---

### Step 16 — Send Alert Email

1. **Add an action** → **HTTP** → rename `Send_Alert_Email`
2. **Method**: `POST` | **URI**: `https://graph.microsoft.com/v1.0/users/SENDER@yourtenant.com/sendMail`
3. **Headers**: `Content-Type` = `application/json`
4. **Body**:
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
5. **Authentication**: Managed identity / `https://graph.microsoft.com`

---

### Step 17 — Save and Test

1. Click **Save**
2. Click **Run Trigger** → **Run** for an immediate test
3. Check **Run history** to monitor execution
4. If no token theft detections exist, the run completes silently — this is correct behaviour
5. Token theft detections are generated automatically by Entra ID Protection's ML engine when anomalous token replay is identified

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `Forbidden (403)` on riskDetections | `IdentityRiskEvent.Read.All` not yet propagated | Wait 5 minutes after granting and re-run |
| `Forbidden (403)` on sendMail | `Mail.Send` not granted or sender mailbox doesn't exist | Verify sender UPN is a real mailbox in your tenant |
| No email but run succeeds | No `anomalousToken` or `tokenIssuerAnomaly` detections in window | Correct — silent when no detections found |
| `BadRequest` on OData filter | Parentheses missing around the `or` condition | Ensure filter starts with `(riskEventType eq 'anomalousToken' or ...)` |
| Detection type shows raw value | `Format_Detection_Row` not connected after `Format_Detection_Type` | Ensure Step 13 runs after Step 12 in the For Each loop |

---

## Security Notes

- **No stored credentials** — Managed Identity eliminates API keys and OAuth connection secrets
- **Least privilege** — Only three read permissions and `Mail.Send` are granted; no write access to user accounts
- **No data stored** — Reads detections, sends email, discards everything
- **Admin consent required** — All three permissions require explicit Global Administrator consent

---

## Files

| File | Description |
|------|-------------|
| [azuredeploy.json](azuredeploy.json) | ARM template — one-click deployment |
| [deploy.ps1](deploy.ps1) | PowerShell deployment + auto permission grant |
| [email-preview.html](email-preview.html) | Browser-viewable preview of the alert email |
