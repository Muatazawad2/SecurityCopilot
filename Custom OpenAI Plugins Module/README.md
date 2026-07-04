# Custom OpenAI Plugins Module

**Developer**: Dr Muataz Awad

This module contains OpenAI-format plugins for Microsoft Security Copilot. These plugins use the OpenAI plugin standard (`manifest.json` + OpenAPI specification) rather than the native Security Copilot YAML format — allowing Security Copilot to call any REST API directly during an investigation.

## What Is an OpenAI Plugin for Security Copilot?

When you upload an OpenAI plugin to Security Copilot, the orchestrator adds it to the list of available capabilities. The LLM determines when to invoke it based on the prompt, calls the REST API, receives the response, and generates a natural language answer grounded in the returned data.

Each plugin consists of:
- **`manifest.json`** — Describes the plugin to the LLM: what it does, when to use it, and where the API spec lives
- **`openapi.yaml`** — Defines the REST API endpoints, parameters, and response schemas
- **The REST API** — The actual backend (public service or internal tool) that performs the work

## Available Plugins

| Plugin | Description | API Source |
|---|---|---|
| [CVE Lookup Plugin](CVE%20Lookup%20Plugin/) | Look up CVE vulnerability details from NIST NVD — severity, CVSS score, affected products, description | Public — no API key required |
| [Internal Security API Template](Internal%20Security%20API%20Template/) | Template for wrapping an internal security tool (SIEM, CMDB, incident database) as an OpenAI plugin | Template — adapt for your own API |

## Available Promptbooks

| Promptbook | Plugin Required | Description |
|---|---|---|
| [CVE Vulnerability Triage and Patch Priority Assessment](Promptbook/CVE%20Vulnerability%20Triage%20and%20Patch%20Priority%20Assessment%20Promptbook.md) | CVE Lookup Plugin | 7-step workflow: CVE lookup → exploitability assessment → affected asset identification → patch availability → environmental exposure → threat intelligence → structured patch priority recommendation |

## How to Upload a Plugin to Security Copilot

1. In Security Copilot, click the **Sources** icon in the prompt bar.
2. Select **Custom** → click **Add a plugin**.
3. Set **Who can use this plugin** → **Just me** or **Everyone**.
4. Select **OpenAI plugin** as the upload format.
5. In the **Add link to OpenAI plugin** field, paste the raw GitHub URL of the `manifest.json`.
6. Click **Add** — Security Copilot fetches the manifest, retrieves the OpenAPI spec from the URL inside it, and registers the plugin.

## OpenAI Plugin vs Security Copilot Plugin

| Aspect | OpenAI Plugin | Security Copilot Plugin |
|---|---|---|
| **File format** | `manifest.json` + OpenAPI spec | YAML manifest |
| **Standard** | OpenAI / ChatGPT plugin standard | Microsoft native |
| **Skills supported** | REST API only | KQL, API, GPT, Logic App, MCP |
| **Best for** | Existing ChatGPT plugins, internal REST APIs | New Security Copilot-native tools |
| **Auth options** | None, API key, OAuth | None, API key, AAD |

<!-- Repository maintenance marker -->
