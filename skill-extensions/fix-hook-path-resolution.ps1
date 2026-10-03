#Requires -Version 5.1
# Bugfix fuer beide Hooks: FullName-Problem + Exit-Code-Semantik (Fehler = 2).

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$hooksDir = 'D:\freebuff-dev-setup\.worktrees\using-skills\skills\using-skills\hooks'

# --- gemeinsamer Block: sichere Pfadauflaesung ---
$resolve = @'
# routed finden: erst PATH (CommandInfo.Source), dann Known-Location
$routedPath = $null
$cmd = Get-Command 'routed.cmd' -ErrorAction SilentlyContinue
if ($cmd) {
	$routedPath = $cmd.Source
	if (-not $routedPath) { $routedPath = $cmd.Path }
}
if (-not $routedPath) {
	$candidate = Join-Path $env:LOCALAPPDATA 'Programs\Routed\bin\routed.cmd'
	if (Test-Path $candidate) { $routedPath = $candidate }
}
if (-not $routedPath) {
	Write-Warning 'routed nicht gefunden (weder PATH noch %LOCALAPPDATA%\Programs\Routed\bin).'
	exit 2
}
'@

# --- route-gate.ps1 ---
$p1 = Join-Path $hooksDir 'route-gate.ps1'
$t1 = [System.IO.File]::ReadAllText($p1)
$old = @'
# routed finden: erst PATH, dann Known-Location
$routed = Get-Command 'routed.cmd' -ErrorAction SilentlyContinue
if (-not $routed) {
	$candidate = Join-Path $env:LOCALAPPDATA 'Programs\Routed\bin\routed.cmd'
	if (Test-Path $candidate) {
		$routed = Get-Item $candidate
	} else {
		Write-Error 'routed nicht gefunden (weder PATH noch %LOCALAPPDATA%\Programs\Routed\bin).'
		exit 2
	}
}

# Prompt routen (JSON-Ausgabe), Fehlerausgabe unterdruecken
$raw = & $routed.FullName route --json $Prompt 2>$null
if ($LASTEXITCODE -ne 0 -or -not $raw) {
	Write-Error 'routed route Aufruf fehlgeschlagen.'
	exit 2
}
'@
$new = @'
'@ + $resolve + @'

# Prompt routen (JSON-Ausgabe), Fehlerausgabe unterdruecken
$raw = & $routedPath route --json $Prompt 2>$null
if ($LASTEXITCODE -ne 0 -or -not $raw) {
	Write-Warning 'routed route Aufruf fehlgeschlagen.'
	exit 2
}
'@
if (-not $t1.Contains($old)) { throw 'route-gate: Ausgangsblock nicht gefunden.' }
$t1 = $t1.Replace($old, $new)
[System.IO.File]::WriteAllText($p1, $t1, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK route-gate.ps1 gefixt'

# --- skills-sync.ps1 ---
$p2 = Join-Path $hooksDir 'skills-sync.ps1'
$t2 = [System.IO.File]::ReadAllText($p2)
$old2 = @'
# 4) routed finden und Index aktualisieren
$routed = Get-Command 'routed.cmd' -ErrorAction SilentlyContinue
if (-not $routed) {
	$candidate = Join-Path $env:LOCALAPPDATA 'Programs\Routed\bin\routed.cmd'
	if (Test-Path $candidate) { $routed = Get-Item $candidate }
}
if (-not $routed) {
	Write-Error 'routed nicht gefunden - Aenderungen konnten nicht registriert werden.'
	exit 2
}

Write-Host ('SYNC: {0} neu, {1} entfernt, {2} geaendert - routed scan laeuft...' -f $added.Count, $removed.Count, $changed.Count)
& $routed.FullName scan 2>$null
if ($LASTEXITCODE -ne 0) {
	Write-Error 'routed scan fehlgeschlagen.'
	exit 2
}
'@
$new2 = @'
# 4) routed finden und Index aktualisieren
'@ + $resolve + @'

Write-Host ('SYNC: {0} neu, {1} entfernt, {2} geaendert - routed scan laeuft...' -f $added.Count, $removed.Count, $changed.Count)
& $routedPath scan 2>$null
if ($LASTEXITCODE -ne 0) {
	Write-Warning 'routed scan fehlgeschlagen.'
	exit 2
}
'@
if (-not $t2.Contains($old2)) { throw 'skills-sync: Ausgangsblock nicht gefunden.' }
$t2 = $t2.Replace($old2, $new2)
[System.IO.File]::WriteAllText($p2, $t2, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK skills-sync.ps1 gefixt'
