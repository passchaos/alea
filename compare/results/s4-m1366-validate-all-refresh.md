# S4-M1366 — Validate-all refresh after the directional and exact-sampling batch

## Goal

Refresh the full aggregate validation evidence after S4-M1360 through
S4-M1365, which precomputed Bingham proposal scales, added the exact 3×2 and
single-column matrix vMF paths, moved directional tangent assembly to direct
circle draws, added the Kent small-`a` exponential race, and switched HIN
binomial exponentials to the ziggurat kernel.

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
doc/tool-gate tests). The native and WASI binaries exercise the exact matrix
vMF 3×2/3×1 paths, the direct circle tangent assembly for Watson and vMF, the
Kent small-`a` race, and the HIN ziggurat exponentials through the
directional, matrix, and binomial tests.

## Rejected probes recorded in `performance-triage.md`

- Vector Kent Wood-proposal exponential race: `vector kent f64x4 3d` moved
  only from 4.1M to 4.2M vectors/s, reverted.
- Student-t CDF shared reciprocal square root: student-t copula stayed inside
  run-to-run noise, reverted.

## Validation

- `zig build validate-all --summary all` passes 122/122 steps and 1787/1787
  tests.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)` with the batch present.
- `compare/results/core-rand-coverage.md` S4-M1366 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further directional or multivariate kernel tuning, or newly discovered core
gaps.
