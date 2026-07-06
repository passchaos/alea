# S4-M393 Validation Build-Step Description Guard

## Gap

Recent validation work expanded `validate`, `validate-local`, and `validate-all`,
but the `build.zig` step descriptions still used older shorthand such as
"unit, API, statistical, and distribution checks" and "local Rust surface
checks". Those descriptions are what users see via `zig build -l`, so they
should match the current aggregate dependency scope.

## Change

`build.zig` now describes the aggregates as:

- `validate`: native unit, docs, statistical, distribution, profile, and wrapper
  checks;
- `validate-local`: native validation plus local Rust comparison and runtime
  checks;
- `validate-all`: native validation plus cross-target, WASI dry/self, and
  runtime checks.

`tools/toolingcheck.zig` now requires these description tokens in `build.zig` so
future aggregate changes do not leave stale help text behind.

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

S4-M393 is closed for the current bar: validation build-step descriptions match
the current aggregate dependency shape and are guarded by toolingcheck. This is
validation tooling reliability only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
