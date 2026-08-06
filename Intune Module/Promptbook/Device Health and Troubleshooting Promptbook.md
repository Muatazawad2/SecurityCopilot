# Device Health and Troubleshooting

**Description**: Troubleshoot a Microsoft Intune managed device by establishing its management baseline, reviewing policy and application state, analyzing the reported symptom, comparing a healthy device when available, and defining targeted evidence collection and remediation steps. This promptbook does not execute remote device actions.

## Required Input

- `{DeviceNameOrId}`: Intune device name or managed device ID
- `{ReportedSymptom}`: Concise description of the problem and user-visible behavior

## Optional Input

- `{HealthyDeviceNameOrId}`: Known-good device with a comparable platform and role
- `{ErrorCode}`: Error code reported by Intune, an application, or the device
- `{UserPrincipalName}`: Affected user's UPN
- `{TicketId}`: Incident or support ticket identifier

## Prerequisites

- Microsoft Security Copilot and the Microsoft Intune source are enabled.
- The operator has the required Security Copilot access, Intune RBAC permissions, and scope tags.
- Optional real-time Device query evidence requires applicable Intune licensing, permissions, and a supported Windows device.

Run the prompts in order in one session. Do not interpret missing Intune data as proof that a device component is healthy.

---

1. Confirm the device and troubleshooting scope

```text
Using Microsoft Intune data, identify {DeviceNameOrId} and create a troubleshooting scope for the reported symptom: {ReportedSymptom}. Include the managed device ID, serial number when available, operating system and version, ownership, primary user, management state, last check-in, compliance state, and Microsoft Entra join or registration state. If {UserPrincipalName} is provided, verify whether it matches the primary user. Label missing or ambiguous values without inferring them.
```

2. Review device health and data freshness

```text
Summarize the current Intune health signals for {DeviceNameOrId}. Review check-in recency, compliance evaluation, configuration status, management state, malware count or threat state when available, and pending, error, conflict, or unknown conditions. Build a timeline from available timestamps and identify stale evidence that must be refreshed or verified.
```

3. Review assigned policies, applications, and groups

```text
For {DeviceNameOrId}, list the assigned configuration policies, compliance policies, endpoint security policies, app configuration policies, installed or assigned applications, and group memberships relevant to {ReportedSymptom}. Highlight failed, pending, conflicting, or not-applicable states. Separate confirmed assignments from policies or applications that require validation in another Intune view.
```

4. Analyze the symptom and error evidence

```text
Analyze the reported symptom {ReportedSymptom} for {DeviceNameOrId}. If {ErrorCode} is provided, explain its documented meaning, likely causes, and validation steps. Correlate the symptom with the device, policy, application, and timeline evidence already collected. Do not present a generic error-code explanation as the confirmed root cause without device-specific evidence.
```

5. Compare with a healthy device when available

```text
If {HealthyDeviceNameOrId} is provided and visible in Intune, compare it with {DeviceNameOrId}. Focus on operating system and hardware characteristics, last check-in, compliance, assigned policies, installed applications, group memberships, and relevant configuration states. Report only differences supported by available data and explain which differences could plausibly contribute to {ReportedSymptom}. If no healthy device is provided, define the characteristics needed to select a valid comparison device.
```

6. Define targeted endpoint evidence collection

```text
Based on the unresolved hypotheses in this session, create a minimal endpoint evidence collection plan for {DeviceNameOrId}. Where Device query supports the needed property, provide a separate natural-language request that can be used to generate KQL for services, processes, application crashes, certificates, Windows updates, encryption, drivers, registry values, or files. For unsupported evidence, identify the authorized Intune or support workflow needed. Do not claim that a query was run or that endpoint state was observed unless results are present in this session.
```

7. Rank root-cause hypotheses

```text
Rank the likely causes of {ReportedSymptom} using evidence from this session. For each hypothesis, provide supporting evidence, contradictory evidence, missing evidence, confidence as High, Medium, or Low, and one discriminating test. Distinguish device-state, policy, application, identity or assignment, connectivity, and stale-data causes when relevant.
```

8. Create a controlled resolution plan

```text
Create a least-disruptive resolution plan for {DeviceNameOrId}. Order diagnostic and remediation steps by risk and expected value. For each step, include prerequisites, responsible role, user impact, approval requirement, expected result, rollback or recovery consideration, and validation evidence. Do not execute or claim completion of sync, restart, remediation script, application reinstall, policy change, retire, wipe, or any other remote action.
```

9. Produce the troubleshooting report

```text
Create a final device troubleshooting report for {DeviceNameOrId} and ticket {TicketId} when provided. Include:
- Reported symptom and investigation scope
- Device identity, user, and data freshness
- Relevant policy, application, group, and health findings
- Healthy-device comparison, if performed
- Root-cause hypotheses with confidence
- Evidence collected and remaining gaps
- Controlled resolution and validation plan
- Final disposition: Root cause confirmed, Probable cause identified, More evidence required, Expected behavior, or Unable to reproduce

Tie each conclusion to observed evidence and do not state that the issue is resolved without post-change validation.
```

---

## Completion Criteria

- [ ] Device and affected user verified
- [ ] Symptom and timeline documented
- [ ] Policy, application, group, and health state reviewed
- [ ] Real-time evidence collected when required and authorized
- [ ] Root cause confirmed or hypotheses ranked
- [ ] Resolution and validation plan approved
- [ ] Troubleshooting report attached to the relevant record

## Official References

- [Use Copilot in Intune to troubleshoot devices](https://learn.microsoft.com/en-us/intune/copilot/troubleshoot-devices)
- [Device query in Microsoft Intune](https://learn.microsoft.com/en-us/intune/advanced-analytics/device-query)
- [Remote actions for devices in Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-management/manage-endpoint-security-devices#remote-actions-for-devices)

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
