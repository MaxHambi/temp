#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$p = 'D:\freebuff-dev-setup\.worktrees\node-watchdog\node-watchdog\node-watchdog.ps1'
$lines = [System.IO.File]::ReadAllLines($p)
# Die foreach-schliessende '}' direkt vor der Leerzeile + '}' vor dem Kill-Kommentar finden
$killIdx = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
	if ($lines[$i] -match '^# -+ Kill / DryRun') { $killIdx = $i; break }
}
if ($killIdx -lt 3) { throw 'Kill-Kommentar nicht gefunden.' }
# Erwartet: ... [killIdx-2] = '}' (foreach), [killIdx-1] = '' , [killIdx] = Kommentar
# Real:     [killIdx-3] = '}' (foreach)  -> Einrueckung fixen
for ($j = $killIdx - 1; $j -ge $killIdx - 5; $j--) {
	if ($lines[$j] -eq '}') {
		$lines[$j] = "`t}"
		[System.IO.File]::WriteAllLines($p, $lines, [System.Text.UTF8Encoding]::new($false))
		Write-Host ("OK Einrueckung an Zeile {0} gefixt" -f ($j + 1))
		break
	}
}
