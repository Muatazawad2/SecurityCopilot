# Logic Apps Module

Automated security workflows built with Azure Logic Apps that integrate with Microsoft Entra ID, Microsoft Graph API, and Microsoft Security Copilot.

All workflows in this module are designed to use System-Assigned Managed Identity (no OAuth connector secrets stored in the workflow definition).

**Developer**: Dr Muataz Awad

---

## Available Logic Apps

| Logic App | Trigger | Description | Documentation |
|-----------|---------|-------------|---------------|
| Daily Risky User Digest | Daily schedule | Sends a daily HTML digest of at-risk users from Entra ID Protection | [Risky User Management/Daily Risky User Digest/README.md](Risky%20User%20Management/Daily%20Risky%20User%20Digest/README.md) |
| Password Spray Auto-Alert | Polling every 30 min | Detects `passwordSpray` risk events and sends immediate SOC alert email | [Password Spray Detection/README.md](Password%20Spray%20Detection/README.md) |
| Token Theft Response Alert | Polling every 15 min | Detects token theft anomalies and sends immediate SOC alert email | [Token Theft Detection/Token Theft Response Alert/README.md](Token%20Theft%20Detection/Token%20Theft%20Response%20Alert/README.md) |

---

## Solution Areas

- [Risky User Management/Daily Risky User Digest/README.md](Risky%20User%20Management/Daily%20Risky%20User%20Digest/README.md)
- [Password Spray Detection/README.md](Password%20Spray%20Detection/README.md)
- [Token Theft Detection/Token Theft Response Alert/README.md](Token%20Theft%20Detection/Token%20Theft%20Response%20Alert/README.md)

---

## Notes

- Use the scenario-specific README files for full setup steps, architecture diagrams, deployment scripts, troubleshooting, and images.
- Keep this file as a module-level index only.
