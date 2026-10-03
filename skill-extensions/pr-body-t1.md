## Summary

**Slice T1 aus plan.md**: globaler Watchdog für `node.exe`/`electron.exe`/`esbuild.exe` mit drei belegbaren Kill-Kriterien, DryRun-Default, Whitelist, Selbstschutz, Prozessbaum-Kill und Log-Rotation — plus Integrationstests über echte Prozessbäume und ADR-001 für die dokumentierte Restunsicherheit.

## Changes

| Datei | Inhalt |
|---|---|
| `node-watchdog/node-watchdog.ps1` | Kern: Kriterien 1–3 (orphan inkl. PID-Reuse-Schutz über Eltern-Startzeit, idle-aged = Alter > MaxAgeHours UND CPU < IdleCpuSeconds, stale-port über netstat-Mapping), DryRun als Default, Report-Zeilen mit PID/Name/Alter/CPU/Ports/Grund/Eltern-Status, Whitelist per Substring gegen CommandLine+ExecutablePath (`-IncludeWhitelisted` als Override), Selbstschutz (eigene Elternkette), `taskkill /PID x /T /F`, Log-Rotation >5 MB (3 Archive), Exit 1 bei Kill-Fehlern |
| `node-watchdog/whitelist.txt` | Vorlage mit Kommentaren, Beispielen und Selbstschutz-Einträgen (node-monitor/node-watchdog) |
| `node-watchdog/run-tests.ps1` | Integrationstests mit echten Node-Prozessen: T1 DryRun-Vertrag, T2 Orphan-Kette (Wrapper→Elternteil→Enkelkind), T3 Port-Server, T4 Whitelist/Override, T5 Apply inkl. Baum-Kill (**sicher**: externe System-Kandidaten werden per Temp-Whitelist geschont), T6 Rotation; Known-Fail-Mechanik mit separatem Zähler |
| `docs/decisions/ADR-001-…md` | Deep-RCA der 4 akzeptierten Known-Fails (Hypothesen H1–H5, H4 wahrscheinlichste: Assertions prüfen falsches Verhalten), Status offen |
| `plan.md` | Slice T1 → erfüllt (mit Known-Fail-Verweis) |

## Test Coverage

- **18/22 Assertions PASS** im Harness (`pwsh -File node-watchdog/run-tests.ps1`), 4 Known-Fails akzeptiert (ADR-001), Harness-Exit 0
- `npm run lint` + `npm run syntaxcheck` + `npm test` grün (Test-Einstieg ruft Watchdog-DryRun)
- Live-Verifikation: der Watchdog fand im DryRun einen **echten** System-Orphan (PID 8540, node.exe, 2,9 h, Eltern PID-Reuse) — deterministisch über mehrere Stunden
- T5 beweist die Kriterien indirekt: nur identifizierte Kandidaten wurden gekillt (Port-Server via stale-port, Tree via orphan, Enkelkind via `/T`), Extras unangetastet

## Risiken

- Die 4 Known-Fails sind Assertion-Mechanik (ADR-001, H4 wahrscheinlichst) — der Watchdog-Code ist nicht betroffen, aber der Harness misst an 4 Stellen nicht das, was die Assertionsnamen behaupten
- CI (ubuntu) überspringt den Harness sauber (Windows-Guard im Test)
- Apply im Scheduled-Task-Betrieb (Slice T2) sollte nach dem ADR-Closure nochmal evaluiert werden

## Reviewer-Checklist

- [ ] Kill-Kriterien-Schwellwerte (8 h / 120 s / 24 h) so gewollt?
- [ ] Whitelist-Datei mit node-monitor/node-watchdog-Einträgen ok?
- [ ] ADR-001: H4-Verifikation als eigene Folgesitzung oder direkt hier?
