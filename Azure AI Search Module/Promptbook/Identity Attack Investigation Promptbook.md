# Identity Attack Investigation

**Developer**: Dr Muataz Awad

**Description**: A structured, multi-step promptbook for investigating identity-based attacks including password spray and token theft, using Microsoft playbooks indexed in Azure AI Search. This workflow guides analysts through identifying attack type, scoping affected identities, containing the threat, and remediating compromised accounts and tokens — drawing from the Microsoft Password Spray and Token Theft investigation playbooks. Results may be limited if the identity attack playbooks are not present in the connected index or the Azure AI Search plugin is not configured.

---

1. Identify the attack type and initial indicators

```
Search Azure AI Search for the indicators and detection signals that distinguish a password spray attack from a token theft attack. Based on the alerts and behaviors observed in this incident, identify which attack type is most likely and what the key differentiating signals are.
```

2. Scope affected accounts and compromised identities

```
Using Azure AI Search, find the investigation steps for identifying all accounts affected by {attack_type} (password spray or token theft). What queries, logs, and data sources should be used to determine the full scope of compromised or targeted accounts?
```

3. Retrieve detection signals and alert analysis guidance

```
Search Azure AI Search for the specific detection signals, Microsoft Entra ID alerts, and Defender XDR alert types associated with {attack_type}. How should analysts triage and validate these alerts to confirm a true positive?
```

4. Look up immediate containment steps for compromised accounts

```
Using Azure AI Search, find the immediate containment steps for accounts compromised in a {attack_type} attack. What actions should be taken — including account disablement, session revocation, token invalidation, and Conditional Access policy enforcement?
```

5. Retrieve token revocation and session termination procedures

```
Search Azure AI Search for procedures to revoke compromised tokens and terminate active sessions after a token theft or credential-based attack. What Microsoft Entra ID and Defender XDR steps are required to invalidate refresh tokens, access tokens, and persistent refresh tokens (PRTs)?
```

6. Find credential reset and re-authentication requirements

```
Using Azure AI Search, find the credential reset procedures and re-authentication requirements for accounts affected by {attack_type}. What must be completed before a user's account is reinstated, and what MFA or Conditional Access policies should be enforced?
```

7. Look up hunting queries for post-compromise activity

```
Search Azure AI Search for hunting queries and investigation steps to detect post-compromise activity following a {attack_type}. What should analysts look for in terms of lateral movement, data access, mailbox forwarding rules, OAuth consent grants, or persistence mechanisms established by the attacker?
```

8. Retrieve hardening and prevention recommendations

```
Using Azure AI Search, find the hardening and prevention recommendations from the Microsoft identity attack playbooks. What Conditional Access policies, MFA configurations, token protection settings, and monitoring rules does Microsoft recommend to prevent password spray and token theft attacks?
```

9. Generate a structured identity attack response summary

```
Based on all information retrieved from Azure AI Search in this session, produce a structured identity attack response plan for a {attack_type} incident that includes:
- Attack type confirmed and key indicators observed
- Scope: number and list of affected accounts
- Immediate containment actions taken
- Token revocation and session termination steps
- Credential reset and MFA enforcement requirements
- Post-compromise hunting findings
- Hardening recommendations to prevent recurrence
Format the output as an incident response summary suitable for both SOC analysts and management reporting.
```

<!-- Repository maintenance marker -->
