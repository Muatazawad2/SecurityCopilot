# Executive Threat Intelligence Briefing

**Developer**: Dr Muataz Awad

**Description**: Generate a structured, executive-ready threat intelligence briefing tailored to your organization's industry and geography. This promptbook walks through the current threat landscape, top threat actors, active campaigns, vulnerability exposure, and strategic recommendations — producing a polished intelligence product suitable for CISO, board, or senior leadership consumption. Results may be limited if the Microsoft Threat Intelligence plugin is not enabled or required permissions are not configured.

---

1. Summarize the current global threat landscape
```
Provide a concise executive-level summary of the current global cybersecurity threat landscape as of today. Include: the top 3 overarching threat trends (e.g., ransomware escalation, state-sponsored espionage, supply chain attacks), any significant geopolitical events driving increased cyber threat activity, notable recent high-profile incidents that have impacted organizations globally, and the overall threat severity outlook for the next 30–60 days. Write in clear, non-technical language suitable for a CISO or board-level audience.
```

2. Identify top threats relevant to our industry and region
```
Identify the top 5 cybersecurity threats most relevant to an organization in the {Industry} sector operating in {Region}. For each threat, provide: the threat category (ransomware, espionage, phishing, supply chain, DDoS, etc.), the primary threat actors driving it, recent incidents impacting similar organizations, the potential business impact (financial, operational, reputational, regulatory), and a current severity rating (Critical / High / Medium). Prioritize by both likelihood and impact.
```

3. Profile the most active threat actors targeting our sector
```
Profile the top 3 threat actors currently most active against organizations in the {Industry} sector. For each actor, provide an executive-friendly summary covering: who they are and who sponsors or motivates them, what kind of attacks they conduct, what they are typically after (data, disruption, financial gain), any recent activity in the last 60 days, and one key action our organization should take to reduce exposure to this specific actor. Avoid deep technical jargon — write for a non-technical senior leader.
```

4. Highlight critical vulnerabilities with active exploitation relevance
```
Identify the top 5 vulnerabilities that currently pose the highest risk to organizations in the {Industry} sector based on active exploitation intelligence. For each CVE, provide: a plain-language description, the affected technology (relevant to common enterprise environments), whether ransomware groups or state-sponsored actors are actively exploiting it, patch or mitigation availability, and an urgency rating (Patch Immediately / Patch This Week / Monitor and Plan). Flag any that are listed in the CISA Known Exploited Vulnerabilities catalog.
```

5. Assess our organization's current threat exposure posture
```
Based on the current threat landscape for the {Industry} sector in {Region}, assess our organization's overall threat exposure posture. Identify: the top 3 areas where our defenses most closely align with threat actor targeting and TTPs, any recent threat intelligence signals that suggest our organization or similar organizations are being actively targeted, and our relative exposure compared to industry peers. Provide an overall exposure rating (Low / Moderate / Elevated / High) with a brief justification.
```

6. Translate intelligence into strategic security priorities
```
Based on the threat landscape analysis, top threat actors, and vulnerability intelligence gathered, identify the top 5 strategic security priorities for our organization over the next 90 days. For each priority, provide: a business-outcome-focused title (not a technical task name), the threat it mitigates, the estimated risk reduction impact, and the key stakeholder team responsible. Format as a strategic recommendation list suitable for inclusion in a CISO report or board security update.
```

7. Generate the final executive briefing document
```
Compile all findings from this session into a polished executive threat intelligence briefing document. Structure it as follows: (1) Executive Summary — 3–4 bullet points capturing the most critical takeaways; (2) Current Threat Landscape — key trends and geopolitical context; (3) Top Threats to Our Organization — prioritized threat overview; (4) Threat Actor Spotlight — profiles of the top 3 relevant actors; (5) Vulnerability Watch — top CVEs requiring attention; (6) Our Threat Exposure Assessment — current posture rating and rationale; (7) Strategic Recommendations — top 5 priorities for the next 90 days; (8) Appendix — key IOCs and indicators to monitor. Write in professional, concise language appropriate for a senior leadership audience. The briefing should be suitable for presentation in a board-level security review.
```

---

## How To Create This Promptbook In Security Copilot

1. Start by running step 1 with no modifications — it provides global context that grounds subsequent prompts.
2. Replace `{Industry}` with your organization's sector (e.g., `Financial Services`, `Healthcare`, `Energy`) and `{Region}` with your geography (e.g., `Europe`, `Middle East`, `North America`) in steps 2, 3, and 5.
3. Run each step sequentially — Security Copilot builds cumulative context that enriches the final briefing in step 7.
4. Select all prompts to include them in the promptbook.
5. Enter the promptbook name: **Executive Threat Intelligence Briefing** and add a description.
6. Choose sharing scope (personal, team, or organization).
7. Select **Create**, verify the success message, and open the promptbook from the library.
