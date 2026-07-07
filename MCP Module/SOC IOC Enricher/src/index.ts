#!/usr/bin/env node
/**
 * SOC IOC Enricher — MCP Server
 * Developer: Dr Muataz Awad
 *
 * Multi-source IOC enrichment for Microsoft Security Copilot.
 * Auto-detects IOC type (IP / file hash / domain) and queries
 * multiple threat intelligence sources in a single tool call,
 * returning one correlated verdict.
 *
 * APIs used (all free, no key required by default):
 *   - IPinfo.io       → IP geolocation and ASN
 *   - AbuseIPDB       → IP abuse confidence score (optional: set ABUSEIPDB_API_KEY)
 *   - MalwareBazaar   → File hash malware lookup
 *   - Google DNS      → Domain resolution
 *   - URLScan.io      → Domain scan history and verdicts
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { SSEServerTransport } from "@modelcontextprotocol/sdk/server/sse.js";
import http from "node:http";
import { createHash } from "node:crypto";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

// ─── OpenAPI Spec — served at /openapi.yaml for Security Copilot plugin ─────

const OPENAPI_SPEC = `openapi: 3.0.1
info:
  title: SOC IOC Enricher
  description: >
    Multi-source IOC enrichment server. Auto-detects the type of an IOC
    (IPv4 address, file hash, or domain name) and queries multiple free
    threat intelligence sources simultaneously - IPinfo.io, AbuseIPDB,
    MalwareBazaar, Google Public DNS, and URLScan.io - returning a single
    correlated verdict, confidence score, and recommended SOC action.
  version: 1.0.0
  contact:
    name: Dr Muataz Awad

servers:
  - url: https://YOUR-APP.YOUR-ENV.eastus.azurecontainerapps.io
    description: Azure Container Apps deployment

paths:

  /enrich:
    get:
      operationId: enrichIoc
      summary: Auto-detect IOC type and enrich from multiple threat intelligence sources
      description: >
        The primary enrichment endpoint. Accepts any IOC - IPv4 address,
        MD5/SHA1/SHA256 file hash, or domain name - automatically detects
        the type, queries all relevant threat intelligence APIs in parallel,
        and returns a single correlated verdict with confidence score and
        recommended action. Use this endpoint first; only use the specific
        endpoints below if the user explicitly requests a particular IOC type.
      parameters:
        - name: ioc
          in: query
          required: true
          schema:
            type: string
          description: >
            The indicator of compromise to investigate. Examples:
            45.33.32.156 (IP), d41d8cd98f00b204e9800998ecf8427e (MD5 hash),
            malicious-domain.com (domain).
      responses:
        '200':
          description: Enrichment result with verdict and recommended action
          content:
            application/json:
              schema:
                \\$ref: '#/components/schemas/EnrichmentResult'
        '400':
          description: Missing or invalid ioc parameter

  /enrich/ip:
    get:
      operationId: enrichIp
      summary: Enrich an IP address using IPinfo.io and AbuseIPDB
      description: >
        Look up an IPv4 address for geolocation (country, city, region),
        ASN, and organization via IPinfo.io. If the ABUSEIPDB_API_KEY
        environment variable is set on the server, also returns abuse
        confidence score, total abuse reports, and ISP from AbuseIPDB.
        Returns a verdict of MALICIOUS (score >= 80), SUSPICIOUS (score 25-79),
        LIKELY CLEAN (score 0-24), or UNKNOWN (no AbuseIPDB key).
      parameters:
        - name: ip
          in: query
          required: true
          schema:
            type: string
          description: "IPv4 address to investigate. Example: 45.33.32.156"
      responses:
        '200':
          description: IP enrichment result
          content:
            application/json:
              schema:
                \\$ref: '#/components/schemas/EnrichmentResult'
        '400':
          description: Missing or invalid ip parameter

  /enrich/hash:
    get:
      operationId: enrichHash
      summary: Look up a file hash in MalwareBazaar
      description: >
        Query MalwareBazaar (abuse.ch) to determine if a file hash is
        associated with known malware. Accepts MD5 (32 hex chars),
        SHA1 (40 hex chars), or SHA256 (64 hex chars). Returns malware
        name, family tags, file type, first and last seen dates, and
        origin country if found. Returns NOT FOUND if the hash is not
        in the database - this does not confirm the file is clean.
      parameters:
        - name: hash
          in: query
          required: true
          schema:
            type: string
          description: >
            File hash to look up. Accepts MD5, SHA1, or SHA256 hex strings.
            Example: 44d88612fea8a8f36de82e1278abb02f (MD5 of EICAR test file).
      responses:
        '200':
          description: Hash enrichment result
          content:
            application/json:
              schema:
                \\$ref: '#/components/schemas/EnrichmentResult'
        '400':
          description: Missing or invalid hash parameter

  /enrich/domain:
    get:
      operationId: enrichDomain
      summary: Investigate a domain via Google DNS and URLScan.io
      description: >
        Check DNS resolution for a domain using Google Public DNS (returns
        A records, CNAME records, and NXDOMAIN status), and search
        URLScan.io for scan history and malicious verdicts. Returns a
        verdict of MALICIOUS if any URLScan.io verdicts are malicious,
        LIKELY CLEAN if scans exist but are clean, or UNKNOWN if no
        scan history is available.
      parameters:
        - name: domain
          in: query
          required: true
          schema:
            type: string
          description: >
            Domain name to investigate. Do not include http:// or paths.
            Example: malicious-domain.com
      responses:
        '200':
          description: Domain enrichment result
          content:
            application/json:
              schema:
                \\$ref: '#/components/schemas/EnrichmentResult'
        '400':
          description: Missing or invalid domain parameter

components:
  schemas:
    EnrichmentResult:
      type: object
      properties:
        ioc:
          type: string
          description: The IOC that was investigated
        type:
          type: string
          description: Detected IOC type (IP Address, File Hash, Domain)
        sources_queried:
          type: array
          items:
            type: string
          description: List of threat intelligence sources that were queried
        verdict:
          type: string
          description: >
            Final verdict: MALICIOUS, SUSPICIOUS, LIKELY CLEAN, UNKNOWN,
            NOT FOUND IN MALWARE DATABASE, or LOOKUP FAILED
        confidence_pct:
          type: integer
          description: Confidence percentage (0-100) for the verdict
        recommended_action:
          type: string
          description: Recommended SOC action based on the verdict
        geolocation:
          type: object
          description: IP geolocation data from IPinfo.io (IP enrichment only)
          properties:
            country:
              type: string
            region:
              type: string
            city:
              type: string
            organization:
              type: string
            asn:
              type: string
        abuse_intelligence:
          type: object
          description: Abuse data from AbuseIPDB (IP enrichment only, requires API key)
          properties:
            abuse_confidence_score:
              type: integer
            total_reports:
              type: integer
            isp:
              type: string
            is_tor:
              type: boolean
        malware_intelligence:
          type: object
          description: Malware data from MalwareBazaar (hash enrichment only)
          properties:
            malware_name:
              type: string
            tags:
              type: string
            file_type:
              type: string
            first_seen:
              type: string
            last_seen:
              type: string
        dns_resolution:
          type: object
          description: DNS data from Google Public DNS (domain enrichment only)
          properties:
            resolves:
              type: boolean
            status:
              type: string
            a_records:
              type: array
              items:
                type: string
        urlscan_intelligence:
          type: object
          description: Scan history from URLScan.io (domain enrichment only)
          properties:
            total_scans:
              type: integer
            malicious_verdicts:
              type: integer
            last_scan_date:
              type: string
`;

// ─── Security Copilot Native Plugin Descriptor — served at /plugin.yaml ─────

const PLUGIN_DESCRIPTOR = `Descriptor:
  Name: SOCIOCEnricher
  DisplayName: SOC IOC Enricher
  Description: >
    Multi-source IOC enrichment — auto-detects IP address, file hash (MD5/SHA1/SHA256),
    or domain name and queries IPinfo.io, AbuseIPDB, MalwareBazaar, Google DNS,
    and URLScan.io simultaneously. Returns a single correlated verdict with confidence
    score and recommended SOC action.
  DescriptionForModel: >
    Use this plugin to enrich any indicator of compromise (IOC). Call EnrichIoc when the
    user provides any IOC and needs to determine if it is malicious — it auto-detects the
    type (IP, hash, or domain) and returns a verdict with confidence score and recommended
    action. Call EnrichIp for explicit IP lookups (geolocation, ASN, abuse score), EnrichHash
    for file hash lookups against MalwareBazaar, and EnrichDomain for domain lookups via
    Google DNS and URLScan.io. Always prefer EnrichIoc unless the user explicitly requests
    a specific IOC type.
  SupportedAuthTypes:
    - None

SkillGroups:
  - Format: API
    Settings:
      OpenApiSpecUrl: https://YOUR-APP.YOUR-ENV.eastus.azurecontainerapps.io/openapi.yaml
      EndpointUrl: https://YOUR-APP.YOUR-ENV.eastus.azurecontainerapps.io
`;

// ─── Response Cache (5-minute TTL) ───────────────────────────────────────────────────────

const _cache = new Map<string, { data: object; expires: number }>();
function getCached(key: string): object | null {
  const e = _cache.get(key);
  if (!e) return null;
  if (Date.now() > e.expires) { _cache.delete(key); return null; }
  return e.data;
}
function setCached(key: string, data: object): void {
  _cache.set(key, { data, expires: Date.now() + 5 * 60 * 1000 });
}

// ─── Defang / Refang ────────────────────────────────────────────────────────────────

function refangIoc(ioc: string): string {
  return ioc
    .replace(/hxxps/gi, "https").replace(/hxxp/gi, "http")
    .replace(/\[dot\]/gi, ".").replace(/\[\.\]/g, ".").replace(/\(\.\.\)/g, ".")
    .trim();
}

function defangIoc(ioc: string): string {
  if (/^https?:\/\//i.test(ioc))
    return ioc.replace(/^https/i, "hxxps").replace(/^http(?!s)/i, "hxxp").replace(/\./g, "[.]");
  return ioc.replace(/\./g, "[.]");
}

// ─── IOC Type Detection ────────────────────────────────────────────────────────────────

type IocType = "ip" | "hash" | "domain" | "url" | "unknown";

function detectIocType(ioc: string): IocType {
  const clean = ioc.trim();
  if (/^https?:\/\//i.test(clean)) return "url";
  if (/^(\d{1,3}\.){3}\d{1,3}$/.test(clean)) return "ip";
  if (/^[a-fA-F0-9]{32}$/.test(clean)) return "hash"; // MD5
  if (/^[a-fA-F0-9]{40}$/.test(clean)) return "hash"; // SHA1
  if (/^[a-fA-F0-9]{64}$/.test(clean)) return "hash"; // SHA256
  if (/^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$/.test(clean)) return "domain";
  return "unknown";
}

function extractDomainFromUrl(url: string): string {
  try { return new URL(url).hostname; } catch { return url; }
}

function hashType(hash: string): string {
  if (hash.length === 32) return "MD5";
  if (hash.length === 40) return "SHA1";
  if (hash.length === 64) return "SHA256";
  return "Unknown";
}

// ─── External API Helpers ─────────────────────────────────────────────────────

async function queryVirusTotal(ioc: string, type: IocType): Promise<Record<string, unknown> | null> {
  const key = process.env.VIRUSTOTAL_API_KEY;
  if (!key) return null;
  try {
    let endpoint: string;
    if (type === "ip") endpoint = `https://www.virustotal.com/api/v3/ip_addresses/${encodeURIComponent(ioc)}`;
    else if (type === "hash") endpoint = `https://www.virustotal.com/api/v3/files/${ioc}`;
    else if (type === "domain") endpoint = `https://www.virustotal.com/api/v3/domains/${encodeURIComponent(ioc)}`;
    else if (type === "url") endpoint = `https://www.virustotal.com/api/v3/urls/${Buffer.from(ioc).toString("base64url")}`;
    else return null;
    const res = await fetch(endpoint, { headers: { "x-apikey": key } });
    if (!res.ok) return null;
    const data = (await res.json()) as Record<string, unknown>;
    const stats = ((data.data as Record<string, unknown>)?.attributes as Record<string, unknown>)?.last_analysis_stats as Record<string, number> | undefined;
    if (!stats) return null;
    const malicious = stats.malicious ?? 0;
    const suspicious = stats.suspicious ?? 0;
    const total = Object.values(stats).reduce((a, b) => a + b, 0);
    return {
      malicious_engines: malicious, suspicious_engines: suspicious, total_engines: total,
      harmless_engines: stats.harmless ?? 0,
      verdict: malicious > 0 ? `MALICIOUS — ${malicious}/${total} engines flagged`
        : suspicious > 0 ? `SUSPICIOUS — ${suspicious}/${total} engines flagged`
        : `CLEAN — 0/${total} engines detected threats`,
    };
  } catch { return null; }
}

async function queryOtx(ioc: string, type: IocType): Promise<Record<string, unknown> | null> {
  const key = process.env.OTX_API_KEY;
  if (!key) return null;
  try {
    const indicatorType = type === "ip" ? "IPv4" : type === "hash" ? "file" : type === "domain" ? "domain" : type === "url" ? "url" : null;
    if (!indicatorType) return null;
    const res = await fetch(
      `https://otx.alienvault.com/api/v1/indicators/${indicatorType}/${encodeURIComponent(ioc)}/general`,
      { headers: { "X-OTX-API-KEY": key } }
    );
    if (!res.ok) return null;
    const data = (await res.json()) as Record<string, unknown>;
    const pulseCount = ((data.pulse_info as Record<string, unknown>)?.count as number) ?? 0;
    return {
      pulse_count: pulseCount,
      tags: ((data.pulse_info as Record<string, unknown>)?.tags as string[] | undefined)?.slice(0, 5) ?? [],
      verdict: pulseCount > 5 ? `MALICIOUS — found in ${pulseCount} threat intelligence pulses`
        : pulseCount > 0 ? `SUSPICIOUS — found in ${pulseCount} threat intelligence pulses`
        : `UNKNOWN — no threat intelligence pulses found`,
    };
  } catch { return null; }
}

async function queryUrlhaus(ioc: string, type: "domain" | "url"): Promise<Record<string, unknown> | null> {
  try {
    const endpoint = type === "url" ? "https://urlhaus-api.abuse.ch/v1/url/" : "https://urlhaus-api.abuse.ch/v1/host/";
    const body = type === "url" ? `url=${encodeURIComponent(ioc)}` : `host=${encodeURIComponent(ioc)}`;
    const res = await fetch(endpoint, { method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" }, body });
    if (!res.ok) return null;
    const data = (await res.json()) as Record<string, unknown>;
    if (data.query_status === "no_results" || data.query_status === "invalid_host")
      return { verdict: "CLEAN — not found in URLhaus malware distribution database", malware_urls: 0 };
    const urlCount = (data.urls as unknown[])?.length ?? 0;
    return {
      query_status: data.query_status, malware_urls: urlCount, blacklists: data.blacklists,
      verdict: urlCount > 0 ? `MALICIOUS — ${urlCount} malware distribution URLs found in URLhaus` : `SUSPICIOUS — listed in URLhaus`,
    };
  } catch { return null; }
}

async function queryRdap(domain: string): Promise<Record<string, unknown> | null> {
  try {
    const res = await fetch(`https://rdap.org/domain/${encodeURIComponent(domain)}`);
    if (!res.ok) return null;
    const data = (await res.json()) as Record<string, unknown>;
    const events = data.events as Array<Record<string, string>> | undefined;
    const registered = events?.find(e => e.eventAction === "registration")?.eventDate;
    const ageDays = registered ? Math.floor((Date.now() - new Date(registered).getTime()) / 86400000) : null;
    const entities = data.entities as Array<Record<string, unknown>> | undefined;
    const registrarVcard = entities?.find(e => (e.roles as string[])?.includes("registrar"))?.vcardArray as unknown[][] | undefined;
    const registrarName = (registrarVcard?.[1]?.find((v: unknown) => Array.isArray(v) && (v as unknown[])[0] === "fn") as unknown[] | undefined)?.[3] as string | undefined;
    return {
      registered: registered ?? "Unknown",
      updated: events?.find(e => e.eventAction === "last changed")?.eventDate ?? "Unknown",
      expiry: events?.find(e => e.eventAction === "expiration")?.eventDate ?? "Unknown",
      age_days: ageDays,
      registrar: registrarName ?? "Unknown",
      verdict: ageDays === null ? "UNKNOWN — registration date unavailable"
        : ageDays < 30 ? `SUSPICIOUS — registered only ${ageDays} days ago`
        : ageDays < 90 ? `SUSPICIOUS — registered ${ageDays} days ago (recently registered)`
        : `INFORMATIONAL — domain is ${ageDays} days old`,
    };
  } catch { return null; }
}

let _mdtiToken: { token: string; expires: number } | null = null;
async function getMdtiToken(): Promise<string | null> {
  const tenantId = process.env.MDTI_TENANT_ID;
  const clientId = process.env.MDTI_CLIENT_ID;
  const clientSecret = process.env.MDTI_CLIENT_SECRET;
  if (!tenantId || !clientId || !clientSecret) return null;
  if (_mdtiToken && Date.now() < _mdtiToken.expires) return _mdtiToken.token;
  try {
    const res = await fetch(`https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`, {
      method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({ client_id: clientId, client_secret: clientSecret, scope: "https://graph.microsoft.com/.default", grant_type: "client_credentials" }).toString(),
    });
    if (!res.ok) return null;
    const data = (await res.json()) as Record<string, unknown>;
    const token = data.access_token as string;
    _mdtiToken = { token, expires: Date.now() + ((data.expires_in as number) * 1000) - 60000 };
    return token;
  } catch { return null; }
}

async function queryMdti(ioc: string, type: IocType): Promise<Record<string, unknown> | null> {
  const token = await getMdtiToken();
  if (!token) return null;
  try {
    let endpoint: string;
    if (type === "ip" || type === "domain")
      endpoint = `https://graph.microsoft.com/v1.0/security/threatIntelligence/hosts/${encodeURIComponent(ioc)}/reputation`;
    else if (type === "hash")
      endpoint = `https://graph.microsoft.com/v1.0/security/threatIntelligence/fileHashes/${ioc}`;
    else return null;
    const res = await fetch(endpoint, { headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" } });
    if (!res.ok) return null;
    const data = (await res.json()) as Record<string, unknown>;
    const classification = (data.classification as string) ?? "unknown";
    const score = (data.score as number) ?? 0;
    return {
      classification, score,
      verdict: classification === "malicious" || score > 50 ? `MALICIOUS — Microsoft classifies as malicious (score: ${score})`
        : classification === "suspicious" || score > 20 ? `SUSPICIOUS — Microsoft classifies as suspicious (score: ${score})`
        : `CLEAN — Microsoft classifies as ${classification} (score: ${score})`,
    };
  } catch { return null; }
}

function computeHashSync(content: string, encoding: "text" | "base64"): object {
  const buf = encoding === "base64" ? Buffer.from(content, "base64") : Buffer.from(content, "utf8");
  const md5 = createHash("md5").update(buf).digest("hex");
  const sha1 = createHash("sha1").update(buf).digest("hex");
  const sha256 = createHash("sha256").update(buf).digest("hex");
  return {
    size_bytes: buf.length, md5, sha1, sha256,
    summary: `Hashes computed from ${encoding} input (${buf.length} bytes):\nMD5:    ${md5}\nSHA1:   ${sha1}\nSHA256: ${sha256}\n\nNext step: use enrich_ioc with one of these hashes to check against threat intelligence.`,
  };
}

// ─── Report Enrichment Helpers ───────────────────────────────────────────────

function getThreatLevel(verdict: string, confidence: number): string {
  if (verdict === "MALICIOUS" && confidence >= 75) return "CRITICAL";
  if (verdict === "MALICIOUS") return "HIGH";
  if (verdict === "SUSPICIOUS") return "MEDIUM";
  if (verdict === "LIKELY CLEAN") return "LOW";
  return "INFORMATIONAL";
}

function getRecommendedActions(type: string, verdict: string, ioc: string): string[] {
  if (verdict === "MALICIOUS") {
    if (type === "IP Address") return [
      `Block ${ioc} at perimeter firewall and proxy immediately`,
      `Search SIEM/EDR logs for all historical connections to/from ${ioc} (last 30/60/90 days)`,
      `Escalate any endpoints that communicated with this IP to Tier 2 for investigation`,
      `Document the indicator in your threat intelligence platform`,
      `Consider filing an incident report if internal hosts were involved`,
    ];
    if (type.includes("Hash")) return [
      `Quarantine all endpoints where this file was detected`,
      `Isolate affected hosts from the network pending investigation`,
      `Search EDR for process execution, file creation, and network activity associated with this hash`,
      `Identify the file origin — email attachment, download, lateral movement`,
      `Preserve forensic artifacts before remediation`,
    ];
    if (type === "Domain" || type === "URL") return [
      `Block this ${type.toLowerCase()} at DNS resolver and web proxy immediately`,
      `Search SIEM/proxy logs for all users who accessed this ${type.toLowerCase()}`,
      `Investigate endpoints that communicated with this ${type.toLowerCase()} for signs of compromise`,
      `Check for related IOCs (IPs resolved by the domain, sibling domains)`,
      `Document and share the indicator with your threat intel team`,
    ];
  }
  if (verdict === "SUSPICIOUS") return [
    `Add to watchlist and monitor all traffic to/from this indicator`,
    `Review recent connections or access logs for suspicious patterns`,
    `Investigate the business context — is there a legitimate reason for this traffic?`,
    `Consider temporary block pending further investigation`,
  ];
  return [
    `No immediate action required based on available intelligence`,
    `Continue standard monitoring per security policy`,
    `Reassess if additional context or indicators emerge`,
  ];
}

function getIpContext(geo: Record<string, unknown> | undefined, abuse: Record<string, unknown> | undefined): string {
  if (!geo) return "IP geolocation data unavailable.";
  const hostname = (geo.hostname as string) ?? "";
  const org = (geo.organization as string) ?? "";
  const isTor = hostname.toLowerCase().includes("tor") || hostname.toLowerCase().includes("exit");
  const isHosting = org.toLowerCase().match(/hosting|cloud|datacenter|vps|server|coloc/);
  const abuseScore = (abuse?.abuse_confidence_score as number) ?? -1;

  if (isTor) return `Tor exit node — this IP is used to anonymize attacker traffic and bypass IP-based detection controls. Connections from Tor exit nodes are commonly associated with scanning, credential stuffing, and targeted attacks.`;
  if (abuseScore >= 80) return `High-abuse IP address with ${abuseScore}% abuse confidence from ${abuse?.total_reports} community reports. Likely used for malicious activity including scanning, brute force, or command-and-control.`;
  if (isHosting) return `Datacenter/hosting IP (${org}) — commonly used for command-and-control infrastructure, anonymous scanning, or malicious hosting. Not a residential endpoint.`;
  return `IP address located in ${geo.city}, ${geo.country} operated by ${org}.`;
}

// ─── Top-level IOC Enricher (with refanging + routing) ───────────────────────

async function enrichIoc(rawIoc: string): Promise<object> {
  // Auto-detect comma-separated list and route to batch
  const trimmed = rawIoc.trim();
  if (trimmed.includes(",")) {
    const iocs = trimmed.split(",").map(s => s.trim()).filter(Boolean);
    if (iocs.length > 1) return enrichBatch(iocs.slice(0, 20));
  }
  const ioc = refangIoc(rawIoc);
  const type = detectIocType(ioc);
  switch (type) {
    case "ip":     return enrichIp(ioc);
    case "hash":   return enrichHash(ioc);
    case "domain": return enrichDomain(ioc);
    case "url":    return enrichUrl(ioc);
    default: return {
      ioc, defanged_ioc: defangIoc(ioc),
      error: "Could not detect IOC type.",
      hint: "Provide an IPv4 address, MD5/SHA1/SHA256 hash, domain name, or http(s):// URL.",
    };
  }
}

// ─── Batch Enrichment ────────────────────────────────────────────────────────

async function enrichBatch(iocs: string[]): Promise<object> {
  const start = Date.now();
  const settled = await Promise.allSettled(iocs.map(ioc => enrichIoc(ioc)));
  const results = settled.map((r, i) =>
    r.status === "fulfilled" ? r.value : { ioc: iocs[i], error: String(r.reason), verdict: "ERROR" }
  ) as Record<string, unknown>[];
  const tally = results.reduce((acc, r) => {
    const v = ((r.verdict as string) ?? "UNKNOWN").split(" ")[0];
    acc[v] = ((acc[v] as number) ?? 0) + 1;
    return acc;
  }, {} as Record<string, number>);
  const ms = Date.now() - start;
  return {
    total_iocs: iocs.length, duration_ms: ms, verdict_summary: tally, results,
    summary: `Batch enrichment: ${iocs.length} IOCs in ${ms}ms\n` + Object.entries(tally).map(([v, c]) => `  ${v}: ${c}`).join('\n'),
  };
}

// ─── IP Enrichment ───────────────────────────────────────────────────────────

async function enrichIp(ip: string): Promise<object> {
  const cached = getCached(`ip:${ip}`);
  if (cached) return cached;

  const result: Record<string, unknown> = {
    ioc: ip, defanged_ioc: defangIoc(ip), type: "IP Address", sources_queried: [] as string[],
  };

  // IPinfo.io
  try {
    const res = await fetch(`https://ipinfo.io/${ip}/json`);
    if (res.ok) {
      const data = (await res.json()) as Record<string, string>;
      const hostname = data.hostname ?? "None";
      const isTor = hostname.toLowerCase().includes("tor") || hostname.toLowerCase().includes("exit");
      const isHosting = (data.org ?? "").toLowerCase().match(/hosting|cloud|datacenter|vps|server|coloc/) !== null;
      result.geolocation = {
        country: data.country ?? "Unknown", region: data.region ?? "Unknown", city: data.city ?? "Unknown",
        timezone: data.timezone ?? "Unknown", organization: data.org ?? "Unknown",
        asn: data.org?.split(" ")[0] ?? "Unknown", hostname,
        verdict: isTor ? "SUSPICIOUS \u2014 Tor exit node detected in hostname"
          : isHosting ? "SUSPICIOUS \u2014 Hosting/datacenter IP (not residential)"
          : "INFORMATIONAL \u2014 No suspicious indicators in geolocation",
      };
      (result.sources_queried as string[]).push("IPinfo.io");
    }
  } catch { result.ipinfo_error = "Could not reach IPinfo.io"; }

  // AbuseIPDB
  const abuseKey = process.env.ABUSEIPDB_API_KEY;
  if (abuseKey) {
    try {
      const res = await fetch(
        `https://api.abuseipdb.com/api/v2/check?ipAddress=${encodeURIComponent(ip)}&maxAgeInDays=90`,
        { headers: { Key: abuseKey, Accept: "application/json" } }
      );
      if (res.ok) {
        const d = ((await res.json()) as { data: Record<string, unknown> }).data;
        const score = d.abuseConfidenceScore as number;
        result.abuse_intelligence = {
          abuse_confidence_score: score, total_reports: d.totalReports,
          last_reported_at: d.lastReportedAt ?? "Never", isp: d.isp ?? "Unknown",
          is_tor: d.isTor ?? false, is_public: d.isPublic ?? true,
          verdict: score >= 80 ? `MALICIOUS \u2014 ${score}% abuse confidence, ${d.totalReports} reports`
            : score >= 25 ? `SUSPICIOUS \u2014 ${score}% abuse confidence, ${d.totalReports} reports`
            : `CLEAN \u2014 ${score}% abuse confidence, ${d.totalReports} reports`,
        };
        (result.sources_queried as string[]).push("AbuseIPDB");
      }
    } catch { result.abuseipdb_error = "Could not reach AbuseIPDB"; }
  } else { result.abuseipdb_note = "AbuseIPDB not queried. Set ABUSEIPDB_API_KEY environment variable."; }

  // VirusTotal, AlienVault OTX (both optional)
  const [vt, otx] = await Promise.all([queryVirusTotal(ip, "ip"), queryOtx(ip, "ip")]);
  if (vt)   { result.virustotal     = vt;   (result.sources_queried as string[]).push("VirusTotal"); }
  if (otx)  { result.alienvault_otx  = otx;  (result.sources_queried as string[]).push("AlienVault OTX"); }

  const abuseScore = (result.abuse_intelligence as Record<string, number> | undefined)?.abuse_confidence_score ?? -1;
  const vtMalicious = (vt?.malicious_engines as number) ?? 0;
  const otxPulses   = (otx?.pulse_count      as number) ?? 0;

  let verdict: string, confidence: number, action: string;
  if (abuseScore >= 80 || vtMalicious > 3) {
    verdict = "MALICIOUS"; confidence = abuseScore >= 80 ? abuseScore : 85;
    action = "Block at firewall immediately. Investigate all connections from this IP.";
  } else if (abuseScore >= 25 || vtMalicious > 0 || otxPulses > 5) {
    verdict = "SUSPICIOUS"; confidence = abuseScore >= 0 ? abuseScore : 60;
    action = "Monitor closely. Review all recent connections. Consider temporary block.";
  } else if (abuseScore >= 0) {
    verdict = "LIKELY CLEAN"; confidence = 100 - abuseScore;
    action = "No immediate action required. Continue standard monitoring.";
  } else {
    verdict = "UNKNOWN"; confidence = 0;
    action = "Add ABUSEIPDB_API_KEY for abuse scoring. Review geolocation for context.";
  }
  result.verdict = verdict; result.confidence_pct = confidence; result.recommended_action = action;

  const geo   = result.geolocation       as Record<string, unknown> | undefined;
  const abuse = result.abuse_intelligence as Record<string, unknown> | undefined;
  const threatLevel = getThreatLevel(verdict, confidence);
  const iocContext  = getIpContext(geo, abuse);
  const actions     = getRecommendedActions("IP Address", verdict, ip);

  const findings: string[] = [];
  if (geo)   findings.push(`IPinfo.io: ${geo.city}, ${geo.region}, ${geo.country} · ${geo.asn} (${geo.organization}) · hostname: ${geo.hostname} → ${geo.verdict}`);
  if (abuse) findings.push(`AbuseIPDB: ${abuse.abuse_confidence_score}% abuse confidence · ${abuse.total_reports} reports · ISP: ${abuse.isp}${abuse.is_tor ? ' · Confirmed Tor exit node' : ''}`);
  else       findings.push(`AbuseIPDB: not queried — set ABUSEIPDB_API_KEY for abuse scoring`);
  if (vt)    findings.push(`VirusTotal: ${vt.malicious_engines} of ${vt.total_engines} engines flagged · ${vt.verdict}`);
  if (otx)   findings.push(`AlienVault OTX: ${otx.pulse_count} threat intelligence pulses · ${otx.verdict}`);

  result.threat_level = threatLevel;
  result.ioc_context = iocContext;
  result.key_findings = findings;
  result.recommended_actions = actions;

  result.summary = [
    `THREAT LEVEL: ${threatLevel} — ${verdict} (${confidence}% confidence)`,
    ``,
    `IOC: ${defangIoc(ip)} (IP Address)`,
    `Context: ${iocContext}`,
    ``,
    `Intelligence Findings:`,
    ...findings.map(f => `  • ${f}`),
    ``,
    `Recommended Actions:`,
    ...actions.map((a, i) => `  ${i + 1}. ${a}`),
  ].join('\n');

  setCached(`ip:${ip}`, result as object);
  return result;
}

// ─── Hash Enrichment ─────────────────────────────────────────────────────────

async function enrichHash(hash: string): Promise<object> {
  const cached = getCached(`hash:${hash}`);
  if (cached) return cached;

  const result: Record<string, unknown> = {
    ioc: hash, defanged_ioc: hash,
    type: `File Hash (${hashType(hash)})`,
    sources_queried: [] as string[],
  };

  // MalwareBazaar
  try {
    const res = await fetch("https://mb-api.abuse.ch/api/v1/", {
      method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: `query=get_info&hash=${hash}`,
    });
    if (res.ok) {
      const data = (await res.json()) as Record<string, unknown>;
      (result.sources_queried as string[]).push("MalwareBazaar (abuse.ch)");
      if (data.query_status === "hash_found") {
        const s = (data.data as Record<string, unknown>[])[0];
        result.malware_intelligence = {
          malware_name: s.signature ?? "Unknown",
          tags: (s.tags as string[] | null)?.join(", ") ?? "None",
          file_type: s.file_type ?? "Unknown", file_name: s.file_name ?? "Unknown",
          file_size_bytes: s.file_size ?? "Unknown", first_seen: s.first_seen ?? "Unknown",
          last_seen: s.last_seen ?? "Unknown", origin_country: s.origin_country ?? "Unknown",
          reporter: s.reporter ?? "Unknown", downloads: s.downloads ?? 0,
          verdict: `MALICIOUS \u2014 confirmed malware sample (${s.signature ?? "Unknown"})`,
        };
      } else if (data.query_status === "hash_not_found") {
        result.malwarebazaar_verdict = "NOT FOUND \u2014 hash not in malware database (does not confirm clean)";
      } else {
        result.malwarebazaar_verdict = `QUERY ERROR: ${data.query_status}`;
      }
    }
  } catch { result.malwarebazaar_error = "Could not reach MalwareBazaar"; }

  // VirusTotal, AlienVault OTX (both optional)
  const [vt, otx] = await Promise.all([queryVirusTotal(hash, "hash"), queryOtx(hash, "hash")]);
  if (vt)   { result.virustotal     = vt;   (result.sources_queried as string[]).push("VirusTotal"); }
  if (otx)  { result.alienvault_otx  = otx;  (result.sources_queried as string[]).push("AlienVault OTX"); }

  // Derive verdict
  const mbMalicious  = !!(result.malware_intelligence);
  const vtMalicious  = ((vt?.malicious_engines  as number) ?? 0) > 0;
  const otxPulses    = (otx?.pulse_count         as number) ?? 0;

  let verdict: string, action: string, confidence: number;
  if (mbMalicious || vtMalicious) {
    verdict = "MALICIOUS"; confidence = 100;
    action = "Quarantine immediately. Isolate all endpoints where this file was detected. Investigate execution history.";
  } else if (otxPulses > 0) {
    verdict = "SUSPICIOUS"; confidence = 70;
    action = "Investigate file origin and execution. Consider quarantine pending further analysis.";
  } else {
    verdict = "NOT FOUND IN MALWARE DATABASE"; confidence = 0;
    action = "Perform additional analysis. Check VirusTotal. Investigate file origin.";
  }
  result.verdict = verdict; result.confidence_pct = confidence; result.recommended_action = action;

  const mal = result.malware_intelligence as Record<string, unknown> | undefined;
  const threatLevel = getThreatLevel(verdict, confidence);
  const iocContext = mal
    ? `Confirmed malware sample: ${mal.malware_name}. File type: ${mal.file_type}. First observed in the wild on ${mal.first_seen}. ${mal.tags ? `Associated tags: ${mal.tags}.` : ''}`
    : `File hash not found in malware databases. This does not confirm the file is clean — additional analysis is recommended.`;
  const actions = getRecommendedActions(result.type as string, verdict, hash);

  const findings: string[] = [];
  if (mal) findings.push(`MalwareBazaar: FOUND — ${mal.malware_name} · type: ${mal.file_type} · first seen: ${mal.first_seen} · last seen: ${mal.last_seen} · origin: ${mal.origin_country}`);
  else     findings.push(`MalwareBazaar: hash not present in database (does not confirm clean)`);
  if (vt)  findings.push(`VirusTotal: ${(vt as Record<string,unknown>).malicious_engines} of ${(vt as Record<string,unknown>).total_engines} engines flagged · ${(vt as Record<string,unknown>).verdict}`);
  if (otx) findings.push(`AlienVault OTX: ${(otx as Record<string,unknown>).pulse_count} threat intelligence pulses · ${(otx as Record<string,unknown>).verdict}`);

  result.threat_level = threatLevel;
  result.ioc_context = iocContext;
  result.key_findings = findings;
  result.recommended_actions = actions;

  result.summary = [
    `THREAT LEVEL: ${threatLevel} — ${verdict}`,
    ``,
    `IOC: ${hash} (${result.type})`,
    `Context: ${iocContext}`,
    ``,
    `Intelligence Findings:`,
    ...findings.map(f => `  • ${f}`),
    ``,
    `Recommended Actions:`,
    ...actions.map((a, i) => `  ${i + 1}. ${a}`),
  ].join('\n');

  setCached(`hash:${hash}`, result as object);
  return result;
}

// ─── Domain Enrichment ───────────────────────────────────────────────────────

async function enrichDomain(domain: string): Promise<object> {
  const cached = getCached(`domain:${domain}`);
  if (cached) return cached;

  const result: Record<string, unknown> = {
    ioc: domain, defanged_ioc: defangIoc(domain), type: "Domain", sources_queried: [] as string[],
  };

  // Google Public DNS
  try {
    const res = await fetch(`https://dns.google/resolve?name=${encodeURIComponent(domain)}&type=A`);
    if (res.ok) {
      const data = (await res.json()) as Record<string, unknown>;
      const answers = data.Answer as Array<Record<string, unknown>> | undefined;
      const aRec = answers?.filter(r => r.type === 1).map(r => r.data as string) ?? [];
      const cRec = answers?.filter(r => r.type === 5).map(r => r.data as string) ?? [];
      result.dns_resolution = {
        resolves: data.Status === 0, a_records: aRec, cname_records: cRec,
        status: data.Status === 0 ? "RESOLVES" : "NXDOMAIN / DNS Error",
        verdict: data.Status === 0 ? `RESOLVES \u2014 ${aRec.join(', ') || 'CNAME only'}` : `NXDOMAIN \u2014 domain does not exist`,
      };
      (result.sources_queried as string[]).push("Google Public DNS");
    }
  } catch { result.dns_error = "Could not resolve domain"; }

  // URLScan.io
  try {
    const res = await fetch(`https://urlscan.io/api/v1/search/?q=domain:${encodeURIComponent(domain)}&size=10`, { headers: { Accept: "application/json" } });
    if (res.ok) {
      const data = (await res.json()) as Record<string, unknown>;
      const items = data.results as Array<Record<string, unknown>> | undefined;
      if (items && items.length > 0) {
        const malCount = items.filter(r => (r.verdicts as Record<string, Record<string, boolean>>)?.overall?.malicious).length;
        const latest = items[0];
        const page = latest.page as Record<string, string> | undefined;
        result.urlscan_intelligence = {
          total_scans: data.total, malicious_verdicts: malCount,
          last_scan_date: (latest.task as Record<string, string>)?.time ?? "Unknown",
          last_scan_ip: page?.ip ?? "Unknown", last_scan_server: page?.server ?? "Unknown",
          verdict: malCount > 0 ? `MALICIOUS \u2014 ${malCount}/${items.length} scans flagged` : `LIKELY CLEAN \u2014 ${items.length} scans, 0 malicious`,
        };
        (result.sources_queried as string[]).push("URLScan.io");
      }
    }
  } catch { result.urlscan_error = "Could not reach URLScan.io"; }

  // URLhaus, RDAP, VirusTotal, AlienVault OTX
  const [urlhaus, rdap, vt, otx] = await Promise.all([
    queryUrlhaus(domain, "domain"),
    queryRdap(domain),
    queryVirusTotal(domain, "domain"),
    queryOtx(domain, "domain"),
  ]);
  if (urlhaus) { result.urlhaus       = urlhaus; (result.sources_queried as string[]).push("URLhaus (abuse.ch)"); }
  if (rdap)    { result.rdap           = rdap;    (result.sources_queried as string[]).push("RDAP/WHOIS"); }
  if (vt)      { result.virustotal     = vt;      (result.sources_queried as string[]).push("VirusTotal"); }
  if (otx)     { result.alienvault_otx = otx;     (result.sources_queried as string[]).push("AlienVault OTX"); }

  const scanMalicious  = (result.urlscan_intelligence as Record<string, number> | undefined)?.malicious_verdicts ?? 0;
  const uhMalicious    = (urlhaus?.malware_urls  as number) ?? 0;
  const vtMalicious    = (vt?.malicious_engines  as number) ?? 0;
  const otxPulses      = (otx?.pulse_count       as number) ?? 0;
  const rdapAge        = (rdap?.age_days         as number | null) ?? null;

  let verdict: string, confidence: number, action: string;
  if (scanMalicious > 0 || uhMalicious > 0 || vtMalicious > 3) {
    verdict = "MALICIOUS"; confidence = 90;
    action = "Block domain at DNS/proxy level. Investigate all users who accessed this domain.";
  } else if (vtMalicious > 0 || otxPulses > 5 || (rdapAge !== null && rdapAge < 30)) {
    verdict = "SUSPICIOUS"; confidence = 60;
    action = "Monitor and review. Consider blocking. Investigate user activity.";
  } else if ((result.dns_resolution as Record<string, boolean> | undefined)?.resolves) {
    verdict = "LIKELY CLEAN"; confidence = 70;
    action = "No immediate action required based on available data.";
  } else {
    verdict = "UNKNOWN"; confidence = 0;
    action = "No data available. Exercise caution. Submit to URLScan.io for analysis.";
  }
  result.verdict = verdict; result.confidence_pct = confidence; result.recommended_action = action;

  const dns  = result.dns_resolution      as Record<string, unknown> | undefined;
  const scan = result.urlscan_intelligence as Record<string, unknown> | undefined;
  const threatLevel = getThreatLevel(verdict, confidence);
  const rdapInfo = rdap ? (rdap as Record<string, unknown>) : null;
  const ageDays = rdapInfo?.age_days as number | null ?? null;
  const iocContext = verdict === "MALICIOUS"
    ? `Domain has been flagged as malicious by multiple threat intelligence sources. ${scan && (scan.malicious_verdicts as number) > 0 ? `URLScan.io recorded ${scan.malicious_verdicts} malicious scan verdicts.` : ''} ${uhMalicious > 0 ? `URLhaus identified ${uhMalicious} malware distribution URLs on this domain.` : ''}`
    : ageDays !== null && ageDays < 30
    ? `Recently registered domain (${ageDays} days old). Newly registered domains are a common indicator of phishing infrastructure and malware campaigns.`
    : dns?.resolves ? `Domain resolves to ${(dns.a_records as string[]).join(', ')}. ${ageDays !== null ? `Domain registered ${ageDays} days ago.` : ''}`
    : `Domain does not resolve (NXDOMAIN). May be a decommissioned malicious domain or a typosquat.`;
  const actions = getRecommendedActions("Domain", verdict, domain);

  const findings: string[] = [];
  if (dns)    findings.push(`Google DNS: ${dns.verdict}`);
  if (scan)   findings.push(`URLScan.io: ${scan.total_scans} scans · ${scan.malicious_verdicts} malicious verdicts · last resolved to ${scan.last_scan_ip}`);
  else        findings.push(`URLScan.io: no scan history found`);
  if (urlhaus) findings.push(`URLhaus: ${(urlhaus as Record<string,unknown>).verdict}`);
  if (rdapInfo) findings.push(`RDAP/WHOIS: registered ${rdapInfo.registered} · ${ageDays !== null ? `age: ${ageDays} days` : 'age unknown'} · registrar: ${rdapInfo.registrar}`);
  if (vt)     findings.push(`VirusTotal: ${(vt as Record<string,unknown>).malicious_engines} of ${(vt as Record<string,unknown>).total_engines} engines flagged`);
  if (otx)    findings.push(`AlienVault OTX: ${(otx as Record<string,unknown>).pulse_count} threat intelligence pulses`);

  result.threat_level = threatLevel;
  result.ioc_context = iocContext;
  result.key_findings = findings;
  result.recommended_actions = actions;

  result.summary = [
    `THREAT LEVEL: ${threatLevel} — ${verdict} (${confidence}% confidence)`,
    ``,
    `IOC: ${defangIoc(domain)} (Domain)`,
    `Context: ${iocContext}`,
    ``,
    `Intelligence Findings:`,
    ...findings.map(f => `  • ${f}`),
    ``,
    `Recommended Actions:`,
    ...actions.map((a, i) => `  ${i + 1}. ${a}`),
  ].join('\n');

  setCached(`domain:${domain}`, result as object);
  return result;
}

// ─── URL Enrichment ──────────────────────────────────────────────────────────

async function enrichUrl(url: string): Promise<object> {
  const cached = getCached(`url:${url}`);
  if (cached) return cached;

  const domain = extractDomainFromUrl(url);
  const result: Record<string, unknown> = {
    ioc: url, defanged_ioc: defangIoc(url), type: "URL", extracted_domain: domain, sources_queried: [] as string[],
  };

  const [urlhaus, vt, otx] = await Promise.all([
    queryUrlhaus(url, "url"),
    queryVirusTotal(url, "url"),
    queryOtx(url, "url"),
  ]);
  if (urlhaus) { result.urlhaus       = urlhaus; (result.sources_queried as string[]).push("URLhaus (abuse.ch)"); }
  if (vt)      { result.virustotal     = vt;      (result.sources_queried as string[]).push("VirusTotal"); }
  if (otx)     { result.alienvault_otx = otx;     (result.sources_queried as string[]).push("AlienVault OTX"); }

  const domainResult = await enrichDomain(domain) as Record<string, unknown>;
  result.domain_analysis = { domain, dns: domainResult.dns_resolution, urlscan: domainResult.urlscan_intelligence, rdap: domainResult.rdap, verdict: domainResult.verdict };
  for (const s of (domainResult.sources_queried as string[] ?? []))
    if (!(result.sources_queried as string[]).includes(s)) (result.sources_queried as string[]).push(s);

  const uhMalicious = (urlhaus?.malware_urls as number) ?? 0;
  const vtMalicious = (vt?.malicious_engines as number) ?? 0;
  const domVerdict  = domainResult.verdict as string ?? "";

  let verdict: string, confidence: number, action: string;
  if (uhMalicious > 0 || vtMalicious > 3 || domVerdict === "MALICIOUS") {
    verdict = "MALICIOUS"; confidence = 90; action = "Block URL at proxy/firewall. Investigate all users who accessed this URL.";
  } else if (vtMalicious > 0 || domVerdict === "SUSPICIOUS") {
    verdict = "SUSPICIOUS"; confidence = 65; action = "Monitor and review. Consider blocking.";
  } else {
    verdict = "LIKELY CLEAN"; confidence = 70; action = "No immediate action required.";
  }
  result.verdict = verdict; result.confidence_pct = confidence; result.recommended_action = action;

  const lines: string[] = [];
  if (urlhaus) lines.push(`URLhaus \u2192 ${urlhaus.verdict}`);
  if (vt)      lines.push(`VirusTotal \u2192 ${vt.verdict}`);
  if (otx)     lines.push(`AlienVault OTX \u2192 ${otx.verdict}`);
  lines.push(`Domain Analysis (${domain}) \u2192 ${domVerdict}`);
  lines.push(`Overall Verdict: ${verdict} (${confidence}% confidence) \u2014 ${action}`);
  result.summary = lines.join('\n');

  setCached(`url:${url}`, result as object);
  return result;
}

// ─── MCP Server Setup ────────────────────────────────────────────────────────

const server = new Server(
  {
    name: "soc-ioc-enricher",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "enrich_ioc",
        description: "Auto-detect the type of an IOC (IP address, file hash, domain, or URL) and query multiple threat intelligence sources. Accepts defanged IOCs and comma-separated lists of multiple IOCs for batch enrichment. Returns a correlated verdict per IOC. Use this tool for any IOC investigation request.",
        inputSchema: {
          type: "object",
          properties: { ioc: { type: "string", description: "The IOC to investigate. Accepts IPv4 (45.33.32.156), MD5/SHA1/SHA256 hash, domain (malicious.com), URL (https://malicious.com/payload), or defanged variants (185[.]220[.]101[.]45, hxxps://...)." } },
          required: ["ioc"],
        },
      },
      {
        name: "enrich_batch",
        description: "Enrich multiple IOCs in a single call. Auto-detects each IOC type. Use for incidents with multiple indicators to investigate.",
        inputSchema: {
          type: "object",
          properties: { iocs: { type: "array", items: { type: "string" }, description: "List of IOCs to enrich. Max 20. Each can be an IP, hash, domain, or URL (including defanged)." } },
          required: ["iocs"],
        },
      },
      {
        name: "compute_hash",
        description: "Compute MD5, SHA1, and SHA256 hashes from text or base64-encoded binary content, then check against threat intelligence.",
        inputSchema: {
          type: "object",
          properties: {
            content: { type: "string", description: "The content to hash. Plain text or base64-encoded binary." },
            encoding: { type: "string", enum: ["text", "base64"], description: "How content is encoded. Use 'base64' for binary files." },
          },
          required: ["content", "encoding"],
        },
      },
      {
        name: "enrich_ip",
        description: "Enrich a specific IP address — IPinfo.io + AbuseIPDB + VirusTotal + AlienVault OTX.",
        inputSchema: { type: "object", properties: { ip: { type: "string", description: "IPv4 address (e.g. 45.33.32.156)" } }, required: ["ip"] },
      },
      {
        name: "enrich_hash",
        description: "Look up a file hash (MD5/SHA1/SHA256) across MalwareBazaar, VirusTotal, and AlienVault OTX.",
        inputSchema: { type: "object", properties: { hash: { type: "string", description: "MD5 (32), SHA1 (40), or SHA256 (64) hex string." } }, required: ["hash"] },
      },
      {
        name: "enrich_domain",
        description: "Investigate a domain — Google DNS + URLScan.io + URLhaus + RDAP/WHOIS + VirusTotal + AlienVault OTX.",
        inputSchema: { type: "object", properties: { domain: { type: "string", description: "Domain name (e.g. malicious-domain.com). No http:// or paths." } }, required: ["domain"] },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    let result: object;

    switch (name) {
      case "enrich_ioc": {
        const ioc = (args as Record<string, string>).ioc?.trim();
        if (!ioc) throw new Error("ioc parameter is required");
        result = await enrichIoc(ioc);
        break;
      }

      case "enrich_batch": {
        const iocs = (args as Record<string, string[]>).iocs;
        if (!iocs?.length) throw new Error("iocs array is required");
        result = await enrichBatch(iocs.slice(0, 20));
        break;
      }

      case "compute_hash": {
        const content  = (args as Record<string, string>).content;
        const encoding = ((args as Record<string, string>).encoding ?? "text") as "text" | "base64";
        if (!content) throw new Error("content parameter is required");
        result = computeHashSync(content, encoding);
        break;
      }

      case "enrich_ip": {
        const ip = (args as Record<string, string>).ip?.trim();
        if (!ip) throw new Error("ip parameter is required");
        result = await enrichIp(refangIoc(ip));
        break;
      }

      case "enrich_hash": {
        const hash = (args as Record<string, string>).hash?.trim();
        if (!hash) throw new Error("hash parameter is required");
        result = await enrichHash(hash);
        break;
      }

      case "enrich_domain": {
        const domain = (args as Record<string, string>).domain?.trim();
        if (!domain) throw new Error("domain parameter is required");
        result = await enrichDomain(refangIoc(domain));
        break;
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(
            { error: String(error), tool: name },
            null,
            2
          ),
        },
      ],
      isError: true,
    };
  }
});

// Start server — supports both stdio (local) and HTTP/SSE (remote/Docker)
async function main() {
  const port = process.env.PORT ? parseInt(process.env.PORT) : null;

  if (port) {
    // ── HTTP/SSE mode — used when deployed to Azure Container Apps or Docker ──
    const transports = new Map<string, SSEServerTransport>();

    const httpServer = http.createServer(async (req, res) => {
      // CORS headers — required for web-based MCP clients
      res.setHeader("Access-Control-Allow-Origin", "*");
      res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
      res.setHeader("Access-Control-Allow-Headers", "Content-Type");

      if (req.method === "OPTIONS") {
        res.writeHead(204).end();
        return;
      }

      // SSE connection endpoint — client connects here to receive server events
      if (req.method === "GET" && req.url === "/sse") {
        const transport = new SSEServerTransport("/messages", res);
        transports.set(transport.sessionId, transport);
        transport.onclose = () => transports.delete(transport.sessionId);
        await server.connect(transport);
        return;
      }

      // Message endpoint — client POSTs requests here
      if (req.method === "POST" && req.url?.startsWith("/messages")) {
        const url = new URL(req.url, `http://localhost:${port}`);
        const sessionId = url.searchParams.get("sessionId");
        const transport = sessionId ? transports.get(sessionId) : undefined;

        if (!transport) {
          res.writeHead(404, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ error: "Session not found. Connect to /sse first." }));
          return;
        }

        await transport.handlePostMessage(req, res);
        return;
      }

      // Health check — used by Azure Container Apps liveness probe
      if (req.url === "/health") {
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ status: "ok", server: "soc-ioc-enricher", version: "1.0.0" }));
        return;
      }

      // OpenAPI spec — consumed by Security Copilot OpenAI plugin
      if (req.url === "/openapi.yaml") {
        res.writeHead(200, { "Content-Type": "application/yaml" });
        res.end(OPENAPI_SPEC);
        return;
      }

      // Security Copilot native plugin descriptor
      if (req.url === "/plugin.yaml") {
        res.writeHead(200, { "Content-Type": "application/yaml" });
        res.end(PLUGIN_DESCRIPTOR);
        return;
      }

      // ── REST endpoints — used by Security Copilot OpenAI plugin ─────────
      const url = new URL(req.url ?? "/", `http://localhost:${port}`);

      if (req.method === "GET" && url.pathname === "/enrich") {
        const ioc = url.searchParams.get("ioc")?.trim();
        if (!ioc) {
          res.writeHead(400, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ error: "Missing required query parameter: ioc" }));
          return;
        }
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(await enrichIoc(ioc)));
        return;
      }

      if (req.method === "GET" && url.pathname === "/enrich/batch") {
        const raw = url.searchParams.get("iocs")?.trim();
        if (!raw) {
          res.writeHead(400, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ error: "Missing required query parameter: iocs (comma-separated)" }));
          return;
        }
        const iocs = raw.split(",").map(s => s.trim()).filter(Boolean).slice(0, 20);
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(await enrichBatch(iocs)));
        return;
      }

      if (req.method === "GET" && url.pathname === "/hash") {
        const content  = url.searchParams.get("content")?.trim();
        const encoding = (url.searchParams.get("encoding") ?? "text") as "text" | "base64";
        if (!content) {
          res.writeHead(400, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ error: "Missing required query parameter: content" }));
          return;
        }
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(computeHashSync(content, encoding)));
        return;
      }

      if (req.method === "GET" && url.pathname === "/enrich/ip") {
        const ip = url.searchParams.get("ip")?.trim();
        if (!ip) {
          res.writeHead(400, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ error: "Missing required query parameter: ip" }));
          return;
        }
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(await enrichIp(ip)));
        return;
      }

      if (req.method === "GET" && url.pathname === "/enrich/hash") {
        const hash = url.searchParams.get("hash")?.trim();
        if (!hash) {
          res.writeHead(400, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ error: "Missing required query parameter: hash" }));
          return;
        }
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(await enrichHash(hash)));
        return;
      }

      if (req.method === "GET" && url.pathname === "/enrich/domain") {
        const domain = url.searchParams.get("domain")?.trim();
        if (!domain) {
          res.writeHead(400, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ error: "Missing required query parameter: domain" }));
          return;
        }
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(await enrichDomain(domain)));
        return;
      }

      res.writeHead(404).end("Not found");
    });

    httpServer.listen(port, () => {
      console.error(`SOC IOC Enricher MCP server running on HTTP port ${port}`);
      console.error(`  SSE endpoint:    http://localhost:${port}/sse`);
      console.error(`  Health check:    http://localhost:${port}/health`);
    });
  } else {
    // ── stdio mode — used for local MCP clients (Claude Desktop, VS Code) ──
    const transport = new StdioServerTransport();
    await server.connect(transport);
    console.error("SOC IOC Enricher MCP server running on stdio");
  }
}

main().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
