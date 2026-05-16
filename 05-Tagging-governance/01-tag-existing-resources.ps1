# ============================================
# Script: tag-existing-resources.ps1
# Purpose: Apply consistent governance tags
#          to ALL existing resources
# ============================================

Connect-AzAccount

Write-Host "Applying Governance Tags..." `
    -ForegroundColor Cyan

# Standard tag set for ALL resources
$standardTags = @{
    Engineer    = "Uzma Sami"
    Project     = "Azure-Governance"
    Environment = "Lab"
    CostCenter  = "IT-Security"
    ManagedBy   = "PowerShell"
    ReviewDate  = "2026-12-31"
    Compliance  = "CIS-Baseline"
}

# Get all resources
$allResources = Get-AzResource

Write-Host "Total resources to tag: $($allResources.Count)" `
    -ForegroundColor White

$tagged   = 0
$failed   = 0

foreach ($resource in $allResources) {
    try {
        # Merge existing tags with standard tags
        $existingTags = $resource.Tags ?? @{}
        $mergedTags   = $existingTags + $standardTags

        Update-AzTag `
            -ResourceId $resource.ResourceId `
            -Tag $mergedTags `
            -Operation Merge `
            -ErrorAction Stop | Out-Null

        $tagged++
        Write-Host "  ✅ Tagged: $($resource.Name)" `
            -ForegroundColor Green
    } catch {
        $failed++
        Write-Host "  ⚠️  Skipped: $($resource.Name)" `
            -ForegroundColor Yellow
    }
}

# Tag Resource Groups too
$allRGs = Get-AzResourceGroup

foreach ($rg in $allRGs) {
    try {
        Update-AzTag `
            -ResourceId $rg.ResourceId `
            -Tag $standardTags `
            -Operation Merge `
            -ErrorAction Stop | Out-Null

        Write-Host "  ✅ Tagged RG: $($rg.ResourceGroupName)" `
            -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️  Skipped RG: $($rg.ResourceGroupName)" `
            -ForegroundColor Yellow
    }
}

# Summary
Write-Host "`n=== TAGGING SUMMARY ===" -ForegroundColor Cyan
Write-Host "Successfully tagged: $tagged" -ForegroundColor Green
Write-Host "Skipped:             $failed" -ForegroundColor Yellow

$coverage = [math]::Round(
    ($tagged / ($tagged + $failed)) * 100
)
Write-Host "Tag coverage:        $coverage%" `
    -ForegroundColor Cyan

