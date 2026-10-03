#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$p = 'D:\freebuff-dev-setup\.worktrees\node-watchdog\node-watchdog\node-watchdog.ps1'
$lines = [System.IO.File]::ReadAllLines($p)
# Zeile 228 (Index 227) ist die foreach-schliessende Klammer des Report-Blocks
if ($lines[227] -eq '}') {
	$lines[227] = "`t}"
	[System.IO.File]::WriteAllLines($p, $lines, [System.Text.UTF8Encoding]::new($false))
	Write-Host 'OK Einrueckung gefixt'
} else {
	Write-Host ("SKIP Zeile 228 ist: '{0}'" -f $lines[227])
}
