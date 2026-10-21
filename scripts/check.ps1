$ErrorActionPreference = "Stop"

$env:Path = "$env:USERPROFILE\.rokit\bin;$env:Path"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$defs = Join-Path $root "globalTypes.d.luau"
if (-not (Test-Path $defs)) {
	Write-Host "Downloading Roblox type definitions..."
	Invoke-WebRequest "https://luau-lsp.pages.dev/type-definitions/globalTypes.None.d.luau" -OutFile $defs
}

New-Item -ItemType Directory -Force build | Out-Null

rojo sourcemap default.project.json -o sourcemap.json
selene src tests scripts/e2e.luau
stylua --check src tests scripts/e2e.luau
luau-lsp analyze --sourcemap=sourcemap.json --definitions=$defs src
rojo build default.project.json -o build/NightFerry.rbxl
