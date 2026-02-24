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

## How it works

### The reviewer agent

Invoke it in any Claude Code session:

- Ask Claude to **"review your last output using the reviewer agent"**
- Or set up auto-review (see below) so it triggers automatically on large outputs

The reviewer runs in a **separate context** from the generating agent, which is key — it doesn't share the same blind spots.

### Agent memory

After each review, the reviewer updates `~/.claude/agent-memory/reviewer/MEMORY.md`. Only errors that are **systematic** (likely to recur), **silent** (would have gone unnoticed), and **substantive** (affect correctness) get logged.

Before each review, the memory is automatically loaded into the reviewer's context. This creates a feedback loop: catch error → log it → check for it next time.

**Important:** Periodically curate the memory yourself — consolidate recurring patterns, delete false positives, keep it under 200 lines. The loop only works if the data is clean.

### Auto-review (optional)

The `claude-md-snippet.md` includes an optional instruction that triggers the reviewer automatically on outputs longer than 50 lines or containing structured data. Remove or adjust this if you find it too aggressive.

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

## Contributing

The most valuable contributions are **new review checks** based on real errors you've encountered. If the reviewer missed something, open an issue or PR describing:

1. What the error was
2. Why the current checklist didn't catch it
3. What check would catch it in the future

## License

MIT
