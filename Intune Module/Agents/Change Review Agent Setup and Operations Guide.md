# Change Review Agent Setup and Operations Guide

## Status

**Public preview**. Confirm current availability and requirements in Microsoft Learn before production use.

## Overview

The Microsoft Intune Change Review Agent evaluates Multi Admin Approval requests for PowerShell scripts targeting Windows devices. It combines signals from Intune, Microsoft Entra ID, Microsoft Defender Vulnerability Management, and Microsoft Threat Intelligence to recommend one of three outcomes:

- **Approve** for a request assessed as low risk
- **Reject** for a request assessed as high risk
- **Needs more info** when the available evidence is insufficient

The recommendation is advisory. An authorized Intune administrator must review the evidence and make the final approval or rejection decision.

## Scope and Limits

- Supports Windows PowerShell script requests protected by Multi Admin Approval.
- Evaluates a maximum of 10 requests per run.
- Runs manually from the Intune admin center; scheduled runs aren't supported.
- A run can't be stopped or paused after it starts.
- Only one agent instance is supported per tenant and user context.
- Uses the identity and permissions of the administrator account used during setup.

## Prerequisites

### Cloud and Licensing

- Public cloud tenant; government clouds aren't supported.
- Microsoft Intune Plan 1.
- Microsoft Entra ID P2.
- Microsoft Defender Vulnerability Management.
- Microsoft Security Copilot with sufficient security compute units (SCUs).
- Multi Admin Approval configured for the PowerShell script workflow you want the agent to assess.

### Required Plugins

Enable and authorize these Security Copilot plugins:

- Microsoft Intune
- Microsoft Entra
- Microsoft Defender XDR
- Microsoft Threat Intelligence

### Roles and Permissions

Use least privilege and verify the live Microsoft prerequisite page before assignment.

To set up and configure the agent, the setup account requires:

- Security Copilot **Copilot owner**.
- Microsoft Entra **Intune Administrator** and **Security Reader** access.
- Read access to risky-user information.
- Microsoft Defender vulnerability-management read access through Unified RBAC Security Reader or an equivalent granular role.
- Scope to every Defender device group whose signals must be evaluated.

To run and review the agent, the operator requires:

- Security Copilot **Copilot contributor**.
- Intune **Read Only Operator** or equivalent custom read permissions.
- Microsoft Entra **Security Reader**.
- Equivalent Defender read access to the data used by the agent.

Approving or rejecting a request still requires the applicable Multi Admin Approval permissions and separation-of-duties rules.

## Set Up the Agent

1. Confirm Security Copilot capacity, plugins, licenses, roles, and Defender device-group scope.
2. In the [Microsoft Intune admin center](https://intune.microsoft.com), go to **Agents** > **Change Review Agent**.
3. On **Overview**, select **Set up Agent**.
4. Review the setup pane, including permissions, plugins, workspace, and identity.
5. Select **Start agent** when all requirements are satisfied.
6. Wait for the first run to complete and confirm that **Overview** shows activity and suggestions.

## Review Agent Results

The agent provides three tabs:

- **Overview** shows availability, run status, top suggestions, and recent activity.
- **Suggestions** shows the complete list of evaluated requests.
- **Settings** shows the identity, permissions, plugins, and configured job type.

For each suggestion:

1. Open the item under **Suggested Next Steps**.
2. Confirm the request name, requester, expiration, resource type, and current status.
3. Review the suggested action, script summary, rationale, and all evaluation factors.
4. Inspect the PowerShell script independently. Validate publisher, source, parameters, obfuscation, network behavior, persistence, privilege use, and expected device scope.
5. Resolve any **Needs more info** gaps with authoritative evidence.
6. Select **View request** to open the Multi Admin Approval workflow.
7. Add an approver note and independently select **Approve request** or **Reject request**.

Never approve a request solely because the agent recommends approval.

## Run the Agent Again

1. Go to **Agents** > **Change Review Agent**.
2. Select **Run** above the agent tabs.
3. Wait for evaluation to finish; the run can't be paused or stopped.
4. Review refreshed suggestions and activity.

The setup identity can expire after 90 consecutive days without a run. Monitor identity warnings and renew or reconfigure authorization as directed by the current Intune interface before expiration.

## Validation Checklist

- [ ] Required licenses and SCUs are available
- [ ] All four plugins are enabled
- [ ] Setup and operator roles follow least privilege
- [ ] Defender device-group scope covers the intended devices
- [ ] Multi Admin Approval is configured for PowerShell scripts
- [ ] First run completes successfully
- [ ] Recommendations include rationale and factors
- [ ] Script content receives independent technical review
- [ ] Final action is taken by an authorized administrator
- [ ] Approver decision and evidence are recorded

## Remove the Agent

1. In the Intune admin center, go to **Agents**.
2. Select the Change Review Agent instance.
3. Select **Remove agent** and confirm.

Removing the agent deletes its suggestions and activity data. It doesn't reverse approval or rejection decisions already completed through Multi Admin Approval.

## Official References

- [Change Review Agent overview and setup](https://learn.microsoft.com/en-us/intune/copilot/agents/change-review-agent)
- [Use the Change Review Agent](https://learn.microsoft.com/en-us/intune/copilot/agents/manage-change-review-agent)
- [Multi Admin Approval in Microsoft Intune](https://learn.microsoft.com/en-us/intune/fundamentals/role-based-access-control/multi-admin-approval)

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
