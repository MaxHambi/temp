#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$p = 'D:\freebuff-dev-setup\.worktrees\node-watchdog\node-watchdog\run-tests.ps1'
$t = [System.IO.File]::ReadAllText($p)

$pairs = @(
	@('$treePids = Get-NodeByMarker -Marker ''wd-selftest-tree''', '$treePids = @(Get-NodeByMarker -Marker ''wd-selftest-tree'')'),
	@('$keepPids = Get-NodeByMarker -Marker ''wd-selftest-keep''', '$keepPids = @(Get-NodeByMarker -Marker ''wd-selftest-keep'')'),
	@('$portPids = Get-NodeByMarker -Marker ''wd-selftest-port''', '$portPids = @(Get-NodeByMarker -Marker ''wd-selftest-port'')'),
	@('$candsA = Get-CandidatePids -LogFile $log', '$candsA = @(Get-CandidatePids -LogFile $log)'),
	@('$candsB = Get-CandidatePids -LogFile $log', '$candsB = @(Get-CandidatePids -LogFile $log)'),
	@('$candsC = Get-CandidatePids -LogFile $log', '$candsC = @(Get-CandidatePids -LogFile $log)')
)
foreach ($pair in $pairs) {
	if (-not $t.Contains($pair[0])) { throw ("Anker nicht gefunden: {0}" -f $pair[0]) }
	$t = $t.Replace($pair[0], $pair[1])
}
[System.IO.File]::WriteAllText($p, $t, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK Aufrufstellen gewrappt'
