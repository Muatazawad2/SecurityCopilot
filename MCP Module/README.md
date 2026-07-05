# MCP Module

**Developer**: Dr Muataz Awad

This module contains Model Context Protocol (MCP) servers for Microsoft Security Copilot. MCP servers extend Security Copilot with tools that run actual code — enabling capabilities that are impossible with OpenAI plugins or native YAML plugins.

## Why MCP?

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
| [SOC IOC Enricher](SOC%20IOC%20Enricher/) | Multi-source IOC enrichment — auto-detects IP, hash, or domain and queries multiple threat intelligence sources in a single call | `enrich_ioc`, `enrich_ip`, `enrich_hash`, `enrich_domain` |

<!-- Repository maintenance marker -->
