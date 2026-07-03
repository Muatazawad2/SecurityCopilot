# Ransomware Investigation and Response

**Developer**: Dr Muataz Awad

**Description**: A structured, multi-step promptbook for investigating and responding to ransomware incidents using Microsoft playbooks and field guides indexed in Azure AI Search. This workflow guides SOC analysts and incident responders through detection signals, containment, eradication, recovery, and hardening — drawing from the Microsoft Defender XDR ransomware field guides and Microsoft Incident Response best practices. Results may be limited if the ransomware playbooks are not present in the connected index or the Azure AI Search plugin is not configured.

---

1. Identify early detection signals and pre-ransomware indicators

```
Search Azure AI Search for early detection signals and pre-ransomware indicators described in the Microsoft Defender XDR field guides. What behaviors, alerts, and patterns should analysts look for that indicate a ransomware attack may be in progress or imminent?
```

2. Retrieve the Microsoft IR ransomware response framework and phases

```
Using Azure AI Search, find the Microsoft Incident Response approach and best practices for ransomware. Summarize the recommended response framework, key phases, and strategic decisions that should be made in the first hour of a ransomware incident.
```

3. Look up initial containment steps for ransomware

```
Search Azure AI Search for the initial containment steps for a ransomware attack. What immediate actions should be taken to stop the spread — including which systems to isolate, network segments to segment, and accounts to disable? Include any required approvals before taking containment actions.
```

4. Retrieve lateral movement detection and hunting guidance

```
Using Azure AI Search, find guidance on detecting lateral movement associated with human-operated ransomware. What Microsoft Defender XDR queries, signals, or behavioral patterns indicate an attacker is moving laterally through the environment prior to deploying ransomware?
```

5. Find eradication and cleanup procedures

```
Search Azure AI Search for eradication procedures after a ransomware attack. What steps are required to remove the ransomware payload, eliminate attacker persistence mechanisms, clean compromised accounts and credentials, and verify the environment is free of the threat before recovery begins?
```

6. Retrieve recovery procedures and restoration guidance

```
Using Azure AI Search, find the recovery procedures for a ransomware attack. What is the recommended order of system restoration, how should backups be validated before use, and what conditions must be met before systems are returned to production?
```

7. Look up Defender XDR investigation and hunting queries

```
Search Azure AI Search for Microsoft Defender XDR investigation steps and hunting queries for ransomware. List any KQL queries, advanced hunting steps, or investigation workflows described in the field guides that can help identify the attack scope, compromised accounts, and affected devices.
```

8. Retrieve hardening and prevention recommendations

```
Using Azure AI Search, find the hardening and prevention recommendations from the Microsoft ransomware field guides and best practices. What security controls, configurations, and architectural changes does Microsoft recommend to reduce ransomware risk and improve resilience?
```

9. Generate a structured ransomware response plan

```
Based on all information retrieved from Azure AI Search in this session, produce a comprehensive ransomware incident response plan that includes:
- Summary of detected indicators and attack scope
- Phase 1: Immediate containment actions (first 30 minutes)
- Phase 2: Investigation and lateral movement analysis
- Phase 3: Eradication steps and persistence removal
- Phase 4: Recovery sequence and validation criteria
- Phase 5: Post-incident hardening recommendations
- Key Microsoft Defender XDR investigation queries to run
Format the output as a structured response plan that a SOC team can execute step-by-step.
```

<!-- Repository maintenance marker -->
