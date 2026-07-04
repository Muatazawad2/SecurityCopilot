# CVE Lookup Plugin — Installation Guide

**Developer**: Dr Muataz Awad

This guide walks you through uploading and configuring the CVE Lookup OpenAI plugin in Microsoft Security Copilot. Once installed, analysts can look up any CVE directly from Copilot during an investigation — retrieving severity scores, CVSS ratings, affected products, and descriptions from the NIST National Vulnerability Database (NVD).

---

## What This Plugin Does

Connects Security Copilot to the **NIST National Vulnerability Database (NVD) REST API v2**. When an analyst mentions a CVE identifier or asks about a vulnerability, Copilot invokes this plugin to retrieve:

- CVE description
- CVSS v3 base score and severity (CRITICAL / HIGH / MEDIUM / LOW)
- Attack vector, complexity, and impact details
- Published date and current status
- Reference links (vendor advisories, patch notices, PoC)
- Associated CWE weaknesses

**No backend to deploy** — the plugin calls the public NVD API directly.

---

## Prerequisites

- Access to **Microsoft Security Copilot** with permission to manage plugins.
- The plugin files from this folder:
  - [`manifest.json`](manifest.json)
  - [`openapi.yaml`](openapi.yaml) — must be publicly accessible via the URL in `manifest.json`

> **Note**: The `openapi.yaml` is referenced by URL in `manifest.json`. The URL points to the raw GitHub file in this repository. If the repository is public, no additional hosting is required.

---

## Step 1 — Verify the OpenAPI Spec URL

Before uploading, confirm the `openapi.yaml` is publicly accessible. Open this URL in a browser — it should display the YAML content:

```
https://raw.githubusercontent.com/Muatazawad2/SecurityCopilot/main/Custom%20OpenAI%20Plugins%20Module/CVE%20Lookup%20Plugin/openapi.yaml
```

If the repository is private, host the `openapi.yaml` on any publicly accessible URL and update the `api.url` field in `manifest.json` accordingly.

---

## Step 2 — Add the Plugin to Security Copilot

1. Open **Microsoft Security Copilot**.
2. Click the **Sources** icon in the prompt bar.
3. Under **Custom**, click **Add a plugin**.
4. Set **Who can use this plugin**:
   - **Just me** — plugin applies to your account only
   - **Everyone** — plugin applies to all users in the workspace (requires admin)
5. Under **Select an upload format**, select **OpenAI plugin**.
6. In the **Add link to OpenAI plugin** field, paste this URL:

   ```
   https://raw.githubusercontent.com/Muatazawad2/SecurityCopilot/main/Custom%20OpenAI%20Plugins%20Module/CVE%20Lookup%20Plugin/manifest.json
   ```

7. Click **Add**.

Security Copilot fetches the manifest from the URL, then automatically retrieves the OpenAPI spec from the URL inside the manifest, and registers the plugin.

---

## Step 3 — Verify the Plugin is Active

1. In the Sources panel, find **CVE Lookup** under Custom plugins.
2. Confirm it shows as **Enabled**.
3. Run a test prompt (see below).

---

## Step 4 — Test the Plugin

Run these prompts in a new Copilot session to verify the plugin is working:

```
Look up CVE-2024-21413 and tell me the severity and what products are affected.
```

```
What is the CVSS score and attack vector for CVE-2021-44228?
```

```
Search for critical CVEs related to Microsoft Exchange published in 2024.
```

A successful response will include the CVE description, CVSS base score, severity rating, and reference links sourced from the NVD.

---

## Optional — Add an NVD API Key for Higher Rate Limits

The NVD API allows **5 requests per 30 seconds** without an API key. For higher throughput (**50 requests per 30 seconds**), request a free API key at [https://nvd.nist.gov/developers/request-an-api-key](https://nvd.nist.gov/developers/request-an-api-key).

To add the API key to the plugin:

1. Update `manifest.json` to use `api_key` authentication:

```json
"auth": {
  "type": "user_http",
  "authorization_type": "bearer"
}
```

2. Add the `apiKey` header parameter to the `openapi.yaml` operation.
3. Re-upload the updated `manifest.json`.
4. When prompted, enter your NVD API key.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Plugin not invoked | Prompt doesn't mention a CVE or vulnerability keyword | Be explicit: "Look up CVE-..." or "Using CVE Lookup, find..." |
| 403 rate limit error | Too many requests in 30 seconds | Wait 30 seconds and retry, or add an NVD API key |
| No results returned | CVE ID format incorrect | Ensure format is `CVE-YYYY-NNNNN` (e.g. `CVE-2024-21413`) |
| Manifest upload fails with cached content error | GitHub CDN serving old version of manifest | Use the commit-hash URL instead of the `main` branch URL: `https://raw.githubusercontent.com/Muatazawad2/SecurityCopilot/{COMMIT_HASH}/Custom%20OpenAI%20Plugins%20Module/CVE%20Lookup%20Plugin/manifest.json` — get the full hash by running `git rev-parse HEAD` |
| Outdated data | NVD data has a processing delay | New CVEs may take 1–2 days to appear with full CVSS analysis |

---

## Reference

| Resource | Link |
|---|---|
| NIST NVD API documentation | [https://nvd.nist.gov/developers/vulnerabilities](https://nvd.nist.gov/developers/vulnerabilities) |
| Request NVD API key | [https://nvd.nist.gov/developers/request-an-api-key](https://nvd.nist.gov/developers/request-an-api-key) |
| CVE database search | [https://nvd.nist.gov/vuln/search](https://nvd.nist.gov/vuln/search) |

<!-- Repository maintenance marker -->
