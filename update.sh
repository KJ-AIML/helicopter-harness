#!/usr/bin/env bash
set -euo pipefail

RESET_STATE=0
PARENT=""

for arg in "$@"; do
  case "$arg" in
    --reset-state) RESET_STATE=1 ;;
    *) PARENT="$arg" ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/.helicopter-harness/HARNESS.md" ]; then
  SOURCE="$SCRIPT_DIR/.helicopter-harness"
elif [ -f "$(pwd)/.helicopter-harness/HARNESS.md" ]; then
  SOURCE="$(pwd)/.helicopter-harness"
else
  echo "No local repository checkout with .helicopter-harness was found." >&2
  echo "Update by cloning or entering the repo checkout, running git pull, then:" >&2
  echo "  ./update.sh <parent-workspace>" >&2
  exit 1
fi

if [ -n "$PARENT" ]; then
  PARENT_FULL="$(cd "$PARENT" && pwd)"
  TARGET="$PARENT_FULL/.helicopter-harness"
else
  CWD="$(pwd)"
  if [ "$(basename "$CWD")" = ".helicopter-harness" ] || [ -f "$CWD/HARNESS.md" ]; then
    TARGET="$CWD"
  else
    TARGET="$CWD/.helicopter-harness"
  fi
fi

if [ ! -d "$TARGET" ]; then
  echo "Target harness does not exist: $TARGET. Run install.sh first." >&2
  exit 1
fi

TMP_STATE=""
if [ "$RESET_STATE" -eq 0 ] && [ -d "$TARGET/state" ]; then
  TMP_STATE="$(mktemp -d)"
  cp -R "$TARGET/state" "$TMP_STATE/state"
fi

if [ "$RESET_STATE" -eq 1 ]; then
  cp -R "$SOURCE"/. "$TARGET"/
else
  find "$SOURCE" -mindepth 1 -maxdepth 1 ! -name state -exec cp -R {} "$TARGET"/ \;
fi

if [ -n "$TMP_STATE" ]; then
  rm -rf "$TARGET/state"
  cp -R "$TMP_STATE/state" "$TARGET/state"
  rm -rf "$TMP_STATE"
fi

echo "Updated Helicopter-Harness at $TARGET"
if [ "$RESET_STATE" -eq 0 ]; then
  echo "Preserved state/. Use --reset-state to replace state from the repo checkout."
fi
echo "AGENTS.md and CLAUDE.md were not modified."

