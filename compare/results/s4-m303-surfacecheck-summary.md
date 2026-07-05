# S4-M303 Surfacecheck Coverage Summaries

Date: 2026-07-06

## Purpose

`zig build surfacecheck` had become a useful local guard against stale
`rand` / `rand_core` / `rand_distr` manifests, but a successful run only printed
`surfacecheck ok`. S4-M303 makes the checker more auditable by reporting how many
source files, manifest expected tokens, and source-discovered public tokens it
validated for each local baseline group.

## Change

`tools/surfacecheck.zig` now accumulates and prints per-group coverage summaries:

```text
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
```

The exact counts intentionally reflect the current local source roots and the
checker scope. They make future drift easier to notice when adding/removing
scanned files or broadening token extraction.

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

This milestone improves local comparison-tool observability. It does not resolve
S4-M11's exact/default-compatible dense SIMD normal/exponential blocker, does not
add an additional architecture/runtime runner, and is not whole-goal completion
evidence.
