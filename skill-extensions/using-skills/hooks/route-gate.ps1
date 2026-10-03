#Requires -Version 5.1
# Route-Gate-Hook fuer den Skill "using-skills".
# Prueft per routed CLI, ob fuer einen Prompt ein Skill passt, und setzt
# thereby mechanisch das Gate um (Enforcement ohne MCP-Kontext).
# Exit-Codes: 0 = kein Skill noetig, 1 = Skill-Treffer (einladen und folgen),
#             2 = routed nicht erreichbar/fehlerhaft.
# Benutzung:  pwsh -File route-gate.ps1 -Prompt "<task>"

param(
	[Parameter(Mandatory = $true)]
	[string]$Prompt
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# routed.cmd finden: erst PATH, dann Known-Location
$routed = Get-Command 'routed.cmd' -ErrorAction SilentlyContinue
if (-not $routed) {
	$candidate = Join-Path $env:LOCALAPPDATA 'Programs\Routed\bin\routed.cmd'
	if (Test-Path $candidate) {
		$routed = Get-Item $candidate
	} else {
		Write-Error 'routed nicht gefunden (weder PATH noch %LOCALAPPDATA%\Programs\Routed\bin).'
		exit 2
	}
}

# Prompt routen (JSON-Ausgabe), Fehlerausgabe unterdruecken
$raw = & $routed.FullName route --json $Prompt 2>$null
if ($LASTEXITCODE -ne 0 -or -not $raw) {
	Write-Error 'routed route Aufruf fehlgeschlagen.'
	exit 2
}

$json = ($raw -join "`n") | ConvertFrom-Json

# Kein Skill noetig -> Gate offen
$hits = @($json.selectedSkills)
if ($json.isNoSkill -or $hits.Count -eq 0) {
	Write-Host 'GATE OFFEN: kein Skill noetig - freie Bahn.'
	exit 0
}

# Treffer berichten -> Gate zu bis der Skill geladen ist
Write-Host ('GATE: {0} Skill-Treffer - vor der Antwort einladen und folgen:' -f $hits.Count)
foreach ($hit in $hits) {
	Write-Host ('  - id: {0} (score {1}, confidence {2})' -f $hit.skill.id, $hit.score, $hit.confidence)
	Write-Host ('    path: {0}' -f $hit.skill.path)
	Write-Host ('    MCP : get_skill id="{0}"' -f $hit.skill.id)
}
exit 1
