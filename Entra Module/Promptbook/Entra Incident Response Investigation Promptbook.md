# Entra Incident Response Investigation

**Developer**: Dr Muataz Awad

**Description**: Investigate security incidents involving compromised accounts, suspicious activities, or unauthorized access. Work through the user's risk profile, sign-in patterns, activity anomalies, permissions and roles, and recent audit events to determine the scope and impact of the incident. Use prompts from Entra ID Prompt Samples, Entra ID Protection Prompt Samples, and Entra ID Governance Prompt Samples. Results may be limited if audit logs are not retained or required investigation permissions are unavailable.

---

## Step 1: Assess User Risk Profile

Determine if the targeted user is flagged as risky and understand their current risk status.

**Prompts to use from [Entra ID Protection Prompt Samples](../Sample%20Prompts/Entra%20ID%20Protection%20Prompt%20Samples.md#risky-users):**
- Determine if this user is currently high risk.
- Display detailed risk information for this user.
- Show the risk history for this user.

---

## Step 2: Analyze Sign-in Patterns and Anomalies

Examine the user's recent sign-in activity to identify suspicious patterns, impossible travel, or unusual authentication methods.

**Prompts to use from [Entra ID Protection Prompt Samples](../Sample%20Prompts/Entra%20ID%20Protection%20Prompt%20Samples.md#risky-sign-ins):**
- Show risky sign-ins from this user.
- What risk factors contributed to this sign-in being flagged?
- Has this user had risky sign-ins from unusual locations?
- What is the pattern of risky sign-ins for this user?

**Also from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#user-activity-and-security-monitoring):**
- Show sign-in activity for the user {UserDisplayName}.
- Show suspicious login activities.

---

## Step 3: Review User Permissions and Roles

Check what permissions, roles, and group memberships the compromised user has to assess potential scope of impact.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#user-authentication-and-permissions):**
- Look up {UserDisplayName}'s permissions.

**Also from [Entra ID Governance Prompt Samples](../Sample%20Prompts/Entra%20ID%20Governance%20Prompt%20Samples.md#access-reviews):**
- Show current membership for this user's groups.
- List all groups this user is a member of.

**And from [Entra ID Prompt Samples — Roles](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#role-assignment-queries):**
- What role does user {UserDisplayName} have?
- What are the transitive roles user {UserDisplayName} has?

---

## Step 4: Check Risky Applications and Permissions

Identify what applications the user has accessed or been granted permissions to, focusing on risky or high-privilege apps.

**Prompts to use from [Entra ID Protection Prompt Samples](../Sample%20Prompts/Entra%20ID%20Protection%20Prompt%20Samples.md#permissions-and-privilege-assessment):**
- Which permissions are granted to risky apps?
- Which permissions granted to this app are highly privileged?

**Also from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#application-and-authentication-analysis):**
- Show sign-ins to a specific application.

---

## Step 5: Review Audit and Activity Logs

Examine audit logs to identify what actions the user or attacker took, including policy changes, role modifications, or suspicious operations.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#group-management-activities) and [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#security-and-authentication-activities):**
- Show me risky sign-ins.
- List suspicious logins.
- Are there any risky authentications?

**From [Entra ID Governance Prompt Samples](../Sample%20Prompts/Entra%20ID%20Governance%20Prompt%20Samples.md#pim-activities):**
- Show PIM activation history for this user.
- Which users activated privileged roles in the last 24 hours?

---

## Step 6: Assess Device and Access Context

Review the devices and locations from which the user accessed systems to determine if access patterns are legitimate.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#device-and-location-analysis):**
- Show sign-ins from non-compliant devices.
- Show logins from specific operating systems.
- Show sign-ins from specific locations.

---

## Step 7: Summarize Incident and Determine Scope

Synthesize findings into a risk assessment and identify scope of potential compromise or unauthorized activity.

**Use this prompt to summarize:**
```
Based on the user's risk profile, sign-in patterns, permissions, application access, and audit activity, provide a comprehensive incident summary including:
- Overall risk verdict (Low, Medium, High, or Critical)
- Scope of impact (number of users, groups, apps, or resources potentially affected)
- Timeline of suspicious activity
- Key risk indicators observed
- Recommended immediate investigation or containment steps
```

---

## How To Create This Promptbook In Security Copilot

1. Open Security Copilot and navigate to Promptbooks.
2. Select each prompt step and run them in order, replacing placeholders like {UserDisplayName}, {UserPrincipalName} with actual values.
3. Once validated, select all prompts to include in the promptbook.
4. Enter the promptbook name: "Entra Incident Response Investigation"
5. Add the description: "Investigate security incidents involving compromised accounts, suspicious activities, or unauthorized access."
6. Create the promptbook and verify it appears in your promptbook library.
7. Share with your security team as needed.
