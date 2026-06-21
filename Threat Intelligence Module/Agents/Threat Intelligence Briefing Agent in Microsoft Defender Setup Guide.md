# Threat Intelligence Briefing Agent in Microsoft Defender Setup Guide

**Developer**: Dr Muataz Awad

## Overview

The Microsoft Security Copilot Threat Intelligence Briefing Agent embedded in Microsoft Defender XDR generates automated threat intelligence briefings based on the latest threat actor activity and internal and external vulnerability information. Accessed directly from the Threat analytics page in the Microsoft Defender portal, it helps security teams quickly generate customized, relevant reports that provide CISOs, security managers, and analysts with key situational awareness and a foundation for defense work.

The agent uses dynamic automation and generative AI to pick each next step based on the result of the previous one, deciding in real-time which threats to include and rank, then turning collected threat intelligence and vulnerability findings into a clear, consumable report.

## Key Capabilities

- Automated threat intelligence briefing generation from the Threat analytics dashboard
- Correlation of internal and external vulnerability information
- Threat actor activity analysis contextualized to your organization
- Dynamic report customization based on region and industry
- Real-time activity tracking with step-by-step transparency
- Report generation, download, and sharing capabilities
- Scheduled or on-demand briefing execution
- Embedded feedback mechanism for continuous improvement

## Required Products & Plugins

### Required:
- **Microsoft Security Copilot** - Core platform for running the agent
- **Microsoft Threat Intelligence** - Plugin required for threat data access
- **Microsoft Threat Intelligence agents** - Plugin required for agent functionality

### Optional:
- **Microsoft Defender External Attack Surface Management** - Adds external attack surface context to the output

## Key Permissions

### For Setup & Administration:

**Required permissions:**
- **Microsoft Defender for Endpoint**: Access to Defender Vulnerability Management data
- **Security Reader**: Access to Threat Analytics and agent results
- **Security Admin**: Access to agent onboarding and configuration

**Optional permissions:**
- **Exposure Management (read)**: Access to Microsoft Security Exposure Management insights, including External Attack Surface Management data

### Agent Identity Setup (Recommended)

Microsoft recommends using a dedicated agent identity (service principal) rather than a user account for:
- Separation of duties
- Audit trail tracking
- Enhanced security monitoring
- Least-privilege access implementation

## Infrastructure Prerequisites

1. Microsoft Security Copilot provisioned and active
2. Microsoft Threat Intelligence and Microsoft Threat Intelligence agents plugins installed
3. Microsoft Defender for Endpoint configured with vulnerability data
4. Access to Microsoft Defender portal as Security Admin or higher
5. Azure CLI installed and authenticated (for service principal creation)
6. Tenant-level admin rights (for agent identity registration)
7. (Optional) Microsoft Defender External Attack Surface Management enabled

## Setting Up Agent Identity (Recommended)

### Prerequisites for Agent Identity Setup:
- Tenant-level admin rights to register a service principal and assign roles
- Azure CLI installed and authenticated (`az login`)
- Access to Defender unified RBAC or equivalent permissions management

### Step 1: Create or Reuse a Least-Privileged Role

1. In the Microsoft Defender portal, navigate to **Settings** → **Roles and permissions (Unified RBAC)** → **Roles**
2. Create a custom role or identify an existing role with the following minimum permissions:
   - **Security operations** → **Security data** → **Security data basics (read)**
   - **Security posture** → **Posture management** → **Vulnerability management (read)**
3. Apply the principle of least privilege and scope assignments narrowly

### Step 2: Register the Agent's Service Principal

1. As a tenant admin, open Azure CLI and get a Microsoft Graph access token:

```azurecli
TOKEN=$(az account get-access-token \
   --tenant <your tenant ID> \
   --resource-type ms-graph \
   --query accessToken -o tsv)
```

2. Create the service principal for the agent identity:

```azurecli
curl -X POST https://graph.microsoft.com/v1.0/servicePrincipals \
   -H "Authorization: Bearer $TOKEN" \
   -H "Content-Type: application/json" \
   -d '{
      "appId": "43d7b169-1d9e-4d32-8cd8-06c5974ed90c"
   }'
```

3. (Optional) Verify the service principal was created:

```azurecli
curl -X GET "https://graph.microsoft.com/v1.0/servicePrincipals?$filter=appId eq '43d7b169-1d9e-4d32-8cd8-06c5974ed90c'" \
   -H "Authorization: Bearer $TOKEN"
```

### Step 3: Assign Unified RBAC Role to Service Principal

1. In the Microsoft Defender portal, go to **Settings** → **Roles and permissions (Unified RBAC)** → **Assignments** → **Add assignment**
2. Configure the following:
   - **Principal**: Select the service principal created in Step 2
   - **Role**: Choose the custom role with the two read permissions from Step 1
   - **Scope**: Select the minimal scope required (specific assets or subscriptions)
3. Save the assignment

**Important**: Activate the [Microsoft Defender XDR Unified RBAC model](https://learn.microsoft.com/en-us/defender-xdr/manage-rbac) for the role to take effect.

### Step 4: Configure Defender for Endpoint Role Permissions

1. Sign in to the [Microsoft Defender portal](https://security.microsoft.com)
2. Navigate to **Settings** → **Endpoints** → **Permissions** → **Roles**
3. Locate the custom role assigned to the Threat Intelligence Briefing Agent
4. Edit the role and confirm the following permissions are enabled:
   - **Advanced Hunting** – Read
   - **Vulnerability Management** – Read
   - **Machine Configuration** – Read
   - **Device Inventory** – Read
5. Save any changes

### Step 5: Grant Device Group Access to Agent Identity

1. In the Microsoft Defender portal, go to **Settings** → **Endpoints** → **Device Groups**
2. For each Device Group containing production endpoints:
   1. Open the Device Group
   2. Select the **User Access** section
   3. Add the Threat Intelligence Briefing Agent service principal
   4. Assign **Read** access
3. Save the changes

**Important**: Without Device Group access, the agent cannot query device vulnerability data, and the Exposure Report section may show as "not available."

### Step 6: Wait for Permission Synchronization

Allow time for permission updates to synchronize across Microsoft Defender services (typically 15-30 minutes) before proceeding to agent setup.

## Deployment Steps

### Step 1: Access the Threat Intelligence Briefing Agent

1. Sign in to the [Microsoft Defender portal](https://security.microsoft.com)
2. Navigate to **Threat intelligence** → **Threat analytics** in the left navigation menu
3. Look for the **Threat Intelligence Briefing Agent** banner at the top of the Threat analytics page
4. Select **Set up agent**

### Step 2: Review Agent Details

1. On the setup popup, review the agent details
2. Select **Next** to continue

### Step 3: Connect Identity or User Account

1. Choose one of the following:
   - **Agent Identity** (recommended): Use the service principal created in the previous section
   - **User Account**: Use an existing user account with appropriate permissions
2. Select **Continue**
3. A new window opens to complete the authentication
4. Sign in with the selected account or approve the service principal

### Step 4: Confirm Connection

1. Wait for the agent to finish connecting to the identity or account
2. Review the account details on the confirmation page
3. Select **Continue** to proceed

### Step 5: Configure Agent Parameters

On the parameters page, specify the following inputs to customize the briefing output:

- **Insights**: Number of vulnerabilities the agent researches for active threats (default: recommended value)
- **Look back days**: Number of days the agent researches threats against your vulnerabilities (default: 30 days)
- **Region**: Geographical area the agent checks for relevant threats (e.g., EMEA, APAC, Americas)
- **Industry**: Sector or industry vertical the agent checks for threats (e.g., Financial, Healthcare, Technology)
- **Scheduled runs settings**: 
  - **Manual**: Run the agent on-demand only
  - **Automatic**: Send briefings at regular intervals (default: every 7 days)
- **Generated brief recipient**: Email address of user or distribution group that receives the briefing

### Step 6: Deploy the Agent

1. Review all settings
2. Select **Deploy agent**
3. Wait for agent activation to complete
4. Choose to:
   - **Go back to Threat analytics** page
   - **Manage agent** to update parameters immediately

## Running the Agent

### On-Demand Execution:

1. Go to the Threat analytics page
2. In the Threat Intelligence Briefing Agent banner, select **Run agent**
3. The agent generates a briefing immediately

### Scheduled Execution:

- If configured for automatic runs, the agent generates briefings at the specified interval (default: every 7 days)
- Recipients receive briefing via email at the configured recipient address

## Viewing and Managing Briefings

### View the Full Briefing:

1. In the Threat Intelligence Briefing Agent banner, select **View full brief**
2. A side panel opens showing:
   - Threat summary overview
   - Detailed technical analysis
   - Actively exploited vulnerabilities
   - Organizational impact assessment

### Download or Copy Briefing:

1. In the briefing side panel, use the icons at the top:
   - **Download**: Save the report as a markdown file
   - **Copy**: Copy the report contents to clipboard

### Manage Agent Settings:

1. In the Threat Intelligence Briefing Agent banner, select **Manage agent** or the three dots menu
2. Access settings by either method:
   - Select **Manage agent** from the banner or side panel
   - Go to **System** → **Settings** → **Microsoft Defender XDR** → **Threat Intelligence Briefing Agent** in the Defender portal

### Access Activity History:

1. In the agent settings page, select **View agent activity**
2. This opens the **Activity** page in the Security Copilot standalone portal
3. View all generated reports with:
   - Generation timestamps
   - Execution method (scheduled or on-demand)
   - Current status

## Assessing and Providing Feedback

### View Agent Activity:

1. In the Threat Intelligence Briefing Agent settings page, select **View agent activity**
2. The Activity page displays all generated reports with metadata
3. Select a report to assess the agent's output

### Track Agent Progress:

1. In a briefing report, select **View activity**
2. An activity map displays showing:
   - Step-by-step progression of the agent
   - Details on how the agent built the briefing
   - Transparency into decision-making process

### Provide Feedback:

1. After reviewing a briefing, select either:
   - **Thumbs up** icon (helpful/good)
   - **Thumbs down** icon (not helpful/poor)
2. In the window that appears, type your feedback in the text box
3. Choose feedback recipient:
   - Send to agent (helps the agent learn your preferences)
   - Send to Microsoft (helps Microsoft improve results)
4. Select **Submit**

## Configuration Management

### Edit Agent Parameters:

Access agent settings through any of these methods:

1. **From Threat analytics page**: Select the three dots menu in the Threat Intelligence Briefing Agent banner, then select **Manage agent**
2. **From the briefing side panel**: Select **Manage agent**
3. **From Settings**: Go to **System** → **Settings** → **Microsoft Defender XDR** → **Threat Intelligence Briefing Agent**

### Modifiable Settings:

- Insights to research
- Look back days
- Region scope
- Industry scope
- Scheduled runs (manual/automatic frequency)
- Generated brief recipient email address(es)

## Best Practices

1. **Use Service Accounts**: Deploy agent identities rather than user accounts for better audit trail and security posture
2. **Least Privilege**: Apply minimal permissions required for agent operation
3. **Device Group Scope**: Ensure agent has access to all Device Groups with relevant endpoints
4. **Parameter Tuning**: Customize region, industry, and look-back days to match your threat profile
5. **Recipient Management**: Distribute briefings to security stakeholders via appropriate distribution lists
6. **Feedback Loop**: Regularly provide feedback to help the agent improve over time
7. **Permission Synchronization**: Allow adequate time for permission changes to propagate (15-30 minutes)
8. **Schedule Optimization**: Configure scheduled runs during off-hours to avoid impacting user experience
9. **Monitoring**: Track briefing generation and recipient acknowledgment
10. **Documentation**: Document custom parameters and recipients for continuity

## Troubleshooting

**Issue**: Agent fails to connect to identity
- **Solution**: Verify the service principal or user account has Security Admin permissions in Defender portal

**Issue**: Briefing shows "Permission Denied" errors
- **Solution**: Confirm the agent identity has required Defender for Endpoint permissions and Unified RBAC role assignments have synchronized

**Issue**: "Exposure Report" shows "not available"
- **Solution**: Verify the agent identity has Read access to all Device Groups containing production endpoints

**Issue**: Email distribution not working
- **Solution**: Verify the recipient email address is valid and the agent identity/account has permission to send emails in the organization

**Issue**: Briefing lacks external threat context
- **Solution**: Ensure Microsoft Threat Intelligence and Microsoft Threat Intelligence agents plugins are properly enabled

**Issue**: Briefing lacks EASM data
- **Solution**: Verify Microsoft Defender External Attack Surface Management is enabled; confirm agent has Exposure Management (read) permissions

**Issue**: Limited or outdated vulnerability data in briefing
- **Solution**: Ensure Microsoft Defender for Endpoint is properly configured on devices and the agent has Advanced Hunting and Vulnerability Management read permissions

## Additional Resources

- [Threat Intelligence Briefing Agent (Standalone Experience)](https://learn.microsoft.com/en-us/copilot/security/threat-intel-briefing-agent)
- [Threat analytics in Microsoft Defender](https://learn.microsoft.com/en-us/defender-xdr/threat-analytics)
- [Get started with Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/get-started-security-copilot)
- [Microsoft Defender XDR Unified RBAC Management](https://learn.microsoft.com/en-us/defender-xdr/manage-rbac)
- [Microsoft Defender for Endpoint Permissions](https://learn.microsoft.com/en-us/defender-endpoint/user-roles)
- [Agent Identities in Security Copilot](https://aka.ms/WhatAreAgentIdentities)
- [Microsoft Defender Portal](https://security.microsoft.com/)
