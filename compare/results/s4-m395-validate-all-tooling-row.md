# S4-M395 Validate-All Tooling Row Precision

## Gap

After S4-M388 expanded `zig build validate-all`, the explanatory paragraph in
`docs/tooling.md` listed `wasi-dry-run`, `wasi-self-test`, and `wasi-report`, but
the table row still summarized validate-all as "WASI runtime checks". That row is
one of the quickest places users look for command meaning, so it should name the
expanded WASI unit/dry/self/report coverage explicitly.

## Change

`docs/tooling.md` now says `zig build validate-all` runs native validation,
cross-target compile checks, WASI unit execution, WASI dry/self tests, and the
chained WASI report. `tools/toolingcheck.zig` now guards those row tokens.

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

S4-M395 is closed for the current bar: the validate-all tooling table row now
matches the expanded aggregate and is guarded by toolingcheck. This is validation
documentation reliability only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
