# S4-M28 Examples Catalog

Date: 2026-07-04

Purpose: after adding many focused adoption examples, add a single discoverable
catalog mapping each `zig build run-*` step to the API surface it demonstrates.

## Change

Added `docs/examples.md`, a runnable examples catalog covering all current files
under `examples/` and their focused build steps. `docs/core-guide.md` and
`docs/api-reference.md` now point to this catalog.

The catalog also documents that `zig build validate` depends on `zig build
examples`, so examples are part of normal local validation.

## Validation

Commands:

```sh
zig build examples
zig build apicheck
```

Result: passed. The examples catalog is documentation-only, while `examples` and
`apicheck` verify the referenced build steps and docs coverage remain healthy.

## S4-M28 Decision

S4-M28 is closed for the current examples-discoverability bar: users now have a
central catalog for all runnable adoption examples in addition to the individual
roadmap notes.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
