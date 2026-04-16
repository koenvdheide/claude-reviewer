# claude-reviewer

A Claude Code reviewer package that automatically QA-checks risky outputs through **hooks** and also provides a reusable `reviewer` subagent plus `/qa` skill for manual review.

It is built to catch concrete correctness failures such as:

- wrong counts and stale totals
- duplicate entries or repeated IDs
- unresolved references and numbering drift
- invalid JSON / YAML / XML / CSV structure
- contradictions within the output
- unsupported additions when source material is available

What makes this more useful than a one-off review prompt is the combination of:

- a dedicated reviewer subagent running in its own context
- automatic hook-based gating for risky outputs
- persistent reviewer memory for recurring failure patterns

## What's included

| File | Purpose |
| --- | --- |
| `agents/reviewer.md` | Reviewer subagent definition |
| `skills/qa/SKILL.md` | `/qa` skill that invokes the reviewer |
| `.claude/settings.json` | Example project-level hook configuration for automatic review |
| `.claude/hooks/protect-files.sh` | Example `PreToolUse` guard for protected files |
| `examples/domain-specific.md` | Example domain-specific review checks |
| `install.sh` | Installer for macOS / Linux / WSL |
| `install.ps1` | Installer for Windows (PowerShell) |


## Installation

### macOS / Linux / WSL

```bash
git clone https://github.com/koenvdheide/claude-reviewer.git
cd claude-reviewer
chmod +x install.sh
./install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/koenvdheide/claude-reviewer.git
cd claude-reviewer
powershell -ExecutionPolicy Bypass -File install.ps1
```

> **Note:** Symlink creation on Windows may require Developer Mode (Settings → Privacy & Security → For Developers) or an elevated PowerShell session with administrator privileges.
If symlink creation fails, the installer falls back to copying files instead.
If files were copied rather than linked, re-run the install script after pulling updates to keep them current.
>
> On Windows, `~/.claude/` maps to `%USERPROFILE%\.claude\`.

> **Note:** `jq` is recommended for JSON validation
> (`brew install jq` / `apt install jq` / `winget install jqlang.jq`).
> If unavailable, the reviewer degrades gracefully to manual inspection with lower confidence.

## How it works

### Manual review

You can invoke the reviewer directly in any Claude Code session:

- Type **`/qa`** in Claude Code
- Ask Claude to **"use the reviewer subagent to review your last output"**
- Ask Claude to review a specific file, such as `output.json`

The reviewer runs in a **separate context** from the generating agent, which helps avoid shared blind spots.

### Automatic review through hooks

Automatic review is configured at the **project level** through `.claude/settings.json` and companion hook scripts.

The included example hook configuration does three things:

1. **Selective Stop gate**
   - only reviews answers that look risky enough to justify QA
   - examples: structured-data blocks, long inventories, exact count claims, citations, or generated output files
   - blocks stopping only for **confirmed concrete errors**, not for softer verification flags

2. **PostToolUse review after `Edit` / `Write`**
   - automatically checks newly written artifacts for structural failures, stale totals, duplicates, numbering drift, and contradictions

3. **PreToolUse protection for sensitive paths**
   - blocks edits to protected files such as `.env`, `.git/*`, or Claude settings files

## Hook setup

The repo includes a sample project-level hook configuration in:

- `.claude/settings.json`
- `.claude/hooks/protect-files.sh`

To use automatic review in a project:

1. copy or adapt those files into your project's `.claude/` directory
2. make the shell hook executable on macOS / Linux / WSL:

```bash
chmod +x .claude/hooks/protect-files.sh
```

3. adjust the protected-path rules and hook prompts to match your workflow if needed

## Reviewer memory

The reviewer uses persistent subagent memory.

Only significant recurring patterns should be logged, for example:

- date-range truncation
- repeated stale totals after list growth
- citation drift across batched records
- recurring duplicate-ID reuse patterns

Memory is scoped to **user level** by default (`memory: user` in `agents/reviewer.md`), which means the reviewer shares one memory across all your projects. If you'd prefer project-scoped memory instead, change `memory: user` to `memory: project` in `agents/reviewer.md`.

The reviewer self-curates its memory — it stores only one-line detection heuristics in a single `MEMORY.md` file (capped at 500 lines), consolidating or removing entries when the budget is exceeded. You can review `~/.claude/agent-memory/reviewer/MEMORY.md` occasionally to remove stale heuristics or add your own.

## Permissions & safety

The reviewer subagent intentionally does **not** have Claude `Edit` or `Write` tools for project files. Its tool access is limited to:

- `Read`
- `Grep`
- `Glob`
- `Bash(jq *)`

This means it is primarily read-only for project work, while still being able to maintain its own subagent memory.

If you want stronger repo-wide protection, keep the included `PreToolUse` hook enabled. That protects the whole workflow, not just the reviewer subagent.


## Usage examples

General review:

```text
Use the reviewer agent to review your last output
```

Target a specific concern:

```text
Use the reviewer agent, focus on duplicate detection and JSON validity
```

Review a file:

```text
Use the reviewer agent to check output.json for structural issues and hallucinations
```

### Slash command

If the `/qa` skill is installed, use:

```text
/qa
```

## Customization

### Adding domain-specific checks

The generic checklist misses domain-specific issues. See `examples/domain-specific.md` for inspiration, then add your own checks to the `Domain-Specific Checks` section of `agents/reviewer.md`.

### Tuning automatic gating

The included `Stop` hook is intentionally selective. Tighten it if you only want review for large structured deliverables, or loosen it if you want more aggressive QA coverage.

### Using a different model

The reviewer works best when run on a different model than the one that generated the output. By default, the agent is configured to use Sonnet, which catches different errors than Opus and is cheaper to run. Change the `model` field in the frontmatter of `agents/reviewer.md` to use a different model.

## Uninstall

**macOS / Linux / WSL:**

```bash
cd claude-reviewer
./install.sh --uninstall
```

**Windows:**

```powershell
cd claude-reviewer
powershell -ExecutionPolicy Bypass -File install.ps1 -Uninstall
```

This removes the installed reviewer subagent and `/qa` skill from `~/.claude/`.
It does **not** remove any project-level hook files you copied into `.claude/` directories.

## Troubleshooting

- **Verify the subagent loaded**: run `/agents` in Claude Code and confirm `reviewer` appears.
- **Verify the skill loaded**: run `/qa`.
- **Check permissions**: run `/permissions` to confirm tool access.
- **Inspect hooks**: confirm the project contains `.claude/settings.json` and any referenced hook scripts.
- **Health check**: run `/doctor` for installation diagnostics.

## Contributing

The most valuable contributions are **new review checks** based on real errors you've encountered. If the reviewer missed something, open an issue or PR describing:

1. What the error was
2. Why the current checklist didn't catch it
3. What check would catch it in the future

## License

MIT
