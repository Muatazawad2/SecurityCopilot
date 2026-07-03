# Security Knowledge Base Investigation

**Developer**: Dr Muataz Awad

**Description**: A structured, multi-step promptbook for systematically querying an organizational security knowledge base connected via Azure AI Search. This workflow helps analysts identify relevant policies, procedures, compliance requirements, and historical context during a security investigation. Results may be limited if the index does not contain content matching the query, or if the Azure AI Search plugin is not configured.

---

1. Retrieve the relevant security policy for the investigation topic

```
Search Azure AI Search for the security policy or procedure most relevant to {investigation_topic} (e.g. unauthorized access, data exfiltration, malware). Summarize the key controls, obligations, and response requirements defined in the policy.
```

2. Look up applicable incident classification criteria

```
Using Azure AI Search, find our incident classification criteria and severity definitions. Based on the current investigation context, identify which severity level applies to {incident_description} and what the corresponding SLA and response obligations are.
```

3. Retrieve containment and triage procedures

```
Search Azure AI Search for containment and triage procedures relevant to this type of incident. List the recommended immediate actions an analyst should take, in priority order.
```

4. Identify applicable compliance and regulatory requirements

```
Using Azure AI Search, identify any compliance or regulatory obligations triggered by this incident, including notification timelines, documentation requirements, and stakeholder reporting obligations relevant to {incident_type} (e.g. data breach, insider threat).
```

5. Search for historical incident context or case studies

```
Search Azure AI Search for any documented historical incidents or case studies related to {attack_technique_or_incident_type}. Summarize lessons learned, root causes identified, and any corrective actions that were implemented.
```

6. Retrieve KQL queries or detection logic from the knowledge base

```
Using Azure AI Search, find any stored KQL queries or detection logic related to {investigation_topic}. List the queries along with a brief description of what each one detects.
```

7. Look up escalation and communication requirements

```
Search Azure AI Search for the escalation procedure and communication requirements for this incident. Identify who should be notified, at what thresholds, and what information must be included in notifications.
```

8. Generate a grounded investigation summary

```
Based on all the information retrieved from Azure AI Search in this session, provide a comprehensive investigation knowledge summary that includes:
- Applicable policy and compliance obligations
- Incident severity classification and SLA
- Recommended containment and response actions
- Escalation and notification requirements
- Relevant historical context or lessons learned
- Any KQL queries or detection artifacts retrieved
Format the output as a structured analyst brief.
```

<!-- Repository maintenance marker -->
