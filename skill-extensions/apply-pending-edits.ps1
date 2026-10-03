#Requires -Version 5.1
# Wendet die drei pending Edits auf die Worktree-Kopien des using-skills-Skills an.
# Einmaliger Aktionsskript (Staging), nicht Teil der Task-Pipeline.

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$base = 'D:\freebuff-dev-setup\.worktrees\using-skills\skills\using-skills'

# --- Edit 1: SKILL.md - Description erweitern ---
$p1 = Join-Path $base 'SKILL.md'
$t1 = [System.IO.File]::ReadAllText($p1)
$old1 = 'and ships hooks/route-gate.ps1 for automated gate enforcement.'
$new1 = 'and ships hooks (route-gate.ps1 for gate enforcement, skills-sync.ps1 for index registration).'
if (-not $t1.Contains($old1)) { throw 'Edit 1: Ausgangsstring nicht gefunden.' }
$t1 = $t1.Replace($old1, $new1)

# --- Edit 2: SKILL.md - Automation hook -> i18n + Automation hooks ---
$old2 = "## Automation hook`n`n``hooks/route-gate.ps1 -Prompt ""<task>""`` routes via the routed CLI and exits ``1`` when a skill matched - wire it as a session-start or file-change hook to enforce the gate mechanically on platforms where MCP is not yet available. Exit codes: ``0`` = no skill needed, ``1`` = invoke the listed skill(s), ``2`` = routed unreachable."
$new2 = @'
## Internationalization (i18n)

Trigger-language rules for this skill:

- The skill body stays in English (ecosystem convention; consuming LLMs are multilingual). Do NOT translate skill instructions per user locale.
- **Trigger surface is bilingual**: the description carries English and German trigger nouns ("skill invocation gate", "which skill applies", "Welcher Skill passt", "Skills aufräumen") so routed's BM25 index and keyword matching catch German prompts too. Keep it bilingual when editing.
- Respond in the user's language (German prompts get German answers); skill invocations and tool names stay verbatim.
- The interview funnel and recommendations are delivered in the user's language; skill names stay `@skill-name`.
- routed matching detail: BM25 is lexical - German-only phrasings route poorly against English-only descriptions. Fix at the source: add the German terms to the target skill's description instead of duplicating the skill.

## Automation hooks

**Gate enforcement** - `hooks/route-gate.ps1 -Prompt "<task>"`: routes via the routed CLI and exits `1` when a skill matched. Wire it as a session-start or file-change hook to enforce the gate mechanically on platforms where MCP is not yet available. Exit codes: `0` = no skill needed, `1` = invoke the listed skill(s), `2` = routed unreachable.

**Index sync** - `hooks/skills-sync.ps1`: detects changes in the skills folders (`.gemini\config\plugins`, `.agents\skills`, `.claude\skills`) by comparing a SKILL.md snapshot against the last run state in `%APPDATA%\routed\skills-sync.state.json` and registers updates with `routed scan`. Run it after installing, editing, moving, or cleaning up skills - it is the registration step for library reorganization. Switches: `-Force` (scan regardless of diff), `-HashContent` (SHA-256 content hash instead of timestamp+size, catches same-size edits). Exit codes: `0` = index up to date, `1` = changes detected and registered, `2` = error. MCP alternative: `scan_skills` tool.
'@
if (-not $t1.Contains($old2)) { throw 'Edit 2: Ausgangsstring nicht gefunden.' }
$t1 = $t1.Replace($old2, $new2)
[System.IO.File]::WriteAllText($p1, $t1, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK SKILL.md aktualisiert'

# --- Edit 3: route-gate.ps1 - thereby -> damit ---
$p2 = Join-Path $base 'hooks\route-gate.ps1'
$t2 = [System.IO.File]::ReadAllText($p2)
$t2 = $t2.Replace('setzt`r`n# thereby mechanisch', 'setzt`r`n# damit mechanisch')
$t2 = $t2.Replace('setzt`n# thereby mechanisch', 'setzt`n# thereby'.Replace('thereby','damit'))
[System.IO.File]::Replace('IGNORED', 'IGNORED', $t2) | Out-Null
if ($t2 -match 'thereby') {
	$t2 = $t2 -replace 'thereby', 'damit'
}
[System.IO.File]::WriteAllText($p2, $t2, [System.Text.UTF8Encoding]::new($false))
if (([System.IO.File]::ReadAllText($p2)) -match 'thereby') { throw 'Edit 3 fehlgeschlagen.' }
Write-Host 'OK route-gate.ps1 bereinigt'

# --- Edit 4: routed-mcp.md - Sync-Verweis ergaenzen ---
$p3 = Join-Path $base 'references\routed-mcp.md'
$t3 = [System.IO.File]::ReadAllText($p3)
$old4 = 'ausfuehren, sonst liefert der Index alte Fassungen aus.'
$new4 = "ausfuehren, sonst liefert der Index alte Fassungen aus. Automatisiert:`r`n  ``hooks/skills-sync.ps1`` (Snapshot-Diff + ``routed scan``, siehe SKILL.md),"
if (-not $t3.Contains($old4)) { throw 'Edit 4: Ausgangsstring nicht gefunden.' }
$t3 = $t3.Replace($old4, $new4)
[System.IO.File]::WriteAllText($p3, $t3, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK routed-mcp.md aktualisiert'
