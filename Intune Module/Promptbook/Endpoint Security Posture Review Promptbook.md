# Endpoint Security Posture Review

**Description**: Review endpoint security posture using Microsoft Intune evidence. Establish the managed-device scope, evaluate compliance and deployed security controls, identify stale or missing coverage, prioritize exposed cohorts, and produce a phased remediation roadmap. This promptbook does not change policies, groups, or devices.

## Required Input

- `{Platform}`: Platform in scope, such as Windows, macOS, Android, or iOS/iPadOS
- `{ReviewScope}`: Tenant, group, department, device cohort, or other authorized scope

## Optional Input

- `{NumberOfDays}`: Freshness and trend window; default to 30 when omitted
- `{TargetGroup}`: Microsoft Entra group used to define or validate the scope
- `{TicketId}`: Audit, assessment, or change record identifier

## Prerequisites

- Microsoft Security Copilot and the Microsoft Intune source are enabled.
- The operator has access to the devices, policies, compliance results, and assignments in scope.
- Enable and authorize other sources, such as Microsoft Defender, only when their evidence is required; identify the source of every finding.

Run the prompts in order in one session. This is an Intune control-coverage review, not a substitute for vulnerability scanning, penetration testing, or a complete security assessment.

---

1. Establish scope and inventory quality

```text
Using Microsoft Intune data, define the endpoint security posture review for {Platform} within {ReviewScope}. If {TargetGroup} is supplied, validate its visible user and device membership. Summarize managed-device count, ownership, operating system versions, management state, compliance state, and last check-in distribution. Use {NumberOfDays} days as the freshness window, defaulting to 30. Identify duplicate, stale, unmanaged, or out-of-scope records when evidence is available.
```

2. Evaluate compliance posture

```text
Summarize compliance posture for the in-scope {Platform} devices. Report compliant, noncompliant, in-grace-period, error, conflict, and unknown states when available. Identify the most common failed controls and affected cohorts, and distinguish active noncompliance from stale reporting. Include policy names and evaluation timestamps where available.
```

3. Map deployed endpoint security controls

```text
Map the Intune endpoint security and configuration policies assigned to the review scope. For controls applicable to {Platform}, cover antivirus or antimalware, firewall, disk encryption, attack surface reduction, endpoint detection and response onboarding, account protection, application control, security baselines, and update controls when available. For each control family, report the policy, target scope, deployment state, and evidence limitations. Mark unsupported or unlicensed controls as not assessed rather than absent.
```

4. Assess control coverage and deployment health

```text
For each applicable control family identified in this session, assess coverage across the in-scope devices. Identify devices or groups with no visible assignment, failed deployment, conflict, pending state, unsupported operating system, exclusion, or stale check-in. Separate a missing policy assignment from a policy assigned through another management technology or a control whose endpoint effectiveness has not been verified.
```

5. Review operating system and update exposure

```text
Review operating system and update posture for the in-scope {Platform} devices using available Intune data. Identify old operating system versions, devices needing updates, prolonged restart or deployment states when available, and devices that have not checked in within {NumberOfDays} days. Do not infer a specific vulnerability or exploitability unless an authorized vulnerability source provides that evidence.
```

6. Review exceptions and administrative exposure

```text
Review exclusions, assignment filters, special-purpose groups, and Intune RBAC information relevant to {ReviewScope} when visible. Identify exceptions that reduce endpoint security coverage, broad or unclear exclusions, and stale exception cohorts. If Endpoint Privilege Management data is available, summarize pending or high-impact elevation request patterns without approving or denying requests. Distinguish approved business exceptions from unexplained gaps.
```

7. Prioritize posture risks

```text
Create a prioritized risk register from the confirmed findings. For each gap, include affected control, cohort size when available, exposure, business or user impact, evidence freshness, compensating controls when known, confidence, and priority as Critical, High, Medium, or Low. Rank combinations of missing controls, noncompliance, stale management, and unsupported operating systems above isolated reporting issues when the evidence supports that ranking.
```

8. Build a phased remediation roadmap

```text
Create a phased endpoint security remediation roadmap for {ReviewScope}. Separate immediate evidence-validation tasks, quick configuration corrections, pilot policy changes, broad rollout, exception review, and long-term governance improvements. For each action, identify owner, prerequisites, affected scope, approval gate, user impact, success metric, rollback consideration, and validation source. Do not deploy policies, change groups, approve elevation, or initiate remote actions.
```

9. Produce the posture assessment report

```text
Create a final endpoint security posture assessment for {Platform}, {ReviewScope}, and ticket {TicketId} when provided. Include:
- Scope, inventory, assumptions, and data freshness
- Compliance posture and common failed controls
- Endpoint security control coverage by family
- Deployment failures, conflicts, exclusions, and stale devices
- Operating system and update exposure
- Prioritized risk register
- Compensating controls and accepted exceptions when evidenced
- Phased remediation roadmap with owners and metrics
- Residual risk and evidence gaps
- Overall posture rating: Strong, Adequate, Needs improvement, High risk, or Insufficient evidence

Explain the rating using observed Intune evidence, identify any findings sourced elsewhere, and do not state that remediation has occurred without validation results.
```

---

## Completion Criteria

- [ ] Scope and inventory freshness confirmed
- [ ] Compliance posture measured
- [ ] Applicable endpoint security controls mapped
- [ ] Coverage gaps, deployment failures, and exceptions reviewed
- [ ] Update and operating system exposure assessed
- [ ] Risks prioritized with evidence
- [ ] Remediation roadmap assigned and approved
- [ ] Residual risk and evidence gaps documented

## Official References

- [Security Copilot in Intune features overview](https://learn.microsoft.com/en-us/intune/copilot/)
- [Manage endpoint security in Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/endpoint-security-policies)
- [Explore Intune data with natural language](https://learn.microsoft.com/en-us/intune/copilot/explorer)

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
