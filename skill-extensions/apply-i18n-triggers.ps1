#Requires -Version 5.1
# Ergaenzt deutsche Trigger-Nomen in der SKILL.md-Description (i18n-Regel).

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$p = 'D:\freebuff-dev-setup\.worktrees\using-skills\skills\using-skills\SKILL.md'
$t = [System.IO.File]::ReadAllText($p)
$old = 'and ships hooks (route-gate.ps1 for gate enforcement, skills-sync.ps1 for index registration).'
$new = 'and ships hooks (route-gate.ps1 for gate enforcement, skills-sync.ps1 for index registration). Triggers (de): "Welcher Skill passt", "Skills aufraeumen und registrieren", "Wo starten", "Skill-Gate".'
if (-not $t.Contains($old)) { throw 'Ausgangsstring nicht gefunden.' }
$t = $t.Replace($old, $new)
[System.IO.File]::WriteAllText($p, $t, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK Description bilingual erweitert'
