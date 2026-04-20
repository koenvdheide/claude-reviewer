---
name: qa
description: QA-review the last output using the reviewer subagent
argument-hint: "[--json [focus text]]"
---

Raw slash-command arguments: `$ARGUMENTS`

Use the reviewer subagent to QA-review your last output for errors.

**JSON mode grammar (strict):**

- Activate JSON mode iff the first whitespace-delimited token of `$ARGUMENTS` is exactly `--json` (case-sensitive) AND `--json` does not appear again as a separate whitespace-delimited token later in the arguments. Leading whitespace is ignored when locating the first token. Forward the remaining text (after the first token) to the reviewer as a focus hint.
- A repeated flag like `--json --json focus on duplicates` does NOT activate JSON mode. Duplicates, quoted `--json`, mid-string `--json`, and absence all fall back to default markdown.
- A quoted or mid-string `--json` (e.g. `focus on "--json" literal` or `please --json the output`) does NOT activate JSON mode. Use default markdown.
- No `--json` token at all → default markdown mode. Behavior unchanged from pre-feature reviewer.

**Precondition (JSON mode only): bash-compatible shell + `jq` in `PATH`.** The validation recipe below uses `command -v` and piped `jq` — assumes the Claude Code Bash tool runs in bash or a bash-compatible shell (the default on macOS/Linux and under Git Bash on Windows). If `command -v jq` returns non-zero, do NOT invoke the reviewer. Emit this single JSON object instead and stop:

```json
{
  "summary": "jq is required for /claude-reviewer:qa --json validation but is not in PATH",
  "confirmed_errors": [],
  "verification_flags": [],
  "error": "install jq (brew install jq / apt install jq / winget install jqlang.jq) and re-run, or omit --json to use markdown mode which has no jq dependency"
}
```

This preserves the "always one valid JSON object in JSON mode" contract. Markdown mode (no flag) keeps working without `jq`.

In JSON mode (assuming the precondition above is met):

1. Invoke the reviewer subagent and explicitly instruct it to emit its final report as a single JSON object matching the structure described in its Output Format → JSON mode subsection.

2. When the reviewer returns, validate its output with a full shape-aware jq gate (not just `jq empty` — that only proves parseability and would let `[]`, `"oops"`, `{"unrelated":1}`, or multiple top-level documents pass through). The gate enforces exactly one top-level object with the required top-level fields AND per-item field constraints (type enum, confidence enum, non-empty strings):

   ```bash
   echo "$REVIEWER_OUTPUT" | jq -e -s '
     length == 1 and
     (.[0] | type == "object") and
     (.[0].summary | type == "string") and (.[0].summary | length > 0) and
     (.[0].confirmed_errors | type == "array") and
     (.[0].verification_flags | type == "array") and
     ((.[0] | has("error") | not) or (.[0].error | type == "string")) and
     (.[0].confirmed_errors | all(
       type == "object" and
       (.type | IN("COUNTING","DUPLICATION","REFERENCE_ID_NUMBERING","STRUCTURE_SYNTAX","INTERNAL_CONSISTENCY","COMPLETENESS","COMMON_AI_SLIPUP")) and
       (.location | type == "string") and (.location | length > 0) and
       (.found | type == "string") and (.found | length > 0) and
       (.expected | type == "string") and (.expected | length > 0) and
       (.evidence | type == "string") and (.evidence | length > 0) and
       (.confidence | IN("high","medium")) and
       (.fix | type == "string") and (.fix | length > 0)
     )) and
     (.[0].verification_flags | all(
       type == "object" and
       (.location | type == "string") and (.location | length > 0) and
       (.suspicion | type == "string") and (.suspicion | length > 0) and
       (.why_flagged | type == "string") and (.why_flagged | length > 0) and
       (.verification_step | type == "string") and (.verification_step | length > 0) and
       (.confidence | IN("low","medium"))
     ))
   '
   ```

   If the gate fails (non-zero exit) for any reason — markdown returned, multi-document output, missing/wrong-typed top-level fields, empty per-item strings, wrong `type` enum, wrong `confidence` enum — re-invoke the reviewer ONCE with this formatting-only correction nudge: "your previous output did not match the JSON schema. This is a **formatting retry only**: do NOT re-run the Review Checklist and do NOT re-curate `MEMORY.md`. Reformat your prior findings into a single JSON object with: `summary` (non-empty string), `confirmed_errors` (array; each item has `type` (one of COUNTING, DUPLICATION, REFERENCE_ID_NUMBERING, STRUCTURE_SYNTAX, INTERNAL_CONSISTENCY, COMPLETENESS, COMMON_AI_SLIPUP), `location`, `found`, `expected`, `evidence`, `confidence` (high|medium), `fix`, all non-empty strings), `verification_flags` (array; each item has `location`, `suspicion`, `why_flagged`, `verification_step` (non-empty strings) and `confidence` (low|medium)), and optional `error` (string). No prose, no markdown framing, no extra top-level documents."

3. If the second attempt also fails, do NOT surface raw non-JSON text. Construct and emit a minimal valid JSON object that preserves the contract, for example:

   ```json
   {
     "summary": "reviewer failed to produce valid JSON after one retry",
     "confirmed_errors": [],
     "verification_flags": [],
     "error": "<short explanation; may include a truncated, JSON-string-escaped excerpt of the raw output for diagnosis>"
   }
   ```

   Downstream consumers always parse exactly one JSON object regardless of outcome.

4. **Pass-through requirement:** when the reviewer's output IS valid JSON, surface it verbatim to the user. Do NOT add framing, preamble, summary, or commentary before or after the JSON object. The whole point is machine-readability; any main-agent prose breaks downstream tools.

In default (markdown) mode, behavior is unchanged.
