# Entra Conditional Access Policy Analysis

**Developer**: Dr Muataz Awad

**Description**: Analyze Conditional Access policies across your Entra tenant. Review policy inventory, targeting scope, enforcement requirements, user compliance patterns, and policy effectiveness. Identify gaps in coverage, policy conflicts, and enforcement challenges. Results depend on available policy audit logs and sign-in data.

---

1. Inventory Conditional Access policies by state

```
List Conditional Access policies that are enabled or report-only (up to 100 policies) and include:
- Policy name and ID
- Current enforcement state (enabled, disabled, report-only)
- Policies enforcing MFA requirements
- Authentication strength policies
- Total policy count and distribution by control type
```

2. Review policy targeting and user/group scope

```
Analyze which users and groups are targeted by Conditional Access policies:
- Policies targeting tenant-wide scopes vs. specific groups
- External user policy coverage
- Administrator-specific policies
- Policies targeting specific applications or service principals
- User populations with no policy coverage
```

3. Assess policy controls and requirements

```
Review the specific controls implemented by each policy:
- Policies requiring MFA
- Device compliance requirements
- Location and network restrictions
- Client app restrictions (legacy auth blocking)
- Session and sign-in frequency controls
```

4. Analyze policy enforcement and impact

```
Examine the real-world impact of policy enforcement:
- Sign-in failures caused by policy violations
- Frequency of unsatisfied policy conditions
- Applications most frequently blocked by policies
- User exception and policy bypass patterns
- Impact on user productivity vs. security benefit
```

5. Review device compliance requirements

```
Analyze device-related policy controls and status:
- Policies requiring device compliance
- Device compliance status distribution (compliant vs. non-compliant)
- Devices requiring remediation
- Non-managed devices in the environment
- Mobile device management (MDM) enrollment coverage
```

6. Check authentication and MFA requirements

```
Review authentication and MFA policy configuration:
- Policies requiring MFA
- MFA method requirements
- Authentication strength policies
- Conditional authentication based on risk
- Legacy authentication blocking coverage
```

7. Identify policy gaps and coverage issues

```
Identify areas where Conditional Access coverage may be insufficient:
- User populations without policy coverage
- Applications without specific policy controls
- Risk scenarios not covered by policies
- External access protection gaps
- Legacy system access protection gaps
```

8. Analyze policy conflicts and inefficiencies

```
Review for policy conflicts and inefficiencies:
- Overlapping or redundant policies
- Policies with low enforcement rate or exceptions
- Policies that appear to have minimal impact
- Report-only policies pending enforcement decision
- Policies requiring review or tuning
```

9. Export and summarize policy inventory

```
Provide a complete Conditional Access policy summary:
- Total policy count (enabled, disabled, report-only)
- Policy count by control type (MFA, device, location, legacy auth)
- User/group coverage metrics
- Policy effectiveness and enforcement metrics
- Device compliance adoption rates
- Authentication method adoption
- Top 10 recommended new policies to close gaps
```

10. Provide Conditional Access optimization recommendations

```
Deliver Conditional Access recommendations and optimization plan:
- High-priority policy improvements
- Recommended new policies for identified gaps
- Policy consolidation or deduplication opportunities
- Report-only to enforcement transition timeline
- Device compliance and MFA adoption targets
- Recommended policy review schedule
- Implementation roadmap with priority ranking
```

---

## How To Create This Promptbook In Security Copilot

1. Start by using each prompt directly to validate the output quality.
2. Select all prompts to include them in the promptbook.
3. Enter the promptbook name and description.
4. Choose how you want to share the promptbook.
5. Select Create, verify the success message, and open the promptbook from the library.
