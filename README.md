# Claude Code Skills — GitHub Copilot Compatible

Two Claude Code skills adapted to work with **GitHub Copilot** via `.github/copilot-instructions.md`.

Both skills emit their output into a single file that Copilot reads automatically on every suggestion. Section markers keep the two skills independent — running one never overwrites the other.

---

## Skills

### `task-spec` — Task-Spec v2.1 generator

Generates atomic, vendor-portable, self-verifying task files (`tasks/T-*.md`) that any agent (Claude, Codex, Kimi, Copilot) can pick up and execute.

**What Copilot gets:** the full Task-Spec template, trigger phrases, zone explanations, severity guide, and validate/gate commands — so Copilot can generate valid `T-*.md` files when you ask.

**Emit Copilot instructions:**
```bash
TARGET_REPO=/path/to/your/project \
  bash .github/skills/task-spec/scripts/emit-copilot.sh
```

**Validate and gate without Claude:**
```bash
bash .github/skills/task-spec/scripts/validate-task-spec.sh tasks/T-*.md
bash .github/skills/task-spec/scripts/safe-to-delegate.sh --stamp tasks/T-*.md
```

**Dependencies:** `bash`, `python3`. No Claude subscription needed to run the scripts.

---

### `agents-kbs-tech-stack` — Tech-stack agent fleet scaffold

Scaffolds a paired architect + developer + troubleshooter agent per technology, each grounded in a curated KB tree. Three universal closer agents (code-reviewer, code-simplifier, code-documenter) are wired into every domain.

**What Copilot gets:** an agents table, a KB domains table with quick-reference links — so Copilot knows which agent context and conventions apply per domain.

**Scaffold a tech (requires Claude Code):**
```bash
TARGET_REPO=/path/to/your/project \
  bash .github/skills/agents-kbs-tech-stack/scripts/scaffold.sh
```

**Emit Copilot instructions (no Claude needed):**
```bash
TARGET_REPO=/path/to/your/project \
  bash .github/skills/agents-kbs-tech-stack/scripts/emit-cross-tool.sh
```

Also emits `AGENTS.md` (cross-tool agent index) and `.cursor/rules/agents-kbs-tech-stack.mdc` (Cursor shim).

**Dependencies:** `bash`, `python3`, `pyyaml`. No Claude subscription needed.

---

## Copilot integration

After running the emit scripts, your repo will have:

```
.github/
  copilot-instructions.md   ← Copilot reads this automatically
AGENTS.md                   ← cross-tool agent index
.cursor/
  rules/
    agents-kbs-tech-stack.mdc  ← Cursor shim
```

The `copilot-instructions.md` uses section markers so both skills coexist:

```
<!-- BEGIN:agents-kbs-tech-stack --> ... <!-- END:agents-kbs-tech-stack -->
<!-- BEGIN:task-spec -->             ... <!-- END:task-spec -->
```

Re-running either emit script replaces only its own section.

---

## Using on a machine without Claude

The bash scripts are self-contained (`bash` + `python3` + `pyyaml`). Copy the skill folder and run:

```bash
# Copy to target machine (USB, email, internal repo)
cp -r .github/skills/task-spec /tmp/transfer/
cp -r .github/skills/agents-kbs-tech-stack /tmp/transfer/

# On the target machine
TARGET_REPO=/path/to/project bash /tmp/transfer/task-spec/scripts/emit-copilot.sh
TARGET_REPO=/path/to/project bash /tmp/transfer/agents-kbs-tech-stack/scripts/emit-cross-tool.sh
```

No internet, no subscription, no Claude Code required.

---

## Folder layout

```
.github/
  agents/
    caw-architect.md          ← CAW triad architect agent
    task-architect.md         ← Task-Spec judgment agent
  skills/
    task-spec/                ← Task-Spec v2.1 skill
      scripts/
        emit-copilot.sh       ← Copilot emit
        generate-task-spec.sh
        validate-task-spec.sh
        safe-to-delegate.sh
        ...
      templates/
        copilot-instructions.md.tpl
        task-spec.md.tpl
    agents-kbs-tech-stack/    ← Agent fleet scaffold skill
      scripts/
        emit-cross-tool.sh    ← emits Copilot section + AGENTS.md + Cursor
        scaffold.sh
        ...
      templates/
        copilot-instructions.md.tpl
        architect.md.tpl
        developer.md.tpl
        ...
```
