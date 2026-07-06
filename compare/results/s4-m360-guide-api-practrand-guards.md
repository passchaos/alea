# S4-M360 Guide/API PractRand Dry-Run Guards

## Gap

README and the tooling catalog exposed PractRand dry-run usage, but core-guide
and API-reference discovery could still regress without a checker failure. Those
documents are common entry points for validation commands and public API usage.

## Change

`tools/toolingcheck.zig` now verifies:

- `docs/core-guide.md` includes `tools/practrand.sh --dry-run fast 1048576`;
- `docs/core-guide.md` includes `zig build practrand-dry-run`;
- `docs/core-guide.md` includes `PRACTRAND_BIN`;
- `docs/api-reference.md` includes `tools/practrand.sh --dry-run fast 1048576`;
- `docs/api-reference.md` includes `zig build practrand-dry-run`.

## Validation

Focused validation command:

```text
$ zig build toolingcheck
toolingcheck ok
```

Broader roadmap validation command:

```text
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M360 is closed for the current bar: core guide and API reference PractRand
dry-run discovery is now guarded by tooling. This is evidence/tooling hardening
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
