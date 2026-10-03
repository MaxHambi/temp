#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$p = 'D:\freebuff-dev-setup\.worktrees\node-watchdog\node-watchdog\node-watchdog.ps1'
$lines = [System.Collections.Generic.List[string]]::new([System.IO.File]::ReadAllLines($p))

for ($i = 0; $i -lt $lines.Count; $i++) {
	if ($lines[$i] -eq "`t`$ageHours = 0.0" -and $lines[$i + 1] -match 'ageHoursRaw = \(\$now') {
		$lines.Insert($i + 1, "`tif (`$proc.CreationDate) {")
		break
	}
}
[System.IO.File]::WriteAllLines($p, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK if-Opener eingefuegt'
