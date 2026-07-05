# SOC IOC Enricher — Sample Prompts

**Developer**: Dr Muataz Awad

**Description**: Sample prompts for the SOC IOC Enricher MCP server in Microsoft Security Copilot. The server auto-detects IOC type and queries multiple threat intelligence sources in a single call — returning one correlated verdict.

> **Supported IOC types**: IPv4 addresses, MD5/SHA1/SHA256 file hashes, domain names.
> Use `enrich_ioc` as the primary tool — it auto-detects the type. Use the specific tools (`enrich_ip`, `enrich_hash`, `enrich_domain`) when you know the type.

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
