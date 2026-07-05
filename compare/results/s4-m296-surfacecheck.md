# S4-M296 Optional Local Surface Drift Checker

Date: 2026-07-06

## Purpose

S4-M288 and S4-M294 consolidated the local Rust `rand` / resolved `rand_core`
and cached `rand_distr 0.6.0` public surfaces into checked-in manifests. S4-M295
made `roadmapcheck` verify representative manifest tokens. S4-M296 adds an
explicit local source drift checker so future comparisons can re-scan the actual
local Rust sources and catch manifest drift when the local checkout/cache changes.

## Change

Added `tools/surfacecheck.zig` and the explicit build step:

```sh
zig build surfacecheck
```

The step is intentionally not part of `zig build doccheck` or generic
`zig build validate`, because it depends on local Rust checkout/cache paths that
are part of this Linux-first comparison environment, not portable project state.
It supports path overrides:

- `ALEA_RAND_ROOT` for the local `rand` source root, defaulting to
  `/home/passchaos/Work/rand/src`;
- `ALEA_RAND_CORE_ROOT` for resolved `rand_core`, defaulting to
  `/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src`;
- `ALEA_RAND_DISTR_ROOT` for cached `rand_distr`, defaulting to
  `/home/passchaos/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src`.

`surfacecheck` scans selected Rust source files for top-level `pub mod`,
`pub use`, `pub fn`, `pub struct`, `pub enum`, `pub trait`, and `pub type`
declarations/re-exports and verifies that representative tokens are mapped in
the S4-M288 or S4-M294 manifests. It also verifies explicit expected tokens for
known important surfaces such as root helper functions, RNG names, distribution
names, sequence aliases, `rand_core` block/utils helpers, `rand_distr` `new` /
`from_mean_cv` / PERT builder names, `multi`, and `weighted` surfaces.

## Baseline Notes

The local cached `rand_distr` source contains `VoidRng` and `rng(seed)` inside a
`#[cfg(test)] mod test` helper module. S4-M296 treats those as test-only helper
symbols, not public crate-surface gaps, and documents the exclusion in the
checker and roadmap evidence.

## Validation

Relevant validation:

```sh
zig fmt build.zig tools/surfacecheck.zig tools/toolingcheck.zig tools/roadmapcheck.zig
zig build surfacecheck
zig build toolingcheck
zig build roadmapcheck
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This checker does not add a new random-number feature, does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not add an
additional architecture/runtime runner, and is not whole-goal completion
evidence. It improves local `rand` / `rand_distr` comparison discipline so future
gap selection starts from actual source drift rather than stale manifest text.
