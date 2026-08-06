# Device Offboarding Agent Retirement Reference

## Status

**Retired and unavailable** as of June 1, 2026.

Microsoft stopped new setup of the Device Offboarding Agent on April 30, 2026 and removed the agent from the Intune admin center on June 1, 2026. Don't design new workflows, dependencies, setup procedures, or training labs around this agent.

## Historical Purpose

Before retirement, the Device Offboarding Agent evaluated signals from Microsoft Intune and Microsoft Entra ID to identify stale or misaligned devices. It produced recommendations, required explicit administrator approval, and could disable corresponding Entra device objects after approval. Other cleanup actions remained administrator-led.

The historical agent supported Intune-managed Windows, iOS/iPadOS, macOS, Android, and Linux devices, but excluded scenarios including hybrid Entra-joined Windows devices, Windows Autopilot devices, shared devices, and Microsoft Teams Phones.

## Required Transition

Use standard, supported Intune and Microsoft Entra device lifecycle controls instead of the retired agent:

1. Define stale-device criteria appropriate to each platform and ownership model.
2. Use Intune inventory, reports, Explorer, or Microsoft Graph through an approved process to identify candidates.
3. Validate last check-in, ownership, primary user, Autopilot state, Entra activity, business purpose, legal hold, and recovery requirements.
4. Exclude shared, privileged, executive, kiosk, emergency-access, and other protected device cohorts as required.
5. Obtain explicit approval from the device lifecycle owner.
6. Select the correct action for the management and ownership state, such as retire, wipe, delete, or disable.
7. Validate effects separately in Intune, Microsoft Entra ID, Microsoft Defender, Apple Business Manager, Managed Google Play, or other connected systems.
8. Record the decision, approver, action, time, and validation evidence.

## Safety Considerations

- **Retire**, **wipe**, **delete**, and **disable** have different effects and aren't interchangeable.
- Confirm whether the device is corporate-owned or personally owned before choosing an action.
- Check Windows Autopilot and enrollment records before deleting device objects.
- Disabling an Entra device object can affect authentication but doesn't remove all management or third-party records.
- Intune cleanup rules and Entra stale-device processes must be tested against protected cohorts before broad use.
- Keep human approval for destructive or access-affecting actions.

## Historical Documentation Notice

Microsoft's Device Offboarding Agent article remains useful for retirement dates and historical behavior, but its setup instructions are no longer actionable. The broader Intune agents overview can temporarily continue to list the retired agent, so use the dated retirement notice as the controlling availability statement.

## Official References

- [Device Offboarding Agent retirement notice](https://learn.microsoft.com/en-us/intune/copilot/agents/device-offboarding-agent)
- [Manage stale devices in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/devices/manage-stale-devices)
- [Remote device actions in Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-management/manage-endpoint-security-devices#remote-actions-for-devices)

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
