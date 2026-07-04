# Active Goal Completion Audit

Date: 2026-07-04

Active objective: keep working toward Alea's project mission until the goal is
actually achieved. In concrete terms for the current thread, this means driving
Alea's core RNG functionality and local Linux performance/validation roadmap to
no known core gaps against the locally available Rust `rand` / `rand_distr`
evidence, then raising the bar instead of declaring the product permanently
finished.

This audit is intentionally not a completion claim. It records the current
prompt-to-artifact checklist and the evidence that prevents calling the goal
complete.

## Prompt-to-Artifact Checklist

| Requirement | Evidence artifact / command | Current finding |
| --- | --- | --- |
| Core RNG functionality breadth must match or exceed local Rust evidence | `compare/results/distribution-parity-matrix.md`, `compare/results/linux-no-known-gaps-audit.md`, `docs/api-reference.md`, `zig build apicheck` | Functionality gaps are closed for the current Linux/local Rust surface. |
| Statistical validation must cover primary engines | PractRand reports under `compare/results/`, `compare/results/2026-06-28-practrand-128gib-summary.md`, `zig build statcheck` | Current 128GiB Linux stage is closed; portable fill smoke is recorded for `Xoshiro256PlusPlus`. |
| Reproducibility must be documented and checked beyond x86_64 Linux where possible | `compare/results/reproducibility-matrix.md`, `compare/results/2026-07-03-repro-wasm32-wasi-node.md`, `zig build crosscheck`, `zig build validate-all` | Current second-target WASI bar is closed; broader non-WASI runner gaps are tracked separately. |
| Benchmark parity must cover local Rust comparable rows | `compare/rand_bench/src/main.rs`, `bench/throughput.zig`, `bench/vector.zig`, `compare/results/rust-benchmark-coverage-audit.md` | Current local Rust benchmark surface is mapped to Alea evidence. |
| S4-M1 broader platform reproducibility | `core-rand-coverage.md`, WASI report, `cross-platform-repro-blocker.md` | Closed for current bar. |
| S4-M2 longer statistical validation | 128GiB PractRand summary and engine reports | Closed for current bar. |
| S4-M3 SIMD/vector API design | `bench/vector.zig`, `simd-distribution-kernel-notes.md`, source audit in `core-rand-coverage.md` | Closed for API/prototype bar; performance blocker moved to S4-M4. |
| S4-M4 targeted performance follow-up | `compare/results/performance-triage.md`, `compare/results/s4-m4-remaining-gaps.md`, `lognormal-codegen-audit.md`, `simd-distribution-kernel-notes.md` | Closed for the current local Linux bar; LogNormal and vector normal/exponential throughput gaps now have documented opt-in coverage. |
| S4-M5 default/general dense SIMD kernels | `compare/results/s4-m5-approximation-policy.md`, `compare/results/s4-m4-remaining-gaps.md`, `compare/results/simd-distribution-kernel-notes.md`, `compare/results/performance-triage.md` | Closed for the current local Linux policy bar: named table and approx-log vector profiles are accepted as the explicit throughput-first dense vector surface, while exact/default APIs remain scalar ziggurat lane-fill. |
| S4-M6 accepted profile hardening | `compare/results/2026-07-04-s4-m6-profilecheck.md`, `tools/profilecheck.zig`, `compare/results/reproducibility-matrix.md`, `zig build validate`, `zig build crosscheck`, `zig build -Doptimize=ReleaseFast wasi-profilecheck` | Closed for the current bar: accepted profiles now have 1Mi-lane mean/variance/CDF gates, native validation integration, WASI execution, and cross-target compile coverage. |
| S4-M7 longer tail/profile validation | `compare/results/2026-07-04-s4-m7-profiletailcheck.md`, `tools/profiletailcheck.zig`, `zig build -Doptimize=ReleaseFast profilecheck-tail`, `zig build -Doptimize=ReleaseFast wasi-profiletailcheck` | Closed for the current bar: accepted profiles now have 8Mi-lane tail-focused gates on native Linux and WASI. |
| S4-M8 multi-seed/profile stress | `compare/results/2026-07-04-s4-m8-profilestresscheck.md`, `tools/profilestresscheck.zig`, `zig build -Doptimize=ReleaseFast profilecheck-stress`, `zig build -Doptimize=ReleaseFast wasi-profilestresscheck` | Closed for the current bar: accepted profiles now have deterministic 8-seed stress gates on native Linux and WASI. |
| S4-M9 longer stress sweep | `compare/results/2026-07-04-s4-m9-profilelongcheck.md`, `tools/profilelongcheck.zig`, `zig build -Doptimize=ReleaseFast profilecheck-long`, `zig build -Doptimize=ReleaseFast wasi-profilelongcheck` | Closed for the current long-sweep bar: accepted profiles now have 8Mi-lane/profile long stress gates on native Linux and WASI. |
| S4-M10 additional non-WASI runtime | `compare/results/2026-07-04-s4-m10-profilelong-musl.md`, `zig build -Dtarget=x86_64-linux-musl -Doptimize=ReleaseFast profilecheck-long` | Closed for the current bar: accepted profiles execute the long sweep on x86_64-linux-musl in addition to native glibc and WASI. |
| S4-M11 exact/default dense-kernel breakthrough or new external gap | `compare/results/s4-m11-blocker-audit.md`, `core-rand-coverage.md`, future dense SIMD evidence, future architecture/runtime reports, future local Rust audits | Blocked in this session; no exact/default-compatible dense SIMD winner is known, no additional runtime runner is installed, and no new local Rust core gap has been identified. |
| S4-M12 accepted vector profile adoption example | `examples/vector_profiles.zig`, `zig build run-vector-profiles`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m12-vector-profile-example.md` | Closed for the current bar: a runnable example demonstrates exact/default vectors versus explicit `Table`/`ApproxLog` opt-ins. |
| S4-M13 LogNormal opt-in adoption example | `examples/lognormal_profiles.zig`, `zig build run-lognormal-profiles`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m13-lognormal-profile-example.md` | Closed for the current bar: a runnable example demonstrates exact/default, buffered, native/exp2, and platform libc-backed LogNormal profiles. |
| S4-M14 NativeF32 profile adoption example | `examples/native_f32_profiles.zig`, `zig build run-native-f32-profiles`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m14-native-f32-profile-example.md` | Closed for the current bar: a runnable example demonstrates exact/default f32 outputs versus `NativeF32` scalar/vector profiles. |
| S4-M15 examples validation gate | `zig build examples`, `zig build validate`, `build.zig`, `compare/results/s4-m15-examples-validation.md` | Closed for the current bar: all user-facing examples run through a single build step and local validation depends on it. |
| S4-M16 weighted sampling adoption example | `examples/weighted_sampling.zig`, `zig build run-weighted-sampling`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m16-weighted-sampling-example.md` | Closed for the current bar: a runnable example demonstrates one-shot, alias-table, weighted-tree, weighted-choice, and weighted no-replacement workflows. |
| S4-M17 multivariate sampling adoption example | `examples/multivariate_sampling.zig`, `zig build run-multivariate-sampling`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m17-multivariate-sampling-example.md` | Closed for the current bar: a runnable example demonstrates Multinomial and Dirichlet owned/caller-buffer/batch workflows. |
| S4-M18 sequence sampling adoption example | `examples/sequence_sampling.zig`, `zig build run-sequence-sampling`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m18-sequence-sampling-example.md` | Closed for the current bar: a runnable example demonstrates index sampling, item subsets, partial shuffle, reservoir, reusable choice, and streaming iterator workflows. |
| S4-M19 string generation adoption example | `examples/string_generation.zig`, `zig build run-string-generation`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m19-string-generation-example.md` | Closed for the current bar: a runnable example demonstrates predefined/custom ASCII charsets, allocated strings, Unicode scalar generation, and caller-owned UTF-8 buffers. |
| S4-M20 unit geometry adoption example | `examples/unit_geometry.zig`, `zig build run-unit-geometry`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m20-unit-geometry-example.md` | Closed for the current bar: a runnable example demonstrates scalar, fill, reusable diagnostic, and vector-lane unit geometry workflows. |
| S4-M21 distribution diagnostics adoption example | `examples/distribution_diagnostics.zig`, `zig build run-distribution-diagnostics`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m21-distribution-diagnostics-example.md` | Closed for the current bar: a runnable example demonstrates moments, support, derived constructors, z-score conversion, and PERT builder diagnostics. |
| S4-M22 reproducible streams adoption example | `examples/reproducible_streams.zig`, `zig build run-reproducible-streams`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m22-reproducible-streams-example.md` | Closed for the current bar: a runnable example demonstrates seed mixing/substreams, engine aliases, split/jump, and PCG stream selection. |
| S4-M23 range and uniform sampling adoption example | `examples/range_sampling.zig`, `zig build run-range-sampling`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m23-range-sampling-example.md` | Closed for the current bar: a runnable example demonstrates integer/float/duration ranges, endpoint semantics, reusable Uniform, vector ranges, collapsed point masses, and checked errors. |
| S4-M24 discrete distributions adoption example | `examples/discrete_distributions.zig`, `zig build run-discrete-distributions`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m24-discrete-distributions-example.md` | Closed for the current bar: a runnable example demonstrates Bernoulli, Binomial, NegativeBinomial, Poisson, Geometric, Hypergeometric, vector discrete samplers, and checked errors. |
| S4-M25 continuous distributions adoption example | `examples/continuous_distributions.zig`, `zig build run-continuous-distributions`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m25-continuous-distributions-example.md` | Closed for the current bar: a runnable example demonstrates core continuous shape/tail distributions, diagnostics, fills, vector batches, and checked errors. |
| S4-M26 advanced continuous distributions adoption example | `examples/advanced_continuous_distributions.zig`, `zig build run-advanced-continuous-distributions`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m26-advanced-continuous-distributions-example.md` | Closed for the current bar: a runnable example demonstrates remaining advanced continuous shape/tail families, fills, vector batches, and checked errors. |
| S4-M27 rank distributions adoption example | `examples/rank_distributions.zig`, `zig build run-rank-distributions`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m27-rank-distributions-example.md` | Closed for the current bar: a runnable example demonstrates finite Zipf, unbounded Zeta, vector rank samplers, degenerate infinite-exponent behavior, and checked errors. |
| S4-M28 examples catalog | `docs/examples.md`, `zig build examples`, `zig build apicheck`, `compare/results/s4-m28-examples-catalog.md` | Closed for the current bar: all focused runnable examples are discoverable from a central catalog and remain under local validation. |
| S4-M29 next unblocked product gap | `core-rand-coverage.md`, future audits | Not complete; S4-M11 remains blocked and the next independent product improvement has not yet been selected. |
| No proxy signal is accepted as whole-goal completion | `zig build validate-all` plus roadmap/audit files | Validation passes are necessary but not sufficient; blocker audits still show missing performance requirements. |

## Current Non-Completion Evidence

The active goal cannot be marked complete because the roadmap has deliberately
raised the bar beyond S4-M5. `s4-m5-approximation-policy.md` records S4-M5 as
closed for the current local Linux policy bar: named table and approx-log vector
profiles are accepted as the explicit throughput-first dense vector surface for
callers who choose approximation/output-mapping contracts, while exact/default
APIs remain scalar ziggurat lane-fill.

The next unresolved blocked milestone remains S4-M11:

1. Accepted approximation profiles have native glibc, x86_64-linux-musl, and WASI
   long-sweep evidence, but no exact/default-compatible dense SIMD
   normal/exponential kernel has beaten scalar ziggurat lane-fill in the real
   `vectorbench` slice-fill harness.
2. No additional architecture/runtime runner is installed here (`qemu-*`,
   `wine*`, `wasmtime`, and `wasmer` are absent), and no new local `rand` /
   `rand_distr` core gap has been identified.

S4-M12 through S4-M14 are closed as unblocked adoption/documentation
improvements, S4-M15 adds an examples validation gate, S4-M16 adds weighted
sampling adoption guidance, S4-M17 adds multivariate adoption guidance, S4-M18
adds sequence sampling adoption guidance, S4-M19 adds string-generation adoption
guidance, S4-M20 adds unit-geometry adoption guidance, S4-M21 adds distribution
diagnostics adoption guidance, S4-M22 adds reproducible-stream adoption
guidance, S4-M23 adds range/uniform adoption guidance, S4-M24 adds discrete
distribution adoption guidance, S4-M25 adds continuous-distribution adoption
guidance, S4-M26 adds advanced-continuous adoption guidance, S4-M27 adds
rank-distribution adoption guidance, and S4-M28 adds a central examples catalog,
but they do not resolve S4-M11 or complete the long-term objective.

All other recently found S4-M4 side gaps have either been closed or narrowed by
checked-in evidence, including Hypergeometric H2PE coverage, static/dynamic
weighted samplers, f32 standard fills, OpenClosed f64 bulk, Cauchy, SkewNormal,
unit geometry direct rows, and many direct-source/bulk distribution workflows.
LogNormal exact defaults are now documented as a stable-output tradeoff with
multiple opt-in performance profiles (`BufferedLogNormal`, `LogNormalDlsymExp`,
`LogNormalLibmvec`, and f32 approximation/native variants) that cover the local
Rust performance gap without changing the exact default.
The SIMD performance gap has narrowed on the vector opt-in side: table-quantile
normal/exponential and f32 approximate-log exponential vector opt-ins now beat the
matching ziggurat lane-fill rows for users who accept explicit
approximation/output-mapping contracts, and distcheck now includes larger-sample
moment/CDF gates for those approximation profiles. S4-M5 is closed by policy,
S4-M6 is closed by native+WASI `profilecheck` hardening, S4-M7 is closed by
native+WASI `profiletailcheck` tail gates, and S4-M8 is closed by native+WASI
`profilestresscheck` multi-seed gates, and S4-M9 is closed by native+WASI
`profilelongcheck` long stress gates, and S4-M10 is closed by x86_64-linux-musl
`profilelongcheck` execution. S4-M11 remains unresolved because exact/default
normal/exponential kernels remain scalar ziggurat lane-fill, no further executed
architecture/runtime is available, and no new local Rust core gap is known.

## Required Next Work Before Completion

The goal remains active until at least one of these happens:

- a default/exact-compatible dense SIMD normal/exponential candidate beats
  scalar lane-fill in the real vector-slice harness while preserving or
  deliberately versioning rejected-lane stream shape;
- or a later roadmap audit raises/reshapes the bar again with explicit rationale.

Until then, do not call `update_goal(status=complete)`.
