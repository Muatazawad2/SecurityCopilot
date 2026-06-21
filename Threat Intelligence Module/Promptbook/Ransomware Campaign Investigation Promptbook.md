# Ransomware Campaign Investigation

**Developer**: Dr Muataz Awad

**Description**: Conduct a structured threat intelligence investigation into a ransomware group or active ransomware campaign using Microsoft Defender Threat Intelligence. Profile the ransomware operator, analyze their intrusion chain, identify associated infrastructure and tooling, assess organizational exposure and vulnerability alignment, and build a comprehensive defensive posture to prevent or respond to an attack. Results may be limited if the Microsoft Threat Intelligence plugin is not enabled or required permissions are not configured.

---

1. Profile the ransomware group and their operational model
```
Build a detailed intelligence profile for the ransomware group {RansomwareGroupName}. Include: their operational model (Ransomware-as-a-Service vs. closed group), suspected origin and sponsorship, years active, estimated number of victims and industries targeted, ransom demand ranges, data leak site or extortion tactics used, known affiliates or initial access broker (IAB) relationships, and any law enforcement actions or disruptions taken against them. Summarize their current operational status (active, disrupted, rebranded).
```

2. Map their full intrusion chain from initial access to impact
```
Map the complete intrusion chain used by {RansomwareGroupName} from initial access through to ransomware deployment. For each stage, provide: the MITRE ATT&CK technique ID and name, the specific tools or methods they use, known dwell time between stages, and observable indicators at that stage. Include their preferred initial access vectors (phishing, exposed RDP, vulnerability exploitation, IAB-purchased access), lateral movement techniques, credential harvesting methods, and data exfiltration approach before encryption.
```

3. Identify all malware, tools, and infrastructure associated with this group
```
List all malware families, offensive security tools, and legitimate tools abused by {RansomwareGroupName}. For each, include: tool name, category (ransomware payload, backdoor, credential stealer, tunneling tool, etc.), known variants or versions, associated file hashes, delivery mechanism, and C2 infrastructure patterns. Identify any shared tooling with other ransomware groups or threat actors that may complicate attribution.
```

4. Retrieve recent campaigns, victims, and intelligence articles
```
Retrieve all Microsoft Defender Threat Intelligence articles and reports referencing {RansomwareGroupName} published in the last 180 days. Summarize: recent campaign activity, newly targeted sectors or geographies, any evolution in their TTPs, reported victim organizations (if publicly disclosed), and new infrastructure observed. Assess whether the group is increasing or decreasing in activity and flag any emerging indicators of a new campaign wave.
```

5. Identify vulnerabilities and misconfigurations this group commonly exploits
```
List all CVEs, software vulnerabilities, and common misconfigurations that {RansomwareGroupName} is known to exploit as part of their initial access or lateral movement. For each, include: CVE ID and CVSS score, affected products, exploitation method used by this group, patch availability, and whether our organization has exposed devices running affected versions. Prioritize by exploitation likelihood and organizational exposure.
```

6. Assess organizational readiness and current exposure
```
Assess our organization's current exposure and readiness against a potential {RansomwareGroupName} attack. Evaluate: whether any of their known IOCs have been observed in our telemetry, whether we have exposed devices running software versions they commonly exploit, whether our backup and recovery capabilities would allow recovery without paying ransom, current coverage of their TTPs by our detection rules, and any gaps in our defenses that align with their known attack path. Provide an overall readiness score and risk rating.
```

7. Build a ransomware-specific defense and response plan
```
Based on the full intelligence profile of {RansomwareGroupName} and our organizational exposure assessment, produce a targeted defense and response plan. Include: (1) top 10 immediate hardening actions that directly counter this group's TTPs; (2) detection rules and KQL queries to identify their known behaviors in our environment; (3) a pre-attack preparation checklist (backup validation, account hygiene, network segmentation); (4) a ransomware incident response trigger checklist — what signals indicate this group is in our network; and (5) containment and recovery priorities if an active intrusion is confirmed. Format for both a security operations team and a CISO-level briefing.
```

---

## How To Create This Promptbook In Security Copilot

1. Start by running step 1 and replacing `{RansomwareGroupName}` with the ransomware group you are investigating (e.g., `LockBit`, `BlackCat/ALPHV`, `Cl0p`, `Play`).
2. Security Copilot carries the group context through subsequent steps.
3. Step 5 and 6 benefit from having the Microsoft Defender for Endpoint and Vulnerability Management plugins enabled.
4. Select all prompts to include them in the promptbook.
5. Enter the promptbook name: **Ransomware Campaign Investigation** and add a description.
6. Choose sharing scope (personal, team, or organization).
7. Select **Create**, verify the success message, and open the promptbook from the library.
