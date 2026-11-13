# S4-M1359 — Validate-all refresh after the transcendental batch

## Goal

Refresh the full aggregate validation evidence after S4-M1355 through S4-M1358,
which split and cached the HIN setup, moved the Zipf acceptance test into log
space, replaced the inverse-power `pow` transforms with exp/log forms, and
switched the large-`n` HIN log-factorial fallback to the Stirling helper.

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
doc/tool-gate tests). The native and WASI binaries exercise the cached
multinomial first conditional, the log-space Zipf acceptance path, the
exp/log Weibull/Frechet/Pareto transforms, and the Stirling HIN fallback
through the binomial, multinomial, Zipf, Weibull, Frechet, and Pareto tests.

## Validation

- `zig build validate-all --summary all` passes 122/122 steps and 1787/1787
  tests.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)` with all four changes present.
- `compare/results/core-rand-coverage.md` S4-M1359 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further directional or matrix sampler optimization, or newly discovered core
gaps.
