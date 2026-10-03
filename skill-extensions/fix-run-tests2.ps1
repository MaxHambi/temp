#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$p = 'D:\freebuff-dev-setup\.worktrees\node-watchdog\node-watchdog\run-tests.ps1'
$t = [System.IO.File]::ReadAllText($p)

# 1) KILL-Check case-sensitive machen ("kein Kill" darf nicht matchen)
$t = $t.Replace("Assert-True (-not (`$logText -match 'KILL ')) 'T1 kein KILL im DryRun'", "Assert-True (-not (`$logText -cmatch 'KILL PID')) 'T1 kein KILL im DryRun'")

# 2) Get-NodeByMarker: List[int] statt Array-Return (leere Arrays unrollen zu $null)
$old1 = @'
function Get-NodeByMarker {
	param([string]$Marker)
	@(Get-CimInstance Win32_Process -Filter "Name = 'node.exe'" -ErrorAction SilentlyContinue |
		Where-Object { $_.CommandLine -like ("*{0}*" -f $Marker) } |
		ForEach-Object { [int]$_.ProcessId })
}
'@
$new1 = @'
function Get-NodeByMarker {
	param([string]$Marker)
	$result = New-Object 'System.Collections.Generic.List[int]'
	$matches2 = @(Get-CimInstance Win32_Process -Filter "Name = 'node.exe'" -ErrorAction SilentlyContinue |
		Where-Object { $_.CommandLine -like ("*{0}*" -f $Marker) })
	foreach ($m in $matches2) { $result.Add([int]$m.ProcessId) }
	return $result
}
'@
if (-not $t.Contains($old1)) { throw 'Anker Get-NodeByMarker nicht gefunden.' }
$t = $t.Replace($old1, $new1)

# 3) Get-CandidatePids: ebenfalls List[int]
$old2 = @'
function Get-CandidatePids {
	param([string]$LogFile)
	$pids = @()
	if (Test-Path $LogFile) {
		foreach ($line in Get-Content $LogFile) {
			if ($line -match 'KANDIDAT PID (\d+)') { $pids += [int]$Matches[1] }
		}
	}
	return ,$pids
}
'@
$new2 = @'
function Get-CandidatePids {
	param([string]$LogFile)
	$pids = New-Object 'System.Collections.Generic.List[int]'
	if (Test-Path $LogFile) {
		foreach ($line in Get-Content $LogFile) {
			if ($line -match 'KANDIDAT PID (\d+)') { $pids.Add([int]$Matches[1]) }
		}
	}
	return $pids
}
'@
if (-not $t.Contains($old2)) { throw 'Anker Get-CandidatePids nicht gefunden.' }
$t = $t.Replace($old2, $new2)

[System.IO.File]::WriteAllText($p, $t, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK Test-Helper robust gemacht'
