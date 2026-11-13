# S4-M1378 — Validate-all refresh after the layout-fix batch

## Goal

Refresh the full aggregate validation evidence after S4-M1375 through
S4-M1377, which reverted the vector Kent Wood tail, recorded the benchmark
regression-hunt method, and precomputed the Wood constants for the exact
single-column matrix vMF.

## Evidence

Command: `zig build validate-all --summary all`

Result:

```
Build Summary: 122/122 steps succeeded; 1787/1787 tests passed
```

Component highlights:

- native `alea-tests`: 880/880,
- WASI Node `alea-tests-wasm32-wasi-node`: 880/880,
- `alea-distcheck`, `alea-distcheck-libc`, and `alea-profilecheck`: success
  (2/2 tool tests each),
- `practrand-self-test`: success,
- crosscheck compile: wasm32-wasi-musl, aarch64-linux, riscv64-linux,
  x86_64-windows, x86_64-macos, and aarch64-macos all success,
- `wasi-dry-run`, `wasi-self-test`, and `wasi-report`: success.

`zig build test` independently passes 899/899 (880 library tests plus 19
doc/tool-gate tests). The native and WASI binaries exercise the reverted
vector Kent path, the exact single-column matrix vMF with precomputed Wood
constants, and the 3×2 exact matrix vMF path through the Kent and matrix
tests.

## Multinomial breakdown note

A focused probe measured the single-sample multinomial at about 130 ns: one
HIN binomial with a cached setup plus one HIN binomial with a per-call setup
and rejection loop. A mixed HIN binomial alone is about 80 ns, so the second
conditional's setup and rejection loop remain the dominant cost; further
single-sample multinomial work should target the HIN setup or acceptance
loop, not the category-loop bookkeeping.

## Validation

- `zig build validate-all --summary all` passes 122/122 steps and 1787/1787
  tests.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)` with the batch present.
- `compare/results/core-rand-coverage.md` S4-M1378 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
HIN setup/acceptance-loop work for single-sample multinomial, or newly
discovered core gaps.
