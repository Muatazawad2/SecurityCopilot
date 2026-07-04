# Security Copilot Workshop

Comprehensive workshop materials for Microsoft Security Copilot across Microsoft Purview, Microsoft Entra, Microsoft Defender Threat Intelligence, Azure AI Search, and Custom OpenAI Plugins. This repository provides prompt engineering best practices, investigation workflows, agent setup guides, knowledge base integration, and practical SOC-focused playbooks.

## Overview

This repository contains curated content designed to help security analysts and administrators effectively leverage Security Copilot for:

- Insider risk investigations and alert triage
- Identity and access investigations in Entra
- Threat intelligence research and actor analysis
- Vulnerability and exploit intelligence workflows
- Incident response acceleration and reporting
- Agent-driven automation and embedded investigation experiences
- Organizational knowledge base integration via Azure AI Search
- Custom OpenAI plugins connecting Security Copilot to external and internal REST APIs

## Modules

### [Entra Module](Entra%20Module/README.md)

Security Copilot content for Entra ID investigations, access governance, conditional access analysis, and incident response workflows.

### [Purview Module](Purview%20Module/README.md)

Security Copilot content for Insider Risk Management (IRM), including promptbooks, sample prompts, agent setup guides, embedded experience guidance, and KQL plugins.

### [Threat Intelligence Module](Threat%20Intelligence%20Module/)

Security Copilot content for Microsoft Defender Threat Intelligence, including analyst-ready sample prompts, investigation promptbooks, and Threat Intelligence Briefing Agent setup guides.

### [Azure AI Search Module](Azure%20AI%20Search%20Module/README.md)

End-to-end setup and resources for connecting an organizational knowledge base to Security Copilot via Azure AI Search. Includes a complete setup guide with 20 screenshots from a real deployment, 10 investigation promptbooks grounded in Microsoft security playbooks, and sample prompts for querying policies, runbooks, and SOC procedures.

### [Custom OpenAI Plugins Module](Custom%20OpenAI%20Plugins%20Module/README.md)

OpenAI-format plugins for extending Security Copilot with external REST APIs. Includes a working CVE Lookup plugin (queries CIRCL CVE Search — no auth required), an internal security API template for wrapping SIEM/CMDB/incident management tools, and a CVE triage promptbook.

## Quick Navigation

### Entra

- **[Entra Promptbooks](Entra%20Module/Promptbook/README.md)**
- **[Entra Sample Prompts](Entra%20Module/Sample%20Prompts/README.md)**
- **[Entra Embedded Experiences](Entra%20Module/Embedded%20Experiences/README.md)**
- **[Entra Agents](Entra%20Module/Agents/README.md)**
- **[Entra Plugins](Entra%20Module/Plugins/README.md)**

### Purview IRM

- **[IRM Investigation Promptbook](Purview%20Module/IRM/Promptbook/IRM%20Investigation%20Promptbook.md)**
- **[IRM Sample Prompts](Purview%20Module/IRM/Sample%20Prompts/IRM%20Sample%20Prompts.md)**
- **[User Investigation Guide](Purview%20Module/IRM/Embedded%20Experiences/User%20Investigation%20Guide.md)**
- **[IRM Triage Agent Setup Guide](Purview%20Module/IRM/Agents/IRM%20Triage%20Agent%20Setup%20Guide.md)**
- **[Triage Agent Dashboard Guide](Purview%20Module/IRM/Agents/Triage%20Agent%20Dashboard%20Guide.md)**
- **[Purview IRM Activity KQL Plugin](Purview%20Module/IRM/Plugins/Purview%20IRM%20Activity%20KQL%20Plugin.yaml)**
- **[Purview IRM KQL Plugin Installation Guide](Purview%20Module/IRM/Plugins/Purview%20IRM%20KQL%20Plugin%20-%20Installation%20Guide.md)**

### Threat Intelligence Module

- **[Threat Intelligence Plugins](Threat%20Intelligence%20Module/Plugins/README.md)**
- **[Threat Intelligence Sample Prompts](Threat%20Intelligence%20Module/Sample%20Prompts/Threat%20Intelligence%20Sample%20Prompts.md)**
- **[Threat Actor Investigation Promptbook](Threat%20Intelligence%20Module/Promptbook/Threat%20Actor%20Investigation%20Promptbook.md)**
- **[IOC and Infrastructure Analysis Promptbook](Threat%20Intelligence%20Module/Promptbook/IOC%20and%20Infrastructure%20Analysis%20Promptbook.md)**
- **[Vulnerability and Exploit Intelligence Promptbook](Threat%20Intelligence%20Module/Promptbook/Vulnerability%20and%20Exploit%20Intelligence%20Promptbook.md)**
- **[Ransomware Campaign Investigation Promptbook](Threat%20Intelligence%20Module/Promptbook/Ransomware%20Campaign%20Investigation%20Promptbook.md)**
- **[Executive Threat Intelligence Briefing Promptbook](Threat%20Intelligence%20Module/Promptbook/Executive%20Threat%20Intelligence%20Briefing%20Promptbook.md)**
- **[Threat Intelligence-Driven Incident Response Promptbook](Threat%20Intelligence%20Module/Promptbook/Threat%20Intelligence-Driven%20Incident%20Response%20Promptbook.md)**
- **[Threat Intelligence Briefing Agent Setup Guide](Threat%20Intelligence%20Module/Agents/Threat%20Intelligence%20Briefing%20Agent%20Setup%20Guide.md)**
- **[Threat Intelligence Briefing Agent in Microsoft Defender Setup Guide](Threat%20Intelligence%20Module/Agents/Threat%20Intelligence%20Briefing%20Agent%20in%20Microsoft%20Defender%20Setup%20Guide.md)**

### Azure AI Search Module

- **[Complete Setup Guide](Azure%20AI%20Search%20Module/Plugins/Azure%20AI%20Search%20Complete%20Setup%20Guide.md)** — End-to-end: Azure AI Search + Azure OpenAI + Storage + index build + Security Copilot connection
- **[Azure AI Search Sample Prompts](Azure%20AI%20Search%20Module/Sample%20Prompts/Azure%20AI%20Search%20Sample%20Prompts.md)**
- **[Phishing Investigation Promptbook](Azure%20AI%20Search%20Module/Promptbook/Phishing%20Investigation%20Promptbook.md)**
- **[Ransomware Investigation and Response Promptbook](Azure%20AI%20Search%20Module/Promptbook/Ransomware%20Investigation%20and%20Response%20Promptbook.md)**
- **[Password Spray Investigation Promptbook](Azure%20AI%20Search%20Module/Promptbook/Password%20Spray%20Investigation%20Promptbook.md)**
- **[Token Theft Investigation Promptbook](Azure%20AI%20Search%20Module/Promptbook/Token%20Theft%20Investigation%20Promptbook.md)**
- **[App Consent Grant Investigation Promptbook](Azure%20AI%20Search%20Module/Promptbook/App%20Consent%20Grant%20Investigation%20Promptbook.md)**
- **[Compromised Application Investigation Promptbook](Azure%20AI%20Search%20Module/Promptbook/Compromised%20Application%20Investigation%20Promptbook.md)**
- **[Identity Attack Investigation Promptbook](Azure%20AI%20Search%20Module/Promptbook/Identity%20Attack%20Investigation%20Promptbook.md)**
- **[Application Threat Investigation Promptbook](Azure%20AI%20Search%20Module/Promptbook/Application%20Threat%20Investigation%20Promptbook.md)**

### Custom OpenAI Plugins Module

- **[CVE Lookup Plugin — Installation Guide](Custom%20OpenAI%20Plugins%20Module/CVE%20Lookup%20Plugin/CVE%20Lookup%20Plugin%20Installation%20Guide.md)**
- **[CVE Lookup Sample Prompts](Custom%20OpenAI%20Plugins%20Module/CVE%20Lookup%20Plugin/CVE%20Lookup%20Sample%20Prompts.md)**
- **[CVE Vulnerability Triage and Patch Priority Assessment Promptbook](Custom%20OpenAI%20Plugins%20Module/Promptbook/CVE%20Vulnerability%20Triage%20and%20Patch%20Priority%20Assessment%20Promptbook.md)**
- **[Internal Security API Template](Custom%20OpenAI%20Plugins%20Module/Internal%20Security%20API%20Template/README.md)**
