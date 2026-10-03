#Requires -Version 5.1
# Fuegt einen maschinenspezifischen Defaults-Block in den authoring-Skill ein.

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$p = 'C:\Users\Max Hambi\.agents\skills\powershell-script-authoring\SKILL.md'
$t = [System.IO.File]::ReadAllText($p)

$old = "Default to **PowerShell 7+ via ``pwsh``** for Ryan's own machine and AI Wiki workflows."
$new = @'
Default to **PowerShell 7+ via `pwsh`** on the local machine (this installation).

### Resolved defaults for this machine (Max Hambi / freebuff-dev-setup)

The generic placeholders below resolve as follows on this installation:

- `<DOWNLOADS_ROOT>` -> `$env:USERPROFILE\Downloads`
- `<DEV_ROOT>` -> `D:\` (Projekte: `D:\freebuff-dev-setup`, Runtime: `%USERPROFILE%\.tools`)
- `<AI_WIKI_ROOT>` -> nicht vorhanden; AI-Wiki-Workflows hier ignorieren
- bevorzugte Shell: `pwsh -NoProfile -File ...` (Task-Aktionen: Windows PowerShell 5.1, siehe AGENTS.md)
- Konventionen: Set-StrictMode + $ErrorActionPreference='Stop', Kommentare Deutsch, DryRun vor -Apply
'@
if (-not $t.Contains($old)) { throw 'Anker nicht gefunden.' }
$t = $t.Replace($old, $new)
[System.IO.File]::WriteAllText($p, $t, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK Defaults-Block eingefuegt'
