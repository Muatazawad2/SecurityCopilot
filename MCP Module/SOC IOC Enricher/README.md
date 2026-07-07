# SOC IOC Enricher — MCP Server

**Developer**: Dr Muataz Awad

A Model Context Protocol (MCP) server that auto-detects the type of an IOC (IP address, file hash, domain, or URL), accepts defanged input and comma-separated batch lists, queries up to 9 threat intelligence sources simultaneously, and returns a structured intelligence report with threat level, context, key findings per source, and a numbered SOC action plan.

## Architecture

![Architecture](../Images/architecture.png)

## How It Works

![How It Works](../Images/how-it-works.png)

## Why This Cannot Be Done Without MCP

| Approach | What happens |
|---|---|
| **Without MCP** | Analyst runs 5–8 separate prompts across different tools. Manually correlates results. |
| **With this MCP server** | ONE prompt → server queries all relevant APIs in parallel → ONE structured report with threat level + per-source findings + recommended actions |

The server runs real code: it detects the IOC type, refangs defanged indicators, selects the appropriate APIs, calls them in parallel, weighs the results, and returns a professional-grade intelligence report.

---

## Tools Exposed

| Tool | Input | Use when |
|---|---|---|
| `enrich_ioc` | Any IOC — or a comma-separated list | **Primary tool** — use this always. Auto-detects type and routes to batch if multiple IOCs detected |
| `enrich_batch` | Array of IOCs | Explicit batch enrichment of up to 20 IOCs |
| `enrich_ip` | IPv4 address | Explicit IP lookup |
| `enrich_hash` | MD5 / SHA1 / SHA256 | Explicit hash lookup |
| `enrich_domain` | Domain name | Explicit domain lookup |
| `compute_hash` | Text or base64 file content | Compute MD5/SHA1/SHA256 from raw content then enrich |

---

## Intelligence Sources

| Source | IOC types | Key required | Data provided |
|---|---|---|---|
| **IPinfo.io** | IP | No | Geolocation, ASN, organization, hostname |
| **AbuseIPDB** | IP | Free — [abuseipdb.com](https://www.abuseipdb.com/register) | Abuse confidence score, total reports, ISP, Tor flag |
| **VirusTotal** | IP, Hash, Domain, URL | Free — [virustotal.com](https://www.virustotal.com/gui/sign-in) | Engine count, malicious/suspicious/clean verdict |
| **AlienVault OTX** | IP, Hash, Domain, URL | Free — [otx.alienvault.com](https://otx.alienvault.com/api) | Community pulse count, threat tags |
| **MalwareBazaar** | Hash | No | Malware name, family, file type, first/last seen |
| **Google Public DNS** | Domain | No | A records, CNAME, NXDOMAIN status |
| **URLScan.io** | Domain | No | Scan history, malicious verdicts, infrastructure |
| **URLhaus** | Domain, URL | No | Malware distribution URLs |
| **RDAP/WHOIS** | Domain | No | Registration date, domain age, registrar |

---

## Output Format

Each enrichment returns a structured report:

```
THREAT LEVEL: CRITICAL — MALICIOUS (100% confidence)

IOC: 185[.]220[.]101[.]45 (IP Address)
Context: Tor exit node — used to anonymize attacker traffic...

Intelligence Findings:
  • IPinfo.io: Berlin, DE · AS60729 · hostname: tor-exit-45.for-privacy.net
  • AbuseIPDB: 100% abuse confidence · 137 reports · Tor exit node confirmed
  • VirusTotal: 15 of 91 engines flagged
  • AlienVault OTX: 50 threat intelligence pulses

Recommended Actions:
  1. Block 185.220.101.45 at perimeter firewall and proxy immediately
  2. Search SIEM/EDR logs for all historical connections (last 30/60/90 days)
  3. Escalate any endpoints that communicated with this IP to Tier 2
  4. Document the indicator in your threat intelligence platform
  5. Consider filing an incident report if internal hosts were involved
```

---

## Prerequisites

- **Node.js 18 or higher** — check with `node --version`
- **npm** — check with `npm --version`

> **What is TypeScript?**
> This server is written in TypeScript (`.ts` files), which is JavaScript with type safety added. You don't need to know TypeScript to use or deploy this server — the build step (`npm run build`) automatically compiles it to plain JavaScript that Node.js runs. Think of it as a safety layer that catches bugs before deployment rather than at 2am in production.

---

## Installation

```bash
# 1. Navigate to this folder
cd "MCP Module/SOC IOC Enricher"

# 2. Install dependencies
npm install

# 3. Build
npm run build
```

---

## Optional: AbuseIPDB API Key

For IP abuse scoring, register for a free API key at [abuseipdb.com](https://www.abuseipdb.com/register) and set it as an environment variable before starting the server:

```powershell
# Windows PowerShell
$env:ABUSEIPDB_API_KEY = "your-free-api-key-here"
```

Without the key, IP enrichment still returns geolocation and ASN from IPinfo.io — the abuse confidence score is skipped.

---

## Running the Server

```bash
node dist/index.js
```

The server starts on `stdio` transport and outputs:
```
SOC IOC Enricher MCP server running on stdio
```

---

## Deploying to Azure (Recommended for Production)

Running the MCP server locally means it is only available when your machine is on. Deploying to **Azure Container Apps** makes it always-on, publicly accessible over HTTPS, and available to any Security Copilot tenant.

The deployment uses **ACR Tasks** (`az acr build`) to build the Docker image entirely in the cloud — **no local Docker installation required**.

---

### Azure Deployment Prerequisites

| Prerequisite | Check | Install |
|---|---|---|
| **Azure CLI** | `az version` | `winget install Microsoft.AzureCLI` |
| **WSL 2** (Windows only) | `wsl --status` | `wsl --install --no-launch` |
| **Azure subscription** | Owner or Contributor role on your resource group | — |

> **Note on WSL 2:** Docker Desktop requires WSL 2 on Windows. Even if you are not using Docker locally, WSL must be installed for Docker Desktop to start. Install it with `wsl --install --no-launch` and restart Docker Desktop.

---

### Step 1 — One-Time Infrastructure Setup

This step creates the shared Azure resources used by all MCP servers in this repository. Run it **once only**. If the resources already exist the script skips creation safely.

```powershell
cd "MCP Module\Infrastructure"
.\setup.ps1
```

This creates:

| Resource | Name | Purpose |
|---|---|---|
| **Azure Container Registry** | `<your-acr-name>` | Stores Docker images for all MCP servers |
| **Container Apps Environment** | `soc-mcp-environment` | Shared runtime (with Log Analytics) for all MCP servers |

Expected output when complete:
```
=== Infrastructure ready! ===
Container Registry : <your-acr-name>.azurecr.io
Container Apps Env : soc-mcp-environment
```

---

### Step 2 — Deploy the SOC IOC Enricher

```powershell
cd "MCP Module\SOC IOC Enricher"
.\deploy.ps1
```

To include AbuseIPDB scoring (recommended), pass your free API key:
```powershell
.\deploy.ps1 -AbuseIpdbKey "your-free-key-here"
```

**What the script does:**

| Step | Action |
|---|---|
| `[1/4]` | Uploads source code to Azure and builds the Docker image using `az acr build` — no local Docker needed |
| `[3/4]` | Creates or updates the Container App with 0–5 replicas on the Consumption plan |
| `[4/4]` | Retrieves and prints the live HTTPS endpoint |

**Expected final output:**
```
=== Deployment complete! ===
  MCP SSE endpoint: https://<your-app>.<your-env>.azurecontainerapps.io/sse
  Health check:     https://<your-app>.<your-env>.azurecontainerapps.io/health
```

---

### Re-Deploying After Code Changes

After editing the source code, re-run the deploy script from inside the `SOC IOC Enricher` folder. The script automatically updates the existing Container App with the new image:

```powershell
cd "MCP Module\SOC IOC Enricher"
.\deploy.ps1
```

> **Re-authentication:** If `az acr build` fails with an `AADSTS50076` error, run `az login` again to refresh the session.

---

### Azure Resource Summary

| Resource | Value |
|---|---|
| Subscription | Your Azure subscription |
| Resource Group | `SecurityCopilot` (or your own) |
| Container Registry | `<your-acr-name>.azurecr.io` |
| Container Apps Environment | `soc-mcp-environment` |
| Container App | `soc-ioc-enricher` |
| SSE Endpoint | `https://<your-app>.<your-env>.azurecontainerapps.io/sse` |
| Health Endpoint | `https://<your-app>.<your-env>.azurecontainerapps.io/health` |

---

## Connecting to Microsoft Security Copilot

Security Copilot connects to MCP servers through its extensibility framework. To register this server:

**Option A — Azure deployment (recommended):**

1. Open **Microsoft Security Copilot**.
2. Navigate to **Settings** → **Plugins** → **Add plugin**.
3. Select **MCP** as the plugin type.
4. Enter the SSE endpoint URL:
   ```
   https://<your-app>.<your-env>.azurecontainerapps.io/sse
   ```
5. Save and enable the plugin.
6. The four tools (`enrich_ioc`, `enrich_ip`, `enrich_hash`, `enrich_domain`) become available as skills.

**Option B — Local server:**

1. Build and start the server locally (`npm run build` then `node dist/index.js`).
2. Follow the same plugin registration steps above, using your local SSE URL instead.

---

## Connecting to Other MCP Clients

This server works with any MCP-compatible client. Example configuration for Claude Desktop (`claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "soc-ioc-enricher": {
      "command": "node",
      "args": ["C:\\path\\to\\MCP Module\\SOC IOC Enricher\\dist\\index.js"],
      "env": {
        "ABUSEIPDB_API_KEY": "your-optional-key"
      }
    }
  }
}
```

---

## Sample Response

**Prompt:** `Enrich this IOC: google.com`

```json
{
  "ioc": "google.com",
  "type": "Domain",
  "sources_queried": ["Google Public DNS", "URLScan.io"],
  "dns_resolution": {
    "resolves": true,
    "status": "RESOLVES",
    "a_records": ["142.251.210.206"]
  },
  "urlscan_intelligence": {
    "total_scans": 10000,
    "malicious_verdicts": 0,
    "last_scan_date": "2026-07-05T01:21:46.422Z"
  },
  "verdict": "LIKELY CLEAN",
  "confidence_pct": 70,
  "recommended_action": "No immediate action required based on available data."
}
```

---

## Troubleshooting

### Local

| Symptom | Cause | Fix |
|---|---|---|
| `Cannot find module 'dist/index.js'` | Running `node` from wrong directory | Run from inside `SOC IOC Enricher/` |
| No AbuseIPDB score | API key not set | Set `ABUSEIPDB_API_KEY` environment variable |
| `UNKNOWN` verdict for IP | No AbuseIPDB key | Add the free key for abuse scoring |
| MalwareBazaar returns "not found" | Hash is unknown or clean | Check VirusTotal for broader coverage |

### Azure Deployment

| Symptom | Cause | Fix |
|---|---|---|
| `AADSTS50076` error during `az acr build` | MFA session expired | Repeat Step 1 (both `az login` commands) |
| `Docker Desktop is unable to start` | WSL 2 not installed | Run `wsl --install --no-launch` then restart Docker Desktop |
| ACR not found after `setup.ps1` | MFA challenge silently blocked creation | Run `az acr create` manually after completing the claims-challenge login |
| `argument --registry-username: expected one argument` | ACR credentials empty (ACR doesn't exist) | Ensure ACR was created successfully before running `deploy.ps1` |
| Health check returns 502/503 | Container App still starting (cold start) | Wait 30–60 seconds and retry — min replicas is 0 (scale to zero) |
| `The resource could not be found` on Container App | First deploy failed mid-way | Re-run `deploy.ps1` — it detects and creates/updates as needed |

---

## Reference

| Resource | Link |
|---|---|
| MCP Protocol specification | [modelcontextprotocol.io](https://modelcontextprotocol.io) |
| MCP TypeScript SDK | [github.com/modelcontextprotocol/typescript-sdk](https://github.com/modelcontextprotocol/typescript-sdk) |
| AbuseIPDB free registration | [abuseipdb.com/register](https://www.abuseipdb.com/register) |
| MalwareBazaar API | [bazaar.abuse.ch/api/](https://bazaar.abuse.ch/api/) |
| URLScan.io API | [urlscan.io/docs/api/](https://urlscan.io/docs/api/) |

<!-- Repository maintenance marker -->
