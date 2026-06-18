# Entra User Access Audit

**Developer**: Dr Muataz Awad

**Description**: Audit user access and permissions across your Entra tenant. Review individual user profiles, group memberships, role assignments, licensing status, and recent activities. Identify risky users, assess access appropriateness, and flag access inconsistencies. Results depend on available audit logs and user query permissions.

---

1. Get user profile and account status overview

```
Provide a comprehensive profile summary for user {UserPrincipalName}. Include display name, user principal name, account status (enabled/disabled), manager, department, location, cloud vs. on-premises managed status, and any recent account changes.
```

2. Review user licensing and feature access

```
Show licenses and subscription SKUs assigned to this user. Include license assignment date, any disabled plans, and overall license compliance. Identify if the user is unlicensed or missing required licenses for their role.
```

3. Assess user risk status and indicators

```
Determine if this user is currently flagged as risky. Display their risk level, active risk indicators, recent risky sign-ins, risk score trend, and any security recommendations.
```

4. Review user group memberships

```
List up to 100 groups that this user is a member of, prioritizing security-enabled and role-assignable groups. For each group, include group name, type (Distribution, Security, Microsoft 365), membership date, and ownership information.
```

5. Check role assignments and privileged access

```
Display roles assigned to this user. If there are more than 50 role-related assignments, prioritize privileged and admin roles first, then summarize remaining counts. Include:
- Direct role assignments
- Transitive roles inherited through group membership
- Eligible roles managed through PIM
- Any scheduled role activations or pending approvals
```

6. Verify authentication methods and MFA status

```
Show authentication methods registered for this user. Include MFA registration status, authentication methods available (phone, authenticator app, FIDO2, etc.), and whether the user has passwordless sign-in configured.
```

7. Analyze recent user activity and sign-ins

```
Provide a summary of recent activity for this user in the last 30 days including:
- Sign-in frequency and patterns
- Applications accessed
- Geographic locations of sign-ins
- Device types and compliance status
- Any failed sign-in attempts or anomalies
```

8. Check Conditional Access policy applicability

```
Identify which Conditional Access policies apply to this user. For each policy, show the controls enforced (MFA requirement, device compliance, location restrictions, etc.) and any recent policy violations or exceptions granted.
```

9. Summarize access audit findings

```
Provide a comprehensive access audit summary for this user including:
- Current access level (Standard User, Elevated, Admin)
- Appropriateness of access for stated role and department
- Any excessive, dormant, or unexpected permissions
- Risky patterns or anomalies in usage
- Compliance status against access policies
- Recommendations for access adjustments or further investigation
```

---

## How To Create This Promptbook In Security Copilot

1. Start by running step 1 and replacing {UserPrincipalName} with the user account to audit.
2. Run the remaining steps without adding the placeholder again; they refer to this user from step 1 context.
3. Select all prompts to include them in the promptbook.
4. Enter the promptbook name and description.
5. Choose how you want to share the promptbook.
6. Select Create, verify the success message, and open the promptbook from the library.
