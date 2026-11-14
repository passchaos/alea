# S4-M1438 — Validate-all refresh after S4-M1437

## Goal

Refresh the aggregate validation evidence after S4-M1437, which added the
`ReaderRng` byte-stream adapter.

## Evidence

Command: `zig build validate-all --summary all`

Result:

```
Build Summary: 122/122 steps succeeded; 1801/1801 tests passed
```

Component highlights:

- native `alea-tests`: 887/887 (including the new `ReaderRng` replay test),
- WASI Node `alea-tests-wasm32-wasi-node`: 887/887,
- `alea-distcheck`, `alea-distcheck-libc`, and `alea-profilecheck`: success
  (2/2 tool tests each),
- `practrand-self-test`: success,
- crosscheck compile: wasm32-wasi-musl, aarch64-linux, riscv64-linux,
  x86_64-windows, x86_64-macos, and aarch64-macos all success,
- `wasi-dry-run`, `wasi-self-test`, and `wasi-report`: success.

`zig build test` independently passes 906/906 (887 library tests plus 19
doc/tool-gate tests).

## Validation

- `zig build validate-all --summary all` passes 122/122 steps and 1801/1801
  tests.
- `zig build test` passes 906/906, including `apicheck` and `roadmapcheck`.
- `zig build distcheck` and `zig build statcheck` pass.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `compare/results/core-rand-coverage.md` S4-M1438 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
vector-directional layout work, or newly discovered core gaps.
