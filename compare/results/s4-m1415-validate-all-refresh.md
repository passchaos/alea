# S4-M1415 — Validate-all refresh after S4-M1414

## Goal

Refresh the aggregate validation evidence after S4-M1414, which replaced the
shifted two-log factorial fallback in the binomial HIN acceptance loop with a
direct one-log Stirling form.

## Evidence

Command: `zig build validate-all --summary all`

Result:

```
Build Summary: 122/122 steps succeeded; 1793/1793 tests passed
```

Component highlights:

- native `alea-tests`: 883/883,
- WASI Node `alea-tests-wasm32-wasi-node`: 883/883,
- `alea-distcheck`, `alea-distcheck-libc`, and `alea-profilecheck`: success
  (2/2 tool tests each),
- `practrand-self-test`: success,
- crosscheck compile: wasm32-wasi-musl, aarch64-linux, riscv64-linux,
  x86_64-windows, x86_64-macos, and aarch64-macos all success,
- `wasi-dry-run`, `wasi-self-test`, and `wasi-report`: success.

`zig build test` independently passes 902/902 (883 library tests plus 19
doc/tool-gate tests). The native and WASI binaries exercise the one-log
factorial through the binomial tests and `distcheck`.

## Validation

- `zig build validate-all --summary all` passes 122/122 steps and 1793/1793
  tests.
- `zig build test` passes 902/902, including `apicheck` and `roadmapcheck`.
- `zig build distcheck` and `zig build statcheck` pass.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `compare/results/core-rand-coverage.md` S4-M1415 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
BTPE-style central binomial rejection, or newly discovered core gaps.
