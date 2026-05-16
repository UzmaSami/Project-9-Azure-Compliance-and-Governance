# ⚖️ Azure Compliance & Governance Framework

## Overview
Enterprise-grade Azure governance implementation
covering Management Groups, Azure Policy, custom
RBAC roles, resource locks, and tagging strategy.

*Engineer:* Uzma Sami | AZ-104 | AZ-500
*Cost:* 100% Free tier compatible
*Region:* UK South

## What Was Built

### Management Groups
- 3 custom management groups created
- Subscription assigned to Security MG
- Hierarchy ready for enterprise scale

### Azure Policy (7 assignments)
- Azure Security Benchmark v3
- Storage encryption enforcement
- Allowed locations (UK South/West only)
- NSG subnet audit
- Require Environment tag
- *2 custom policies* (no public storage, HTTPS only)
- *1 custom initiative* (security baseline)

### Custom RBAC Roles (3 roles)
- Security Auditor (read-only)
- Network Security Engineer (network only)
- Key Vault Security Officer (KV management)

### Resource Locks
- CanNotDelete on all security RGs
- ReadOnly on visibility/monitoring RG

### Tagging
- 6 standard tags on all resources
- Policy enforcing Environment tag
- Full tag coverage achieved

##  Deployment
powershell
.\01-management-groups\create-management-groups.ps1
.\02-azure-policy\assign-builtin-policies.ps1
.\02-azure-policy\create-custom-policy.ps1
.\02-azure-policy\create-policy-initiative.ps1
.\03-rbac\create-custom-roles.ps1
.\04-resource-locks\apply-resource-locks.ps1
.\05-tagging\tag-existing-resources.ps1
.\06-compliance-report\generate-governance-report.ps1


## 👩‍💻 Author
*Uzma Shabbir*
Azure Security Engineer | AZ-104 | AZ-500
Available on Upwork for Azure Security projects
