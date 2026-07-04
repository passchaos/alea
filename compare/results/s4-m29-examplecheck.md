# S4-M29 Example Catalog Drift Check

Date: 2026-07-04

Purpose: prevent `docs/examples.md` from drifting as runnable examples are added
or renamed.

## Change

Added `tools/examplecheck.zig` and build step:

```sh
zig build examplecheck
```

The checker verifies:

- every known `examples/*.zig` source exists;
- `docs/examples.md` mentions every example source path;
- `docs/examples.md` mentions every focused `zig build run-*` example step;
- every checked-in `examples/*.zig` file is listed in `tools/examplecheck.zig`;
- the catalog mentions both `zig build examples` and its `zig build validate`
relationship.

`zig build validate` now depends on `examplecheck` in addition to `examples`, so
both the examples and their catalog are covered by normal local validation.

## Validation

Command:

```sh
zig build examplecheck
```

Result: passed, `examplecheck ok`.

A follow-up `zig build -Doptimize=ReleaseFast validate` was run after wiring the
step into validation.

## S4-M29 Decision

S4-M29 is closed for the current examples-catalog drift bar: the runnable example
catalog now has a dedicated verifier and is part of local validation.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
