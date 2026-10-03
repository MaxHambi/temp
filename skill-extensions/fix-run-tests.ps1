#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$p = 'D:\freebuff-dev-setup\.worktrees\node-watchdog\node-watchdog\run-tests.ps1'
$t = [System.IO.File]::ReadAllText($p)

$old1 = "`$testPids = New-Object 'System.Collections.Generic.List[int]'"
$new1 = "`$testPids = New-Object 'System.Collections.Generic.List[int]'`n`$treePids = @()`n`$keepPids = @()`n`$portPids = @()"
if (-not $t.Contains($old1)) { throw 'Anker 1 nicht gefunden.' }
$t = $t.Replace($old1, $new1)

$old2 = "	foreach (`$p in `$testPids) { & taskkill.exe /PID `$p /T /F 2>`$null | Out-Null }`n	if (`$portPids) { foreach (`$p in `$portPids) { & taskkill.exe /PID `$p /T /F 2>`$null | Out-Null } }"
$new2 = "	foreach (`$p in `$testPids) { & taskkill.exe /PID `$p /T /F 2>`$null | Out-Null }`n	foreach (`$p in `$portPids) { & taskkill.exe /PID `$p /T /F 2>`$null | Out-Null }"
if (-not $t.Contains($old2)) { throw 'Anker 2 nicht gefunden.' }
$t = $t.Replace($old2, $new2)

[System.IO.File]::WriteAllText($p, $t, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK run-tests.ps1 robust gemacht'
