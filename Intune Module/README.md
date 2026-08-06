# Microsoft Intune

Resources for using Microsoft Security Copilot in Microsoft Intune to investigate managed devices, understand policies, explore tenant data, and support endpoint administration workflows.

---

## Start Here

Begin with the [Device Investigation Guide](Embedded%20Experiences/Device%20Investigation%20Guide.md) to summarize and troubleshoot a managed device from the Security Copilot embedded experience in the Intune admin center.

Use the [Intune Sample Prompts](Sample%20Prompts/Intune%20Sample%20Prompts.md) for copy-ready device, data exploration, policy, compliance, application, and Device query requests.

Use the [Intune Promptbooks](Promptbook/README.md) for complete, evidence-driven investigation and assessment workflows.

Use the [Intune Agent Guides](Agents/README.md) to set up and operate current Security Copilot agents and review retirement guidance for unavailable agents.

Use the [Intune Plugin Guides](Plugins/README.md) to enable the Microsoft Intune source, validate access, troubleshoot failures, and prepare agent dependencies.

## Subsections

| Subsection | Purpose | Status |
|---|---|---|
| [Embedded Experiences](Embedded%20Experiences/README.md) | In-product Intune Copilot investigation and administration workflows | In progress |
| [Agents](Agents/README.md) | Setup and operating guides for Intune-focused Security Copilot agents | Available |
| [Plugins](Plugins/README.md) | Intune source setup, validation, troubleshooting, and agent dependency guidance | Available |
| [Promptbook](Promptbook/README.md) | Structured endpoint management and investigation workflows | Available |
| [Sample Prompts](Sample%20Prompts/README.md) | Reusable prompts for common Intune scenarios | Available |

## Initial Workflow

1. Open a managed device in the Intune admin center.
2. Use **Summarize with Copilot** to establish device context.
3. Ask focused follow-up questions about the device.
4. Validate the response against authoritative Intune records before taking action.

## Available Promptbook Workflows

- [Noncompliant Device Investigation](Promptbook/Noncompliant%20Device%20Investigation%20Promptbook.md)
- [Device Health and Troubleshooting](Promptbook/Device%20Health%20and%20Troubleshooting%20Promptbook.md)
- [Application Deployment Failure Investigation](Promptbook/Application%20Deployment%20Failure%20Investigation%20Promptbook.md)
- [Configuration Policy Impact Analysis](Promptbook/Configuration%20Policy%20Impact%20Analysis%20Promptbook.md)
- [Endpoint Security Posture Review](Promptbook/Endpoint%20Security%20Posture%20Review%20Promptbook.md)

## Intune Agent Guides

- [Change Review Agent Setup and Operations](Agents/Change%20Review%20Agent%20Setup%20and%20Operations%20Guide.md) - Public preview
- [Policy Configuration Agent Setup and Operations](Agents/Policy%20Configuration%20Agent%20Setup%20and%20Operations%20Guide.md) - Public preview
- [Vulnerability Remediation Agent Setup and Operations](Agents/Vulnerability%20Remediation%20Agent%20Setup%20and%20Operations%20Guide.md) - Public preview
- [Device Offboarding Agent Retirement Reference](Agents/Device%20Offboarding%20Agent%20Retirement%20Reference.md) - Retired June 1, 2026

## Intune Plugin Guides

- [Microsoft Intune Plugin Setup and Validation](Plugins/Microsoft%20Intune%20Plugin%20Setup%20and%20Validation%20Guide.md)
- [Intune Plugin Access and Troubleshooting](Plugins/Intune%20Plugin%20Access%20and%20Troubleshooting%20Guide.md)
- [Intune Agent Plugin Dependency Matrix](Plugins/Intune%20Agent%20Plugin%20Dependency%20Matrix.md)

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
