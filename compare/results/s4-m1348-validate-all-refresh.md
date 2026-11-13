# S4-M1348 — Validate-all refresh after the fading and performance batch

## Goal

Refresh the full aggregate validation evidence after S4-M1343 through S4-M1347,
which added Rice and Hoyt diagnostics, made the matrix vMF benchmark
deterministic, completed the SIMD Kent scalar tail, and added the direct 2D vMF
vector sampler.

## Evidence

Command: `zig build validate-all --summary all`

Result:

```
Build Summary: 122/122 steps succeeded; 1783/1783 tests passed
```

Component highlights:

- native `alea-tests`: 878/878,
- WASI Node `alea-tests-wasm32-wasi-node`: 878/878,
- `alea-distcheck`, `alea-distcheck-libc`, and `alea-profilecheck`: success
  (2/2 tool tests each),
- `practrand-self-test`: success,
- crosscheck compile: wasm32-wasi-musl, aarch64-linux, riscv64-linux,
  x86_64-windows, x86_64-macos, and aarch64-macos all success,
- `wasi-dry-run`, `wasi-self-test`, and `wasi-report`: success.

`zig build test` independently passes 897/897 (878 library tests plus 19
doc/tool-gate tests). The native and WASI binaries exercise `riceCdf` /
`riceQuantile`, `hoytCdf` / `hoytQuantile`, the Rice/Hoyt sampler methods, the
reworked SIMD Kent tail, and the direct 2D vMF path used by the matrix vMF
Gibbs conditional.

## Validation

- `zig build validate-all --summary all` passes 122/122 steps and 1783/1783
  tests.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `compare/results/core-rand-coverage.md` S4-M1348 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further Gibbs-sweep optimization, or newly discovered core gaps.
