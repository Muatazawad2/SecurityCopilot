# Threat Intelligence-Driven Incident Response

**Developer**: Dr Muataz Awad

**Description**: Enrich and accelerate an active security incident investigation using Microsoft Defender Threat Intelligence. This promptbook correlates live incident signals with threat intelligence to identify the threat actor, validate the attack chain, map observed behaviors to MITRE ATT&CK, assess blast radius, and produce a threat-informed containment and remediation plan. Designed for use by Tier 2/3 SOC analysts and incident responders. Results may be limited if required Defender and Threat Intelligence plugins are not enabled.

---

1. Establish initial threat intelligence context for the incident
```
We are investigating an active security incident. The initial indicators observed are: {IncidentIndicators: list known IPs, domains, hashes, alert names, or behavioral patterns}. Using Microsoft Defender Threat Intelligence, identify whether these indicators are associated with any known threat actors, malware families, or active campaigns. Provide: threat actor attribution with confidence level, associated campaign or operation name, relevant MDTI articles, and any additional IOCs linked to these indicators that we should immediately search for in our environment.
```

2. Map the observed attack behaviors to MITRE ATT&CK
```
Based on the initial indicators and threat intelligence attribution established, map all observed attacker behaviors to the MITRE ATT&CK Enterprise framework. For each technique identified: provide the ATT&CK ID and name, describe how this specific threat actor implements it, list the observable evidence in our telemetry (process names, command lines, network connections, registry keys, file paths), and indicate whether we have a detection rule covering this technique. Identify any technique gaps where we have no current detection visibility.
```

3. Expand the scope — hunt for additional compromise indicators
```
Based on the threat actor attribution and TTPs identified, generate targeted threat hunting queries to identify additional compromised devices, accounts, or systems beyond the initially known scope. Search across: DeviceNetworkEvents for C2 communication patterns, DeviceProcessEvents for tool execution or persistence mechanisms, IdentityLogonEvents for lateral movement indicators, and EmailEvents for phishing delivery artifacts. List every additional affected asset discovered with evidence and timestamp.
```

4. Assess the blast radius and business impact
```
Based on all compromised assets and accounts identified so far, assess the full blast radius of this incident. Include: total number of affected devices and user accounts, any privileged accounts or service accounts involved, sensitive data repositories or workloads that were accessed, whether the attacker achieved persistence (and where), any evidence of data staging or exfiltration, and the regulatory and compliance implications (e.g., GDPR, HIPAA, PCI-DSS) if sensitive data was exposed. Estimate the overall business impact severity.
```

5. Reconstruct the complete attack timeline
```
Reconstruct the complete attack timeline for this incident from earliest evidence of initial access through to the current state. Present findings as a chronological timeline with: timestamp, stage of the attack (aligned to the kill chain and MITRE ATT&CK), specific action taken by the attacker, evidence source (log type, alert name, process event), affected asset, and any defensive response actions taken. Identify the dwell time (gap between initial access and detection) and any missed detection opportunities.
```

6. Generate a threat-informed containment and eradication plan
```
Based on the threat actor's known TTPs, the full scope of compromise, and the reconstructed attack timeline, generate a prioritized containment and eradication plan. Include: (1) immediate isolation actions — which devices and accounts to contain right now and why; (2) credential revocation — which accounts must be reset or disabled (prioritizing privileged accounts); (3) persistence removal — specific registry keys, scheduled tasks, services, and files to remove based on this actor's known persistence methods; (4) network blocking — all IOCs to block at firewall, DNS, and proxy layers; (5) C2 disruption — steps to cut off attacker communication; and (6) eradication validation — how to confirm the attacker has been fully removed before recovery begins.
```

7. Produce the incident threat intelligence report
```
Compile all findings from this investigation into a structured incident threat intelligence report. Include: (1) Incident Summary — what happened, when, and current status; (2) Threat Attribution — actor profile, confidence level, and campaign context; (3) Attack Chain Analysis — MITRE ATT&CK techniques observed with evidence; (4) Blast Radius — all affected systems, accounts, and data; (5) Attack Timeline — key events from initial access to containment; (6) Containment and Eradication Status — actions taken and outstanding; (7) Indicators of Compromise — full IOC list for sharing with threat intelligence teams; (8) Lessons Learned and Detection Gaps — what was missed and how to close those gaps; (9) Recommended Follow-on Actions — post-incident hardening priorities. Format as a formal incident intelligence product suitable for CISO briefing and post-incident review.
```

---

## How To Create This Promptbook In Security Copilot

1. Start by running step 1 and replacing `{IncidentIndicators}` with the known signals from the active incident (e.g., `suspicious IP 185.220.x.x, alert "Possible Cobalt Strike beacon", lateral movement from DEVICE01`).
2. Security Copilot builds cumulative context across all steps — do not restart the session between prompts.
3. Steps 3 and 4 require Microsoft Defender XDR and Threat Intelligence plugins to be active for cross-table hunting.
4. Select all prompts to include them in the promptbook.
5. Enter the promptbook name: **Threat Intelligence-Driven Incident Response** and add a description.
6. Choose sharing scope (personal, team, or organization).
7. Select **Create**, verify the success message, and open the promptbook from the library.
