# Triage Agent in Insider Risk Management Dashboard

**Developer**: Dr Muataz Awad

## Overview

When the Triage Agent is enabled in Insider Risk Management, it automatically reviews alerts and displays them on the Triage Agent dashboard. This dashboard provides prioritized alerts and filtering options to help analysts quickly investigate and resolve issues.

## Accessing the Dashboard

1. Navigate to the Insider Risk Management alerts page
2. Select the **Triage Agent** toggle at the top of the dashboard page to view the Triage Agent-specific view

## Dashboard Features

### Customization Options

- **Customize columns**: Select which information appears in the dashboard
- **Filter alerts** by:
  - **Priority**: Needs Attention or Less Urgent
  - **Date**: Alert detection date
  - **Alert status**: Current status of the alert
  - **Alert scope**: Scope of affected resources

### Viewing Alert Details

1. Select an alert on the dashboard to display the Agent summary
2. Select **View details** to access:
   - Risk factors
   - Risk pattern narratives
   - Activity explorer
   - Additional alert context and related content

## Agent Summary Tab

The **Agent summary tab** appears in the **Alert details** page when viewing alerts from the Triage Agent dashboard. It provides:

### Agent Categorization

Alerts are categorized as:
- **Needs attention**: Higher priority alerts requiring investigation
- **Less urgent**: Lower priority alerts

### User Information

Displays:
- **Alert history**: Previous alerts for the user
- **Title**: User's job title
- **Organization**: User's organization
- **Last working date**: Most recent activity date
- Select the user tile to view additional profile details

### Risk Patterns

Provides narrative summaries of each risk associated with the alert. Each risk pattern includes:

- **Summary**: Narrative detailing risky activity, sensitive data involved, and affected files
- **Actors**: Device involved and client IP address (if available)
- **Timeframe**: Start and end dates/times in UTC
- **Sensitive data involved**: Information types, classifiers, and file sensitivity labels
- **Activity names**: Types of actions taken by the user
- **Activity details**: Key aspects of observed activity, scope of events, and contextual risk signals

Select **Filter activity** to view the relevant Activity explorer entries that contributed to the risk assessment.

## Agent Analysis Scope

The Triage Agent:
- Analyzes up to the **most recent 30,000 activity events** associated with the user
- Evaluates **all recorded user activities** for risk (not limited to policy-triggering activities)
- Clearly indicates when specific information isn't available by marking it as **"Not found by agent"**

## Providing Feedback

If you disagree with the agent's categorization:

1. Select **Is this incorrect?** in the agent summary
2. Provide feedback on why the categorization is incorrect
3. Your feedback helps improve future agent performance

## Important Notes

- The file risk section of the Triage Agent is deprecated
- For a comprehensive overview of the triage experience, see the [Insider Risk Management Alerts Triage Experience video](https://www.youtube.com/watch?v=KgmpxBLJLPI)
