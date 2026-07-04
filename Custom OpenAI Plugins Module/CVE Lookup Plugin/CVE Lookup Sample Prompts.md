# CVE Lookup Plugin — Sample Prompts

**Developer**: Dr Muataz Awad

**Description**: Sample prompts for the CVE Lookup OpenAI plugin in Microsoft Security Copilot. The plugin queries **CIRCL CVE Search** by CVE identifier — it is invoked automatically when a CVE ID is detected in the prompt.

> **Capability note**: This plugin supports **lookup by CVE ID only** (e.g. `CVE-2024-21413`).
> It does not support keyword search, product-based discovery, or severity filtering.
> To find CVE IDs for a product, use [nvd.nist.gov/vuln/search](https://nvd.nist.gov/vuln/search) first,
> then bring the IDs into Security Copilot for analysis.

---

## Lookup by CVE ID

### Single CVE details

- Look up CVE-2024-21413 and summarize the severity, affected products, and recommended remediation.
- What is CVE-2021-44228 (Log4Shell)? Provide the CVSS score, attack vector, and current status.
- Get the details for CVE-2023-44487 including severity and whether it has been patched.
- Look up CVE-2017-0144 (EternalBlue) and explain why it is still relevant to SOC operations today.
- What is the CVSS base score and attack complexity for CVE-2024-3400?
- Look up CVE-2022-26134 and tell me what product it affects and how it is exploited.
- What does CVE-2023-20198 allow an attacker to do? What is the severity?

### Rapid triage during an incident

- We received an alert referencing CVE-2023-23397. Look it up and tell me the severity, attack vector, and what action an analyst should take immediately.
- During this investigation I found CVE-2024-21762 referenced in a malicious payload. Look it up and tell me what it allows an attacker to do.
- A threat intel report mentions CVE-2022-41082 and CVE-2022-41040. Look up both and summarize the combined risk to our Microsoft Exchange environment.
- Look up CVE-2021-44228 and CVE-2021-45046 and explain the difference between the two Log4j vulnerabilities.
- We found CVE-2019-0708 (BlueKeep) referenced in a lateral movement tool. Look it up and summarize the risk.

---

## Contextual Investigation Support

### During an active investigation

- I am investigating a compromised Windows server. Look up CVE-2024-21413 and tell me whether this vulnerability could have been exploited remotely without credentials.
- A user received a phishing email exploiting a vulnerability. Look up CVE-2023-36884 and explain what product is affected and what an attacker could achieve.
- We detected exploitation traffic referencing CVE-2021-44228. Look it up and give me the CVSS score, attack vector, and what the attacker can do if they succeed.
- Our EDR flagged an exploit attempt. Look up CVE-2022-41082 and explain if this requires authentication and what the impact would be.

### Patch management support

- Look up CVE-2024-21413 and summarize it in a format suitable for a patch management ticket — include CVE ID, severity, CVSS score, affected product, and recommended action.
- Look up CVE-2023-44487 (HTTP/2 Rapid Reset) and tell me the severity, CVSS score, and what type of attack it enables.
- I need to brief my manager on CVE-2021-44228. Look it up and produce a one-paragraph non-technical summary suitable for executive communication.
- Look up CVE-2024-3400 and tell me whether it requires user interaction and what the patch status is according to the reference links.

---

## Multi-CVE Reporting

- Look up CVE-2024-21413, CVE-2023-23397, and CVE-2022-41082 one by one and produce a single table showing CVE ID, severity, CVSS score, affected product, and whether user interaction is required.
- Look up these three Ivanti CVEs: CVE-2024-21887, CVE-2024-21893, CVE-2023-46805. Summarize each and rank them by CVSS score.

<!-- Repository maintenance marker -->
