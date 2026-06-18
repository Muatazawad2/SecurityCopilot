# Entra Internet and Private Access Prompt Samples

Source scenario:
- https://learn.microsoft.com/en-us/entra/security-copilot/entra-internet-access-private-access-scenarios

**Developer**: Dr Muataz Awad

**Description**: A reusable set of Microsoft Entra Internet Access and Private Access prompt samples for Global Secure Access traffic analysis, threat investigation, access pattern review, and cross-tenant monitoring. Replace placeholders with your tenant values. Results depend on network traffic telemetry and licensed feature availability.

## Global Secure Access

### Monitor data consumption and bandwidth usage

- Show the top 5 users with the highest data consumption in the last day.
- List the top 10 accessed applications names in the last week based on network traffic logs.

### Investigate blocked traffic and security threats

- Show all blocked traffic for user {UserPrincipalName} in the last 24 hours.
- List all applications with high-risk scores accessed in the last 24 hours based on network traffic logs.

### Analyze user application access patterns

- List all application names that user {UserPrincipalName} has accessed in the last 24 hours based on network traffic logs.

### Monitor cross-tenant access and external connections

- Show all cross-tenant traffic to tenant {TargetTenantId} in the last 7 days based on network traffic logs.

## Session Hygiene

- Activate the {required role} so that I can perform {the desired task}.
