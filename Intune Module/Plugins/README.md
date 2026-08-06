# Intune Plugins

Configuration, validation, access, and troubleshooting guidance for the Microsoft Intune source in Microsoft Security Copilot.

## Available Guides

- [Microsoft Intune Plugin Setup and Validation Guide](Microsoft%20Intune%20Plugin%20Setup%20and%20Validation%20Guide.md)
- [Intune Plugin Access and Troubleshooting Guide](Intune%20Plugin%20Access%20and%20Troubleshooting%20Guide.md)
- [Intune Agent Plugin Dependency Matrix](Intune%20Agent%20Plugin%20Dependency%20Matrix.md)

## Plugin Model

Microsoft Intune is a preinstalled, Microsoft-managed Security Copilot plugin. It is enabled from **Sources** in the Security Copilot portal. There is no Intune manifest in this repository to upload, edit, or maintain.

The plugin provides Intune data and system capabilities to standalone Security Copilot sessions and supported embedded Intune experiences. Results remain constrained by the signed-in user's Intune RBAC permissions and scope tags.

## Choose a Guide

| Need | Use |
|---|---|
| Enable and test the Intune source | Setup and Validation Guide |
| Diagnose missing sources, permissions, or incomplete results | Access and Troubleshooting Guide |
| Prepare plugins for an Intune Security Copilot agent | Agent Plugin Dependency Matrix |

## Related Resources

- [Intune Sample Prompts](../Sample%20Prompts/Intune%20Sample%20Prompts.md)
- [Device Investigation Guide](../Embedded%20Experiences/Device%20Investigation%20Guide.md)
- [Intune Agent Guides](../Agents/README.md)
- [Custom OpenAI Plugins Module](../../Custom%20OpenAI%20Plugins%20Module/README.md)

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
