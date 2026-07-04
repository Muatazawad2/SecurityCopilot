# CVE Lookup Plugin — Installation Guide

**Developer**: Dr Muataz Awad

This guide walks you through configuring the CVE Lookup OpenAI plugin in Microsoft Security Copilot. Once installed, analysts can look up any CVE directly from Copilot during an investigation — retrieving CVSS scores, severity ratings, affected products, and descriptions from CIRCL CVE Search.

---

## What This Plugin Does

Connects Security Copilot to the **CIRCL CVE Search API** (cve.circl.lu). CIRCL (Computer Incident Response Center Luxembourg) mirrors CVE records from MITRE and NVD, providing a free, unauthenticated REST API with no Cloudflare or bot detection restrictions.

When an analyst mentions a CVE identifier, Copilot invokes this plugin to retrieve:

- CVE description
- CVSS v3.1 base score and severity (CRITICAL / HIGH / MEDIUM / LOW)
- Attack vector, complexity, privileges required, and user interaction required
- Published date and current status
- Reference links (vendor advisories, patch notices, PoC)
- Affected vendor and product names

**No backend to deploy, no API key required** — the plugin calls the public CIRCL API directly.

> **Important**: This plugin supports **CVE ID lookup only** (e.g. `CVE-2024-21413`). It does not support keyword search or product-based CVE discovery. Use [nvd.nist.gov/vuln/search](https://nvd.nist.gov/vuln/search) to find CVE IDs, then look them up in Security Copilot.

---

## Prerequisites

- Access to **Microsoft Security Copilot** with permission to manage plugins.
- The repository must be public so Security Copilot can fetch the `openapi.yaml` by URL.

---

## Step 1 — Add the Plugin to Security Copilot

1. Open **Microsoft Security Copilot**.
2. Click the **Sources** icon in the prompt bar.
3. Under **Custom**, click **Add a plugin**.
4. Set **Who can use this plugin**:
   - **Just me** — plugin applies to your account only
   - **Everyone** — plugin applies to all users in the workspace (requires admin)
5. Under **Select an upload format**, select **OpenAI plugin**.
6. In the **Add link to OpenAI plugin** field, paste the manifest URL.

   > **GitHub CDN Caching Note**: GitHub's raw CDN caches files for several minutes after a push.
   > If you see a "Plugin not added" error after pasting the `main` branch URL, use a commit-hash URL instead to bypass the cache.

   **Option A — Standard URL** (use first, works once CDN propagates):
   ```
   https://raw.githubusercontent.com/Muatazawad2/SecurityCopilot/main/Custom%20OpenAI%20Plugins%20Module/CVE%20Lookup%20Plugin/manifest.json
   ```

   **Option B — Commit hash URL** (bypasses CDN cache, use if Option A fails):
   ```
   https://raw.githubusercontent.com/Muatazawad2/SecurityCopilot/f5eb5d80d066d23a2ceb7c03572d4447502d65bf/Custom%20OpenAI%20Plugins%20Module/CVE%20Lookup%20Plugin/manifest.json
   ```
   To get the latest commit hash, run `git rev-parse HEAD` in the repository.

7. Click **Add**.

---

## Step 2 — Verify the Plugin is Active

1. In the Sources panel, find **CVE Lookup** under Custom plugins.
2. Confirm it shows as **Enabled**.
3. Run a test prompt (see below).

---

## Step 3 — Test the Plugin

Run these prompts in a new Copilot session to verify the plugin is working:

```
Look up CVE-2021-44228 and tell me the CVSS score and attack vector.
```

```
What is the severity and affected product for CVE-2024-21413?
```

A successful response returns the CVE description, CVSS v3.1 base score, severity, attack vector, and affected product — sourced from CIRCL CVE Search.

---

## Rate Limits

CIRCL CVE Search allows **20 requests per minute** per IP address. This is sufficient for individual analyst usage. If rate limited, Security Copilot will return a "couldn't complete your request" error — wait 60 seconds and retry.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Plugin not invoked | Prompt does not mention a CVE ID | Be explicit: "Look up CVE-2024-21413..." |
| "Couldn't complete your request" | CIRCL rate limit hit (20/min) | Wait 60 seconds and retry |
| No results / empty response | CVE ID format incorrect or CVE not in CIRCL database | Ensure format is `CVE-YYYY-NNNNN` — verify the CVE exists at [cve.circl.lu](https://cve.circl.lu) |
| "Plugin not added" on registration | GitHub CDN serving cached old manifest | Use the commit-hash URL (Option B above) |
| CVSS score missing | Some newer CVEs have not yet received NVD scoring | Check back after a few days when NVD publishes the CVSS analysis |

---

## Reference

| Resource | Link |
|---|---|
| CIRCL CVE Search | [https://cve.circl.lu](https://cve.circl.lu) |
| CIRCL API documentation | [https://cve.circl.lu/api/](https://cve.circl.lu/api/) |
| CVE ID search (NIST) | [https://nvd.nist.gov/vuln/search](https://nvd.nist.gov/vuln/search) |
| CVE ID search (MITRE) | [https://cve.mitre.org/cgi-bin/cvekey.cgi](https://cve.mitre.org/cgi-bin/cvekey.cgi) |

<!-- Repository maintenance marker -->
