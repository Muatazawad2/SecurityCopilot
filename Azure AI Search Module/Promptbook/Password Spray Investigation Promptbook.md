# Password Spray Investigation

**Developer**: Dr Muataz Awad

**Description**: A structured, multi-step promptbook for investigating password spray attacks using the Microsoft Password Spray Investigation Playbook indexed in Azure AI Search. This workflow guides analysts through identifying spray patterns, scoping compromised accounts, investigating post-compromise activity, containing the threat, and hardening the environment. Results may be limited if the password spray playbook is not present in the connected index or the Azure AI Search plugin is not configured.

---

1. Identify password spray indicators and confirm the attack

```
Search Azure AI Search for the indicators and detection signals that confirm a password spray attack. What sign-in log patterns, Microsoft Entra ID alerts, and Defender XDR signals are described in the password spray playbook as evidence of an active or completed spray campaign?
```

2. Determine the spray pattern and attacker infrastructure

```
Using Azure AI Search, find the investigation steps for analyzing the spray pattern and attacker infrastructure. How should analysts identify the source IPs, ASNs, user agents, and timing patterns used in the spray, and how can this information help scope the full campaign?
```

3. Scope targeted and compromised accounts

```
Search Azure AI Search for the steps to identify all accounts targeted by the spray and determine which accounts were successfully compromised. What sign-in log queries and investigation steps are described for distinguishing accounts that had failed attempts only versus accounts that had a successful sign-in following failed attempts?
```

4. Investigate post-compromise activity on breached accounts

```
Using Azure AI Search, find the investigation steps for identifying post-compromise activity on accounts successfully breached via password spray. What actions — including mailbox access, data downloads, app consent grants, forwarding rule creation, and new device registrations — should be reviewed for each compromised account?
```

5. Check for attacker persistence mechanisms

```
Search Azure AI Search for the persistence mechanisms attackers typically establish after a successful password spray. What should analysts check for — including MFA method changes, trusted device additions, OAuth app consent, inbox rules, and delegated mailbox permissions — that indicate the attacker is attempting to maintain access?
```

6. Retrieve containment steps for compromised accounts

```
Using Azure AI Search, find the containment steps for accounts compromised via password spray. What immediate actions — including password reset, session revocation, MFA re-enrollment, and Conditional Access enforcement — are described in the playbook for stopping attacker access?
```

7. Block the attacking infrastructure

```
Search Azure AI Search for the steps to block the attacking infrastructure identified in a password spray campaign. How should the source IPs, ASNs, and user agents be blocked at the network, identity, and endpoint layers to prevent further spray attempts?
```

8. Retrieve hardening and prevention recommendations

```
Using Azure AI Search, find the hardening and prevention recommendations from the Microsoft password spray playbook. What password policies, MFA configurations, Conditional Access policies, Smart Lockout settings, and monitoring rules does Microsoft recommend to prevent and detect password spray attacks?
```

9. Generate a password spray investigation summary

```
Based on all information retrieved from Azure AI Search in this session, produce a structured password spray investigation report that includes:
- Attack confirmation: indicators observed and spray pattern identified
- Attacker infrastructure: source IPs, ASNs, user agents
- Scope: total accounts targeted, accounts compromised
- Post-compromise activity found per breached account
- Persistence mechanisms discovered and removed
- Containment actions completed
- Infrastructure blocks applied
- Hardening recommendations
Format as a structured incident investigation report for SOC records and management.
```

<!-- Repository maintenance marker -->
