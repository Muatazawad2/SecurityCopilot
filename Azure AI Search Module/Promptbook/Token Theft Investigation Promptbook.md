# Token Theft Investigation

**Developer**: Dr Muataz Awad

**Description**: A structured, multi-step promptbook for investigating token theft attacks using the Microsoft Token Theft Playbook indexed in Azure AI Search. This workflow guides analysts through identifying token theft indicators, determining the token type stolen, scoping affected accounts, revoking compromised tokens, investigating how the tokens were stolen, and hardening token security. Results may be limited if the token theft playbook is not present in the connected index or the Azure AI Search plugin is not configured.

---

1. Identify token theft indicators and confirm the attack

```
Search Azure AI Search for the indicators and detection signals that confirm a token theft attack. What Microsoft Entra ID alerts, sign-in anomalies, and Defender XDR signals are described in the token theft playbook as evidence that tokens have been stolen and replayed by an attacker?
```

2. Determine the token type stolen

```
Using Azure AI Search, find the guidance for determining which type of token was stolen — access token, refresh token, or Primary Refresh Token (PRT). What distinguishes each token type in terms of attacker capability, session persistence, and the investigation and remediation steps required for each?
```

3. Identify the token theft mechanism

```
Search Azure AI Search for the common token theft mechanisms described in the playbook. How are tokens typically stolen — including adversary-in-the-middle (AiTM) phishing proxies, malware, pass-the-cookie attacks, and device compromise — and what evidence should analysts look for to identify which method was used in this incident?
```

4. Scope affected accounts and token replay activity

```
Using Azure AI Search, find the investigation steps for scoping accounts affected by token theft. What sign-in logs, impossible travel signals, token issuance anomalies, and session activity should be reviewed to identify all accounts where stolen tokens were replayed and what actions the attacker took?
```

5. Investigate post-compromise activity

```
Search Azure AI Search for the investigation steps for identifying post-compromise activity conducted using stolen tokens. What actions — including mailbox access, data exfiltration, Teams message access, SharePoint file access, and API calls — should be reviewed, and how can the attacker's session be distinguished from the legitimate user's activity?
```

6. Revoke compromised tokens and terminate attacker sessions

```
Using Azure AI Search, find the procedures for revoking compromised tokens and terminating attacker sessions. What Microsoft Entra ID steps — including revoking refresh tokens, invalidating PRTs, signing out all sessions, and re-issuing compliant tokens — are described in the playbook for cutting off attacker access?
```

7. Check for attacker persistence after token revocation

```
Search Azure AI Search for the persistence mechanisms attackers may establish using stolen token access before revocation. What should analysts check for — including new OAuth app consents, inbox forwarding rules, added authentication methods, registered devices, and delegated permissions — that indicate the attacker has created a backup access path?
```

8. Retrieve hardening and prevention recommendations

```
Using Azure AI Search, find the hardening and prevention recommendations from the Microsoft token theft playbook. What Conditional Access policies, token protection configurations, device compliance requirements, phishing-resistant MFA settings, and monitoring rules does Microsoft recommend to prevent and detect token theft?
```

9. Generate a token theft investigation summary

```
Based on all information retrieved from Azure AI Search in this session, produce a structured token theft investigation report that includes:
- Attack confirmed: indicators observed and token type stolen
- Theft mechanism identified (AiTM, malware, pass-the-cookie, etc.)
- Scope: affected accounts and attacker session activity
- Post-compromise data access and actions taken by attacker
- Token revocation and session termination steps completed
- Persistence mechanisms discovered and removed
- Hardening recommendations to prevent recurrence
Format as a structured incident investigation report for SOC records and management.
```

<!-- Repository maintenance marker -->
