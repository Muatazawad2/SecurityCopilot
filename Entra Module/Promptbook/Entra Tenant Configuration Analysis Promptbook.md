# Entra Tenant Configuration Analysis

**Developer**: Dr Muataz Awad

**Description**: Analyze your Entra tenant configuration and provide comprehensive information about tenant identity, size, licensing, domains, authentication methods, and overall health. Results provide an operational overview of your tenant's identity infrastructure. Results may be limited based on query permissions and available audit data.

---

1. Identify core tenant configuration and details

```
Provide detailed information about my Entra tenant including:
- Tenant display name
- Tenant ID
- Technical contact
- Tenant creation date
- Whether users can create new tenants
- Tenant region and data residency
```

2. Analyze tenant licensing and feature availability

```
Review active licenses and subscriptions in my tenant. If there are more than 50 SKUs, return the top 50 by assigned seats. Include:
- Total license count by SKU
- Microsoft Entra P1 and P2 license utilization
- License assignment trends
- Feature usage for each license type
- Premium feature adoption and enablement
```

3. Review user population and organizational structure

```
Provide user population metrics including:
- Total user count
- Active vs. inactive users
- Users by department or organizational unit
- Disabled user accounts
- Unlicensed users
- Guest users and external collaborators
```

4. Analyze group taxonomy and structure

```
Review organizational grouping and structure:
- Total group count by type (Distribution, Security, Microsoft 365)
- Number of ownerless groups
- Nested group structures
- Group membership distribution
- Dynamic membership rule usage
```

5. Verify domain configuration and status

```
List verified and unverified domains currently registered in my tenant (up to 50 domains), including:
- Domain names and verification status
- Primary and secondary domains
- DNS verification records
- Initial tenant domain
- Domain type (verified, unverified, managed)
```

6. Assess authentication methods and MFA adoption

```
Review authentication method configuration and adoption:
- Enabled authentication methods
- Microsoft Authenticator registration rate
- FIDO2 security key adoption
- Phone sign-in adoption
- Registration campaign status and effectiveness
- System preferred authentication configuration
```

7. Check Azure AD P1/P2 feature utilization

```
Analyze premium feature usage and adoption:
- Conditional Access policy count and effectiveness
- PIM (Privileged Identity Management) usage
- Access reviews and remediation completion
- Identity Governance features in use
- Dynamic group usage
- Self-service password reset (SSPR) adoption
```

8. Review service level agreement and health

```
Check tenant SLA and health metrics:
- Microsoft Entra authentication SLA status
- Recent SLA compliance record
- SLA breach history
- Tenant authentication availability percentage
- Service health alerts and incidents
```

9. Monitor tenant health alerts and operational status

```
Review current health and operational status:
- Active health monitoring alerts
- Users impacted by health alerts
- Recent health alert history
- Recommended remediation actions
- Overall tenant health score
```

10. Summarize tenant configuration and health report

```
Provide a comprehensive tenant analysis report including:
- Tenant identification and configuration summary
- User population metrics (total, departments, licenses)
- Organizational structure and grouping (groups, types)
- Domain configuration status
- Licensing utilization (Entra P1/P2 features in use)
- Authentication posture (MFA adoption, methods enabled)
- SLA compliance and availability metrics
- Overall health status and active alerts
- Key optimization recommendations
- Next steps for tenant health improvement
```

---

## How To Create This Promptbook In Security Copilot

1. Start by using each prompt directly to validate the output quality.
2. Select all prompts to include them in the promptbook.
3. Enter the promptbook name and description.
4. Choose how you want to share the promptbook.
5. Select Create, verify the success message, and open the promptbook from the library.
