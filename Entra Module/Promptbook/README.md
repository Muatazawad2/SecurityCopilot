# Entra Promptbook

Investigation methodologies and reusable prompt workflows for Entra incidents.

**Developer**: Dr Muataz Awad

## Scenario Families

This promptbook is organized around four Microsoft Entra Security Copilot scenario families:

1. Microsoft Entra ID
2. Microsoft Entra ID Protection
3. Microsoft Entra ID Governance
4. Microsoft Entra Internet Access and Microsoft Entra Private Access

## Standard Investigation Workflow

Use this sequence for every scenario family:

1. Scope the request: Identify tenant, user, app, group, device, or policy in scope.
2. Baseline current state: Collect current configuration, assignments, and posture.
3. Investigate anomalies: Correlate signs of risk, changes, and activity history.
4. Assess impact: Determine blast radius, affected identities/resources, and urgency.
5. Recommend action: Provide prioritized containment and remediation steps.
6. Validate closure: Confirm controls, log evidence, and define monitoring follow-up.

## 1) Microsoft Entra ID

### Typical investigation goals

<!-- Repository maintenance marker -->

- User and tenant posture discovery
- Sign-in, audit, and provisioning log review
- RBAC and privileged assignment checks
- Conditional Access and authentication posture validation

### Suggested workflow focus

1. Identify the identity object and timeframe.
2. Pull sign-in, audit, and policy context.
3. Compare against expected behavior and role scope.
4. Confirm whether CA/auth controls were bypassed or misconfigured.
5. Document high-confidence findings and next actions.

## 2) Microsoft Entra ID Protection

### Typical investigation goals

- Risky user triage and remediation
- Application/workload identity risk analysis
- Prioritization of risk signals and response actions

### Suggested workflow focus

1. Collect risk detections and risk history.
2. Correlate with sign-ins and recent privilege/app changes.
3. Determine account compromise likelihood.
4. Recommend containment (reset, revoke sessions, require MFA, block sign-in).
5. Capture decision rationale and follow-up checks.

## 3) Microsoft Entra ID Governance

### Typical investigation goals

- Access review quality and overdue decisions
- Entitlement package and assignment validation
- PIM activation/assignment and privileged access controls
- Lifecycle workflow drift and process gaps

### Suggested workflow focus

1. Validate governance object ownership and policy intent.
2. Review high-risk grants, expirations, and approval paths.
3. Inspect privileged role activations and standing access.
4. Identify segregation-of-duties and least-privilege violations.
5. Recommend governance hardening and review cadence.

## 4) Microsoft Entra Internet Access and Microsoft Entra Private Access

### Typical investigation goals

- Global Secure Access posture and policy review
- User/application access path validation
- Access anomalies and connection risk analysis

### Suggested workflow focus

1. Define affected users, apps, and network segments.
2. Review access policies and enforcement outcomes.
3. Correlate anomalous access with identity and device posture.
4. Assess exposure of private resources and internet-bound sessions.
5. Recommend policy tuning and monitoring improvements.

## Analyst Output Template

For each investigation, produce:

1. Executive summary
2. Evidence timeline
3. Root cause or likely cause
4. Impact assessment
5. Immediate containment actions
6. Long-term preventive controls
