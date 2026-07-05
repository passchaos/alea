# S4-M305 Surfacecheck Extra Public Files

Date: 2026-07-06

## Purpose

After S4-M304, `surfacecheck` used stricter token matching and printed coverage
summaries. A follow-up source-list audit found two public/implementation-surface
files that were already described by manifests but not yet included in the
source-driven scan:

- local `rand/src/distr/other.rs`, which defines `Alphanumeric` and `Alphabetic`;
- cached `rand_distr/src/ziggurat_tables.rs`, which exposes the `ZigTable` type
  used by the local Rust distribution implementations.

Private local `rand::seq` helper modules such as `coin_flipper` and
`increasing_uniform` remain intentionally excluded because they are not re-exported
public surface.

## Change

`tools/surfacecheck.zig` now scans both additional files. The S4-M294
`rand_distr` manifest scanned-source notes now explicitly mention
`ziggurat_tables.rs` for public implementation-table type names.

Current `zig build surfacecheck` summary:

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
