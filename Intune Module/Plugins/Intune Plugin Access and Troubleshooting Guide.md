# Intune Plugin Access and Troubleshooting Guide

## Overview

This guide provides a structured process for diagnosing Microsoft Intune plugin problems in standalone Microsoft Security Copilot and embedded Copilot experiences in the Intune admin center.

Troubleshoot the three access layers separately:

1. **Availability**: Can the user access the preinstalled Microsoft Intune plugin?
2. **Enabled state**: Is the Microsoft Intune source turned on for the relevant experience or agent?
3. **Authorization**: Can the active identity read the requested Intune object through RBAC and scope tags?

## Capture Diagnostic Context

Before changing configuration, record:

- Affected user and Security Copilot workspace
- Standalone portal, embedded Intune experience, or agent name
- Exact prompt and time of failure
- Security Copilot session ID when available
- Expected Intune object and its ID
- User's Security Copilot role
- User's Intune role assignments and scope tags
- Microsoft Intune source availability and toggle state
- Whether another authorized user can reproduce the issue
- Error message, screenshot, and any cited capability

Use test objects that contain no unnecessary sensitive information.

## Symptom: Microsoft Intune Is Missing from Sources

1. Confirm the user is in the intended Security Copilot workspace.
2. Ask a Security Copilot owner to open **Owner** > **Plugin settings**.
3. Review availability for preinstalled plugins.
4. Confirm Microsoft Intune is available to **All users** or to the affected user's permitted role.
5. Sign out and back in, then reopen **Sources**.

Restricting a preinstalled plugin is immediate and affects standalone and embedded experiences. Don't broaden availability without the plugin owner and data owner approving the change.

## Symptom: Microsoft Intune Is Listed but Can't Be Enabled

1. Confirm the affected user is allowed to use the plugin under workspace plugin settings.
2. Check whether an owner has restricted Microsoft Intune to owners only.
3. Confirm Security Copilot provisioning and workspace membership.
4. Check Security Copilot capacity and service health.
5. Retry in a new session after the availability issue is corrected.

The Intune plugin is preinstalled. Uploading a custom manifest isn't a valid repair.

## Symptom: The Plugin Is Enabled but Returns No Data

1. Verify that the target object exists in Intune and use its exact name or ID.
2. Open the same object directly in the Intune admin center with the affected identity.
3. Review Intune RBAC role assignments.
4. Review scope tags on both the role assignment and target resource.
5. Confirm the prompt asks for a currently supported Intune system capability.
6. Retry with a narrow prompt that names Microsoft Intune and one known object.

Example:

```text
According to Microsoft Intune, tell me the device name, managed device ID, compliance state, and primary user for {DeviceNameOrId}. Clearly identify fields that aren't available.
```

If a more privileged user receives data and the affected user doesn't, investigate authorization and scope rather than toggling the plugin repeatedly.

## Symptom: Only Some Objects or Fields Are Returned

Possible causes include:

- Intune RBAC limits the resource types the user can read.
- Scope tags exclude some objects.
- The selected system capability doesn't return the requested property.
- The property isn't populated or current in Intune.
- Multiple objects have similar display names.
- The prompt crossed data domains without the other required plugin enabled.

Use IDs instead of display names, ask for one resource type at a time, and compare the result with the authoritative Intune record. Treat absent output as unavailable data, not proof that the property is empty or the condition is false.

## Symptom: Embedded Copilot Is Missing in Intune

1. In the Intune admin center, go to **Tenant administration** > **Copilot**.
2. Confirm Copilot is enabled for the tenant.
3. Confirm the user has Security Copilot access.
4. Confirm the Microsoft Intune preinstalled plugin isn't restricted from the user.
5. Confirm the user has permission to view the current Intune resource.
6. Try the **Copilot** button in the top banner, then test **Summarize with Copilot** on a known device or supported policy.

An owner restriction on a preinstalled plugin can affect embedded experiences immediately.

## Symptom: Results Refer to the Wrong Device, App, or Policy

1. Stop using the ambiguous result for decision-making.
2. Replace the display name with the managed device ID, application ID, or exact policy name.
3. State `According to Microsoft Intune` in the prompt.
4. Ask Copilot to repeat the object identifiers in its response.
5. Compare those identifiers with Intune before continuing.
6. Start a new session if prior context is steering the prompt toward another object.

## Symptom: A Prompt Doesn't Invoke Intune

1. Confirm Microsoft Intune is enabled under **Sources**.
2. Open **See all system capabilities** and locate a matching Intune capability.
3. Rewrite the request to name Microsoft Intune and supply required inputs.
4. Select a built-in prompt suggestion when one appears.
5. Split requests that mix Intune, Entra, Defender, or Windows 365 data into source-specific steps.

Example:

```text
According to Microsoft Intune, which configuration policies are assigned to device {DeviceNameOrId}?
```

## Symptom: An Intune Agent Can't Access a Required Plugin

1. Open the agent's **Settings** tab and review required plugins and identity.
2. Confirm the agent setup completed successfully.
3. Verify every non-Intune plugin required by that agent.
4. Validate permissions for the agent identity, not only the interactive administrator.
5. Run the agent's readiness check when one is available.
6. Check Security Copilot audit logs for plugin, identity, or permission failures.

Plugins automatically activated for an agent are scoped to that agent. Their activation doesn't make the same plugin available or enabled for interactive users.

Use the [Intune Agent Plugin Dependency Matrix](Intune%20Agent%20Plugin%20Dependency%20Matrix.md) for agent-specific requirements.

## Symptom: Prompts Fail Intermittently

Check:

- Available SCUs and capacity throttling
- Microsoft service health
- Session-specific source state
- Identity token or agent authorization expiration
- Request complexity and ambiguous inputs
- Temporary capability or connector failures

Retry once with a new session and a minimal prompt. Don't repeatedly run expensive prompts without checking capacity and failure details.

## Security and Privacy Review

Security Copilot processes and stores prompts, retrieved Intune data, and generated output within the Security Copilot service. Before enabling broad access:

- Apply least-privileged Security Copilot and Intune roles.
- Design scope tags for delegated administration.
- Review Security Copilot privacy and data-security commitments.
- Control who can change preinstalled plugin availability.
- Review session sharing and retention practices.
- Avoid copying sensitive output into unapproved tickets or chat systems.

## Escalation Package

When local troubleshooting doesn't resolve the issue, prepare:

- Tenant and workspace identifiers
- Security Copilot session ID
- UTC timestamp
- Affected identity and roles, without credentials
- Intune scope tags
- Source availability and enabled state
- Exact prompt and object ID
- Expected versus observed result
- Reproduction result from a comparison identity
- Relevant audit or service-health information

Remove secrets and unnecessary personal or device-sensitive data before sharing the package.

## Resolution Checklist

- [ ] Plugin availability is correct for the affected persona
- [ ] Microsoft Intune is enabled for the relevant experience
- [ ] Security Copilot workspace access is confirmed
- [ ] Intune RBAC and scope tags are validated
- [ ] Exact object identifiers are used
- [ ] A supported Intune capability matches the request
- [ ] Embedded tenant integration is enabled when applicable
- [ ] Agent identity and non-Intune plugins are checked when applicable
- [ ] Result is compared with authoritative Intune data
- [ ] Diagnostic evidence and resolution are recorded

## Official References

- [Security Copilot in Microsoft Intune](https://learn.microsoft.com/en-us/intune/copilot/security-copilot)
- [Manage plugins in Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/manage-plugins)
- [Roles and authentication in Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/authentication)
- [Role-based access control in Microsoft Intune](https://learn.microsoft.com/en-us/intune/fundamentals/role-based-access-control/overview)
- [Use scope tags in Microsoft Intune](https://learn.microsoft.com/en-us/intune/fundamentals/role-based-access-control/scope-tags)
- [Security Copilot audit logs](https://learn.microsoft.com/en-us/copilot/security/audit-log)

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
