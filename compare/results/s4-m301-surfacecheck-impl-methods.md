# S4-M301 Surfacecheck Impl-Method Scanning

Date: 2026-07-06

## Purpose

S4-M296 introduced `zig build surfacecheck`, and S4-M297 taught it to parse
multiline Rust `pub use` blocks. The checker still focused on top-level public
declarations/re-exports, while many Rust APIs are exposed as `pub fn` methods
inside `impl` blocks. S4-M301 broadens the checker so local public method drift
is visible too.

## Change

`tools/surfacecheck.zig` now checks non-test `impl`-body `pub fn` lines against
the relevant public-surface manifest. It continues to skip explicit `#[cfg(test)]`
helper modules, preserving the earlier exclusions for local test-only helpers.

With the broader scan, the manifests were updated to make newly exposed method
mappings explicit:

- local `rand` / `rand_core`: `reseed`, `num_choices`, `new_inclusive`,
  `update_weights`, `weights`, `total_weight`, `len`, `is_empty`, `into_vec`,
  and `rand_core::block` helper methods such as `reconstruct`, `reset_and_skip`,
  `word_offset`, `remaining_results`, and `next_u64_from_u32`;
- local `rand_distr`: weighted alias/tree methods including `weights`,
  `is_empty`, `len`, `get`, `pop`, `push`, `update`, and `try_sample`.

These names map to existing Alea APIs such as `newInclusive`, `numChoices`,
`updateWeights`, weight/total diagnostics, `IndexVec.intoVec`, dynamic-tree
`isEmpty` / `len` / `get` / `pop` / `push` / `update`, checked sampling, or to
Rust-only implementation scaffolding where appropriate.

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

This milestone strengthens local comparison tooling and manifest evidence. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add an additional architecture/runtime runner, and is not
whole-goal completion evidence.
