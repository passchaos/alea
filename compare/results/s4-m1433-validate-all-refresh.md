# S4-M1433 — Validate-all refresh after S4-M1432

## Goal

Refresh the aggregate validation evidence after S4-M1432, which added the
dyadic fill and multinomial marginal gates to `distcheck`.

## Evidence

Command: `zig build validate-all --summary all`

Result:

```
Build Summary: 122/122 steps succeeded; 1795/1795 tests passed
```

Component highlights:

- native `alea-tests`: 884/884,
- WASI Node `alea-tests-wasm32-wasi-node`: 884/884,
- `alea-distcheck`, `alea-distcheck-libc`, and `alea-profilecheck`: success
  (2/2 tool tests each), now including the dyadic fill and multinomial
  marginal gates,
- `practrand-self-test`: success,
- crosscheck compile: wasm32-wasi-musl, aarch64-linux, riscv64-linux,
  x86_64-windows, x86_64-macos, and aarch64-macos all success,
- `wasi-dry-run`, `wasi-self-test`, and `wasi-report`: success.

`zig build test` independently passes 903/903 (884 library tests plus 19
doc/tool-gate tests).

## Validation

- `zig build validate-all --summary all` passes 122/122 steps and 1795/1795
  tests.
- `zig build test` passes 903/903, including `apicheck` and `roadmapcheck`.
- `zig build distcheck` and `zig build statcheck` pass.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)` with the new gates active.
- `compare/results/core-rand-coverage.md` S4-M1433 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
longer external statistical sweeps when PractRand is available, or newly
discovered core gaps.
