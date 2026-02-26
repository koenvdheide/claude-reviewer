<!-- 
  Add this section to your ~/.claude/CLAUDE.md
  It provides lightweight always-on self-review and optional auto-review via the reviewer subagent.
-->

## Output Review Protocol

After generating any structured output (lists, JSON, data, catalogues, schemas,
code with repetitive structures), perform a quick self-review before presenting:

1. **Count verification**: Independently recount all items. Compare to any stated totals.
2. **Duplicate check**: Scan for exact and near-duplicate entries.
3. **Index/ID consistency**: Verify cross-references, numbering, and IDs are sequential and valid.
4. **Schema compliance**: Confirm output matches the declared or expected format.
5. **Source fidelity**: If working from source material, verify no hallucinated additions or omissions.

If any issue is found, fix it silently and note the correction briefly.

When uncertain about a specific item (a date, attribution, transliteration, etc.),
mark it with [?] inline so the reviewer agent can flag it for verification.

## Auto-Review (via reviewer subagent)

For any output that meets ONE of these criteria:

- Longer than 50 lines
- Contains structured data (JSON, YAML, CSV, XML)
- Contains numbered lists with more than 10 items
- Involves data from external sources

Use the Task tool to invoke the `reviewer` agent to verify the output before
presenting it. If the reviewer finds issues, fix them before sharing the final result.
