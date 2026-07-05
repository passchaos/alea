# S4-M315 Roadmapcheck Surface Blocker Tokens

Date: 2026-07-06

## Purpose

S4-M307 refreshed the S4-M11 blocker audit with current `surfacecheck` coverage
and the conclusion that no new unblocked local `rand` / `rand_distr` public
surface gap was found. S4-M315 makes that blocker evidence durable by adding it
to `roadmapcheck`'s required S4-M11 blocker tokens.

## Change

`tools/roadmapcheck.zig` now requires `compare/results/s4-m11-blocker-audit.md`
to include:

- `surfacecheck local rand`
- `No new unblocked public-surface gap`

These checks complement the existing S4-M11 tokens for exact/default dense SIMD,
missing runtime families, lack of local Rust SIMD non-uniform evidence, and the
non-completion warning.

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

This milestone strengthens blocker-evidence drift checking. It does not resolve
S4-M11's exact/default-compatible dense SIMD normal/exponential blocker, does not
add an additional architecture/runtime runner, and is not whole-goal completion
evidence.
