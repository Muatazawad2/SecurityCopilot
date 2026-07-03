# Azure AI Search Sample Prompts

**Developer**: Dr Muataz Awad

**Description**: A reusable set of Microsoft Security Copilot prompt samples for querying an organizational knowledge base connected via the Azure AI Search plugin. All prompts require the Azure AI Search plugin to be configured and active. Replace placeholders `{in curly braces}` with your actual values. Always include **"Azure AI Search"** in the prompt to invoke the plugin.

---

## Security Policies and Compliance

### General policy lookup

- Search Azure AI Search for our password policy and summarize the key requirements.
- What does Azure AI Search say about our acceptable use policy?
- Using Azure AI Search, find our data classification policy and list the classification levels.
- Search Azure AI Search for our remote access security policy.
- What are the key controls in our information security policy according to Azure AI Search?

### Compliance and regulatory requirements

- Search Azure AI Search for requirements related to {regulation_name} compliance (e.g. ISO 27001, NIST, CIS).
- Using Azure AI Search, what does our policy say about data retention and deletion?
- Find any references to PCI DSS requirements in Azure AI Search.
- Search Azure AI Search for our GDPR data handling obligations.
- What does Azure AI Search say about breach notification requirements?

---

## Incident Response Runbooks and Procedures

### Incident response procedure lookup

- Search Azure AI Search for the incident response runbook for {incident_type} (e.g. ransomware, phishing, data breach).
- Using Azure AI Search, what are the containment steps for a compromised user account?
- Find the escalation procedure for a P1 security incident in Azure AI Search.
- Search Azure AI Search for our security incident classification criteria.
- What are the first 5 steps I should take according to Azure AI Search for responding to a malware outbreak?

### Triage and investigation guidance

- Using Azure AI Search, find investigation steps for a user with multiple failed sign-in attempts.
- Search Azure AI Search for guidance on triaging alerts from {tool_name} (e.g. Microsoft Defender, Sentinel).
- What does Azure AI Search say about how to determine if a phishing email is part of a broader campaign?
- Find our threat hunting procedures in Azure AI Search for lateral movement detection.
- Search Azure AI Search for the triage checklist for identity-based attacks.

---

## SOC Runbooks and Operational Procedures

### SOC operations

- Search Azure AI Search for our SOC shift handover procedure.
- What does Azure AI Search say about the alert triage SLA requirements for high-severity alerts?
- Using Azure AI Search, find the on-call escalation contacts and procedures.
- Search Azure AI Search for the procedure to add a new detection rule to Sentinel.
- What does Azure AI Search say about the process for closing a false positive alert?

### Tool-specific procedures

- Search Azure AI Search for the procedure to create a new watchlist in Microsoft Sentinel.
- Using Azure AI Search, find the approved KQL query patterns for detecting brute force attacks.
- Search Azure AI Search for guidance on configuring Defender for Endpoint isolation policies.
- Find any runbooks in Azure AI Search related to Microsoft Entra ID Conditional Access policy updates.

---

## KQL Library

### Query discovery

- Search Azure AI Search for KQL queries related to {query_topic} (e.g. anomalous login detection, data exfiltration).
- Using Azure AI Search, find pre-approved KQL queries for hunting lateral movement.
- Search Azure AI Search for any stored queries that detect privilege escalation in Azure AD audit logs.
- What KQL queries does Azure AI Search have for correlating sign-in risk with Sentinel incidents?
- Find KQL queries for detecting impossible travel sign-ins in Azure AI Search.

---

## Security Awareness and Training

### Onboarding and procedures

- Using Azure AI Search, summarize the security onboarding requirements for new SOC analysts.
- Search Azure AI Search for the procedure to request access to privileged systems.
- What does Azure AI Search say about how to handle a suspected insider threat?
- Find the security awareness training requirements in Azure AI Search.
- Search Azure AI Search for our clean desk and screen lock policy.

---

## Threat Intelligence Reference

### Internal threat intelligence

- Search Azure AI Search for any documented threat actor profiles relevant to our industry.
- Using Azure AI Search, find historical incident summaries related to {attack_technique} (e.g. credential stuffing, supply chain attacks).
- Search Azure AI Search for our known threat indicators or IOC blocklists.
- What does Azure AI Search say about previous incidents involving the {threat_actor} group?

---

## Contextual Investigation Support

### Active investigation grounding

- I am investigating a potential ransomware incident. Search Azure AI Search for our ransomware response playbook and summarize the key actions I should take immediately.
- Search Azure AI Search for investigation steps that I should follow for an incident involving multiple failed sign-in attempts by user {UserPrincipalName}.
- Using Azure AI Search, look up our data breach response procedure and list the stakeholder notification requirements.
- Search my Azure AI Search index for multifactor authentication policies and summarize enforcement requirements.
- A user has reported a suspicious email. Using Azure AI Search, find the phishing reporting and investigation procedure I should follow.

<!-- Repository maintenance marker -->
