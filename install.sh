#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/.helicopter-harness"
PARENT="${1:-$(pwd)}"
PARENT_FULL="$(cd "$PARENT" && pwd)"
TARGET="$PARENT_FULL/.helicopter-harness"

if [ ! -d "$SOURCE" ]; then
  echo "Source harness not found: $SOURCE" >&2
  exit 1
fi

mkdir -p "$TARGET"
cp -R "$SOURCE"/. "$TARGET"/

AGENTS_PATH="$TARGET/AGENTS.md"
CLAUDE_PATH="$TARGET/CLAUDE.md"
AGENTS_SNIPPET="Read adapters/codex/AGENTS.md first, then HARNESS.md."
CLAUDE_SNIPPET="Read adapters/claude/CLAUDE.md first, then HARNESS.md."

if [ -e "$AGENTS_PATH" ]; then
  echo "AGENTS.md already exists at $AGENTS_PATH"
  echo "Append manually if desired:"
  echo "$AGENTS_SNIPPET"
else
  printf '%s\n' "$AGENTS_SNIPPET" > "$AGENTS_PATH"
fi

if [ -e "$CLAUDE_PATH" ]; then
  echo "CLAUDE.md already exists at $CLAUDE_PATH"
  echo "Append manually if desired:"
  echo "$CLAUDE_SNIPPET"
else
  printf '%s\n' "$CLAUDE_SNIPPET" > "$CLAUDE_PATH"
fi

for path in "$TARGET/HARNESS.md" "$TARGET/manifest.json" "$TARGET/skills" "$TARGET/adapters"; do
  if [ ! -e "$path" ]; then
    echo "Install validation failed: missing $path" >&2
    exit 1
  fi
done

cat <<EOF

Helicopter-Harness installed to:
  $TARGET

Next steps:
  1. Add repo profiles under $TARGET/profiles
  2. Start agents from $TARGET
  3. Use this first-run prompt:

Start from this parent workspace. Read HARNESS.md, identify the target repo, read its profile if present, then inspect repo-local docs. Update state/current-task.md before non-trivial edits. Task: <describe task>.
EOF

