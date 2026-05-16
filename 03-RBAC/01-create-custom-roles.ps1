# ============================================
# Script: create-custom-roles.ps1
# Purpose: Create custom RBAC roles following
#          least privilege principle
#          Custom roles = advanced Azure skill!
# ============================================

Connect-AzAccount

$subscriptionId = (Get-AzContext).Subscription.Id

Write-Host "Creating Custom RBAC Roles..." `
    -ForegroundColor Cyan

Write-Host @"

Custom RBAC Roles = Least Privilege
Instead of: Contributor (too broad)
Use: Exactly the permissions needed
This is Zero Trust applied to access!

"@ -ForegroundColor Yellow

# ---- Custom Role 1: Security Auditor ----
Write-Host "`n[1/3] Creating Security Auditor Role..." `
    -ForegroundColor Yellow

$securityAuditorRole = @{
    Name             = "UzmaSami Security Auditor"
    Description      = "Custom role by Uzma Sami — Read-only access to security resources. Can view security configurations, policies, and compliance status but cannot make changes."
    Actions          = @(
        "Microsoft.Security/*/read",
        "Microsoft.PolicyInsights/*/read",
        "Microsoft.Network/*/read",
        "Microsoft.KeyVault/vaults/read",
        "Microsoft.OperationalInsights/workspaces/read",
        "Microsoft.Authorization/*/read",
        "Microsoft.Resources/subscriptions/resourceGroups/read"
    )
    NotActions       = @()
    DataActions      = @()
    NotDataActions   = @()
    AssignableScopes = @(
        "/subscriptions/$subscriptionId"
    )
}

$role1 = New-AzRoleDefinition `
    -Role $securityAuditorRole `
    -ErrorAction SilentlyContinue

if ($role1) {
    Write-Host "✅ Security Auditor role created!" `
        -ForegroundColor Green
} else {
    Write-Host "⚠️  Role may already exist" `
        -ForegroundColor Yellow
}

# ---- Custom Role 2: Network Security Engineer ----
Write-Host "`n[2/3] Network Security Engineer Role..." `
    -ForegroundColor Yellow

$networkSecRole = @{
    Name             = "UzmaSami Network Security Engineer"
    Description      = "Custom role by Uzma Sami — Can manage network security resources including NSGs, VNets, and private endpoints. Cannot access compute or data."
    Actions          = @(
        "Microsoft.Network/*/read",
        "Microsoft.Network/networkSecurityGroups/*",
        "Microsoft.Network/virtualNetworks/*",
        "Microsoft.Network/privateEndpoints/*",
        "Microsoft.Network/privateDnsZones/*",
        "Microsoft.Resources/subscriptions/resourceGroups/read",
        "Microsoft.Authorization/*/read"
    )
    NotActions       = @(
        "Microsoft.Compute/*",
        "Microsoft.Storage/*",
        "Microsoft.Sql/*"
    )
    DataActions      = @()
    NotDataActions   = @()
    AssignableScopes = @(
        "/subscriptions/$subscriptionId"
    )
}

$role2 = New-AzRoleDefinition `
    -Role $networkSecRole `
    -ErrorAction SilentlyContinue

if ($role2) {
    Write-Host "✅ Network Security Engineer role created!" `
        -ForegroundColor Green
}

# ---- Custom Role 3: Key Vault Security Officer ----
Write-Host "`n[3/3] Key Vault Security Officer Role..." `
    -ForegroundColor Yellow

$kvSecRole = @{
    Name             = "UzmaSami Key Vault Security Officer"
    Description      = "Custom role by Uzma Sami — Manages Key Vault security settings and access policies. Cannot read secret values — only manage structure."
    Actions          = @(
        "Microsoft.KeyVault/vaults/read",
        "Microsoft.KeyVault/vaults/write",
        "Microsoft.KeyVault/vaults/accessPolicies/write",
        "Microsoft.KeyVault/vaults/privateEndpointConnections/*",
        "Microsoft.Resources/subscriptions/resourceGroups/read",
        "Microsoft.Authorization/*/read"
    )
    NotActions       = @()
    DataActions      = @(
        "Microsoft.KeyVault/vaults/keys/read",
        "Microsoft.KeyVault/vaults/certificates/read"
    )
    NotDataActions   = @(
        "Microsoft.KeyVault/vaults/secrets/*"
    )
    AssignableScopes = @(
        "/subscriptions/$subscriptionId"
    )
}

$role3 = New-AzRoleDefinition `
    -Role $kvSecRole `
    -ErrorAction SilentlyContinue

if ($role3) {
    Write-Host "✅ KV Security Officer role created!" `
        -ForegroundColor Green
}

# Show all custom roles
Write-Host "`n=== CUSTOM RBAC ROLES ===" `
    -ForegroundColor Cyan
Get-AzRoleDefinition -Custom |
    Select-Object Name, Description |
    Format-Table -AutoSize -Wrap

