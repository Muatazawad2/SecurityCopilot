# Entra Access Control & Compliance Audit

**Developer**: Dr Muataz Awad

**Description**: Audit access control policies and compliance posture across your Entra tenant. Review Conditional Access policies, privileged access management activities, access review status, and device compliance. Assess alignment with security standards and identify gaps in policy enforcement. Results depend on available policy logs and audit trail data.

---

1. Inventory all Conditional Access policies

```
List all Conditional Access policies in my tenant including:
- Policy name and ID
- Current enforcement state (enabled/disabled/report-only)
- Policies enforcing MFA requirements
- Authentication strength policies
- Number of policies by control type
```

2. Analyze Conditional Access policy targeting

```
Review Conditional Access policy targeting and scope:
- Which users and groups are targeted by policies
- Policy coverage by user role or department
- External user policy coverage
- Application-specific policy targeting
- Risk areas with low or no policy coverage
```

3. Assess Conditional Access requirements and controls

```
Analyze Conditional Access policy controls:
- Policies requiring MFA
- Device compliance requirements
- Legacy authentication blocking policies
- Location-based restrictions
- Session and sign-in frequency controls
```

4. Review Conditional Access enforcement impact

```
Analyze the real-world impact of Conditional Access policies:
- Sign-in failures caused by policy violations
- Unsatisfied policy patterns
- High exception rates or policy bypasses
- User impact metrics from policy enforcement
- Applications most frequently blocked by policies
```

5. Examine PIM and privileged access governance

```
Review Privileged Identity Management (PIM) configuration and activity:
- Eligible vs. active role assignments
- PIM activation history and approval workflow
- Just-in-time access patterns
- Time-bound role assignments
- Admin role holders and their activity
```

6. Review access review campaigns and status

```
Assess access review campaigns:
- Active and pending access review campaigns
- Access review completion rates and timelines
- Compliance with access review deadlines
- Resources and groups under review
- Access removal recommendations from reviews
```

7. Assess device compliance and management

```
Review device compliance posture:
- Total device count and compliance distribution
- Non-compliant devices requiring remediation
- Devices not under management
- Device operating systems and risk profiles
- Mobile device management (MDM) enrollment status
```

8. Check authentication method policies and adoption

```
Review authentication method configuration and adoption:
- Enabled authentication methods in the tenant
- MFA method registration rates (Authenticator, FIDO2, phone, etc.)
- System preferred authentication configuration
- Passwordless sign-in adoption
- Authentication method enforcement for privileged users
```

9. Summarize access control and compliance posture

```
Provide a comprehensive access control and compliance audit including:
- Conditional Access policy posture (coverage, enforcement, effectiveness)
- PIM governance maturity and privileged access risk
- Access review compliance and remediation rates
- Device compliance and management coverage
- Authentication method adoption and MFA coverage
- Key compliance gaps and priority remediation items
- Recommended policy adjustments and governance improvements
- Timeline for next audit cycle
```

---

## How To Create This Promptbook In Security Copilot

1. Start by using each prompt directly to validate the output quality.
2. Select all prompts to include them in the promptbook.
3. Enter the promptbook name and description.
4. Choose how you want to share the promptbook.
5. Select Create, verify the success message, and open the promptbook from the library.
