# S4-M316 Surfacecheck Ignored-File Guard

Date: 2026-07-06

## Purpose

S4-M306 added explicit ignored public-file entries for private local `rand::seq`
helper modules. Those ignores are intentional, but an ignore list can become
stale if a file is deleted, renamed, or stops containing public-looking helper
methods. S4-M316 makes stale ignores visible.

## Change

`tools/surfacecheck.zig` now validates every `ignored_public_files` entry after
its recursive unlisted-public-file scan:

- the ignored file must still be readable;
- the ignored file must still contain at least one public-looking line.

The current ignored private helper files remain valid:

- `seq/coin_flipper.rs`
- `seq/increasing_uniform.rs`

## Validation

Relevant validation:

```sh
zig fmt tools/surfacecheck.zig tools/roadmapcheck.zig
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
