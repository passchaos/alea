# S4-M394 Test-Step Doccheck Description Guard

## Gap

`build.zig` makes `zig build test` depend on both unit tests and the full
`doccheck` aggregate. `docs/tooling.md` still described the step as unit tests
plus API reference coverage only, underrepresenting example, tooling, README,
and roadmap checks.

## Change

`docs/tooling.md` now says `zig build test` runs unit tests plus the full
`doccheck` aggregate: API, examples, tooling, README, and roadmap checks.
`tools/toolingcheck.zig` now requires those documentation tokens so this catalog
entry cannot silently drift back to an incomplete description.

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

S4-M394 is closed for the current bar: `zig build test` tooling documentation now
matches its actual full doccheck dependency and is guarded by toolingcheck. This
is validation documentation reliability only; it does not resolve S4-M11 and is
not whole-goal completion evidence.
