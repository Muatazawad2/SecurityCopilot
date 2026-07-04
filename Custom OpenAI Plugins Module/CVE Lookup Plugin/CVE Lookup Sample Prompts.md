# CVE Lookup Plugin — Sample Prompts

**Developer**: Dr Muataz Awad

**Description**: Sample prompts for querying the NIST National Vulnerability Database via the CVE Lookup OpenAI plugin in Microsoft Security Copilot. The plugin is invoked automatically when CVE identifiers or vulnerability-related queries are detected — no need to explicitly name the plugin in most cases.

---

## Lookup by CVE ID

### Single CVE details

- Look up CVE-2024-21413 and summarize the severity, affected products, and recommended remediation.
- What is CVE-2021-44228 (Log4Shell)? Provide the CVSS score, attack vector, and current status.
- Get the details for CVE-2023-44487 including severity and whether it has been patched.
- Look up CVE-2017-0144 (EternalBlue) and explain why it is still relevant to SOC operations today.
- What is the CVSS base score and attack complexity for CVE-2024-3400?

### Rapid triage during an incident

- We received an alert referencing CVE-2023-23397. Look it up and tell me the severity, attack vector, and what action an analyst should take immediately.
- A threat intel report mentions CVE-2022-41082 and CVE-2022-41040. Look up both CVEs and summarize the risk they pose to our Microsoft Exchange environment.
- During this investigation I found CVE-2024-21762 referenced in a malicious payload. Look it up and tell me what it allows an attacker to do.

---

## Search by Product or Vendor

### Product-specific vulnerability searches

- Find the top 5 critical CVEs related to Microsoft Exchange published in 2024.
- Search for high or critical severity CVEs affecting Fortinet FortiGate.
- What are the most recent critical CVEs for Cisco IOS?
- Find CVEs related to Apache Log4j and summarize the most severe ones.
- Search for critical vulnerabilities in VMware ESXi from the last 12 months.
- What critical CVEs affect Ivanti Connect Secure?

### Attack type searches

- Find CVEs related to remote code execution affecting Windows.
- Search for SQL injection CVEs with a CVSS score of 9.0 or above.
- What are recent critical CVEs involving privilege escalation on Linux?
- Find CVEs related to authentication bypass in web applications.

---

## Severity-Based Queries

- List the 10 most recently published CRITICAL severity CVEs.
- Are there any new CRITICAL CVEs published this week?
- Find all HIGH severity CVEs related to Microsoft that were published in the last 30 days.
- What CRITICAL CVEs should our patch management team prioritize this month?

---

## Investigation Context

### During an active incident

- I am investigating a compromised Windows server. Search for recent critical CVEs related to Windows Server remote code execution to identify potential exploitation vectors.
- We have a vulnerable version of OpenSSL (1.1.1) in our environment. Find CVEs affecting OpenSSL 1.1.1 with HIGH or CRITICAL severity.
- A user received a phishing email containing a malicious Office document. Look up recent CVEs related to Microsoft Office macro execution and summarize the risk.

### Threat hunting

- Find CVEs that have been associated with ransomware groups by searching for CVEs related to remote code execution in VPN products.
- Search for CVEs related to Outlook or Exchange that allow unauthenticated remote access.
- What are the CVSS 10.0 CVEs published in the last year?

---

## Reporting and Briefings

- Look up the 5 most critical CVEs from the last 30 days and summarize them in a format suitable for an executive briefing.
- Find the top HIGH and CRITICAL CVEs affecting our Microsoft product stack (Windows, Exchange, SharePoint, Teams) from 2024 and produce a patch priority list.
- Summarize CVE-2024-21413, CVE-2023-36884, and CVE-2023-23397 in a single table showing CVE ID, severity, CVSS score, affected product, and recommended action.

<!-- Repository maintenance marker -->
