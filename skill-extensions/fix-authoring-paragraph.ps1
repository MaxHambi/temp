#Requires -Version 5.1
# Repariert den verschluckten Zeilenumbruch im authoring-Skill.

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$p = 'C:\Users\Max Hambi\.agents\skills\powershell-script-authoring\SKILL.md'
$t = [System.IO.File]::ReadAllText($p)
$t = $t.Replace("DryRun vor -ApplynFor client, production", "DryRun vor -Apply" + [Environment]::NewLine + [Environment]::NewLine + "For client, production")
[System.IO.File]::WriteAllText($p, $t, [System.Text.UTF8Encoding]::new($false))

$check = [System.IO.File]::ReadAllText($p)
if ($check.Contains('-ApplynFor') -or $check.Contains('-Apply For client')) { throw 'Fix fehlgeschlagen.' }
Write-Host 'OK Absatztrennung repariert'
