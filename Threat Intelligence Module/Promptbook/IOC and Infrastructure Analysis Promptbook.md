# IOC and Infrastructure Analysis

**Developer**: Dr Muataz Awad

**Description**: Perform a structured analysis of a suspicious indicator of compromise (IOC) — IP address, domain, URL, or file hash — using Microsoft Defender Threat Intelligence. Enrich the indicator, pivot on related infrastructure, map attribution, assess active threat campaigns, and produce a triage verdict with recommended response actions. Results may be limited if the Microsoft Threat Intelligence plugin is not enabled or the user lacks required permissions.

---

1. Enrich the initial indicator and establish its threat context
```
Enrich the following indicator: {IOC} (type: {IOCType: IP address / domain / URL / file hash}). Provide a full threat intelligence summary including: geolocation and ASN (for IPs), registration details and WHOIS history (for domains), reputation score, known threat categories (malware C2, phishing, botnet, scanner, etc.), first and last observed dates, and any associated threat actor or malware family attribution. Assign an initial risk verdict of Low, Medium, High, or Critical.
```

2. Retrieve all threat intelligence articles referencing this indicator
```
Search Microsoft Defender Threat Intelligence for all articles, reports, and intelligence entries that reference the indicator {IOC}. For each result, provide: title, publication date, key findings, the threat actor or campaign associated with this indicator, and the context in which this indicator appeared (C2 infrastructure, phishing kit, payload delivery, etc.). Identify whether this indicator is currently active or historical.
```

3. Pivot to discover related malicious infrastructure
```
Perform an infrastructure pivot analysis on {IOC}. Identify all related indicators that share infrastructure characteristics such as: hosting provider or ASN block, SSL/TLS certificate fingerprint or subject, domain registrar and registration pattern, WHOIS data similarity, passive DNS co-resolution, or behavioral similarity. For each discovered related indicator, provide its type, current reputation, threat association, and whether it is active. Map the full infrastructure cluster visually if possible.
```

4. Identify all threat actors and campaigns associated with this indicator
```
Identify every known threat actor and campaign that has used or is currently associated with {IOC}. For each association, include: actor name and origin, the campaign name or timeframe, how this indicator was used (initial access, C2, data exfiltration, phishing, etc.), and the confidence level of the attribution. Flag if multiple distinct threat actors have leveraged the same infrastructure, which may indicate shared tooling or infrastructure-as-a-service (IaaS) hosting.
```

5. Check for organizational exposure to this indicator
```
Determine whether the indicator {IOC} or any of the related infrastructure discovered has been observed in our environment. Search across available telemetry including: network connection logs, DNS query history, email headers and links, endpoint process network connections, and alert history. If matched, provide: the affected device(s), user(s), timestamp(s), and the context of the interaction. Assess whether this constitutes a confirmed breach, a potential exposure, or a false positive.
```

6. Generate blocking and detection recommendations
```
Based on the full enrichment and pivot analysis of {IOC} and its associated infrastructure cluster, generate a complete response action plan. Include: (1) a definitive list of all indicators that should be immediately blocked in Microsoft Defender, Sentinel, and network security controls; (2) KQL detection queries to hunt for any historical or ongoing interactions with this infrastructure across DeviceNetworkEvents, EmailEvents, and DeviceProcessEvents; (3) recommended threat intelligence feed updates; and (4) any additional monitoring rules to detect future reuse of this infrastructure pattern.
```

7. Produce a final IOC triage report
```
Produce a structured triage report for the indicator {IOC} and its associated infrastructure. Include: executive summary (2–3 sentences), full enrichment findings, infrastructure cluster map, threat actor and campaign attributions, organizational exposure assessment, risk verdict (Low / Medium / High / Critical) with justification, and a prioritized response checklist. Format for use as a shareable intelligence product by a SOC team.
```

---

## How To Create This Promptbook In Security Copilot

1. Start by running step 1 and replacing `{IOC}` with the indicator under investigation and `{IOCType}` with its type (IP address, domain, URL, or file hash).
2. Security Copilot retains the indicator context across subsequent steps — do not repeat the value.
3. Replace `{IOC}` in steps 2–7 only on first run; subsequent promptbook executions will prompt for it once.
4. Select all prompts to include them in the promptbook.
5. Enter the promptbook name: **IOC and Infrastructure Analysis** and add a description.
6. Choose sharing scope (personal, team, or organization).
7. Select **Create**, verify the success message, and open the promptbook from the library.
