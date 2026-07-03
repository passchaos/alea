# Rust Benchmark Coverage Audit

Date: 2026-07-03

This file maps the current local Rust benchmark surface in
`compare/rand_bench/src/main.rs` to Alea evidence. It is a S4-M4 support audit:
when a Rust row exists and Alea trails, the row should either have a targeted
fix, an explicit watch item, or a documented Zig-native reason it is not a core
Alea gap.

## Summary

The local Rust benchmark surface is covered by Alea benchmark/evidence rows.
The previous S4-M4 performance blockers are closed or reshaped: exact LogNormal
is now documented as a stable-output tradeoff with explicit opt-in performance
profiles, while dense SIMD normal/exponential work has moved to the stricter
S4-M5 product bar. The Rust benchmark harness itself does not include a SIMD
distribution row; `s4-m5-rand-simd-audit.md` confirms local `rand` SIMD support
is limited to uniform/integer/wide values while local `rand_distr`
normal/exponential remain scalar ziggurat implementations. Alea `vectorbench`
evidence keeps the S4-M5 product-above-Rust blocker open.

## Coverage Map

| Rust benchmark group | Alea evidence | Status |
| --- | --- | --- |
| `rand SmallRng`, `StdRng`, fill-only, `next_u64` | Alea engine `next` / fill rows, PractRand reports, reproducibility matrix | Covered; engine throughput and statistical evidence are tracked separately from distribution rows. |
| bounded integers, float f32/f64, `Open01`, `OpenClosed01`, float range | `Rng` scalar/fill/range rows, open/open-closed notes, `performance-triage.md` | Covered; Alea scalar float/range rows exceed local Rust, and exact f64 open-closed bulk is at/above the local Rust boundary. |
| sequence sample indices | `seq` benchmark rows and `sampleIndicesU32` portable snapshot evidence | Covered. |
| bool, alphanumeric | `Rng` bool/chance/ratio rows and `ascii` rows | Covered. |
| `rand weighted index` | `Rng.weightedIndex`, `AliasTable`, `WeightedChoice` rows | Covered. |
| `rand_distr WeightedAliasIndex` f32/f64/u32 | `AliasTable(f32/f64/u32)` rows | Covered after the power-of-two one-word threshold fast path; f32/f64 exceed Rust directly and u32 exceeds Rust with `ScalarPrng`. |
| `rand_distr WeightedTreeIndex` integer/f64 | `WeightedIntTree`, `WeightedTree(f64)` rows | Covered; integer and f64 update+sample evidence now exist. |
| standard/parameterized normal and exponential, f32/f64 | scalar, raw, native-f32 opt-in, fill, vectorbench rows, and `s4-m5-rand-simd-audit.md` | Covered for scalar/fill evidence. Local Rust has no comparable SIMD non-uniform row; dense SIMD remains a separate S4-M5 product bar because production vector kernels are still scalar lane-fill. |
| Poisson, Geometric, StandardGeometric, Binomial, Hypergeometric | discrete distribution and fill rows, HIN/H2PE rows, `distcheck` | Covered; Hypergeometric includes HIN, balanced large H2PE, and skew-large H2PE. |
| Gamma, ChiSquared, Beta, FisherF, StudentT | distribution rows, cached sampler rows, bulk fill rows, `distcheck` | Covered. |
| Triangular, Cauchy, Pareto, Weibull | scalar and vectorized/bulk rows, `distcheck` | Covered; current rows exceed local Rust evidence. |
| LogNormal f32/f64 and `stddev=1` variants | scalar/raw/fill/vector/opt-in rows, `lognormal-transform-notes.md` | Not closed for exact defaults. This is the active exact LogNormal transform/codegen blocker. |
| Gumbel, Frechet, SkewNormal, PERT | scalar/fill rows, shape=2 SkewNormal row, `distcheck` | Covered. |
| UnitCircle, UnitDisc, UnitSphere, UnitBall | scalar/direct/fill/vector rows, unit geometry probes | Covered for direct point rows and bulk APIs; facade UnitCircle is near the Rust boundary but not a hard standalone blocker. |
| InverseGaussian, NormalInverseGaussian | scalar/cached/fill rows and family probes | Covered for cached/direct/bulk evidence. |
| Zipf, Zeta | scalar/fill rows, `distcheck` | Covered. |

## Action Rule

If a new Rust benchmark row is added, update this audit in the same change and
then either:

1. add/refresh the matching Alea benchmark row,
2. add a targeted optimization, or
3. record a S4-M4 watch/rejection row in `performance-triage.md`.
