# S4-M5 Approximation-Profile Policy

Date: 2026-07-04

S4-M5 asked for a stricter answer to the remaining vector normal/exponential
question after S4-M4: either produce a default or explicitly versioned dense SIMD
kernel, or make a documented policy decision that a named approximation profile
is allowed to satisfy a specific default/general dense-kernel API surface with
statistical-quality and reproducibility evidence.

This policy closes S4-M5 for the current local Linux bar. It is not a whole
project completion claim, and it does not make approximation profiles silent
replacements for exact/default APIs.

## Policy Decision

Alea keeps the exact/default vector normal and exponential APIs on scalar
ziggurat lane-fill until a stream-compatible dense kernel wins in the real
`vectorbench` slice harness. The following named profiles are accepted as the
recommended general high-throughput vector distribution surface when callers
explicitly choose an approximation/output-mapping contract:

- `VectorStandardNormalTableF32` / `VectorNormalTableF32`
- `VectorStandardNormalTableF64` / `VectorNormalTableF64`
- `VectorStandardExponentialTableF32` / `VectorExponentialTableF32`
- `VectorStandardExponentialTableF64` / `VectorExponentialTableF64`
- `VectorStandardExponentialApproxLogF32` / `VectorExponentialApproxLogF32`

The corresponding top-level `vector*`, `fillVector*`, checked, direct-source,
and reusable-sampler APIs are part of the same accepted surface. Their names are
the opt-in boundary: callers must spell `Table`, `ApproxLog`, or another future
profile name to opt into approximation-specific distribution and reproducibility
semantics.

## What This Does And Does Not Mean

Accepted:

- For high-volume vector normal/exponential workloads where discrete/truncated or
  approximate-log output is acceptable, these named profiles satisfy the S4-M5
  dense-throughput requirement on the local Linux platform.
- They may be documented as the first recommendation for throughput-first vector
  normal/exponential sampling, provided the approximation caveats are stated.
- Their output mappings are versioned-stable opt-ins and may be changed only as a
  documented versioned profile update.

Not accepted:

- They do not replace `Rng.vectorStandardNormal`, `Rng.vectorNormal`,
  `Rng.vectorStandardExponential`, `Rng.vectorExponential`, or the distribution
  namespace defaults.
- They do not claim exact ziggurat output compatibility or scalar/repeated-lane
  stream compatibility.
- The normal table profiles do not provide unbounded tails; the current 16,384
  midpoint table is discrete and truncated around `±4.01`.
- The exponential table profiles are discrete/truncated; the f32 `ApproxLog`
  profile is approximate and f32-only.
- They are not sufficient for tail-sensitive simulations unless the caller has
  accepted the documented approximation profile.

## Evidence Checklist

| Requirement | Evidence |
| --- | --- |
| Named API surface exists | `src/distributions.zig`, `docs/api-reference.md`, and `compare/results/distribution-parity-matrix.md` list the table and approx-log vector normal/exponential profiles. |
| Reproducibility snapshots exist | `src/distributions.zig` contains stable snapshot tests for table normal f32/f64, table exponential f32/f64, and approx-log f32 exponential profiles; `compare/results/reproducibility-matrix.md` classifies them as versioned-stable output mappings. |
| Statistical-quality gates exist | `tools/distcheck.zig` uses vector samples with mean/variance gates plus fixed-CDF smoke gates, and `tools/profilecheck.zig` now extends accepted profiles to 1,048,576-lane mean/variance/CDF checks for standard normal (`-3` through `3`) and standard exponential (`0.1` through `6`). Parameterized profiles have scaled mean/variance gates in `distcheck`. |
| Throughput wins in real harness | `compare/results/performance-triage.md` records public `vectorbench -- 16777216 "Table"` rows around 1.0-1.30B lanes/s for table normal/exponential f32/f64, above current default scalar ziggurat lane-fill rows around 454-477M lanes/s; approx-log f32 exponential also beats default f32 ziggurat lane-fill as a smaller table-free profile. |
| Rejected exact/default alternatives are documented | `compare/results/simd-distribution-kernel-notes.md` and `compare/results/performance-triage.md` list rejected ziggurat repair, block fallback, mask-redraw, Marsaglia polar, ratio-of-uniforms, inverse-CDF, CLT, libmvec vector-log, f64 approx-log, and lane-local candidates. |
| Local Rust comparison scope is clear | `compare/results/s4-m5-rand-simd-audit.md` confirms local `rand` SIMD support covers uniform/integer/wide values only, and local `rand_distr 0.6.0` normal/exponential remain scalar ziggurat implementations with no SIMD non-uniform row. |

## Completion Decision

S4-M5 is closed by the policy path for the current local Linux bar: Alea accepts
named vector approximation profiles as the general throughput-first dense vector
normal/exponential surface, while preserving exact/default APIs on scalar
ziggurat lane-fill.

The long-term objective remains active. S4-M6 has since hardened this decision
with native and WASI `profilecheck` evidence, S4-M7 added native and WASI
8Mi-lane tail-focused gates, S4-M8 added native and WASI deterministic
multi-seed stress gates, S4-M9 added native and WASI long stress gates, and
S4-M10 added x86_64-linux-musl long-sweep execution. The next roadmap bar should
keep exact/default dense SIMD candidates under watch, use additional
architecture/runtime runners if they become available, and add new Rust
comparison rows if the local Rust surface gains SIMD non-uniform distributions.
