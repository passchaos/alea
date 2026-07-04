# S4-M11 Blocker Audit

Date: 2026-07-04

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
| Additional architecture/runtime runner | `command -v` found `node`, `cargo`, and `rustc`, but not `qemu-aarch64`, `qemu-riscv64`, `qemu-x86_64`, `wine`, `wine64`, `wasmtime`, or `wasmer`. Current executed targets are native glibc Linux, x86_64-linux-musl via Zig's runnable target, and Node WASI. Other targets remain compile-only through `zig build crosscheck`. |
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
