param([string]$PAT = "")
$Username  = "ATKrsh"
$Workspace = "E:\workspace"
if (-not $PAT) { $PAT = Read-Host "Enter GitHub PAT" }
$manifest = (Get-Content "$PSScriptRoot\WORKSPACE_MANIFEST.json" -Raw | ConvertFrom-Json).projects
Write-Host ("ATK Workspace Restore - " + (Get-Date)) -ForegroundColor Cyan
foreach ($proj in $manifest.PSObject.Properties) {
    $name    = $proj.Name
    $info    = $proj.Value
    $authUrl = ($info.repo -replace "https://", ("https://" + $Username + ":" + $PAT + "@")) + ".git"
    $dest    = Join-Path $Workspace $info.localPath
    $parent  = Split-Path $dest -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    Write-Host ("  Cloning " + $name + " -> " + $dest)
    if (Test-Path $dest) {
        Push-Location $dest
        git pull origin main --quiet 2>&1 | Out-Null
        Pop-Location
        Write-Host "    [PULLED]"
    } else {
        git clone $authUrl $dest --quiet 2>&1 | Out-Null
        Write-Host "    [CLONED]"
    }
}
Write-Host "Done! Run npm install / pip install -r requirements.txt per project." -ForegroundColor Green
