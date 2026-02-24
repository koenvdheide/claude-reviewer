#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

# Uninstall mode
if [[ "${1:-}" == "--uninstall" ]]; then
    echo "Uninstalling claude-reviewer..."
    
    [[ -L "$CLAUDE_DIR/agents/reviewer.md" ]] && rm "$CLAUDE_DIR/agents/reviewer.md" && info "Removed agents/reviewer.md"
    
    echo ""
    warn "Agent memory at $CLAUDE_DIR/agent-memory/reviewer/ was NOT removed (contains your data)."
    warn "Remove the review protocol section from $CLAUDE_DIR/CLAUDE.md manually."
    echo ""
    echo "Done."
    exit 0
fi

echo "Installing claude-reviewer..."
echo ""

# Create directories
mkdir -p "$CLAUDE_DIR/agents"

# Symlink the reviewer agent
if [[ -e "$CLAUDE_DIR/agents/reviewer.md" ]] && [[ ! -L "$CLAUDE_DIR/agents/reviewer.md" ]]; then
    warn "agents/reviewer.md already exists and is not a symlink. Backing up to agents/reviewer.md.bak"
    mv "$CLAUDE_DIR/agents/reviewer.md" "$CLAUDE_DIR/agents/reviewer.md.bak"
fi
ln -sf "$SCRIPT_DIR/agents/reviewer.md" "$CLAUDE_DIR/agents/reviewer.md"
info "Linked agents/reviewer.md"


echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Add the contents of claude-md-snippet.md to your ~/.claude/CLAUDE.md"
echo "  2. (Optional) Add domain-specific checks from examples/domain-specific.md"
echo "     to agents/reviewer.md"
echo ""
echo "Usage:"
echo "  - In Claude Code, ask: \"review your last output using the reviewer agent\""
echo "  - The reviewer will log significant findings to ~/.claude/agent-memory/reviewer/MEMORY.md"
echo ""
echo "Curate MEMORY.md periodically to consolidate patterns and remove false positives!"
