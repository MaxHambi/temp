#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# --- 1) Watchdog: ageHoursRaw fuer Kriterien (Bugfix aus Integrationstest) ---
$pw = 'D:\freebuff-dev-setup\.worktrees\node-watchdog\node-watchdog\node-watchdog.ps1'
$t = [System.IO.File]::ReadAllText($pw)

$old1 = @'
	$ageHours = 0.0
	if ($proc.CreationDate) {
		$ageHours = [math]::Round((($now - $proc.CreationDate).TotalHours), 2)
	}
'@
$new1 = @'
	# Volle Praezision fuer Kriterien (Runden wuerde -PortStaleHours 0 killen),
	# gerundet nur fuer den Report.
	$ageHoursRaw = 0.0
	$ageHours = 0.0
	if ($proc.CreationDate) {
		$ageHoursRaw = ($now - $proc.CreationDate).TotalHours
		$ageHours = [math]::Round($ageHoursRaw, 2)
	}
'@
if (-not $t.Contains($old1)) { throw 'Watchdog: Anker 1 nicht gefunden.' }
$t = $t.Replace($old1, $new1)

$old2 = "if (`$ageHours -gt `$MaxAgeHours -and `$cpuSeconds -lt `$IdleCpuSeconds) { `$reasons += 'idle-aged' }"
$new2 = "if (`$ageHoursRaw -gt `$MaxAgeHours -and `$cpuSeconds -lt `$IdleCpuSeconds) { `$reasons += 'idle-aged' }"
if (-not $t.Contains($old2)) { throw 'Watchdog: Anker 2 nicht gefunden.' }
$t = $t.Replace($old2, $new2)

$old3 = "		if (`$ownedPorts -contains `$wp -and `$ageHours -gt `$PortStaleHours) {"
$new3 = "		if (`$ownedPorts -contains `$wp -and `$ageHoursRaw -gt `$PortStaleHours) {"
if (-not $t.Contains($old3)) { throw 'Watchdog: Anker 3 nicht gefunden.' }
$t = $t.Replace($old3, $new3)

[System.IO.File]::WriteAllText($pw, $t, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK node-watchdog.ps1: Alters-Praezision gefixt'

# --- 2) Tests: Tree mit Enkelkind, Param-Doppelung, Bool-Wraps ---
$pt = 'D:\freebuff-dev-setup\.worktrees\node-watchdog\node-watchdog\run-tests.ps1'
$t2 = [System.IO.File]::ReadAllText($pt)

# 2a) Enkelkind-Script + Parent-Script
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

# 2b) baseArgs ohne WhitelistPath; Whitelist je Aufruf
$oldBase = "`$baseArgs = @('-LogPath', `$log, '-WhitelistPath', `$wlA, '-PortStaleHours', '0', '-WatchedPorts', '31317')"
$newBase = "`$baseArgs = @('-LogPath', `$log, '-PortStaleHours', '0', '-WatchedPorts', '31317')"
if (-not $t2.Contains($oldBase)) { throw 'Tests: Anker baseArgs nicht gefunden.' }
$t2 = $t2.Replace($oldBase, $newBase)
$t2 = $t2.Replace("(@(`$baseArgs) + @('-MaxAgeHours', '8', '-IdleCpuSeconds', '120'))", "(@(`$baseArgs) + @('-WhitelistPath', `$wlA, '-MaxAgeHours', '8', '-IdleCpuSeconds', '120'))")
$t2 = $t2.Replace("(@(`$baseArgs) + @('-WhitelistPath', `$wlB))", "(@(`$baseArgs) + @('-WhitelistPath', `$wlB))")
$t2 = $t2.Replace("(@(`$baseArgs) + @('-WhitelistPath', `$wlB, '-IncludeWhitelisted'))", "(@(`$baseArgs) + @('-WhitelistPath', `$wlB, '-IncludeWhitelisted'))")

# 2c) Bool-Wraps
$t2 = $t2.Replace("Assert-True (`$candsC | Where-Object { `$keepPids -contains `$_ }) 'T4 -IncludeWhitelisted listet Whitelist-Prozess'", "Assert-True ([bool](`$candsC | Where-Object { `$keepPids -contains `$_ })) 'T4 -IncludeWhitelisted listet Whitelist-Prozess'")

[System.IO.File]::WriteAllText($pt, $t2, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK run-tests.ps1: Tree/Args/Bool gefixt'
