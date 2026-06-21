# Threat Actor Investigation

**Developer**: Dr Muataz Awad

**Description**: Conduct a structured, end-to-end investigation of a specific threat actor using Microsoft Defender Threat Intelligence. Walk through the actor's identity, motivations, targeting behavior, TTPs, infrastructure, active campaigns, and organizational exposure — concluding with prioritized defensive recommendations. Results may be limited if the Microsoft Threat Intelligence plugin is not enabled or the user lacks the required permissions.

---

1. Build a foundational profile of the threat actor
```
Build a foundational intelligence profile for the threat actor {ThreatActorName}. Include: their origin country or suspected state sponsorship, primary motivations (espionage, financial, disruption, hacktivism), years active, known aliases and alternative naming conventions used by other vendors, and a high-level summary of their operational history. Identify whether they are classified as an advanced persistent threat (APT) group.
```

2. Identify their targeting scope and victim profile
```
Describe the targeting scope of {ThreatActorName}. Include: which industries and sectors they most frequently target, which geographic regions they operate in or target, the typical profile of their victims (organization size, government vs. private sector), and any notable shifts in targeting over the last 12 months. Highlight if they have ever targeted the {Industry} sector or organizations in {Region}.
```

3. Map their TTPs to the MITRE ATT&CK framework
```
Map all known TTPs of {ThreatActorName} to the MITRE ATT&CK Enterprise framework. Organize by tactic (Initial Access, Execution, Persistence, Privilege Escalation, Defense Evasion, Credential Access, Discovery, Lateral Movement, Collection, Exfiltration, Command and Control, Impact). For each technique, include the ATT&CK ID, a brief description of how this actor implements it, and a detection note or mitigation recommendation.
```

4. Enumerate their tooling, malware, and infrastructure patterns
```
List all known malware families, custom tools, and commodity tooling associated with {ThreatActorName}. For each tool, include: its purpose (dropper, RAT, stealer, ransomware, etc.), delivery mechanism, known variants, and any command-and-control infrastructure patterns such as preferred hosting providers, domain registration behaviors, SSL certificate reuse, or dynamic DNS usage.
```

5. Retrieve recent campaigns and intelligence articles
```
Retrieve all Microsoft Defender Threat Intelligence articles and reports published in the last 90 days related to {ThreatActorName}. For each article, provide: title, publication date, key findings, new TTPs or infrastructure changes observed, affected industries or regions, and a direct link. Highlight any indication of increased operational tempo or new campaign activity.
```

6. Assess current indicators of compromise associated with the actor
```
Provide the most current and high-confidence indicators of compromise (IOCs) associated with {ThreatActorName}. Organize by type: IP addresses, domains, URLs, file hashes (SHA256 preferred), email infrastructure, and registry artifacts. For each IOC, include: first observed, last observed, confidence level, associated malware or campaign, and recommended action (block, monitor, or investigate).
```

7. Evaluate organizational exposure and provide defensive recommendations
```
Based on everything gathered about {ThreatActorName}, evaluate the potential exposure risk to an organization in the {Industry} sector operating in {Region}. Identify which of their TTPs our environment is most vulnerable to, which of their known IOCs should be immediately blocked or monitored, and provide a prioritized defensive action plan covering: immediate actions (24–48 hours), short-term hardening (1–2 weeks), and strategic improvements (1–3 months). Include specific Microsoft security product recommendations where applicable.
```

---

## How To Create This Promptbook In Security Copilot

1. Start by running step 1 and replacing `{ThreatActorName}` with the actor you are investigating (e.g., `Midnight Blizzard`, `Scattered Spider`).
2. Replace `{Industry}` and `{Region}` in steps 2 and 7 with your organization's sector and geography.
3. Run each subsequent step — Security Copilot retains context from previous steps so you do not need to repeat the actor name.
4. Select all prompts to include them in the promptbook.
5. Enter the promptbook name: **Threat Actor Investigation** and add a description.
6. Choose sharing scope (personal, team, or organization).
7. Select **Create**, verify the success message, and open the promptbook from the library.
