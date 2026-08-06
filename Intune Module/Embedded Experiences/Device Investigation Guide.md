# Device Investigation Guide

## Overview

This guide explains how to investigate and troubleshoot a managed device in the Microsoft Intune admin center by using the Microsoft Security Copilot embedded experience. The workflow starts with a device summary, narrows the investigation with contextual prompts, and optionally uses device query for current device evidence.

## Prerequisites

Before starting, confirm that:

- Microsoft Security Copilot is provisioned and its first-run setup is complete.
- The Microsoft Intune source is enabled in the Security Copilot portal.
- Copilot is enabled under **Tenant administration** > **Copilot** in the Intune admin center.
- Your account has Security Copilot access and the required Intune role-based access control permissions and scope tags.
- Security Copilot capacity is available.

Copilot honors existing Intune RBAC permissions and scope tags. It can only return Intune data that the signed-in administrator is authorized to access.

## Investigate a Device

### 1. Open the Intune Admin Center

Go to [https://intune.microsoft.com](https://intune.microsoft.com) and sign in with your administrator account.

### 2. Select the Device

Go to **Devices** > **All devices**, then select the managed device you want to investigate.

Choose a device tied to the support case, compliance issue, or security concern you are reviewing. Confirm the device name and primary user before continuing so that the investigation remains scoped to the intended endpoint.

### 3. Summarize with Copilot

On the device page, select **Summarize with Copilot**.

Copilot Chat opens and runs the device summary prompt. Review the response for available device context, such as installed applications, group membership, and other device-specific information exposed through Intune.

### 4. Review the Summary

Use the initial response to establish the investigation baseline:

- Confirm that the returned device identity matches the selected endpoint.
- Note compliance, configuration, application, or management signals that require follow-up.
- Distinguish observed Intune data from Copilot-generated interpretation or recommendations.
- Record material findings in the relevant incident, change, or support record.

### 5. Ask Focused Follow-Up Questions

Continue in Copilot Chat with one question at a time. Example questions include:

- Which applications are installed on this device?
- Which groups is this device a member of?
- Summarize the device information that could explain its compliance issue.
- What additional Intune data should I review before remediating this device?
- Explain the reported error code and suggest investigation steps.

Copilot suggestions change dynamically as you type. Prefer a suggested Intune prompt when one matches the investigation because supported prompts define the data and actions available to the embedded experience.

### 6. Use Device Query for Deeper Evidence (Optional)

Device query requires a license that includes Microsoft Intune Advanced Analytics.

For a single device, go to **Devices** > **All devices** > select the device > **Monitor** > **Device query**. In Copilot Chat, ask for device information that device query supports. Copilot can generate a Kusto Query Language (KQL) query and explain how it answers the request.

Example questions include:

- Is Microsoft Defender running on this device?
- Show the last five application crash events on this device.
- Does this device support TPM 2.0?
- Show expired certificates on this device.

Review the generated KQL before running it. Device query can only answer questions covered by its supported properties.

### 7. Validate and Decide

Before making a change:

1. Compare Copilot's response with the device overview, compliance results, configuration status, discovered applications, and recent check-in data available to you.
2. Confirm that evidence is current and belongs to the intended device.
3. Follow organizational approval and change-control requirements.
4. Document the evidence used and the action selected.

Do not treat a generated recommendation as authorization to retire, wipe, reconfigure, or otherwise remediate a device.

## Investigation Checklist

- [ ] Security Copilot and the Intune source are enabled
- [ ] Correct device and primary user confirmed
- [ ] Device summary reviewed
- [ ] Material signals investigated with focused prompts
- [ ] Optional device query reviewed and executed when needed
- [ ] Findings validated against authoritative Intune data
- [ ] Decision and supporting evidence documented

## Troubleshooting

### Copilot Is Not Available

Verify the following:

- Security Copilot configuration and first-run setup are complete.
- **Tenant administration** > **Copilot** shows Copilot as enabled.
- The Microsoft Intune source is enabled in Security Copilot.
- Your account has an appropriate Security Copilot role.
- Security Copilot capacity is available.

### Expected Device Data Is Missing

- Confirm your Intune RBAC permissions and scope tags.
- Verify that the device is managed by Intune and has recent check-in data.
- Check whether the requested information is supported by the selected Copilot prompt or device query property.
- Narrow the request to one device attribute or troubleshooting question.

### A Generated Device Query Does Not Run

- Confirm that the tenant has an Intune license that includes Advanced Analytics.
- Check that the requested property is supported by device query.
- Review the generated KQL syntax and scope before execution.

## Official References

- [Security Copilot in Intune features overview](https://learn.microsoft.com/en-us/intune/copilot/)
- [Get started with Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/get-started-security-copilot)
- [Roles and authentication in Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/authentication)
- [Device query in Microsoft Intune](https://learn.microsoft.com/en-us/intune/advanced-analytics/device-query)

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
