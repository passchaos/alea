# S4-M306 Surfacecheck Public-File Guard

Date: 2026-07-06

## Purpose

S4-M305 broadened the explicit `surfacecheck` file list after a manual audit
found public/implementation-surface files that were not scanned. S4-M306 turns
that manual audit into an automated guard: if a local baseline adds or exposes a
new Rust file with public declarations/methods, the checker should fail until the
file is either scanned or intentionally ignored.

## Change

`tools/surfacecheck.zig` now recursively walks each local baseline root and
reports unlisted `.rs` files containing lines that trim to `pub ...`. Each
`SourceGroup` can explicitly ignore known private helper files. The current
local `rand` ignores are:

- `seq/coin_flipper.rs`
- `seq/increasing_uniform.rs`

Those modules contain `pub` methods inside private implementation types, but they
are not re-exported public API. All other public-looking files under the current
local `rand`, resolved `rand_core`, and cached `rand_distr` roots are either
scanned or fail the check.

Current `zig build surfacecheck` summary remains:

```text
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
```

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

This milestone improves local comparison-tool coverage. It does not resolve
S4-M11's exact/default-compatible dense SIMD normal/exponential blocker, does not
add an additional architecture/runtime runner, and is not whole-goal completion
evidence.
