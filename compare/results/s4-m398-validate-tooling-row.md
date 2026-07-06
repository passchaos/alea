# S4-M398 Validate Tooling Row Precision

## Gap

`docs/tooling.md` has a table row explaining `zig build validate`. After recent
aggregate expansions, that row carries important detail: native unit, example,
catalog, API, statistical, distribution, libc, accepted-profile, and no-external
PractRand-wrapper self-test checks. `toolingcheck` did not directly guard this
row, so it could silently lose the accepted-profile or PractRand-wrapper meaning.

## Change

`tools/toolingcheck.zig` now requires `docs/tooling.md` to retain tokens for the
`zig build validate` row, including accepted-profile and no-external PractRand
wrapper self-test coverage.

## Validation

Focused validation commands:

```text
$ zig build toolingcheck
toolingcheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M398 is closed for the current bar: `zig build validate` tooling-row coverage
is explicit and guarded. This is validation documentation reliability only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
