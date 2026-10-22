# Azure RBAC Inventory Sample Prompts

**Developer**: Dr Muataz Awad

**Description**: A reusable set of sample prompts for the [Azure Subscription & RBAC Inventory plugin](../Plugin/README.md) and [Entra Principal Resolver](../Entra%20Principal%20Resolver/README.md) companion plugin. Replace `{Placeholder}` values with your own subscription and object IDs. Ask about one principal (or principal type) per prompt — see the Known Behavior note at the bottom.

## Subscription Discovery

- List all Azure subscriptions in my tenant.
- What Azure subscriptions do we have?
- Is subscription {SubscriptionId} enabled or disabled?

## Role Assignment & Access Review

- Who has role assignments on subscription {SubscriptionId}?
- List role assignments for subscription {SubscriptionId}.
- Who has access to subscription {SubscriptionId}?
- What is the role definition ID {RoleDefinitionId} at scope {Scope}?

## Principal Name Resolution

- Who is the Entra user with object ID {UserPrincipalId}?
- Who is the Entra service principal with object ID {ServicePrincipalId}?
- Who is the Entra group with object ID {GroupPrincipalId}?
- What is the user principal name for Entra user {UserPrincipalId}?
- Is the Entra user {UserPrincipalId} account enabled?
- What is the app ID for the service principal {ServicePrincipalId}?

## Governance & Best Practices

- Based on Azure RBAC least-privilege best practices, how many subscription Owners should an organization typically have?
- Should Owner access on an Azure subscription be assigned to individual users or to groups, and why?
- What is the recommended review cadence for Azure RBAC role assignments?
- What is the difference between the Owner, Contributor, and Reader built-in Azure roles?
- What is the difference between the User Access Administrator and Owner roles?

## Known Behavior

Asking about **two different principal types in one prompt** (for example, a user ID and a service principal ID together) can cause the orchestrator to resolve only one of them and report the other as unavailable. Ask about one principal — or one principal type — per prompt for reliable results. This applies to the Principal Name Resolution prompts above; Subscription Discovery and Role Assignment prompts are not affected since they only call a single skill.
