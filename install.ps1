param([switch]$Uninstall)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = "$HOME\.claude"

function info($msg) { Write-Host "v $msg" -ForegroundColor Green }
function warn($msg) { Write-Host "! $msg" -ForegroundColor Yellow }

if ($Uninstall) {
    Write-Host "Uninstalling claude-reviewer..."

    $target = "$ClaudeDir\agents\reviewer.md"
    if (Test-Path $target) {
        Remove-Item $target -Force
        info "Removed agents/reviewer.md"
    }

    Write-Host ""
    warn "Agent memory at $ClaudeDir\agent-memory\reviewer\ was NOT removed (contains your data)."
    warn "Remove the review protocol section from $ClaudeDir\CLAUDE.md manually."
    Write-Host ""
    Write-Host "Done."
    exit 0
}

Write-Host "Installing claude-reviewer..."
Write-Host ""

# Create directories
New-Item -ItemType Directory -Force -Path "$ClaudeDir\agents" | Out-Null

# Symlink the reviewer agent (fall back to copy if symlinks are unavailable)
$target = "$ClaudeDir\agents\reviewer.md"
$source = "$ScriptDir\agents\reviewer.md"

$existing = Get-Item $target -ErrorAction SilentlyContinue
if ($existing -and $existing.LinkType -ne "SymbolicLink") {
    warn "agents/reviewer.md already exists and is not a symlink. Backing up to agents/reviewer.md.bak"
    Move-Item $target "$target.bak" -Force
}

$linked = $false
try {
    New-Item -ItemType SymbolicLink -Path $target -Target $source -Force | Out-Null
    info "Linked agents/reviewer.md (symlink)"
    $linked = $true
} catch {
    Copy-Item $source $target -Force
    warn "Copied agents/reviewer.md (symlink failed — enable Developer Mode or run as Administrator for a live link)"
}

Write-Host ""
Write-Host "Installation complete!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Add the contents of claude-md-snippet.md to your $ClaudeDir\CLAUDE.md"
Write-Host "  2. (Optional) Add domain-specific checks from examples\domain-specific.md"
Write-Host "     to agents\reviewer.md"
Write-Host ""
Write-Host "Usage:"
Write-Host "  - In Claude Code, ask: ""review your last output using the reviewer agent"""
Write-Host "  - The reviewer will log significant findings to $ClaudeDir\agent-memory\reviewer\MEMORY.md"
Write-Host ""
Write-Host "Curate MEMORY.md periodically to consolidate patterns and remove false positives!"

if (-not $linked) {
    Write-Host ""
    warn "You have a copy, not a symlink. Re-run install.ps1 after pulling updates to keep it current."
}
