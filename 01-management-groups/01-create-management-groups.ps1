# ============================================
# Script: create-management-groups.ps1
# Purpose: Create Management Group hierarchy
#          for enterprise governance at scale
# Author: Uzma Sami
# Date: May 2026
# ============================================

Connect-AzAccount

Write-Host @"
╔══════════════════════════════════════════╗
║   Azure Compliance & Governance          ║
║   Author: Uzma Sami | AZ-104 | AZ-500   ║
║   Creating Management Groups...          ║
╚══════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# Get tenant root management group
$tenantId = (Get-AzContext).Tenant.Id
Write-Host "Tenant ID: $tenantId" -ForegroundColor Cyan

# ---- Create Security Management Group ----
Write-Host "`n[1/3] Creating Security MG..." `
    -ForegroundColor Yellow

New-AzManagementGroup `
    -GroupId "mg-uzmasami-security" `
    -DisplayName "UzmaSami — Security" `
    -ErrorAction SilentlyContinue | Out-Null

Write-Host "✅ Security Management Group created!" `
    -ForegroundColor Green

# ---- Create Development Management Group ----
Write-Host "`n[2/3] Creating Development MG..." `
    -ForegroundColor Yellow

New-AzManagementGroup `
    -GroupId "mg-uzmasami-development" `
    -DisplayName "UzmaSami — Development" `
    -ErrorAction SilentlyContinue | Out-Null

Write-Host "✅ Development Management Group created!" `
    -ForegroundColor Green

# ---- Create Production Management Group ----
Write-Host "`n[3/3] Creating Production MG..." `
    -ForegroundColor Yellow

New-AzManagementGroup `
    -GroupId "mg-uzmasami-production" `
    -DisplayName "UzmaSami — Production" `
    -ErrorAction SilentlyContinue | Out-Null

Write-Host "✅ Production Management Group created!" `
    -ForegroundColor Green

# Move current subscription to Security MG
Write-Host "`nMoving subscription to Security MG..." `
    -ForegroundColor Yellow

$subscriptionId = (Get-AzContext).Subscription.Id

New-AzManagementGroupSubscription `
    -GroupId "mg-uzmasami-security" `
    -SubscriptionId $subscriptionId `
    -ErrorAction SilentlyContinue | Out-Null

Write-Host "✅ Subscription moved!" -ForegroundColor Green

# Verify hierarchy
Write-Host "`n=== MANAGEMENT GROUP HIERARCHY ===" `
    -ForegroundColor Cyan

Get-AzManagementGroup | 
    Select-Object DisplayName, Name, Type |
    Format-Table -AutoSize

Write-Host "✅ Management Groups configured!" `
    -ForegroundColor Green

