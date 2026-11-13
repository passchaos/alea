# S4-M1353 — Validate-all refresh after the performance batch

## Goal

Refresh the full aggregate validation evidence after S4-M1350 through S4-M1352,
which added the comptime-specialized 3×2 matrix vMF Gibbs kernel, the HIN
log-factorial table, and the exact integer-degree Student-t CDF recurrence.

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
doc/tool-gate tests). The native and WASI binaries exercise the 3×2 matrix
vMF cross-product sweep (including the generic 4×2/4×3 orthonormality test),
the HIN log-factorial binomial path through the multinomial and binomial
tests, and the integer-degree Student-t CDF recurrence through the known-value
and recurrence-vs-incomplete-beta tests.

## Validation

- `zig build validate-all --summary all` passes 122/122 steps and 1787/1787
  tests.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)` with all three changes present.
- `compare/results/core-rand-coverage.md` S4-M1353 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further directional or matrix sampler optimization, or newly discovered core
gaps.
