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

## Architecture

```
Security Copilot --(OAuth Client Credentials)--> Microsoft Entra ID --(access token)--> Azure Resource Manager
                                                                                                |
                                                                                 subscriptions + roleAssignments
```

- **Auth**: `OAuthClientCredentialsFlow` — Security Copilot exchanges a ClientId/ClientSecret for a bearer token at the tenant's token endpoint, then calls ARM with it.
- **Identity**: A dedicated Entra App Registration (service principal), granted the **Reader** role at the subscription (or management group) scope — least privilege, read-only.
- **Skills exposed**:
  - `ListAzureSubscriptions` — `GET /subscriptions`
  - `ListSubscriptionRoleAssignments` — `GET /subscriptions/{subscriptionId}/providers/Microsoft.Authorization/roleAssignments`

## Quick Start

1. Create an Entra App Registration and a client secret.
2. Grant it the **Reader** role on the target subscription(s).
3. Upload [`Plugin/manifest.yaml`](Plugin/manifest.yaml) to Security Copilot as a custom plugin.
4. Enter the ClientId / ClientSecret / TokenEndpoint / Scopes when prompted.
5. Ask: *"List all Azure subscriptions in my tenant"* or *"Who has role assignments on subscription \<id\>?"*

See **[Plugin/README.md](Plugin/README.md)** for the complete walkthrough with screenshots.

## Important Notes

- **Security Copilot cannot create the App Registration or grant RBAC itself.** Someone with Entra/Azure admin rights must provision the identity and access outside Security Copilot first (Azure Portal, CLI, or PowerShell). The plugin only *consumes* those credentials — it does not create them.
- Scope the Reader grant as narrowly as possible (single subscription, not tenant root) unless a full tenant-wide inventory is genuinely required.
- Rotate the client secret regularly — it is a long-lived credential with read access to your subscription's resource and RBAC metadata.

---

**Developer**: Dr Muataz Awad
