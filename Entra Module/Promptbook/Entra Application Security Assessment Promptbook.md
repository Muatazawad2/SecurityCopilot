# Entra Application Security Assessment

**Developer**: Dr Muataz Awad

**Description**: Assess application security posture and identify risky, over-privileged, or unused applications in your Entra tenant. Review application permissions, service principals, external exposure, credential status, and compliance risks. Results may be limited if required audit logs or plugin data are unavailable.

---

1. Identify and list high-risk applications

```
Show me up to 50 applications in my tenant flagged as risky in the last 30 days, prioritized by High/Critical risk level. For each app, display the application name, ID, risk level, risk state (e.g., confirmed compromise), number of owners, and current enforcement status.
```

2. Analyze application permissions and privilege level

```
For the risky applications identified, analyze their permissions including:
- API permissions granted (application and delegated)
- Highly privileged permissions
- Admin consent status
- Permission usage patterns
- Any permissions that exceed the application's legitimate business need
```

3. Review service principals and application ownership

```
Provide details for up to 50 service principals that are risky, highly privileged, or recently active (last 30 days), including:
- Service principal name and display name
- Application ID and object ID
- Ownership and creation date
- Sign-in activity frequency
- Configuration risk factors
```

4. Identify external and multitenant application exposure

```
Show up to 50 applications configured for external or multitenant access, prioritized by broad OAuth scope or high privilege, including:
- Applications available to other tenants
- External API access patterns
- Cross-tenant resource access
- Applications with broad OAuth scopes
- Unsupported or non-compliant configurations
```

5. Assess application credential status and expiration

```
Review application credentials that are expired or expiring in the next 30 days (up to 100 records), including:
- Certificate and secret status
- Expiration dates (current, expiring, and expired)
- Credentials without expiration configured
- Recent credential additions or modifications
- Applications with high credential churn
```

6. Identify unused and stale applications

```
List up to 50 unused or stale applications in my tenant, prioritized by high privilege and no sign-in activity in the last 90 days, including:
- Applications with no sign-in activity in the last 90 days
- Service principals created but never used
- Legacy or deprecated applications
- Applications with low usage frequency
- Recommendations for deprovisioning
```

7. Review application sign-in activity and usage patterns

```
Analyze application sign-in activity and usage patterns:
- Most used applications in the tenant
- Applications with unusual sign-in times or locations
- Applications with authentication failures
- Sign-ins without MFA to sensitive applications
- Applications accessed by external or guest users
```

8. Check application compliance and security posture

```
Assess application compliance and security including:
- Multi-tenant application risks
- Applications requesting excessive permissions
- Non-Microsoft applications with high access
- Applications flagged in security recommendations
- Applications with suspicious or anomalous behavior
```

9. Summarize application security assessment

```
Provide a comprehensive application security assessment including:
- Total application count (risky, unused, compliant)
- Top security risks and priority remediation items
- Credential management summary (expiring/expired credentials)
- External and multitenant exposure assessment
- Permission risk score and over-privileged applications
- Recommended actions for risk remediation
- Applications recommended for immediate attention or deprovisioning
```

---

## How To Create This Promptbook In Security Copilot

1. Start by using each prompt directly to validate the output quality.
2. Select all prompts to include them in the promptbook.
3. Enter the promptbook name and description.
4. Choose how you want to share the promptbook.
5. Select Create, verify the success message, and open the promptbook from the library.
