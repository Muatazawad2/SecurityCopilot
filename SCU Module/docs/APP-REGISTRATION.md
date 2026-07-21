# Manual Entra app registration

`SCU-Setup.ps1` registers the required Entra app for you automatically. Use this
guide only when you'd rather register the app **by hand** — for example when:

- you don't have rights to run setup scripts,
- tenant policy requires app registrations to go through a specific process,
- an admin pre-registers one shared app for everyone to reuse, or
- you simply want to understand what `SCU-Setup.ps1` does under the hood.

After registering the app with either method below, hand the resulting
**Application (client) ID** to the tooling to skip the creation step:

```powershell
# Reuse the app you just registered instead of creating a new one
.\SCU-Setup.ps1 -AppId <the-client-id>
```

## What gets registered

| Item | Value |
| --- | --- |
| App name | `SCU-Usage-Puller` |
| Sign-in audience | Single tenant (this directory only) |
| Public client flows | Enabled — required for device-code sign-in |
| API (SPN) | Microsoft Purview — AppId `73c2949e-da2d-457a-9607-fcc665198967` |
| Delegated permission | `Purview.DelegatedAccess` — id `817468d0-81dd-4cb5-94ac-07ca133fbbf6` |
| Application permission | Purview app role — id `8d48872e-7710-4001-bfd0-7dac15c28f69` |

> Granting admin consent requires **Global Administrator**, **Privileged Role
> Administrator**, or **Cloud Application Administrator**. If your role can't
> consent, ask an admin to run the consent step (or click the consent URL the
> setup script prints).

---

## Method A — Azure CLI (recommended)

```powershell
# 0. Sign in with an account that has Application Developer + admin-consent rights
az login

# 1. Constants (identical for every tenant - Microsoft's Purview SPN + scope IDs)
$PurviewAppId    = '73c2949e-da2d-457a-9607-fcc665198967'
$DelegatedScope  = '817468d0-81dd-4cb5-94ac-07ca133fbbf6'  # Purview.DelegatedAccess
$AppRole         = '8d48872e-7710-4001-bfd0-7dac15c28f69'  # Purview app role

# 2. Create the app registration (single tenant)
$app = az ad app create --display-name "SCU-Usage-Puller" `
    --sign-in-audience AzureADMyOrg --only-show-errors -o json | ConvertFrom-Json
$appId = $app.appId
Write-Host "AppId: $appId"

# 3. Add delegated + app role permissions on the Microsoft Purview SPN
az ad app permission add --id $appId --api $PurviewAppId `
    --api-permissions "$DelegatedScope=Scope" --only-show-errors
az ad app permission add --id $appId --api $PurviewAppId `
    --api-permissions "$AppRole=Role" --only-show-errors

# 4. Enable public-client flow (required for device-code sign-in)
az ad app update --id $appId --is-fallback-public-client true --only-show-errors

# 5. Create service principal for the app
az ad sp create --id $appId --only-show-errors

# 6. Grant admin consent (Global Admin / Priv Role Admin / Cloud App Admin)
az ad app permission admin-consent --id $appId --only-show-errors

Write-Host "Done. AppId: $appId"
Write-Host "Run:  .\SCU-Setup.ps1 -AppId $appId   # to skip the app-creation step"
```

Total time: ~30 seconds.

---

## Method B — Azure Portal (GUI, ~2 minutes)

### Step 1 — Create the app

1. Go to **<https://entra.microsoft.com>**.
2. Left nav → **Applications** → **App registrations** → **+ New registration**.
3. Fill in:
   - **Name:** `SCU-Usage-Puller`
   - **Supported account types:** *Accounts in this organizational directory only (Single tenant)*
   - **Redirect URI:** leave blank
4. Click **Register**.
5. From the **Overview** page, **copy the Application (client) ID** — you'll need it later.

### Step 2 — Enable device-code flow

1. Left nav → **Authentication**.
2. Scroll down to **Advanced settings** → **Allow public client flows**.
3. Set to **Yes** → **Save**.

### Step 3 — Add API permissions

1. Left nav → **API permissions** → **+ Add a permission**.
2. Click the tab **APIs my organization uses**.
3. Search for `Microsoft Purview` and pick the SPN with AppId
   **`73c2949e-da2d-457a-9607-fcc665198967`**.

   > Note: "Microsoft Purview" as an SPN is different from the newer Purview
   > Compliance offerings. The one you want has that exact GUID.

4. Choose **Delegated permissions** → check **`Purview.DelegatedAccess`** → **Add permissions**.
5. Repeat: **+ Add a permission** → **APIs my organization uses** → **Microsoft Purview**
   → **Application permissions** → check the Purview app role
   (id `8d48872e-7710-4001-bfd0-7dac15c28f69`) → **Add permissions**.

### Step 4 — Grant admin consent

1. Still on the **API permissions** page.
2. Click **Grant admin consent for `<your tenant name>`** *(disabled unless you're
   Global Admin / Privileged Role Admin / Cloud App Admin)*.
3. Confirm **Yes**.
4. Verify both permissions now show a green check under the **Status** column.

### Step 5 — Use the app

```powershell
# Skip SCU-Setup's app-creation step and use the app you just registered
.\SCU-Setup.ps1 -AppId <the-client-id-you-copied>
```

`SCU-Setup.ps1` detects the existing app and skips straight to the device-code
sign-in step.

---

## Verify it worked

Whichever method you used, verify with:

```powershell
$appId  = '<your-client-id>'
$sp     = az ad sp show --id $appId --only-show-errors | ConvertFrom-Json
$grants = az rest --method get `
    --uri "https://graph.microsoft.com/v1.0/oauth2PermissionGrants?`$filter=clientId eq '$($sp.id)'" |
    ConvertFrom-Json
$grants.value | Format-Table clientId, consentType, principalId, scope
```

You should see `Purview.DelegatedAccess offline_access` in the `scope` column.

---

**Developer**: Dr Muataz Awad
