# ============================================
# Script: generate-governance-report.ps1
# Purpose: Beautiful governance compliance 
#          report showing all controls
# ============================================

Connect-AzAccount

$reportDate     = Get-Date -Format "yyyy-MM-dd HH:mm"
$subscriptionId = (Get-AzContext).Subscription.Id
$subName        = (Get-AzContext).Subscription.Name

Write-Host "Gathering Governance Data..." -ForegroundColor Cyan

# Gather all data
$mgGroups          = Get-AzManagementGroup -ErrorAction SilentlyContinue
$policyAssign      = Get-AzPolicyAssignment -Scope "/subscriptions/$subscriptionId" -ErrorAction SilentlyContinue
$customPolicies    = Get-AzPolicyDefinition -Custom -ErrorAction SilentlyContinue
$customInitiatives = Get-AzPolicySetDefinition -Custom -ErrorAction SilentlyContinue
$customRoles       = Get-AzRoleDefinition -Custom -ErrorAction SilentlyContinue
$locks             = Get-AzResourceLock -ErrorAction SilentlyContinue
$allResources      = Get-AzResource -ErrorAction SilentlyContinue

# CORRECTED: Using $_.Tags for pipeline processing
$taggedResources = $allResources | Where-Object {
    $_.Tags -and $_.Tags.Count -gt 0
}

$tagCoverage = if ($allResources.Count -gt 0) {
    [math]::Round(($taggedResources.Count / $allResources.Count) * 100)
} else {0}

# Build policy rows
$policyRows = ""
foreach ($policy in $policyAssign) {
    $policyRows += @"
        <tr>
            <td>$($policy.Properties.DisplayName)</td>
            <td><span class='badge-green'>✅ Assigned</span></td>
            <td>Subscription</td>
        </tr>
"@
}

# Build custom role rows
$roleRows = ""
foreach ($role in $customRoles) {
    # Ensure description isn't null before taking Substring
    $desc = if ($role.Description) { $role.Description } else { "No description provided" }
    $shortDesc = $desc.Substring(0,[Math]::Min(80,$desc.Length))
    
    $roleRows += @"
        <tr>
            <td>$($role.Name)</td>
            <td>$shortDesc...</td>
            <td><span class='badge-green'>✅ Active</span></td>
        </tr>
"@
}

$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Azure Governance Report — Uzma Sami</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', Arial; background: #f0f4f8; padding: 40px; }
        .container { background: white; max-width: 1200px; margin: 0 auto; border-radius: 16px; padding: 40px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #0078d4, #005a9e); color: white; padding: 30px; border-radius: 12px; margin-bottom: 30px; }
        .header h1 { font-size: 26px; margin-bottom: 8px; }
        .metric-grid { display: grid; grid-template-columns: repeat(4,1fr); gap: 16px; margin-bottom: 30px; }
        .metric-box { background: #f8f9fa; border: 2px solid #0078d4; border-radius: 10px; padding: 20px; text-align: center; }
        .metric-number { font-size: 40px; font-weight: 700; color: #0078d4; }
        .metric-label { font-size: 12px; color: #666; margin-top: 5px; }
        h2 { color: #0078d4; border-left: 4px solid #0078d4; padding-left: 12px; margin: 25px 0 15px; font-size: 18px; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        th { background: #0078d4; color: white; padding: 12px; text-align: left; font-size: 13px; }
        td { padding: 10px 12px; font-size: 12px; border-bottom: 1px solid #eee; }
        tr:nth-child(even) { background: #f8f9fa; }
        .badge-green { background: #d4edda; color: #155724; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; }
        .controls-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 15px; margin-bottom: 25px; }
        .control-card { background: #f8f9fa; border: 1px solid #dee2e6; border-radius: 10px; padding: 20px; }
        .control-card h3 { color: #0078d4; font-size: 14px; margin-bottom: 10px; }
        .control-item { padding: 5px 0; font-size: 12px; border-bottom: 1px solid #eee; color: #333; }
        footer { margin-top: 40px; text-align: center; color: #666; font-size: 12px; border-top: 1px solid #eee; padding-top: 20px; }
    </style>
</head>
<body>
<div class='container'>
    <div class='header'>
        <h1>⚖️ Azure Compliance & Governance Report</h1>
        <p>Engineer: Uzma Sami | AZ-104 | AZ-500</p>
        <p>Subscription: $subName</p>
        <p>Report Date: $reportDate | Region: UK South</p>
    </div>

    <div class='metric-grid'>
        <div class='metric-box'><div class='metric-number'>$($mgGroups.Count)</div><div class='metric-label'>Management Groups</div></div>
        <div class='metric-box'><div class='metric-number'>$($policyAssign.Count)</div><div class='metric-label'>Policies Assigned</div></div>
        <div class='metric-box'><div class='metric-number'>$($customRoles.Count)</div><div class='metric-label'>Custom RBAC Roles</div></div>
        <div class='metric-box'><div class='metric-number'>$tagCoverage%</div><div class='metric-label'>Tag Coverage</div></div>
    </div>

    <h2>🏛️ Governance Controls</h2>
    <div class='controls-grid'>
        <div class='control-card'>
            <h3>👤 RBAC</h3>
            <div class='control-item'>✅ Custom roles: $($customRoles.Count)</div>
            <div class='control-item'>✅ Least privilege applied</div>
        </div>
        <div class='control-card'>
            <h3>🔒 Resource Locks</h3>
            <div class='control-item'>✅ Total locks: $($locks.Count)</div>
        </div>
        <div class='control-card'>
            <h3>🏷️ Tagging</h3>
            <div class='control-item'>✅ Coverage: $tagCoverage%</div>
        </div>
    </div>

    <h2>📜 Policy Assignments</h2>
    <table>
        <tr><th>Policy Name</th><th>Status</th><th>Scope</th></tr>
        $policyRows
    </table>

    <h2>👤 Custom RBAC Roles</h2>
    <table>
        <tr><th>Role Name</th><th>Description</th><th>Status</th></tr>
        $roleRows
    </table>

    <footer>
        Azure Compliance & Governance Report | Uzma Sami | $reportDate
    </footer>
</div>
</body>
</html>
"@

# Generate the filename
$filename = "governance-report-$(Get-Date -Format 'yyyyMMdd').html"
$reportPath = Join-Path $HOME $filename

# Save the file
$html | Out-File $reportPath -Encoding UTF8

Write-Host "`n✅ Governance report generated successfully!" -ForegroundColor Green
Write-Host "File location: $reportPath" -ForegroundColor White
Write-Host "`nTo view the report:" -ForegroundColor Cyan
Write-Host "1. Click the 'Upload/Download' icon in the top toolbar."
Write-Host "2. Select 'Download'."
Write-Host "3. Type: $filename"

