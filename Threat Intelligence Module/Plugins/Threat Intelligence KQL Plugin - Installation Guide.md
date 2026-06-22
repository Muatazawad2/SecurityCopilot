# Threat Intelligence KQL Plugin - Installation Guide

**Developer**: Dr Muataz Awad

## Overview

This guide explains how to upload and use the custom Threat Intelligence KQL plugin in Microsoft Security Copilot.

## Prerequisites

- Access to Microsoft Security Copilot
- Permission to manage plugins in your Security Copilot workspace
- Access to Microsoft Defender advanced hunting data
- Plugin file: [Threat Intelligence KQL Plugin.yaml](Threat%20Intelligence%20KQL%20Plugin.yaml)

## Install and Upload

1. Open Microsoft Security Copilot.
2. Go to the Plugins area in your workspace.
3. Choose the option to add or upload a custom plugin.
4. Select [Threat Intelligence KQL Plugin.yaml](Threat%20Intelligence%20KQL%20Plugin.yaml).
5. Complete the upload/import flow.
6. Enable the plugin in your workspace.

Note: UI labels can vary by tenant and release ring (for example: Add plugin, Import plugin, Upload custom plugin).

## Included Skills

- **Get Threat Intel High Severity Alerts Last 7 Days**
  - Pulls recent high and medium severity alerts to accelerate TI triage.
- **Get Potential External C2 Connections Last 7 Days**
  - Summarizes suspicious public outbound connections for possible C2 analysis.
- **Get Critical Vulnerability Exposure Snapshot**
  - Highlights high/critical CVE exposure across the device estate.

## Validate the Plugin

1. Open a new Security Copilot session.
2. Confirm the plugin appears in the available plugin list.
3. Run validation prompts, for example:
   - "Use Get Threat Intel High Severity Alerts Last 7 Days and summarize top threat families."
   - "Use Get Potential External C2 Connections Last 7 Days and show top remote endpoints by connection volume."
   - "Use Get Critical Vulnerability Exposure Snapshot and rank top CVEs by exposed device count."
4. Confirm output includes key fields such as:
   - AlertId, Title, Severity, ServiceSource
   - RemoteIP, RemoteUrl, DistinctDevices, DistinctUsers
   - CveId, Severity, ExposedDevices

## Troubleshooting

- No results returned:
  - Verify Defender advanced hunting data is available in your tenant.
  - Increase lookback windows in the plugin query temporarily for validation.
- Plugin upload fails:
  - Confirm YAML formatting is intact.
  - Re-upload the same file without editor-added hidden characters.
- Permission errors:
  - Confirm your account can run Defender-targeted KQL queries.

## Optional Query Tuning

You can tune lookback windows in the plugin file for testing or production needs:

- `let since = ago(7d);` -> `let since = ago(14d);`
- `let since = ago(30d);` -> `let since = ago(90d);`

After updating the plugin file, re-upload or update it in Security Copilot.
