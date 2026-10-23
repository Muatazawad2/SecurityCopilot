# Azure RBAC Access Review

**Developer**: Dr Muataz Awad

**Description**: Conduct a structured Azure RBAC access review for a subscription — discover what subscriptions exist, retrieve who has access, resolve the raw principal IDs into real names for users, service principals, and groups, and close with least-privilege governance recommendations. Uses the [Azure Subscription & RBAC Inventory plugin](../Plugin/README.md) and the [Entra Principal Resolver companion plugin](../Entra%20Principal%20Resolver/README.md) — both must be installed and enabled. Each step is a single, independent request; Security Copilot's orchestrator can under-resolve results when two different lookups (e.g., two principal types, or a lookup plus a reasoning question) are combined into one compound prompt, so this promptbook deliberately keeps one intent per step.

---

1. Discover what subscriptions are in scope
```
List all Azure subscriptions in my tenant.
```

2. Retrieve who has access on the subscription under review
```
Who has role assignments on subscription {SubscriptionId}?
```

3. Resolve a specific user's real name
```
Who is the Entra user with object ID {UserPrincipalId}?
```

4. Resolve a specific service principal's real name
```
Who is the Entra service principal with object ID {ServicePrincipalId}?
```

5. Resolve a specific group's real name
```
Who is the Entra group with object ID {GroupPrincipalId}?
```

6. Apply least-privilege governance guidance
```
Based on Azure RBAC least-privilege best practices, how many subscription Owners should an organization typically have, should Owner access be assigned to individual users or to groups, and what is the recommended review cadence for Azure RBAC role assignments?
```

---

## How To Create This Promptbook In Security Copilot

1. Start by running step 1 to see every subscription in the tenant, then copy the `SubscriptionId` you want to review.
2. Run step 2 with that `SubscriptionId`. This returns every principal with access — as raw object IDs and principal types (User, ServicePrincipal, Group) — since the underlying API doesn't carry display names.
3. For each principal ID you want a real name for, run **one** of steps 3, 4, or 5 — matching the `PrincipalType` column from step 2 — substituting `{UserPrincipalId}`, `{ServicePrincipalId}`, or `{GroupPrincipalId}`. Run one principal at a time; asking about two different principal types in a single prompt can cause the orchestrator to resolve only one of them.
4. Run step 6 on its own, with no principal ID substitution, to get general governance guidance to close out the review.
5. Select all six prompts to include them in the promptbook.
6. Enter the promptbook name: **Azure RBAC Access Review** and add a description.
7. Choose sharing scope (personal, team, or organization).
8. Select **Create**, verify the success message, and open the promptbook from the library.

## Known Behavior

Steps 2–5 depend on custom plugins (not built-in Microsoft plugins), so they only return data if the [Azure Subscription & RBAC Inventory plugin](../Plugin/README.md) and [Entra Principal Resolver plugin](../Entra%20Principal%20Resolver/README.md) are both installed, enabled, and authorized for your tenant. Step 6 works with no plugins at all — it's general knowledge.

⚠️ **Do not edit step 2 to ask for names in the same prompt** (e.g. "...and what are their real names?"). This promptbook is deliberately designed to keep name resolution in separate, single-principal steps (3–5) because asking for bulk name resolution in one prompt — confirmed by live testing — can cause Security Copilot to **fabricate plausible-but-fake names** instead of calling the resolver, with no indication the output isn't real. If you need every principal in a subscription resolved automatically in one pass for a customer-facing report, use the [Logic App alternative](../Logic%20App/README.md) instead — it has no fabrication risk since it calls Microsoft Graph directly with no LLM step.

---

**Developer**: Dr Muataz Awad
