# Entra Principal Resolver — Companion Plugin

[<- Azure RBAC Inventory Module](../README.md)

A second Security Copilot plugin that resolves the raw GUIDs returned by the [Azure Subscription & RBAC Inventory plugin](../Plugin/README.md) into human-readable names, by calling **Microsoft Graph** instead of Azure Resource Manager.

---

## Why a Separate Plugin

Azure Resource Manager (ARM) and Microsoft Graph are **different OAuth token audiences**. A single Security Copilot plugin authenticates with one `TokenEndpoint` + `Scopes` combination, producing a token valid for exactly one audience. A token scoped to `https://management.azure.com/.default` (used by the RBAC Inventory plugin) is rejected by Microsoft Graph, and vice versa.

So instead of trying to force both APIs into one plugin, this is a **second, independent plugin** that reuses the **same Entra App Registration** (same ClientId/ClientSecret) but requests tokens scoped to `https://graph.microsoft.com/.default`. Security Copilot's orchestrator can call both plugins in the same conversation — it already chains multiple tool calls per prompt when needed (for example, listing role assignments and then resolving each principal name).

## Skills Exposed

| Skill | Graph endpoint | Resolves |
|---|---|---|
| `ResolveEntraUserById` | `GET /users/{id}` | A `"User"` principalId to display name + UPN |
| `ResolveEntraServicePrincipalById` | `GET /servicePrincipals/{id}` | A `"ServicePrincipal"` principalId to display name + app ID |
| `ResolveEntraGroupById` | `GET /groups/{id}` | A `"Group"` principalId to display name |

## Prerequisites

- The **same** Entra App Registration used for the [Azure Subscription & RBAC Inventory plugin](../Plugin/README.md)
- Microsoft Graph **Application permissions** granted to that app registration, with admin consent:
  - `User.Read.All`
  - `Application.Read.All`
  - `Group.Read.All`

## Setup

### Step 1 — Open API permissions on the existing app registration

Go to the same app registration used for the RBAC Inventory plugin, then **API permissions**.

![Step 1 — API permissions page](../Images/25.png)

### Step 2 — Add a permission → Microsoft Graph

Click **Add a permission**, then select **Microsoft Graph**.

![Step 2 — Request API permissions, Microsoft Graph](../Images/26.png)

### Step 3 — Choose "Application permissions"

Since this plugin runs as a background service with no signed-in user, choose **Application permissions**, not Delegated.

![Step 3 — Application permissions selected](../Images/27.png)

### Step 4 — Search for and select each permission

Search for and check each of the three: `User.Read.All`, `Application.Read.All`, `Group.Read.All`.

![Step 4 — User.Read.All selected](../Images/28.png)

Click **Add permissions** once all three are checked.

### Step 5 — Grant admin consent

Click **Grant admin consent** and confirm. Application permissions are inert until an administrator consents — they won't work just by being added.

![Step 5 — Grant admin consent confirmation](../Images/29.png)

### Step 6 — Confirm all three show "Granted"

![Step 6 — All three permissions granted](../Images/30.png)

Equivalent Azure CLI (if you prefer scripting this step):

```powershell
$graphAppId   = "00000003-0000-0000-c000-000000000000"
$userReadAll  = "df021288-bdef-4463-88db-98f22de89214"   # User.Read.All
$appReadAll   = "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30"    # Application.Read.All
$groupReadAll = "5b567255-7703-4780-807c-7be8301ae99b"    # Group.Read.All

az ad app permission add --id <app-client-id> --api $graphAppId `
  --api-permissions "$userReadAll=Role" "$appReadAll=Role" "$groupReadAll=Role"

az ad app permission admin-consent --id <app-client-id>
```

### Step 7 — Upload the plugin to Security Copilot

Same flow as the RBAC Inventory plugin (**Sources > Custom > Upload plugin > Security Copilot plugin > Upload as a link**), pointing at [`manifest.yaml`](manifest.yaml).

### Step 8 — Configure auth with the Graph scope

Security Copilot prompts for OAuth Client Credentials fields again — reuse the same ClientId/ClientSecret from the RBAC Inventory plugin, but change the scope:

| Field | Value |
|---|---|
| **ClientId** | Same as the RBAC Inventory plugin |
| **ClientSecret** | Same as the RBAC Inventory plugin |
| **TokenEndpoint** | `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token` |
| **Scopes** | `https://graph.microsoft.com/.default` |

### Step 9 — Confirm it's active

![Step 9 — Entra Principal Resolver enabled in Security Copilot](../Images/31.png)

Its settings show the Graph-scoped configuration (ClientId and TokenEndpoint redacted below, same values as the RBAC Inventory plugin):

![Settings showing the Graph scope](../Images/32.png)

### Step 10 — Test it

With both plugins enabled, ask Security Copilot something like:

> "Who has role assignments on subscription \<id\>, and what are their names?"

In practice, the orchestrator does **not** reliably chain `ListSubscriptionRoleAssignments` into this plugin's skills on its own — see the warning below before relying on this for anything customer-facing. Name resolution works reliably only when you ask about **one specific object ID** at a time, as in the Verified Example.

## Verified Example

Resolving a known object ID directly confirms the plugin works end-to-end:

| Object ID | Resolved via | Result |
|---|---|---|
| `d5a157af-...` | `ResolveEntraUserById` | displayName: `System Administrator`, UPN: `admin@<tenant>.onmicrosoft.com` |
| `15d05821-...` | `ResolveEntraServicePrincipalById` | displayName: matches the RBAC Inventory plugin's own service principal, appId matches its ClientId |

![Live test — user resolved successfully](../Images/24.png)

## ⚠️ Known Behavior: Do Not Ask for Bulk Name Resolution in One Prompt

Asking Security Copilot to resolve **every principal in a role assignment list** within a single prompt — even a very explicit, insistent one (e.g. *"for every principal ID returned, you must call the resolver before answering"*) — has two observed failure modes, confirmed by live testing:

1. **Honest failure**: the response says names are "not available" and returns only raw GUIDs and principal types. This is safe but unhelpful.
2. **Silent fabrication (more dangerous)**: the activity trace shows the orchestrator calling `ListSubscriptionRoleAssignments` exactly once and then going straight to "Prepared your response" / "Composed Message" — **the resolver skills (`ResolveEntraUserById`, `ResolveEntraServicePrincipalById`, `ResolveEntraGroupById`) are never actually invoked.** Instead, the underlying model fills in plausible-sounding, generic Azure identity names (e.g. a human name, "Microsoft Azure CLI", "Azure Machine Learning", "Azure OpenAI") that are **not the real tenant data** and do not match any actual resolved result. The response is presented with full confidence and no indication it is fabricated.

**Do not present confidence-worded "resolved" multi-row name tables from a single compound Security Copilot prompt to a customer or in any report** — verify every name against a known-good source first, or avoid the pattern entirely.

**Reliable options instead**:
- Ask about **one principal ID per prompt** (e.g. *"Who is the Entra user with object ID \<id\>?"*) — verified accurate every time, including for multiple principal types across separate prompts.
- For a complete, automatically resolved list in one pass with **zero hallucination risk**, use the [Logic App (Managed Identity) alternative](../Logic%20App/README.md) instead — it calls Microsoft Graph directly via deterministic workflow logic, not an LLM, so there is nothing for a model to fabricate.

This is a different and more serious issue than the skill-collision behavior below (which at least fails honestly); treat it as the primary reason not to use chat-based bulk name resolution for anything you plan to share externally.

## Known Behavior: Ask About One Principal Type at a Time

When a single prompt asks Security Copilot to resolve **multiple different principal types in one go** (e.g. "resolve this user ID and this service principal ID"), the orchestrator may only invoke one of the two matching skills and report the other as "could not be resolved" — even though both skills work correctly in isolation. This is a documented Security Copilot behavior called **skill collision**, where very similarly described skills (`ResolveEntraUserById` vs. `ResolveEntraServicePrincipalById`) can be under-disambiguated when requested together.

**Workaround**: Ask about one principal (or one principal type) per prompt — e.g. *"Who is the Entra user with object ID \<id\>?"* — rather than a single compound request covering users and service principals together. Both skills were verified to work correctly end-to-end when asked individually.

---

**Developer**: Dr Muataz Awad
