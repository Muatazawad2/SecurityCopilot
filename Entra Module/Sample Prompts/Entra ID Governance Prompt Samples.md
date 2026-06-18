# Entra ID Governance Prompt Samples

**Developer**: Dr Muataz Awad

## Access Reviews

### Access review exploration and management

- Show me the top 10 pending access reviews.
- Get access review details for {AccessReviewName}.
- Who are the reviewers for the Sales App Access Q2 review?

### Access review decision analysis

- Who approved or denied access in the Q2 finance review?
- List reviews where Alex Chen is the assigned reviewer.
- Which access review decisions overrode AI-suggested actions?

## Entitlement Management

### Catalog and access package management

- What resources are in catalog "XYZ"?
- How many catalogs are in the tenant?
- Which access packages are in catalog "XYZ"?
- How many access packages are in the tenant?
- What resource role scopes are in access package "XYZ"?
- Find all access packages where the name contains "Sales"?

### User assignments and connected organizations

- What access package assignments does "User" have?
- Who are the external users of connected organization "XYZ"?
- Who are the sponsors for connected organization "XYZ"?
- What custom extensions does catalog "XYZ" have?

## Privileged Identity Management (PIM)

### PIM role assignment queries

- Which PIM roles are currently assigned to "User"?
- Which PIM eligible roles are assigned to "User"?
- Which PIM active roles are assigned to "User"?
- Who has PIM eligible assignment of {Specific Role}?
- Who has PIM active assignment of a {Specific role}?

## PIM Write Actions

- I want to perform {the desired task}, help me activate a role so that I can perform the desired action.
- I am done with my investigation or {desired task}, deactivate my access.
- I accidentally activated a role, roll back my changes.

## Lifecycle Workflows

### Create and configure workflows

- Create a lifecycle workflow for new hires in the Marketing department that sends a welcome email and a TAP and adds them to the "All Users in My Tenant" group. Also, provide the option to enable the schedule of the workflow.
- List all lifecycle workflows in my tenant.
- List all the supported workflow templates for creating a new workflow.
- What are my lifecycle workflow settings?
- Which leaver tasks can I automate with lifecycle workflows?
- What templates can be used for creating a mover workflow?

### Analyze active workflow list

- Get my lifecycle workflows with the name {workflow name}.
- List all mover workflows in my tenant.
- List all the deleted lifecycle workflows in my tenant.
- List all disabled lifecycle workflows in my tenant.
- Show me the details of disabled workflow {workflow}.

### Troubleshoot workflow runs

- Summarize the runs for {workflow} in the last 7 days.
- How many times did the workflow run in the last 24 hours.
- Which users failed to be processed by this workflow in the last 7 days?
- Which tasks failed for {workflow} in the last 7 days?
- Show me the user processing results summary for {workflow} in the last 7 days.
- How many workflows were processed in the last 7 days?
- How many users were successfully processed by workflows in the last 14 days?
- Which workflows have been run the most in the last 7 days?
- Which tasks failed the most in the last 30 days?
- Which workflows failed the most in the last 7 days?
- How many mover workflows were executed in the last 30 days?

### Compare workflow versions

- List all workflow versions for {workflow}.
- Show me who last modified {workflow} and when.
- Show me the details of {version #} for this workflow.
- What changed in the last version of this workflow?
- Compare the last two versions of this workflow.
- Compare {version #} and {version #} of this workflow.

## Session Hygiene

- Activate the {required role} so that I can perform {the desired task}.
- I am done with my investigation or {desired task}, deactivate my access.
