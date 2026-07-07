# Phishing Incident IOC Investigation Promptbook

**Developer**: Dr Muataz Awad

A Security Copilot promptbook for investigating all indicators extracted from a phishing incident. Combines the SOC IOC Enricher plugin with Microsoft Sentinel and Microsoft Defender for a complete end-to-end triage workflow.

---

## When to Use

Use this promptbook when:
- A phishing email has been reported by a user or detected by Defender
- You have extracted one or more IOCs (sender IP, redirect URLs, attachment hashes, C2 domains)
- You need a complete triage decision: block, investigate, or clear

---

## Prerequisites

- SOC IOC Enricher plugin enabled in Security Copilot
- Microsoft Sentinel plugin enabled
- Microsoft Defender for Endpoint plugin enabled (optional — enhances device investigation steps)

---

## Promptbook Steps

### Step 1 — Enrich all extracted IOCs

```
Investigate these IOCs extracted from the phishing incident and provide a threat level, intelligence summary, and recommended action for each:

[PASTE COMMA-SEPARATED IOCs HERE]

Example: 185.220.101.45, malicious-login.ru, d41d8cd98f00b204e9800998ecf8427e
```

> The SOC IOC Enricher will auto-detect each type (IP / domain / hash), query IPinfo.io, AbuseIPDB, VirusTotal, AlienVault OTX, Google DNS, URLScan.io, URLhaus, and RDAP simultaneously, and return a structured report with threat level and recommended actions.

---

### Step 2 — Check Sentinel for exposure

```
Search Microsoft Sentinel for any alerts or incidents related to the following IOCs in the last 7 days:

[PASTE IOCs HERE]

Also check if any internal hosts communicated with these indicators.
```

---

### Step 3 — Identify exposed users (if email-based phishing)

```
In Microsoft Defender, check whether any users received or clicked the phishing link to [DOMAIN/URL] in the last 24 hours. List affected user accounts and devices.
```

---

### Step 4 — Scope the blast radius

```
Based on the malicious IOCs identified above, search Sentinel and Defender for:
1. Any endpoints that communicated with the malicious IPs or domains
2. Any file executions matching the malicious hash
3. Any authentication events from the malicious IP

Provide a list of affected users and devices.
```

---

### Step 5 — Recommended containment actions

```
Based on the enrichment results and Sentinel findings above, provide a prioritized containment plan including:
1. Which IOCs to block at firewall / DNS / proxy and why
2. Which endpoints or users require immediate investigation
3. Whether this appears to be a targeted or opportunistic attack
4. Suggested incident severity (P1/P2/P3)
```

---

## Quick Reference — Single Prompt Version

If you want the entire triage in one prompt:

```
I am investigating a phishing incident. Here are all extracted indicators:

IPs: [list]
Domains/URLs: [list]
File hashes: [list]

Please:
1. Enrich each indicator using the SOC IOC Enricher and provide threat level and key findings
2. Search Sentinel for any related alerts or host exposure in the last 7 days
3. Identify any affected users or endpoints
4. Provide a prioritized containment and remediation plan
```

---

## Output Example

After running Step 1, Security Copilot will return a report like:

**185.220.101.45**
- Threat Level: CRITICAL — MALICIOUS (100%)
- Context: Tor exit node, Berlin, Germany. Used to anonymize attacker traffic.
- AbuseIPDB: 100% confidence, 137 reports
- VirusTotal: 15/91 engines flagged
- Action: Block at firewall immediately

**malicious-login.ru**
- Threat Level: HIGH — MALICIOUS
- Context: Recently registered domain (12 days old). URLhaus malware distribution record.
- Action: Block at DNS resolver and proxy

<!-- Repository maintenance marker -->
