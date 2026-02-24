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
