# Phishing Investigation

**Developer**: Dr Muataz Awad

**Description**: A structured, multi-step promptbook for investigating phishing incidents using the Microsoft Phishing Investigation Playbook indexed in Azure AI Search. This workflow guides SOC analysts through identifying and classifying phishing messages, scoping the campaign, investigating affected users, analyzing indicators, remediating the threat, and producing an investigation summary. Results may be limited if the phishing playbook is not present in the connected index or the Azure AI Search plugin is not configured.

---

1. Classify the phishing message and identify the attack type

```
Search Azure AI Search for the phishing classification criteria and attack types described in the Microsoft phishing investigation playbook. Based on the reported message, identify the type of phishing attack (credential harvesting, malware delivery, business email compromise, spear phishing) and what the key indicators are.
```

2. Retrieve the initial triage and evidence collection steps

```
Using Azure AI Search, find the initial triage steps for a phishing investigation. What information and evidence should be collected from the reported email — including headers, sender details, URLs, attachments, and recipient list — and in what order should this be gathered?
```

3. Scope the campaign — identify all affected recipients

```
Search Azure AI Search for the steps to scope a phishing campaign and identify all recipients. What Microsoft Defender, Exchange, or Entra ID queries and investigation steps are described for determining how many users received the message, how many opened it, and how many clicked any links or submitted credentials?
```

4. Analyze email headers and sender authentication

```
Using Azure AI Search, find the guidance for analyzing email headers and sender authentication signals in a phishing investigation. What fields — including SPF, DKIM, DMARC, return-path, and X-headers — should be examined, and what do anomalous values indicate?
```

5. Investigate malicious URLs and attachments

```
Search Azure AI Search for the steps to investigate malicious URLs and attachments identified in a phishing email. What analysis and detonation steps are described, and how should analysts assess whether links led to credential harvesting pages, malware downloads, or attacker-controlled infrastructure?
```

6. Identify users who clicked or submitted credentials

```
Using Azure AI Search, find the investigation steps for identifying users who clicked phishing links or submitted credentials. What sign-in logs, risky sign-in alerts, and behavioral signals should be reviewed to determine if any accounts were compromised as a result of the phishing campaign?
```

7. Check for post-compromise activities and inbox rule manipulation

```
Search Azure AI Search for the steps to investigate post-compromise activities following a phishing attack. What should analysts check for — including suspicious inbox forwarding rules, mailbox delegation changes, OAuth consent grants, and attacker persistence mechanisms — that indicate the attacker gained access to a mailbox?
```

8. Retrieve email remediation and blocking steps

```
Using Azure AI Search, find the remediation steps for a phishing campaign. What actions are required to purge the phishing emails from all recipient mailboxes, block the sender domain and IP, block the malicious URLs, and prevent further delivery of the campaign?
```

9. Look up user notification and awareness requirements

```
Search Azure AI Search for the user notification requirements following a phishing incident. Who must be notified, what information should be communicated to affected users, and what guidance should be provided to help users protect themselves and recognize similar attacks in future?
```

10. Generate a phishing investigation summary

```
Based on all information retrieved from Azure AI Search in this session, produce a comprehensive phishing investigation summary that includes:
- Attack type and classification
- Campaign scope: total recipients, users who clicked, users who submitted credentials
- Key indicators: sender, URLs, attachment hashes, infrastructure
- Accounts confirmed compromised and post-compromise activity found
- Inbox rules or persistence mechanisms discovered
- Remediation actions completed (email purge, blocks applied)
- User notification actions taken
- Recommended follow-up steps and hardening measures
Format the output as a structured investigation report suitable for SOC records and management review.
```

<!-- Repository maintenance marker -->
