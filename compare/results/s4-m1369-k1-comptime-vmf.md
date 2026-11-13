# S4-M1369 — Comptime vMF path for single-column matrix vMF

## Goal

Use the comptime-specialized vector von Mises-Fisher sampler for the exact
single-column matrix vMF when the column dimension is 2 or 3, instead of the
runtime-dimension path.

## Implementation

- Added `MatrixVonMisesFisher.sampleExactK1From`, a `noinline` helper that
  dispatches `rows == 2` and `rows == 3` to `vonMisesFisherPointFrom` and
  falls back to `runtimeVonMisesFisherInto` for larger dimensions.
- `sampleIntoFrom` calls the helper for `cols == 1`.
- The `noinline` attribute is required for the 3×2 row: an inlined version of
  the same dispatch grew the hot `sampleIntoFrom` body and dropped the 3×2
  benchmark from about 34.2M to 27.5M samples/s through code layout. Keeping
  the helper out of line restores the 3×2 rate while retaining the 3×1 gain.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-host A/B, five runs each:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea matrix von mises-fisher 3x1` | 30.6M samples/s | 33.6M samples/s | +10% |
| `alea matrix von mises-fisher 3x2` | 34.2M samples/s | 34.2M samples/s | unchanged |

The 3×1 checksum changes to `13936223317007019539`; the 3×2 checksum stays
`5952472309509111602`.

## Validation

- All 7 matrix vMF tests pass.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further directional or matrix kernel tuning, or newly discovered core gaps.
