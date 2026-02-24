# claude-reviewer

A global Claude Code subagent that reviews AI-generated output for common LLM errors: miscounting, duplicate entries, hallucinated content, and internal inconsistencies.

What makes this different from a one-off review prompt is the **persistent memory feedback loop** — the reviewer logs significant errors it catches to its agent memory, which is automatically loaded before each review. Over time, it gets better at catching the specific failure modes *you* encounter.

## What's included

| File | Purpose |
|---|---|
| `agents/reviewer.md` | The reviewer subagent definition |
| `claude-md-snippet.md` | Drop-in section for your `~/.claude/CLAUDE.md` |
| `examples/domain-specific.md` | Example of domain-specific review checks |
| `install.sh` | Symlinks everything into `~/.claude/` |

## Installation

```bash
git clone https://github.com/koenvdheide/claude-reviewer.git
cd claude-reviewer
chmod +x install.sh
./install.sh
```

Then add the contents of `claude-md-snippet.md` to your `~/.claude/CLAUDE.md`.

> **Note:** `jq` is recommended for JSON validation (`brew install jq` / `apt install jq`). If unavailable, the reviewer degrades gracefully to manual inspection with lower confidence.

## How it works

### The reviewer agent

Invoke it in any Claude Code session:

- Ask Claude to **"review your last output using the reviewer agent"**
- Or set up auto-review (see below) so it triggers automatically on large outputs

The reviewer runs in a **separate context** from the generating agent, which is key — it doesn't share the same blind spots.

### Agent memory

After each review, the reviewer updates `~/.claude/agent-memory/reviewer/MEMORY.md`. Only errors that are **systematic** (likely to recur), **silent** (would have gone unnoticed), and **substantive** (affect correctness) get logged.

Before each review, the memory is automatically loaded into the reviewer's context. This creates a feedback loop: catch error → log it → check for it next time.

Memory is scoped to **user level** by default (`memory: user` in the frontmatter), meaning the reviewer shares a single memory across all your projects. Errors caught in one project inform reviews in every other project. If you'd prefer project-scoped memory instead, change `memory: user` to `memory: project` in `agents/reviewer.md` — see the [Claude Code subagent memory docs](https://code.claude.com/docs/en/sub-agents#enable-persistent-memory) for details.

**Important:** Periodically curate the memory yourself — consolidate recurring patterns, delete false positives, keep it under 200 lines. The loop only works if the data is clean.

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

The `claude-md-snippet.md` includes an optional instruction that triggers the reviewer automatically on outputs longer than 50 lines or containing structured data. Remove or adjust this if you find it too aggressive. Note: this is a prompted protocol, not a guaranteed hook — the model may skip it on short or simple responses.

## Usage examples

The reviewer runs in the background and reports back when done.

General review:

```text
Review your last output using the reviewer agent
```

Target a specific concern:

```text
Use the reviewer agent — focus on duplicate detection and JSON validity
```

Review a file:

```text
Use the reviewer agent to check output.json for structural issues and hallucinations
```

## Customization

### Adding domain-specific checks

The generic checklist misses domain-specific issues. Add checks specific to your work to catch these. See `examples/domain-specific.md` for inspiration, then add your own to the reviewer agent under the `Domain-Specific Checks` section.

### Adjusting the logging threshold

If the memory is too noisy, tighten the criteria in the `Memory Protocol` section of `agents/reviewer.md`. If it's too quiet, loosen them.

### Using a different model

The reviewer works best when run on a different model than the one that generated the output. By default, the agent is configured to use Sonnet, which catches different errors than Opus and is cheaper to run. Change the `model` field in the frontmatter of `agents/reviewer.md` to use a different model.

## Uninstall

```bash
cd claude-reviewer
./install.sh --uninstall
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
