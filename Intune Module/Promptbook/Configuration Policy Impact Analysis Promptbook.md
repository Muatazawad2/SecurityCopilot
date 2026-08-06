# Configuration Policy Impact Analysis

**Description**: Analyze the current and proposed impact of a Microsoft Intune configuration or endpoint security policy. Review settings, assignments, deployment health, overlap, user and security effects, and rollout controls before recommending whether a change should proceed. This promptbook does not edit or assign policies.

## Required Input

- `{PolicyName}`: Existing Intune policy name

## Optional Input

- `{ProposedChange}`: Exact setting, value, assignment, or scope change under review
- `{TargetGroup}`: Intended Microsoft Entra user or device group
- `{TicketId}`: Change, incident, or review record identifier

## Prerequisites

- Microsoft Security Copilot and the Microsoft Intune source are enabled.
- The operator can view the policy, settings, assignments, deployment status, and affected objects.
- The proposed change is described precisely enough to compare with the current configuration.

Run the prompts in order in one session. When a proposed value is not present in Intune, treat it as user-supplied change context rather than observed tenant configuration.

---

1. Identify the policy and current state

```text
Using Microsoft Intune data, identify {PolicyName}. Report the policy type, platform, technology or template, creation and modification times when available, current assignments, and deployment summary. If multiple policies match, list them and stop for clarification. Clearly distinguish observed policy data from user-supplied context.
```

2. Summarize settings and intended behavior

```text
Summarize every configured setting in {PolicyName}. For each setting, report its current value, intended behavior, relevant security purpose, and likely user or device effect. Identify settings whose behavior or default depends on platform version, licensing, prerequisites, or another service. Label any interpretation that is not directly represented in Intune.
```

3. Analyze assignments and effective scope

```text
Analyze the assignments for {PolicyName}, including included and excluded groups, user versus device targeting, assignment filters, and scope tags when available. If {TargetGroup} is provided, determine whether it is currently included, excluded, or outside scope. Identify nested membership, filter, or targeting questions that require validation before estimating impact.
```

4. Review deployment health

```text
Review available deployment status for {PolicyName}. Summarize succeeded, pending, error, conflict, not applicable, and unknown results by user and device where available. Identify recurring status details, affected platforms or versions, and stale reporting. Do not interpret a successful assignment as proof that every setting is effective on the endpoint.
```

5. Identify overlap and potential conflicts

```text
Find other Intune policies that configure the same or related settings as {PolicyName}. Compare their values, platforms, technologies, and target scope. Classify each overlap as aligned, potentially conflicting, demonstrably conflicting, or requiring validation. Do not claim an effective-setting conflict solely because two policies contain the same setting.
```

6. Assess current user, operational, and security impact

```text
Assess the current impact of {PolicyName}. Cover security benefit, affected users and devices, workflow or usability changes, support burden, compatibility considerations, and the risk of removing or weakening the policy. Tie conclusions to observed settings and scope, and state where endpoint testing or authoritative Microsoft documentation is still required.
```

7. Analyze the proposed change

```text
Analyze this proposed change to {PolicyName}: {ProposedChange}. Compare it with the current policy and explain the expected security, user, operational, compatibility, and deployment effects. Estimate the affected scope only from available assignments and membership evidence. Identify prerequisites, likely conflicts, assumptions, and unanswered questions. If no proposed change is supplied, identify the highest-value policy improvements supported by current evidence without presenting them as approved changes.
```

8. Design rollout, rollback, and validation controls

```text
Create a controlled implementation plan for the proposed change to {PolicyName}. Define a representative pilot group, exclusions, prerequisites, approval gates, communication, deployment stages, monitoring metrics, success and stop criteria, rollback steps, and post-change validation. Protect break-glass, shared, kiosk, privileged, and other special-purpose devices when relevant. Do not edit, assign, or deploy the policy.
```

9. Produce the policy impact assessment

```text
Create a final configuration policy impact assessment for {PolicyName} and ticket {TicketId} when provided. Include:
- Policy identity, purpose, platform, and current settings
- Assignments and estimated effective scope
- Deployment health and reporting freshness
- Overlapping policies and verified or potential conflicts
- Current security, user, and operational impact
- Proposed change and expected impact
- Assumptions, dependencies, and evidence gaps
- Pilot, rollout, rollback, and validation controls
- Recommendation: Proceed, Proceed with conditions, Hold, Reject, or Insufficient evidence

Justify the recommendation with observed evidence. Do not claim that the proposed change has been approved or deployed.
```

---

## Completion Criteria

- [ ] Unique policy and current configuration confirmed
- [ ] Assignments and affected scope reviewed
- [ ] Deployment health assessed
- [ ] Overlap and conflicts analyzed
- [ ] Security, user, and operational impacts documented
- [ ] Proposed change compared with current state
- [ ] Pilot, rollback, and validation controls defined
- [ ] Authorized change owner reviewed the recommendation

## Official References

- [Security Copilot in Intune features overview](https://learn.microsoft.com/en-us/intune/copilot/)
- [Monitor device configuration policies in Intune](https://learn.microsoft.com/en-us/intune/device-configuration/monitor-device-profile)
- [Assign device profiles in Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-configuration/assign-device-profile)

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
