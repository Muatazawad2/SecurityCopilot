# Entra Access Control & Compliance Audit

**Developer**: Dr Muataz Awad

**Description**: Audit access governance, privileged access management, and device compliance across your Entra tenant. Review PIM activities, access review campaigns, device compliance status, and authentication method adoption. Assess alignment with compliance standards and identity governance best practices. Results depend on available audit logs and policy configuration data.

---

1. Review Privileged Identity Management (PIM) configuration

```
Provide an overview of Privileged Identity Management (PIM) configuration in my tenant including:
- List of all privileged roles managed by PIM
- Number of active vs. eligible role assignments
- PIM approval workflow configuration
- Just-in-time access activation patterns
- PIM security rules and constraints (time limits, MFA requirements)
```

2. Analyze PIM activation history and activity

```
Review PIM activation patterns and privileged access activity:
- Show PIM activation history for the last 30 days
- Which users activated privileged roles recently
- How many users have eligible vs. active role assignments
- Privileged role activation approval rates
- Users with frequent or unusual role activations
- Pending PIM activation approvals
```

3. Review access review campaigns and completion status

```
Examine access review governance and completion:
- List all active and pending access review campaigns
- Access review completion rates and timelines
- Groups and resources currently under review
- Access review timeline and deadline status
- Recommendations for removal from access reviews
- Outstanding access review decisions or approvals
```

4. Assess device compliance and management posture

```
Review device compliance and management coverage:
- Total device count and compliance distribution
- Number of compliant vs. non-compliant devices
- Devices requiring remediation
- Non-managed devices in the environment
- Device operating systems and risk profiles
- Mobile device management (MDM) enrollment rates
```

5. Review authentication method adoption and configuration

```
Examine authentication method policies and adoption:
- Enabled authentication methods in the tenant
- MFA method registration rates by type (Authenticator app, FIDO2, phone, etc.)
- System preferred authentication configuration
- Passwordless sign-in adoption rates
- Authentication method enforcement for privileged users
- Registration campaign status and effectiveness
```

6. Summarize access governance and compliance posture

```
Provide a comprehensive access governance and compliance audit including:
- PIM maturity level and privileged access risk score
- Active vs. eligible role assignments distribution
- Access review completion rates and remediation status
- Device compliance and management coverage
- Authentication method adoption and MFA coverage
- Key compliance gaps (PIM, access reviews, device management, MFA)
- Recommendations for governance improvements
- Priority actions to enhance access control compliance
- Timeline for next governance audit cycle
```

---

## How To Create This Promptbook In Security Copilot

1. Start by using each prompt directly to validate the output quality.
2. Select all prompts to include them in the promptbook.
3. Enter the promptbook name and description.
4. Choose how you want to share the promptbook.
5. Select Create, verify the success message, and open the promptbook from the library.
