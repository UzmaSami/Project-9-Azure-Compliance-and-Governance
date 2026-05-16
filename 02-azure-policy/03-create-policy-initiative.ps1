# ============================================
# Script: create-policy-initiative.ps1
# Purpose: Group related policies into ONE initiative
#          This is enterprise-level governance!
# ============================================

Connect-AzAccount -UseDeviceAuthentication

$subscriptionId = (Get-AzContext).Subscription.Id
$scope          = "/subscriptions/$subscriptionId"

Write-Host "`nCreating Security Policy Initiative..." -ForegroundColor Cyan

Write-Host @"

Policy Initiative = Group of related policies
Enterprise clients ALWAYS use initiatives
This shows senior-level governance knowledge!

"@ -ForegroundColor Yellow

# Construct the exact ARM Resource IDs
$policyDefinitions = @(
    @{
        policyDefinitionId = "/subscriptions/$subscriptionId/providers/Microsoft.Authorization/policyDefinitions/custom-deny-public-storage"
        policyDefinitionReferenceId = "no-public-storage"
    },
    @{
        policyDefinitionId = "/subscriptions/$subscriptionId/providers/Microsoft.Authorization/policyDefinitions/custom-require-https-storage"
        policyDefinitionReferenceId = "https-storage-only"
    },
    @{
        policyDefinitionId = "/providers/Microsoft.Authorization/policyDefinitions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        policyDefinitionReferenceId = "secure-transfer"
    }
)

# FIXED: Use -InputObject to prevent PowerShell from unrolling the array, 
# ensuring it outputs a proper JSON array `[ {...}, {...} ]`
$jsonPayload = ConvertTo-Json -InputObject $policyDefinitions -Depth 5 -Compress

# Create the initiative
$initiative = New-AzPolicySetDefinition `
    -Name "initiative-uzmasami-security-baseline" `
    -DisplayName "UzmaSami Security Baseline Initiative" `
    -Description "Custom security initiative by Uzma Sami combining storage security, encryption, and access control policies for enterprise baseline compliance." `
    -PolicyDefinition $jsonPayload `
    -Metadata '{"category":"Security Baseline","version":"1.0.0","author":"Uzma Sami","contact":"Upwork"}' `
    -ErrorAction Stop

if ($initiative) {
    Write-Host "✅ Security Initiative created!" -ForegroundColor Green

    # Assign the initiative
    # FIXED: Removed -AssignIdentity as it is not needed for "Deny" effects 
    # and causes compatibility errors in some Cloud Shell versions.
    $assignment = New-AzPolicyAssignment `
        -Name "assign-security-baseline-initiative" `
        -DisplayName "UzmaSami: Security Baseline Initiative" `
        -PolicySetDefinition $initiative `
        -Scope $scope `
        -Location "uksouth" `
        -ErrorAction Stop 

    if ($assignment) {
        Write-Host "✅ Initiative assigned to subscription!" -ForegroundColor Green
    }
}

# Show all initiatives
Write-Host "`n=== POLICY INITIATIVES ===" -ForegroundColor Cyan
Start-Sleep -Seconds 2
Get-AzPolicySetDefinition -Custom | 
    Select-Object `
    @{N="Initiative";E={$_.DisplayName}},
    @{N="Policies";E={$_.PolicyDefinitions.Count}} | 
    Format-Table -AutoSize

