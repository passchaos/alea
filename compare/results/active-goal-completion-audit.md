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
| S4-M5 default/general dense SIMD kernels | `compare/results/s4-m4-remaining-gaps.md`, `compare/results/simd-distribution-kernel-notes.md`, `compare/results/performance-triage.md` | Not complete; the next bar requires default or explicitly versioned dense SIMD normal/exponential kernels, or a documented policy accepting an approximation profile for a default/general API surface. |
| No proxy signal is accepted as whole-goal completion | `zig build validate-all` plus roadmap/audit files | Validation passes are necessary but not sufficient; blocker audits still show missing performance requirements. |

## Current Non-Completion Evidence

The active goal cannot be marked complete because the roadmap has deliberately
raised the bar beyond S4-M4. `s4-m4-remaining-gaps.md` now records S4-M4 as
closed for the local Linux performance-follow-up bar and defines S4-M5 as the
next unresolved milestone:

1. Default/general dense SIMD normal/exponential kernels have not replaced or
   versioned scalar ziggurat lane-fill in the real `vectorbench` slice-fill
   harness, and no policy has accepted the table/approximation opt-ins as a
   default/general substitute.

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
approximation/output-mapping contracts. S4-M5 remains unresolved because default
normal/exponential kernels remain scalar ziggurat lane-fill.

## Required Next Work Before Completion

The goal remains active until at least one of these happens:

- a default or explicitly versioned dense SIMD normal/exponential candidate
  beats scalar lane-fill in the real vector-slice harness while preserving or
  deliberately versioning rejected-lane stream shape;
- or a documented policy accepts a named approximation profile for a
  default/general API surface with statistical-quality and reproducibility
  evidence;
- or a later roadmap audit raises/reshapes the bar again with explicit rationale.

Until then, do not call `update_goal(status=complete)`.
