# Entra Sample Prompts

Ready-to-use sample prompts for common Entra investigation and triage scenarios.

**Developer**: Dr Muataz Awad

## How To Use

1. Start with triage prompts to quickly understand context.
2. Use deep-dive prompts to investigate behavior and changes.
3. End with remediation and summary prompts for action tracking.

## 1) Microsoft Entra ID

### Triage prompts

- Summarize this user's identity posture, assigned roles, and recent sign-in activity for the last 7 days.
- List the most relevant tenant recommendations and health alerts that need immediate attention.
- Show recent audit log entries related to authentication, policy, or admin changes.

### Deep-dive prompts

- Analyze sign-in logs for this user and highlight anomalies by location, device, client app, and risk indicators.
- Review Conditional Access policies applied to this sign-in and explain why access was allowed or blocked.
- Summarize authentication methods registered by this user and identify weak or missing factors.

### Remediation and reporting prompts

- Recommend top 3 identity hardening actions for this user with expected risk reduction.
- Draft an analyst incident summary with findings, impact, and next steps.

## 2) Microsoft Entra ID Protection

### Triage prompts

- Summarize risky users by risk level, trend, and remediation status.
- Show this user's risk detections and explain what each detection implies.
- List risky applications or workload identities and rank by exposure.

### Deep-dive prompts

- Correlate this risky user's detections with sign-in patterns and recent privilege changes.
- Explain whether current evidence suggests likely account compromise or false positive risk.
- Analyze application risk signals and identify over-privileged permissions that should be reduced.

### Remediation and reporting prompts

- Provide containment steps for this risky user in priority order with user-impact notes.
- Draft a remediation plan for risky applications, including owners and timelines.

## 3) Microsoft Entra ID Governance

### Triage prompts

- Summarize overdue or high-risk access reviews and impacted resources.
- List privileged role assignments that violate least-privilege or show long-lived elevation.
- Show entitlement packages with unusual assignment patterns or weak approval controls.

### Deep-dive prompts

- Analyze PIM activations for abnormal patterns by user, role, time, and justification quality.
- Identify access review decision patterns that indicate rubber-stamping or reviewer fatigue.
- Review lifecycle workflows and surface failures that could leave stale access in place.

### Remediation and reporting prompts

- Recommend governance control improvements across access reviews, entitlement management, and PIM.
- Generate an executive summary of governance risk with 30/60/90-day actions.

## 4) Microsoft Entra Internet Access and Microsoft Entra Private Access

### Triage prompts

- Summarize Global Secure Access posture and list policies with highest operational risk.
- Identify users or apps with unusual private access patterns in the last 7 days.
- Show high-risk access paths to private resources and related identity context.

### Deep-dive prompts

- Correlate anomalous access attempts with user sign-in risk, device posture, and policy outcomes.
- Explain why this private access request was permitted and which controls were evaluated.
- Identify recurring access failures that suggest policy gaps or misconfiguration.

### Remediation and reporting prompts

- Recommend policy tuning changes to reduce exposure while minimizing business disruption.
- Draft a change-validation checklist for secure rollout of updated access policies.

## Reusable Summary Prompt

- Create a complete investigation report with: scope, timeline, key findings, risk statement, containment actions, and preventive recommendations.
