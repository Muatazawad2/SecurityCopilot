# Noncompliant Device Investigation

**Description**: Investigate why a Microsoft Intune managed device is noncompliant. Establish the device identity and data freshness, identify failed compliance controls, review relevant assignments and configuration, assess user and security impact, and produce a validated remediation plan. This promptbook recommends actions but does not authorize or execute device changes.

## Required Input

- `{DeviceNameOrId}`: Intune device name or managed device ID

## Optional Input

- `{UserPrincipalName}`: Expected primary user's UPN
- `{TicketId}`: Incident or support ticket identifier

## Prerequisites

- Microsoft Security Copilot is provisioned.
- The Microsoft Intune source is enabled in Security Copilot.
- The operator has the required Security Copilot access, Intune RBAC permissions, and scope tags.
- The target is an Intune managed device visible to the operator.

Run the prompts in order in one Security Copilot session. Treat missing data as an investigation gap, not evidence that an issue is absent. Validate all material findings in the Intune admin center before remediation.

---

1. Establish device identity and management context

```text
Using Microsoft Intune data, identify the managed device {DeviceNameOrId}. Report the device name, managed device ID, serial number when available, operating system and version, ownership, management state, Microsoft Entra registration or join state, primary user, last check-in time, and current compliance state. If {UserPrincipalName} is provided, verify whether it matches the recorded primary user. Clearly label any requested field that is unavailable or ambiguous, and do not infer missing values.
```

2. Identify failed compliance controls

```text
For the Intune device {DeviceNameOrId}, list every compliance policy and setting currently reporting noncompliant, in grace period, error, conflict, or unknown. For each result, include the policy name, setting or control, reported state, available error or status detail, and the most recent evaluation time. Separate observed Intune data from interpretation, and state explicitly if detailed per-setting results are unavailable.
```

3. Review compliance policy assignments and applicability

```text
Review the compliance policies applicable to {DeviceNameOrId}. For each relevant policy, summarize its purpose, platform, assignments, exclusions, assignment filters when available, and settings that influence the device's current compliance state. Identify evidence of missing assignment, overlapping scope, unsupported platform, or applicability mismatch. Do not claim a policy conflict unless the available Intune data demonstrates one.
```

4. Review related configuration and security policy state

```text
Using the findings from this session, review device configuration and endpoint security policies assigned to {DeviceNameOrId} that could affect the failed compliance controls. Report policy status and relevant setting values when available. Highlight configuration errors, conflicts, pending states, or settings that appear inconsistent with the compliance requirement. Distinguish confirmed relationships from hypotheses that require administrator validation.
```

5. Assess data freshness and evaluation gaps

```text
Assess whether stale or incomplete Intune data could explain the compliance result for {DeviceNameOrId}. Consider its last check-in, last compliance evaluation, management state, and any pending, unknown, or error states found earlier. Identify which evidence is current, which is stale, and which must be collected directly from the device or another authorized management view.
```

6. Determine the most likely cause

```text
Based only on evidence collected in this session, rank the likely causes of noncompliance for {DeviceNameOrId}. For each candidate cause, provide supporting evidence, contradictory or missing evidence, confidence as High, Medium, or Low, and the next validation step. Include policy assignment, policy evaluation, device configuration, operating system or security state, and stale check-in as candidate categories when relevant.
```

7. Assess operational and security impact

```text
Assess the impact of the confirmed noncompliance findings for {DeviceNameOrId}. Explain the security exposure, affected control objective, likely user impact, access or Conditional Access implications when supported by the available data, and urgency. Do not assume that access has been blocked or granted unless the session contains evidence of that outcome.
```

8. Build a remediation and validation plan

```text
Create a least-disruptive remediation plan for {DeviceNameOrId} based on the confirmed findings. Order the steps by priority and include the responsible role, prerequisites, user communication needs, rollback or recovery consideration, expected result, and the Intune evidence that should confirm success. Separate safe diagnostic steps from changes that require approval. Do not execute, simulate completion of, or claim approval for any remote action, policy change, retirement, wipe, sync, restart, or remediation script.
```

9. Produce the investigation report

```text
Create a final noncompliant device investigation report for {DeviceNameOrId} and reference ticket {TicketId} when provided. Include:
- Device identity and primary user
- Investigation scope and data freshness
- Failed compliance policies and settings
- Relevant configuration or endpoint security policy findings
- Confirmed cause and unresolved hypotheses
- Security and user impact
- Recommended remediation and validation steps
- Evidence gaps, owners, and next actions
- Final disposition: Confirmed configuration issue, Confirmed endpoint-state issue, Stale or insufficient data, Expected policy behavior, or Undetermined

For every major conclusion, identify the supporting Intune evidence. Do not state that remediation is complete unless completion evidence was provided in this session.
```

---

## Completion Criteria

- [ ] Device identity and primary user verified
- [ ] Compliance failures enumerated
- [ ] Policy applicability and related configuration reviewed
- [ ] Data freshness assessed
- [ ] Cause ranked with evidence and confidence
- [ ] Impact documented
- [ ] Remediation and validation plan reviewed by an authorized administrator
- [ ] Investigation report attached to the relevant record

## Official References

- [Security Copilot in Intune features overview](https://learn.microsoft.com/en-us/intune/copilot/)
- [Use Copilot in Intune to troubleshoot devices](https://learn.microsoft.com/en-us/intune/copilot/troubleshoot-devices)
- [Device compliance policies in Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/compliance/overview)
- [Monitor Intune device compliance policies](https://learn.microsoft.com/en-us/intune/device-security/compliance/monitor-policy)

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
