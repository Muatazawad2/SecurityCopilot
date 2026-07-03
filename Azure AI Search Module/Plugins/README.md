# Azure AI Search Plugins

**Developer**: Dr Muataz Awad

## Overview

Azure AI Search is a **built-in Microsoft plugin** for Security Copilot — no custom YAML upload is required. The plugin is available natively in every Security Copilot workspace and must be configured with your Azure AI Search instance details before use.

## Available Guides

| Guide | Description |
|---|---|
| **[Azure AI Search Complete Setup Guide](Azure%20AI%20Search%20Complete%20Setup%20Guide.md)** | **⭐ Start here — full end-to-end setup: Azure AI Search service, Azure OpenAI, Storage, index build, and Security Copilot connection. Includes all screenshots from a real deployment.** |
| [Azure AI Search Plugin Setup Guide](Azure%20AI%20Search%20Plugin%20Setup%20Guide.md) | Quick reference for the Copilot plugin connection — for users who already have an Azure AI Search index and only need the field requirements, plugin configuration, and troubleshooting guide. |

## How It Works

The plugin performs **hybrid search** — combining semantic vector search (using `text-embedding-ada-002` embeddings) with traditional keyword search — against your configured Azure AI Search index. This makes it highly effective for searching large volumes of unstructured security content like policy documents, runbooks, and investigation guides.

<!-- Repository maintenance marker -->
