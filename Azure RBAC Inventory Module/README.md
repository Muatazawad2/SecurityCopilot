# Azure RBAC Inventory Module

A custom Security Copilot plugin that answers a question none of the built-in Microsoft plugins can: *"List all Azure subscriptions in my tenant and show who has role assignments (access) on each one."*

---

## Why a Custom Plugin Is Needed

Security Copilot ships with built-in plugins for Microsoft Entra, Microsoft Defender XDR, Microsoft Sentinel, Microsoft Purview, Microsoft Intune, and Microsoft Threat Intelligence. None of them call the **Azure Resource Manager (ARM)** API, so Security Copilot cannot natively enumerate Azure subscriptions or Azure RBAC role assignments — that control plane is separate from Microsoft Graph / Entra ID. Asked directly, Security Copilot will confirm it has no data source for this.

This module restores that capability using the native Security Copilot **API plugin** format (YAML manifest + OpenAPI spec), authenticated with an Entra **App Registration** via the **OAuth 2.0 Client Credentials** flow.

## What's Included

| Item | Description |
|---|---|
| [`Plugin/manifest.yaml`](Plugin/manifest.yaml) | Native Security Copilot plugin manifest (`Descriptor` + `SkillGroups`, API format) |
| [`Plugin/openapi.yaml`](Plugin/openapi.yaml) | OpenAPI 3.0 spec wrapping two ARM endpoints: list subscriptions, list role assignments |
| [`Plugin/README.md`](Plugin/README.md) | Complete setup guide — 23 screenshots covering the Entra App Registration, RBAC grant, and Security Copilot plugin upload |
| [`Entra Principal Resolver/manifest.yaml`](Entra%20Principal%20Resolver/manifest.yaml) | Companion plugin manifest — resolves raw GUIDs to names via Microsoft Graph |
| [`Entra Principal Resolver/openapi.yaml`](Entra%20Principal%20Resolver/openapi.yaml) | OpenAPI 3.0 spec wrapping three Graph endpoints: resolve user, service principal, group |
| [`Entra Principal Resolver/README.md`](Entra%20Principal%20Resolver/README.md) | Setup guide for the companion plugin |

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
- **Skills exposed** (`Plugin/` — ARM, subscription-scoped):
  - `ListAzureSubscriptions` — `GET /subscriptions`
  - `ListSubscriptionRoleAssignments` — `GET /subscriptions/{subscriptionId}/providers/Microsoft.Authorization/roleAssignments`
- **Skills exposed** (`Entra Principal Resolver/` — Graph-scoped, same identity, different token audience):
  - `ResolveEntraUserById` — `GET /users/{id}`
  - `ResolveEntraServicePrincipalById` — `GET /servicePrincipals/{id}`
  - `ResolveEntraGroupById` — `GET /groups/{id}`

> ARM and Microsoft Graph are different OAuth token audiences, so this is two separate Security Copilot plugins sharing one app registration — not one plugin calling both APIs. See [`Entra Principal Resolver/README.md`](Entra%20Principal%20Resolver/README.md) for why.

## Quick Start

1. Create an Entra App Registration and a client secret.
2. Grant it the **Reader** role on the target subscription(s).
3. Upload [`Plugin/manifest.yaml`](Plugin/manifest.yaml) to Security Copilot as a custom plugin.
4. Enter the ClientId / ClientSecret / TokenEndpoint / Scopes when prompted.
5. Ask: *"List all Azure subscriptions in my tenant"* or *"Who has role assignments on subscription \<id\>?"*
6. **(Optional, for readable names instead of GUIDs)** Add Microsoft Graph Application permissions to the same app registration, grant admin consent, then upload [`Entra Principal Resolver/manifest.yaml`](Entra%20Principal%20Resolver/manifest.yaml) as a second plugin. Ask: *"Who has role assignments on subscription \<id\>, and what are their names?"*

See **[Plugin/README.md](Plugin/README.md)** for the complete walkthrough with screenshots, and **[Entra Principal Resolver/README.md](Entra%20Principal%20Resolver/README.md)** for the name-resolution companion plugin.

## Important Notes

- **Security Copilot cannot create the App Registration or grant RBAC itself.** Someone with Entra/Azure admin rights must provision the identity and access outside Security Copilot first (Azure Portal, CLI, or PowerShell). The plugin only *consumes* those credentials — it does not create them.
- Scope the Reader grant as narrowly as possible (single subscription, not tenant root) unless a full tenant-wide inventory is genuinely required.
- Rotate the client secret regularly — it is a long-lived credential with read access to your subscription's resource and RBAC metadata.

---

**Developer**: Dr Muataz Awad
