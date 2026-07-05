# S4-M311 Toolingcheck Surfacecheck Dependency Guard

Date: 2026-07-06

## Purpose

S4-M310 made `zig build surfacecheck` run `tools/surfacecheck.zig` helper tests
before the checker executable. S4-M311 makes that build-step shape durable by
teaching `toolingcheck` to fail if either surfacecheck dependency is removed.

## Change

`tools/toolingcheck.zig` now requires `build.zig` to contain both dependency
tokens:

- `surfacecheck_step.dependOn(&run_surfacecheck_tests.step)`
- `surfacecheck_step.dependOn(&run_surfacecheck.step)`

`docs/tooling.md` now states that `toolingcheck` verifies the surfacecheck helper tests run before the drift scan.

## Validation

Relevant validation:

```sh
zig fmt tools/toolingcheck.zig tools/roadmapcheck.zig
zig build toolingcheck
zig build surfacecheck
zig build roadmapcheck
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone improves local comparison-tool guardrails. It does not resolve
S4-M11's exact/default-compatible dense SIMD normal/exponential blocker, does not
add an additional architecture/runtime runner, and is not whole-goal completion
evidence.
