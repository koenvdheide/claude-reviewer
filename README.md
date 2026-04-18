# claude-reviewer

A Claude Code plugin that provides a `reviewer` subagent and `/claude-reviewer:qa` skill for manual QA review of AI-generated output.

It is built to catch concrete correctness failures such as:

- wrong counts and stale totals
- duplicate entries or repeated IDs
- unresolved references and numbering drift
- invalid JSON / YAML / XML / CSV structure
- contradictions within the output
- unsupported additions when source material is available

What makes this more useful than a one-off review prompt is the combination of:

- a dedicated reviewer subagent running in its own context
- persistent reviewer memory for recurring failure patterns

## Track record

Measured across **1,500+ reviewer invocations** spanning 30+ projects (including but not limited to: code review & programming, bug hunting, writing architecture/design/specs documents, academic archival research and writing):

- **~86% of reviews surfaced at least one real issue**
- **~2.3 confirmed errors per review** on average, plus ~2.7 verification flags for human follow-up
- **~5–15% estimated false positive rate** on confirmed errors (reviewer self-tags 25% of findings as low-confidence and main session identifies practically all remaining false positives)

Most common catches:

| Category | Share of confirmed errors | Typical example |
| --- | --- | --- |
| Consistency | ~30% | Summary says "3 categories", details contain 4 |
| Counting & arithmetic | ~10% | "Top 10" list contains 9 items; scalar count diverges from its corresponding list |
| Completeness | ~10% | Promised section never appears; JSON array cut off mid-object |
| Stale references | ~5% | Docstrings/comments describing old behavior after a refactor |
| Logic errors | ~5% | Boolean OR masking a missing field check |
| Hallucinations / factual errors | ~2% | Missing or fabricated citations, invented claims, incorrect function call |

On occasions it has also caught issues severe enough to scrap a plan rather than patch it: fabricated dependencies (tools or APIs that don't exist), load-bearing assumptions that turn out to be false, invariant violations at architectural boundaries, over-engineered designs that dissolve under a simpler framing, and premise inversions where one misread claim cascades into every downstream conclusion.

## What's included

| File | Purpose |
| --- | --- |
| `.claude-plugin/plugin.json` | Plugin manifest |
| `agents/reviewer.md` | Reviewer subagent definition |
| `skills/qa/SKILL.md` | `/claude-reviewer:qa` skill that invokes the reviewer |

## Installation

```text
/plugin install claude-reviewer@<marketplace-name>
```

Once the plugin is accepted into the [Anthropic plugin marketplace](https://github.com/anthropics/claude-code), install with the command above (substituting the correct marketplace name).

> **Note:** `jq` is recommended for JSON validation
> (`brew install jq` / `apt install jq` / `winget install jqlang.jq`).
> If unavailable, the reviewer degrades gracefully to manual inspection with lower confidence.

## Local development

To iterate on this repo without publishing, clone it and load it directly:

```bash
git clone https://github.com/koenvdheide/claude-reviewer.git
claude --plugin-dir ./claude-reviewer
```

Marketplace plugins are copied into `~/.claude/plugins/cache`, so editing a published plugin's source does not update the installed version. `--plugin-dir` loads the plugin from the source path for the current session.

## How it works

You can invoke the reviewer directly in any Claude Code session:

- Type **`/claude-reviewer:qa`** in Claude Code
- Ask Claude to **"use the reviewer subagent to review your last output"**
- Ask Claude to review a specific file, such as `output.json`

The reviewer runs in a **separate context** from the generating agent, which helps avoid shared blind spots.

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

## Using a different model

The reviewer works best when run on a different model than the one that generated the output. By default, the agent is configured to use Sonnet, which catches different errors than Opus and is cheaper to run. Change the `model` field in the frontmatter of `agents/reviewer.md` to use a different model.

## Uninstall

```text
/plugin uninstall claude-reviewer
```

## Troubleshooting

- **Verify the plugin loaded**: run `/plugin list` and confirm `claude-reviewer` appears.
- **Verify the subagent loaded**: run `/agents` and confirm `reviewer` appears.
- **Verify the skill loaded**: run `/claude-reviewer:qa` — it should delegate to the reviewer subagent.
- **Check permissions**: run `/permissions` to confirm tool access.
- **Health check**: run `/doctor` for installation diagnostics.

## Contributing

The most valuable contributions are **new review checks** based on real errors you've encountered. If the reviewer missed something, open an issue or PR describing:

1. What the error was
2. Why the current checklist didn't catch it
3. What check would catch it in the future

## License

MIT
