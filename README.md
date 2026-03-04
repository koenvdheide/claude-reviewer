# claude-reviewer

A global Claude Code subagent that reviews AI-generated output for common LLM errors: miscounting, duplicate entries, hallucinated content, and internal inconsistencies.

What makes this different from a one-off review prompt is the **persistent memory feedback loop** — the reviewer logs significant errors it catches to its agent memory, which is automatically loaded before each review. Over time, it gets better at catching the specific failure modes *you* encounter.

## Why use it

Claude is often strong at drafting but weaker at tedious verification. This reviewer is meant to catch the kinds of issues that slip through when output is long, structured, or derived from source material.

Typical failure modes it helps catch:

- “12 items” stated, but only 11 are present
- duplicated rows or repeated entities
- JSON that looks right but does not parse cleanly
- references to sections or IDs that do not exist
- stale totals after edits
- internal contradictions between summary and details

## How it works

The package provides:

- a `reviewer` subagent
- a `/qa` slash command that calls the reviewer
- an optional `CLAUDE.md` snippet that encourages lightweight self-checking and escalation to the reviewer

The reviewer runs as a **background subagent**. This is intentional: QA work is often verbose and mechanical, and isolated background execution keeps that noise out of the main thread while still returning a concise result. Claude Code subagents are explicitly designed to run in isolated contexts and return summaries to the parent session.

## Installation

The installer symlinks reviewer.md and the QA SKILL.md in this checkout to your Claude Code directory:

agents/reviewer.md to ~/.claude/agents/reviewer.md

skills/qa/SKILL.md to ~/.claude/skills/qa/SKILL.md

After this symlink, the reviewer is available across your projects as a user-level subagent. This symlink lets you easily pull new updates without having to mess around with your Claude Code directory.

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
If files were copied rather than linked, re-run install.ps1 after pulling updates to keep them current.
> re-run `install.ps1` after pulling updates to keep it current.
>
> On Windows, `~/.claude/` maps to `%USERPROFILE%\.claude\`.

---

Then add the contents of `claude-md-snippet.md` to your `~/.claude/CLAUDE.md`.

> **Note:** `jq` is recommended for JSON validation
> (`brew install jq` / `apt install jq` / `winget install jqlang.jq`).
> If unavailable, the reviewer degrades gracefully to manual inspection with lower confidence.

## Usage

You can invoke the reviewer in three ways:

### 1. Manual subagent invocation

Ask Claude Code to use the reviewer directly:

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

### 2. Slash command

If the skill is installed, use:

```text
/qa
```

This tells Claude Code to invoke the reviewer subagent on the latest output.

### 3. Prompted review via CLAUDE.md

You can add the supplied claude-md-snippet.md section to your ~/.claude/CLAUDE.md. This encourages Claude Code to run a lightweight self-check on structured outputs and escalate to the reviewer for higher-risk outputs.

## Agent memory

After each review, the reviewer updates its Claude Code memory with significant findings. Only errors that are **systematic** (likely to recur), **silent** (would have gone unnoticed), and **substantive** (affect correctness) get logged.

Before each review, that memory is automatically loaded into the reviewer's context. This creates a feedback loop: catch error -> log it -> check for it next time.

Memory is scoped at the **user level** (`memory: user` in the frontmatter). In practice, that gives the reviewer one persistent Claude Code memory area across your work, but it does **not** force everything into one monolithic log. You can keep separate memory files for different projects or topics inside that area, with `MEMORY.md` acting as a short index and cross-project pattern summary. This preserves global learning while still keeping project-specific notes separate. See the [Claude Code subagent memory docs](https://code.claude.com/docs/en/sub-agents#enable-persistent-memory) for details.

**Important:** Periodically curate the memory yourself — consolidate recurring patterns, delete false positives, keep it concise. The loop only works if the data is clean.

### Permissions & safety

`memory: user` causes Claude Code to automatically enable Read, Write, and Edit for the subagent so it can maintain its memory files. The reviewer prompt restricts writes to the memory directory only, but if you want a hard boundary, add this to `~/.claude/settings.json`:

```json
{
  "permissions": {
    "deny": ["Edit(./**)", "Write(./**)"]
  }
}
```

This blocks edits inside any working directory while leaving `~/.claude/` (where agent memory lives) unaffected.

### Auto-review (optional)

The `claude-md-snippet.md` includes an optional instruction that triggers the reviewer automatically when output meets any of four criteria: longer than 50 lines, contains structured data, contains numbered lists with more than 10 items, or involves data from external sources. Remove or adjust these if you find them too aggressive. Note: this is a prompted protocol, not a guaranteed hook — the model may skip it on short or simple responses.

## Customization

### Adding domain-specific checks

The generic checklist misses domain-specific issues. Add checks specific to your work to catch these. See `examples/domain-specific.md` for inspiration, then add your own to the reviewer agent under the `Domain-Specific Checks` section.

### Adjusting the logging threshold

If the memory is too noisy, tighten the criteria in the `Memory Protocol` section of `agents/reviewer.md`. If it's too quiet, loosen them.

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

## Troubleshooting

- **Verify the agent loaded**: run `/agents` in Claude Code and confirm `reviewer` appears in the list.
- **Check permissions**: run `/permissions` to confirm tool access matches the frontmatter.
- **Health check**: run `/doctor` for installation diagnostics.
- **Inspect behavior**: subagent transcripts live in `~/.claude/projects/` and can help diagnose unexpected reviewer output.

## Contributing

The most valuable contributions are **new review checks** based on real errors you've encountered. If the reviewer missed something, open an issue or PR describing:

1. What the error was
2. Why the current checklist didn't catch it
3. What check would catch it in the future

## License

MIT
