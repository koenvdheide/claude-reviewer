<!--
  SNAPSHOT of the reviewer agent's own MEMORY.md after several months of real use.
  NOT a starter kit — heuristics are domain-biased toward the author's projects
  and will prime your reviewer with irrelevant patterns.
  See README.md "Example memory snapshot" section for context and the curation rules.

  Note: not every Review Checklist section appears here. Sections without logged
  generalizable heuristics at snapshot time are omitted (this snapshot covers 6
  of the 7 sections — "Structure and Syntax" had no logged entries yet).
-->

# QA Reviewer — Detection Heuristics

## Counting and Totals

- **make_* family count drift**: When a spec says "~14 make_* builders", grep `^def make_` in the actual file — actual count may be 16 and the spec's "~14" is stale.
- **Trailing-section absorbed into list count**: When a source has N bulleted items followed by a named standalone section (e.g., "Concrete next step"), verify the stated total counts only the bullets — off-by-one errors occur when the trailing section is absorbed into the bullet count.
- **"files using X" vs "files importing X"**: "files using make_* family" (8 files) can differ sharply from "files importing helpers" (41 files); verify the narrower claim separately.
- **Silent probe/step subset omission**: When a message presents a numbered list of test probes or steps, compare the count and character-class coverage against the authoritative source (plan/spec) — items are silently dropped and re-numbered without disclosure, leaving acceptance criteria unmet.

## References, IDs, and Numbering

- **Step-number reference drift after renumber**: When a checklist is renumbered (e.g., 9 items → 8 by merging two steps), search the prose sections for "(step N)" back-references — the inline reference is not updated and now points to the wrong step.
- **File:line citations drift**: Spec line citations (e.g., `dispatch.py:34`) go stale after refactors; always grep for the function/pattern and compare to the cited line number.
- **Collector line number drift**: When a conftest.py or collector is edited, cited internal line numbers (e.g., `conftest.py:24`, `conftest.py:54`) shift; verify all cited lines against the live file.
- **Bracket-citation format collapse in summaries**: When a source uses bracket-style citations (e.g., `[README.md:20]`), verify summaries preserve the full `[file:line]` form rather than silently converting to informal "line N" or dropping embedded secondary citations entirely.

## Duplicate Detection

- **Appended-clause intra-prompt term repetition**: When a new instruction block is appended to an existing prompt string, check whether key terms in the appended clause (e.g., "trust boundaries", "tenant isolation") already appear earlier in the same prompt — the append pattern silently duplicates without full-prompt context.
- **Qualifier-vs-list-scope conflict**: When a single-finding preference instruction ("prefer one strong finding") is added to a prompt that also contains a multi-category enumeration (7-item taxonomy), verify that Codex's expected output cardinality is coherent — instructing breadth and depth simultaneously creates contradictory output shape.
- **Capitalization drift in ported terminology**: When the same compound term (e.g., "Blast Radius") is added to multiple locations, check each insertion for consistent capitalization — copy-paste from different sources silently introduces mixed-case across the same document.

## Completeness

- **Spec-section behavior not reflected in artifact text**: When a spec's prose section (e.g., Error Handling) describes runtime behavior (e.g., retry logic) but none of the proposed artifact texts (skill body, agent prompt) contain that behavior, the implementer will omit it — verify every behavior claim maps to at least one proposed artifact.
- **Missing-file cross-reference in shipped skill**: When a SKILL.md references a sibling file (e.g., `skills/shared/task-format-reference.md`) as a "see for full format" pointer, verify the file exists in the repo — cross-file references added during development are silently left unresolved when the referenced file was never committed.
- **NOTICE/attribution description vs shipped file divergence**: When a NOTICE or LICENSE-UPSTREAM file describes a modification (e.g., "spec location changed from X to Y"), verify the shipped skill file reflects the described change — the NOTICE may be written prospectively or after a partial edit, leaving the actual file unchanged.
- **Undeclared external skill dependency**: When a skill invokes another skill by name (e.g., `writing-plans`, `elements-of-style`) without bundling it, verify the README's dependency section names it — skills silently depend on separately-installed plugins that aren't listed as prerequisites.

## Common AI Slipups

- **"all immediately verifiable" blanket overclaim**: When prose says "X, Y, Z — all [property]" and a nearby taxonomy contains categories not in {X,Y,Z}, verify every table category satisfies the property — the selective list silently excludes counterexamples.

## Internal Consistency

- **README-fallback vs SKILL-failure-policy divergence**: When a README says "falls back to self-review" on plugin unavailability but the SKILL says "ask user before proceeding unreviewed", the behaviors are contradictory — verify README failure descriptions against the actual instruction in the SKILL.
- **Auto-fires-vs-explicit-step duplication**: When a plan step says a sub-action "fires automatically" (e.g., "QA runs automatically per skill"), and a later numbered step explicitly performs that same sub-action, flag the contradiction — implementers will either skip the explicit step (treating it as redundant) or run it twice.
- **Self-rebuttal bridge fabrication**: When a summary dismisses a source finding as "largely neutralized" or "resolved by X", verify X is in the source — summaries frequently insert the author's own counter-reasoning as if it were endorsed by the reviewer.
- **Partial-application-as-verbatim**: When a review bullet recommends adding items A+B+C and only C was applied, "shipped verbatim" is false — verify each multi-part recommendation against the shipped artifact before accepting a "verbatim" claim.
- **Total file count vs shim + non-shim split**: If a directory has N .py files and spec says "X shims + Y non-shim + dispatch + hook_utils", verify X+Y+2 = N; mismatches surface when new files were added after the spec was written.
- **D6 retire-in-Phase-1 vs Phase-1.5 contradiction**: When a spec section (D6) says "retire in Phase X" but a later phase section moves it to Phase X+0.5, check whether D6 was updated to match — stale section-level claims are a common AI spec error.
- **Architectural-decision vs implementation-section divergence**: When a spec has a "revised" D-section (e.g., D4 adopts marker-list) but a later layout section (D7) still describes the superseded approach (legacy/ directory), the layout section was not updated — check every Dx section for cross-consistency after a revision.
- **Quoted-label inversion**: When a summary re-labels a source's quoted session/version descriptor (e.g., "v1-minimal adoption" → "full Codex adoption"), grep the source for the original label and compare — directional opposites are a common silent substitution.
- **Disjunction collapse in paraphrase**: When a source says "X or Y", a paraphrase that drops one branch ("X") is technically non-false but misleading — always check "or" clauses in source against the paraphrase.
- **Technical-name substitution in paraphrase**: When paraphrasing a finding that names a specific mechanism (e.g., "bash_guard hook"), verify the paraphrase preserves the name rather than substituting a generic synonym ("bash hook").
- **Strength de-escalation in paraphrase**: When a source uses a definitive verb ("turns it into"), a paraphrase that substitutes a directional one ("toward") silently weakens the claim — check both amplification and softening, not just amplification.
- **Modal stripping in paraphrase**: When a source uses a conditional modal ("can become", "can fail"), a paraphrase that drops the modal makes the claim unconditional — grep every "can/may/might" in the source and verify the summary preserves or strengthens rather than silently universalizes.
- **Fabricated artifact label in evidence list**: When a summary lists contributors to a finding (e.g., "Brainstorming + codex + close-out additions"), verify each label maps to a named artifact in the source — invented descriptive labels silently replace cited document names (e.g., "marketplace README").
- **Sentinel-value stdin convention**: When a skill documents a CLI flag with a sentinel value for stdin reading (e.g., `-p -`), verify against `--help` output — CLIs often do not support this convention and the literal `-` is passed as the argument value instead.
- **Multi-source evidence merged into single sentence**: When a source cites two separate artifacts for one claim (e.g., reviewer.md:207 for prose format, spec-reviewer-prompt.md:7 for output schema), a summary that fuses them into one sentence without naming the two components creates a false impression of a single unified source — verify each citation maps to the exact sub-claim it supports.
- **Cited-source scope mismatch**: When a prose claim ("instructs the main session to push back on reviewer findings") is attributed to a source document, verify the source actually covers that specific claim and not merely a related but narrower one (e.g., "fix clearly-improvement flags immediately" ≠ "push back on reviewer findings") — LLMs routinely over-extend the scope of cited evidence.
- **Intra-entity conflict collapsed to inter-entity heading**: When a source identifies a contradiction within a single unit (e.g., "¶2 says X, then says Y"), check that the summary heading doesn't re-frame it as a conflict between two units (e.g., "between ¶2 and ¶3") — the body text may preserve the detail while the heading silently flattens the structure.
- **Cross-section label importation**: When a source uses a vivid phrase in section B (e.g., "trust detour") that also applies to a finding in section A, verify the summary doesn't import the section-B label as the heading for the section-A finding — the body-section's own language (e.g., "bad skeptic read") should govern the heading.
- **Executive-summary sentence absorption**: When a source has a short "top risks" or "key issues" sentence listing N named items, verify each item is surfaced with its exact label in the summary, not just absorbed into body bullets where labels silently shift.
