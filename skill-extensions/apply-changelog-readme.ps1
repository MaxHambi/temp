#Requires -Version 5.1
# Staging-Skript: CHANGELOG erweitern + README-Skills-Abschnitt ergaenzen (Worktree).
# Einmalig fuer PR #11, nicht Teil der Task-Pipeline.

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# --- 1) CHANGELOG.md: using-skills-Eintrag unter [Unreleased] ### Added ---
$p1 = 'D:\freebuff-dev-setup\.worktrees\using-skills\CHANGELOG.md'
$t1 = [System.IO.File]::ReadAllText($p1)
$old1 = "## [Unreleased]`n`n### Added`n`n- README-Abschnitt"
$new1 = @'
## [Unreleased]

### Added

- Meta-Skill `using-skills` (`skills/using-skills/`): vereint using-superpowers
  (1%-Gate), using-agent-skills (Phasen-Baum, Operating Behaviors) und
  skill-router (Interview-Funnel); Skill-Discovery ueber routed MCP
  (`route_skill`/`get_skill`/`list_skills`/`scan_skills`) mit deutsch-
  englischer Trigger-Oberflaeche und i18n-Regeln (Body englisch, Antworten
  in der Sprache des Users).
- Automation-Hooks: `route-gate.ps1` (Gate-Enforcement per routed CLI,
  Exit 0/1/2 = kein Skill noetig/Skill-Treffer/Fehler) und `skills-sync.ps1`
  (Aenderungen an den Skills-Ordnern per Snapshot-Diff erkennen und mit
  `routed scan` registrieren; `-Force`/`-HashContent`).
- README-Abschnitt
'@
if (-not $t1.Contains($old1)) { throw 'CHANGELOG: Anker nicht gefunden.' }
$t1 = $t1.Replace($old1, $new1)
[System.IO.File]::WriteAllText($p1, $t1, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK CHANGELOG.md erweitert'

# --- 2) README.md: Skills-Verzeichnis-Abschnitt vor ## Wiederherstellung ---
$p2 = 'D:\freebuff-dev-setup\.worktrees\using-skills\README.md'
$t2 = [System.IO.File]::ReadAllText($p2)
$old2 = "## Wiederherstellung eines Tasks (GUI)"
$new2 = @'
## Skills-Verzeichnis (`skills/`)

Das Repo versioniert eigene Agent Skills unter `skills/`; Deploy-Ziel ist
`%USERPROFILE%\.agents\skills\<name>\` (Registrierung im routed-Index via
`skills-sync.ps1` oder MCP `scan_skills`).

### skills/using-skills — Meta-Skill (Gate + Router)

Vereint das 1%-Skill-Gate (using-superpowers), den Phasen-Baum (using-agent-skills)
und den Interview-Funnel (skill-router); Discovery-Fallback ueber routed MCP.

| Artefakt | Zweck |
|---|---|
| `SKILL.md` | Gate → Router → Interview → routed-Discovery → Operating Behaviors; i18n-Regeln (deutsch-englische Trigger-Description) |
| `references/routing-reference.md` | Vollstaendiger Phasen-Baum, Kategorie-Routing, Interview-Funnel, Lifecycle |
| `references/routed-mcp.md` | MCP-Tool-Signaturen, Standard-Workflow, CLI-Fallback, Fehlersignaturen |
| `hooks/route-gate.ps1` | Gate-Enforcement per routed CLI. Exit `0` = kein Skill noetig, `1` = Skill-Treffer einladen, `2` = routed nicht erreichbar |
| `hooks/skills-sync.ps1` | Snapshot-Diff ueber die Skills-Ordner (`.gemini/config/plugins`, `.agents/skills`, `.claude/skills`) + Registrierung via `routed scan`. Switches: `-Force`, `-HashContent` (SHA-256 statt Zeitstempel+Groesse) |

Hooks ausfuehren:

```powershell
pwsh -File skills/using-skills/hooks/route-gate.ps1 -Prompt "<task>"
pwsh -File skills/using-skills/hooks/skills-sync.ps1
```

State des Syncs: `%APPDATA%\routed\skills-sync.state.json` (nur nach
erfolgreichem Scan geschrieben). Aenderungen an Skills immer am Deploy-Ziel
und im Repo pflegen, danach Sync laufen lassen.

## Wiederherstellung eines Tasks (GUI)
'@
if (-not $t2.Contains($old2)) { throw 'README: Anker nicht gefunden.' }
$t2 = $t2.Replace($old2, $new2)
[System.IO.File]::WriteAllText($p2, $t2, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK README.md erweitert'

# --- Verifikation ---
$chk1 = ([System.IO.File]::ReadAllText($p1)).Contains('Meta-Skill `using-skills`')
$chk2 = ([System.IO.File]::ReadAllText($p2)).Contains('### skills/using-skills')
if (-not $chk1 -or -not $chk2) { throw 'Verifikation fehlgeschlagen.' }
Write-Host 'Alle Marker verifiziert.'
