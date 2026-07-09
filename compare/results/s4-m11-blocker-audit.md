# S4-M11 Resolution Audit

Date: 2026-07-09

S4-M11 asked for one of three ways to keep raising the accepted vector profile
bar:

1. land an exact/default-compatible dense SIMD normal/exponential kernel that
   beats scalar ziggurat lane-fill in the real `vectorbench` harness;
2. execute accepted profile validation on another genuine architecture/runtime
   target beyond native glibc, x86_64-linux-musl, and Node WASI;
3. find and close a new local `rand` / `rand_distr` core gap.

## Current Evidence

| Check | Result |
| --- | --- |
| Exact/default-compatible dense SIMD kernel | No default/exact dense SIMD winner is claimed. Prior ziggurat repair, block-fallback, all-accepted, mask-redraw, lane-local, Marsaglia polar, ratio-of-uniforms, inverse-CDF, CLT, libmvec vector-log, and f64 approx-log attempts remain rejected in `simd-distribution-kernel-notes.md` and `performance-triage.md`. Default vector normal/exponential APIs still intentionally use scalar ziggurat lane-fill. |
| Additional architecture/runtime runner | Closed for the current bar by executing accepted profile validation under Wasmtime 31.0.0 (`wasmtime 31.0.0 (7a9be587f 2025-03-20)`) using the locally downloaded upstream `wasmtime-v31.0.0-x86_64-linux` release. `compare/results/s4-m1123-wasmtime-profilelongcheck.md` records direct Wasmtime execution of `alea-wasi-profilecheck.wasm` and `alea-wasi-profilelongcheck.wasm`; the long run ends with `profilelongcheck ok`. This is a genuine non-Node WASI runtime in addition to prior native glibc, x86_64-linux-musl, and Node WASI evidence. Other non-WASI runners (`qemu-aarch64`, `qemu-aarch64-static`, `qemu-riscv64`, `qemu-riscv64-static`, `qemu-x86_64`, `qemu-x86_64-static`, `wine`, `wine64`, and `wasmer`) are still not part of the current executed evidence. |
| Local `rand` / `rand_distr` public-surface and comparison-benchmark gap | No new unblocked local Rust public-surface or comparison-benchmark gap is identified by the current local scan and smoke coverage. `zig build surfacecheck` covers 25 local `rand` files, 6 resolved `rand_core` files, and 34 cached `rand_distr` files. `zig build validate-local` continues to aggregate native validation with local public-surface scan plus `rand-bench-test`, `rand-bench-smoke`, `rand-bench-smoke-self-test`, `rand-status`, `rand-status-json`, `rand-status-schema-version`, and `rand-status-self-test`. |
| Local `rand` SIMD/non-uniform surface | Re-auditing `~/Work/rand` still finds `simd_support` for uniform/integer/wide values and uniform float/range APIs only. Cached `rand_distr 0.6.0` still has scalar ZIGNOR `StandardNormal`/`Exp1` with f32 delegating through f64 and no SIMD non-uniform implementation. |

## Local Status Tokens

The current status and local-comparison signals retained for roadmap guards are:

```text
surfacecheck local rand
zig build validate-local
zig build rand-bench-test
zig build rand-bench-smoke
zig build rand-bench-smoke-self-test
zig build rand-status
zig build rand-status-json
zig build rand-status-self-test
zig build rand-status-schema-version
compare/results/s4-m1141-f64x4-facade-standard-vector-fill.md
`1`
Alea local rand/rand_distr status (2026-07-09)
"schema_version"
"baseline"
"validate_local_passes"
"opportunity_runners_available"
"current_conclusion"
"no_known_unblocked_gap"
"s4_m11_blocked"
"local_rand_status"
"blocker_audit"
"latest_validate_local_evidence"
"compare/results/s4-m1141-f64x4-facade-standard-vector-fill.md"
rand-status self-test ok
rand_distr standard-normal
five passing Rust parser tests
rand_bench_smoke self-test ok
ALEA_RAND_BENCH_MANIFEST
ALEA_RAND_BENCH_EXPECTED_ROW
zig build runtimecheck
No new unblocked public-surface or local comparison-benchmark gap
```

## Decision

S4-M11 is closed for the current bar via the additional-runtime branch. The
accepted vector approximation profiles now have long-sweep evidence across
native glibc, x86_64-linux-musl, Node WASI, and direct Wasmtime execution.

This does not replace exact/default vector normal/exponential APIs: those remain
scalar ziggurat lane-fill until an exact/default-compatible dense SIMD kernel
wins in the real vector-slice harness. It also does not complete the long-term
product objective. The roadmap is raised to S4-M1124 for the next stricter bar:
continue exact/default dense-kernel research, seek additional non-WASI OS or
architecture execution, and keep local `rand` / `rand_distr` audits current.

Do not call `update_goal(status=complete)` from this audit: S4-M11 is resolved
for the current milestone only, while the product goal deliberately keeps
raising the bar.
S4-M1125 post-S4-M11 next product bar remains active after S4-M1124 restores validate-all.
S4-M1126 post-S4-M1125 next product bar remains active after S4-M1125 refreshes rand-status.
S4-M1126 remains active after `compare/results/s4-m1126-f32x8-dense-simd-probe.md` found no checksum-preserving f32x8 dense SIMD winner.
S4-M1128 remains active after S4-M1127 closes `compare/results/s4-m1127-f64x4-standard-normal-direct-fill.md` for direct-source f64x4 standard-normal fills.
S4-M1129 remains active after S4-M1128 closes `compare/results/s4-m1128-f64x4-standard-exponential-direct-fill.md` for direct-source f64x4 standard-exponential fills.
S4-M1130 remains active after S4-M1129 refreshes rand-status in `compare/results/s4-m1129-post-s4-m1128-rand-status-refresh.md`.
S4-M1131 remains active after S4-M1130 refreshes validate-all in `compare/results/s4-m1130-post-s4-m1129-validate-all.md`.
S4-M1132 remains active after S4-M1131 refreshes rand-status in `compare/results/s4-m1131-post-s4-m1130-rand-status-refresh.md`.
S4-M1133 remains active after S4-M1132 refreshes f32x8 direct-source evidence in `compare/results/s4-m1132-f32x8-direct-source-probe.md`.
S4-M1134 remains active after S4-M1133 closes rate-one vector exponential delegation in `compare/results/s4-m1133-vector-exponential-rate-one-delegate.md`.
S4-M1135 remains active after S4-M1134 closes single-vector rate-one exponential delegation in `compare/results/s4-m1134-single-vector-exponential-rate-one-delegate.md`.
S4-M1136 remains active after S4-M1135 closes scalar rate-one exponential fill delegation in `compare/results/s4-m1135-scalar-exponential-rate-one-fill.md`.
S4-M1137 remains active after S4-M1136 closes scalar rate-one exponential sample delegation in `compare/results/s4-m1136-scalar-exponential-rate-one-sample.md`.
S4-M1138 remains active after S4-M1137 closes scalar standard-normal sample delegation in `compare/results/s4-m1137-scalar-normal-standard-sample.md`.
S4-M1139 remains active after S4-M1138 refreshes rand-status in `compare/results/s4-m1138-post-s4-m1137-rand-status-refresh.md`.
S4-M1140 remains active after S4-M1139 fixes roadmapcheck evidence mapping in `compare/results/s4-m1139-roadmapcheck-evidence-map-fix.md`.
S4-M1141 remains active after S4-M1140 refreshes rand-status in `compare/results/s4-m1140-post-s4-m1139-rand-status-refresh.md`.
S4-M1142 remains active after S4-M1141 extends f64x4 facade standard-vector fills in `compare/results/s4-m1141-f64x4-facade-standard-vector-fill.md`.
