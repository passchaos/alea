# S4-M324 `validate-local` Runtime Evidence Sync

Date: 2026-07-06

## Purpose

S4-M317 introduced `validate-local` as `validate + surfacecheck`. S4-M321 later
added `runtimecheck` to the aggregate. S4-M324 updates the original S4-M317
evidence so it does not lag behind the current build graph.

## Change

`compare/results/s4-m317-validate-local.md` now states that `validate-local`
depends on:

- `zig build validate`
- `zig build surfacecheck`
- `zig build runtimecheck`

It also states that `toolingcheck` verifies all three dependencies.

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

This milestone improves evidence accuracy. It does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not execute
an additional architecture/runtime runner, and is not whole-goal completion
evidence.
