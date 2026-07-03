# App Consent Grant Investigation

**Developer**: Dr Muataz Awad

**Description**: A structured, multi-step promptbook for investigating malicious OAuth app consent grant attacks using the Microsoft App Consent Grant Investigation Playbook indexed in Azure AI Search. This workflow guides analysts through identifying the malicious application, determining which users granted consent and what permissions were granted, assessing data access, revoking the consent, and hardening consent controls. Results may be limited if the app consent grant playbook is not present in the connected index or the Azure AI Search plugin is not configured.

---

1. Identify the malicious application and confirm the consent grant attack

```
Search Azure AI Search for the indicators and detection signals that confirm a malicious app consent grant attack. What Microsoft Entra ID alerts, audit log events, and Defender XDR signals are described in the app consent grant playbook as evidence that users have been tricked into granting OAuth permissions to a malicious application?
```

2. Identify the application that received consent

```
Using Azure AI Search, find the investigation steps for identifying the malicious application involved in the consent grant. How should analysts locate the application in Microsoft Entra ID, determine whether it is a first-party or third-party application, identify the publisher, and assess whether the application is verified or unverified?
```

3. Determine which users granted consent and what permissions were granted

```
Search Azure AI Search for the steps to identify all users who granted consent to the malicious application and the specific permissions (OAuth scopes) they granted. What Entra ID audit logs, PowerShell queries, or portal steps are described for enumerating all consent grants and the permission scope for each user?
```

4. Assess what the application accessed on behalf of users

```
Using Azure AI Search, find the investigation steps for determining what actions the malicious application performed on behalf of consenting users. What audit logs, sign-in logs, and API activity records should be reviewed to identify data accessed, emails read, files downloaded, and actions taken using the granted permissions?
```

5. Revoke the consent grant and disable the application

```
Search Azure AI Search for the procedures to revoke the OAuth consent grant and disable the malicious application. What Microsoft Entra ID steps — including revoking user consent, removing admin consent, disabling the service principal, and invalidating tokens issued to the application — are described in the playbook?
```

6. Invalidate tokens and terminate active application sessions

```
Using Azure AI Search, find the steps to invalidate all tokens issued to the malicious application and terminate any active sessions. How should analysts ensure that the application can no longer access organizational data even after the consent is revoked?
```

7. Investigate affected users for post-compromise activity

```
Search Azure AI Search for the steps to investigate each user who granted consent for signs of broader compromise. What should analysts check for — including suspicious sign-ins, inbox rule changes, forwarding rules, shared mailbox access, and data exfiltration — that indicate the application was used to compromise user accounts further?
```

8. Retrieve hardening and prevention recommendations

```
Using Azure AI Search, find the hardening and prevention recommendations from the Microsoft app consent grant playbook. What user consent settings, admin consent workflow configurations, app governance policies, Conditional Access controls, and monitoring rules does Microsoft recommend to prevent malicious app consent grant attacks?
```

9. Generate an app consent grant investigation report

```
Based on all information retrieved from Azure AI Search in this session, produce a structured app consent grant investigation report that includes:
- Malicious application identified: name, publisher, verification status
- Users who granted consent and permissions scope per user
- Data and actions accessed by the application
- Revocation steps completed: consent revoked, service principal disabled, tokens invalidated
- Post-compromise findings per affected user
- Notification and disclosure obligations
- Hardening recommendations to prevent recurrence
Format as a structured incident investigation report for SOC records, compliance review, and management.
```

<!-- Repository maintenance marker -->
