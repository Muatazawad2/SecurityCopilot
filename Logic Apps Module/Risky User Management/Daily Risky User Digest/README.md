# Daily Risky User Digest

[<- Logic Apps Module](../../README.md)

A Logic App that runs daily and emails a formatted HTML digest of at-risk users from Microsoft Entra ID Protection.

**Developer**: Dr Muataz Awad

---

## Architecture

![Daily Risky User Digest Architecture](../../Images/architecture.png)

---

## Overview

This workflow queries Entra ID risky users and sends a SOC-ready email summary.

- Trigger: daily schedule
- Source API: Microsoft Graph `identityProtection/riskyUsers`
- Auth: System-assigned managed identity (no stored credentials)
- Output: one daily HTML digest email

## Workflow Execution Flow

![Daily Risky User Digest Workflow](../../Images/how-it-works.png)

---

## Prerequisites

- Azure subscription with Global Administrator or Security Administrator role
- Microsoft Entra ID P2 license (required for Identity Protection risky users)
- Exchange Online license on the sender mailbox

---

## Deployment

### Option A - One-click ARM deployment

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMuatazawad2%2FSecurityCopilot%2Fmain%2FLogic%2520Apps%2520Module%2FRisky%2520User%2520Management%2FDaily%2520Risky%2520User%2520Digest%2Fazuredeploy.json)

### Option B - PowerShell

```powershell
.\deploy.ps1 -SenderEmail "admin@yourtenant.onmicrosoft.com" `
             -RecipientEmail "soc-team@yourtenant.onmicrosoft.com" `
             -SubscriptionId "your-subscription-id" `
             -ResourceGroup "your-resource-group"
```

### Option C - Manual Portal Setup (with screenshots)

Follow the step-by-step guide below.

---

## Required Graph Permissions

| Permission | Purpose |
|------------|---------|
| `IdentityRiskyUser.Read.All` | Read risky users from Entra ID Protection |
| `User.Read.All` | Resolve user profile information for reporting |
| `Mail.Send` | Send digest email through Microsoft Graph |

---

## Step-by-Step Manual Setup Guide

### Step 1 - Create the Logic App

1. Go to https://portal.azure.com, search for Logic Apps, and click Create.
2. Select your resource group, name it `daily-risky-user-digest`, choose Standard plan, and select your region.
3. Click Review + create, then Create.

![Step 1 - Create Logic App](../../Images/1.png)

---

### Step 2 - Enable System-Assigned Managed Identity

1. Open the Logic App and go to Settings > Identity.
2. Under System assigned, set Status to On and save.
3. Copy the Object (principal) ID for permission assignment.

![Step 2 - Enable Managed Identity](../../Images/4.png)

---

### Step 3 - Grant Microsoft Graph Permissions

Use either Graph Explorer or Azure Cloud Shell to grant the 3 app roles listed above to the Logic App managed identity.

Cloud Shell script:

```powershell
$token = (az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv)
$headers = @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }

$graphSp   = Invoke-RestMethod -Method GET -Uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '00000003-0000-0000-c000-000000000000'" -Headers $headers
$graphSpId = $graphSp.value[0].id
$principalId = "YOUR-MANAGED-IDENTITY-OBJECT-ID"

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

Verify in Entra ID Enterprise Applications that all 3 permissions show under admin consent.

![Step 3 - Graph Permissions](../../Images/21.png)

---

### Step 4 - Open the Logic App Designer

1. Open Logic app designer.
2. Click Add trigger.

![Step 4 - Logic App Designer](../../Images/5.png)

---

### Step 5 - Add Recurrence Trigger

1. Select On a schedule > Recurrence.
2. Set Interval to `1`, Frequency to `Day`, and choose your preferred run time.

![Step 5 - Recurrence Trigger](../../Images/7.png)

---

### Step 6 - Initialize Array Variable

1. Add action: Initialize variable.
2. Name: `UserReport`
3. Type: `Array`
4. Value: leave empty.

![Step 6a - Search Initialize Variable](../../Images/9.png)
![Step 6b - Initialize Variable Config](../../Images/10.png)

---

### Step 7 - Add HTTP GET for Risky Users

1. Add action: HTTP (Built-in).
2. Method: `GET`
3. URI: `https://graph.microsoft.com/v1.0/identityProtection/riskyUsers`
4. Queries:

| Key | Value |
|-----|-------|
| `$filter` | `riskState eq 'atRisk' and (riskLevel eq 'high' or riskLevel eq 'medium')` |
| `$select` | `id,userDisplayName,userPrincipalName,riskLevel,riskDetail,riskLastUpdatedDateTime` |
| `$orderby` | `riskLevel desc` |
| `$top` | `50` |

5. Authentication: Managed identity, System-assigned, Audience `https://graph.microsoft.com`.

![Step 7 - Search HTTP](../../Images/11.png)

---

### Step 8 - Add Parse JSON

1. Add action: Parse JSON.
2. Content: Body from HTTP step.
3. Schema: Use sample payload.

![Step 8a - Search Parse JSON](../../Images/12.png)
![Step 8b - Parse JSON Schema](../../Images/14.png)

Sample payload:

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

---

### Step 9 - Add For Each

1. Add action: For each.
2. Select output expression:

```
body('Parse_JSON')?['value']
```

![Step 9 - For Each](../../Images/16.png)

---

### Step 10 - Append HTML Rows to UserReport

1. Inside For each, add Append to array variable.
2. Name: `UserReport`.
3. Value expression:

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

### Step 11 - Add HTTP POST SendMail

1. Outside For each, add HTTP action and rename to Send Email Report.
2. Method: `POST`
3. URI: `https://graph.microsoft.com/v1.0/users/SENDER@yourtenant.onmicrosoft.com/sendMail`
4. Header: `Content-Type` = `application/json`
5. Authentication: Managed identity, System-assigned, Audience `https://graph.microsoft.com`.

![Step 11 - Send Email Auth](../../Images/18.png)

---

### Step 12 - Publish and Test

1. Click Publish.
2. Click Run draft.
3. Confirm success in Run history.

![Step 12 - Complete Workflow](../../Images/19.png)

Expected email result:

![Expected Email Result](../../Images/20.png)

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `Whitespaces must be encoded for URIs` | Space included directly in URI | Put OData parameters in the Queries section |
| `ValidationFailed` on Parse JSON | Schema does not match response | Regenerate schema using sample payload |
| `Forbidden (403)` on sendMail | Permissions not propagated yet | Wait a few minutes and re-run |
| Publish button disabled | Action validation errors in designer | Fix actions with red error markers |

---

## Files

| File | Description |
|------|-------------|
| [azuredeploy.json](azuredeploy.json) | ARM template for deployment |
| [deploy.ps1](deploy.ps1) | PowerShell deploy and permission grant script |

---

## Security Notes

- No stored credentials; uses system-assigned managed identity only.
- Uses least-privilege permissions for risky user read and email send.
- Requires admin consent for Microsoft Graph app role assignment.
