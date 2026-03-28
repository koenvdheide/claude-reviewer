param([switch]$Uninstall)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = "$HOME\.claude"
$allLinked = $true

function Info($msg) { Write-Host "[OK] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "[!!] $msg" -ForegroundColor Yellow }
function Fail($msg) { Write-Host "[XX] $msg" -ForegroundColor Red; exit 1 }

function Require-File($path) {
    if (-not (Test-Path $path -PathType Leaf)) {
        Fail "Missing required file: $path"
    }
}

if ($Uninstall) {
    Write-Host "Uninstalling claude-reviewer..."

    $target = "$ClaudeDir\agents\reviewer.md"
    if (Test-Path $target) {
        Remove-Item $target -Force
        Info "Removed agents/reviewer.md"
    }

    $skillTarget = "$ClaudeDir\skills\qa\SKILL.md"
    if (Test-Path $skillTarget) {
        Remove-Item $skillTarget -Force
        Info "Removed skills/qa/SKILL.md"
    }

    Remove-Item "$ClaudeDir\skills\qa" -Force -ErrorAction SilentlyContinue
    Remove-Item "$ClaudeDir\skills" -Force -ErrorAction SilentlyContinue

    Write-Host ""
    Warn "Reviewer memory was not removed."
    Warn "Any project-level hook files in .claude/ directories were not removed."
    Write-Host ""
    Write-Host "Done."
    exit 0
}

Write-Host "Installing claude-reviewer..."
Write-Host ""

$source = "$ScriptDir\agents\reviewer.md"
$skillSource = "$ScriptDir\skills\qa\SKILL.md"
$hookSettings = "$ScriptDir\.claude\settings.json"
$hookScript = "$ScriptDir\.claude\hooks\protect-files.sh"

Require-File $source
Require-File $skillSource
Require-File $hookSettings
Require-File $hookScript

New-Item -ItemType Directory -Force -Path "$ClaudeDir\agents" | Out-Null
New-Item -ItemType Directory -Force -Path "$ClaudeDir\skills\qa" | Out-Null

$target = "$ClaudeDir\agents\reviewer.md"
$existing = Get-Item $target -ErrorAction SilentlyContinue
if ($existing -and $existing.LinkType -ne "SymbolicLink") {
    Warn "agents/reviewer.md already exists and is not a symlink. Backing up to agents/reviewer.md.bak"
    Move-Item $target "$target.bak" -Force
}

try {
    New-Item -ItemType SymbolicLink -Path $target -Target $source -Force | Out-Null
    Info "Linked agents/reviewer.md (symlink)"
} catch {
    Copy-Item $source $target -Force
    Warn "Copied agents/reviewer.md (symlink failed - enable Developer Mode or run elevated for a live link)"
    $allLinked = $false
}

$skillTarget = "$ClaudeDir\skills\qa\SKILL.md"
$existingSkill = Get-Item $skillTarget -ErrorAction SilentlyContinue
if ($existingSkill -and $existingSkill.LinkType -ne "SymbolicLink") {
    Warn "skills/qa/SKILL.md already exists and is not a symlink. Backing up to SKILL.md.bak"
    Move-Item $skillTarget "$skillTarget.bak" -Force
}

try {
    New-Item -ItemType SymbolicLink -Path $skillTarget -Target $skillSource -Force | Out-Null
    Info "Linked skills/qa/SKILL.md (symlink)"
} catch {
    Copy-Item $skillSource $skillTarget -Force
    Warn "Copied skills/qa/SKILL.md (symlink failed)"
    $allLinked = $false
}

Write-Host ""
Write-Host "Installation complete!"
Write-Host ""
Write-Host "Installed globally to $ClaudeDir"
Write-Host "  - reviewer subagent"
Write-Host "  - /qa skill"
Write-Host ""
Write-Host "To enable automatic review in a project"
Write-Host "  1. Copy .claude\settings.json into that project's .claude\ directory"
Write-Host "  2. Copy .claude\hooks\protect-files.sh into that project's .claude\hooks\ directory"
Write-Host "  3. Ensure the hook script is executable in your shell environment"
Write-Host ""
Write-Host "Usage"
Write-Host "  - Type /qa in Claude Code to invoke the skill"
Write-Host "  - Or ask: ""use the reviewer subagent to review your last output"""
Write-Host "  - The reviewer may store recurring patterns in its memory area"
Write-Host ""

if (-not $allLinked) {
    Warn "One or more files were copied instead of symlinked. Re-run install.ps1 after pulling updates to keep them current."
}

Write-Host "The reviewer self-curates its memory. Check ~\.claude\agent-memory\reviewer\MEMORY.md occasionally to remove stale heuristics."
