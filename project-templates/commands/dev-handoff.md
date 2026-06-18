---
description: Transition from PM phase to development phase. Verifies the spec is ready, summarizes PM decisions into the task file, creates a feature branch, and opens VS Code. Use when discovery/PRD work is done and you're ready to build.
---

Execute the following steps in order. If any step reveals a problem, STOP and report it.

## 1. Identify what we're building
Ask the user (unless already clear from conversation):

> "Which spec are we handing off to development? Give me the PRD or story path (e.g. `docs/prds/PRD-003-onboarding.md`), or say 'no spec' if this is small enough to skip."

## 2. Verify spec readiness (skip if 'no spec')
Read the referenced PRD or story. These specs are produced by the pm-skills
plugins (`/pm-execution:create-prd`, `/pm-execution:user-stories`), so check for
substance, not for exact section names.

For a **PRD**, confirm it has:
- [ ] A clear problem / background, who hurts and why now (not placeholder text)
- [ ] A measurable objective or Key Result, how we'll know it worked
- [ ] A solution with the key features described
- [ ] Assumptions flagged, what's believed but not yet validated

For a **story**, confirm it has:
- [ ] A description in "As a / I want / So that" form
- [ ] Acceptance criteria that are observable and testable

If any check fails:
- STOP
- Tell the user exactly what's missing
- Ask: "Fill this in first, or proceed anyway with the gap noted?"

## 3. Write the handoff summary into the task file
Update `.claude/tasks/todo.md` with:

```markdown
# Active Task

## Task
[One-sentence description derived from the spec]

## Context
- Spec: [path to PRD/story]
- Key PM decisions made during discovery:
  - [decision 1, pulled from this conversation]
  - [decision 2]
  - [...]
- Out of scope (do NOT build):
  - [from spec's out-of-scope section]

## Plan
- [ ] (to be filled in plan mode at development start)

## Notes

## Review
```

Show the summary to the user for approval before writing.

## 4. Create the feature branch
Derive a branch name from the spec:
- PRD-003-onboarding → `feature/onboarding`
- Or ask the user if the name isn't obvious

Run:
```bash
git checkout main
git pull
git checkout -b feature/<name>
```

If `git pull` fails because no remote exists, note it and continue (user may not have pushed yet).

## 5. Open VS Code
Run:
```bash
code .
```

If `code` command is not found, tell the user:
> "VS Code CLI not installed. In VS Code: Cmd+Shift+P → 'Shell Command: Install code command in PATH'. Opening skipped, open VS Code manually."

## 6. Set the development frame
Tell the user:

> "Handoff complete:
> - Branch: `feature/<name>`
> - Task seeded in `.claude/tasks/todo.md`
> - Spec: [path]
> - VS Code open
>
> Development phase starts now. Enter plan mode (Shift+Tab twice) and I'll draft the implementation plan from the spec."

## Safety Rules
- Never create the branch from anything other than up-to-date main (unless user explicitly says otherwise)
- Never skip the spec readiness check silently, gaps must be acknowledged
- Never overwrite an existing in-progress task in todo.md without asking
