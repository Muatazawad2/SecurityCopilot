# SOC IOC Enricher — Sample Prompts

**Developer**: Dr Muataz Awad

**Description**: Sample prompts for the SOC IOC Enricher MCP server in Microsoft Security Copilot. The server auto-detects IOC type, accepts defanged IOCs and comma-separated lists, and queries 4–9 threat intelligence sources simultaneously — returning a structured intelligence report with threat level, context, key findings, and recommended SOC actions.

> **Supported IOC types**: IPv4 addresses · MD5/SHA1/SHA256 file hashes · domain names · URLs (http/https)
> **Accepts defanged input**: `185[.]220[.]101[.]45`, `hxxps://malicious[.]ru/payload` are automatically refanged before lookup.
> **Batch support**: Pass multiple IOCs separated by commas in a single prompt.

---

## Auto-Detection (Primary — Use This)

- Enrich this IOC: 185.220.101.45
- Is this indicator malicious? 45.33.32.156
- Investigate this IOC and tell me the threat level: malicious-domain.com
- What is the threat intelligence on this hash: 44d88612fea8a8f36de82e1278abb02f
- Enrich this defanged IOC: 185[.]220[.]101[.]45

---

## Batch / Multi-IOC Triage

- Investigate these IOCs from a phishing incident: 185.220.101.45, 91.108.4.1, google.com
- I have three indicators from a ransomware alert. Enrich each and tell me which require immediate blocking: 103.21.244.0, fake-microsoft-update.com, bd60b7a95e5ee3efaf1b11c5a94e2aac
- Triage these IOCs extracted from a malicious email: 5.188.206.14, verify-account-secure.net, hxxps://malicious-site[.]ru/payload
- Enrich all indicators from this incident: 45.33.32.156, 198.51.100.42, d41d8cd98f00b204e9800998ecf8427e, suspicious-login.net

---

## IP Address Enrichment

- Check the reputation of IP 185.220.101.45 and provide the threat level, intelligence findings, and recommended SOC actions.
- We detected outbound traffic to 45.33.32.156 — investigate this IP, identify the organization and abuse history, and recommend whether to block it.
- During an incident investigation we found connections to 91.108.4.0 — enrich this IP and confirm if it is associated with known threat infrastructure.
- Our SIEM triggered an alert for authentication from IP 103.21.244.0 — enrich this IP and assess the risk.
- A threat actor report references infrastructure at 5.188.206.14 — investigate and provide the threat context.

---

## File Hash Enrichment

- A suspicious file was quarantined by our AV with MD5 hash 44d88612fea8a8f36de82e1278abb02f — identify the malware family and assess severity.
- Our EDR detected execution of a file with SHA256: 275a021bbfb6489e54d471899f7db9d1663fc695ec2fe2a2c4538aabf651fd0f — investigate and tell me if we should isolate affected endpoints.
- During incident response we found a suspicious executable. Hash: a04ac6d98ad989312783d4fe3456c54730907d05 — identify it and recommend response actions.
- A threat intel report mentions hash bd60b7a95e5ee3efaf1b11c5a94e2aac — investigate and tell me if any of our endpoints should be checked.

---

## Domain Enrichment

- Investigate domain suspicious-login-alert.com — provide threat level, registration age, and whether to block at DNS.
- A user clicked a link to verify-account-security.net — investigate this domain and assess whether users who clicked are at risk.
- Our DNS logs show repeated queries to update-microsoft-windows.com — investigate and tell me if this is C2 infrastructure.
- Check the domain malware-c2.xyz — provide WHOIS registration age, URLScan history, and recommended action.

---

## URL Enrichment

- Investigate this URL found in a phishing email: https://login-secure-verify.ru/microsoft/auth
- A user received a link to hxxps://update-windows-security[.]com/patch — is this malicious?
- Our proxy blocked access to https://malicious-payload.xyz/dropper.exe — enrich this URL and assess the threat.

---

## Active Incident Investigation

- I am investigating a compromised workstation. The EDR shows outbound connections to 91.108.4.0 on port 443 — enrich this IP and tell me if this is consistent with malware C2 communication.
- We are triaging a ransomware alert. The malicious process contacted 5.188.206.14 and also made DNS requests to malware-c2.xyz — enrich both indicators and confirm if they are ransomware infrastructure.
- During phishing investigation I found a redirect to analytics-secure-login.com — investigate and tell me the domain registration age, malicious scan history, and whether users who visited it need remediation.
- Our sandbox detonated a suspicious file (SHA256: 275a021bbfb6489e54d471899f7db9d1663fc695ec2fe2a2c4538aabf651fd0f) — investigate and provide threat category, severity, and recommended response.

---

## Defanged IOC Handling

- Enrich this IOC from a threat report (defanged): 185[.]220[.]101[.]45
- Investigate this URL from a phishing alert: hxxps://verify-account[.]malicious-site[.]ru/login
- Our threat intel team shared this indicator in defanged format: update-windows[.]malware-domain[.]com — enrich it.

<!-- Repository maintenance marker -->


---

## Auto-Detection (Primary — Use This)

- Enrich this IOC: 45.33.32.156
- Investigate this indicator: malicious-domain.com
- What is the threat intelligence on this hash: 44d88612fea8a8f36de82e1278abb02f
- Enrich this IOC and tell me if I should block it: 198.51.100.42
- Is this indicator malicious? bd60b7a95e5ee3efaf1b11c5a94e2aac

---

## IP Address Enrichment

- Check the reputation of IP 185.220.101.47 and tell me if it should be blocked.
- Enrich this IP address from a suspicious login alert: 103.21.244.0
- We detected outbound traffic to 45.33.32.156 — investigate this IP and provide a verdict.
- What country and organization does this IP belong to? Is it associated with known abuse? IP: 94.102.49.190
- During an incident investigation we found connections to 91.108.4.0 — enrich this IP and recommend whether to block it.

---

## File Hash Enrichment

- Investigate this MD5 hash found in our EDR: 44d88612fea8a8f36de82e1278abb02f
- A user downloaded a file with SHA256 hash 275a021bbfb6489e54d471899f7db9d1663fc695ec2fe2a2c4538aabf651fd0f — is it malware?
- Our AV flagged a file with this hash: bd60b7a95e5ee3efaf1b11c5a94e2aac — look it up and tell me the malware family.
- During incident response we found a suspicious executable. Hash: a04ac6d98ad989312783d4fe3456c54730907d05 — what is it?
- A threat intel report mentions hash 44d88612fea8a8f36de82e1278abb02f — investigate and tell me if we should quarantine affected endpoints.

---

## Domain Enrichment

- Investigate this domain found in phishing email headers: suspicious-login-alert.com
- A user clicked a link to verify-account-security.net — investigate this domain.
- Our DNS logs show repeated queries to update-microsoft-windows.com — is this malicious?
- Enrich this domain found in a C2 communication alert: fast-flux-domain.ru
- A threat actor report mentions infrastructure domain malware-c2.xyz — investigate and provide a verdict.

---

## Active Investigation Context

- I am investigating a compromised workstation. The EDR shows outbound connections to 91.108.4.0 on port 443. Enrich this IP and tell me if this is consistent with malware C2 communication.
- During a phishing investigation I found a redirect to analytics-secure-login.com — investigate this domain and tell me whether users who clicked it are at risk.
- Our sandbox detonated a suspicious file and produced this SHA256: 275a021bbfb6489e54d471899f7db9d1663fc695ec2fe2a2c4538aabf651fd0f — investigate and tell me the threat category and recommended response.
- We are triaging a ransomware alert. The suspicious process made connections to 5.188.206.0 — enrich this IP and confirm whether it is associated with ransomware infrastructure.

---

## Multi-IOC Triage

- I have three IOCs from a single incident. Investigate each one and give me a combined threat assessment:
  1. IP: 185.220.101.47
  2. Domain: phishing-login.net
  3. Hash: 44d88612fea8a8f36de82e1278abb02f

- Our threat intel team provided these indicators. Enrich each one and tell me which require immediate blocking:
  - 103.21.244.0
  - fake-microsoft-update.com
  - bd60b7a95e5ee3efaf1b11c5a94e2aac

<!-- Repository maintenance marker -->
