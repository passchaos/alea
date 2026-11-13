# S4-M1362 — Exact single-column matrix vMF sampling

## Goal

Remove the burn-in/thinning chain from single-column matrix Langevin
sampling, where the Gibbs conditional is already the full vector
von Mises-Fisher law.

## Implementation

- `MatrixVonMisesFisher.initWithOptions` now precomputes the normalized
  parameter direction into `g` and its norm into `mean_norm` when `cols == 1`.
- `sampleIntoFrom` dispatches `cols == 1` to `runtimeVonMisesFisherInto`
  directly, so each draw is one exact vector von Mises-Fisher sample instead
  of `burnin + thin` Gibbs sweeps.
- `burnin` and `thin` are ignored for `k = 1` (draws are independent); the
  generic Gibbs path remains for `k ≥ 2` shapes.
- The type documentation now states the exact `k = 1` contract.
- Added a fixed-seed `alea matrix von mises-fisher 3x1` benchmark row.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before (Gibbs, 100/10) | After (exact) | Change |
| --- | --- | --- | --- |
| `alea matrix von mises-fisher 3x1` | 1.1M samples/s | 29.0M samples/s | ~26× |

The 3×2 exact row is unchanged at about 32M samples/s. The new checksum
`12221980465663435514` is stable across runs; the old Gibbs path produced
`12731677796421029898`.

## Statistical checks

- The `k = 1` test compares the sample mean against the vector vMF mean
  resultant and passes.
- All 7 matrix vMF tests pass, including the 3×2 exact path, orthonormality,
  clone, f32, and generic 4×2/4×3 shapes.
- `distcheck` matrix vMF gates pass on native and WASI.

## Validation

- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig bench/throughput.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
exact reductions for other Stiefel shapes, or newly discovered core gaps.
