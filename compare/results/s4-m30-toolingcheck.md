# S4-M30 Build/Tooling Catalog Drift Check

Date: 2026-07-04

Purpose: prevent build-step and checked-in tool documentation from drifting as
validation gates, benchmark probes, runtime checks, and helper tools are added or
renamed.

## Change

Added `docs/tooling.md` as a central catalog for project-defined `zig build`
steps and checked-in `tools/` files, covering:

- local validation gates (`test`, `apicheck`, `examplecheck`, `toolingcheck`,
  `statcheck`, `distcheck`, `distcheck-libc`, profile checks, `validate`, and
  `validate-all`);
- runnable examples and the aggregate `examples` step;
- WASI runtime steps;
- benchmark and performance probe steps;
- external statistical/snapshot helpers;
- every checked-in `.zig`, `.sh`, and `.js` file under `tools/`.

Added `tools/toolingcheck.zig` and build step:

```sh
zig build toolingcheck
```

The checker verifies:

- every known project-defined build step is still present in `build.zig`;
- every known build step is documented in `docs/tooling.md` as a `zig build ...`
  command;
- every checked-in `tools/*.zig`, `tools/*.sh`, and `tools/*.js` file is listed
  in the checker and in `docs/tooling.md`;
- tool files that should be wired through `build.zig` are still referenced by
  `build.zig`;
- `docs/core-guide.md` and `docs/api-reference.md` link the tooling catalog and
  mention `zig build toolingcheck`;
- `zig build validate` runs `toolingcheck` through the aggregate `doccheck` step.

`zig build validate` now depends on `doccheck`, and `doccheck` depends on
`toolingcheck`, so API docs, example docs, README discovery, and tooling docs are
all covered by the normal local validation gate.

## Validation

Commands:

```sh
zig build toolingcheck
zig build apicheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed. `toolingcheck` prints `toolingcheck ok`.

## S4-M30 Decision

S4-M30 is closed for the current build/tooling drift bar: adoption and validation
surface discovery now has a dedicated catalog and verifier included in local
validation.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
