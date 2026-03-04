#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
ALL_LINKED=true

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

require_file() {
    local path="$1"
    if [[ ! -f "$path" ]]; then
        error "Missing required file: $path"
        exit 1
    fi
}

link_or_copy() {
    local source="$1"
    local target="$2"
    local label="$3"

    if ln -sf "$source" "$target" 2>/dev/null; then
        info "Linked $label"
    else
        cp "$source" "$target"
        warn "Copied $label (symlink failed)"
        ALL_LINKED=false
    fi
}

if [[ "${1:-}" == "--uninstall" ]]; then
    echo "Uninstalling claude-reviewer..."

    [[ -e "$CLAUDE_DIR/agents/reviewer.md" ]] && rm -f "$CLAUDE_DIR/agents/reviewer.md" && info "Removed agents/reviewer.md"
    [[ -e "$CLAUDE_DIR/skills/qa/SKILL.md" ]] && rm -f "$CLAUDE_DIR/skills/qa/SKILL.md" && info "Removed skills/qa/SKILL.md"

    rmdir "$CLAUDE_DIR/skills/qa" 2>/dev/null || true
    rmdir "$CLAUDE_DIR/skills" 2>/dev/null || true

    echo ""
    warn "Reviewer memory was not removed."
    warn "Any project-level hook files in .claude/ directories were not removed."
    echo ""
    echo "Done."
    exit 0
fi

echo "Installing claude-reviewer..."
echo ""

require_file "$SCRIPT_DIR/agents/reviewer.md"
require_file "$SCRIPT_DIR/skills/qa/SKILL.md"
require_file "$SCRIPT_DIR/.claude/settings.json"
require_file "$SCRIPT_DIR/.claude/hooks/protect-files.sh"

mkdir -p "$CLAUDE_DIR/agents"
mkdir -p "$CLAUDE_DIR/skills/qa"

if [[ -e "$CLAUDE_DIR/agents/reviewer.md" && ! -L "$CLAUDE_DIR/agents/reviewer.md" ]]; then
    warn "agents/reviewer.md already exists and is not a symlink. Backing up to agents/reviewer.md.bak"
    mv "$CLAUDE_DIR/agents/reviewer.md" "$CLAUDE_DIR/agents/reviewer.md.bak"
fi

if [[ -e "$CLAUDE_DIR/skills/qa/SKILL.md" && ! -L "$CLAUDE_DIR/skills/qa/SKILL.md" ]]; then
    warn "skills/qa/SKILL.md already exists and is not a symlink. Backing up to SKILL.md.bak"
    mv "$CLAUDE_DIR/skills/qa/SKILL.md" "$CLAUDE_DIR/skills/qa/SKILL.md.bak"
fi

link_or_copy "$SCRIPT_DIR/agents/reviewer.md" "$CLAUDE_DIR/agents/reviewer.md" "agents/reviewer.md"
link_or_copy "$SCRIPT_DIR/skills/qa/SKILL.md" "$CLAUDE_DIR/skills/qa/SKILL.md" "skills/qa/SKILL.md"

echo ""
echo "Installation complete!"
echo ""
echo "Installed globally to ~/.claude/:"
echo "  - reviewer subagent"
echo "  - /qa skill"
echo ""
echo "Automatic reviewing now uses project-level hooks, not a CLAUDE.md snippet."
echo "To enable automatic review in a project:"
echo "  1. Copy .claude/settings.json into that project's .claude/ directory"
echo "  2. Copy .claude/hooks/protect-files.sh into that project's .claude/hooks/ directory"
echo "  3. chmod +x .claude/hooks/protect-files.sh"
echo ""
echo "Usage:"
echo "  - Type /qa in Claude Code to invoke the skill"
echo "  - Or ask: \"use the reviewer subagent to review your last output\""
echo "  - The reviewer may store recurring patterns in its memory area"
echo ""

if [[ "$ALL_LINKED" != true ]]; then
    warn "One or more files were copied instead of symlinked. Re-run install.sh after pulling updates to keep them current."
fi

echo "Curate reviewer memory periodically to consolidate patterns and remove false positives!"
