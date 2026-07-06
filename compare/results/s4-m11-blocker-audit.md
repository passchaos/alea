# S4-M11 Blocker Audit

Date: 2026-07-06

S4-M11 asks for one of three ways to keep raising the accepted vector profile bar:

1. land an exact/default-compatible dense SIMD normal/exponential kernel that
   beats scalar ziggurat lane-fill in the real `vectorbench` harness;
2. execute accepted profile validation on another genuine architecture/runtime
   target beyond native glibc, x86_64-linux-musl, and Node WASI;
3. find and close a new local `rand` / `rand_distr` core gap.

## Current Evidence

| Check | Result |
| --- | --- |
| Exact/default-compatible dense SIMD kernel | No new winning candidate is available. Prior ziggurat repair, block-fallback, all-accepted, mask-redraw, lane-local, Marsaglia polar, ratio-of-uniforms, inverse-CDF, CLT, libmvec vector-log, and f64 approx-log attempts remain rejected in `simd-distribution-kernel-notes.md` and `performance-triage.md`. Default vector normal/exponential APIs still intentionally use scalar ziggurat lane-fill. |
| Additional architecture/runtime runner | Refreshed `command -v` audit found `node`, `cargo`, and `rustc`, but still not `qemu-aarch64`, `qemu-aarch64-static`, `qemu-riscv64`, `qemu-riscv64-static`, `qemu-x86_64`, `qemu-x86_64-static`, `wine`, `wine64`, `wasmtime`, or `wasmer`; `zig build runtimecheck` now automates this availability check and currently reports `runtimecheck summary: required found=3 missing=0; opportunities found=0 missing=10` and `runtimecheck ok: no additional runtime runner available`. Current executed targets remain native glibc Linux, x86_64-linux-musl via Zig's runnable target, and Node WASI. Other targets remain compile-only through `zig build crosscheck`. |
| Local `rand` / `rand_distr` public-surface and comparison-benchmark gap | `zig build surfacecheck` now passes with source-driven coverage summaries for 25 local `rand` files, 6 resolved `rand_core` files, and 34 cached `rand_distr` files; the current output starts with `surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137`. The checker has been hardened through S4-M296..S4-M306 to scan multiline re-exports, impl methods, Bernoulli implementation methods, stricter token boundaries, and unlisted public files. `zig build validate-local` now aggregates native validation with this local public-surface scan plus the Rust comparison benchmark gates `zig build rand-bench-test`, `zig build rand-bench-smoke`, and `zig build rand-bench-smoke-self-test`; the smoke wrapper also keeps `ALEA_RAND_BENCH_MANIFEST` and `ALEA_RAND_BENCH_EXPECTED_ROW` override paths self-tested for custom local comparison checks. S4-M418 refreshed this aggregate after the WASI help-output documentation updates: `compare/results/s4-m418-validate-local-after-wasi-help-docs.md` records `rand_distr standard-normal`, five passing Rust parser tests, `surfacecheck ok`, `rand_bench_smoke self-test ok`, `runtimecheck summary: required found=3 missing=0; opportunities found=0 missing=10`, and `runtimecheck ok: no additional runtime runner available`. No new unblocked public-surface or local comparison-benchmark gap is identified by this current local scan and smoke coverage. |
| Local `rand` SIMD/non-uniform surface | Re-auditing `~/Work/rand` still finds `simd_support` for uniform/integer/wide values and uniform float/range APIs only. Cached `rand_distr 0.6.0` still has scalar ZIGNOR `StandardNormal`/`Exp1` with f32 delegating through f64 and no SIMD non-uniform implementation. |

## Decision

S4-M11 is blocked in this session. The accepted vector approximation profiles now
have substantial deterministic validation across native glibc, musl, and WASI,
but the remaining next-bar options require either new algorithmic insight for
exact/default dense SIMD kernels or additional runtime infrastructure not
available locally.

The long-term objective remains active. Do not call `update_goal(status=complete)`
from this audit: the product goal explicitly keeps raising the roadmap bar, and
S4-M11 is an unresolved blocker rather than a completion state.
