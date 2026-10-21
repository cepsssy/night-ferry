$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:Path = "$env:USERPROFILE\.rokit\bin;$env:Path"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

rojo build test.project.json -o build/NightFerryTests.rbxl

$studio = Get-ChildItem "$env:LOCALAPPDATA\Roblox\Versions" -Directory |
	ForEach-Object { Join-Path $_.FullName "RobloxStudioBeta.exe" } |
	Where-Object { Test-Path $_ } |
	Sort-Object { (Get-Item $_).LastWriteTime } -Descending |
	Select-Object -First 1

if (-not $studio) {
	throw "Roblox Studio not found. Install it from https://create.roblox.com/download"
}

$place = (Resolve-Path "build/NightFerryTests.rbxl").Path
$runner = (Resolve-Path "scripts/e2e.luau").Path
$log = Join-Path $root "build/e2e-output.log"
if (Test-Path $log) {
	Remove-Item $log
}

$process = Start-Process -FilePath $studio -ArgumentList @(
	"--task", "RunScript",
	"--localPlaceFile", "`"$place`"",
	"--runScriptFile", "`"$runner`"",
	"--outputFile", "`"$log`"",
	"--quitAfterExecution"
) -PassThru

if (-not $process.WaitForExit(120000)) {
	Stop-Process -Id $process.Id -Force
	throw "Studio did not finish within 120 seconds"
}

Start-Sleep -Seconds 2
if (-not (Test-Path $log)) {
	throw "Studio produced no output log"
}

$output = Get-Content $log -Raw -Encoding UTF8
Write-Host $output

if ($output -notmatch "\[NightFerry\] e2e tests passed") {
	throw "E2E tests failed. See build/e2e-output.log"
}
