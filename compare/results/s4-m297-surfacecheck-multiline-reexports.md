# S4-M297 Surfacecheck Multiline Re-Export Parsing

Date: 2026-07-06

## Purpose

S4-M296 added `zig build surfacecheck` to compare local Rust `rand`, resolved
`rand_core`, and cached `rand_distr` public declarations/re-exports against the
checked-in S4-M288/S4-M294 manifests. The first checker handled single-line
`pub use` declarations directly and relied on expected-token lists for important
multiline re-export blocks. S4-M297 strengthens the checker so the source scan
itself covers Rust multiline re-exports.

## Change

`tools/surfacecheck.zig` now:

- starts collecting a `pub use` block when a top-level `pub use` line has no
  semicolon terminator;
- appends subsequent lines until the terminating `;` is found;
- runs the same alias/name extraction over the collected block, including
  `Error as FooError` aliases and brace-grouped re-exports;
- reports oversized blocks and unterminated blocks as checker failures;
- preserves the explicit `#[cfg(test)]` helper exclusions for local Rust test
  helpers such as `StepRng` and cached `rand_distr` `VoidRng` / `rng`.

This matters for the local baselines because `rand_distr::lib.rs` uses multiline
root re-exports, including grouped distribution and error alias exports.

## Baseline Comparison

The enhanced checker was run against the same local sources used by the current
Linux-first comparison bar:

- `/home/passchaos/Work/rand/src`
- `/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src`
- `/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src`

`zig build surfacecheck` passes with the enhanced parser, showing that the
current S4-M288/S4-M294 manifests cover the scanned single-line and multiline
public-surface tokens at the current expected bar.

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

This milestone does not add a new random-number API, does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not add an
additional architecture/runtime runner, and is not whole-goal completion
evidence. It improves local comparison tooling so future public-surface drift is
less likely to be hidden by multiline Rust re-export syntax.
