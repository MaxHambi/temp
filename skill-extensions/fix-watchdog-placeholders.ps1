#Requires -Version 5.1
# Bereinigt Platzhalter-Kommentar und Report-Block im Watchdog.

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$p = 'D:\freebuff-dev-setup\.worktrees\node-watchdog\node-watchdog\node-watchdog.ps1'
$t = [System.IO.File]::ReadAllText($p)

# 1) Placeholder-Zeile entfernen
$t = $t.Replace("	`$parent = `$byPid.TryGetValue(`$parentPid, [ref]`$null) # Placeholder-Refs unten korrigiert`r`n", "")
$t = $t.Replace("	`$parent = `$byPid.TryGetValue(`$parentPid, [ref]`$null) # Placeholder-Refs unten korrigiert`n", "")

# 2) Report-Block: fruehe Klammerung korrigieren
$old = @'
if ($eligible.Count -eq 0) {
	Write-Log 'Keine Kandidaten - nichts zu tun.'
	exit 0
}

foreach ($c in $eligible) {
	Write-Log ("KANDIDAT
'@
$blockAfter = @'
if ($eligible.Count -gt 0) {
	foreach ($c in $eligible) {
		Write-Log ("KANDIDAT
'@
if ($t.Contains($old)) {
	$t = $t.Replace($old, $blockAfter)
	# schliessende Klammer nach dem Kandidaten-Loop ergaenzen
	$anchor = @'
	}

	# ---------------------------------------------------------------- Kill / DryRun
'@
	$anchorNew = @'
	}
}

	# ---------------------------------------------------------------- Kill / DryRun
'@
	$t = $c = $t.Replace($anchor, $anchorNew)
}
[System.IO.File]::WriteAllText($p, $t, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK Watchdog bereinigt'
