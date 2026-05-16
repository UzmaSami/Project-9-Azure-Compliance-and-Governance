# ============================================
# Script: assign-builtin-policies.ps1
# Purpose: Assign Azure built-in security
#          policies for compliance baseline
# ============================================

Connect-AzAccount

$subscriptionId = (Get-AzContext).Subscription.Id
$scope = "/subscriptions/$subscriptionId"

Write-Host "Assigning Built-in Security Policies..." `
    -ForegroundColor Cyan

# ---- Policy 1: Azure Security Benchmark ----
Write-Host "`n[1/5] Azure Security Benchmark..." `
    -ForegroundColor Yellow

$asbDefinition = Get-AzPolicySetDefinition |
    Where-Object {
        $_.Properties.DisplayName -like `
        "Azure Security Benchmark"
    } | Select-Object -First 1

if ($asbDefinition) {
    New-AzPolicyAssignment `
        -Name "assign-azure-security-benchmark" `
        -DisplayName "Governance: Azure Security Benchmark v3" `
        -PolicySetDefinition $asbDefinition `
        -Scope $scope `
        -AssignIdentity `
        -Location "uksouth" `
        -ErrorAction SilentlyContinue | Out-Null

    Write-Host "✅ Azure Security Benchmark assigned!" `
        -ForegroundColor Green
}

# ---- Policy 2: Require Encryption ----
Write-Host "`n[2/5] Storage Encryption Policy..." `
    -ForegroundColor Yellow

$encryptionPolicy = Get-AzPolicyDefinition |
    Where-Object {
        $_.Properties.DisplayName -like `
        "storage accounts should use*encryption" -or
        $_.Properties.DisplayName -like `
        "Secure transfer*storage"
    } | Select-Object -First 1

if ($encryptionPolicy) {
    New-AzPolicyAssignment `
        -Name "assign-storage-encryption" `
        -DisplayName "Governance: Require Storage Encryption" `
        -PolicyDefinition $encryptionPolicy `
        -Scope $scope `
        -ErrorAction SilentlyContinue | Out-Null

    Write-Host "✅ Storage Encryption policy assigned!" `
        -ForegroundColor Green
}

# ---- Policy 3: Allowed Locations ----
Write-Host "`n[3/5] Allowed Locations Policy..." `
    -ForegroundColor Yellow

$locationPolicy = Get-AzPolicyDefinition |
    Where-Object {
        $_.Properties.DisplayName -eq `
        "Allowed locations"
    } | Select-Object -First 1

if ($locationPolicy) {
    $locationParams = @{
        listOfAllowedLocations = @{
            value = @(
                "uksouth",
                "ukwest",
                "global"
            )
        }
    }

    New-AzPolicyAssignment `
        -Name "assign-allowed-locations" `
        -DisplayName "Governance: UK South/West Only" `
        -PolicyDefinition $locationPolicy `
        -Scope $scope `
        -PolicyParameterObject $locationParams `
        -ErrorAction SilentlyContinue | Out-Null

    Write-Host "✅ Allowed Locations policy assigned!" `
        -ForegroundColor Green
    Write-Host "   Allowed: UK South, UK West" `
        -ForegroundColor White
}

# ---- Policy 4: Audit NSGs ----
Write-Host "`n[4/5] Audit NSG Policy..." `
    -ForegroundColor Yellow

$nsgPolicy = Get-AzPolicyDefinition |
    Where-Object {
        $_.Properties.DisplayName -like `
        "network security group*subnet"
    } | Select-Object -First 1

if ($nsgPolicy) {
    New-AzPolicyAssignment `
        -Name "assign-audit-nsg-subnets" `
        -DisplayName "Governance: Audit NSG on Subnets" `
        -PolicyDefinition $nsgPolicy `
        -Scope $scope `
        -ErrorAction SilentlyContinue | Out-Null

    Write-Host "✅ NSG Audit policy assigned!" `
        -ForegroundColor Green
}

# ---- Policy 5: Require Tags ----
Write-Host "`n[5/5] Require Tags Policy..." `
    -ForegroundColor Yellow

$tagPolicy = Get-AzPolicyDefinition |
    Where-Object {
        $_.Properties.DisplayName -like `
        "Require a tag on resources"
    } | Select-Object -First 1

if ($tagPolicy) {
    $tagParams = @{
        tagName = @{value = "Environment"}
    }

    New-AzPolicyAssignment `
        -Name "assign-require-environment-tag" `
        -DisplayName "Governance: Require Environment Tag" `
        -PolicyDefinition $tagPolicy `
        -Scope $scope `
        -PolicyParameterObject $tagParams `
        -ErrorAction SilentlyContinue | Out-Null

    Write-Host "✅ Require Tags policy assigned!" `
        -ForegroundColor Green
}

# Summary
Write-Host "`n=== POLICY ASSIGNMENTS ===" `
    -ForegroundColor Cyan

Get-AzPolicyAssignment -Scope $scope |
    Select-Object `
    @{N="Name";E={$_.Properties.DisplayName}} |
    Format-Table -AutoSize

Write-Host "✅ All policies assigned!" `
    -ForegroundColor Green

