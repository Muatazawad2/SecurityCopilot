# Azure RBAC Inventory Module

Answers a question none of the built-in Microsoft Security Copilot plugins can: *"List all Azure subscriptions in my tenant and show who has role assignments (access) on each one."*

This module ships **two working ways** to get that answer — pick based on how you want to use it.

---

## Two Ways to Get This Done

| | [Security Copilot Plugins](#part-1--step-by-step-azure-subscription--rbac-inventory-plugin) (Parts 1–2) | [Logic App — Managed Identity](Logic%20App/README.md) (Part 3) |
|---|---|---|
| **How you use it** | Ask in chat — *"List all Azure subscriptions"*, *"Who has access to subscription X, with names?"* | Trigger it (manually or on a schedule) — get back the full resolved report, no prompting |
| **Best for** | Ad-hoc investigation, analysts asking follow-up questions | Scheduled reporting, audits, feeding results into another system |
| **Credentials** | Entra App Registration + client secret (must be rotated) | **Zero secrets** — system-assigned managed identity only |
| **Determinism** | Chat orchestrator decides which skill to call | Fixed sequence every run — no orchestrator judgment |
| **Known caveat** | Asking about a user + service principal together in one prompt can hit a "skill collision" — ask one at a time | Synchronous response window scales with role assignment count (mitigated with `Foreach` concurrency) |
| **Setup** | [Part 1](#part-1--step-by-step-azure-subscription--rbac-inventory-plugin) + [Part 2](#part-2--step-by-step-entra-principal-resolver-companion-plugin) | [Part 3](#part-3--step-by-step-logic-app-managed-identity-alternative) |

> A native Security Copilot **Agent** (a third idea, to auto-chain the two plugins so the chat UI could do this deterministically) was evaluated and did not work — Security Copilot's Agent `ChildSkills` cannot currently call skills across separately uploaded plugins, confirmed via a minimal reproducible test. That finding is what led to building the Logic App alternative instead; it is **not** a third option today. See [Part 3's "Why a Logic App Instead of (or Alongside) an Agent"](#why-a-logic-app-instead-of-or-alongside-an-agent) for the full explanation.

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

> ARM and Microsoft Graph are different OAuth token audiences, so this is two separate Security Copilot plugins sharing one app registration — not one plugin calling both APIs. See the comparison table at the top of this page for the Logic App alternative.

## What's Included

| Item | Description |
|---|---|
| [`Plugin/manifest.yaml`](Plugin/manifest.yaml) | Native Security Copilot plugin manifest (ARM) |
| [`Plugin/openapi.yaml`](Plugin/openapi.yaml) | OpenAPI 3.0 spec: list subscriptions, list role assignments |
| [`Entra Principal Resolver/manifest.yaml`](Entra%20Principal%20Resolver/manifest.yaml) | Companion plugin manifest (Graph) |
| [`Entra Principal Resolver/openapi.yaml`](Entra%20Principal%20Resolver/openapi.yaml) | OpenAPI 3.0 spec: resolve user, service principal, group |
| [`Logic App/workflow-definition.json`](Logic%20App/workflow-definition.json) | Full deterministic Logic App workflow (no Security Copilot involved) |
| [`Logic App/Grant-ManagedIdentityGraphPermissions.ps1`](Logic%20App/Grant-ManagedIdentityGraphPermissions.ps1) | Grants the managed identity's Graph application permissions |
| [`Promptbook/Azure RBAC Access Review Promptbook.md`](Promptbook/Azure%20RBAC%20Access%20Review%20Promptbook.md) | 6-step saved Security Copilot promptbook: discover, review access, resolve names, apply governance guidance |
| [`Sample Prompts/Azure RBAC Inventory Sample Prompts.md`](Sample%20Prompts/Azure%20RBAC%20Inventory%20Sample%20Prompts.md) | Standalone prompts by category: discovery, access review, name resolution, governance |

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

# Part 3 — Step-by-Step: Logic App (Managed Identity) Alternative

An Azure Logic App that performs the same inventory and name resolution as Parts 1 and 2 above, but as a **deterministic workflow with zero secrets** — using the Logic App's **system-assigned managed identity** instead of an Entra App Registration client secret. Full details, sample output, and known considerations are in the [Logic App README](Logic%20App/README.md); the short version and all screenshots are below.

## Why a Logic App Instead of (or Alongside) an Agent

A native Security Copilot **Agent** was tried first, to chain the two plugins above deterministically instead of leaving tool selection to the chat orchestrator's judgment. A controlled, minimal reproduction confirmed a platform limitation: an Agent's `ChildSkills` only resolve skills that live **inside the agent's own uploaded manifest** — never skills belonging to a *separately uploaded* plugin, even when that plugin is correctly listed in `RequiredSkillsets` and fully enabled. Every attempt to call a `ChildSkill` owned by another plugin failed with `Unable to find skill '<name>'`, regardless of whether it was referenced by bare name or fully qualified as `SkillsetName.SkillName` — both documented as valid. Since ARM and Microsoft Graph are different OAuth token audiences, the two plugins can't be merged into one manifest to work around this (one Security Copilot manifest supports exactly one `Authorization` config).

A Logic App has no such limitation — it's pure Azure control flow, not an LLM-mediated tool call, so it can call both APIs in one deterministic sequence with no orchestrator ambiguity at all.

## Create the Logic App and Grant Access

**Step 1 — Create the Logic App with a system-assigned managed identity enabled** (via `az logic workflow create --mi-system-assigned`, or Portal + Identity blade).

**Step 2 — Confirm the identity and note its Object (principal) ID**

![Step 2 — System-assigned identity On, Object (principal) ID shown](Logic%20App/Images/02-identity.png)

**Step 3 — Grant Azure RBAC Reader on the subscription** to the managed identity (Access control (IAM), or the "Azure role assignments" shortcut on the Identity page)

![Step 3 — Reader role assigned at the subscription scope](Logic%20App/Images/03-role-assignments.png)

**Step 4 — Grant Microsoft Graph application permissions.** The Portal has no "API permissions" UI for a managed identity the way it does for an App Registration — run [`Grant-ManagedIdentityGraphPermissions.ps1`](Logic%20App/Grant-ManagedIdentityGraphPermissions.ps1) to grant `User.Read.All`, `Group.Read.All`, and `Application.Read.All` via the Graph API directly. Verify afterward under **Enterprise applications > (Logic App name) > Permissions**:

![Step 4 — Microsoft Graph permissions granted to the managed identity](Logic%20App/Images/08-enterprise-app-permissions.png)

## Review and Run the Workflow

**Step 5 — Paste [`workflow-definition.json`](Logic%20App/workflow-definition.json) into Logic app code view** (or deploy with `az logic workflow update --definition`). The designer shows the entire deterministic chain in one diagram — list subscriptions, then for each subscription list role assignments, then for each role assignment resolve the role name and principal name, compose a row, and append it to the final report:

![Step 5 — Full workflow: deterministic chain, no LLM orchestration](Logic%20App/Images/04-designer-full.png)

**Step 6 — Trigger a run.** The Overview page shows run history with status and duration:

![Step 6 — Logic App overview with run history](Logic%20App/Images/01-overview.png)

**Step 7 — Inspect a successful run.** Every action is green, including the live iteration count — this run processed 163 role assignments across its subscriptions, fully automatically:

![Step 7 — Successful run: all green, 163 role assignments processed](Logic%20App/Images/05-run-monitor.png)

Drilling into `Resolve Principal` for one iteration shows the real Microsoft Graph call and its result — `GET /directoryObjects/{id}` returning `@odata.type: #microsoft.graph.user` and a resolved display name:

![Step 7b — Resolve Principal: real Graph call and resolved name](Logic%20App/Images/06-resolve-principal-detail.png)

And `Compose Row` shows the fully merged record for that same iteration — subscription, resolved principal name and type, resolved role name (including custom roles, not just built-ins like Owner/Reader), and scope:

![Step 7c — Compose Row: one fully merged, human-readable record](Logic%20App/Images/07-compose-row-detail.png)

> See the [Logic App README](Logic%20App/README.md) for the full architecture explanation, sample JSON output, and known considerations (synchronous response window, stale-principal handling, least privilege).

---

## Quick Start

1. Create an Entra App Registration and a client secret (Part 1, Steps 1–8).
2. Grant it the **Reader** role on the target subscription(s) (Part 1, Steps 9–15).
3. Upload `Plugin/manifest.yaml` to Security Copilot (Part 1, Steps 16–22).
4. Ask: *"List all Azure subscriptions in my tenant"* or *"Who has role assignments on subscription \<id\>?"*
5. **(Optional, for readable names)** Add Graph permissions + admin consent (Part 2, Steps 1–6), upload `Entra Principal Resolver/manifest.yaml` (Part 2, Steps 7–9). Ask about one principal ID at a time.
6. **(No-secret alternative)** Create the Logic App with a system-assigned managed identity, grant it Reader + the three Graph permissions, paste in `workflow-definition.json`, and trigger it (Part 3). One run returns every subscription's access list with every principal and role already resolved to a name — no chat prompt needed.
7. **(Ready-made prompts)** Don't want to write prompts yourself? Use the [Azure RBAC Access Review promptbook](Promptbook/Azure%20RBAC%20Access%20Review%20Promptbook.md) for a saved, repeatable 6-step review, or browse the [Sample Prompts](Sample%20Prompts/Azure%20RBAC%20Inventory%20Sample%20Prompts.md) for standalone prompts by category.

## Important Notes

- **Security Copilot cannot create the App Registration or grant RBAC itself.** Someone with Entra/Azure admin rights must provision the identity and access outside Security Copilot first (Azure Portal, CLI, or PowerShell). The plugin only *consumes* those credentials — it does not create them.
- Scope the Reader grant as narrowly as possible (single subscription, not tenant root) unless a full tenant-wide inventory is genuinely required.
- Rotate the client secret regularly — it is a long-lived credential with read access to your subscription's resource, RBAC metadata, and (with the companion plugin) directory user/app/group data.
- The Logic App alternative (Part 3) needs no client secret at all — the system-assigned managed identity is the credential, and Azure manages and rotates it automatically.

---

**Developer**: Dr Muataz Awad
