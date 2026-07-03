# Application Threat Investigation

**Developer**: Dr Muataz Awad

**Description**: A structured, multi-step promptbook for investigating application-based threats including malicious OAuth app consent grants and compromised or malicious applications, using Microsoft playbooks indexed in Azure AI Search. This workflow guides analysts through identifying malicious applications, auditing permissions, revoking access, and hardening the application environment — drawing from the Microsoft App Consent Grant and Compromised and Malicious Applications investigation playbooks. Results may be limited if the application threat playbooks are not present in the connected index or the Azure AI Search plugin is not configured.

---

1. Identify the application threat type and initial indicators

```
Search Azure AI Search for the indicators and detection signals associated with malicious app consent grants and compromised applications. What alerts, audit log events, or behavioral patterns indicate that a malicious application may have been granted OAuth consent or that a legitimate application may have been compromised?
```

2. Retrieve the app consent grant investigation steps

```
Using Azure AI Search, find the investigation steps for an app consent grant attack. How should analysts identify which users granted consent, what permissions were granted, which application received consent, and what data or actions the application has accessed since the consent was granted?
```

3. Audit application permissions and consent grants

```
Search Azure AI Search for the procedures to audit application permissions and OAuth consent grants in Microsoft Entra ID. What queries, portal steps, or PowerShell commands are described in the playbooks for enumerating all consent grants, identifying over-privileged applications, and finding applications with suspicious permission scopes?
```

4. Investigate a compromised or malicious application

```
Using Azure AI Search, find the investigation workflow for a compromised or malicious application. What steps should analysts take to determine the scope of access, identify what actions the application performed on behalf of users, and assess whether sensitive data was accessed or exfiltrated?
```

5. Look up procedures for revoking malicious app access

```
Search Azure AI Search for the procedures to revoke access granted to a malicious or compromised application. What Microsoft Entra ID steps — including consent revocation, service principal disablement, and token invalidation — are required to stop the application from accessing organizational resources?
```

6. Retrieve post-compromise investigation for affected users

```
Using Azure AI Search, find the steps to investigate user accounts that granted consent to a malicious application or were accessed by a compromised application. What actions, sign-ins, mailbox activities, or data accesses should be reviewed to determine the full impact on affected users?
```

7. Find notification and communication requirements

```
Search Azure AI Search for the notification and communication requirements triggered by a malicious app consent or compromised application incident. Who must be notified, what information is required, and are there any regulatory disclosure obligations associated with unauthorized application access to organizational data?
```

8. Retrieve hardening and prevention recommendations

```
Using Azure AI Search, find the hardening and prevention recommendations from the Microsoft application threat playbooks. What Conditional Access policies, app governance controls, user consent settings, admin consent workflow configurations, and monitoring rules does Microsoft recommend to prevent malicious app consent and application compromise?
```

9. Generate a structured application threat response plan

```
Based on all information retrieved from Azure AI Search in this session, produce a structured application threat response plan that includes:
- Threat type identified (app consent grant / compromised app / both)
- Affected applications and permission scope
- Affected users and data access summary
- Revocation steps completed (consent, tokens, service principal)
- Post-compromise investigation findings per affected user
- Notification and disclosure obligations
- Hardening recommendations to prevent recurrence
Format the output as a structured incident response report suitable for security operations and compliance review.
```

<!-- Repository maintenance marker -->
