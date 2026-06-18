# Entra Incident Response Investigation

**Developer**: Dr Muataz Awad

**Description**: Investigate security incidents involving compromised accounts, suspicious activities, or unauthorized access. Work through the user's risk profile, sign-in patterns, activity anomalies, permissions and roles, and recent audit events to determine the scope and impact of the incident. Results may be limited if audit logs are not retained or required investigation permissions are unavailable.

---

1. Assess user risk profile and current status

```
Determine if the user {UserPrincipalName} is currently flagged as risky. Display detailed risk information including their current risk level, active risk indicators, recent sign-in attempts, and risk score trend.
```

2. Analyze risky sign-in patterns and anomalies

```
Show all risky sign-ins from user {UserPrincipalName}. For each risky sign-in, identify what risk factors contributed to the flagging, including location anomalies, impossible travel patterns, and unusual authentication methods.
```

3. Review user sign-in activity timeline

```
Provide a detailed summary of all sign-in activity for user {UserPrincipalName} in the last 30 days. Include sign-in timestamps, applications accessed, devices used, locations, and any authentication challenges or failures. Highlight any unusual patterns or spikes.
```

4. Check user permissions and role assignments

```
Look up all permissions and roles assigned to user {UserPrincipalName}. Include direct role assignments, transitive roles, group memberships, and any privileged access assignments through PIM.
```

5. Review audit logs for suspicious activities

```
Show all audit log entries for user {UserPrincipalName} in the last 7 days. Include administrative actions, role modifications, group membership changes, policy updates, and any other activities that may indicate compromise or unauthorized changes.
```

6. Identify risky application access

```
Show all applications that user {UserPrincipalName} has signed into or been granted permissions to. Identify if any of these applications are flagged as risky or have highly privileged permissions assigned.
```

7. Assess device and location context

```
Analyze the devices and locations from which user {UserPrincipalName} has accessed systems. Identify any non-compliant devices, unusual operating systems, impossible travel patterns, or sign-ins from outside normal geographic locations.
```

8. Summarize incident investigation findings

```
Provide a comprehensive incident investigation summary for user {UserPrincipalName} including:
- Overall risk verdict (Low, Medium, High, or Critical) with justification
- Scope of potential impact (affected resources, groups, applications)
- Timeline of suspicious activities observed
- Key risk indicators and anomalies detected
- Recommended immediate investigation or containment steps
- Whether escalation to security operations is warranted
```

---

## How To Create This Promptbook In Security Copilot

1. Start by using each prompt directly to validate the output quality, replacing {UserPrincipalName} with the account under investigation.
2. Select all prompts (as shown in the screenshot) to include them in the promptbook.
3. Enter the promptbook name and description.
4. Choose how you want to share the promptbook.
5. Select Create, verify the success message, and open the promptbook from the library.
