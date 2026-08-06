# Intune Agent Plugin Dependency Matrix

## Overview

Microsoft Security Copilot agents in Intune use preinstalled plugins to retrieve Microsoft service data and perform their specialized evaluations. Plugin availability, agent identity permissions, service licensing, and data scope are separate requirements; enabling a plugin alone isn't sufficient.

## Current Matrix

| Experience or Agent | Availability as of August 6, 2026 | Required Preinstalled Plugins | Important Notes |
|---|---|---|---|
| Copilot in Intune and standalone Intune prompts | Available | Microsoft Intune | Interactive results follow the signed-in user's Intune RBAC and scope tags. |
| Change Review Agent | Public preview | Microsoft Intune, Microsoft Entra, Microsoft Defender XDR, Microsoft Threat Intelligence | Evaluates Windows PowerShell Multi Admin Approval requests. Final approval or rejection remains with an administrator. |
| Policy Configuration Agent | Public preview | Microsoft Intune | Maps Windows requirements to settings catalog suggestions. A generated policy isn't enforced until an administrator assigns it. |
| Vulnerability Remediation Agent | Public preview | Microsoft Intune, Microsoft Defender | Requires Defender Vulnerability Management and an authorized agentic identity. It provides guidance but doesn't remediate devices. |
| Device Offboarding Agent | Retired June 1, 2026 | Historically Microsoft Intune, with Intune and Entra signals | No longer available; don't configure new plugin dependencies for it. |
| Windows 365 Cloud PC insights in Intune | Available where licensed and supported | Microsoft Intune, Windows 365 | Enable the Windows 365 source when the requested Cloud PC capability depends on it. |

## Agent-Scoped Plugin Activation

When an Intune agent is set up, its required plugins are automatically enabled for that agent only. This behavior:

- Doesn't enable those plugins for standalone Security Copilot sessions.
- Doesn't change organization-wide availability settings.
- Doesn't grant service permissions to the agent identity.
- Doesn't replace Intune, Entra, Defender, or Threat Intelligence licensing.
- Can be reversed by disabling or removing the agent without changing interactive plugin settings.

Validate interactive sources and agent-scoped sources independently.

## Change Review Agent

### Plugin Roles

- **Microsoft Intune** supplies Multi Admin Approval requests and historical Intune context.
- **Microsoft Entra** supplies identity risk context.
- **Microsoft Defender XDR** supplies vulnerability and security context.
- **Microsoft Threat Intelligence** supplies threat intelligence used in evaluation.

### Validation

1. Confirm all four plugins appear in the agent setup or **Settings** view.
2. Verify the setup identity has the documented Intune, Entra, Defender, and Security Copilot permissions.
3. Confirm Defender device-group scope includes the intended devices.
4. Run the agent manually and review factor-level results.
5. Keep the final Multi Admin Approval decision with an authorized administrator.

See the [Change Review Agent Setup and Operations Guide](../Agents/Change%20Review%20Agent%20Setup%20and%20Operations%20Guide.md).

## Policy Configuration Agent

### Plugin Role

- **Microsoft Intune** maps natural-language requirements and knowledge sources to Windows settings catalog configurations.

### Validation

1. Confirm the Microsoft Intune plugin appears in agent settings.
2. Validate the setup identity's read permissions.
3. Validate create and update permissions separately before creating a policy.
4. Test with a small, clearly written source.
5. Confirm supported, unsupported, and low-confidence mappings.
6. Keep the resulting policy unassigned until normal change approval is complete.

See the [Policy Configuration Agent Setup and Operations Guide](../Agents/Policy%20Configuration%20Agent%20Setup%20and%20Operations%20Guide.md).

## Vulnerability Remediation Agent

### Plugin Roles

- **Microsoft Defender** supplies Defender Vulnerability Management CVE, exposure, and affected-device data.
- **Microsoft Intune** supplies managed application, device configuration, and remediation-path context.

### Validation

1. Confirm both plugins appear in agent settings.
2. Confirm the Microsoft Entra agentic identity was provisioned.
3. Delegate the documented Intune and Defender read permissions to the agentic user.
4. Scope Defender access to the intended device groups.
5. Run **Run Readiness Check**.
6. Compare a suggestion with current Defender Vulnerability Management evidence.
7. Confirm **Mark as applied** doesn't trigger a device action.

See the [Vulnerability Remediation Agent Setup and Operations Guide](../Agents/Vulnerability%20Remediation%20Agent%20Setup%20and%20Operations%20Guide.md).

## Device Offboarding Agent

The Device Offboarding Agent is unavailable after June 1, 2026. Its historical documentation can remain visible, and the general Microsoft agent overview can still mention it, but don't enable sources or assign permissions for a new deployment.

Use the [Device Offboarding Agent Retirement Reference](../Agents/Device%20Offboarding%20Agent%20Retirement%20Reference.md) to transition to supported Intune and Entra lifecycle controls.

## Change-Control Checklist

Before changing plugin availability or agent dependencies:

- [ ] Confirm the experience or agent is currently available
- [ ] Identify every required plugin and service license
- [ ] Distinguish interactive-user and agent-identity permissions
- [ ] Apply least privilege and appropriate service scope
- [ ] Assess effects on embedded experiences and existing agents
- [ ] Test with a nonproduction or limited-scope persona when possible
- [ ] Notify affected users before restricting a preinstalled plugin
- [ ] Define rollback and validation steps
- [ ] Record plugin, identity, permission, and workspace changes

## Official References

- [Security Copilot agents in Intune](https://learn.microsoft.com/en-us/intune/copilot/agents/)
- [Manage plugins in Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/manage-plugins)
- [Change Review Agent overview](https://learn.microsoft.com/en-us/intune/copilot/agents/change-review-agent)
- [Policy Configuration Agent overview](https://learn.microsoft.com/en-us/intune/copilot/agents/policy-configuration-agent)
- [Vulnerability Remediation Agent overview](https://learn.microsoft.com/en-us/intune/copilot/agents/vulnerability-remediation-agent)
- [Device Offboarding Agent retirement notice](https://learn.microsoft.com/en-us/intune/copilot/agents/device-offboarding-agent)

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
