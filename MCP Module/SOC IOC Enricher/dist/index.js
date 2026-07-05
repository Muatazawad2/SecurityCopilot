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
import { CallToolRequestSchema, ListToolsRequestSchema, } from "@modelcontextprotocol/sdk/types.js";
function detectIocType(ioc) {
    const clean = ioc.trim();
    if (/^(\d{1,3}\.){3}\d{1,3}$/.test(clean))
        return "ip";
    if (/^[a-fA-F0-9]{32}$/.test(clean))
        return "hash"; // MD5
    if (/^[a-fA-F0-9]{40}$/.test(clean))
        return "hash"; // SHA1
    if (/^[a-fA-F0-9]{64}$/.test(clean))
        return "hash"; // SHA256
    if (/^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$/.test(clean))
        return "domain";
    return "unknown";
}
function hashType(hash) {
    if (hash.length === 32)
        return "MD5";
    if (hash.length === 40)
        return "SHA1";
    if (hash.length === 64)
        return "SHA256";
    return "Unknown";
}
// ─── IP Enrichment ───────────────────────────────────────────────────────────
async function enrichIp(ip) {
    const result = {
        ioc: ip,
        type: "IP Address",
        sources_queried: [],
    };
    // IPinfo.io — no key required for basic queries
    try {
        const res = await fetch(`https://ipinfo.io/${ip}/json`);
        if (res.ok) {
            const data = (await res.json());
            result.geolocation = {
                country: data.country ?? "Unknown",
                region: data.region ?? "Unknown",
                city: data.city ?? "Unknown",
                timezone: data.timezone ?? "Unknown",
                organization: data.org ?? "Unknown",
                asn: data.org?.split(" ")[0] ?? "Unknown",
                hostname: data.hostname ?? "None",
            };
            result.sources_queried.push("IPinfo.io");
        }
    }
    catch {
        result.ipinfo_error = "Could not reach IPinfo.io";
    }
    // AbuseIPDB — optional, requires free API key in ABUSEIPDB_API_KEY env var
    const abuseKey = process.env.ABUSEIPDB_API_KEY;
    if (abuseKey) {
        try {
            const res = await fetch(`https://api.abuseipdb.com/api/v2/check?ipAddress=${encodeURIComponent(ip)}&maxAgeInDays=90`, { headers: { Key: abuseKey, Accept: "application/json" } });
            if (res.ok) {
                const json = (await res.json());
                const d = json.data;
                result.abuse_intelligence = {
                    abuse_confidence_score: d.abuseConfidenceScore,
                    total_reports: d.totalReports,
                    last_reported_at: d.lastReportedAt ?? "Never",
                    usage_type: d.usageType ?? "Unknown",
                    isp: d.isp ?? "Unknown",
                    is_tor: d.isTor ?? false,
                    is_public: d.isPublic ?? true,
                };
                result.sources_queried.push("AbuseIPDB");
            }
        }
        catch {
            result.abuseipdb_error = "Could not reach AbuseIPDB";
        }
    }
    else {
        result.abuseipdb_note =
            "AbuseIPDB not queried. Set ABUSEIPDB_API_KEY environment variable for IP abuse scoring.";
    }
    // Derive verdict
    const abuseScore = result.abuse_intelligence
        ?.abuse_confidence_score ?? -1;
    let verdict;
    let confidence;
    let action;
    if (abuseScore >= 80) {
        verdict = "MALICIOUS";
        confidence = abuseScore;
        action = "Block at firewall immediately. Investigate all connections from this IP.";
    }
    else if (abuseScore >= 25) {
        verdict = "SUSPICIOUS";
        confidence = abuseScore;
        action = "Monitor closely. Review all recent connections. Consider temporary block.";
    }
    else if (abuseScore >= 0) {
        verdict = "LIKELY CLEAN";
        confidence = 100 - abuseScore;
        action = "No immediate action required. Continue standard monitoring.";
    }
    else {
        verdict = "UNKNOWN";
        confidence = 0;
        action = "Add ABUSEIPDB_API_KEY for abuse scoring. Review geolocation for context.";
    }
    result.verdict = verdict;
    result.confidence_pct = confidence;
    result.recommended_action = action;
    return result;
}
// ─── Hash Enrichment ─────────────────────────────────────────────────────────
async function enrichHash(hash) {
    const result = {
        ioc: hash,
        type: `File Hash (${hashType(hash)})`,
        sources_queried: [],
    };
    // MalwareBazaar — no API key required
    try {
        const res = await fetch("https://mb-api.abuse.ch/api/v1/", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: `query=get_info&hash=${hash}`,
        });
        if (res.ok) {
            const data = (await res.json());
            result.sources_queried.push("MalwareBazaar (abuse.ch)");
            if (data.query_status === "hash_found") {
                const sample = data.data[0];
                result.malware_intelligence = {
                    malware_name: sample.signature ?? "Unknown",
                    tags: sample.tags?.join(", ") ?? "None",
                    file_type: sample.file_type ?? "Unknown",
                    file_name: sample.file_name ?? "Unknown",
                    file_size_bytes: sample.file_size ?? "Unknown",
                    first_seen: sample.first_seen ?? "Unknown",
                    last_seen: sample.last_seen ?? "Unknown",
                    origin_country: sample.origin_country ?? "Unknown",
                    reporter: sample.reporter ?? "Unknown",
                    downloads: sample.downloads ?? 0,
                    delivery_method: sample.delivery_method ?? "Unknown",
                };
                result.verdict = "MALICIOUS";
                result.confidence_pct = 100;
                result.recommended_action =
                    "Quarantine immediately. Isolate all endpoints where this file was detected. Investigate execution history.";
            }
            else if (data.query_status === "hash_not_found") {
                result.verdict = "NOT FOUND IN MALWARE DATABASE";
                result.confidence_pct = 0;
                result.note =
                    "Hash not found in MalwareBazaar. This does not confirm the file is clean — consider checking VirusTotal for broader coverage.";
                result.recommended_action =
                    "Perform additional analysis. Check VirusTotal. Investigate file origin.";
            }
            else {
                result.verdict = "QUERY ERROR";
                result.malwarebazaar_status = data.query_status;
            }
        }
    }
    catch {
        result.malwarebazaar_error = "Could not reach MalwareBazaar";
        result.verdict = "LOOKUP FAILED";
        result.recommended_action = "Manual lookup required. Check https://bazaar.abuse.ch/browse/";
    }
    return result;
}
// ─── Domain Enrichment ───────────────────────────────────────────────────────
async function enrichDomain(domain) {
    const result = {
        ioc: domain,
        type: "Domain",
        sources_queried: [],
    };
    // Google Public DNS — no key required
    try {
        const res = await fetch(`https://dns.google/resolve?name=${encodeURIComponent(domain)}&type=A`);
        if (res.ok) {
            const data = (await res.json());
            const answers = data.Answer;
            result.dns_resolution = {
                resolves: data.Status === 0,
                status: data.Status === 0 ? "RESOLVES" : "NXDOMAIN / DNS Error",
                a_records: answers?.filter((r) => r.type === 1).map((r) => r.data) ?? [],
                cname_records: answers?.filter((r) => r.type === 5).map((r) => r.data) ?? [],
            };
            result.sources_queried.push("Google Public DNS");
        }
    }
    catch {
        result.dns_error = "Could not resolve domain";
    }
    // URLScan.io — no key required for search
    try {
        const res = await fetch(`https://urlscan.io/api/v1/search/?q=domain:${encodeURIComponent(domain)}&size=10`, { headers: { Accept: "application/json" } });
        if (res.ok) {
            const data = (await res.json());
            const results = data.results;
            if (results && results.length > 0) {
                const maliciousCount = results.filter((r) => r.verdicts?.overall?.malicious).length;
                const latest = results[0];
                const page = latest.page;
                const verdicts = latest.verdicts;
                result.urlscan_intelligence = {
                    total_scans: data.total,
                    malicious_verdicts: maliciousCount,
                    last_scan_date: latest.task?.time ?? "Unknown",
                    last_scan_country: page?.country ?? "Unknown",
                    last_scan_ip: page?.ip ?? "Unknown",
                    last_scan_server: page?.server ?? "Unknown",
                    overall_verdict: verdicts?.overall?.score ?? "No verdict",
                    categories: verdicts?.overall?.categories?.join(", ") ?? "None",
                };
                result.sources_queried.push("URLScan.io");
                if (maliciousCount > 0) {
                    result.verdict = "MALICIOUS";
                    result.confidence_pct = Math.round((maliciousCount / results.length) * 100);
                    result.recommended_action =
                        "Block domain at DNS/proxy level. Investigate all users who accessed this domain.";
                }
                else {
                    result.verdict = "LIKELY CLEAN";
                    result.confidence_pct = 70;
                    result.recommended_action = "No immediate action required based on available data.";
                }
            }
            else {
                result.urlscan_note = "No scan history found for this domain in URLScan.io.";
                result.verdict = "UNKNOWN";
                result.confidence_pct = 0;
                result.recommended_action =
                    "No scan history available. Exercise caution. Submit domain to URLScan.io for analysis: https://urlscan.io/";
            }
        }
    }
    catch {
        result.urlscan_error = "Could not reach URLScan.io";
    }
    return result;
}
// ─── MCP Server Setup ────────────────────────────────────────────────────────
const server = new Server({
    name: "soc-ioc-enricher",
    version: "1.0.0",
}, {
    capabilities: {
        tools: {},
    },
});
// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
    return {
        tools: [
            {
                name: "enrich_ioc",
                description: "Auto-detect the type of an IOC (IP address, file hash MD5/SHA1/SHA256, or domain) and query multiple threat intelligence sources simultaneously. Returns a single correlated verdict with confidence score and recommended action. This is the primary tool — use this first.",
                inputSchema: {
                    type: "object",
                    properties: {
                        ioc: {
                            type: "string",
                            description: "The indicator of compromise to investigate. Can be an IPv4 address (e.g. 45.33.32.156), a file hash (MD5, SHA1, or SHA256), or a domain name (e.g. malicious-domain.com).",
                        },
                    },
                    required: ["ioc"],
                },
            },
            {
                name: "enrich_ip",
                description: "Enrich a specific IP address by querying IPinfo.io for geolocation and ASN data, and optionally AbuseIPDB for abuse confidence score (requires ABUSEIPDB_API_KEY environment variable).",
                inputSchema: {
                    type: "object",
                    properties: {
                        ip: {
                            type: "string",
                            description: "IPv4 address to investigate (e.g. 45.33.32.156)",
                        },
                    },
                    required: ["ip"],
                },
            },
            {
                name: "enrich_hash",
                description: "Look up a file hash (MD5, SHA1, or SHA256) in MalwareBazaar to determine if it is associated with known malware. Returns malware family, tags, file type, and first/last seen dates.",
                inputSchema: {
                    type: "object",
                    properties: {
                        hash: {
                            type: "string",
                            description: "File hash to look up. Accepts MD5 (32 chars), SHA1 (40 chars), or SHA256 (64 chars) hex strings.",
                        },
                    },
                    required: ["hash"],
                },
            },
            {
                name: "enrich_domain",
                description: "Investigate a domain name by checking DNS resolution (Google Public DNS) and searching URLScan.io for scan history and malicious verdicts.",
                inputSchema: {
                    type: "object",
                    properties: {
                        domain: {
                            type: "string",
                            description: "Domain name to investigate (e.g. malicious-domain.com). Do not include http:// or paths.",
                        },
                    },
                    required: ["domain"],
                },
            },
        ],
    };
});
// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const { name, arguments: args } = request.params;
    try {
        let result;
        switch (name) {
            case "enrich_ioc": {
                const ioc = args.ioc?.trim();
                if (!ioc)
                    throw new Error("ioc parameter is required");
                const type = detectIocType(ioc);
                switch (type) {
                    case "ip":
                        result = await enrichIp(ioc);
                        break;
                    case "hash":
                        result = await enrichHash(ioc);
                        break;
                    case "domain":
                        result = await enrichDomain(ioc);
                        break;
                    default:
                        result = {
                            ioc,
                            error: "Could not detect IOC type.",
                            hint: "Provide an IPv4 address, MD5/SHA1/SHA256 hash, or a domain name.",
                        };
                }
                break;
            }
            case "enrich_ip": {
                const ip = args.ip?.trim();
                if (!ip)
                    throw new Error("ip parameter is required");
                result = await enrichIp(ip);
                break;
            }
            case "enrich_hash": {
                const hash = args.hash?.trim();
                if (!hash)
                    throw new Error("hash parameter is required");
                result = await enrichHash(hash);
                break;
            }
            case "enrich_domain": {
                const domain = args.domain?.trim();
                if (!domain)
                    throw new Error("domain parameter is required");
                result = await enrichDomain(domain);
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
    }
    catch (error) {
        return {
            content: [
                {
                    type: "text",
                    text: JSON.stringify({ error: String(error), tool: name }, null, 2),
                },
            ],
            isError: true,
        };
    }
});
// Start server
async function main() {
    const transport = new StdioServerTransport();
    await server.connect(transport);
    console.error("SOC IOC Enricher MCP server running on stdio");
}
main().catch((err) => {
    console.error("Fatal error:", err);
    process.exit(1);
});
