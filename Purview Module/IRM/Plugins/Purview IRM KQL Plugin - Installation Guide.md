# Purview IRM KQL Plugin - Installation Guide

**Developer**: Dr Muataz Awad

## Overview

This guide explains how to upload and use the custom Purview IRM KQL plugin in Microsoft Security Copilot.

## Prerequisites

- Access to Microsoft Security Copilot
- Permission to manage plugins in your Security Copilot workspace
- Access to Defender Advanced Hunting data that includes DataSecurityEvents
- Plugin file: [Purview IRM Activity KQL Plugin.yaml](Purview%20IRM%20Activity%20KQL%20Plugin.yaml)

## Install and Upload

1. Open Microsoft Security Copilot.
2. Go to the Plugins area in your workspace.
3. Choose the option to add or upload a custom plugin.
4. Select [Purview IRM Activity KQL Plugin.yaml](Purview%20IRM%20Activity%20KQL%20Plugin.yaml).
5. Complete the upload/import flow.
6. Enable the plugin in your workspace.

Note: UI labels can vary slightly by tenant or release ring (for example: Add plugin, Import plugin, Upload custom plugin).

## Validate the Plugin

1. Open a new Security Copilot session.
2. Confirm the plugin appears in the available plugin list.
3. Run a prompt that calls the skill, for example:
   - "Use Get Purview IRM Activity Last Day and summarize top IRM action categories."
4. Confirm results return DataSecurityEvents fields such as:
   - EventTime
   - AccountUpn
   - IrmActionCategory
   - PolicyName
   - CorrelationId

## What the Plugin Returns

The skill queries DataSecurityEvents for the last one day and returns enriched IRM context:

- User/account details
- Device and file details
- IRM category and policy context
- Sequence and correlation identifiers

## Troubleshooting

- No results returned:
  - Verify DataSecurityEvents exists in your hunting environment.
  - Increase lookback in the plugin query from 1d to 7d for testing.
  - Validate that IRM-related events exist in your tenant.
- Plugin upload fails:
  - Ensure the YAML format is valid and unchanged.
  - Re-upload the same file without extra characters.
- Permission errors:
  - Confirm your account has access to run Defender target KQL queries.

## Update the Query Window

To test with more data, edit this line in the plugin file:

- `let since = ago(1d);`

Example changes:

- `let since = ago(7d);`
- `let since = ago(30d);`

After updating the file, re-upload or update the plugin in Security Copilot.
