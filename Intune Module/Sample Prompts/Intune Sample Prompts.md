# Intune Sample Prompts

**Description**: A ready-to-use collection of Microsoft Security Copilot prompts for exploring Intune data, investigating managed devices, analyzing policies and settings, reviewing compliance, troubleshooting applications and updates, and generating Device query KQL. Replace placeholders with values from your environment.

## Before You Begin

- Security Copilot and the Microsoft Intune source must be enabled.
- Results are limited by your Intune RBAC permissions and scope tags.
- Copilot Chat and Explorer match natural-language requests to queries and prompts built into Intune. Type the sample, select the closest built-in suggestion, and complete its parameters.
- Available suggestions and data coverage evolve. If no matching suggestion appears, try the shorter discovery phrase shown in the sample heading.
- Device query requires the applicable Intune Advanced Analytics licensing and supported device configuration.
- Verify generated results and KQL before making a policy, group, device, or remediation change.

## Placeholder Reference

| Placeholder | Replace With |
|---|---|
| `{DeviceNameOrId}` | Intune device name or managed device ID |
| `{HealthyDeviceNameOrId}` | A known-good comparison device |
| `{Platform}` | Windows, Android, iOS/iPadOS, macOS, or another available platform |
| `{UserPrincipalName}` | User principal name, such as `user@contoso.com` |
| `{AppName}` | Application display name |
| `{PolicyName}` | Intune policy name |
| `{SettingName}` | Configuration or compliance setting name |
| `{ErrorCode}` | Error code shown in Intune or on the managed device |
| `{GroupName}` | Microsoft Entra group name |
| `{NumberOfDays}` | Investigation time window in days |
| `{ServiceName}` | Windows service name |
| `{RegistryKeyPath}` | Full Windows registry key path |
| `{FolderPath}` | Full Windows folder path |

## Device Investigation and Troubleshooting

Use these prompts in **Copilot Chat** from the Intune admin center. Select the matching suggested prompt and provide the requested device parameter.

### 1. Summarize a managed device

```text
Summarize the Intune device {DeviceNameOrId}.
```

### 2. Show applications installed on a device

```text
Show the applications installed on the Intune device {DeviceNameOrId}.
```

### 3. Show policies assigned to a device

```text
Show the configuration, compliance, and app configuration policies assigned to the device {DeviceNameOrId}.
```

### 4. Show device group memberships

```text
Show the group memberships for the Intune device {DeviceNameOrId}.
```

### 5. Identify the primary user

```text
Show the primary user of the Intune device {DeviceNameOrId}.
```

### 6. Compare a problem device with a healthy device

```text
Compare the Intune device {DeviceNameOrId} with the healthy device {HealthyDeviceNameOrId}. Show their similarities and differences in hardware, compliance policies, and device configurations.
```

### 7. Analyze an Intune error code

```text
Analyze Intune error code {ErrorCode}. Explain what it means, its likely causes, and the recommended troubleshooting steps.
```

### 8. Find all noncompliant devices

```text
Show me all noncompliant devices.
```

## Intune Data Exploration

Use these requests in **Explorer**. Start typing the request, select the closest built-in query suggestion, fill in its parameters, and then select **Get results**.

### 9. Find noncompliant devices by platform

```text
Get {Platform} devices that are noncompliant.
```

### 10. Find devices past the compliance grace period

```text
Show noncompliant devices that are past the compliance grace period.
```

### 11. Find devices that have not checked in recently

```text
Show devices that have not checked in during the last {NumberOfDays} days.
```

### 12. Review the most common applications

```text
What are the top five applications across managed devices?
```

### 13. Find devices with a specific application

```text
Show managed devices with {AppName} installed.
```

### 14. Find application installation failures

```text
Show devices where the installation of {AppName} failed.
```

### 15. Find users affected by compliance issues

```text
Show users who have noncompliant managed devices on {Platform}.
```

### 16. Review device update status

```text
Show {Platform} devices that need operating system updates.
```

### 17. Review Windows Autopilot deployment failures

```text
Show Windows Autopilot deployments that failed during the last {NumberOfDays} days.
```

### 18. Review devices belonging to a user

```text
Show all Intune managed devices associated with {UserPrincipalName}.
```

## Policy, Compliance, and Settings Analysis

Use policy-level prompts from the selected policy or setting in the Intune admin center. For an existing configuration policy, select **Summarize with Copilot** when that action is available.

### 19. Summarize a configuration policy

```text
Summarize the Intune policy {PolicyName}. Include its purpose, configured settings, assignments, and expected effect on users and devices.
```

### 20. Explain a policy setting

```text
Explain the Intune setting {SettingName}, including what it controls and the behavior of each available value.
```

### 21. Request a recommended setting value

```text
Does Microsoft recommend a particular value for {SettingName}? Explain the recommendation and any prerequisites or tradeoffs.
```

### 22. Assess user impact

```text
How could the setting {SettingName} affect users and their workflows?
```

### 23. Assess security impact

```text
How could the setting {SettingName} affect the security posture of managed devices?
```

### 24. Find the setting in other policies

```text
Has {SettingName} been configured in any other Intune policies? Show the policies and configured values.
```

### 25. Analyze a compliance policy

```text
Analyze the compliance policy {PolicyName}. Summarize its settings, assignments, user impact, and security impact.
```

### 26. Look for conflicting compliance settings

```text
Show compliance policies that have conflicting settings with {PolicyName}. Identify each conflicting setting and value.
```

## Endpoint Administration and Governance

Use these requests in **Explorer** and select the closest available built-in suggestion.

### 27. Review recent Intune audit activity

```text
Show Intune audit events performed by {UserPrincipalName} during the last {NumberOfDays} days.
```

### 28. Review Intune role assignments

```text
Show Intune RBAC role assignments for {UserPrincipalName}.
```

### 29. Review Endpoint Privilege Management requests

```text
Show Endpoint Privilege Management elevation requests that are pending review.
```

### 30. Find members of a deployment group

```text
Show the users and devices in the group {GroupName}.
```

## Single-Device Query Generation

Open **Devices** > **All devices** > select a supported Windows device > **Monitor** > **Device query**. Enter these requests in Copilot Chat to generate KQL. Review the generated KQL before running it because Device query supports a defined subset of KQL entities, operators, and functions.

### 31. Check Microsoft Defender service status

```text
Is Microsoft Defender running on this device?
```

### 32. Find recent application crashes

```text
Show the last five application crash events on this device.
```

### 33. Find memory-intensive processes

```text
Show the top 10 processes using the most memory on this device.
```

### 34. Find expired certificates

```text
Show expired certificates on this device.
```

### 35. Check TPM 2.0 support

```text
Does this device support TPM 2.0?
```

### 36. Review installed Windows updates

```text
Show the Windows hotfixes installed on this device, ordered by installation date.
```

### 37. Review disk encryption state

```text
Show the encryption status of all encryptable volumes on this device.
```

### 38. Review drivers by provider

```text
Show drivers on this device grouped by provider name.
```

### 39. Review a Windows service

```text
Show the status and start mode of the Windows service {ServiceName} on this device.
```

### 40. Review a registry value

```text
Show the value of registry key {RegistryKeyPath} on this device.
```

### 41. Review recently created files

```text
Show the 20 most recently created files in {FolderPath} on this device.
```

## Multi-Device Query Generation

Open **Devices** > **Device query** to query supported properties across multiple devices. Availability depends on your Intune licensing, permissions, and device support.

### 42. Find unencrypted devices

```text
Which devices are not encrypted?
```

### 43. Find Windows 11 devices

```text
Show Windows 11 devices.
```

### 44. Find devices with TPM 2.0

```text
Show devices that support TPM 2.0.
```

### 45. Find devices missing recent patches

```text
Which devices have not been patched in the last 30 days?
```

### 46. Group devices by manufacturer

```text
Show devices sorted by manufacturer.
```

## Suggested Investigation Sequences

### Noncompliant Device

1. Run prompt 9 to identify noncompliant devices for the affected platform.
2. Run prompt 1 for the selected device.
3. Run prompt 3 to review its assigned policies.
4. Run prompt 6 against a known-good device when comparison is useful.
5. Use prompts 31-41 to collect current device evidence when Device query is available.

### Application Deployment Failure

1. Run prompt 14 to find affected devices.
2. Run prompt 2 to confirm application inventory on one affected device.
3. Run prompt 7 with the reported installation error.
4. Run prompts 32, 39, or 40 when the failure requires current endpoint evidence.

### Policy Change Review

1. Run prompt 19 to establish the policy's purpose and assignments.
2. Run prompts 20-24 for each material setting.
3. Run prompt 26 to investigate possible conflicts.
4. Validate the output against the policy configuration and organizational change requirements.

## Official References

- [Security Copilot in Intune features overview](https://learn.microsoft.com/en-us/intune/copilot/)
- [Explore Intune data with natural language](https://learn.microsoft.com/en-us/intune/copilot/explorer)
- [Use Copilot in Intune to troubleshoot devices](https://learn.microsoft.com/en-us/intune/copilot/troubleshoot-devices)
- [Device query in Microsoft Intune](https://learn.microsoft.com/en-us/intune/advanced-analytics/device-query)

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
