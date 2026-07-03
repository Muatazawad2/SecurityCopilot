# Compromised and Malicious Application Investigation

**Developer**: Dr Muataz Awad

**Description**: A structured, multi-step promptbook for investigating compromised or malicious applications using the Microsoft Compromised and Malicious Applications Investigation Playbook indexed in Azure AI Search. This workflow guides analysts through identifying the compromised or malicious application, determining its scope of access, analysing its activity, disabling it, remediating affected users and workloads, and hardening the application environment. Results may be limited if the compromised and malicious applications playbook is not present in the connected index or the Azure AI Search plugin is not configured.

---

1. Identify the compromised or malicious application and classify the threat

```
Search Azure AI Search for the indicators and classification criteria described in the Microsoft compromised and malicious applications playbook. How should analysts determine whether an application is malicious (purpose-built for attack) versus compromised (legitimate app taken over by an attacker), and what are the key signals and alert types associated with each scenario?
```

2. Determine the application's identity and permissions scope

```
Using Azure AI Search, find the investigation steps for analysing the application's identity, registration details, and permissions. How should analysts enumerate the application's API permissions, delegated permissions, OAuth scopes, service principal properties, and certificate/secret configuration to understand its potential access scope?
```

3. Assess the application's activity and actions taken

```
Search Azure AI Search for the steps to investigate what actions the compromised or malicious application has taken. What audit logs, sign-in logs, and API activity records should be reviewed to identify which users and workloads were accessed, what data was read or modified, and what operations were performed using the application's credentials or permissions?
```

4. Identify users and workloads affected by the application

```
Using Azure AI Search, find the investigation steps for scoping all users and workloads that have authenticated to or been accessed by the compromised or malicious application. What queries and investigation methods are described for identifying all service accounts, user accounts, and automated workflows that used or were affected by the application?
```

5. Disable and isolate the compromised application

```
Search Azure AI Search for the procedures to disable and isolate a compromised or malicious application. What Microsoft Entra ID steps — including disabling the service principal, rotating or revoking credentials, removing certificates and secrets, and blocking API access — are described in the playbook for stopping the application from accessing organizational resources?
```

6. Revoke tokens and terminate active sessions

```
Using Azure AI Search, find the steps to revoke all tokens issued to the compromised or malicious application and terminate any active sessions. How should analysts ensure that the application can no longer authenticate or access data after it has been disabled?
```

7. Investigate affected users for post-compromise activity

```
Search Azure AI Search for the investigation steps for each user or workload affected by the compromised or malicious application. What should analysts check for — including suspicious data access, privilege escalation, configuration changes, new app registrations, and persistence mechanisms — that indicate the application was used to conduct further malicious activity?
```

8. Retrieve notification and communication requirements

```
Using Azure AI Search, find the notification and communication requirements triggered by a compromised or malicious application incident. Who must be notified internally and externally, what regulatory disclosure obligations may apply, and what information must be provided to affected users and stakeholders?
```

9. Retrieve hardening and prevention recommendations

```
Using Azure AI Search, find the hardening and prevention recommendations from the Microsoft compromised and malicious applications playbook. What application lifecycle management controls, credential rotation policies, permission reviews, app governance configurations, and monitoring rules does Microsoft recommend to detect and prevent application compromise?
```

10. Generate a compromised application investigation report

```
Based on all information retrieved from Azure AI Search in this session, produce a structured compromised application investigation report that includes:
- Application classification: malicious vs compromised, evidence basis
- Application identity: name, registration details, permissions scope
- Activity summary: users and workloads accessed, data read or modified, operations performed
- Affected scope: all users, service accounts, and workloads impacted
- Remediation actions: service principal disabled, credentials revoked, tokens invalidated
- Post-compromise findings per affected user and workload
- Notification and disclosure obligations
- Hardening recommendations to prevent recurrence
Format as a structured incident investigation report for SOC records, compliance review, and management.
```

<!-- Repository maintenance marker -->
