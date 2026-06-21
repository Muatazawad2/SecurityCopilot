# IRM Triage Agent Setup Guide

**Developer**: Dr Muataz Awad

## Overview

The Microsoft Purview Triage Agent in Insider Risk Management (IRM) automates alert triaging and prioritization using Security Copilot. It analyzes alerts and categorizes them as "Needs Attention," "Less Urgent," or "Not Categorized."

## Key Permissions

### For Setup & Administration (Any one from each group):

**Group A**: Role Management, Organization Management, or Insider Risk Management Admin  
**Group B**: Security Copilot Contributor or Purview Copilot Workspace Contributor

### For Analysts (Any one from each group):

**Group A**: Insider Risk Management Analyst or Insider Risk Management Investigator  
**Group B**: Purview Agent Deployment contributor  
**Group C**: Security Copilot Contributor or Purview Copilot Workspace Contributor

## Infrastructure Prerequisites

1. Tenant onboarded to Microsoft Security Copilot
2. Microsoft 365 data sharing enabled in Security Copilot
3. Microsoft Purview plug-in enabled in Security Copilot

## Deployment Steps

### 1. Enable the Agent

1. Sign in to [Microsoft Purview Portal](https://purview.microsoft.com/)
2. Navigate to **Agents** → **Explore agents**
3. Select the IRM Triage Agent → **Add**
4. Select **Setup** and configure:
   - **Run schedule**: Automatic (recommended) or Manual
   - **Alert timeframe**: Set how far back the agent looks for alerts
5. Select **Deploy**

### 2. Configure the Agent (Setup Agents)

1. Go to **Alerts** page for your solution
2. Select **Customize** on the first-run dialog
3. Configure:
   - **Alert timeframe** (can only shorten, not lengthen)
   - **Custom instructions**: Natural language instructions to guide alert prioritization
   - **Select policies**: Choose which policies the agent monitors
4. Select **Start agent** (allow up to 2 hours for initial processing)

## Key Configuration Options

- **Triggers**: Set agent to run automatically or manually on individual alerts
- **Custom Instructions**: Natural language input that helps the agent identify priority alerts
- **Alert Timeframe**: Define lookback period for alert analysis (analysts can shorten but not extend)

## Agent Lifecycle

- **Deactivate**: Stops triaging but keeps configuration
- **Remove**: Completely deletes agent; must redeploy to use again
- **Edit**: Change triggers, timeframe, policies, or custom instructions anytime

## Monitoring & Management

- Track SCU consumption in the **usage monitoring tool**
- View triaged alerts in the **Alerts** page with **Triage Agent** view toggle
- Alerts are grouped into: **All**, **Needs Attention**, **Less Urgent**, **Not Categorized**

## Important Notes

- Agent runs in security context of the user who saved the configuration
- Configuration authentication is valid for 90 days; manually save again after 90 days to maintain functionality
- Only one instance of each agent per tenant
- Most recent agent configuration is always used

## Additional Resources

- [Security Copilot Agents in Microsoft Purview Overview](https://learn.microsoft.com/en-us/purview/copilot-in-purview-agents-overview)
- [Get started with Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/get-started-security-copilot)
- [Microsoft Purview Portal](https://purview.microsoft.com/)

<!-- Repository maintenance marker -->
