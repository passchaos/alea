# S4-M319 Roadmapcheck `validate-local` Blocker Token

Date: 2026-07-06

## Purpose

S4-M317 added `zig build validate-local` as the local Linux aggregate for native
validation plus local Rust public-surface drift checking. S4-M319 keeps that
aggregate visible in S4-M11 blocker evidence so future blocker refreshes do not
fall back to listing only `surfacecheck` without the aggregate local validation
entry point.

## Change

- `compare/results/s4-m11-blocker-audit.md` now states that
  `zig build validate-local` aggregates native validation with the current local
  public-surface scan.
- `tools/roadmapcheck.zig` now requires `zig build validate-local` in the S4-M11
  blocker audit token set.

## Validation

Relevant validation:

```sh
zig fmt tools/roadmapcheck.zig
zig build roadmapcheck
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone improves blocker-evidence drift checking. It does not resolve
S4-M11's exact/default-compatible dense SIMD normal/exponential blocker, does not
add an additional architecture/runtime runner, and is not whole-goal completion
evidence.
