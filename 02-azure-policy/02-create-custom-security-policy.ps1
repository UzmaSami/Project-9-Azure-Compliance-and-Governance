
# ============================================
# Script: create-custom-policy.ps1
# Purpose: Create CUSTOM Azure Policy
#          This proves advanced policy skills!
#          Custom policy = premium Upwork rates
# ============================================

Connect-AzAccount

$subscriptionId = (Get-AzContext).Subscription.Id
$scope          = "/subscriptions/$subscriptionId"

Write-Host "Creating Custom Security Policy..." `
    -ForegroundColor Cyan

# ---- Custom Policy 1: No Public Storage ----
Write-Host "`n[1/2] Custom: Block Public Storage..." `
    -ForegroundColor Yellow

$noPublicStorageRule = @{
    if     = @{
        allOf = @(
            @{
                field  = "type"
                equals = "Microsoft.Storage/storageAccounts"
            },
            @{
                field  = "Microsoft.Storage/storageAccounts/allowBlobPublicAccess"
                equals = "true"
            }
        )
    }
    then   = @{
        effect = "deny"
    }
} | ConvertTo-Json -Depth 10

$customPolicy1 = New-AzPolicyDefinition `
    -Name "custom-deny-public-storage" `
    -DisplayName "CUSTOM: Deny Public Blob Storage Access" `
    -Description "Custom policy by Uzma Sami — Denies creation of storage accounts with public blob access enabled. Enforces Zero Trust data principle." `
    -Policy $noPublicStorageRule `
    -Mode "All" `
    -Metadata '{"category":"Security","version":"1.0.0","author":"Uzma Sami"}' `
    -ErrorAction SilentlyContinue

if ($customPolicy1) {
    # Assign custom policy
    New-AzPolicyAssignment `
        -Name "assign-custom-no-public-storage" `
        -DisplayName "CUSTOM: Block Public Storage" `
        -PolicyDefinition $customPolicy1 `
        -Scope $scope `
        -ErrorAction SilentlyContinue | Out-Null

    Write-Host "✅ Custom policy created + assigned!" `
        -ForegroundColor Green
    Write-Host "   Effect: DENY public blob access" `
        -ForegroundColor White
}

# ---- Custom Policy 2: Require HTTPS Storage ----
Write-Host "`n[2/2] Custom: Require HTTPS Storage..." `
    -ForegroundColor Yellow

$httpsStorageRule = @{
    if   = @{
        allOf = @(
            @{
                field  = "type"
                equals = "Microsoft.Storage/storageAccounts"
            },
            @{
                field  = "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly"
                equals = "false"
            }
        )
    }
    then = @{
        effect = "deny"
    }
} | ConvertTo-Json -Depth 10

$customPolicy2 = New-AzPolicyDefinition `
    -Name "custom-require-https-storage" `
    -DisplayName "CUSTOM: Require HTTPS — Storage Accounts" `
    -Description "Custom policy by Uzma Sami — Denies storage accounts that do not enforce HTTPS-only traffic. Ensures encryption in transit." `
    -Policy $httpsStorageRule `
    -Mode "All" `
    -Metadata '{"category":"Security","version":"1.0.0","author":"Uzma Sami"}' `
    -ErrorAction SilentlyContinue

if ($customPolicy2) {
    New-AzPolicyAssignment `
        -Name "assign-custom-https-storage" `
        -DisplayName "CUSTOM: Require HTTPS Storage" `
        -PolicyDefinition $customPolicy2 `
        -Scope $scope `
        -ErrorAction SilentlyContinue | Out-Null

    Write-Host "✅ Custom HTTPS policy created!" `
        -ForegroundColor Green
}

Write-Host "`n=== CUSTOM POLICIES CREATED ===" `
    -ForegroundColor Cyan
Get-AzPolicyDefinition `
    -Custom `
    -ErrorAction SilentlyContinue |
    Select-Object `
    @{N="Name";E={$_.Properties.DisplayName}} |
    Format-Table -AutoSize
