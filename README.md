# claude-reviewer

## Deprecated

This plugin is deprecated. Newer models catch more of their own mistakes than they did when I built it, so a separate QA reviewer pass earns its keep less often. The code is unchanged and it still works, but the `agent-tools` marketplace no longer lists it and I am not developing it further.

A Claude Code plugin with a `reviewer` subagent and a `/claude-reviewer:qa` skill for manual QA review of AI-generated output.

It is built to catch concrete correctness failures such as:

- wrong counts and stale totals
- duplicate entries or repeated IDs
- unresolved references and numbering drift
- invalid JSON / YAML / XML / CSV structure
- contradictions within the output
- unsupported additions when source material is available

It adds two things over a one-off review prompt:

- a dedicated reviewer subagent running in its own context
- persistent reviewer memory for recurring failure patterns

## What's included

| File | Purpose |
| --- | --- |
| `.claude-plugin/plugin.json` | Plugin manifest |
| `agents/reviewer.md` | Reviewer subagent definition |
| `skills/qa/SKILL.md` | `/claude-reviewer:qa` skill that invokes the reviewer |

## Installation

The `agent-tools` marketplace no longer lists this plugin. It still installs from any marketplace that carries it:

```text
/plugin install claude-reviewer@<marketplace-name>
```

> `jq` is recommended for JSON validation
> (`brew install jq` / `apt install jq` / `winget install jqlang.jq`).
> Without it, the reviewer falls back to manual inspection with lower confidence.

## Local development

To iterate on this repo without publishing, clone it and load it directly:

```bash
git clone https://github.com/koenvdheide/claude-reviewer.git
claude --plugin-dir ./claude-reviewer
```

Marketplace plugins are copied into `~/.claude/plugins/cache`, so editing a published plugin's source does not update the installed version. `--plugin-dir` loads the plugin from the source path for the current session.

## How it works

You can invoke the reviewer directly in any Claude Code session:

- Type `/claude-reviewer:qa` in Claude Code
- Ask Claude to "use the reviewer subagent to review your last output"
- Ask Claude to review a specific file, such as `output.json`

The reviewer runs in a separate context from the generating agent, which helps avoid shared blind spots.

## Reviewer memory

The reviewer uses persistent subagent memory.

It logs only significant recurring patterns, for example:

- date-range truncation
- repeated stale totals after list growth
- citation drift across batched records
- recurring duplicate-ID reuse patterns

Memory is scoped to user level by default (`memory: user` in `agents/reviewer.md`), which means the reviewer shares one memory across all your projects. For project-scoped memory, change `memory: user` to `memory: project` in `agents/reviewer.md`.

The reviewer curates its own memory: it stores one-line detection heuristics in a single `MEMORY.md` file (capped at 500 lines), and consolidates or removes entries when the budget is exceeded. You can review `~/.claude/agent-memory/reviewer/MEMORY.md` occasionally to remove stale heuristics or add your own.

## Permissions & safety

The reviewer subagent intentionally has no `Edit` or `Write` tools for project files. Its tool access is limited to:

- `Read`
- `Grep`
- `Glob`
- `Bash(jq *)`

It is therefore primarily read-only for project work, and can still maintain its own subagent memory.

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

If the `/claude-reviewer:qa` skill is installed, use:

```text
/claude-reviewer:qa
```

## Example memory snapshot

[`docs/examples/MEMORY.snapshot.md`](docs/examples/MEMORY.snapshot.md) is a frozen copy of the reviewer agent's own curated `MEMORY.md` after months of real use, as a sample of what generalisable detection heuristics look like.

> Do NOT copy this file into your own `agent-memory/` directory. The heuristics are domain-biased toward the author's projects and will prime your reviewer with irrelevant patterns. Start with an empty `MEMORY.md` and let the reviewer curate its own.

### How the reviewer curates memory

The reviewer writes to a single `MEMORY.md` in its agent-memory directory after each review, under rules its own prompt enforces (see [`agents/reviewer.md`](agents/reviewer.md) → "Memory Protocol"):

- A heuristic earns a line if (a) the pattern will recur in other projects, (b) it would go unnoticed without explicit review, and (c) the check fits in one sentence. Project-specific findings, style preferences, and already-covered heuristics are excluded.
- Each heuristic gets one bullet, formatted `- **[pattern name]**: [one-sentence detection heuristic]`. No error types, dates, project names, or multi-line descriptions; the heuristic stands alone.
- Entries live under the 7 top-level Review Checklist sections: Counting and Totals; Duplicate Detection; References, IDs, and Numbering; Structure and Syntax; Internal Consistency; Completeness; Common AI Slipups.
- The hard cap is 500 lines. Before adding, the agent counts the file. If adding would exceed 500, it first deletes the entry most similar to another (consolidating near-duplicates) or the entry that is least general. If nothing can be removed without losing value, the new entry is not added.

Net effect: memory grows toward a tight catalogue of AI error patterns that recur across projects.

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

## Contributing

The most valuable contributions are new review checks based on real errors you've encountered. If the reviewer missed something, open an issue or PR describing:

1. What the error was
2. Why the current checklist didn't catch it
3. What check would catch it in the future

## License

MIT
