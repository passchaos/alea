# S4-M1374 — Validate-all refresh after the copula and directional batch

## Goal

Refresh the full aggregate validation evidence after S4-M1367 through
S4-M1373, which added the table-driven Student-t recurrence, the direct
cos/sin Kent conditional, the comptime single-column vMF path, the vector
Kent Wood tail, the vectorized Student-t copula CDF, the multinomial batch
HIN cache, and the Bingham `@log` acceptance.

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
doc/tool-gate tests). The native and WASI binaries exercise the vectorized
copula CDF, the exact single-column and 3×2 matrix vMF paths, the Kent
cos/sin conditional and Wood tail, the multinomial batch cache, and the
Bingham log acceptance through the copula, directional, matrix, and binomial
tests.

## Rejected probe recorded in `performance-triage.md`

- Vector Kent per-lane cos/sin helper (retried with a `noinline` wrapper):
  vector Kent improved 4.8M → 5.5M vectors/s, but scalar `kent 3d` dropped
  from about 26.9M to 23.7M through code layout with an unchanged checksum;
  reverted to keep the scalar row.

## Validation

- `zig build validate-all --summary all` passes 122/122 steps and 1787/1787
  tests.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)` with the batch present.
- `compare/results/core-rand-coverage.md` S4-M1374 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further vector rejection-loop or copula tuning, or newly discovered core gaps.
