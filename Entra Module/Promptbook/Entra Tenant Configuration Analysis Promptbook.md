# Entra Tenant Configuration Analysis

**Developer**: Dr Muataz Awad

**Description**: Analyze your Entra tenant configuration and provide comprehensive information about tenant identity, size, licensing, domains, authentication methods, and overall health. Use prompts from Entra ID Prompt Samples to gather tenant-level insights. Results provide an operational overview of your tenant's identity infrastructure. Results may be limited based on query permissions and available audit data.

---

## Step 1: Identify Tenant Configuration

Start with basic tenant identification and configuration details.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#tenants):**
- What is my tenant's display name?
- What is my tenant ID?
- Can users in my tenant create new tenants?
- What are all the active licenses assigned to my tenant?
- Who is the technical contact for my tenant?

---

## Step 2: Analyze User Population

Review user count, organization structure, and departmental breakdown.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#user-information-and-details):**
- Give the member count of each department.
- Show users by mail nickname.

**Also from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#user-filtering-and-organization):**
- List users without assigned licenses.
- Show users with account disabled.
- Are there any users with {Specific license}?

---

## Step 3: Review Group and Organizational Structure

Examine the group taxonomy and organizational hierarchy in your tenant.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#group-organization-and-governance):**
- Show the count of groups categorized by group type.
- List the number of groups under each of the group types.
- How many groups exist for each group type?
- Count the total ownerless groups in my tenant.

---

## Step 4: Verify Domains and DNS Configuration

Review all registered domains and their verification status.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#domains):**
- List details of {DomainName}.
- Show me DNS verification records of {DomainName}.
- What is my initial domain name?

---

## Step 5: Review License Utilization

Assess Microsoft Entra licensing and feature utilization across your tenant.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#licenses):**
- How many Microsoft Entra P1/P2 licenses do I have?
- Count of P1/P2 Microsoft Entra licenses.
- Number of Microsoft Entra ID P1/P2 licenses.
- What is the usage of Microsoft Entra P1/P2 license?
- Show me P1/P2 feature utilization.
- Provide Microsoft Entra P1/P2 license usage details.

---

## Step 6: Check Authentication Methods and Security Configuration

Review authentication methods, MFA adoption, and security method enablement.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#authentication-method-configuration):**
- What authentication methods are enabled in my tenant?
- Is Microsoft Authenticator enabled in my tenant? For who?
- Is registration campaign enabled in my tenant? For who?
- Is system preferred authentication enabled in my tenant? For who?
- Is report suspicious activity enabled in my tenant? For who?

---

## Step 7: Monitor Service Level Agreement and Availability

Check your SLA status and authentication availability metrics.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#service-level-agreement):**
- What is my SLA for Microsoft Entra authentication?
- What is my Microsoft Entra SLA?
- What is the SLA of Microsoft Entra authentication?
- Show me my tenant's authentication availability.
- Has my tenant had an SLA breach in the last "X" months?

---

## Step 8: Review Health and Operational Alerts

Check for active health monitoring alerts and operational issues.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#health-alert-monitoring):**
- What health alerts do I have in my tenant?
- List all active health monitoring alerts.
- What are my recent health monitoring alerts?
- What users are impacted according to the active health monitoring alerts?

---

## Step 9: Summarize Tenant Configuration and Health Status

Consolidate all findings into a comprehensive tenant analysis report.

**Use this prompt to summarize:**
```
Based on the tenant configuration analysis, provide a comprehensive tenant report including:
- Tenant identification (name, ID, technical contact)
- User population metrics (total count, disabled accounts, unlicensed users)
- Group and organizational structure (group types, ownerless groups)
- Licensed features and utilization (Entra P1/P2 usage)
- Authentication posture (enabled methods, MFA adoption, registration campaign status)
- Domain configuration (registered domains, verification status)
- Overall health status (SLA compliance, active alerts, impacted users)
- Key operational recommendations for tenant optimization
```

---

## How To Create This Promptbook In Security Copilot

1. Open Security Copilot and navigate to Promptbooks.
2. Select each prompt step and validate output, replacing placeholders like {DomainName}, {Specific license} with your actual values.
3. Once all steps are validated, select all prompts to include in the promptbook.
4. Enter the promptbook name: "Entra Tenant Configuration Analysis"
5. Add the description: "Analyze your Entra tenant configuration and provide comprehensive information about tenant identity, size, licensing, and health."
6. Create the promptbook and verify it appears in your promptbook library.
7. Share with your identity and access governance stakeholders.
