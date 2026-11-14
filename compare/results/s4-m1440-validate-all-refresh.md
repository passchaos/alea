# S4-M1440 — Validate-all refresh after S4-M1439

## Goal

Refresh the aggregate validation evidence after S4-M1439, which added the
engine adapter adoption example and its catalog entries.

## Evidence

Command: `zig build validate-all --summary all`

Result:

```
Build Summary: 124/124 steps succeeded; 1801/1801 tests passed
```

Component highlights:

- native `alea-tests`: 887/887,
- WASI Node `alea-tests-wasm32-wasi-node`: 887/887,
- `alea-distcheck`, `alea-distcheck-libc`, and `alea-profilecheck`: success
  (2/2 tool tests each),
- `practrand-self-test`: success,
- crosscheck compile: wasm32-wasi-musl, aarch64-linux, riscv64-linux,
  x86_64-windows, x86_64-macos, and aarch64-macos all success,
- `wasi-dry-run`, `wasi-self-test`, and `wasi-report`: success,
- the example aggregate now includes `zig build run-engine-adapters`
  (two extra build steps, 124 total).

`zig build test` independently passes 906/906 (887 library tests plus 19
doc/tool-gate tests), including `apicheck`, `toolingcheck`, `examplecheck`,
and `readmecheck`.

## Validation

- `zig build validate-all --summary all` passes 124/124 steps and 1801/1801
  tests.
- `zig build examples --summary all` passes 43/43 steps.
- `zig build test` passes 906/906.
- `zig build distcheck` and `zig build statcheck` pass.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `compare/results/core-rand-coverage.md` S4-M1440 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
vector-directional layout work, or newly discovered core gaps.
