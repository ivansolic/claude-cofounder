#!/usr/bin/env bash
#
# init-project.sh, Initialize a new Claude-ready project from your templates
#
# Usage:
#   init-project.sh <project-name>
#
# Requires templates in ~/.claude-templates/ (see INSTALL.md, Step 7)

set -euo pipefail

TEMPLATES_DIR="${CLAUDE_TEMPLATES_DIR:-$HOME/.claude-templates}"
PROJECT_NAME="${1:-}"

if [[ -z "$PROJECT_NAME" ]]; then
  echo "Usage: init-project.sh <project-name>"
  echo ""
  echo "Example: init-project.sh my-startup"
  exit 1
fi

if [[ -e "$PROJECT_NAME" ]]; then
  echo "Error: '$PROJECT_NAME' already exists in this directory."
  exit 1
fi

if [[ ! -d "$TEMPLATES_DIR" ]]; then
  echo "Error: Templates directory not found at $TEMPLATES_DIR"
  echo "See INSTALL.md Step 7 for first-time setup."
  exit 1
fi

REQUIRED_TEMPLATES=(
  "CLAUDE.md"
  "tasks/todo.md"
  "tasks/lessons.md"
  "agents/code-reviewer.md"
  "agents/architecture-reviewer.md"
  "agents/design-reviewer.md"
  "commands/commit-push.md"
  "commands/dev-handoff.md"
  "commands/setup-project.md"
  "commands/setup-design.md"
  "commands/retro.md"
  "docs/ADR-TEMPLATE.md"
  "design/tokens.json"
  "design/README.md"
)

MISSING=()
for template in "${REQUIRED_TEMPLATES[@]}"; do
  if [[ ! -f "$TEMPLATES_DIR/$template" ]]; then
    MISSING+=("$template")
  fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "Error: Missing templates in $TEMPLATES_DIR:"
  for t in "${MISSING[@]}"; do
    echo "  - $t"
  done
  exit 1
fi

echo "Creating project: $PROJECT_NAME"
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

echo "  → initializing git"
git init -q
git commit --allow-empty -m "chore: initial commit" -q
git branch -M main

echo "  → creating folder structure"
mkdir -p .claude/tasks .claude/agents .claude/commands
mkdir -p docs/prds docs/stories docs/decisions docs/research docs/templates
mkdir -p design

echo "  → copying templates"
cp "$TEMPLATES_DIR/CLAUDE.md" CLAUDE.md
cp "$TEMPLATES_DIR/tasks/todo.md" .claude/tasks/todo.md
cp "$TEMPLATES_DIR/tasks/lessons.md" .claude/tasks/lessons.md
cp "$TEMPLATES_DIR/agents/code-reviewer.md" .claude/agents/code-reviewer.md
cp "$TEMPLATES_DIR/agents/architecture-reviewer.md" .claude/agents/architecture-reviewer.md
cp "$TEMPLATES_DIR/agents/design-reviewer.md" .claude/agents/design-reviewer.md
cp "$TEMPLATES_DIR/commands/commit-push.md" .claude/commands/commit-push.md
cp "$TEMPLATES_DIR/commands/dev-handoff.md" .claude/commands/dev-handoff.md
cp "$TEMPLATES_DIR/commands/setup-project.md" .claude/commands/setup-project.md
cp "$TEMPLATES_DIR/commands/setup-design.md" .claude/commands/setup-design.md
cp "$TEMPLATES_DIR/commands/retro.md" .claude/commands/retro.md
cp "$TEMPLATES_DIR/docs/ADR-TEMPLATE.md" docs/templates/ADR-TEMPLATE.md
cp "$TEMPLATES_DIR/design/tokens.json" design/tokens.json
cp "$TEMPLATES_DIR/design/README.md" design/README.md

echo "  → writing .gitignore"
cat > .gitignore << 'GITIGNORE'
# Dependencies
node_modules/
.pnpm-store/

# Environment (NEVER commit)
.env
.env.local
.env.*.local

# Build artifacts
dist/
build/
.angular/
tmp/

# Coverage
coverage/
.nyc_output/

# IDE
.vscode/*
!.vscode/extensions.json
.idea/

# Claude local-only files
CLAUDE.local.md
.claude/local/

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*
pnpm-debug.log*
GITIGNORE

git add -A
git commit -m "chore: scaffold Claude-ready project structure" -q

echo ""
echo "✅ Project '$PROJECT_NAME' initialized."
echo ""
echo "Structure:"
echo "  $PROJECT_NAME/"
echo "  ├── CLAUDE.md"
echo "  ├── .claude/"
echo "  │   ├── agents/     (code-reviewer, architecture-reviewer, design-reviewer)"
echo "  │   ├── commands/   (setup-project, setup-design, commit-push, dev-handoff, retro)"
echo "  │   └── tasks/      (todo.md, lessons.md)"
echo "  ├── design/         (tokens.json, design system source of truth)"
echo "  └── docs/           (prds, stories, decisions, research, templates)"
echo ""
echo "PM work (PRDs, critique, stories) is driven by the pm-skills plugins:"
echo "  /pm-product-discovery:brainstorm-ideas-new   → explore the idea"
echo "  /pm-execution:create-prd                      → write the PRD"
echo "  /pm-execution:strategy-red-team + :pre-mortem → critique it"
echo "  /pm-execution:user-stories                    → break into stories"
echo "  (save outputs into docs/prds and docs/stories)"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  gh repo create $PROJECT_NAME --private --source=. --remote=origin --push"
echo "  claude"
echo ""
echo "Then, first thing inside Claude, configure the project for your stack:"
echo "  > /setup-project   (stack, commands, conventions → fills CLAUDE.md)"
echo "After the PM phase, before building UI, set up the design system:"
echo "  > /setup-design    (ingest your tokens or generate from PRD/personas → tokens.json)"
echo ""
