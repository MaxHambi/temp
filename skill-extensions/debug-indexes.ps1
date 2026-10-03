#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) 'wd-debug'
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$log = Join-Path $tmp 'debug.log'
$wlA = Join-Path $tmp 'wl.txt'
Set-Content -Path $wlA -Value '# leer' -Encoding UTF8

$env:WD_TREE_CHILD = "/*wd-selftest-tree*/require('child_process').spawn(process.execPath,['-e',process.env.WD_GRAND_CHILD],{stdio:'ignore'});setInterval(function(){},2147483647);"
$env:WD_GRAND_CHILD = "/*wd-selftest-tree*/setInterval(function(){},2147483647);"
$nodeExe = (Get-Command 'node.exe').Source
$watchdog = 'D:\freebuff-dev-setup\.worktrees\node-watchdog\node-watchdog\node-watchdog.ps1'

$wrapper = Start-Process -FilePath $nodeExe -ArgumentList '-e', "/*wd-selftest-wrapper*/require('child_process').spawn(process.execPath,['-e',process.env.WD_TREE_CHILD],{stdio:'ignore'});setInterval(function(){},2147483647);" -PassThru -WindowStyle Hidden
Start-Sleep -Milliseconds 1200
& taskkill.exe /PID $wrapper.Id /F 2>$null | Out-Null
Start-Sleep -Milliseconds 800

$treePids = @(Get-CimInstance Win32_Process -Filter "Name = 'node.exe'" |
	Where-Object { $_.CommandLine -like '*wd-selftest-tree*' } |
	ForEach-Object { [int]$_.ProcessId })

& pwsh -NoProfile -File $watchdog -LogPath $log -WhitelistPath $wlA -PortStaleHours 0 -WatchedPorts 31317 -MaxAgeHours 8 -IdleCpuSeconds 120 | Out-Null

Write-Host "=== Tree-PIDs ==="
$treePids | ForEach-Object { Write-Host "  $_" }
Write-Host "=== Kandidaten im Log ==="
foreach ($line in (Get-Content $log)) { if ($line -match 'KANDIDAT') { Write-Host "  $($line.Substring(40))" } }
Write-Host "=== Elternbeziehungen ==="
foreach ($tp in $treePids) {
	$proc = Get-CimInstance Win32_Process -Filter "ProcessId = $tp"
	if ($proc) {
		$parent = Get-CimInstance Win32_Process -Filter "ProcessId = $($proc.ParentProcessId)" -ErrorAction SilentlyContinue
		Write-Host ("  PID {0} -> Parent {1} ({2})" -f $tp, $proc.ParentProcessId, $(if ($parent) { 'lebt' } else { 'tot' }))
	}
}
foreach ($p in $treePids) { & taskkill.exe /PID $p /T /F 2>$null | Out-Null }
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
