---
name: using-superpowers
description: Use when starting any conversation - establishes how to find and use skills, requiring skill invocation before ANY response including clarifying questions
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, ignore this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## The Rule

**Invoke relevant or requested skills BEFORE any response or action** — including clarifying questions, exploring the codebase, or checking files. If it turns out wrong for the situation, you don't have to use it.

**Before entering plan mode:** if you haven't already brainstormed, invoke the brainstorming skill first.

Then announce "Using [skill] to [purpose]" and follow the skill exactly. If it has a checklist, create a todo per item.

## Skill Discovery (which skill?)

The 1% rule decides *whether* to invoke. To find *which* skill applies, map the task to a phase first:

```
Don't know what you want yet?      → interview-me / brainstorming
New project/feature/change?        → spec-driven-development
Have a spec, need tasks?           → planning-and-task-breakdown
Implementing code?                 → incremental-implementation
Writing/running tests?             → test-driven-development
Something broke?                   → systematic-debugging
Reviewing code?                    → code-review-and-quality
Committing/branching?              → git-workflow-and-versioning
Logs/metrics/alerts?               → observability-and-instrumentation
Deploying/launching?               → shipping-and-launch
None of these fit?                 → routed fallback (below)
```

### Routed fallback (local index)

If no listed skill fits, or you need skills beyond the installed collections, route the prompt through the local `routed` index:

- MCP: `route_skill` with the task prompt → `get_skill` with the returned id.
- CLI: `routed route --json "<prompt>"` and read the `SKILL.md` at the returned path.

## Skill Priority

When multiple skills apply, process skills come first — they set the approach, then implementation skills (frontend-design, etc.) carry it out. Brainstorming and systematic-debugging are Superpowers' most common process skills, but the rule holds for any of them.

- "Let's build X" → superpowers:brainstorming first, then implementation skills.
- "Fix this bug" → superpowers:systematic-debugging first, then domain skills.

## Operating Behaviors (apply inside every skill)

- Surface assumptions before non-trivial work so the user can correct them early.
- Stop and name confusion instead of silently picking an interpretation.
- Push back on bad approaches with concrete downsides; accept informed overrides.
- Prefer the boring, simple solution; resist over-engineering.
- Scope discipline: touch only what the task requires, no unsolicited renovation.
- Verify with evidence — tests, build output, runtime data. "Looks right" is not done.

The `using-agent-skills` meta-skill details these behaviors plus the full development-phase lifecycle.

## When to Drop an Invoked Skill

Invocation is not obedience. If the skill's premise does not hold — wrong domain, required inputs are missing, or it contradicts user instructions — announce that and proceed without it instead of forcing a mismatched checklist.

## Red Flags

These thoughts mean STOP—you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I can check git/files quickly" | Files lack conversation context. Check for skills. |
| "Let me gather information first" | Skills tell you HOW to gather information. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "This doesn't count as a task" | Action = task. Check for skills. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "This feels productive" | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means" | Knowing the concept ≠ using the skill. Invoke it. |

## Platform Adaptation

If your harness appears here, read its reference file for special instructions:

- Codex: `references/codex-tools.md`
- Pi: `references/pi-tools.md`
- Antigravity: `references/antigravity-tools.md`
- Gemini: `references/gemini-tools.md`
- Hermes Agent: `references/hermes-tools.md`

## User Instructions

User instructions (CLAUDE.md, AGENTS.md, GEMINI.md, etc, direct requests) take precedence over skills, which in turn override default behavior. Only skip skill workflows or instructions when your human partner has explicitly told you to.
