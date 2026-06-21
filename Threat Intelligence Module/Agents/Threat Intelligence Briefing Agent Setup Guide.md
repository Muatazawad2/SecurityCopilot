# Threat Intelligence Briefing Agent Setup Guide

**Developer**: Dr Muataz Awad

## Overview

The Microsoft Security Copilot Threat Intelligence Briefing Agent generates automated threat intelligence briefings based on the latest threat actor activity and both internal and external vulnerability information. It helps security teams save time by creating customized, relevant reports that provide CISOs, security managers, and analysts with key situational awareness in a matter of minutes.

The agent leverages dynamic automation and deep generative AI to dynamically choose the next step based on the outcome of the previous step, allowing it to decide in real-time what threat intelligence to include and prioritize.

## Key Capabilities

- Automated threat intelligence briefing generation
- Correlation of internal and external vulnerability information
- Threat actor activity analysis
- Dynamic report customization based on organizational context
- Real-time threat intelligence integration
- Real-time activity tracking and transparency

## Required Products & Plugins

### Required:
- **Microsoft Security Copilot** - Core platform for running the agent
- **Microsoft Threat Intelligence** - Plugin required for threat data access

### Optional:
- **Microsoft Defender External Attack Surface Management** - Adds additional organizational attack surface context to the output

## Key Permissions

### For Setup & Administration:

**Required permissions:**
- **Microsoft Defender for Endpoint**: Access to Defender Vulnerability Management data
- **Security Copilot Contributor**: Access to Security Copilot platform and agent management

**Optional permissions:**
- **Exposure Management (read)**: Access to Microsoft Security Exposure Management insights, including External Attack Surface Management data

### Custom Role Creation (Recommended):

Microsoft recommends creating a custom read-only role for the agent:

1. Sign in to the [Microsoft Defender portal](https://security.microsoft.com/) as Security Administrator or higher
2. Navigate to **Permissions** → **Microsoft Defender XDR** → **Roles**
3. Select **Create custom role**
4. Configure as follows:
   - **Role name**: `Threat Intel Agent - Read Only`
   - **Description**: `Read-only access for Threat Intelligence Briefing Agent`
5. On the **Choose permissions** page:
   - Select **Security posture** → **Custom permissions**
   - Under **Posture management**, select **Vulnerability management** - **Read**
6. On the **Assign users and data sources** page:
   - Select **Add assignment**
   - **Assignment name**: `Threat Intel Agent Assignment`
   - **Employees**: Select the user account for the agent
   - **Data sources**: Select **Microsoft Defender for Endpoint**

## Infrastructure Prerequisites

1. Tenant onboarded to Microsoft Security Copilot
2. Microsoft Threat Intelligence plugin installed and enabled in Security Copilot
3. User account or agent identity created with appropriate permissions
4. Microsoft Defender for Endpoint configured with vulnerability data
5. (Optional) Microsoft Defender External Attack Surface Management enabled for additional context

## Deployment Steps

### Step 1: Create Agent Identity or Use Existing Account

1. Go to the **Agents** page in the [Microsoft Security Copilot](https://securitycopilot.microsoft.com/) standalone portal
2. Select **Threat Intelligence Briefing Agent** and choose **Set up**
3. Select an identity for the agent:
   - **Option A**: Create a new agent identity (recommended for separation of duties)
   - **Option B**: Use an existing user account
4. Wait for the agent to finish setting up

### Step 2: Assign Security Copilot Contributor Role (If Using Existing Account)

1. In [Microsoft Security Copilot](https://securitycopilot.microsoft.com/), select the home menu → **Role assignment** → **Add members**
2. Search for and select the user account
3. Assign **Security Copilot Contributor** role
4. Select **Add**

### Step 3 (Optional): Add External Attack Surface Management Permissions

If your organization uses Microsoft Defender External Attack Surface Management:

1. In the Microsoft Defender portal, go to **Permissions** → **Microsoft Defender XDR** → **Roles**
2. Find the `Threat Intel Agent - Read Only` role and select **Edit**
3. Navigate to **Choose permissions** → **Security posture** → **Select custom permissions**
4. Under **Posture management**, add **Exposure Management** - **Read**
5. In **Data sources**, add **Microsoft Security Exposure Management**
6. Save the changes

**Important**: Activate the [Microsoft Defender XDR Unified role-based access control (RBAC) model](https://learn.microsoft.com/en-us/defender-xdr/manage-rbac) for the role to take effect.

### Step 4: Configure Agent Parameters

1. On the setup parameters page, specify the following inputs to customize the output:
   - **Insights to research**: Number of vulnerabilities the agent researches for active threats
   - **Look back days**: How far back (in days) the agent researches threats against your vulnerabilities
   - **Email**: Email address of user or distribution group that the briefing is sent to
   - **Region**: Scope of geographical area the agent checks for threats
   - **Industry**: Sector or industry that the agent checks for threats
2. Select **Next** to continue

### Step 5: Complete Setup

1. Review the agent configuration
2. Select **Return to agents** to go back to the **Agents** page, or select **Go to agent** to view the Threat Intelligence Briefing Agent overview page

## Running the Agent

1. Go to the upper right of the agent overview page and select **Run**
2. Choose execution option:
   - **On the trigger**: Schedule the agent to run at the set time interval
   - **One time**: Run the report on demand immediately

## Agent Triggers

- **Scheduled**: Runs automatically at configured time intervals when enabled
- **On-demand**: Run manually whenever you need a fresh threat intelligence briefing

## Monitoring & Assessment

### View Generated Reports

1. Access the Threat Intelligence Briefing Agent page
2. Go to the **Activity** section to view all generated reports
3. The page displays:
   - Report name
   - Start time
   - Generation method (scheduled or on-demand)
   - Current status

### Review Report Output

1. Select a report from the Activity list to open it
2. The briefing contains:
   - Relevant summary of threat information
   - Detailed technical analysis
   - Currently exploited vulnerabilities and organizational impact assessment
   - Prioritized threat intelligence tailored to your region and industry

### Track Agent Progress

1. Select **View activity** to see agent's step-by-step progress
2. The activity map provides transparency on steps the agent takes to produce the output
3. This helps you understand the reasoning behind the briefing's focus areas

## Providing Feedback

After reviewing a generated briefing:

1. Select the **thumbs up** (helpful) or **thumbs down** (not helpful) button
2. Optionally elaborate your feedback in the text box that appears
3. Select **Submit** to send feedback to Microsoft for agent improvement

## Configuration Management

- **Edit Parameters**: Select the three dots in the upper right section of the agent overview page to modify parameters later
- **Update Settings**: You can change:
  - Insights to research
  - Look back days
  - Email recipients
  - Region scope
  - Industry scope

## Important Notes

- **Service Account Recommendation**: Consider using a dedicated service account for running agents to maintain separation of duties and enhance security monitoring
- **Least Privilege**: Microsoft recommends using roles with the fewest permissions needed for operation
- **Data Requirements**: Agent performs best when configured with Microsoft Defender External Attack Surface and Microsoft Defender for Endpoint enabled
- **Authentication**: Configuration authentication is valid for 90 days; re-authenticate after 90 days to maintain functionality
- **Unified RBAC**: Ensure Microsoft Defender XDR Unified role-based access control (RBAC) model is activated for permissions to take effect

## Best Practices

1. Use a dedicated agent identity or service account for audit trail and separation of duties
2. Configure region and industry parameters to match your organization's threat profile
3. Set appropriate "look back days" to balance threat freshness with data volume
4. Regularly review generated briefings and provide feedback to improve agent performance
5. Schedule briefings during off-hours to avoid impacting user experience
6. Distribute briefings to relevant security stakeholders via email recipients list
7. Monitor SCU consumption for cost management

## Troubleshooting

**Issue**: Agent fails to generate briefing
- **Solution**: Verify the user account has required Microsoft Defender for Endpoint permissions

**Issue**: Briefing lacks external threat context
- **Solution**: Ensure Microsoft Threat Intelligence plugin is properly enabled in Security Copilot

**Issue**: Briefing doesn't include EASM data
- **Solution**: Verify Microsoft Defender External Attack Surface Management is enabled and permissions are configured for Exposure Management (read)

**Issue**: Email distribution not working
- **Solution**: Verify email address is valid and user account has permission to send emails

## Additional Resources

- [Threat Intelligence Briefing Agent in Microsoft Defender](https://learn.microsoft.com/en-us/defender-xdr/threat-intel-briefing-agent-defender)
- [Get started with Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/get-started-security-copilot)
- [Microsoft Security Copilot Agents](https://learn.microsoft.com/en-us/copilot/security/agents)
- [Microsoft Defender XDR RBAC Management](https://learn.microsoft.com/en-us/defender-xdr/manage-rbac)
- [Microsoft Security Copilot Portal](https://securitycopilot.microsoft.com/)
