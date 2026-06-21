# Insider Risk Management (IRM)

Comprehensive resources for investigating insider risk alerts using Microsoft Security Copilot within Microsoft Purview Insider Risk Management. This section provides investigation methodologies, prompt engineering examples, automation guides, and practical workflows for analyzing user risk profiles and security incidents.

---

## Complete IRM Investigation Workflow: Step-by-Step

A comprehensive investigation journey from profiling a user through automated agent triaging.

### Step 1: Profile the User (10-15 min)
**Start here first** - Understand the person & their baseline
- **Use**: [User Investigation Guide](Embedded%20Experiences/User%20Investigation%20Guide.md)
- **What you get**: User background, role, permissions, normal activity baseline
- **Question answered**: What is "normal" for this user?

### Step 2: See Investigation Examples (10-15 min)
**Learn what to look for** - See practical prompt examples
- **Use**: [IRM Sample Prompts](Sample%20Prompts/IRM%20Sample%20Prompts.md)
- **What you get**: Real-world investigation examples, query patterns, use cases
- **Question answered**: What patterns should I investigate?

### Step 3: Learn Investigation Methodology (20-30 min)
**Deepen your technique** - Master the investigation approach
- **Use**: [IRM Investigation Promptbook](Promptbook/IRM%20Investigation%20Promptbook.md)
- **What you get**: Investigation frameworks, behavioral analysis techniques, threat patterns, advanced correlations
- **Question answered**: How do I build sophisticated investigations?

### Step 4: Create Query Plugins (Setup once)
**Build your data access layer** - Query raw IRM data
- **Install first (one-time)**: [Purview IRM KQL Plugin Installation Guide](Plugins/Purview%20IRM%20KQL%20Plugin%20-%20Installation%20Guide.md)
- **Configure**: [Purview IRM Activity KQL Plugin](Plugins/Purview%20IRM%20Activity%20KQL%20Plugin.yaml)
- **What you get**: Direct access to activity logs, timeline data, event details
- **Question answered**: What is the detailed activity data?

### Step 5: Setup Agent for Automation (Setup once)
**Build automated investigation** - Prepare the triage agent
- **Install & configure**: [IRM Triage Agent Setup Guide](Agents/IRM%20Triage%20Agent%20Setup%20Guide.md)
- **What you get**: Agent framework, automation workflows, triage rules
- **Question answered**: How do I automate this investigation process?

### Step 6: Run Triaging with Agent (Ongoing)
**Let the agent work** - Monitor and execute automated triaging
- **Use & monitor**: [Triage Agent Dashboard Guide](Agents/Triage%20Agent%20Dashboard%20Guide.md)
- **What you get**: Automated risk scoring, batch triaging, pattern detection, continuous monitoring
- **Question answered**: What needs immediate attention?

---

## Investigation Progression Checklist

- [ ] Step 1: User profiled (embedded experience)
- [ ] Step 2: Examples reviewed (sample prompts)
- [ ] Step 3: Methodology learned (promptbook)
- [ ] Step 4: Plugins created & configured (KQL)
- [ ] Step 5: Agent setup complete (triage setup)
- [ ] Step 6: Agent running & triaging (dashboard)

---

## Quick Reference: All Resources in Sequence

| Step | Resource | Time | Setup? |
|------|----------|------|--------|
| 1 | User Investigation Guide | 10-15 min | Per investigation |
| 2 | IRM Sample Prompts | 10-15 min | Per investigation |
| 3 | IRM Investigation Promptbook | 20-30 min | Per investigation |
| 4 | KQL Plugin Installation + Configuration | 15-20 min | One-time setup |
| 5 | IRM Triage Agent Setup Guide | 30 min | One-time setup |
| 6 | Triage Agent Dashboard Guide | Ongoing | Continuous use |

---

## Common Scenarios Using This Workflow

**Suspicious Data Exfiltration Alert**
→ Step 1 (profile) → Step 2 (what to look for) → Step 4 (query the data) → Step 6 (let agent triage)

**New Analyst First Investigation**
→ Steps 1-6 (complete workflow to learn)

**Ongoing Monitoring**
→ Step 6 (agent handles it)

**Custom Investigation Needed**
→ Steps 1-3 (manual investigation) + Step 4 (queries)

---

## Key Resources

- [IRM Investigation Promptbook](Promptbook/IRM%20Investigation%20Promptbook.md)
- [IRM Sample Prompts](Sample%20Prompts/IRM%20Sample%20Prompts.md)
- [User Investigation Guide](Embedded%20Experiences/User%20Investigation%20Guide.md)
- [IRM Triage Agent Setup Guide](Agents/IRM%20Triage%20Agent%20Setup%20Guide.md)
- [Triage Agent Dashboard Guide](Agents/Triage%20Agent%20Dashboard%20Guide.md)
- [Purview IRM Activity KQL Plugin](Plugins/Purview%20IRM%20Activity%20KQL%20Plugin.yaml)
- [Purview IRM KQL Plugin Installation Guide](Plugins/Purview%20IRM%20KQL%20Plugin%20-%20Installation%20Guide.md)

<!-- Repository maintenance marker -->
