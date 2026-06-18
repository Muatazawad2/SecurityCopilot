# Entra ID Prompt Samples

Source scenarios:
- https://learn.microsoft.com/en-us/entra/security-copilot/entra-id-scenarios
- https://learn.microsoft.com/en-us/entra/security-copilot/entra-enterprise-user-management
- https://learn.microsoft.com/en-us/entra/security-copilot/entra-monitoring-operations
- https://learn.microsoft.com/en-us/entra/security-copilot/entra-security-access-control

**Developer**: Dr Muataz Awad

## Tenants

- What is my tenant's display name?
- What is my tenant ID?
- Can users in my tenant create new tenants?
- What are all the active licenses assigned to my tenant?
- Who is the technical contact for my tenant?
- Who is the security compliance contact for my tenant?

## Users

### User information and details

- Show recently deleted users.
- Tell me about myself.
- Are there guest users in the Human Resources department?
- Show transitive reports of Brandon Artois.
- Give the member count of each department.
- Who is Asha Brunelle's manager?
- Is Blake Martin's account cloud managed?
- Show users by mail nickname.

### User authentication and permissions

- What are Abbi Atin's authentication methods?
- Look up Abadi Bod's permissions.
- How many users are reporting to Brandon Artois?

### User filtering and organization

- List users without assigned licenses.
- List users in Finance or Marketing department.
- Show users not in {Company Name}.
- Show users with account disabled.
- Are there any users with {Specific license}?

## Groups

### Group membership and composition

- Count the total ownerless groups in my tenant.
- Count the total user memberships for a group.
- Provide separate counts for users, groups, devices, and service principals in a group.
- How many different object types does a group have in total?
- Show me all user members of a group.
- Which users are included in a group?

### Group configuration and roles

- What directory roles are assigned to a group?
- Does this group have any built-in roles?
- Show me the membership rules for a group.
- Is the dynamic membership rule currently processing for a group?
- Give me the details of a group.

### Group organization and governance

- Show the count of groups categorized by group type.
- List the number of groups under each of the group types.
- How many groups exist for each group type?

## Domains

- List details of contoso.com.
- Show me DNS verification records of contoso.com.
- What is my initial domain name?

## Licenses

- How many Microsoft Entra P1/P2 licenses do I have?
- Count of P1/P2 Microsoft Entra licenses.
- Number of Microsoft Entra ID P1/P2 licenses.
- What is the usage of Microsoft Entra P1/P2 license?
- Show me P1/P2 feature utilization.
- Provide Microsoft Entra P1/P2 license usage details.

## Sign-in Logs

### Application and authentication analysis

- Show sign-ins to a specific application.
- Show sign-ins without multifactor authentication.
- Show sign-in failures due to a specific Conditional Access policy.
- Show sign-ins with unsatisfied Conditional Access Policies.

### Device and location analysis

- Show sign-ins from non-compliant devices.
- Show logins from specific web browsers.
- Show logins from specific operating systems.
- Show sign-ins from specific locations.

### User activity and security monitoring

- Show sign-in activities since a specific time period.
- Show sign-in activity for the user Casey Jensen.
- Show suspicious login activities.
- Display risky sign-ins.

## Audit Logs

### Group management activities

- Show me recently deleted groups.
- What groups were deleted recently?
- Last deleted groups in my directory?
- Who created this group?
- Find out who created a specific group.
- Group creation details.
- What groups were created by these users?
- Show groups created by specific users.
- List all groups created by the user Casey Jensen.

### Security and authentication activities

- Show me risky sign-ins.
- List suspicious logins.
- Are there any risky authentications?
- List jobs for this service principal.

## Provisioning Logs

### User provisioning monitoring

- Show provisioning logs for this user.
- Get provisioning history for user.
- Show user provisioning activity.
- Show recent provisioning events for this user.

### Provisioning failure analysis

- Show provisioning failures.
- List all failed provisioning attempts.
- Show the provisioning error logs.

### Provisioning success tracking

- Show the successful provisioning deletions.
- Were any users successfully deleted by the provisioning service?
- Show successful provisioning disables.
- Were any users successfully disabled by the provisioning service?
- Show successful provisioning creates.
- List successful object creations.

### Provisioning job status monitoring

- Check provisioning job status.
- Is my provisioning job completed?
- Show provisioning jobs for this service principal.

## Recommendations

### General recommendations and secure score

- List all Entra recommendations.
- Show my tenant's historical Secure Score data.
- Show Entra recommendation "example" and its details.
- Show the resources affected by an Entra recommendation.
- Show resource "example" of Entra recommendation "example".
- List secure score recommendations.
- List best practice recommendations.

### Targeted recommendations by category

- List recommendations for conditional access policies.
- Show Entra recommendations for a specific feature area.
- List high-priority recommendations.
- List recommendations with high priority.
- List recommendations that are active.
- List recommendations to improve app portfolio health.
- List recommendations to reduce surface area risk.
- List recommendations to improve security posture of my apps.
- List recommendations for tenant configuration.
- Show Entra recommendations by impact type.

### Application credential management

- Which enterprise applications have credentials about to expire?
- Show me service principals with credentials that are expiring soon.
- Show me applications with credentials that are expiring soon.
- Which of our apps are stale or unused in the tenant?
- List the unused apps.

## Health Monitoring Alerts

### Health alert monitoring

- What health alerts do I have in my tenant?
- List all active health monitoring alerts.
- What are my recent health monitoring alerts?
- What users are impacted according to the active health monitoring alerts?
- Show me health monitoring alert details for alert ID [alertId].

### Scenario-specific health monitoring

- Show me health monitoring alerts related to MFA sign in failure.
- Show me managed device health monitoring alerts.
- Show me compliant device health monitoring alerts.
- Show me device scenario health monitoring alerts.

## Service Level Agreement

- What is my SLA for Microsoft Entra authentication?
- What is my Microsoft Entra SLA?
- What is the SLA of Microsoft Entra authentication?
- Show me my tenant's authentication availability.
- Has my tenant had an SLA breach in the last "X" months?

## Roles and Administrators

### Role assignment queries

- What role does user/group/app (name/email/ID) have?
- What are the transitive roles user/group/app (name/email/ID) has?
- What are the eligible roles user/group/app (name/email/ID) has?
- What are the scheduled roles user/group/app (name/email/ID) has?
- Who has the Cloud Application Administrator role assigned to them?
- Who has eligibility for the Global Reader role?

### Role information and identification

- What is the ID of role (role name)
- Name of the role with ID 5d6b6bb7-de71-4623-b4af-96380a352509

## Devices

### Device identification and status

- Show me the device for with an ID of {ID}
- Show me all compliant devices/Show me all non-compliant devices.
- List devices that are not under management.
- How many devices are there?

### Device join types and configuration

- List all devices that are Entra ID registered/Entra ID joined/Entra ID hybrid joined.
- How many devices exist for each device trust type?

### Device activity and operating systems

- Show me when device {ID} was last active.
- List the devices with specific {operating system name}.
- Show me how many devices are running Windows (8,10,11).
- Show the count of Windows devices categorized by release.

## Conditional Access

### Policy identification and status

- Authentication strength policies.
- Conditional Access policy by name.
- Active Multifactor Authentication Conditional Access Policies.
- Enforced MFA policies.
- Enabled Conditional Access Policies.
- CA Policies currently enforced.
- Actively enforced CA Policies.

### Policy configuration and management

- Conditional Access Policies to enable.
- What CA Policies are not currently enabled?
- What policies can I enable?
- List inactive Conditional Access Policies/
- Conditional Access Policies.
- List CA policies.
- What CA Policies not applicable to trusted locations?
- Conditional Access Policies excluding all trusted locations.
- Get all conditional access policies for user considering the groups.

## Authentication

### Authentication method configuration

- What authentication methods are enabled in my tenant?
- Is Microsoft Authenticator enabled in my tenant? For who?
- Is registration campaign enabled in my tenant? For who?
- Is system preferred authentication enabled in my tenant? For who?
- Is report suspicious activity enabled in my tenant? For who?

### User authentication status

- What authentication methods does karita@woodgrovebank.com have registered?
- Is user karita@woodgrovebank.com enabled for per-user MFA?
- How many users have the FIDO2 Security keys method registered?

## Session Hygiene

- Activate the {required role} so that I can perform {the desired task}.
- I am done with my investigation or {desired task}, deactivate my access.
