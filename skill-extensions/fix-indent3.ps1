#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$p = 'D:\freebuff-dev-setup\.worktrees\node-watchdog\node-watchdog\node-watchdog.ps1'
$lines = [System.IO.File]::ReadAllLines($p)
$killIdx = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
	if ($lines[$i] -match '^# -+ Kill / DryRun') { $killIdx = $i; break }
}
if ($killIdx -lt 5) { throw 'Kill-Kommentar nicht gefunden.' }

# Vor dem Kill-Kommentar: [k-4]='}' (col0, foreach-Close), [k-2]="`t}" (if-Close)
$a = $killIdx - 4
$b = $killIdx - 2
if ($lines[$a] -eq '}' -and $lines[$b] -eq "`t}") {
	$lines[$a] = "`t}"   # foreach-Close richtig einruecken
	$lines[$b] = '}'     # if-Close auf Spalte 0
	[System.IO.File]::WriteAllLines($p, $lines, [System.Text.UTF8Encoding]::new($false))
	Write-Host 'OK Einrueckungen getauscht'
} else {
	Write-Host ("UNERWARTET: [{0}]='{1}' [{2}]='{3}'" -f $a, $lines[$a], $b, $lines[$b])
}
