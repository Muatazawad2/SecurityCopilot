# MCP Module

**Developer**: Dr Muataz Awad

This module contains Model Context Protocol (MCP) servers for Microsoft Security Copilot. MCP servers extend Security Copilot with tools that run actual code — enabling capabilities that are impossible with OpenAI plugins or native YAML plugins.

> **📌 Note on Implementation Approach**
> The servers in this module use **TypeScript + Node.js deployed on Azure Container Apps** as one implementation approach. This is not a requirement — MCP supports multiple languages and hosting options. You can build MCP servers in Python, C#, Go, or any language with an MCP SDK. You can host them locally, on any cloud provider, or as serverless functions. The approach here was chosen for its native MCP SDK support, zero-cost idle scaling, and no local Docker requirement — but the MCP protocol itself is platform and language agnostic.

## Why MCP?

![Why MCP Changes Everything](Images/why-mcp.png)

| Capability | OpenAI Plugin | MCP Server |
|---|---|---|
| Call a single REST API | ✅ | ✅ |
| Call multiple APIs and correlate results | ❌ | ✅ |
| Run code and logic server-side | ❌ | ✅ |
| Auto-detect IOC type and route to right API | ❌ | ✅ |
| Return one aggregated verdict from multiple sources | ❌ | ✅ |
| Work with Claude, GitHub Copilot, VS Code | ❌ | ✅ |

## Available MCP Servers

| Server | Description | Tools |
|---|---|---|
| [SOC IOC Enricher](SOC%20IOC%20Enricher/) | Multi-source IOC enrichment — auto-detects IP, hash, or domain and queries multiple threat intelligence sources in a single call | `enrich_ioc`, `enrich_batch`, `enrich_ip`, `enrich_hash`, `enrich_domain`, `compute_hash` |

---

## Getting Started — Infrastructure Setup

![Azure Infrastructure Setup](Images/infrastructure.png)

![Why Each Azure Component Exists](Images/why-each-component.png)

Before deploying any MCP server, run the one-time infrastructure setup to create the shared Azure resources all servers depend on:

```powershell
cd Infrastructure
.\setup.ps1 -SubscriptionId "your-azure-subscription-id" `
            -AcrName "youruniquename"
```

This creates two resources (once only — idempotent if re-run):

| Resource | Purpose |
|---|---|
| **Azure Container Registry (ACR)** | Private Docker image registry — stores the built container images for all MCP servers. The ACR name must be globally unique across all Azure customers (like a domain name). |
| **Container Apps Environment** | Shared runtime where all MCP servers run as containers. Multiple servers share this environment — you only pay for what they use. Includes Log Analytics for monitoring. |

After setup completes, deploy individual servers using their own `deploy.ps1`:

```powershell
cd "../SOC IOC Enricher"
.\deploy.ps1 -SubscriptionId "your-sub-id" -AcrName "youruniquename"
```

**Relationship between the two scripts:**

```
Infrastructure/setup.ps1        ← run ONCE (creates ACR + Container Apps environment)
        ↓
SOC IOC Enricher/deploy.ps1    ← run per server, per update (builds image, creates Container App)
Future MCP Server/deploy.ps1
        etc.
```

<!-- Repository maintenance marker -->
