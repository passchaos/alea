# S4-M1336 — Validate-all refresh after the diagnostics and directional batch

## Goal

Refresh the full aggregate validation evidence after S4-M1326 through S4-M1335,
which added the O(3) matrix Fisher example/long-run coverage, hypergeometric and
Zipf/Zeta diagnostics, the Exp(1) directional rejection race, the von Mises and
matrix-vMF fixes, and the discrete/continuous empirical-CDF gates.

## Evidence

Command: `zig build validate-all --summary all`

Result:

```
Build Summary: 122/122 steps succeeded; 1769/1769 tests passed
```

Component highlights:

- native `alea-tests`: 871/871,
- WASI Node `alea-tests-wasm32-wasi-node`: 871/871,
- `alea-distcheck` and `alea-distcheck-libc`: success (2/2 tool tests each),
- `alea-profilecheck`: success (2/2 tool tests),
- `practrand-self-test`: success,
- crosscheck compile: wasm32-wasi-musl, aarch64-linux, riscv64-linux,
  x86_64-windows, x86_64-macos, and aarch64-macos all success,
- `wasi-dry-run`, `wasi-self-test`, and `wasi-report`: success.

`zig build test` independently passes 890/890 (871 library tests plus 19
doc/tool-gate tests). The native and WASI binaries exercise every symbol added
since the previous refresh, including `hypergeometricCdf`/`hypergeometricQuantile`,
`zipfCdf`/`zipfQuantile`, `zetaCdf`/`zetaQuantile`, the scalar/vector sampler
`cdf`/`quantile` methods, and the long-run empirical-CDF gates.

## Validation

- `zig build validate-all --summary all` passes 122/122 steps and 1769/1769
  tests.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `compare/results/core-rand-coverage.md` S4-M1336 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further performance work, or newly discovered core gaps.
