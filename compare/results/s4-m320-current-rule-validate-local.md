# S4-M320 Current-Rule `validate-local` Guidance

Date: 2026-07-06

## Purpose

S4-M317 added `zig build validate-local` for Linux-first local comparison work,
but the living roadmap's Current Rule still said to use `zig build validate` for
broad local validation. S4-M320 updates the rule so future changes affecting
local `rand` / `rand_distr` comparison workflows or public-surface evidence use
the aggregate that includes `surfacecheck`.

## Change

`compare/results/core-rand-coverage.md` now distinguishes:

- `zig build validate` for broad native validation;
- `zig build validate-local` when a change affects local `rand` / `rand_distr`
  comparison workflow or public-surface evidence;
- `zig build statcheck` as the minimum for engine/distribution/range/sampling
  internals.

`tools/roadmapcheck.zig` now requires the `zig build validate-local` token in the
roadmap/audit evidence set.

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

This milestone improves validation guidance. It does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not add an
additional architecture/runtime runner, and is not whole-goal completion
evidence.
