# S4-M304 Surfacecheck Token-Boundary Matching

Date: 2026-07-06

## Purpose

After S4-M301 and S4-M302 broadened `surfacecheck` to more Rust source methods,
manifest checks still used plain substring matching. That is too permissive for
short public names such as `p`, `len`, `get`, `iter`, `weight`, or `fill`: a
manifest could accidentally pass because those letters appeared inside unrelated
words.

## Change

`tools/surfacecheck.zig` now checks manifest tokens with stricter matching:

1. prefer an exact backtick-wrapped code token such as `` `len` ``;
2. for identifier-only tokens, accept only identifier-boundary matches;
3. fall back to substring matching only for non-identifier phrases and scoped
   tokens where ordinary identifier boundaries are not appropriate.

The stricter matcher exposed additional S4-M288 manifest mappings that had been
hidden by substring matches. The local Rust manifest now explicitly maps:

- weighted `Weight` / `weight` diagnostics;
- `seq::index` `iter`;
- `rand_core::block` helper methods `next_word` and `fill_bytes`.

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

`zig build surfacecheck` passes with the stricter matcher and current coverage
summary:

```text
surfacecheck local rand: files=24 expected-tokens=75 source-tokens=135
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=33 expected-tokens=64 source-tokens=177
surfacecheck ok
```

## Non-Completion Note

This milestone improves local comparison-tool correctness. It does not resolve
S4-M11's exact/default-compatible dense SIMD normal/exponential blocker, does not
add an additional architecture/runtime runner, and is not whole-goal completion
evidence.
