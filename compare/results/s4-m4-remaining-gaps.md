# S4-M4 Completion / Next-Bar Audit

Date: 2026-07-04

S4-M4 asked for targeted performance follow-up wherever Alea still trailed the
locally available Rust `rand` / `rand_distr` evidence in comparable core random
workloads. This audit records the current completion state for that milestone
and the deliberately raised next bar. The long-term product goal is broader than
S4-M4, so closing this milestone is not a whole-project completion claim.

## Completion Audit Checklist

Objective for S4-M4: use the completed feature matrix to choose targeted
performance work where Alea trails local Rust in comparable core workloads, and
close or explicitly document each such gap.

| Requirement / artifact | Evidence inspected | Current status |
| --- | --- | --- |
| Local Rust baseline exists for comparable core workloads | `compare/rand_bench/src/main.rs`, `rust-benchmark-coverage-audit.md`, focused Rust rows in `performance-triage.md`, and local `~/Work/rand` / cached `rand_distr` scope in `linux-no-known-gaps-audit.md` | Covered for current Linux scope; new missing rows have been added as found, including skew-large Hypergeometric and weighted alias f32/f64/u32. |
| Alea benchmark rows separate facade/direct/bulk profiles where relevant | `bench/throughput.zig`, `bench/vector.zig`, `performance-triage.md` | Covered for known hot paths; direct-source rows distinguish engine/profile gaps from API gaps. |
| Functionality and validation gates cover distribution changes | `zig build validate-all`, `zig build distcheck`, focused unit tests listed in `performance-triage.md` and `reproducibility-matrix.md`; native and x86_64-linux-musl `zig build test` after the native-f32 LogNormal snapshot tolerance fix | Covered for implemented changes; recent commits ran relevant focused validation before commit, and native-f32 LogNormal snapshot tests now tolerate cross-libc 1 ULP transform differences while keeping stream-state snapshots exact. |
| Non-LogNormal comparable rows no longer trail local Rust without explanation | `performance-triage.md`, `core-rand-coverage.md`, `linux-no-known-gaps-audit.md` | Covered or narrowed by evidence: Hypergeometric HIN/H2PE, weighted trees/alias tables, unit geometry direct rows, standard fills, OpenClosed f64, Cauchy, SkewNormal, inverse-Gaussian-family, and bulk distribution rows have current evidence. |
| LogNormal performance gap has exact-default tradeoff and explicit opt-in coverage | `lognormal-transform-notes.md`, `performance-triage.md`, `lognormal-codegen-audit.md`, `bench-libc`, `distcheck-libc` | Covered for S4-M4 by documented opt-ins; exact default remains a stable-output tradeoff rather than an active blocker. |
| Vector normal/exponential throughput gap has explicit opt-in coverage | `performance-triage.md`, `simd-distribution-kernel-notes.md`, `bench/vector.zig`, `distcheck`, unit snapshots | Covered for S4-M4 by vector-only table-quantile opt-ins: `VectorStandardNormalTableF32/F64`, `VectorNormalTableF32/F64`, `VectorStandardExponentialTableF32/F64`, and `VectorExponentialTableF32/F64` beat current f32x8/f64x4 ziggurat lane-fill rows for users who accept discrete/truncated table-output mappings. `VectorStandardExponentialApproxLogF32` / `VectorExponentialApproxLogF32` remain a smaller table-free f32 approximation. |

Conclusion: S4-M4 is complete for the current local Linux performance-follow-up
bar. The remaining dense-kernel question is now a stricter S4-M5 bar about
replacing or versioning default/general normal/exponential kernels without
relying on approximation-only opt-ins.

## Closed Or Narrowed Items

| Area | Current status |
| --- | --- |
| LogNormal performance coverage | Exact defaults remain intentionally stable on Zig `@exp` output mapping and still trail local Rust in narrow single-sample rows, but S4-M4 now has documented opt-in coverage for the performance gap: `BufferedLogNormal` covers repeated exact-transform sampling, `LogNormalDlsymExp` covers scalar libm `exp` with max-observed 1 ULP drift and `distcheck-libc`, and `LogNormalLibmvec` covers the fastest x86_64-linux-gnu/libmvec path with `bench-libc` rows well above local Rust and f64/f32 `distcheck-libc` mean gates. |
| Vector normal/exponential table opt-ins | `VectorStandardNormalTableF32/F64` / `VectorNormalTableF32/F64` and `VectorStandardExponentialTableF32/F64` / `VectorExponentialTableF32/F64` provide vector-only table-quantile profiles with real-harness rows around 1.0-1.30B lanes/s, far above current f32x8/f64x4 ziggurat lane-fill. They intentionally use a discrete/truncated table-output mapping and are not default replacements. |
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
  diagnostics, libmvec vector-log exponential, low-degree/f32-widened
  approximate-log f64 exponential, and raw-buffer prefetch without a
  rejected-lane stream policy.
- FastPrng/facade f32 standard fills: cached-`Rng` and Alea4x64 lane cycling.

## Raised Next Bar: S4-M5

S4-M5 is the next stricter milestone after S4-M4. It is intentionally stronger
than local Rust parity and opt-in throughput coverage.

A candidate that could close S4-M5 should do one of the following:

1. Provide a default or explicitly versioned dense SIMD normal/exponential
   kernel that runs in the real vector-slice harness, preserves or deliberately
   versions rejected-lane stream shape, and beats current direct standard and
   parameterized vectorbench rows without relying solely on discrete/truncated or
   approximate-only table profiles.
2. Provide a policy decision with evidence that a named approximation profile is
   allowed to satisfy the default/general dense-kernel bar for a specific API
   surface, including statistical-quality gates and reproducibility snapshots.
3. Produce new local Rust evidence showing another untracked comparable core
   workload where Alea trails, then add a targeted fix or explicit exclusion.

Until S4-M5 is closed, the long-term objective remains active. Do not call
`update_goal(status=complete)` based only on S4-M4 closure.
