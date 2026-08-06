# Intune Agents

Setup, configuration, and operating guidance for Microsoft Security Copilot agents that support Intune administration and endpoint security workflows.

## Agent Guides

| Agent | Availability as of August 6, 2026 | Guide |
|---|---|---|
| Change Review Agent | Public preview | [Setup and Operations Guide](Change%20Review%20Agent%20Setup%20and%20Operations%20Guide.md) |
| Policy Configuration Agent | Public preview | [Setup and Operations Guide](Policy%20Configuration%20Agent%20Setup%20and%20Operations%20Guide.md) |
| Vulnerability Remediation Agent | Public preview | [Setup and Operations Guide](Vulnerability%20Remediation%20Agent%20Setup%20and%20Operations%20Guide.md) |
| Device Offboarding Agent | Retired June 1, 2026 | [Retirement Reference](Device%20Offboarding%20Agent%20Retirement%20Reference.md) |

## Shared Requirements

- Microsoft Intune Plan 1 and Microsoft Security Copilot with sufficient SCUs.
- Public cloud; these agents aren't supported in government clouds.
- Required Microsoft and Security Copilot plugins enabled.
- Least-privileged Intune, Microsoft Entra, Microsoft Defender, and Security Copilot roles required by the selected agent.
- Administrator review before approving requests, creating or assigning policies, or applying remediation.

Licensing, identity, permissions, and preview behavior differ by agent. Review the selected guide and current Microsoft documentation before setup.

See the [Security Copilot agents in Intune overview](https://learn.microsoft.com/en-us/intune/copilot/agents/) for current Microsoft documentation.

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
