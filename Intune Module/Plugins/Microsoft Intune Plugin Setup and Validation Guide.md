# Microsoft Intune Plugin Setup and Validation Guide

## Overview

This guide explains how to enable and validate the preinstalled Microsoft Intune plugin in Microsoft Security Copilot. The plugin grounds Security Copilot prompts in Intune data, including managed devices, applications, compliance and configuration policies, assignments, groups, and available hardware properties.

The Microsoft Intune plugin is Microsoft-managed. Don't upload a YAML or OpenAI manifest for this built-in integration.

## Where the Plugin Is Used

The Intune plugin supports two related experiences:

- **Standalone Security Copilot portal** for SOC and security-administrator investigations across enabled Microsoft sources.
- **Copilot in the Intune admin center** for embedded device, policy, settings, data exploration, and troubleshooting workflows.

Enabling the source makes Intune capabilities available, but it doesn't expand the signed-in user's Intune permissions.

## Prerequisites

- Microsoft Intune in the same tenant as Microsoft Security Copilot.
- Microsoft Security Copilot provisioned with sufficient security compute units (SCUs).
- Completion of the Security Copilot first-run experience.
- Access to the Security Copilot workspace.
- A role allowed to access the Microsoft Intune preinstalled plugin.
- Intune RBAC permissions and scope tags for the data being requested.

For broad Intune data access, Microsoft identifies the Microsoft Entra **Intune Administrator** role, also called **Intune Service Administrator**. Prefer a least-privileged Intune role when broad tenant access isn't required.

## Understand the Access Boundaries

Three independent controls affect whether a prompt succeeds:

1. **Plugin availability**: A Security Copilot owner can make a preinstalled plugin available to all users or restrict it to owners.
2. **Plugin state**: The Microsoft Intune source must be turned on for the session or experience using it.
3. **Data authorization**: Intune RBAC permissions and scope tags determine which Intune objects and properties the signed-in user can retrieve.

Turning on the plugin doesn't grant Intune permissions. Conversely, having Intune permissions doesn't help when the plugin is unavailable or disabled.

## Enable the Microsoft Intune Plugin

1. Open the [Microsoft Security Copilot portal](https://securitycopilot.microsoft.com) and sign in.
2. In the prompt bar, select **Sources**.
3. In **Manage sources**, locate **Microsoft Intune**.
4. Turn on the Microsoft Intune source.
5. Confirm that the source remains enabled after closing and reopening **Manage sources**.

If Microsoft Intune isn't listed or its toggle is unavailable, ask a Security Copilot owner to review preinstalled plugin availability under **Owner** > **Plugin settings**.

## Confirm Intune Integration Status

1. Open the [Microsoft Intune admin center](https://intune.microsoft.com).
2. Go to **Tenant administration** > **Copilot**.
3. Confirm that Copilot is enabled for the Intune tenant.
4. From the top banner, select **Copilot** and confirm that Copilot Chat opens.

The Intune source and the tenant integration must both be usable for a complete embedded experience.

## Inspect Intune System Capabilities

1. In the Security Copilot portal, select the Copilot prompts icon in the prompt bar.
2. Select **See all system capabilities**.
3. Find **Microsoft Intune**.
4. Review the currently available built-in capabilities and their required inputs.

System capabilities evolve. Use the list shown in your tenant as the authoritative catalog instead of assuming that every natural-language request maps to a supported capability.

## Validate the Plugin

Start a new standalone Security Copilot session after enabling the source. Run the following checks in order, replacing placeholders with objects visible to your account.

### Test 1: Tenant-Level Intune Data

```text
According to Microsoft Intune, how many devices were enrolled in the last 24 hours?
```

Expected result:

- The response identifies Microsoft Intune as a source or capability.
- It returns an authorized count or clearly explains a data or permission limitation.

### Test 2: Device Lookup

```text
According to Microsoft Intune, tell me about the managed device {DeviceNameOrId}.
```

Expected result:

- The returned identity matches the selected Intune device.
- Available properties can include device name, ID, manufacturer, enrollment information, compliance state, or primary user.

### Test 3: Device Relationship

```text
According to Microsoft Intune, what groups is {DeviceNameOrId} in?
```

Expected result:

- The response returns only group information visible within the signed-in user's authorization boundary.

### Test 4: Application Assignment

```text
According to Microsoft Intune, which groups is {AppName} assigned to?
```

Expected result:

- The response identifies the intended application unambiguously and returns authorized assignment data.

### Test 5: Policy Applicability

```text
According to Microsoft Intune, why is {PolicyName} applying to {DeviceNameOrId}?
```

Expected result:

- The response uses available Intune policy, assignment, group, or applicability context.
- Unsupported details are identified as gaps rather than invented.

## Validate the Embedded Experience

1. In the Intune admin center, go to **Devices** > **All devices**.
2. Select a device visible to your account.
3. Select **Summarize with Copilot**.
4. Confirm Copilot Chat opens and returns the intended device context.
5. Ask one supported follow-up question, such as showing assigned policies or installed applications.
6. Compare material values with the device record in Intune.

For the complete workflow, use the [Device Investigation Guide](../Embedded%20Experiences/Device%20Investigation%20Guide.md).

## Record the Validation

Document:

- Security Copilot workspace and tenant tested
- Tester identity and assigned Intune role
- Relevant scope tags
- Plugin availability setting and enabled state
- Test time
- Prompts used
- Objects used for validation
- Expected and observed results
- Missing or unauthorized data
- Security Copilot session ID

Don't include sensitive prompt output in a ticket or report unless its destination is approved for that data.

## Validation Checklist

- [ ] Security Copilot is provisioned and capacity is available
- [ ] Tester can access the intended Security Copilot workspace
- [ ] Microsoft Intune is available and enabled under **Sources**
- [ ] Intune tenant integration reports Copilot enabled
- [ ] Intune system capabilities are visible
- [ ] Tenant-level test returns an authorized result
- [ ] Device, application, and policy tests use known objects
- [ ] Embedded device summary works
- [ ] Returned data matches authoritative Intune records
- [ ] RBAC and scope-tag limits are documented
- [ ] Session ID and validation evidence are retained appropriately

## Disable or Restrict the Plugin

Before changing availability, assess the effect on:

- Standalone Intune prompts in Security Copilot
- Copilot embedded experiences in Intune
- Promptbooks that depend on Intune capabilities
- Security Copilot agents that require the Intune plugin

A Security Copilot owner can restrict preinstalled plugin availability under **Owner** > **Plugin settings**. Restriction is immediate and can affect standalone and embedded users. Communicate the change, test with an affected persona, and maintain a rollback plan.

Agent-required plugins are enabled for the agent itself during agent setup. This agent-scoped activation doesn't change the plugin's broader availability or enabled state for users.

## Official References

- [Security Copilot in Microsoft Intune](https://learn.microsoft.com/en-us/intune/copilot/security-copilot)
- [Security Copilot in Intune features overview](https://learn.microsoft.com/en-us/intune/copilot/)
- [Manage plugins in Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/manage-plugins)
- [Roles and authentication in Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/authentication)
- [Privacy and data security in Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/privacy-data-security)

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
