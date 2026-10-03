#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# --- 1) Watchdog: zeilenbasiert (CRLF-sicher) ---
$pw = 'D:\freebuff-dev-setup\.worktrees\node-watchdog\node-watchdog\node-watchdog.ps1'
$lines = [System.Collections.Generic.List[string]]::new([System.IO.File]::ReadAllLines($pw))

for ($i = 0; $i -lt $lines.Count; $i++) {
	if ($lines[$i] -eq "`t`$ageHours = 0.0") {
		$lines[$i] = "`t# Volle Praezision fuer Kriterien (Runden wuerde -PortStaleHours 0 killen),"
		$lines.Insert($i + 1, "`t# gerundet nur fuer den Report.")
		$lines.Insert($i + 2, "`t`$ageHoursRaw = 0.0")
		$lines.Insert($i + 3, "`t`$ageHours = 0.0")
		$lines[$i + 4] = "`t`t`$ageHoursRaw = (`$now - `$proc.CreationDate).TotalHours"
		$lines[$i + 5] = "`t`t`$ageHours = [math]::Round(`$ageHoursRaw, 2)"
		break
	}
}
for ($i = 0; $i -lt $lines.Count; $i++) {
	if ($lines[$i] -match 'if \(\$ageHours -gt \$MaxAgeHours -and \$cpuSeconds') {
		$lines[$i] = $lines[$i].Replace('$ageHours -gt $MaxAgeHours', '$ageHoursRaw -gt $MaxAgeHours')
	}
	if ($lines[$i] -match '\$ageHours -gt \$PortStaleHours') {
		$lines[$i] = $lines[$i].Replace('$ageHours -gt $PortStaleHours', '$ageHoursRaw -gt $PortStaleHours')
	}
}
[System.IO.File]::WriteAllLines($pw, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK node-watchdog.ps1 Praezision gefixt'

# --- 2) run-tests.ps1: Tree mit Enkelkind, baseArgs ohne WhitelistPath, Bool-Wraps ---
$pt = 'D:\freebuff-dev-setup\.worktrees\node-watchdog\node-watchdog\run-tests.ps1'
$t2 = [System.IO.File]::ReadAllText($pt)

$oldEnv = @'
$env:WD_TREE_CHILD = "/*wd-selftest-tree*/setInterval(function(){},2147483647);"
$env:WD_KEEP_CHILD = "/*wd-selftest-keep*/setInterval(function(){},2147483647);"
$wrapperTreeScript = "/*wd-selftest-wrapper*/require('child_process').spawn(process.execPath,['-e',process.env.WD_TREE_CHILD],{stdio:'ignore'});setInterval(function(){},2147483647);"
'@
$newEnv = @'
$env:WD_TREE_CHILD = "/*wd-selftest-tree*/require('child_process').spawn(process.execPath,['-e',process.env.WD_GRAND_CHILD],{stdio:'ignore'});setInterval(function(){},2147483647);"
$env:WD_GRAND_CHILD = "/*wd-selftest-tree*/setInterval(function(){},2147483647);"
$env:WD_KEEP_CHILD = "/*wd-selftest-keep*/setInterval(function(){},2147483647);"
$wrapperTreeScript = "/*wd-selftest-wrapper*/require('child_process').spawn(process.execPath,['-e',process.env.WD_TREE_CHILD],{stdio:'ignore'});setInterval(function(){},2147483647);"
'@
if (-not $t2.Contains($oldEnv)) { throw 'Tests: Anker Env nicht gefunden.' }
$t2 = $t2.Replace($oldEnv, $newEnv)

$oldBase = "`$baseArgs = @('-LogPath', `$log, '-WhitelistPath', `$wlA, '-PortStaleHours', '0', '-WatchedPorts', '31317')"
$newBase = "`$baseArgs = @('-LogPath', `$log, '-PortStaleHours', '0', '-WatchedPorts', '31317')"
if (-not $t2.Contains($oldBase)) { throw 'Tests: Anker baseArgs nicht gefunden.' }
$t2 = $t2.Replace($oldBase, $newBase)
$t2 = $t2.Replace("(@(`$baseArgs) + @('-MaxAgeHours', '8', '-IdleCpuSeconds', '120'))", "(@(`$baseArgs) + @('-WhitelistPath', `$wlA, '-MaxAgeHours', '8', '-IdleCpuSeconds', '120'))")

$t2 = $t2.Replace("Assert-True (`$candsC | Where-Object { `$keepPids -contains `$_ }) 'T4", "Assert-True ([bool](`$candsC | Where-Object { `$keepPids -contains `$_ })) 'T4")

[System.IO.File]::WriteAllText($pt, $t2, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK run-tests.ps1 gefixt'
