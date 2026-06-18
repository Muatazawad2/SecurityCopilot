# Entra Conditional Access Policy Analysis

**Developer**: Dr Muataz Awad

**Description**: Analyze Conditional Access policies across your Entra tenant. Review policy inventory, targeting scope, enforcement requirements, user compliance patterns, and policy effectiveness. Identify gaps in coverage, policy conflicts, and enforcement challenges. Results depend on available policy audit logs and sign-in data.

---

1. Inventory Conditional Access policies by state

```
Start with policy scope {PolicyNameOrScope}. If no exact match is found, list enabled or report-only Conditional Access policies (up to 50 policies) and include:
- Policy name and ID
- Current enforcement state (enabled, disabled, report-only)
- Policies enforcing MFA requirements
- Authentication strength policies
- Total policy count and distribution by control type
```

2. Review policy targeting and user/group scope

```
Analyze which users and groups are targeted by this policy set:
- Policies targeting tenant-wide scopes vs. specific groups
- External user policy coverage
- Administrator-specific policies
- Policies targeting specific applications or service principals
- User populations with no policy coverage
```

3. Assess policy controls and requirements

```
Review the specific controls implemented by this policy set:
- Policies requiring MFA
- Device compliance requirements
- Location and network restrictions
- Client app restrictions (legacy auth blocking)
- Session and sign-in frequency controls
```

4. Analyze policy enforcement and impact

```
Examine the real-world impact of this policy set:
- Sign-in failures caused by policy violations
- Frequency of unsatisfied policy conditions
- Applications most frequently blocked by policies
- User exception and policy bypass patterns
- Impact on user productivity vs. security benefit
```

5. Review device compliance requirements

```
Analyze device-related controls and status for this policy set:
- Policies requiring device compliance
- Device compliance status distribution (compliant vs. non-compliant)
- Devices requiring remediation
- Non-managed devices in the environment
- Mobile device management (MDM) enrollment coverage
```

6. Check authentication and MFA requirements

```
Review authentication and MFA configuration for this policy set:
- Policies requiring MFA
- MFA method requirements
- Authentication strength policies
- Conditional authentication based on risk
- Legacy authentication blocking coverage
```

7. Identify policy gaps and coverage issues

```
Identify areas where coverage in this policy set may be insufficient:
- User populations without policy coverage
- Applications without specific policy controls
- Risk scenarios not covered by policies
- External access protection gaps
- Legacy system access protection gaps
```

8. Analyze policy conflicts and inefficiencies

```
Review this policy set for conflicts and inefficiencies:
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

1. Start by running step 1 and replacing {PolicyNameOrScope} with the policy name, control theme, or scope to investigate.
2. Run the remaining steps without adding another placeholder; they refer to this policy set from step 1 context.
3. Select all prompts to include them in the promptbook.
4. Enter the promptbook name and description.
5. Choose how you want to share the promptbook.
6. Select Create, verify the success message, and open the promptbook from the library.
