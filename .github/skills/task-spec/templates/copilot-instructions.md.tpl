<!-- BEGIN:task-spec -->
# Task-Spec v2.1

When the user asks to "create a task", "scaffold a task", "decompose this into work", "make this executable for any agent", or provides fuzzy intent like "verify X works" — generate a Task-Spec v2.1 file following the format below.

Skip Task-Spec if: the request is L/XL effort (multi-week), the output is subjective (UX/copy/design), or the user just wants a one-off prompt.

## Format

Save as `tasks/T-<slug>.md`. Fill every `{{PLACEHOLDER}}` — leave none behind.

```markdown
---
id: T-<YYYYMMDD>-<slug>
title: <one-line imperative title>
status: ready
format_version: 2
effort: S  # S = ≤1 day | M = 1-3 days. Refuse L/XL — route to AgentSpec instead.
budget_iterations: 15
agent: any  # any | python-developer | kafka-developer | etc.
depends_on: []
touches_paths:
  - path/to/file/or/dir/
source_note: <meeting note | ticket | audit | verbal>
created: <YYYY-MM-DD>
tags: []
owner: (none)
priority: (none)
severity: bugfix  # cosmetic | refactor | feature | bugfix | security | financial-critical
due_date: (none)
precondition: (none)
blocked_reason: (none)
security_class: (none)
source_action_item: (none)
linear_ref: (none)
execution_backend: any  # any | claude | kimi | codex | cursor | agentspec | anthive | taskship
signed_off: false
signed_off_by: (none)
signed_off_at: (none)
---

# <title>

> **Why:** <one paragraph — the business or technical reason this work matters>

---

## Goal

<one paragraph — what done looks like, concrete and scoped>

---

## Context

<lean context, max 100 lines — background the executor needs, no more>

---

## Success Criteria

Each criterion is a runnable bash function returning 0 (pass) or non-zero (fail).
Each MUST be terminal (deterministic, idempotent, non-flaky).

\`\`\`bash
# eval-1: <description>
eval_1() {
  <bash that proves the work is done>
}

# eval-2: <description>
eval_2() {
  <bash that proves the work is done>
}

# eval-3: <description>
eval_3() {
  <bash that proves the work is done>
}
\`\`\`

---

## Validation Card

\`\`\`yaml
success_criteria:
  - id: eval_1
    description: <description>
    runnable: bash
    check_type: deterministic
    terminal: true
    expected_duration_sec: 5
  - id: eval_2
    description: <description>
    runnable: bash
    check_type: deterministic
    terminal: true
    expected_duration_sec: 5
  - id: eval_3
    description: <description>
    runnable: bash
    check_type: deterministic
    terminal: true
    expected_duration_sec: 5

retry_policy:
  max_iterations: 15
  circuit_breaker_no_progress: 3
  on_terminal_failure: park_with_context

agent_contract:
  version: 2
  read: [intent, contract, guardrails, operations]
  produce:
    - code
    - docs
    - config
    - tests
  required_tools: [git, bash]
  timeout_minutes: 30
  sandbox_type: host
  output_artifacts: []
  mcp_dependencies: []
  emit:
    - pass
    - fail
    - retry_with_reason
    - parked_with_context
  codex_metadata: {}
  kimi_metadata: {}
\`\`\`

---

## Exit Check

\`\`\`bash
eval_1 && eval_2 && eval_3
\`\`\`

---

## Rollback Plan

1. **Git revert** — `git revert --no-commit HEAD`
2. **File restore** — `git checkout -- <paths>`
3. **State reset** — set status to `parked`, record `blocked_reason`

<specific rollback steps, or: "(none — append-only task)">

---

## Observability Hooks

- **Expected duration:** <e.g. 2 min>
- **Key metric:** <what to watch>
- **Alert condition:** <when to worry>
- **Log tail:** <command to stream logs>

(or: "(none — no runtime observability required)")

---

## Anti-Patterns

- **Don't <action>** — <reason>. <what to do instead>.
- **Don't <action>** — <reason>. <what to do instead>.
- **Don't <action>** — <reason>. <what to do instead>.

---

## Do-Not-Touch

Files the executor MUST NOT modify:

- <path>

---

## Open Questions

1. **<question>** — <context>

(or: "(none — fully specified)")
```

## 6 Zones

| Zone | Section | Purpose |
|------|---------|---------|
| 1 | Why / Goal / Context | Intent and scoping |
| 2 | Success Criteria + Validation Card + Exit Check | Runnable bash evals — the proof of done |
| 3 | Rollback Plan | How to undo safely |
| 4 | Observability Hooks | What to watch during execution |
| 5 | Anti-Patterns + Do-Not-Touch | Guard rails for the executor |
| 6 | Open Questions | What to resolve during build |

## Severity threshold guide

| Severity | When to use |
|----------|-------------|
| cosmetic | doc typos, comment fixes |
| refactor | code shape changes with tests |
| feature | new behavior, scoped acceptance criteria |
| bugfix | correctness change with regression risk (default) |
| security | auth, cryptography, secrets |
| financial-critical | money fields, ledger, accounting |

## Validate and gate (no Claude needed)

```bash
# Lint structure
bash .claude/skills/task-spec/scripts/validate-task-spec.sh tasks/T-*.md

# Gate before delegating to any agent
bash .claude/skills/task-spec/scripts/safe-to-delegate.sh --stamp tasks/T-*.md
```
<!-- END:task-spec -->