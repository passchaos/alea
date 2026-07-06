# S4-M334 Example Aggregate Validation Guard

## Gap

`zig build validate` depends on aggregate `zig build examples`, and
`zig build examplecheck` already checked that every checked-in example was
listed in `docs/examples.md` with a focused `zig build run-*` command. It did
not directly verify that each cataloged example remained wired into the aggregate
`examples` build step. A future build edit could therefore leave an example
source documented and individually runnable while accidentally removing it from
normal validation coverage.

This matters for Alea's local Linux product bar because the example suite is a
core adoption surface for APIs that intentionally exceed local Rust `rand` /
`rand_distr` ergonomics. The examples should remain validated as a group without
requiring maintainers to manually cross-check `docs/examples.md` against
`build.zig`.

## Change

`tools/examplecheck.zig` now stores an aggregate dependency token for every
cataloged runnable example and checks that `build.zig` contains the matching
`examples_step.dependOn(...)` entry.

The guard covers all currently cataloged examples, including:

- `examples/basic.zig` via `examples_step.dependOn(&run_example.step)`
- `examples/reproducible_streams.zig` via
  `examples_step.dependOn(&run_reproducible_streams_example.step)`
- `examples/range_sampling.zig` via
  `examples_step.dependOn(&run_range_sampling_example.step)`
- `examples/weighted_sampling.zig` via
  `examples_step.dependOn(&run_weighted_sampling_example.step)`
- `examples/sequence_sampling.zig` via
  `examples_step.dependOn(&run_sequence_sampling_example.step)`
- `examples/string_generation.zig` via
  `examples_step.dependOn(&run_string_generation_example.step)`
- `examples/unit_geometry.zig` via
  `examples_step.dependOn(&run_unit_geometry_example.step)`

The documentation now describes this aggregate guard in both
`docs/examples.md` and `docs/tooling.md`.

## Validation

Focused validation command:

```text
$ zig build examplecheck
examplecheck ok
```

Broader documentation/roadmap validation command:

```text
$ zig build doccheck
examplecheck ok
toolingcheck ok
readmecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M334 is closed for the current bar: runnable examples are now guarded across
three layers — source presence, documentation/focused command coverage, and
aggregate `zig build examples` wiring. This is an adoption and validation
hardening improvement only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
