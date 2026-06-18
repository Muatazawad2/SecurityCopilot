# Entra Access Control & Compliance Audit

**Developer**: Dr Muataz Awad

**Description**: Audit access control policies and compliance posture across your Entra tenant. Review Conditional Access policies, privileged access management activities, access review status, and device compliance. Assess alignment with security standards and identify gaps in policy enforcement. Use prompts from Entra ID Prompt Samples and Entra ID Governance Prompt Samples. Results depend on available policy logs and audit trail data.

---

## Step 1: Inventory Conditional Access Policies

Begin by listing all Conditional Access policies and their current enforcement state.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#policy-discovery-and-status):**
- Which Conditional Access policies are currently enabled in my tenant?
- What Conditional Access policies are disabled?
- List CA policies enforcing MFA.
- Show me all authentication strength policies.

---

## Step 2: Review Policy Targeting and Scope

Examine which users, groups, and applications are targeted by Conditional Access policies.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#policy-targeting-and-application):**
- Show CA policies applied to a specific user.
- Which CA policies are targeting {UserPrincipalName}?
- Show CA policies targeting a specific group.
- What policies apply to users in the {DepartmentName} group?
- Which CA policies apply to external users?

---

## Step 3: Assess Policy Requirements and Controls

Review the specific controls and requirements implemented by each policy.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#policy-status-and-management):**
- List inactive CA policies.
- How many CA policies are currently active?
- What CA policies are not applicable to trusted locations?
- Which CA policies have legacy authentication blocked?
- Show me CA policies that require compliant devices.

**Also from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#application-and-authentication-analysis):**
- Show sign-in failures due to a specific Conditional Access policy.
- Show sign-ins with unsatisfied Conditional Access Policies.

---

## Step 4: Review Privileged Access Management (PIM) Activities

Examine PIM activations, eligible roles, and activation history to ensure privileged access is properly governed.

**Prompts to use from [Entra ID Governance Prompt Samples](../Sample%20Prompts/Entra%20ID%20Governance%20Prompt%20Samples.md#pim-activities):**
- Show PIM activation history.
- Which users activated privileged roles in the last 24 hours?
- Show me all eligible PIM roles.
- List the approval requests for PIM activations.
- Show PIM resource discovery and assignment.

**Also from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#role-assignment-queries):**
- Who has the Cloud Application Administrator role assigned to them?
- Who has eligibility for the Global Reader role?

---

## Step 5: Review Access Review Campaigns and Status

Check the status of access reviews and identify any pending or stale review campaigns.

**Prompts to use from [Entra ID Governance Prompt Samples](../Sample%20Prompts/Entra%20ID%20Governance%20Prompt%20Samples.md#access-reviews):**
- Show all access review campaigns.
- List pending access reviews.
- How many access reviews are in progress?
- Show access review completion status.
- Show me the results of completed access reviews.

---

## Step 6: Assess Device Compliance and Authentication Posture

Review device compliance requirements and authentication method policies.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#device-identification-and-status):**
- Show me all compliant devices / Show me all non-compliant devices.
- List devices that are not under management.
- How many devices are there?

**Also from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#authentication-method-configuration):**
- What authentication methods are enabled in my tenant?
- Is Microsoft Authenticator enabled in my tenant?
- Is system preferred authentication enabled in my tenant?

---

## Step 7: Get Policy Inventory and Compliance Summary

Export and summarize the complete access control and compliance posture.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#policy-inventory-and-export):**
- Export CA-policy inventory.
- How many total Conditional Access policies exist in my tenant?
- What is the count of enabled vs. disabled CA policies?
- List all CA policies with their current enforcement state.
- Show me a summary of all CA policy configurations.

---

## Step 8: Synthesize Audit Findings and Recommendations

Consolidate all findings into a compliance and access control assessment.

**Use this prompt to summarize:**
```
Based on the Conditional Access policy audit, PIM activities, access review status, and device compliance review, provide an access control and compliance audit summary including:
- Current access control posture (Low, Medium, High, or Critical)
- Coverage of key risk areas (MFA, device compliance, legacy auth blocking, etc.)
- Number of active policies, pending reviews, and compliance gaps
- PIM activation trends and privileged access governance status
- Device compliance and authentication method adoption metrics
- Top compliance risks and recommended policy adjustments
- Timeline for next audit or policy review cycle
```

---

## How To Create This Promptbook In Security Copilot

1. Open Security Copilot and navigate to Promptbooks.
2. Select each prompt step and validate output, replacing placeholders like {UserPrincipalName}, {DepartmentName} with actual values.
3. Once all steps are validated, select all prompts to include in the promptbook.
4. Enter the promptbook name: "Entra Access Control & Compliance Audit"
5. Add the description: "Audit access control policies and compliance posture across your Entra tenant."
6. Create the promptbook and verify it appears in your promptbook library.
7. Share with your compliance, governance, and security teams for regular audits.
