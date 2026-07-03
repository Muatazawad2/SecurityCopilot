# Azure AI Search Promptbooks

**Developer**: Dr Muataz Awad

## Overview

These promptbooks provide structured, multi-step workflows for querying an organizational knowledge base connected to Microsoft Security Copilot via the Azure AI Search plugin. They are designed to guide analysts through systematic knowledge retrieval during security investigations, incident response, and compliance reviews.

## Available Promptbooks

| Promptbook | Playbooks it draws from | Description |
|---|---|---|
| [Security Knowledge Base Investigation](Security%20Knowledge%20Base%20Investigation%20Promptbook.md) | All indexed documents | Systematically search policies, procedures, and compliance requirements during an active investigation |
| [Incident Response Procedure Lookup](Incident%20Response%20Procedure%20Lookup%20Promptbook.md) | All indexed documents | Retrieve the correct IR playbook, containment steps, escalation paths, and documentation requirements for any incident type |
| [Ransomware Investigation and Response](Ransomware%20Investigation%20and%20Response%20Promptbook.md) | Detecting Human-Operated Ransomware, Responding to Ransomware Attacks, Microsoft IR Ransomware Best Practices | Full ransomware lifecycle: detection signals → containment → eradication → recovery → hardening |
| [Password Spray Investigation](Password%20Spray%20Investigation%20Promptbook.md) | Password Spray Investigation Playbook | Dedicated password spray investigation: spray pattern analysis, scope compromised accounts, investigate post-compromise, revoke sessions, block attacker infrastructure |
| [Token Theft Investigation](Token%20Theft%20Investigation%20Promptbook.md) | Token Theft Playbook | Dedicated token theft investigation: identify token type and theft mechanism, scope replay activity, revoke tokens, investigate post-compromise, harden token security |
| [App Consent Grant Investigation](App%20Consent%20Grant%20Investigation%20Promptbook.md) | App Consent Grant Investigation Playbook | Dedicated OAuth consent grant investigation: identify malicious app, enumerate consenting users, assess data access, revoke consent, disable service principal |
| [Compromised Application Investigation](Compromised%20Application%20Investigation%20Promptbook.md) | Compromised and Malicious Applications Playbook | Dedicated compromised/malicious app investigation: classify threat, analyse permissions, assess activity scope, disable app, remediate affected users and workloads |
| [Identity Attack Investigation](Identity%20Attack%20Investigation%20Promptbook.md) | Password Spray Playbook, Token Theft Playbook | Combined identity attack workflow — use when attack type is unclear |
| [Phishing Investigation](Phishing%20Investigation%20Promptbook.md) | Phishing Investigation Playbook | 10-step phishing investigation: classify attack, scope campaign, analyze headers and URLs, identify compromised users, check post-compromise activity, remediate, notify |
| [Application Threat Investigation](Application%20Threat%20Investigation%20Promptbook.md) | App Consent Grant Playbook, Compromised and Malicious Applications Playbook | Investigate malicious OAuth consent grants and compromised applications: audit permissions, revoke access, assess impact |

## Prerequisites

- Azure AI Search plugin configured in Microsoft Security Copilot.
- An Azure AI Search index containing your organization's knowledge base documents.
- Explicitly include **"Azure AI Search"** in every prompt step to invoke the plugin.

<!-- Repository maintenance marker -->
