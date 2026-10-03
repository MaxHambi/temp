#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$p = 'D:\freebuff-dev-setup\.worktrees\node-watchdog\node-watchdog\node-watchdog.ps1'
$lines = [System.Collections.Generic.List[string]]::new([System.IO.File]::ReadAllLines($p))

# Block 178-186 reparieren: if-Zeile wieder einbauen
# aktuell: ... $ageHours = 0.0 / (indented raw) / (indented round) / } / $cpuSeconds...
for ($i = 0; $i -lt $lines.Count; $i++) {
	if ($lines[$i] -match '^\t\$ageHoursRaw = 0\.0$') {
		# Zeile i+3 muss die geklammerte if-Zeile sein -> rekonstruieren
		if ($lines[$i + 3] -match 'ageHoursRaw = \(\$now') {
			$lines[$i + 3] = "`tif (`$proc.CreationDate) {"
			$lines.Insert($i + 4, "`t`t`$ageHoursRaw = (`$now - `$proc.CreationDate).TotalHours")
			$lines.Insert($i + 5, "`t`t`$ageHours = [math]::Round(`$ageHoursRaw, 2)")
		}
		break
	}
}
[System.IO.File]::WriteAllLines($p, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK Block rekonstruiert'

# Verifikation
$check = [System.IO.File]::ReadAllText($p)
pwsh -NoProfile -Command "[void][ScriptBlock]::Create((Get-Content -Raw 'D:\freebuff-dev-setup\.worktrees\node-watchdog\node-watchdog\node-watchdog.ps1')); Write-Host 'SYNTAX OK'"
$check = [System.IO.File]::ReadAllLines($p)
$inBlock = $false
foreach ($l in $check) {
	if ($l -match 'Alter \+ CPU') { $inBlock = $true }
	if ($inBlock) { Write-Host ("  |{0}" -f $l) }
	if ($l -match 'cpuSeconds = 0\.0$' -and $inBlock) { break }
}
