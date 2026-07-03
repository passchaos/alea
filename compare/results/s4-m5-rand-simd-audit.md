# S4-M5 Local Rand SIMD Distribution Audit

Date: 2026-07-04

Purpose: check whether the locally available Rust `rand` / `rand_distr`
evidence contains a comparable SIMD normal/exponential distribution workload for
Alea's S4-M5 dense-kernel milestone.

This is not a completion claim. S4-M5 deliberately raises the bar beyond local
Rust parity: Alea still wants default or explicitly versioned dense SIMD
normal/exponential kernels, or an explicit policy accepting named approximation
profiles for a default/general API surface.

## Inspected Local Rust Artifacts

| Artifact | Finding |
| --- | --- |
| `~/Work/rand/benches/benches/simd.rs` | Benchmarks only `StandardUniform`-style SIMD integer/wide random values such as `u128`, x86 vector integer types, and `core::simd` integer vectors. It has no normal, exponential, or other non-uniform SIMD distribution row. |
| `~/Work/rand/src/distr/float.rs` | `simd_support` implements uniform float, `Open01`, and `OpenClosed01` for `f32x*` / `f64x*` vector types. This is uniform sampling, not non-uniform normal/exponential distribution sampling. |
| `~/Work/rand/src/distr/uniform_float.rs` | `simd_support` implements `Uniform` ranges for SIMD float vector types. This is range-uniform sampling, not non-uniform normal/exponential distribution sampling. |
| `~/.cargo/registry/src/.../rand_distr-0.6.0/src/normal.rs` | `StandardNormal` uses scalar ZIGNOR ziggurat for `f64`; `f32` delegates to the `f64` sampler then casts, with an upstream `TODO` to use an optimal 32-bit implementation. No SIMD implementation is present. |
| `~/.cargo/registry/src/.../rand_distr-0.6.0/src/exponential.rs` | `Exp1` uses scalar ZIGNOR ziggurat for `f64`; `f32` delegates to the `f64` sampler then casts, with an upstream `TODO` to use an optimal 32-bit implementation. No SIMD implementation is present. |
| `grep -R "simd\|portable_simd\|f32x\|f64x\|Simd" rand_distr-0.6.0/src rand_distr-0.6.0/Cargo.toml` | No SIMD non-uniform distribution implementation was found in local `rand_distr`. |

## Consequence For S4-M5

There is currently no locally available Rust SIMD normal/exponential benchmark
or implementation surface that Alea can directly compare against. The existing
Alea vector normal/exponential rows are therefore a product-above-Rust pressure,
not a local Rust parity gap.

This means S4-M5 remains open for Alea's own product bar rather than because a
new local Rust row is missing. The current actionable choices remain:

1. produce a default or explicitly versioned dense SIMD normal/exponential
   candidate that beats scalar ziggurat lane-fill in Alea's real `vectorbench`
   slice harness;
2. or write and accept a policy that a named approximation profile may satisfy a
   specific default/general dense-kernel API surface, backed by reproducibility
   snapshots and statistical gates;
3. or, if a future local Rust checkout gains non-uniform SIMD distribution rows,
   add matching rows to `compare/rand_bench` and update the parity audit.

## Current Alea Evidence To Keep Separate

Alea already exceeds the local Rust SIMD surface for broad Zig-native vector
ergonomics by exposing vector normal/exponential APIs and explicit opt-in table
or approximate-log profiles. However, the default vector normal/exponential APIs
still use scalar ziggurat lane-fill, and the fast table/approx-log profiles have
explicit output-mapping and approximation contracts. They should not be counted
as default/general replacements without a separate S4-M5 policy decision.
