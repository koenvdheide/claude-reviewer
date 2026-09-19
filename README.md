# claude-reviewer

> Deprecated. Newer models catch more of their own mistakes than they did when I built it, so a separate QA reviewer pass earns its keep less often. The code is unchanged and it still works, but the `agent-tools` marketplace no longer lists it and I am not developing it further.

A Claude Code plugin with a `reviewer` subagent and a `/claude-reviewer:qa` skill for manual QA review of AI-generated output.

It is built to catch concrete correctness failures such as:

- wrong counts and stale totals
- duplicate entries or repeated IDs
- unresolved references and numbering drift
- invalid JSON / YAML / XML / CSV structure
- contradictions within the output
- unsupported additions when source material is available

It adds two things over a one-off review prompt:

- a dedicated reviewer subagent running in its own context, which helps avoid shared blind spots
- persistent reviewer memory for recurring failure patterns

## What's included

| File | Purpose |
| --- | --- |
| `.claude-plugin/plugin.json` | Plugin manifest |
| `agents/reviewer.md` | Reviewer subagent definition |
| `skills/qa/SKILL.md` | `/claude-reviewer:qa` skill that invokes the reviewer |

## Installation

> `jq` is recommended for JSON validation
> (`brew install jq` / `apt install jq` / `winget install jqlang.jq`).
> Without it, the reviewer falls back to manual inspection with lower confidence.

The `agent-tools` marketplace no longer lists this plugin. It still installs from any marketplace that carries it:

```text
/plugin install claude-reviewer@<marketplace-name>
```

## Usage

Invoke the reviewer in any Claude Code session:

```text
/claude-reviewer:qa
```

Or ask Claude in plain language, which lets you aim the review:

```text
Use the reviewer subagent to review your last output
Use the reviewer subagent, focus on duplicate detection and JSON validity
Use the reviewer subagent to check output.json for structural issues and hallucinations
```

## Reviewer memory

The reviewer keeps persistent subagent memory: a single `MEMORY.md` holding nothing but one-line detection heuristics, grouped under the 7 headings of the reviewer's own Review Checklist and capped at 500 lines. A pattern earns an entry only if it will recur in other projects, would go unnoticed without explicit review, and fits in one sentence. At the cap the reviewer consolidates near-duplicates or drops its least general entry before adding. The full rules are in [`agents/reviewer.md`](agents/reviewer.md) under "Memory Protocol".

Typical entries cover date-range truncation, stale totals after list growth, citation drift across batched records, and duplicate-ID reuse. Each is one bullet, formatted `- **[pattern name]**: [one-sentence detection heuristic]`.

Memory is scoped to user level by default (`memory: user` in `agents/reviewer.md`), which means the reviewer shares one memory across all your projects. For project-scoped memory, change `memory: user` to `memory: project` in `agents/reviewer.md`. You can review `~/.claude/agent-memory/reviewer/MEMORY.md` occasionally to remove stale heuristics or add your own.

### Example memory snapshot

[`docs/examples/MEMORY.snapshot.md`](docs/examples/MEMORY.snapshot.md) is a frozen copy of the reviewer agent's own curated `MEMORY.md` after months of real use, as a sample of what generalisable detection heuristics look like.

> Do NOT copy this file into your own `agent-memory/` directory. The heuristics are domain-biased toward the author's projects and will prime your reviewer with irrelevant patterns. Start with an empty `MEMORY.md` and let the reviewer curate its own.

## Permissions & safety

The reviewer subagent intentionally has no `Edit` or `Write` tools for project files. Its tool access is limited to:

- `Read`
- `Grep`
- `Glob`
- `Bash(jq *)`

It is therefore read-only for project work, while still maintaining its own subagent memory.

## Using a different model

The reviewer works best when run on a different model than the one that generated the output. The agent is configured to use Sonnet by default, which catches different errors than Opus and is cheaper to run. Change the `model` field in the frontmatter of `agents/reviewer.md` to use a different model.

## Uninstall

```text
/plugin uninstall claude-reviewer
```

## Troubleshooting

- Run `/plugin list` and confirm `claude-reviewer` appears.
- Run `/context` and confirm `reviewer` appears under Custom Agents, or @-mention it as `claude-reviewer:reviewer`.
- Run `/claude-reviewer:qa`; it should delegate to the reviewer subagent.
- Run `/permissions` to confirm tool access.
- Run `/doctor` for installation diagnostics.

## Local development

To iterate on this repo without publishing, clone it and load it directly:

```bash
git clone https://github.com/koenvdheide/claude-reviewer.git
claude --plugin-dir ./claude-reviewer
```

Marketplace plugins are copied into `~/.claude/plugins/cache`, so editing a published plugin's source does not update the installed version. `--plugin-dir` loads the plugin from the source path for the current session.

## Contributing

The most valuable contributions are new review checks based on real errors you've encountered. If the reviewer missed something, open an issue or PR describing:

1. What the error was
2. Why the current checklist didn't catch it
3. What check would catch it in the future

## License

MIT
