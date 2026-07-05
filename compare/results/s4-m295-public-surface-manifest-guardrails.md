# S4-M295 Public-Surface Manifest Guardrails

Date: 2026-07-06

## Purpose

S4-M288 and S4-M294 created consolidated manifests for the local Rust `rand` /
resolved `rand_core` surface and the cached local `rand_distr 0.6.0` surface.
Before this milestone, `roadmapcheck` only verified that those evidence files
existed and were referenced from the roadmap/audits. S4-M295 strengthens that
bar so future local `rand` / `rand_distr` comparisons do not silently regress to
file-existence-only evidence.

## Change

`tools/roadmapcheck.zig` now reads both public-surface manifests directly and
checks representative tokens from each one:

- scanned source / version tokens, such as `~/Work/rand/src/lib.rs`, resolved
  `rand_core 0.10.1`, and the cached `rand_distr-0.6.0/src` path;
- major public-surface sections, including root `rand`, RNG namespace,
  distribution, sequence, `rand_core`, root `rand_distr`, `multi`, `weighted`,
  and utility/internal sections;
- representative Rust-only or Zig-native-excluded surfaces, such as
  `ThreadRng` / `rng()`, distribution and uniform traits, `seq::index`,
  `rand_core::block`, `AliasableWeight`, and `Distribution<T>` trait
  implementations;
- explicit no-new-unblocked-gap result language for both manifests;
- explicit non-completion notes that prevent these manifests from being treated
  as whole-goal completion evidence.

The checker also advances the roadmap/audit next-gap guard from S4-M295 to
S4-M296, ensuring the roadmap is raised after closing this guardrail milestone.

## Baseline Comparison

Local Rust references remain:

- `~/Work/rand` for `rand` public API and the resolved local `rand_core` surface;
- `~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0` for the
  cached `rand_distr` public surface.

S4-M295 does not claim a new API parity closure. It hardens evidence quality for
future comparisons against those references by requiring the checked-in
manifests to keep their source/version scope, major surface categories,
representative exclusions, and no-new-gap/non-completion conclusions intact.

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

This milestone does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add an additional architecture/runtime
runner, and is not whole-goal completion evidence. It only improves the
automated audit guardrails around the local Rust and `rand_distr` public-surface
manifests.
