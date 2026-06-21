# Threat Intelligence Sample Prompts

**Developer**: Dr Muataz Awad

**Description**: A ready-to-use set of threat intelligence prompts for investigating threat actors, analyzing indicators of compromise, researching vulnerabilities, assessing organizational exposure, and building actionable intelligence reports. Results may be limited or incomplete if the Microsoft Threat Intelligence plugin is not enabled or if the user does not have the required permissions.

---

## Threat Actor Profiling & Research

1. Build a comprehensive profile of a specific threat actor
```
Build a comprehensive profile of the threat actor <Threat Actor Name>. Include their origin, suspected sponsorship or motivation, primary targets by industry and geography, known aliases, operational history, and any recent campaigns observed in the last 90 days. Highlight any evolution in their tactics or infrastructure over time.
```

2. Map threat actor activity to the MITRE ATT&CK framework
```
Map the known TTPs of <Threat Actor Name> to the MITRE ATT&CK framework. List each technique by tactic category (Initial Access, Execution, Persistence, Lateral Movement, Exfiltration, etc.) with the corresponding ATT&CK technique ID, a brief description of how this actor implements it, and any relevant detection notes or mitigations.
```

3. Identify threat actors actively targeting a specific industry
```
Identify all threat actors currently active and known to target the <Industry> sector. For each actor, provide their motivation (espionage, financial, hacktivism), primary attack vectors, and any intelligence articles or campaigns published in the last 60 days. Rank them by current threat level.
```

4. Compare two threat actors side by side
```
Compare the threat actor <Threat Actor A> with <Threat Actor B>. Highlight their differences and similarities across: motivation, targeting scope, sophistication level, preferred initial access techniques, malware tooling, infrastructure patterns, and known geographic origins. Summarize which poses a greater current risk to <Industry or Region>.
```

5. Identify threat actors active in a specific geographic region
```
List all threat actors with reported activity targeting organizations in <Region or Country> in the last 180 days. Include their motivations, sectors targeted, known campaigns, and any current intelligence articles. Flag which actors are state-sponsored versus financially motivated.
```

---

## Indicators of Compromise (IOC) Analysis

6. Investigate a suspicious IP address for threat intelligence context
```
Investigate the IP address <IP Address>. Provide a full threat intelligence summary including its geolocation, ASN, known associations with threat actors or malware campaigns, reported malicious activity, passive DNS records, hosting history, and any open-source or Microsoft threat intelligence articles referencing this IP. Include a current risk verdict.
```

7. Analyze a suspicious domain for malicious infrastructure
```
Analyze the domain <Domain Name> for threat intelligence indicators. Include registration details, WHOIS history, DNS records, known associations with phishing campaigns or command-and-control infrastructure, reputation scores, related malware families, and any threat actor attribution. Assess whether this domain represents an active threat.
```

8. Investigate a file hash for malware attribution
```
Investigate the file hash <SHA256/MD5/SHA1 Hash>. Provide a full threat intelligence report including known malware family classification, sandbox analysis results, associated threat actors, campaigns this sample has been linked to, observed infrastructure (C2 domains/IPs), and detection coverage across Microsoft security products. Include recommended response actions.
```

9. Pivot on an IOC to uncover related malicious infrastructure
```
Using the indicator <IOC: IP/Domain/Hash> as a starting point, perform an infrastructure pivot analysis. Identify related domains, IPs, and file hashes that share infrastructure patterns such as hosting provider, SSL certificate, registrar, WHOIS data, or behavioral similarity. Map out the full network of connected indicators and assess whether they belong to a known threat actor or campaign.
```

10. Bulk IOC enrichment and prioritization
```
Enrich the following list of indicators and prioritize them by threat severity:
<List of IPs, Domains, or File Hashes>
For each indicator, provide: type, threat category (malware/phishing/C2/etc.), associated threat actor or campaign, current reputation status, and whether it has been observed in active attacks. Output a prioritized table ranked from highest to lowest risk.
```

---

## Vulnerability & Exploit Intelligence

11. Research threat intelligence context for a specific CVE
```
Provide a full threat intelligence report on <CVE-XXXX-XXXXX>. Include a plain-language description of the vulnerability, CVSS score and severity rating, affected products and versions, known exploitation status (proof-of-concept, active exploitation in the wild), associated threat actors or ransomware groups known to exploit it, and recommended mitigations or patches. Flag if it is listed in CISA's Known Exploited Vulnerabilities catalog.
```

12. Identify vulnerabilities being actively exploited in the wild
```
List all vulnerabilities currently being actively exploited in the wild that are relevant to <Specific Technology Stack or Product Suite: e.g., Microsoft Exchange, VPN appliances, Apache systems>. For each CVE, include: severity, exploitation method, threat actors or campaigns leveraging it, available patches or workarounds, and recommended immediate actions.
```

13. Assess organizational exposure to a specific threat campaign
```
Based on the recent threat campaign <Campaign Name or Description>, assess my organization's potential exposure. Cross-reference the campaign's known TTPs, targeted vulnerabilities, and IOCs against our environment signals. Identify which assets or configurations are most at risk and provide a prioritized list of defensive actions to reduce exposure.
```

---

## Campaign & Intelligence Article Analysis

14. Summarize the latest threat intelligence articles for a topic
```
Summarize all Microsoft Defender Threat Intelligence articles published in the last 30 days related to <Topic: e.g., ransomware, supply chain attacks, credential theft, or specific technology>. For each article, include: title, publication date, key findings, threat actors involved, targeted sectors, and recommended defensive measures. Highlight the highest-priority items for immediate action.
```

15. Deep-dive analysis of a specific threat intelligence article
```
Provide a detailed breakdown of the threat intelligence article titled <Article Title or Topic>. Extract and explain: the key threat actor(s) involved, timeline of activity, technical indicators, kill chain analysis mapped to MITRE ATT&CK, impacted industries and geographies, and specific defensive recommendations. Translate technical findings into actionable guidance for a security operations team.
```

16. Track the evolution of a specific malware family
```
Provide an intelligence timeline for the malware family <Malware Name>. Include: initial discovery date, key variant releases, changes in capabilities or delivery mechanisms over time, associated threat actors, notable campaigns, and current state of the threat. Assess whether this malware is increasing or decreasing in activity.
```

---

## KQL Hunting Queries

17. Generate a multi-signal threat actor hunting query
```
Generate a KQL hunting query for Microsoft Defender XDR to detect activity associated with <Threat Actor Name>. The query should combine at minimum three signal types: network indicators (IPs/domains), file-based indicators (hashes, filenames, paths), and behavioral patterns (process lineage, command-line arguments, or scheduled tasks). Deduplicate results, sort by timestamp descending, and project: DeviceName, AccountName, Timestamp, ActionType, FileName, RemoteIP, RemoteUrl, InitiatingProcessCommandLine. Add inline comments explaining the detection logic and provide a Sentinel (SecurityEvent / DeviceNetworkEvents) equivalent.
```

18. Build a multi-stage attack chain detection query
```
Write a KQL query for Microsoft Defender XDR that detects a multi-stage attack chain for the following MITRE ATT&CK technique sequence: <e.g., T1566 Phishing → T1059 Command Execution → T1105 Ingress Tool Transfer → T1071 C2 Communication>. The query should correlate events across DeviceProcessEvents, DeviceNetworkEvents, and DeviceFileEvents within a 1-hour window using a common AccountSid or DeviceId. Return: device, user, each stage detected, timestamps, and a composite risk score based on how many stages are matched.
```

19. Hunt for living-off-the-land binaries (LOLBins) abused by a threat actor
```
Generate a KQL query for Microsoft Defender XDR that hunts for abuse of Living-off-the-Land Binaries (LOLBins) associated with the TTPs of <Threat Actor Name or Campaign>. Focus on suspicious usage of: certutil, mshta, regsvr32, wscript, cscript, rundll32, msiexec, bitsadmin, and powershell with encoded commands. Filter out known-benign parent processes and software deployment baselines. Return: device, user, process, parent process, command line, and timestamp.
```

20. Generate a threat intelligence-driven Sentinel analytics rule
```
Based on the threat intelligence for <Threat Actor Name or Campaign>, generate a complete Microsoft Sentinel analytics rule in KQL. The rule should: define a query that detects the actor's primary attack pattern using SecurityEvent, OfficeActivity, AzureActivity, or DeviceNetworkEvents tables; set appropriate query frequency and lookback; include entity mappings for Account, Host, and IP; define alert details with severity, MITRE ATT&CK tactic and technique, and a descriptive name and description; and include suppression logic to reduce false positive noise. Output the full rule body ready for import.
```

21. Build a vulnerability exploitation hunting query for a specific CVE
```
Write a KQL hunting query for Microsoft Defender XDR to identify signs of active exploitation of <CVE-XXXX-XXXXX> in my environment. Include detection logic for: known exploit payloads or file hashes, suspicious child processes spawned by the vulnerable application, unusual outbound network connections following the vulnerability trigger, and any registry or file system artifacts left by the exploit. Add a section to identify which devices are running unpatched versions of the affected software using DeviceTvmSoftwareVulnerabilities.
```

22. Build a lateral movement detection query correlated with threat intelligence
```
Generate a KQL query for Microsoft Defender XDR that detects lateral movement techniques used by <Threat Actor Name>, specifically focusing on: pass-the-hash or pass-the-ticket activity, remote service creation, WMI or PsExec-style execution, SMB lateral movement, and use of stolen credentials from known compromised accounts. Correlate events across IdentityLogonEvents, DeviceProcessEvents, and DeviceNetworkEvents. Highlight activity that originates from the same source IP or account within a 30-minute window across multiple target devices.
```

23. Create a data exfiltration detection query tied to threat actor TTPs
```
Write a KQL query for Microsoft Defender XDR that detects data exfiltration patterns consistent with <Threat Actor Name> or <Campaign>. Include detection logic for: large file uploads to cloud storage or file-sharing domains, DNS tunneling patterns (unusually long subdomain queries or high-frequency lookups to a single domain), use of known exfiltration tools (e.g., Rclone, MEGAsync, WinSCP), and staged archive creation (zip/rar) in temp or user profile directories. Return: device, user, destination, data volume, and timestamp. Flag activity exceeding a configurable threshold.
```

24. Explain and optimize an existing KQL query
```
Analyze the following KQL query and provide: (1) a line-by-line plain English explanation of what each clause does; (2) identification of any performance issues such as broad time ranges, missing filters, or unindexed fields; (3) suggested optimizations to reduce query execution time and improve result precision; (4) any logic gaps that could produce false negatives or false positives; and (5) an optimized rewrite of the full query with your improvements applied. Query: <paste KQL query here>
```

25. Generate a watchlist-driven IOC matching query with triage output
```
Generate a KQL query for Microsoft Defender XDR that cross-references a dynamic watchlist of IOCs for <Threat Actor Name or Campaign> against live telemetry in DeviceNetworkEvents, DeviceProcessEvents, and EmailEvents tables. The query should: match on IP addresses, domains, file hashes, and email sender domains from the watchlist; deduplicate matches per device per 24-hour window; return a triage-ready output with columns for: matched indicator, indicator type, affected device, affected user, first seen, last seen, match count, and recommended immediate action (Block / Investigate / Monitor). Sort results by match count descending.
```

---

## Geopolitical & Industry Threat Landscape

20. Generate a current threat landscape briefing for a specific industry
```
Generate a current threat landscape briefing for the <Industry> sector. Include: the top 5 threat actors targeting this industry and their motivations, the most common attack techniques being used, recent campaigns or incidents impacting the sector, the top vulnerabilities being exploited, and recommended strategic security priorities for the next 90 days.
```

21. Assess the threat environment for a specific country or region
```
Assess the current threat environment for organizations operating in <Country or Region>. Provide intelligence on: active state-sponsored threat actors originating from or targeting this region, primary attack motivations (espionage, financial, disruption), sectors most at risk, recent notable incidents, and geopolitical factors influencing the threat landscape. Recommend key defensive priorities.
```

22. Identify emerging threat trends for executive briefing
```
Identify the top 5 emerging threat trends relevant to our organization in <Industry> operating in <Region>. For each trend, provide: a clear non-technical description suitable for executive communication, the underlying threat actors or motivations driving it, the potential business impact if unaddressed, and 2-3 concrete recommended actions. Format as an executive-ready briefing summary.
```

---

## Defensive Hardening & Response

23. Generate hardening recommendations based on threat actor TTPs
```
Based on the known TTPs of <Threat Actor Name>, generate a prioritized list of hardening and defensive measures for my organization. Map each recommendation to the specific technique it mitigates, include the relevant ATT&CK technique ID, and indicate whether this is a quick win (days), medium-term improvement (weeks), or strategic initiative (months). Prioritize by highest risk reduction impact.
```

24. Create an IOC watchlist for a threat actor
```
Create a comprehensive IOC watchlist for the threat actor <Threat Actor Name>. Organize by indicator type: IP addresses, domains, URLs, file hashes, email subjects/senders, and registry keys. For each indicator, include: last observed date, confidence level, associated campaign or malware family, and recommended detection or blocking action in Microsoft Defender and Sentinel.
```

25. Build a threat intelligence-driven incident response playbook entry
```
Based on threat intelligence for <Threat Actor Name or Attack Type>, draft a focused incident response playbook section covering: initial detection signals to look for, first 15-minute containment actions, key forensic evidence to collect, systems and accounts to prioritize for investigation, indicators that confirm or rule out this threat actor's involvement, and recommended communication and escalation triggers. Format for use by a Tier 2 SOC analyst.
```
