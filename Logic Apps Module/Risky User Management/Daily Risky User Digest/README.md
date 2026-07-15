# Daily Risky User Digest

[<- Risky User Management](../README.md)

A Logic App that runs daily and emails a formatted HTML digest of at-risk users from Microsoft Entra ID Protection.

**Developer**: Dr Muataz Awad

---

## Overview

This workflow queries Entra ID risky users and sends a SOC-ready email summary.

- Trigger: daily schedule
- Source API: Microsoft Graph `identityProtection/riskyUsers`
- Auth: System-assigned managed identity (no stored credentials)
- Output: one daily HTML digest email

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

---

## Files

| File | Description |
|------|-------------|
| [azuredeploy.json](azuredeploy.json) | ARM template for deployment |
| [deploy.ps1](deploy.ps1) | PowerShell deploy and permission grant script |

