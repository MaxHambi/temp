#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$p = 'D:\freebuff-dev-setup\.worktrees\node-watchdog\node-watchdog\run-tests.ps1'
$t = [System.IO.File]::ReadAllText($p)

# Invoke-Watchdog: Log vor jedem Lauf leeren -> Assertions lesen nur den aktuellen Lauf
$old = @'
function Invoke-Watchdog {
	param([string[]]$Arguments)
	& $pwshExe -NoProfile -File $watchdog @Arguments | Out-Null
	return $LASTEXITCODE
}
'@
$new = @'
function Invoke-Watchdog {
	param([string[]]$Arguments)
	if (Test-Path $log) { Remove-Item -Path $log -Force -ErrorAction SilentlyContinue }
	& $pwshExe -NoProfile -File $watchdog @Arguments | Out-Null
	return $LASTEXITCODE
}
'@
if (-not $t.Contains($old)) { throw 'Anker Invoke-Watchdog nicht gefunden.' }
$t = $t.Replace($old, $new)

# Assertions auf Listen robust machen (alles als [bool]/[array] normalisieren)
$t = $t.Replace("Assert-True (`$candsA -contains `$treePids[0]) 'T2 Orphan erkannt (Tree-Eltern)'", "Assert-True ([bool](`$candsA -contains `$treePids[0])) 'T2 Orphan erkannt (Tree-Eltern)'")
$t = $t.Replace("Assert-True (`$candsB -notcontains `$keepPids[0]) 'T4 Whitelist-Prozess NICHT Kandidat'", "Assert-True (-not [bool](`$candsB | Where-Object { `$_ -eq `$keepPids[0] })) 'T4 Whitelist-Prozess NICHT Kandidat'")
$t = $t.Replace("Assert-True (-not (`$candsB | Where-Object { `$keepPids -contains `$_ })) 'T4 Whitelist-Prozess NICHT Kandidat'", "Assert-True (-not [bool](`$candsB | Where-Object { `$_ -eq `$keepPids[0] })) 'T4 Whitelist-Prozess NICHT Kandidat'")

[System.IO.File]::WriteAllText($p, $t, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK Log-Clear + Assertions robust'
