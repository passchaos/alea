# S4-M31 README Discovery And Doccheck Aggregate

Date: 2026-07-04

Purpose: keep first-contact documentation and documentation validation discoverable
after the examples/tooling catalogs were split out and guarded by dedicated
checkers.

## Change

Added `tools/readmecheck.zig` and build step:

```sh
zig build readmecheck
```

The checker verifies that `README.md` continues to expose the core discovery
path for new contributors and users:

- `docs/core-guide.md`
- `docs/api-reference.md`
- `docs/examples.md`
- `docs/tooling.md`
- `compare/results/core-rand-coverage.md`
- `compare/results/performance-triage.md`
- `zig build -l`
- `zig build test`
- `zig build apicheck`
- `zig build examplecheck`
- `zig build toolingcheck`
- `zig build readmecheck`
- `zig build doccheck`
- `zig build validate`
- `zig build validate-all`
- `zig build run-basic`
- `zig build examples`
- the local Rust `rand` comparison note and `~/Work/rand` reference.

Added aggregate documentation gate:

```sh
zig build doccheck
```

`doccheck` depends on `apicheck`, `examplecheck`, `toolingcheck`,
`readmecheck`, and `roadmapcheck`. `zig build test` now runs unit tests plus `doccheck`, while
`zig build validate` depends on `doccheck` instead of hand-wiring each
individual documentation checker.

Updated `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
`docs/tooling.md` so `readmecheck` and `doccheck` are discoverable from the
normal docs.

## Validation

Commands:

```sh
zig build readmecheck
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed. `readmecheck` prints `readmecheck ok`; `doccheck` runs the five
documentation/catalog/roadmap checkers successfully.

## S4-M31 Decision

S4-M31 is closed for the current README/discovery and documentation-gate bar:
first-contact docs now point to the examples/tooling catalogs and a single
`doccheck` aggregate validates API, examples, tooling, README discovery, and roadmap/audit evidence.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
