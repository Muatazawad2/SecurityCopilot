# Azure AI Search Module

Comprehensive guides and resources for integrating Azure AI Search with Microsoft Security Copilot. This module enables you to connect your organization's knowledge base — including security policies, SOC runbooks, investigation procedures, KQL libraries, and compliance documents — into Copilot for contextual, grounded responses during security operations.

**Developer**: Dr Muataz Awad

## What Is Azure AI Search in Security Copilot?

Azure AI Search is a built-in Microsoft plugin for Security Copilot that connects a configured Azure AI Search index to your Copilot workspace. Once connected, analysts can reference organizational knowledge directly in their Copilot sessions using natural language, enabling faster triage, more relevant investigations, and policy-aware responses.

![Architecture — The Why](Images/architecture.png)

## Key Resources

- [Complete Setup Guide](Plugins/Azure%20AI%20Search%20Complete%20Setup%20Guide.md) ← Start here
- [Sample Prompts](Sample%20Prompts/Azure%20AI%20Search%20Sample%20Prompts.md)
- [Phishing Investigation Promptbook](Promptbook/Phishing%20Investigation%20Promptbook.md)
- [Password Spray Investigation Promptbook](Promptbook/Password%20Spray%20Investigation%20Promptbook.md)
- [Token Theft Investigation Promptbook](Promptbook/Token%20Theft%20Investigation%20Promptbook.md)
- [App Consent Grant Investigation Promptbook](Promptbook/App%20Consent%20Grant%20Investigation%20Promptbook.md)
- [Compromised Application Investigation Promptbook](Promptbook/Compromised%20Application%20Investigation%20Promptbook.md)
- [Ransomware Investigation and Response Promptbook](Promptbook/Ransomware%20Investigation%20and%20Response%20Promptbook.md)
- [Identity Attack Investigation Promptbook](Promptbook/Identity%20Attack%20Investigation%20Promptbook.md)
- [Application Threat Investigation Promptbook](Promptbook/Application%20Threat%20Investigation%20Promptbook.md)
- [Security Knowledge Base Investigation Promptbook](Promptbook/Security%20Knowledge%20Base%20Investigation%20Promptbook.md)
- [Incident Response Procedure Lookup Promptbook](Promptbook/Incident%20Response%20Procedure%20Lookup%20Promptbook.md)

## Module Structure

```
Azure AI Search Module/
├── README.md                                          ← This file
├── Images/                                            ← Screenshots from real deployment
├── Plugins/
│   ├── README.md
│   ├── Azure AI Search Complete Setup Guide.md        ← Primary guide (all phases + screenshots)
│   └── Azure AI Search Plugin Setup Guide.md          ← Quick reference: Copilot plugin connection
├── Sample Prompts/
│   ├── README.md
│   └── Azure AI Search Sample Prompts.md
└── Promptbook/
    ├── README.md
    ├── Security Knowledge Base Investigation Promptbook.md
    └── Incident Response Procedure Lookup Promptbook.md
```

## Key Capabilities

| Capability | Description |
|---|---|
| Knowledge Base Query | Search organizational policies, runbooks, and procedures |
| Hybrid Search | Combines semantic vector search with keyword search |
| Contextual Grounding | Grounds Copilot responses in your proprietary content |
| SOC Runbook Lookup | Retrieve step-by-step incident response procedures |
| Compliance Reference | Pull applicable compliance and regulatory requirements |
| KQL Library Access | Find and retrieve KQL queries stored in your index |

## Known Limitations

- Only one Azure AI Search index can be connected at a time.
- To query a different index, update the plugin settings with the new index details.
- You must explicitly mention **"Azure AI Search"** in your prompt to invoke this plugin.
- Hybrid search (keyword + vector) requires the index to be configured with `text-embedding-ada-002` vectors.
- Document titles from the index are displayed but are not hyperlinked in responses.
- Private link endpoints are not supported.

<!-- Repository maintenance marker -->
