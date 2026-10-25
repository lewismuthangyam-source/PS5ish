$src  = Join-Path $PSScriptRoot "source"
$id   = "PS5ishLewis_b7c1e5a2-4d3f-4a86-9f21-6c8e0d5a7b34"
$dest = Join-Path $env:APPDATA "Playnite\Themes\Fullscreen\$id"

# Playnite must be closed so files aren't locked
Get-Process Playnite.FullscreenApp, Playnite.DesktopApp -ErrorAction SilentlyContinue | Stop-Process -Force

if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
Copy-Item $src $dest -Recurse

# Patch the manifest in the deployed copy only, so the repo's theme.yaml stays untouched
$yaml = Join-Path $dest "theme.yaml"
(Get-Content $yaml) `
  -replace '^Id:.*',     "Id: $id" `
  -replace '^Name:.*',   'Name: PS5ish Lewis' `
  -replace '^Author:.*', 'Author: Lewis (fork of David Griggs)' |
  Set-Content $yaml

Write-Host "Deployed to $dest"