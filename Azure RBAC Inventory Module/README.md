# Azure RBAC Inventory Module

A custom Security Copilot plugin that answers a question none of the built-in Microsoft plugins can: *"List all Azure subscriptions in my tenant and show who has role assignments (access) on each one."*

---

## Why a Custom Plugin Is Needed

Security Copilot ships with built-in plugins for Microsoft Entra, Microsoft Defender XDR, Microsoft Sentinel, Microsoft Purview, Microsoft Intune, and Microsoft Threat Intelligence. None of them call the **Azure Resource Manager (ARM)** API, so Security Copilot cannot natively enumerate Azure subscriptions or Azure RBAC role assignments — that control plane is separate from Microsoft Graph / Entra ID. Asked directly, Security Copilot will confirm it has no data source for this.

This module restores that capability using the native Security Copilot **API plugin** format (YAML manifest + OpenAPI spec), authenticated with an Entra **App Registration** via the **OAuth 2.0 Client Credentials** flow — plus a companion plugin that resolves the raw GUIDs into readable names via Microsoft Graph.

## Architecture

```
Security Copilot --(OAuth Client Credentials)--> Microsoft Entra ID --(access token)--> Azure Resource Manager
                                                                                                |
                                                                                 subscriptions + roleAssignments
                                                                                                |
                                                                            principal IDs (GUIDs, not names)
                                                                                                |
Security Copilot --(OAuth Client Credentials, Graph scope)--> Microsoft Entra ID --(access token)--> Microsoft Graph
                                                                                                |
                                                                                 resolved display names
```

- **Auth**: `OAuthClientCredentialsFlow` — Security Copilot exchanges a ClientId/ClientSecret for a bearer token at the tenant's token endpoint, then calls the target API with it.
- **Identity**: A dedicated Entra App Registration (service principal), granted:
  - **Reader** role at the subscription (or management group) scope, for ARM — least privilege, read-only
  - Microsoft Graph **Application permissions** `User.Read.All`, `Application.Read.All`, `Group.Read.All` (admin-consented), for name resolution
- **Skills exposed** (`Plugin/` — ARM, subscription-scoped): `ListAzureSubscriptions`, `ListSubscriptionRoleAssignments`
- **Skills exposed** (`Entra Principal Resolver/` — Graph-scoped, same identity, different token audience): `ResolveEntraUserById`, `ResolveEntraServicePrincipalById`, `ResolveEntraGroupById`

> ARM and Microsoft Graph are different OAuth token audiences, so this is two separate Security Copilot plugins sharing one app registration — not one plugin calling both APIs.

## What's Included

| Item | Description |
|---|---|
| [`Plugin/manifest.yaml`](Plugin/manifest.yaml) | Native Security Copilot plugin manifest (ARM) |
| [`Plugin/openapi.yaml`](Plugin/openapi.yaml) | OpenAPI 3.0 spec: list subscriptions, list role assignments |
| [`Entra Principal Resolver/manifest.yaml`](Entra%20Principal%20Resolver/manifest.yaml) | Companion plugin manifest (Graph) |
| [`Entra Principal Resolver/openapi.yaml`](Entra%20Principal%20Resolver/openapi.yaml) | OpenAPI 3.0 spec: resolve user, service principal, group |

---

# Part 1 — Step-by-Step: Azure Subscription & RBAC Inventory Plugin

## Create the Entra App Registration and Grant RBAC Access

**Step 1 — Open App registrations**

![App registrations list](Images/01.png)

**Step 2 — Register a new application**

![Register an application — empty form](Images/02.png)

**Step 3 — Name the app and register it** (single-tenant, no redirect URI needed)

![Name filled in](Images/03.png)

**Step 4 — Record the Client ID and Tenant ID from the Overview page**

![Overview — app created](Images/04.png)

**Step 5 — Go to Certificates & secrets**

![Certificates & secrets — empty](Images/05.png)

**Step 6 — Add a client secret**

![Add a client secret panel](Images/06.png)

**Step 7 — Describe the secret and set an expiry**

![Secret description filled in](Images/07.png)

**Step 8 — Copy the secret value immediately** (shown only once)

![Secret value shown once](Images/08.png)

**Step 9 — Find your subscription ID** under Subscriptions

![Subscriptions list](Images/09.png)

**Step 10 — Access control (IAM) → Add role assignment → select Reader** (least privilege)

![Add role assignment — role picker](Images/10.png)

**Step 11 — Confirm Reader is selected**

![Reader role selected](Images/11.png)

**Step 12 — Go to the Members tab**

![Members tab — empty](Images/12.png)

**Step 13 — Search for and select your app registration as the member**

![Searching for the app as the RBAC member](Images/13.png)

**Step 14 — Confirm the member selection**

![Member selected and confirmed](Images/14.png)

**Step 15 — Review + assign to finalize** (Role: Reader, Scope: subscription, Member: your app)

![Review + assign summary](Images/15.png)

## Upload and Configure the Plugin in Security Copilot

**Step 16 — Sources icon → Manage plugins → Custom section**

![Manage plugins — Custom section](Images/16.png)

**Step 17 — Upload plugin → choose format**

![Add a plugin — format selection](Images/17.png)

**Step 18 — Choose "Security Copilot plugin", toggle "Upload as a link", paste the manifest.yaml raw URL**

![Format selected — upload options](Images/18.png)

**Step 19 — Set File type to `.yaml`, click Add**

![Link pasted, file type dropdown](Images/19.png)

**Step 20 — Security Copilot auto-detects OAuth Client Credentials and prompts for auth fields**

![Auth setup — empty](Images/20.png)

**Step 21 — Fill in ClientId / ClientSecret / TokenEndpoint / Scopes** (`https://management.azure.com/.default`)

![Auth form filled in](Images/21.png)

**Step 22 — Plugin now appears active in the Custom section**

![Plugin active in the Custom list](Images/22.png)

**Step 23 — Test it: "List all Azure subscriptions in my tenant" — real, live data returned**

![Live test — success](Images/23.png)

You can also ask *"Who has role assignments on subscription \<id\>?"* to invoke the second skill.

---

# Part 2 — Step-by-Step: Entra Principal Resolver Companion Plugin

The RBAC Inventory plugin returns raw GUIDs for principals, not names. This companion plugin resolves them via Microsoft Graph, reusing the **same app registration** with Graph-scoped permissions.

**Step 1 — Open API permissions on the same app registration**

![API permissions page](Images/25.png)

**Step 2 — Add a permission → Microsoft Graph**

![Request API permissions, Microsoft Graph](Images/26.png)

**Step 3 — Choose "Application permissions"** (background service, no signed-in user)

![Application permissions selected](Images/27.png)

**Step 4 — Search for and select `User.Read.All`, `Application.Read.All`, `Group.Read.All`**

![User.Read.All selected](Images/28.png)

**Step 5 — Grant admin consent** (Application permissions are inert until consented)

![Grant admin consent confirmation](Images/29.png)

**Step 6 — Confirm all three show "Granted"**

![All three permissions granted](Images/30.png)

Equivalent Azure CLI:

```powershell
$graphAppId   = "00000003-0000-0000-c000-000000000000"
$userReadAll  = "df021288-bdef-4463-88db-98f22de89214"   # User.Read.All
$appReadAll   = "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30"    # Application.Read.All
$groupReadAll = "5b567255-7703-4780-807c-7be8301ae99b"    # Group.Read.All

az ad app permission add --id <app-client-id> --api $graphAppId `
  --api-permissions "$userReadAll=Role" "$appReadAll=Role" "$groupReadAll=Role"

az ad app permission admin-consent --id <app-client-id>
```

**Step 7 — Upload `Entra Principal Resolver/manifest.yaml`** to Security Copilot the same way as Part 1, Steps 16–19.

**Step 8 — Configure auth, reusing the same ClientId/ClientSecret but with the Graph scope** (`https://graph.microsoft.com/.default`)

**Step 9 — Confirm it's active alongside the first plugin**

![Entra Principal Resolver enabled](Images/31.png)

Its settings show the Graph-scoped configuration (credentials redacted):

![Settings showing the Graph scope](Images/32.png)

**Step 10 — Test it: ask about one principal at a time** — e.g. *"Who is the Entra user with object ID \<id\>?"*

![Live test — user resolved successfully](Images/24.png)

> **Known behavior**: asking about a user and a service principal **together in one compound prompt** may cause the orchestrator to only resolve one of them ("skill collision"). Asking about one principal per prompt works reliably every time — both skills were verified end-to-end in isolation.

---

## Quick Start

1. Create an Entra App Registration and a client secret (Part 1, Steps 1–8).
2. Grant it the **Reader** role on the target subscription(s) (Part 1, Steps 9–15).
3. Upload `Plugin/manifest.yaml` to Security Copilot (Part 1, Steps 16–22).
4. Ask: *"List all Azure subscriptions in my tenant"* or *"Who has role assignments on subscription \<id\>?"*
5. **(Optional, for readable names)** Add Graph permissions + admin consent (Part 2, Steps 1–6), upload `Entra Principal Resolver/manifest.yaml` (Part 2, Steps 7–9). Ask about one principal ID at a time.

## Important Notes

- **Security Copilot cannot create the App Registration or grant RBAC itself.** Someone with Entra/Azure admin rights must provision the identity and access outside Security Copilot first (Azure Portal, CLI, or PowerShell). The plugin only *consumes* those credentials — it does not create them.
- Scope the Reader grant as narrowly as possible (single subscription, not tenant root) unless a full tenant-wide inventory is genuinely required.
- Rotate the client secret regularly — it is a long-lived credential with read access to your subscription's resource, RBAC metadata, and (with the companion plugin) directory user/app/group data.

---

**Developer**: Dr Muataz Awad
