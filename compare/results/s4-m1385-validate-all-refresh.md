# S4-M1385 — Validate-all refresh after S4-M1384

## Goal

Refresh the aggregate validation evidence after S4-M1384, which added the
pointer-receiver Bingham body for the O(3) matrix Fisher sampler and switched
the HIN setup path to pointers.

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
doc/tool-gate tests). The native and WASI binaries exercise the pointer-based
Bingham body through the Bingham, matrix Fisher, and matrix vMF tests, and the
pointer-based HIN setup through the binomial and multinomial tests.

## Validation

- `zig build validate-all --summary all` passes 122/122 steps and 1787/1787
  tests.
- `zig build test` passes 899/899, including `apicheck` and `roadmapcheck`.
- `zig build distcheck` and `zig build statcheck` pass.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `compare/results/core-rand-coverage.md` S4-M1385 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
`Rng` facade-overhead reduction for the facade binomial/multinomial rows, or
newly discovered core gaps.
