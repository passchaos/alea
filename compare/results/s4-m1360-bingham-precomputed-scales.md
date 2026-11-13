# S4-M1360 — Precomputed Bingham proposal scales

## Goal

Remove the per-draw `sqrt`/division work from the Bingham rejection proposal
and reuse it across scalar, vector, and Matrix Fisher sampling.

## Implementation

- `Bingham(T, n)` now stores `normal_scale[i] = 1 / sqrt(precision[i])` and
  `two_over_nu = 2 / nu`, both computed once in `init`.
- The scalar proposal uses `normal * normal_scale[i]` instead of
  `normal / sqrt(precision[i])`, and evaluates the envelope with
  `log1p(two_over_nu * t)` instead of a per-iteration division.
- The vector Bingham path uses the same precomputed scale and `two_over_nu`
  instead of recomputing them per round.
- `MatrixFisher` (SO(3)) and `MatrixFisherO3` inherit the change through
  their `Bingham(T, 4)` samplers.

## Benchmarks (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-host focused A/B runs at the previous commit and with the change:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea bingham 3d` | 22.0M samples/s | 23.2M samples/s | +5% |
| `alea vector bingham f64x4 3d` | 6.1M vectors/s | 6.3M vectors/s | +2% |
| `alea matrix fisher so3` | 23.8M samples/s | 25.3M samples/s | +6% |
| `alea matrix fisher o3` | 17.8M samples/s | 18.7M samples/s | +5% |

The checksums shift because `normal * (1/sqrt(p))` rounds differently from
`normal / sqrt(p)`; the Bingham checksums change more because a last-bit
proposal change can flip an acceptance decision. They are stable across runs.
The Watson rows keep their checksums unchanged, and their full-suite
difference was confirmed as context noise by a focused A/B.

## Validation

- All 36 Bingham tests pass, including the isotropic mixture-weight,
  orthonormality, and Matrix Fisher O(3) tests.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further directional rejection-kernel tuning, or newly discovered core gaps.
