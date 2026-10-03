# Deployt die erweiterten Meta-Skill-Fassungen an die Zielspeicherorte.
# Einmaliger Aktionsskript für die Skill-Erweiterung (nicht Teil der Task-Pipeline).

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$src = 'D:\freebuff-dev-setup\.freebuff\skill-extensions\using-superpowers.SKILL.md'
$dst = 'C:\Users\Max Hambi\.agents\skills\using-superpowers\SKILL.md'
$text = [System.IO.File]::ReadAllText($src)

# Body hinter dem schliessenden Frontmatter-Delimiter extrahieren
$idx = $text.IndexOf('---', 3) + 3
$body = $text.Substring($idx).TrimStart()

# .agents-Fassung: urspruengliches Metadaten-Frontmatter erhalten
$nl = [Environment]::NewLine
$front = '---' + $nl +
	'name: using-superpowers' + $nl +
	'description: "Use when starting any conversation - establishes how to find and use skills, requiring Skill tool invocation before ANY response including clarifying questions"' + $nl +
	'risk: unknown' + $nl +
	'source: community' + $nl +
	'date_added: "2026-02-27"' + $nl +
	'---' + $nl + $nl

[System.IO.File]::WriteAllText($dst, $front + $body, [System.Text.UTF8Encoding]::new($false))
Write-Host 'OK .agents copy written'

# Verifikation: Zeilenzahlen aller vier Ziele
$targets = @(
	'C:\Users\Max Hambi\.gemini\config\plugins\agent-skills\skills\using-agent-skills\SKILL.md',
	'C:\Users\Max Hambi\.gemini\config\plugins\superpowers\skills\using-superpowers\SKILL.md',
	'C:\Users\Max Hambi\.agents\skills\using-agent-skills\SKILL.md',
	$dst
)
foreach ($t in $targets) {
	$lines = [System.IO.File]::ReadAllLines($t).Count
	$first = ([System.IO.File]::ReadAllLines($t))[0]
	Write-Host ("{0} Zeilen | erste Zeile: {1} | {2}" -f $lines, $first, $t)
}
