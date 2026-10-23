# Azure Subscription & RBAC Inventory — Plugin Setup Guide

[<- Azure RBAC Inventory Module](../README.md)

A native Security Copilot API plugin that lists Azure subscriptions and Azure RBAC role assignments by calling Azure Resource Manager (ARM) directly, authenticated with an Entra App Registration using OAuth 2.0 Client Credentials.

---

## Why This Plugin Exists

None of Security Copilot's built-in Microsoft plugins (Entra, Defender XDR, Sentinel, Purview, Intune, Threat Intelligence) call the Azure Resource Manager API. Azure subscription inventory and Azure RBAC role assignments live on a different control plane than Microsoft Graph / Entra ID, so prompts like *"List all Azure subscriptions in my tenant and show who has access"* return **no data** from the stock plugin set — Security Copilot will say so directly if you ask.

This plugin closes that gap with two skills:

| Skill | ARM endpoint | Example prompt |
|---|---|---|
| `ListAzureSubscriptions` | `GET /subscriptions` | "List all Azure subscriptions in my tenant" |
| `ListSubscriptionRoleAssignments` | `GET /subscriptions/{id}/providers/Microsoft.Authorization/roleAssignments` | "Who has role assignments on subscription \<id\>?" |

---

## Prerequisites

- Azure AD / Entra ID admin rights to create an App Registration and client secret
- Azure RBAC admin rights (Owner or User Access Administrator) on the subscription(s) you want inventoried
- Security Copilot Owner/Contributor access with permission to add custom plugins

---

## Important: Security Copilot Cannot Provision This Itself

Security Copilot has no capability to create Entra app registrations, generate secrets, or grant Azure RBAC role assignments. A human with the appropriate Entra and Azure admin rights must provision the identity and access **outside** Security Copilot (Azure Portal, CLI, or PowerShell) before the plugin can authenticate. Security Copilot's plugin setup only *consumes* the resulting ClientId / ClientSecret — it does not create them.

---

## Part 1 — Create the Entra App Registration and Grant RBAC Access

### Step 1 — Open App registrations

Go to the [Azure Portal](https://portal.azure.com) and navigate to **Microsoft Entra ID > App registrations**.

![App registrations list](../Images/01.png)

### Step 2 — Register a new application

Click **New registration**.

![Register an application — empty form](../Images/02.png)

### Step 3 — Name the app and register it

Give it a descriptive name (single-tenant, no redirect URI needed for this auth flow), then click **Register**.

![Name filled in](../Images/03.png)

### Step 4 — Record the identifiers

After registration, the Overview page shows the **Application (client) ID** and **Directory (tenant) ID** you'll need later for the plugin setup.

![Overview — app created](../Images/04.png)

### Step 5 — Go to Certificates & secrets

![Certificates & secrets — empty](../Images/05.png)

### Step 6 — Add a client secret

Click **New client secret**.

![Add a client secret panel](../Images/06.png)

### Step 7 — Describe the secret and set an expiry

Give it a clear description and choose an expiry (shorter is more secure — plan to rotate it).

![Secret description filled in](../Images/07.png)

### Step 8 — Copy the secret value immediately

The **Value** is shown only once. Copy it now — you cannot retrieve it again later (you would have to create a new secret).

![Secret value shown once](../Images/08.png)

### Step 9 — Find your subscription ID

Go to **Subscriptions** to find the subscription ID you want this plugin to inventory.

![Subscriptions list](../Images/09.png)

### Step 10 — Open Access control (IAM) > Add role assignment

From the subscription, go to **Access control (IAM) > Add > Add role assignment**, then search for and select the **Reader** role (least privilege — read-only).

![Add role assignment — role picker](../Images/10.png)

### Step 11 — Confirm Reader is selected

![Reader role selected](../Images/11.png)

### Step 12 — Go to the Members tab

![Members tab — empty](../Images/12.png)

### Step 13 — Search for and select your app registration

Click **Select members**, search by the app's display name, and select it.

![Searching for the app as the RBAC member](../Images/13.png)

### Step 14 — Confirm the member selection

![Member selected and confirmed](../Images/14.png)

### Step 15 — Review and assign

Confirm **Role: Reader**, the correct **Scope** (subscription), and the app under **Members**, then click **Review + assign** to finalize.

![Review + assign summary](../Images/15.png)

> **Scope it narrowly.** Grant Reader at the single subscription level, not the tenant/management-group root, unless a genuine tenant-wide inventory is required.

---

## Part 2 — Upload and Configure the Plugin in Security Copilot

### Step 16 — Open Manage plugins

In Security Copilot, click the **Sources** icon in the prompt bar, then scroll to the **Custom** section.

![Manage plugins — Custom section](../Images/16.png)

### Step 17 — Add a plugin

Click **Upload plugin**, then choose the upload format.

![Add a plugin — format selection](../Images/17.png)

### Step 18 — Select "Security Copilot plugin" and paste the manifest link

Choose **Security Copilot plugin** (native YAML format), toggle **Upload as a link**, and paste the raw GitHub URL of [`manifest.yaml`](manifest.yaml).

![Format selected — upload options](../Images/18.png)

### Step 19 — Set the file type

Set **File type** to `.yaml`, then click **Add**.

![Link pasted, file type dropdown](../Images/19.png)

### Step 20 — Complete the auth setup

Security Copilot auto-detects `OAuthClientCredentialsFlow` from the manifest and prompts for the auth fields.

![Auth setup — empty](../Images/20.png)

### Step 21 — Fill in the auth fields

| Field | Value |
|---|---|
| **ClientId** | The Application (client) ID from Step 4 |
| **ClientSecret** | The secret value you copied in Step 8 |
| **TokenEndpoint** | `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token` |
| **Scopes** | `https://management.azure.com/.default` |
| **AuthorizationContentType** | `application/x-www-form-urlencoded` (default) |

![Auth form filled in](../Images/21.png)

Click **Set up**.

### Step 22 — Confirm the plugin is active

The plugin now appears, enabled, in the **Custom** section.

![Plugin active in the Custom list](../Images/22.png)

### Step 23 — Test it

Ask: *"List all Azure subscriptions in my tenant"*. Security Copilot calls `ListAzureSubscriptions` via the plugin and returns a real, live table.

![Live test — success](../Images/23.png)

You can now also ask follow-up prompts like *"Who has role assignments on subscription \<id\>?"* to invoke `ListSubscriptionRoleAssignments`.

---

## Security Notes

- The client secret is a long-lived credential with read access to your subscription's resource and RBAC metadata. Store it only in Security Copilot's plugin configuration — never in source control or chat.
- Rotate the secret periodically and before its expiry date.
- Prefer the narrowest RBAC scope that satisfies the requirement (single subscription over management group root, Reader over Owner).

---

**Developer**: Dr Muataz Awad
