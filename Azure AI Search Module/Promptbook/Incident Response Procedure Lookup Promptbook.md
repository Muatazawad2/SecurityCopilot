# Incident Response Procedure Lookup

**Developer**: Dr Muataz Awad

**Description**: A structured, multi-step promptbook for retrieving your organization's incident response procedures from a knowledge base connected via Azure AI Search. This workflow guides SOC analysts through finding the correct playbook, containment steps, escalation paths, and documentation requirements for a specific incident type. Results may be limited if response procedures are not present in the connected index or the Azure AI Search plugin is not configured.

---

1. Identify the incident type and retrieve the primary playbook

```
Search Azure AI Search for the incident response playbook or runbook for {incident_type} (e.g. ransomware, phishing, business email compromise, insider threat, data breach). Summarize the playbook overview, the scope of the response, and the key phases covered.
```

2. Retrieve immediate triage and initial response steps

```
Using Azure AI Search, find the immediate triage and initial response steps for {incident_type}. List the first actions the analyst on duty must take within the first 15 minutes of detection, in order of priority.
```

3. Look up containment procedures

```
Search Azure AI Search for the containment procedures for {incident_type}. List all recommended containment actions, including which systems, accounts, or network segments should be isolated, and what approvals are required before taking containment actions.
```

4. Find eradication and recovery procedures

```
Using Azure AI Search, retrieve the eradication and recovery steps for {incident_type}. What actions are required to remove the threat from the environment, restore affected systems, and verify the environment is clean before returning to normal operations?
```

5. Retrieve escalation procedure and key contacts

```
Search Azure AI Search for the escalation procedure and key contact list for a {incident_severity} severity {incident_type} incident. Who must be notified, at what time thresholds, and through which channels? Include any out-of-hours contact information if available.
```

6. Look up external notification and legal obligations

```
Using Azure AI Search, find any external notification requirements triggered by {incident_type}. Include regulatory notification timelines, law enforcement engagement criteria, customer or partner communication obligations, and any legal holds that must be placed.
```

7. Retrieve evidence collection and chain of custody requirements

```
Search Azure AI Search for evidence collection procedures and chain of custody requirements applicable to {incident_type}. What artifacts must be collected, how must they be preserved, and what documentation is required to maintain forensic integrity?
```

8. Find post-incident review and documentation requirements

```
Using Azure AI Search, retrieve the post-incident review process and documentation requirements for {incident_type}. What reports must be filed, who reviews them, what is the timeline for the post-incident review meeting, and what lessons-learned artifacts must be produced?
```

9. Generate a structured incident response action plan

```
Based on all procedures retrieved from Azure AI Search in this session for a {incident_type} incident of {incident_severity} severity, produce a structured incident response action plan that includes:
- Incident classification and priority
- Immediate triage actions (first 15 minutes)
- Containment steps (with required approvals)
- Eradication and recovery steps
- Escalation contacts and notification timeline
- External regulatory notification obligations
- Evidence collection requirements
- Post-incident review timeline and deliverables
Format the output as a numbered action plan that an analyst can follow step-by-step.
```

<!-- Repository maintenance marker -->
