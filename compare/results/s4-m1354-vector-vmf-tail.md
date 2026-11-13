# S4-M1354 — SIMD von Mises-Fisher scalar tail

## Goal

Bring the SIMD von Mises-Fisher rejection loop in line with the Watson,
Bingham, and Kent kernels by finishing the last pending lanes with the scalar
marginal sampler instead of redrawing full vectors.

## Implementation

- `vectorVmfPointFrom` now counts pending lanes after each vector marginal
  round. When `active_count ≤ 4` it fills the remaining lanes with
  `vmfSampleWWithConstantsFrom` using the already-precomputed Wood constants
  and exits the loop.
- The shared angle and assembly code still handles every lane, so the change
  only affects how the pending lanes consume randomness.
- The scalar vMF sampler and its stream are unchanged.

## Benchmarks (ReleaseFast, `-Dcpu=native`, 16,777,216 samples)

Five same-host runs each:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea vector von mises-fisher f64x4 3d` | 9.9M vectors/s | 10.6M vectors/s | +7% |
| `alea von mises-fisher 3d` | 46.3M samples/s | 46.3M samples/s | unchanged |

The vector checksum changes from `13357188622735645254` to
`695608859174499369` because the tail consumes randomness in a different
order; it is stable across runs. The scalar checksum remains
`8019094426131455251`.

## Validation

- All 22 von Mises-Fisher tests pass, including the vector f64x4/f32x8
  validity and moment tests.
- `zig build test` passes 899/899.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
narrow-vector lane compaction for the remaining SIMD directional kernels, or
newly discovered core gaps.
