# S4-M4 Remaining Gap Audit

Date: 2026-07-03

S4-M4 asks for targeted performance follow-up wherever Alea still trails the
locally available Rust `rand` / `rand_distr` evidence in comparable core random
workloads. This audit records the current non-completion state so future work
focuses on genuinely new hypotheses instead of repeating rejected probes.

## Current Blocking Gaps

| Area | Current evidence | Why not closed |
| --- | --- | --- |
| Exact LogNormal transform/codegen | Focused f64 single-sample rows remain around 118M for facade/FastPrng/raw versus local Rust f64 around 146M. Exact f32 rows improved: `fillLogNormal f32` is about 138.5M facade, 144.2M FastPrng direct, and 148.9M ScalarPrng direct after the direct-source f32 standard-fill refinement, but Rust f32 evidence is about 155.3M. Wider `stddev=1` rows are still much slower, around 65M f64 and 60-64M f32 single-sample versus Rust around 80M/79M. | Exact `@exp` transform/codegen is still the bottleneck. The useful f32/native/exp2 paths are opt-in because they change output mapping or accuracy contract. |
| Dense SIMD normal/exponential distribution kernels | Vector APIs and vectorbench coverage are complete, but production vector normal/exponential kernels still use scalar ziggurat lane-fill. f32x8/f64x4 repair, same-candidate repair, all-accepted repair, block-fallback, flat-slice routing, FastPrng repair, and Alea4x64 lane-local repair have all trailed the current direct rows in the real vector-slice harness. | No genuinely dense SIMD candidate has beaten scalar lane-fill while preserving or explicitly versioning rejected-lane stream shape. |
| Static weighted alias f64 throughput | Fresh local Rust `rand_distr::WeightedAliasIndex<f64>` evidence is about 147.2M samples/s, while Alea `AliasTable(f64)` is about 126.6M facade, 132.3M direct, and 127.1M direct fill. | This is a newly tracked S4-M4 performance gap for a comparable core static weighted sampler. A u32 column-draw attempt was rejected because it did not improve the row and changed checksums. |

## Recently Closed Or Narrowed Items

| Area | Current status |
| --- | --- |
| Hypergeometric H2PE coverage | HIN `(100, 30, 10)`, balanced large H2PE `(5000, 2500, 500)`, and skewed large H2PE `(10000, 1000, 2000)` now have local Rust comparison rows plus `distcheck` mean gates. |
| Weighted dynamic sampling | Integer weights are covered by `WeightedIntTree`; generic `WeightedTree(f64)` now has matching local Rust f64 evidence and exceeds it in focused update+sample rows. Static `AliasTable(f64)` now has explicit local Rust `WeightedAliasIndex<f64>` evidence, but it remains a small throughput gap and is listed above. |
| Unit geometry point rows | Direct f64 point rows are at or above local Rust evidence after the FMA and UnitCircle numerator-FMA work; facade UnitCircle remains near the Rust boundary but not a hard standalone blocker. |
| Standard f32 fills | Default f32 standard normal/exponential fills now use the stream-preserving vector8 chunk path, improving ScalarPrng direct rows above focused Rust evidence and narrowing FastPrng/facade rows. Cached-`Rng`, lane-local Alea4x64, generic `Rng.fillNormal`, and parameterized `fillExponential` transfers were rejected. |
| OpenClosed f64 bulk | Exact `(0, 1]` f64 endpoint-grid bulk fill now exceeds local Rust evidence after the raw-word `@mulAdd` conversion; keep `openclosed-endpoint-notes.md` for regression history. |

## Rejected Paths To Avoid Repeating

See `performance-triage.md` for detailed rows. In summary:

- LogNormal exact defaults: wrapper inlining, sampler field storage, value
  receivers, `@mulAdd`, `std.math.exp`, libc `exp` / `expf`, `@setFloatMode`,
  `exp2` as an exact default, noinline transforms, out-of-place/noalias
  transforms, staging chunk sizes, widened f64 exact f32 `exp`, general
  `expm1 + 1`, branchy hybrid `expm1`, single-sample `stddev=1` branches,
  direct-fill f32 `stddev=1` standard-source branches, and vector LogNormal
  mean-zero staging.
- SIMD distribution kernels: optimistic repair, correct/same-candidate repair,
  all-accepted fast return, block fallback, flat scalar-slice routing,
  FastPrng repair, Alea4x64 lane-local repair, and raw-buffer prefetch without a
  rejected-lane stream policy.
- FastPrng/facade f32 standard fills: cached-`Rng` and Alea4x64 lane cycling.

## Requirements For The Next Successful Candidate

A candidate that could close S4-M4 should do one of the following:

1. Improve exact default LogNormal without changing exact output mapping, or add
   a clearly named opt-in profile with documented accuracy/reproducibility
   tradeoffs that covers a gap not already served by `LogNormalApproxF32`,
   `LogNormalExp2F32`, `LogNormalNativeF32`, or `LogNormalNativeExp2F32`.
2. Provide a dense SIMD normal/exponential kernel that runs in the real
   vector-slice harness, preserves or explicitly versions rejected-lane stream
   shape, and beats current direct standard and parameterized vectorbench rows.
3. Improve static `AliasTable(f64)` sampling enough to match the new local Rust
   `WeightedAliasIndex<f64>` evidence, or document a Zig-native tradeoff that
   justifies the remaining gap.
4. Produce new local Rust evidence showing another untracked comparable core
   workload where Alea trails, then add a targeted fix or explicit exclusion.

Until one of these is available, S4-M4 remains in progress and the long-term
objective is not complete.
