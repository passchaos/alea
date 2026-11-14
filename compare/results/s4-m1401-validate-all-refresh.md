# S4-M1401 — Validate-all refresh after S4-M1400

## Goal

Refresh the aggregate validation evidence after S4-M1400, which extended the
packed dyadic binomial to p = 3/8 and p = 1/16 and added the Cauchy quantile
gate.

## Evidence

Command: `zig build validate-all --summary all`

Result:

```
Build Summary: 122/122 steps succeeded; 1789/1789 tests passed
```

Component highlights:

- native `alea-tests`: 881/881 (the new dyadic-fraction moment test is
  included),
- WASI Node `alea-tests-wasm32-wasi-node`: 881/881,
- `alea-distcheck`, `alea-distcheck-libc`, and `alea-profilecheck`: success
  (2/2 tool tests each),
- `practrand-self-test`: success,
- crosscheck compile: wasm32-wasi-musl, aarch64-linux, riscv64-linux,
  x86_64-windows, x86_64-macos, and aarch64-macos all success,
- `wasi-dry-run`, `wasi-self-test`, and `wasi-report`: success.

`zig build test` independently passes 900/900 (881 library tests plus 19
doc/tool-gate tests). The native and WASI binaries exercise the new dyadic
fractions through the binomial tests and the Cauchy quantile gate through
`distcheck`.

## Validation

- `zig build validate-all --summary all` passes 122/122 steps and 1789/1789
  tests.
- `zig build test` passes 900/900, including `apicheck` and `roadmapcheck`.
- `zig build distcheck` and `zig build statcheck` pass.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `compare/results/core-rand-coverage.md` S4-M1401 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
packed fills for the 3/8 and 1/16 ratios, or newly discovered core gaps.
