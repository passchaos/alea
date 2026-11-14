# S4-M1403 — Validate-all refresh after S4-M1402

## Goal

Refresh the aggregate validation evidence after S4-M1402, which added packed
bool fills for the 3/8 and 1/16 ratios.

## Evidence

Command: `zig build validate-all --summary all`

Result:

```
Build Summary: 122/122 steps succeeded; 1791/1791 tests passed
```

Component highlights:

- native `alea-tests`: 882/882 (the new dyadic fill probability test is
  included),
- WASI Node `alea-tests-wasm32-wasi-node`: 882/882,
- `alea-distcheck`, `alea-distcheck-libc`, and `alea-profilecheck`: success
  (2/2 tool tests each),
- `practrand-self-test`: success,
- crosscheck compile: wasm32-wasi-musl, aarch64-linux, riscv64-linux,
  x86_64-windows, x86_64-macos, and aarch64-macos all success,
- `wasi-dry-run`, `wasi-self-test`, and `wasi-report`: success.

`zig build test` independently passes 901/901 (882 library tests plus 19
doc/tool-gate tests). The native and WASI binaries exercise the new fraction
fill kernels through the chance tests and `distcheck`.

## Validation

- `zig build validate-all --summary all` passes 122/122 steps and 1791/1791
  tests.
- `zig build test` passes 901/901, including `apicheck` and `roadmapcheck`.
- `zig build distcheck` and `zig build statcheck` pass.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `compare/results/core-rand-coverage.md` S4-M1403 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
packed fills for other dyadic ratios, or newly discovered core gaps.
