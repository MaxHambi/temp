## Summary

Neuer Meta-Skill **`using-skills`**: vereint `using-superpowers` (1%-Gate), `using-agent-skills` (Phasen-Baum + Operating Behaviors) und `skill-router` (Interview-Funnel) zu einem Skill mit eigener Gate-Logik, routed-MCP-Discovery und zwei Automation-Hooks.

## Changes

| Datei | Inhalt |
|---|---|
| `skills/using-skills/SKILL.md` | Gate → Router → Interview → routed-Discovery → Operating Behaviors, Red Flags, **i18n-Abschnitt** (deutsche Trigger-Nomen in der Description: "Welcher Skill passt", "Skills aufräumen und registrieren", "Wo starten", "Skill-Gate"), Automation-Hooks-Doku |
| `skills/using-skills/references/routing-reference.md` | Vollständiger Phasen-Baum, Kategorie-Routing-Tabelle, Interview-Funnel, Lifecycle-Sequenz |
| `skills/using-skills/references/routed-mcp.md` | MCP-Tool-Signaturen (route_skill/get_skill/list_skills/scan_skills/record_feedback), Standard-Workflow, CLI-Fallback, Fehlersignaturen-Tabelle |
| `skills/using-skills/hooks/route-gate.ps1` | Gate-Enforcement per routed CLI; Exit 0 = kein Skill nötig, 1 = Skill-Treffer einladen, 2 = routed nicht erreichbar |
| `skills/using-skills/hooks/skills-sync.ps1` | Erkennt Änderungen an den Skills-Ordnern (`.gemini/config/plugins`, `.agents/skills`, `.claude/skills`) per Snapshot-Diff und registriert sie mit `routed scan`; Switches `-Force`/`-HashContent` |

## i18n-Entscheidung

Skill-Body bleibt **englisch** (Ökosystem-Konvention, LLMs sind mehrsprachig); die **Trigger-Oberfläche ist bilingual** — deutsche Trigger-Nomen in der Frontmatter-Description, damit routed (BM25, lexikalisch) deutsche Prompts matcht. Antworten erfolgen in der Sprache des Users; Skill-Namen bleiben verbatim.

## Testing

- [x] `npm run lint` (Biome) grün
- [x] `npm run syntaxcheck` — 7/7 PowerShell-Skripte OK
- [x] `route-gate.ps1` dogfoodet: deutscher Prompt → Exit 1 mit 6 Treffern; englischer Prompt → Exit 1 mit 5 Treffern (inkl. `test-fixing` 0,732)
- [x] `skills-sync.ps1` dogfoodet: Erstlauf 2347 Skills registriert + `routed scan` ausgelöst; Idempotenz-Lauf → Exit 0
- [x] routed-Registrierung verifiziert: `get_skill("using-skills")` liefert den vollen Skill-Inhalt

## Risiken

- routed hat `.agents\skills` im Environment-Scan nicht automatisch erfasst (nur via `scan_skills -workspace` explizit) → skills-sync.ps1 sollte als regulärer Schritt nach Skill-Installationen laufen
- CLI-`routed scan` (972) vs. MCP-`scan_skills` (2843) indexieren unterschiedlich breit — Divergenz im Aufräumplan klären

## Reviewer-Checklist

- [ ] i18n-Ansatz (bilinguale Trigger-Description) so gewollt?
- [ ] Exit-Code-Vertrag der Hooks (0/1/2) so passend?
- [ ] Sync-Hook als Session-Start-Hook verankern?
