# Entra ID Governance Prompt Samples

**Developer**: Dr Muataz Awad

**Description**: A reusable set of Microsoft Entra ID Governance prompt samples for access reviews, entitlement management, PIM, PIM write actions, and lifecycle workflow operations. Replace placeholders with your environment values. Outputs depend on governance configuration, workflow history, and role entitlements.

## Access Reviews

### Access review exploration and management

- Show me the top 10 pending access reviews.
- Get access review details for {AccessReviewName}.
- Who are the reviewers for the {AccessReviewName} review?

### Access review decision analysis

- Who approved or denied access in the {AccessReviewName} review?
- List reviews where {ReviewerDisplayName} is the assigned reviewer.
- Which access review decisions overrode AI-suggested actions?

## Entitlement Management

### Catalog and access package management

- What resources are in catalog "{CatalogName}"?
- How many catalogs are in the tenant?
- Which access packages are in catalog "{CatalogName}"?
- How many access packages are in the tenant?
- What resource role scopes are in access package "{AccessPackageName}"?
- Find all access packages where the name contains "{SearchTerm}"?

### User assignments and connected organizations

- What access package assignments does "{UserDisplayName}" have?
- Who are the external users of connected organization "{ConnectedOrganizationName}"?
- Who are the sponsors for connected organization "{ConnectedOrganizationName}"?
- What custom extensions does catalog "{CatalogName}" have?

## Privileged Identity Management (PIM)

### PIM role assignment queries

- Which PIM roles are currently assigned to "{UserDisplayName}"?
- Which PIM eligible roles are assigned to "{UserDisplayName}"?
- Which PIM active roles are assigned to "{UserDisplayName}"?
- Who has PIM eligible assignment of {Specific Role}?
- Who has PIM active assignment of a {Specific role}?

## PIM Write Actions

- I want to perform {the desired task}, help me activate a role so that I can perform the desired action.
- I am done with my investigation or {desired task}, deactivate my access.
- I accidentally activated a role, roll back my changes.

## Lifecycle Workflows

### Create and configure workflows

- Create a lifecycle workflow for new hires in the {DepartmentName} department that sends a welcome email and a TAP and adds them to the "{TargetGroupName}" group. Also, provide the option to enable the schedule of the workflow.
- List all lifecycle workflows in my tenant.
- List all the supported workflow templates for creating a new workflow.
- What are my lifecycle workflow settings?
- Which leaver tasks can I automate with lifecycle workflows?
- What templates can be used for creating a mover workflow?

### Analyze active workflow list

- Get my lifecycle workflows with the name {WorkflowName}.
- List all mover workflows in my tenant.
- List all the deleted lifecycle workflows in my tenant.
- List all disabled lifecycle workflows in my tenant.
- Show me the details of disabled workflow {WorkflowName}.

### Troubleshoot workflow runs

- Summarize the runs for {WorkflowName} in the last 7 days.
- How many times did the workflow run in the last 24 hours.
- Which users failed to be processed by this workflow in the last 7 days?
- Which tasks failed for {WorkflowName} in the last 7 days?
- Show me the user processing results summary for {WorkflowName} in the last 7 days.
- How many workflows were processed in the last 7 days?
- How many users were successfully processed by workflows in the last 14 days?
- Which workflows have been run the most in the last 7 days?
- Which tasks failed the most in the last 30 days?
- Which workflows failed the most in the last 7 days?
- How many mover workflows were executed in the last 30 days?

### Compare workflow versions

- List all workflow versions for {WorkflowName}.
- Show me who last modified {WorkflowName} and when.
- Show me the details of {version #} for this workflow.
- What changed in the last version of this workflow?
- Compare the last two versions of this workflow.
- Compare {version #} and {version #} of this workflow.

## Session Hygiene

- Activate the {required role} so that I can perform {the desired task}.
- I am done with my investigation or {desired task}, deactivate my access.
