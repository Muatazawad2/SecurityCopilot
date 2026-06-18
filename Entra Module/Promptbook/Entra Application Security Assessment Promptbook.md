# Entra Application Security Assessment

**Developer**: Dr Muataz Awad

**Description**: Assess application security posture and identify risky, over-privileged, or unused applications in your Entra tenant. Review application permissions, service principals, external exposure, credential status, and compliance risks. Use prompts from Entra ID Prompt Samples and Entra ID Protection Prompt Samples to understand app risk and scope. Results may be limited if required audit logs or plugin data are unavailable.

---

## Step 1: Identify Risky Applications

Start by discovering applications flagged as risky or with concerning risk indicators.

**Prompts to use from [Entra ID Protection Prompt Samples](../Sample%20Prompts/Entra%20ID%20Protection%20Prompt%20Samples.md#explore-risky-service-principals):**
- Show me risky apps.
- Are any apps at risk of being malicious or compromised?
- List 5 apps with High Risk Level.
- List the apps with Risk State "Confirmed compromise".
- Show me the details of risky app with ID {ServicePrincipalObjectId}.

---

## Step 2: Explore Service Principals and App Details

Get comprehensive details about the identified apps and their service principals.

**Prompts to use from [Entra ID Protection Prompt Samples](../Sample%20Prompts/Entra%20ID%20Protection%20Prompt%20Samples.md#explore-service-principals-and-applications):**
- Tell me more about these service principals.
- Give me details about service principal with {DisplayName}.
- Give me a list of owners for these apps.
- Tell me more about the application {DisplayName}.

---

## Step 3: Assess Permissions and Privilege Level

Review the permissions granted to each application and identify highly privileged grants.

**Prompts to use from [Entra ID Protection Prompt Samples](../Sample%20Prompts/Entra%20ID%20Protection%20Prompt%20Samples.md#permissions-and-privilege-assessment):**
- Which permissions are granted to the app with ID {ServicePrincipalId}?
- What permissions do the above risky apps have?
- Which permissions granted to this app are highly privileged?

**Also from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#application-credential-management):**
- Which enterprise applications have credentials about to expire?
- Show me service principals with credentials that are expiring soon.

---

## Step 4: Analyze External and Multitenant Exposure

Identify applications with external exposure, multitenant configuration, or cross-tenant access patterns.

**Prompts to use from [Entra ID Protection Prompt Samples](../Sample%20Prompts/Entra%20ID%20Protection%20Prompt%20Samples.md#external-and-multitenant-exposure):**
- Show me apps outside my tenant.
- How many apps are from outside my tenant?

**Also from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#application-credential-management):**
- Which of our apps are stale or unused in the tenant?
- List the unused apps.

---

## Step 5: Identify Unused and Expiring Applications

Flag applications that are no longer actively used or have credentials expiring soon.

**Prompts to use from [Entra ID Protection Prompt Samples](../Sample%20Prompts/Entra%20ID%20Protection%20Prompt%20Samples.md#unused-and-expiring-apps):**
- Show me unused apps.
- How many unused apps do I have?
- Which enterprise applications have credentials about to expire?
- Show me applications with credentials that are expiring soon.

---

## Step 6: Review Application Usage and Sign-ins

Examine how applications are being used and by whom to identify anomalies or unauthorized access.

**Prompts to use from [Entra ID Prompt Samples](../Sample%20Prompts/Entra%20ID%20Prompt%20Samples.md#application-and-authentication-analysis):**
- Show sign-ins to a specific application.
- Show sign-ins without multifactor authentication.

---

## Step 7: Summarize Application Security Posture

Consolidate findings into a comprehensive application security assessment.

**Use this prompt to summarize:**
```
Based on the applications discovered, permissions granted, external exposure, credential status, and usage patterns, provide an application security assessment including:
- Overall app risk posture (Low, Medium, High, or Critical)
- Count of risky, unused, over-privileged, and compliant applications
- Top security concerns and priority remediation items
- Credential management status (expiring or expired credentials)
- External/multitenant exposure risks
- Recommended actions for each identified risk category
```

---

## How To Create This Promptbook In Security Copilot

1. Open Security Copilot and navigate to Promptbooks.
2. Select each prompt step and run them, replacing placeholders like {ServicePrincipalId}, {DisplayName} with actual application identifiers.
3. Once all steps are validated, select all prompts to include in the promptbook.
4. Enter the promptbook name: "Entra Application Security Assessment"
5. Add the description: "Assess application security posture and identify risky, over-privileged, or unused applications."
6. Create the promptbook and verify it appears in your promptbook library.
7. Share with your application security and cloud governance teams.
