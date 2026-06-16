# Email Header Investigation Agent

This folder contains a Security Copilot agent manifest based on the Promptbook sample:
- Email header analysis and investigation

## Files

- manifest.yaml: Agent manifest with GPT helper skills and an AGENT orchestration entrypoint.

## What this agent does

The agent implements the same flow as the Promptbook:
1. Triage the email headers.
2. Extract technical indicators.
3. Check domain reputation.
4. Check IP reputation.
5. Check threat article associations for domains/IPs.
6. Check threat article associations for sender and return path.
7. Hunt whether similar emails were sent in the tenant.
8. Hunt whether users clicked URLs from the email.
9. Summarize findings with phishing certainty percentage.

## Before import

Update these fields in manifest.yaml:
- Descriptor.Name
- AgentDefinitions.Name
- AgentDefinitions.Publisher
- AgentDefinitions.Product

Verify RequiredSkillsets entries exist in your workspace:
- ThreatIntelligence.DTI
- DefenderXDR

If your workspace uses different skillset names, replace them in:
- AgentDefinitions.RequiredSkillsets

## Input contract

The entrypoint skill expects:
- EmailHeaders (required): raw RFC-style email headers.

## Output contract

Final response includes:
- Evidence summary across all executed steps.
- Explicit mention of any skipped steps and why.
- Suspicious certainty percentage, always included.

## Notes

- The manifest is designed to degrade gracefully when a TI or Defender tool is unavailable.
- Default trigger scheduling is disabled with DefaultPeriodSeconds: 0 (manual/invoked execution).