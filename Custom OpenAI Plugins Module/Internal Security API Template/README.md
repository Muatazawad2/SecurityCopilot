# Internal Security API Template

**Developer**: Dr Muataz Awad

This template provides a ready-to-adapt OpenAI plugin for connecting an internal security operations platform to Microsoft Security Copilot. Use it as the starting point when your organization has an existing REST API (SIEM, CMDB, incident management system, asset database, or custom security tool) and you want Security Copilot to query it directly during investigations.

---

## What Is This Template?

This template provides the two files needed to create an OpenAI plugin:

| File | Purpose |
|---|---|
| [`manifest.json`](manifest.json) | Describes the plugin to Security Copilot — what it does, when to invoke it, and where the API spec lives |
| [`openapi.yaml`](openapi.yaml) | Defines the REST API endpoints, parameters, and response schemas |

The template models a fictional "Contoso Security Operations" platform with 5 common security API endpoints. Adapt them to match your actual internal API.

---

## Endpoints Included in the Template

| Endpoint | Operation | Description |
|---|---|---|
| `GET /api/incidents` | `listIncidents` | List security incidents filtered by status, severity, or assignee |
| `GET /api/incidents/{id}` | `getIncidentById` | Get full details of a specific incident including timeline and notes |
| `GET /api/risky-users` | `listRiskyUsers` | List users flagged as risky with risk level and reason |
| `GET /api/assets` | `listAssets` | Query asset inventory by hostname, owner, or compliance status |
| `GET /api/alerts` | `listAlerts` | List active security alerts filtered by severity or affected entity |

---

## How to Adapt This Template for Your API

### Step 1 — Update the Server URL

In `openapi.yaml`, replace the server URL:
```yaml
servers:
  - url: https://YOUR-API-HOST
```
with your actual API base URL, e.g.:
```yaml
servers:
  - url: https://securityops.contoso.com
```

### Step 2 — Update Authentication

The template uses **Bearer token** authentication. Update `components.securitySchemes` if your API uses a different method:

| Auth method | Configuration |
|---|---|
| **Bearer token (JWT)** | Keep as-is — `type: http, scheme: bearer` |
| **API key in header** | Change to `type: apiKey, in: header, name: X-API-Key` |
| **API key in query** | Change to `type: apiKey, in: query, name: api_key` |
| **OAuth 2.0** | Change to `type: oauth2` with your flows |
| **No auth** | Remove the `security` section entirely |

Also update the `auth` section in `manifest.json` to match.

### Step 3 — Adapt Endpoints to Your API

For each endpoint:
1. Update the path to match your actual API route
2. Update the `operationId` to a descriptive, unique name
3. Update `description` — **this is what the LLM reads to decide when to call the endpoint. Be specific.**
4. Update parameter names and descriptions to match your API
5. Update the response schema to match your API's actual JSON structure

### Step 4 — Remove Unused Endpoints

Delete any endpoint blocks your API doesn't expose. The plugin only needs to describe endpoints that actually exist.

### Step 5 — Update manifest.json

```json
{
  "name_for_human": "YOUR TOOL NAME",
  "name_for_model": "your_tool_name_no_spaces",
  "description_for_human": "One sentence describing what the tool does for users",
  "description_for_model": "Detailed instructions for the LLM: WHEN to invoke this plugin, WHAT it returns, and WHICH prompts should trigger it. Be very specific.",
  "api": {
    "url": "https://YOUR-HOSTED-OPENAPI-URL/openapi.yaml"
  }
}
```

> The `description_for_model` is the most important field. It determines when Copilot decides to invoke your plugin. Be explicit: list the types of questions that should trigger it.

### Step 6 — Host the openapi.yaml Publicly

Security Copilot fetches the `openapi.yaml` at the URL specified in `manifest.json`. It must be publicly accessible. Options:
- Public GitHub repository (raw URL)
- Azure Blob Storage with public read access
- Azure Static Web Apps
- Any publicly accessible HTTPS endpoint

### Step 7 — Upload to Security Copilot

1. Open Security Copilot → Sources → Add a plugin
2. Select **OpenAI plugin**
3. Upload the adapted `manifest.json`
4. Security Copilot fetches the spec and registers the plugin

---

## Example: Adapting for a ServiceNow Security Incident API

To wrap ServiceNow's REST API:

**openapi.yaml server:**
```yaml
servers:
  - url: https://your-instance.service-now.com
```

**Replace `/api/incidents` with ServiceNow Table API:**
```yaml
/api/now/table/sn_si_incident:
  get:
    operationId: listServiceNowSecurityIncidents
    description: >
      Retrieve security incidents from ServiceNow. Invoke when the user asks about
      open tickets, security cases, incident status, or ServiceNow incident details.
```

**manifest.json description_for_model:**
```
Use this plugin to query ServiceNow for security incidents. Invoke when the user asks 
about open security tickets, ServiceNow case status, incident assignments, or 
resolution details. This plugin connects directly to our ServiceNow instance.
```

---

## Sample Prompts (After Adaptation)

Once adapted and uploaded, prompts like these will invoke your plugin:

```
Show me all open critical security incidents assigned to the SOC team.
```

```
Get the details for incident INC-2024-00847 including the timeline and investigation notes.
```

```
List all users currently flagged as high risk in our security platform.
```

```
Find the asset record for hostname DESKTOP-CORP-0042 and tell me who owns it.
```

```
Show me all new critical alerts from the last 24 hours that haven't been assigned yet.
```

<!-- Repository maintenance marker -->
