# Policy Configuration Agent Setup and Operations Guide

## Status

**Public preview**. Confirm current availability and requirements in Microsoft Learn before production use.

## Overview

The Microsoft Intune Policy Configuration Agent converts natural-language requirements and uploaded baseline documents into suggested Windows settings catalog configurations. It can:

- Parse internal standards and industry benchmarks.
- Map requirements to supported Intune settings and recommended values.
- Identify unsupported requirements and low-confidence mappings.
- Produce a policy draft that an administrator can review.
- Create an unassigned settings catalog policy after administrator confirmation.

The agent doesn't approve or deploy a policy. A created policy has no effect until an authorized administrator reviews and assigns it.

## Scope and Limits

- Supports Windows settings catalog policies.
- Accepts direct natural-language instructions or one uploaded knowledge-source file at a time.
- Supports text files up to 25 KB.
- Input quality affects mapping quality; use clear, atomic requirements.
- Only one agent instance is supported per tenant.
- The setup identity and permissions constrain the agent's actions.
- Authorization can expire after 90 days of inactivity.

## Prerequisites

### Cloud and Licensing

- Public cloud tenant; government clouds aren't supported.
- Microsoft Intune Plan 1.
- Microsoft Security Copilot with sufficient SCUs.
- Microsoft Intune plugin enabled in Security Copilot.

### Roles and Permissions

To enable and configure the agent:

- Security Copilot **Copilot owner**.
- Intune **Read Only Operator**, or a custom role with **Device configurations/Read**.

To generate and review recommendations:

- Security Copilot **Copilot contributor**.
- Intune **Read Only Operator**, or equivalent **Device configurations/Read** permission.

To create an Intune policy from a draft:

- Security Copilot **Copilot contributor**.
- Intune **Policy and Profile Manager**, or a custom role with **Device configurations/Create** and **Device configurations/Update**.

Policy assignment requires the applicable Intune assignment permissions and organizational change approval.

## Prepare the Requirements

Before uploading a document or entering instructions:

1. Use one requirement per sentence or bullet.
2. State the Windows scope and expected control behavior.
3. Include required values, exceptions, and prerequisites explicitly.
4. Remove contradictory, obsolete, or duplicated requirements.
5. Classify the source and confirm that uploading it complies with organizational data-handling rules.
6. Split documents larger than 25 KB into coherent, independently reviewed sources.

## Set Up the Agent

1. Confirm the licenses, Security Copilot capacity, Intune plugin, and required roles.
2. In the [Microsoft Intune admin center](https://intune.microsoft.com), go to **Agents** > **Policy Configuration Agent**.
3. On **Overview**, select **Set up agent**.
4. Review the permissions, identity, plugin, workspace, and setup requirements.
5. Select **Set up agent**.
6. Confirm that **Overview**, **Knowledge**, **Suggestions**, and **Settings** are available.

## Add a Knowledge Source

1. Go to **Agents** > **Policy Configuration Agent**.
2. Select **Create new** > **Knowledge source**.
3. Enter a descriptive name and optional description.
4. Upload one supported document.
5. Select **Review** and wait for the analysis to finish.
6. Review every identified setting, proposed value, source requirement, and confidence score.
7. Record unsupported requirements and define a separate control or exception owner.
8. Give additional scrutiny to low-confidence mappings.
9. Save a mapping only after validating it against the source requirement and current Intune settings documentation.

## Create and Review a Policy Draft

1. Select **Create new** > **Policy draft**.
2. Enter a policy name and optional description.
3. Select a knowledge source when applicable.
4. Add precise natural-language instructions for the policy outcome.
5. Select **Create** and open the resulting suggestion.
6. Review the AI summary, every setting and value, parent and child settings, confidence scores, unsupported items, and exported CSV when needed.
7. Remove mappings that are incorrect, unsupported, or outside the approved scope.
8. Select **Create configuration policy** only after technical and change-owner review.
9. In the settings catalog, review the generated policy again before saving it.

The created policy remains unassigned. Use a separate approved workflow to pilot, assign, monitor, and roll back the policy.

## Validation Checklist

- [ ] Source requirements are current and authorized
- [ ] Every requirement has an identified mapping or documented gap
- [ ] Low-confidence mappings received manual review
- [ ] Unsupported controls have an owner or compensating control
- [ ] Generated settings and values match the approved intent
- [ ] Parent, child, and automatically added settings are reviewed
- [ ] Overlap with existing policies is assessed
- [ ] A representative pilot group and exclusions are defined
- [ ] Success, stop, rollback, and monitoring criteria are approved
- [ ] The policy remains unassigned until change approval is complete

## Identity, Renewal, and Removal

The agent uses the identity and permissions selected during setup. If it isn't used for 90 days, authorization can expire. Follow the warning in the Intune agent page to renew authentication or select another authorized identity.

To remove the agent:

1. Go to **Agents** and select the Policy Configuration Agent instance.
2. Select **Remove agent** and confirm.

Removing the agent deletes its generated suggestions and activity data. Policies already created in Intune remain and must be governed separately.

## Official References

- [Policy Configuration Agent overview and setup](https://learn.microsoft.com/en-us/intune/copilot/agents/policy-configuration-agent)
- [Use the Policy Configuration Agent](https://learn.microsoft.com/en-us/intune/copilot/agents/manage-policy-configuration-agent)
- [Intune settings catalog](https://learn.microsoft.com/en-us/intune/device-configuration/settings-catalog/)

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
