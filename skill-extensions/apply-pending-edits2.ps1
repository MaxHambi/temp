#Requires -Version 5.1
# Zweiter Staging-Schub: route-gate.ps1 Kommentar-Fix + routed-mcp.md Sync-Verweis.

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# --- Edit 3: route-gate.ps1 - thereby -> damit ---
$p2 = 'D:\freebuff-dev-setup\.worktrees\using-skills\skills\using-skills\hooks\route-gate.ps1'
$t2 = [System.IO.File]::ReadAllText($p2)
if ($t2 -match 'thereby') {
	$t2 = $t2 -replace 'thereby', 'damit'
	[System.IO.File]::WriteAllText($p2, $t2, [System.Text.UTF8Encoding]::new($false))
}
if (([System.IO.File]::ReadAllText($p2)) -match 'thereby') { throw 'Edit 3 fehlgeschlagen.' }
Write-Host 'OK route-gate.ps1 bereinigt'

# --- Edit 4: routed-mcp.md - Sync-Verweis ergaenzen ---
$p3 = 'D:\freebuff-dev-setup\.worktrees\using-skills\skills\using-skills\references\routed-mcp.md'
$t3 = [System.IO.File]::ReadAllText($p3)
$old4 = 'ausfuehren, sonst liefert der Index alte Fassungen aus.'
$new4 = "ausfuehren, sonst liefert der Index alte Fassungen aus. Automatisiert:`r`n  ``hooks/skills-sync.ps1`` (Snapshot-Diff + ``routed scan``, siehe SKILL.md),"
if (-not $t3.Contains($old4)) { throw 'Edit 4: Ausgangsstring nicht gefunden.' }
$t3 = $t3.Replace($old4, $new4)
[System.IO.File]::WriteAllText($p3, $t3, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK routed-mcp.md aktualisiert'

# --- Verifikation: neue Marker in allen drei Dateien ---
$checks = @(
	@{ p = 'D:\freebuff-dev-setup\.worktrees\using-skills\skills\using-skills\SKILL.md'; m = '## Internationalization (i18n)' },
	@{ p = 'D:\freebuff-dev-setup\.worktrees\using-skills\skills\using-skills\SKILL.md'; m = '## Automation hooks' },
	@{ p = 'D:\freebuff-dev-setup\.worktrees\using-skills\skills\using-skills\SKILL.md'; m = 'skills-sync.ps1' },
	@{ p = 'D:\freebuff-dev-setup\.worktrees\using-skills\skills\using-skills\hooks\route-gate.ps1'; m = 'damit mechanisch' },
	@{ p = 'D:\freebuff-dev-setup\.worktrees\using-skills\skills\using-skills\references\routed-mcp.md'; m = 'skills-sync.ps1' }
)
foreach ($c in $checks) {
	$hit = ([System.IO.File]::ReadAllText($c.p)).Contains($c.m)
	Write-Host ("{0} -> {1}" -f ($(if ($hit) { 'OK  ' } else { 'FEHLT' })), $c.m)
	if (-not $hit) { throw "Verifikation fehlgeschlagen: $($c.m)" }
}
Write-Host 'Alle Edits verifiziert.'
