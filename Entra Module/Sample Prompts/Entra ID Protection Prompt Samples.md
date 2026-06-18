# Entra ID Protection Prompt Samples

**Developer**: Dr Muataz Awad

**Description**: A reusable set of Microsoft Entra ID Protection prompt samples for risky user triage and workload identity/application risk analysis. Replace placeholders with your tenant values. Results may be limited if required ID Protection data, app risk signals, or permissions are unavailable.

## Risky Users

### List or identify users based on risk

- List all users currently flagged as risky.
- Show users who are currently at risk.
- Identify users who have been marked as risky.
- List all users who have been compromised.
- Show users who are currently considered safe.
- How many users are currently flagged as risky?
- Provide a count of all risky users.

### User-specific risk information

- Determine if this user is currently high risk.
- Display detailed risk information for this user.

### User risk history

- Show the risk history for this user.
- Has this user ever been flagged as risky.
- Was this user previously at risk.

## Application Risk

### Explore risky service principals

- Show me risky apps.
- Are any apps at risk of being malicious or compromised?
- List 5 apps with High Risk Level. Format the table as follows: Display Name | ID | Risk State.
- List the apps with Risk State "Confirmed compromise".
- Show me the details of risky app with ID {ServicePrincipalObjectId} (or App ID {ApplicationId}).

### Explore service principals and applications

- Tell me more about these service principals (from previous response).
- Give me details about service principal with {DisplayName} (or {ServicePrincipalId}).
- Give me a list of owners for these apps?
- Tell me more about the application {DisplayName} or {AppId}.
- Tell me more about these apps (from previous response).

### Permissions and privilege assessment

- Which permissions are granted to the app with ID {ServicePrincipalId} or app ID {AppId}?
- What permissions do the above risky apps have (from previous response)?
- Which permissions granted to this app are highly privileged?

### Unused and expiring apps

- Show me unused apps.
- How many unused apps do I have?
- Which enterprise applications have credentials about to expire?
- Show me service principals with credentials that are expiring soon.
- Show me applications with credentials that are expiring soon.

### External and multitenant exposure

- Show me apps outside my tenant.
- How many apps are from outside my tenant?

## Session Hygiene

- Activate the {required role} so that I can perform {desired task}.
- I am done with my investigation or {desired task}, deactivate my access.
