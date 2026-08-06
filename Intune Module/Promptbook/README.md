# Intune Promptbooks

Structured Microsoft Security Copilot workflows for endpoint investigation, policy analysis, compliance review, and remediation planning in Microsoft Intune.

## Available Promptbooks

- [Noncompliant Device Investigation Promptbook](Noncompliant%20Device%20Investigation%20Promptbook.md)
- [Device Health and Troubleshooting Promptbook](Device%20Health%20and%20Troubleshooting%20Promptbook.md)
- [Application Deployment Failure Investigation Promptbook](Application%20Deployment%20Failure%20Investigation%20Promptbook.md)
- [Configuration Policy Impact Analysis Promptbook](Configuration%20Policy%20Impact%20Analysis%20Promptbook.md)
- [Endpoint Security Posture Review Promptbook](Endpoint%20Security%20Posture%20Review%20Promptbook.md)

## Choose a Workflow

| Scenario | Primary Input | Outcome |
|---|---|---|
| Noncompliant device | Device name or ID | Evidence-based cause and remediation plan |
| Device health and troubleshooting | Device name or ID and symptom | Root-cause hypothesis and diagnostic plan |
| Application deployment failure | Application name and platform | Failure scope, cause, and staged recovery plan |
| Configuration policy impact | Policy name | Change impact, rollout controls, and recommendation |
| Endpoint security posture | Platform and review scope | Prioritized control gaps and remediation roadmap |

## How to Use These Promptbooks

1. Review the required and optional inputs in the selected promptbook.
2. Replace each placeholder with an authorized value from your environment.
3. Run the prompts in order in one Security Copilot session so later prompts can use prior evidence.
4. Validate every material finding in the Intune admin center or another authoritative source.
5. Obtain the required approval before making device, application, group, or policy changes.

Prompts can also be tested individually before they are assembled into a custom promptbook in Microsoft Security Copilot.

## Related Resources

- [Intune Sample Prompts](../Sample%20Prompts/Intune%20Sample%20Prompts.md)
- [Device Investigation Guide](../Embedded%20Experiences/Device%20Investigation%20Guide.md)

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
