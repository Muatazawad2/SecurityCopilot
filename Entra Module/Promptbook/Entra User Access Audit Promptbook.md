# Entra User Access Audit

**Developer**: Dr Muataz Awad

**Description**: Audit user access and permissions across your Entra tenant. Review individual user profiles, group memberships, role assignments, licensing status, and recent activities. Identify risky users, assess access appropriateness, and flag access inconsistencies. Use prompts from Entra ID Prompt Samples, Entra ID Protection Prompt Samples, and Entra ID Governance Prompt Samples. Results depend on available audit logs and user query permissions.

---

## Step 1: Get User Profile and Status Overview

Start with a high-level view of the user's account status, licensing, and general profile information.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#user-information-and-details):**
- Tell me about this user.
- Who is {UserDisplayName}'s manager?
- Is {UserDisplayName}'s account cloud managed?

**Also from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#user-filtering-and-organization):**
- Show users with account disabled.
- List users without assigned licenses.

---

## Step 2: Review User Risk Status

Determine if the user has any associated risk factors or risky behaviors.

**Prompts to use from [Entra ID Protection Prompt Samples](../Sample%20Prompts/Entra%20ID%20Protection%20Prompt%20Samples.md#risky-users):**
- Determine if this user is currently high risk.
- Display detailed risk information for this user.
- Show the risk history for this user.

---

## Step 3: Analyze Group Memberships

Review all groups the user is a member of to understand their access scope and departmental associations.

**Prompts to use from [Entra ID Governance Prompt Samples](../Sample%20Prompts/Entra%20ID%20Governance%20Prompt%20Samples.md#access-reviews):**
- Show current membership for this user's groups.
- List all groups this user is a member of.
- How many groups is this user a member of?

---

## Step 4: Review Role Assignments

Check all administrative and privileged roles assigned to the user, including eligible and active assignments.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#role-assignment-queries):**
- What role does user {UserDisplayName} have?
- What are the transitive roles user {UserDisplayName} has?
- What are the eligible roles user {UserDisplayName} has?
- What are the scheduled roles user {UserDisplayName} has?

**Also from [Entra ID Governance Prompt Samples](../Sample%20Prompts/Entra%20ID%20Governance%20Prompt%20Samples.md#pim-activities):**
- Show PIM activation history for this user.

---

## Step 5: Assess Permissions and Authentication

Review the user's permissions, authentication methods, and any conditional access policy impacts.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#user-authentication-and-permissions):**
- What are {UserDisplayName}'s authentication methods?
- Look up {UserDisplayName}'s permissions.

**Also from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#sign-in-logs):**
- Show sign-in failures due to a specific Conditional Access policy.
- Show sign-ins with unsatisfied Conditional Access Policies.

---

## Step 6: Review Recent User Activity

Examine recent sign-ins, provisioning events, and audit log entries to detect anomalies.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#user-activity-and-security-monitoring):**
- Show sign-in activity for the user {UserDisplayName}.
- Show sign-in activities since a specific time period.

**From [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#user-provisioning-monitoring):**
- Show provisioning logs for this user.
- Get provisioning history for user {UserDisplayName}.

---

## Step 7: Identify and Report Access Anomalies

Synthesize findings to identify any access inconsistencies, excessive permissions, or unusual patterns.

**Use this prompt to summarize:**
```
Based on the user's profile, group memberships, role assignments, permissions, and recent activity, provide an access audit summary including:
- Current access level (Low, Standard, Elevated/Admin)
- Appropriateness of access for their role
- Any excessive or unexpected permissions
- Risky patterns or anomalies detected
- Recommendations for access adjustments or further investigation
- Any compliance or governance concerns
```

---

## How To Create This Promptbook In Security Copilot

1. Open Security Copilot and navigate to Promptbooks.
2. Select each prompt step, validate output by replacing {UserDisplayName}, {UserPrincipalName} with actual user values.
3. Once all steps are validated, select all prompts to include in the promptbook.
4. Enter the promptbook name: "Entra User Access Audit"
5. Add the description: "Audit user access and permissions across your Entra tenant."
6. Create the promptbook and verify it appears in your promptbook library.
7. Share with your identity governance and compliance teams.
