# Example: Domain-Specific Review Checks

These are examples of how to extend the reviewer for specific domains.
Copy relevant sections into `agents/reviewer.md` under the `Domain-Specific Checks` heading.

---

## Digital Humanities / Manuscript Studies

```markdown
### Transliteration
- Verify IJMES transliteration consistency (don't mix Turkish and Arabic conventions)
- Check diacritical marks: ā ī ū ṣ ṭ ẓ ḥ ḍ should not be inconsistently applied
- Flag Anglicized spellings mixed with transliterated ones (e.g., "Quran" vs "Qurʾān")

### Dates
- If both Hijri and CE dates are given, verify the conversion is plausible
- Ottoman dates: check that Rumi calendar dates (if used) are distinguished from Hijri
- Flag anachronistic date ranges (e.g., an Ottoman manuscript dated to 1100 CE)

### Terminology
- Decoration terms must match the project vocabulary (e.g., use "serlevha" not "headpiece")
- Verify that catalogue fields match the declared schema exactly
```

## Software Development

```markdown
### Python
- Check that all f-string braces are balanced and contain valid expressions
- Verify `__init__.py` exports match actual module contents
- Flag bare `except:` clauses (should be `except Exception:` at minimum)
- Check that type hints are consistent (don't mix `Optional[str]` with `str | None` in the same file)

### JavaScript/TypeScript
- Verify `import` statements resolve to actual exports
- Check for accidental `==` instead of `===`
- Flag `any` type usage in TypeScript (should be explicitly justified)
- Verify async/await consistency (no fire-and-forget promises)

### SQL
- Check that JOIN conditions reference existing columns
- Verify GROUP BY includes all non-aggregated SELECT columns
- Flag SELECT * in production code
```

## Data & APIs

```markdown
### JSON/API Schemas
- Verify required fields are present in every example/instance
- Check that enum values in examples match the declared enum list
- Verify that nested object types are consistent across all occurrences

### CSV/Tabular Data
- Verify column count is consistent across all rows
- Check for delimiter confusion (commas inside unquoted fields)
- Flag empty required columns
```

## Security / Bug Bounty

```markdown
### Vulnerability Analysis
- Check that severity/impact claims are supported by demonstrated exploitation, not assumed
- Flag "partial mitigation" or "does not fully prevent" language — verify the mitigation doesn't already block the attack completely (e.g., SameSite=Lax on cross-site requests)
- When code is claimed dead or unreachable, verify all build entry points: bundler configs, copy plugins, content script manifests, service worker registrations
- Flag line-number citations in minified or bundled files — these shift between analysis and report
- Check sentinel/boundary values: what happens at counter=0, empty input, wraparound, off-by-one at filter boundaries
- Flag `expect()` / `unwrap()` / unguarded panics outside test code
- When CORS or origin checks are analyzed, verify testing covered multiple origins/subdomains, not just one
- Check that `externally_connectable`, CSP headers, and `web_accessible_resources` are read from the actual manifest, not assumed
- Flag "practical limit" dismissals — verify the limit is genuinely untestable with available tools (DevTools, storage APIs, public endpoints)

### Bug Bounty Reports
- After any severity change, verify that title, scope, summary, weakness category (CWE), and impact description all reflect the new severity — not just the severity field itself
- Flag fields or verdicts quoted from upstream sources — verify they exist verbatim in the source material
- Check that evidence sections contain actual observed data (HAR captures, screenshots, repro steps), not inferred behavior
- Flag contradictions between different sections of the same report (e.g., "may not be affected" vs. "confirmed not affected")
- Check for duplicate findings described under different phrasing
- Verify reproduction steps reference the correct context (web page vs. content script vs. background script)
```
