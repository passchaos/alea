# S4-M420 Current Local Rand Comparison Status

Date: 2026-07-06

## Summary

Against the locally available Rust evidence on this Linux host:

- local `~/Work/rand` is the `rand` baseline;
- cached `rand_distr 0.6.0` is the distribution baseline;
- `zig build validate-local` currently passes;
- `zig build surfacecheck` currently passes for local `rand`, resolved
  `rand_core`, and cached `rand_distr` manifests;
- the local Rust comparison benchmark parser tests and tiny filtered smoke run
  currently pass;
- `zig build runtimecheck` currently finds required `node`, `cargo`, and `rustc`
  but no opportunity runners (`qemu-*`, Wine, wasmtime, wasmer);
- no new unblocked local Rust public-surface or comparison-benchmark gap is known.

## Latest Evidence

S4-M437 refreshed `zig build validate-local` after adding `rand-status-self-test`
to the local aggregate. The passing run included:

```text
rand_distr standard-normal: 39.6 M samples/s checksum=-3.640
rand_distr standard-normal f32: 37.2 M samples/s checksum=-3.640
Alea local rand/rand_distr status (2026-07-06)
  "validate_local_passes": true,
  "opportunity_runners_available": false,
  "no_known_unblocked_gap": true,
  "s4_m11_blocked": true,
rand-status self-test ok
test result: ok. 5 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand_bench_smoke self-test ok
runtimecheck summary: required found=3 missing=0; opportunities found=0 missing=10
runtimecheck ok: no additional runtime runner available
```

S4-M419 synchronized validate-local signals into `compare/results/s4-m11-blocker-audit.md`; S4-M428 confirmed `rand-status` output is part of the local aggregate; S4-M433 confirmed stable JSON status output is part of the local aggregate; S4-M437 additionally confirms the `rand-status` self-test is part of the local aggregate; S4-M442 keeps the JSON boolean status fields visible in this snapshot.

## Current Blocker

The long-term product goal is not complete. S4-M11 remains blocked on one of:

1. an exact/default-compatible dense SIMD normal/exponential kernel that beats
   scalar ziggurat lane-fill in the real harness;
2. a newly available genuine architecture/runtime runner beyond current native
   glibc, x86_64-linux-musl, and Node WASI coverage;
3. a newly found local `rand` / `rand_distr` core gap.

## Result

S4-M420 is a status snapshot only: current local Rust comparison evidence shows
no known unblocked core RNG gap versus locally available `rand` / `rand_distr`,
while S4-M11 continues to block whole-goal completion.
