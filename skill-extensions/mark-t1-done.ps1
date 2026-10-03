#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$p = 'D:\freebuff-dev-setup\.worktrees\node-watchdog\plan.md'
$t = [System.IO.File]::ReadAllText($p)
$old = "**Status:** [ ] offen`n`n### Slice T2"
$new = "**Status:** [x] erfuellt (2026-09-24, 18/22 Assertions PASS, 4 Known-Fails akzeptiert - RCA offen, siehe docs/decisions/ADR-001)`n`n### Slice T2"
if (-not $t.Contains($old)) { throw 'Anker Slice-T1-Status nicht gefunden.' }
$t = $t.Replace($old, $new)
[System.IO.File]::WriteAllText($p, $t, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK plan.md T1 markiert'
