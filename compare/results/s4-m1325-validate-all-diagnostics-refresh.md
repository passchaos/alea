# S4-M1325 — Validate-all refresh after diagnostics expansion

## Goal

Refresh the full aggregate validation evidence after the closed-form CDF,
derived-family CDF, and sampler-method milestones (S4-M1322 through S4-M1324),
confirming that the 48 new public diagnostics symbols compile and run on every
supported target.

## Evidence

Command: `zig build validate-all --summary all`

Result:

```
Build Summary: 122/122 steps succeeded; 1749/1749 tests passed
```

Component highlights:

- native `alea-tests`: 862/862,
- WASI Node `alea-tests-wasm32-wasi-node`: 862/862,
- `alea-distcheck`, `alea-distcheck-libc`, and `alea-profilecheck`: success,
- `practrand-self-test`: success,
- crosscheck compile: wasm32-wasi-musl, aarch64-linux, riscv64-linux,
  x86_64-windows, x86_64-macos, and aarch64-macos all success,
- `wasi-dry-run`, `wasi-self-test`, and `wasi-report`: success.

The aggregate includes the native library tests, tool-gate tests, and the WASI
Node test binary. The 48 new symbols from S4-M1322–S4-M1324 are exercised by
the native and WASI test binaries.

## Validation

- `zig build validate-all --summary all` passes 122/122 steps and 1749/1749
  tests.
- `compare/results/core-rand-coverage.md` S4-M1325 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.

## Next bar

O(3) matrix Fisher reflections, further vector compaction/squeeze
optimizations, broader platform runners, or newly discovered core gaps.
