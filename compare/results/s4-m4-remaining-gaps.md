# S4-M4 Remaining Gap Audit

Date: 2026-07-04

S4-M4 asks for targeted performance follow-up wherever Alea still trails the
locally available Rust `rand` / `rand_distr` evidence in comparable core random
workloads. This audit records the current non-completion state so future work
focuses on genuinely new hypotheses instead of repeating rejected probes.

## Completion Audit Checklist

Objective for S4-M4: use the completed feature matrix to choose targeted
performance work where Alea trails local Rust in comparable core workloads, and
close or explicitly document each such gap. The long-term project goal is
broader than S4-M4, so this checklist only audits the current performance
follow-up milestone.

| Requirement / artifact | Evidence inspected | Current status |
| --- | --- | --- |
| Local Rust baseline exists for comparable core workloads | `compare/rand_bench/src/main.rs`, `rust-benchmark-coverage-audit.md`, focused Rust rows in `performance-triage.md`, and local `~/Work/rand` / cached `rand_distr` scope in `linux-no-known-gaps-audit.md` | Covered for current Linux scope; new missing rows have been added as found, including skew-large Hypergeometric and weighted alias f32/f64/u32. |
| Alea benchmark rows separate facade/direct/bulk profiles where relevant | `bench/throughput.zig`, `bench/vector.zig`, `performance-triage.md` | Covered for known hot paths; direct-source rows distinguish engine/profile gaps from API gaps. |
| Functionality and validation gates cover distribution changes | `zig build validate-all`, `zig build distcheck`, focused unit tests listed in `performance-triage.md` and `reproducibility-matrix.md`; native and x86_64-linux-musl `zig build test` after the native-f32 LogNormal snapshot tolerance fix | Covered for implemented changes; recent commits ran relevant focused validation before commit, and native-f32 LogNormal snapshot tests now tolerate cross-libc 1 ULP transform differences while keeping stream-state snapshots exact. |
| Non-LogNormal comparable rows no longer trail local Rust without explanation | `performance-triage.md`, `core-rand-coverage.md`, `linux-no-known-gaps-audit.md` | Mostly closed or narrowed by evidence: Hypergeometric HIN/H2PE, weighted trees/alias tables, unit geometry direct rows, standard fills, OpenClosed f64, Cauchy, SkewNormal, inverse-Gaussian-family, and bulk distribution rows have current evidence. |
| LogNormal performance gap has exact-default tradeoff and explicit opt-in coverage | `lognormal-transform-notes.md`, `performance-triage.md`, `lognormal-codegen-audit.md`, `bench-libc`, `distcheck-libc` | Covered for S4-M4 by documented opt-ins; exact default remains a stable-output tradeoff rather than the active blocker. |
| Dense SIMD normal/exponential kernels beat scalar lane-fill in real vector-slice harness | `simd-distribution-kernel-notes.md`, vectorbench rows in `performance-triage.md` | Not complete; see blocking gap below. |

Conclusion: S4-M4 is not complete. The remaining work is no longer unverified
LogNormal coverage; the concrete hard blocker is the dense SIMD kernel gap below.

## Current Blocking Gaps

| Area | Current evidence | Why not closed |
| --- | --- | --- |
| Dense SIMD normal/exponential distribution kernels | Vector APIs and vectorbench coverage are complete, but production vector normal/exponential kernels still use scalar ziggurat lane-fill. f32x8/f64x4 repair, same-candidate repair, all-accepted repair, block-fallback, mantissa-range block-fallback, mask-redraw exponential, flat-slice routing, FastPrng repair, Alea4x64 lane-local repair, Marsaglia polar normal, approximate-log polar normal, ratio-of-uniforms normal, inverse-CDF normal, f32-only inverse-CDF normal, central-fast inverse-CDF normal, tail-repair inverse-CDF normal, libmvec vector-log exponential, f64 approximate-log exponential, and f64 direct-next/noinline codegen probes have all trailed or failed to transfer into current direct rows in the real vector-slice harness. A new vector-only f32 approximate-log exponential profile beats f32x8 ziggurat rows as an explicit output-mapping opt-in, but it does not cover normal or f64/default exponential. | No default or general dense SIMD candidate has beaten scalar lane-fill while preserving or explicitly versioning rejected-lane stream shape across the required normal/exponential surface; `simd-distribution-kernel-notes.md` now lists the minimum real-harness vectorbench rows required for any future candidate. |

## Recently Closed Or Narrowed Items

| Area | Current status |
| --- | --- |
| LogNormal performance coverage | Exact defaults remain intentionally stable on Zig `@exp` output mapping and still trail local Rust in narrow single-sample rows, but S4-M4 now has documented opt-in coverage for the performance gap: `BufferedLogNormal` covers repeated exact-transform sampling, `LogNormalDlsymExp` covers scalar libm `exp` with max-observed 1 ULP drift and `distcheck-libc`, and `LogNormalLibmvec` covers the fastest x86_64-linux-gnu/libmvec path with `bench-libc` rows well above local Rust and f64/f32 `distcheck-libc` mean gates. |
| f32 vector exponential opt-in | `VectorStandardExponentialApproxLogF32` / `VectorExponentialApproxLogF32` provide a vector-only f32 approximate-log inverse-transform profile with real-harness rows above current f32x8 ziggurat lane-fill. This narrows the exponential side of S4-M4 for users who accept the explicit approximation/output-mapping contract, but it is not a default replacement and does not close normal or f64 dense-kernel requirements. |
| Hypergeometric H2PE coverage | HIN `(100, 30, 10)`, balanced large H2PE `(5000, 2500, 500)`, and skewed large H2PE `(10000, 1000, 2000)` now have local Rust comparison rows plus `distcheck` mean gates. |
| Weighted dynamic/static sampling | Integer dynamic weights are covered by `WeightedIntTree`; generic `WeightedTree(f64)` now has matching local Rust f64 evidence and exceeds it in focused update+sample rows. Static `AliasTable(f32)`, `AliasTable(f64)`, and `AliasTable(u32)` now have explicit local Rust `WeightedAliasIndex` evidence and exceed it in the relevant facade/direct/fill rows after the power-of-two one-word threshold fast path. |
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
  all-accepted fast return, block fallback, mantissa-range block fallback,
  mask-redraw exponential, flat scalar-slice routing, FastPrng repair, Alea4x64
  lane-local repair, Marsaglia polar normal, approximate-log Marsaglia polar
  normal, dense approximate-log Marsaglia polar normal, ratio-of-uniforms
  normal, CLT summed-uniform normal, inverse-CDF normal, f32-only inverse-CDF
  normal, central-fast inverse-CDF normal,
  tail-repair/tail-only/reduced-degree/central-mask inverse-CDF normal,
  ziggurat-tail inverse-CDF normal, invalid central-only/tail-zero inverse-CDF
  diagnostics, libmvec vector-log exponential, f32-widened approximate-log f64
  exponential, and raw-buffer prefetch without a rejected-lane stream policy.
- FastPrng/facade f32 standard fills: cached-`Rng` and Alea4x64 lane cycling.

## Requirements For The Next Successful Candidate

A candidate that could close S4-M4 should do one of the following:

1. Provide a dense SIMD normal/exponential kernel that runs in the real
   vector-slice harness, preserves or explicitly versions rejected-lane stream
   shape, and beats current direct standard and parameterized vectorbench rows.
2. Produce new local Rust evidence showing another untracked comparable core
   workload where Alea trails, then add a targeted fix or explicit exclusion.

Until one of these is available, S4-M4 remains in progress and the long-term
objective is not complete.
