$src  = Join-Path $PSScriptRoot "source"
$id   = "PS5ishLewis_b7c1e5a2-4d3f-4a86-9f21-6c8e0d5a7b34"
$dest = Join-Path $env:APPDATA "Playnite\Themes\Fullscreen\$id"

# Close Playnite and its helper processes, then wait for file handles to release
Get-Process -Name "Playnite.FullscreenApp","Playnite.DesktopApp","CefSharp.BrowserSubprocess" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Delete the old deployed copy, retrying if a file is still locked
for ($i = 0; $i -lt 5 -and (Test-Path $dest); $i++) {
    Remove-Item $dest -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path $dest) { Start-Sleep -Seconds 1 }
}
if (Test-Path $dest) {
    Write-Error "Could not delete $dest because a file is still in use. Close Playnite and try again."
    exit 1
}

# Copy the CONTENTS of source into a fresh folder
New-Item -ItemType Directory -Path $dest | Out-Null
Copy-Item "$src\*" $dest -Recurse -Force

# Patch the manifest in the deployed copy only
$yaml = Join-Path $dest "theme.yaml"
(Get-Content $yaml) `
  -replace '^Id:.*',     "Id: $id" `
  -replace '^Name:.*',   'Name: PS5ish Lewis' `
  -replace '^Author:.*', 'Author: Lewis (fork of David Griggs)' |
  Set-Content $yaml

if (Test-Path $yaml) { Write-Host "Deployed OK to $dest" } else { Write-Error "Deploy failed: theme.yaml missing" }