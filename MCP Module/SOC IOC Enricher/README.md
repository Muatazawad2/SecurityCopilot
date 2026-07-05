# SOC IOC Enricher — MCP Server

**Developer**: Dr Muataz Awad

A Model Context Protocol (MCP) server that auto-detects the type of an IOC (IP address, file hash, or domain) and queries multiple threat intelligence sources simultaneously — returning a single correlated verdict and recommended action.

## Why This Cannot Be Done Without MCP

| Approach | What happens |
|---|---|
| **Without MCP** | Analyst runs 3–4 separate prompts, one per API. Manually correlates results. |
| **With this MCP server** | ONE prompt → server queries all relevant APIs → ONE correlated verdict returned |

The MCP server runs real code server-side: it detects the IOC type, selects the appropriate APIs, calls them in parallel, weights the results, and returns a structured response — all transparent to the analyst.

---

## Tools Exposed

| Tool | Input | APIs called | Use when |
|---|---|---|---|
| `enrich_ioc` | Any IOC (IP, hash, or domain) | Auto-selects based on type | **Primary tool** — use this always |
| `enrich_ip` | IPv4 address | IPinfo.io + AbuseIPDB (optional) | Explicit IP lookup |
| `enrich_hash` | MD5 / SHA1 / SHA256 | MalwareBazaar | Explicit hash lookup |
| `enrich_domain` | Domain name | Google DNS + URLScan.io | Explicit domain lookup |

---

## APIs Used

| API | Data provided | Key required |
|---|---|---|
| **IPinfo.io** | Geolocation, ASN, organization, hostname | No |
| **AbuseIPDB** | Abuse confidence score, total reports, ISP | Optional — free key at [abuseipdb.com](https://www.abuseipdb.com/register) |
| **MalwareBazaar** (abuse.ch) | Malware name, family, file type, first/last seen | No |
| **Google Public DNS** | A records, CNAME, NXDOMAIN status | No |
| **URLScan.io** | Scan history, malicious verdicts, infrastructure | No |

---

## Prerequisites

- **Node.js 18 or higher** — check with `node --version`
- **npm** — check with `npm --version`

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

## Connecting to Microsoft Security Copilot

Security Copilot connects to MCP servers through its extensibility framework. To register this server:

1. Open **Microsoft Security Copilot**.
2. Navigate to **Settings** → **Plugins** → **Add plugin**.
3. Select **MCP** as the plugin type.
4. Provide the path to the server:
   ```
   node "C:\path\to\MCP Module\SOC IOC Enricher\dist\index.js"
   ```
5. Save and enable the plugin.
6. The four tools (`enrich_ioc`, `enrich_ip`, `enrich_hash`, `enrich_domain`) become available as skills.

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

| Symptom | Cause | Fix |
|---|---|---|
| `Cannot find module 'dist/index.js'` | Running `node` from wrong directory | Run from inside `SOC IOC Enricher/` |
| No AbuseIPDB score | API key not set | Set `ABUSEIPDB_API_KEY` environment variable |
| `UNKNOWN` verdict for IP | No AbuseIPDB key | Add the free key for abuse scoring |
| MalwareBazaar returns "not found" | Hash is unknown or clean | Check VirusTotal for broader coverage |

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
