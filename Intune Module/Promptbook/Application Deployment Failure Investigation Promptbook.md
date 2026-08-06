# Application Deployment Failure Investigation

**Description**: Investigate a failed Microsoft Intune application deployment by defining the affected scope, reviewing assignment and applicability, analyzing installation evidence, comparing successful and failed devices, and producing a staged recovery plan. This promptbook does not modify application assignments or initiate installations.

## Required Input

- `{AppName}`: Application display name in Intune
- `{Platform}`: Target platform, such as Windows, Android, iOS/iPadOS, or macOS

## Optional Input

- `{DeviceNameOrId}`: A representative failed device
- `{UserPrincipalName}`: Affected user's UPN
- `{ErrorCode}`: Installation or reporting error code
- `{NumberOfDays}`: Investigation window; default to 7 when omitted
- `{TicketId}`: Incident, change, or support ticket identifier

## Prerequisites

- Microsoft Security Copilot and the Microsoft Intune source are enabled.
- The operator can view the application, assignments, installation status, users, and devices in scope.
- Platform-specific logs or endpoint evidence might require additional authorized tools.

Run the prompts in order in one session. Preserve platform differences and do not apply Windows-specific installation concepts to other application types.

---

1. Establish the application deployment baseline

```text
Using Microsoft Intune data, identify the application {AppName} for {Platform}. Report its display name, application type, publisher, version, deployment intent, assignment status, last modification time, and other available deployment metadata. If multiple applications match, list them and stop for clarification. Label unavailable fields and do not infer package configuration.
```

2. Scope deployment outcomes

```text
For {AppName}, summarize installation outcomes during the last {NumberOfDays} days, using 7 days when no value is provided. Report successful, failed, pending, not installed, not applicable, and unknown results when available. Break down the results by user versus device assignment and by relevant platform or operating system version. Identify whether the issue is isolated, cohort-specific, or widespread, and state any data coverage limitations.
```

3. Validate assignments and applicability

```text
Review the assignments for {AppName}. Include required, available, uninstall, and other applicable intents; included and excluded groups; assignment filters; user or device context; and availability or deadline settings when visible. For {DeviceNameOrId} or {UserPrincipalName} when provided, trace why the target should or should not receive the application. Identify evidence of exclusion, conflicting intent, unsupported platform, unmet applicability, or missing group membership.
```

4. Analyze failed installation evidence

```text
For failed deployments of {AppName}, group the available Intune status details and error codes by frequency. Explain {ErrorCode} when provided, including its documented meaning and validation steps. For {DeviceNameOrId} or {UserPrincipalName}, report the latest installation state, timestamp, and status detail. Separate Microsoft-documented error meaning from the root cause demonstrated by tenant or endpoint evidence.
```

5. Review package rules and relationships

```text
Review the available configuration for {AppName} that can determine installation success. Depending on the application type, examine requirements, detection rules, dependencies, supersedence, install and uninstall commands, architecture, operating system minimums, restart behavior, and return-code handling. Identify misconfiguration or mismatch only where evidence is available; otherwise list the exact configuration that an administrator must verify.
```

6. Compare successful and failed targets

```text
Compare representative successful and failed targets for {AppName}. Focus on platform and operating system version, architecture, ownership, management and check-in state, group membership, application intent, dependency state, and relevant policy differences. If {DeviceNameOrId} is provided, use it as the failed target. Report supported differences and rank which could explain the deployment failure.
```

7. Assess endpoint readiness and evidence gaps

```text
Assess whether device readiness or stale reporting contributes to failures for {AppName}. Review last check-in, available storage or system evidence when present, pending restart indicators when present, management state, and prerequisite application state. Create a minimal plan for collecting missing platform-specific logs or Device query evidence. Do not claim endpoint conditions that are not present in this session.
```

8. Create a staged recovery plan

```text
Create a staged recovery plan for {AppName}. Prioritize corrections that address the supported cause, define a small validation cohort, specify success and failure criteria, describe monitoring and rollback, and identify the approval owner for assignment or package changes. Include separate handling for already-successful targets to avoid disruption. Do not modify assignments, reinstall applications, or claim that a deployment was retried.
```

9. Produce the application deployment report

```text
Create a final application deployment failure investigation report for {AppName} and ticket {TicketId} when provided. Include:
- Application identity, type, version, and target platform
- Assignment and applicability summary
- Deployment outcome counts and affected scope
- Error-code and status clusters
- Package-rule, dependency, and supersedence findings when applicable
- Successful-versus-failed comparison
- Confirmed cause or ranked hypotheses
- Staged recovery, rollback, and validation plan
- Evidence gaps and responsible owners
- Final disposition: Package configuration issue, Assignment issue, Applicability issue, Endpoint prerequisite issue, Reporting delay, External dependency, or Undetermined

Support each conclusion with observed evidence and do not report recovery as complete without fresh installation status.
```

---

## Completion Criteria

- [ ] Unique application and platform confirmed
- [ ] Failure scope and status clusters documented
- [ ] Assignment and applicability traced
- [ ] Package rules and relationships reviewed
- [ ] Successful and failed targets compared
- [ ] Cause confirmed or hypotheses ranked
- [ ] Staged recovery and rollback approved
- [ ] Fresh deployment results used to validate recovery

## Official References

- [Monitor application information and assignments with Intune](https://learn.microsoft.com/en-us/intune/app-management/monitor-assignments)
- [Troubleshoot app installation issues](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/troubleshoot-app-install)

---

**Developer**: Dr Muataz Awad

<!-- Repository maintenance marker -->
