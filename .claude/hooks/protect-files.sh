#!/usr/bin/env bash
set -euo pipefail

INPUT="$(cat)"

FILE="$({ echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // .tool_input.target // .tool_input.filename // ""'; } )"

if [[ -z "${FILE}" || "${FILE}" == "null" ]]; then
  exit 0
fi

DENY_GLOBS=(
  ".env"
  ".env.*"
  ".git/*"
  ".git/**"
  ".claude/settings.json"
  ".claude/settings.local.json"
  "**/secrets/**"
  "**/*_secret*"
  "**/*_key*"
  "**/*token*"
  "**/*password*"
)

shopt -s globstar nullglob extglob 2>/dev/null || true

for GLOB in "${DENY_GLOBS[@]}"; do
  if [[ "$FILE" == $GLOB ]]; then
    cat <<JSON
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Blocked Edit/Write to protected path: '$FILE' (matched rule: '$GLOB'). If you need a change here, make it manually or update the protection policy deliberately."
  }
}
JSON
    exit 0
  fi
done

exit 0
