# Entra Conditional Access Policy Analysis

**Developer**: Dr Muataz Awad

**Description**: Analyze Conditional Access policies across your Entra tenant. Review policy inventory, targeting scope, enforcement requirements, user compliance patterns, and policy effectiveness. Identify gaps in coverage, policy conflicts, and enforcement challenges. Use prompts from Entra ID Prompt Samples to assess your complete CA policy posture. Results depend on available policy audit logs and sign-in data.

---

## Step 1: Inventory All Conditional Access Policies

Start by listing all CA policies and their current deployment status.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#policy-discovery-and-status):**
- Which Conditional Access policies are currently enabled in my tenant?
- What Conditional Access policies are disabled?
- List CA policies enforcing MFA.
- Show me all authentication strength policies.
- Which CA policies require MFA for users?

---

## Step 2: Review Policy Targeting and Scope

Examine which users, groups, and applications are affected by CA policies.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#policy-targeting-and-application):**
- Show CA policies applied to a specific user.
- Which CA policies are targeting {UserPrincipalName}?
- Show CA policies targeting a specific group.
- What policies apply to users in the {DepartmentName} group?
- Which CA policies apply to external users?

---

## Step 3: Analyze Policy Requirements and Controls

Review the specific controls and conditions implemented in each policy.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#policy-status-and-management):**
- List inactive CA policies.
- How many CA policies are currently active?
- What CA policies are not applicable to trusted locations?
- Which CA policies have legacy authentication blocked?
- Show me CA policies that require compliant devices.

---

## Step 4: Check Policy Enforcement and Sign-in Impact

Examine how policies are being enforced and their impact on user sign-ins.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#application-and-authentication-analysis):**
- Show sign-in failures due to a specific Conditional Access policy.
- Show sign-ins with unsatisfied Conditional Access Policies.

---

## Step 5: Assess Device and Location Controls

Review CA policy controls related to device compliance and location-based access.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#device-identification-and-status):**
- Show me all compliant devices / Show me all non-compliant devices.
- List devices that are not under management.

**Also from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#device-and-location-analysis):**
- Show sign-ins from non-compliant devices.
- Show logins from specific operating systems.
- Show sign-ins from specific locations.

---

## Step 6: Review Authentication Method Requirements

Examine CA policies enforcing specific authentication methods and MFA configuration.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#authentication-method-configuration):**
- What authentication methods are enabled in my tenant?
- Is Microsoft Authenticator enabled in my tenant? For who?
- Is system preferred authentication enabled in my tenant? For who?

---

## Step 7: Export Policy Inventory and Configuration

Get comprehensive policy inventory and configuration export.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#policy-inventory-and-export):**
- Export CA-policy inventory.
- How many total Conditional Access policies exist in my tenant?
- What is the count of enabled vs. disabled CA policies?
- List all CA policies with their current enforcement state.
- Show me a summary of all CA policy configurations.

---

## Step 8: Identify Policy Gaps and Conflicts

Analyze coverage gaps and potential policy conflicts or redundancies.

**Use this prompt to summarize:**
```
Review the CA policy inventory and targeting, then identify:
- Policies with overlapping or redundant controls
- User populations not covered by specific policy types (e.g., external users, risky sign-ins)
- Policies with high sign-in failure rates or exceptions
- Policies that appear inactive or have low enforcement impact
- Recommended new policies to close identified coverage gaps
```

---

## Step 9: Provide Policy Recommendations and Optimization

Consolidate findings into a comprehensive CA policy analysis and recommendations.

**Use this prompt to summarize:**
```
Based on the complete Conditional Access policy analysis, provide a comprehensive assessment including:
- Total policy count (enabled, disabled, draft)
- Policy coverage by control type (MFA, device compliance, legacy auth, location, etc.)
- User and group populations affected by policies
- Policy enforcement effectiveness (failure rate, unsatisfied policy count)
- Device compliance adoption and non-compliant device count
- Key gaps in policy coverage
- High-priority recommendations for new policies or policy updates
- Suggested policy review and optimization roadmap
- Timeline for next CA policy audit
```

---

## How To Create This Promptbook In Security Copilot

1. Open Security Copilot and navigate to Promptbooks.
2. Select each prompt step and validate output, replacing placeholders like {UserPrincipalName}, {DepartmentName} with actual values.
3. Once all steps are validated, select all prompts to include in the promptbook.
4. Enter the promptbook name: "Entra Conditional Access Policy Analysis"
5. Add the description: "Analyze Conditional Access policies across your Entra tenant to assess coverage, effectiveness, and identify optimization opportunities."
6. Create the promptbook and verify it appears in your promptbook library.
7. Share with your security and identity governance teams for regular policy audits.
