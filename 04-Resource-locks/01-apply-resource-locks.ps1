# ============================================
# Script: apply-resource-locks.ps1
# Purpose: Protect critical resources with
#          locks — prevents accidental deletion
# ============================================

Connect-AzAccount

$rgNames = @(
    "rg-zt-identity",
    "rg-zt-network",
    "rg-zt-data",
    "rg-zt-visibility"
)

Write-Host "Applying Resource Locks..." `
    -ForegroundColor Cyan

Write-Host @"

Resource Locks = Last line of defense
CanNotDelete — prevents accidental removal
ReadOnly — prevents ANY changes
Critical for production governance!

"@ -ForegroundColor Yellow

foreach ($rg in $rgNames) {
    # Check if RG exists
    $rgExists = Get-AzResourceGroup `
        -Name $rg `
        -ErrorAction SilentlyContinue

    if ($rgExists) {
        # Apply CanNotDelete lock
        New-AzResourceLock `
            -LockName "lock-$rg-nodelete" `
            -LockLevel CanNotDelete `
            -ResourceGroupName $rg `
            -LockNotes "Governance lock by Uzma Sami — Prevents accidental deletion of security resources" `
            -Force `
            -ErrorAction SilentlyContinue | Out-Null

        Write-Host "✅ Lock applied: $rg" `
            -ForegroundColor Green
    } else {
        Write-Host "⚠️  RG not found: $rg" `
            -ForegroundColor Yellow
    }
}

# Apply ReadOnly to visibility RG
$visRG = Get-AzResourceGroup `
    -Name "rg-zt-visibility" `
    -ErrorAction SilentlyContinue

if ($visRG) {
    New-AzResourceLock `
        -LockName "lock-visibility-readonly" `
        -LockLevel ReadOnly `
        -ResourceGroupName "rg-zt-visibility" `
        -LockNotes "ReadOnly lock — Log Analytics must not be modified" `
        -Force `
        -ErrorAction SilentlyContinue | Out-Null

    Write-Host "✅ ReadOnly lock on visibility RG!" `
        -ForegroundColor Green
}

# Verify all locks
Write-Host "`n=== ALL RESOURCE LOCKS ===" `
    -ForegroundColor Cyan
Get-AzResourceLock |
    Select-Object Name, `
    @{N="Level";E={$_.Properties.Level}},
    ResourceGroupName |
    Format-Table -AutoSize

