# S4-M1363 — Direct circle draws for directional assembly

## Goal

Replace the uniform-angle `cos`/`sin` pair used to build the tangent
direction in Watson and von Mises-Fisher sampling with the direct unit-circle
sampler, which avoids two transcendentals per sample.

## Implementation

- `watsonPointFrom` (n = 3) and `vonMisesFisherFromW` (n = 3) now draw the
  tangent direction with `unitCircleFrom` instead of
  `angle = 2π·u; (cos angle, sin angle)`.
- `vectorVmfPointFrom` and `vectorWatsonPointFrom` use per-lane
  `unitCircleFrom` draws instead of the vector angle plus vector `@cos`/`@sin`.
- The sampled laws are unchanged: both constructions produce a uniform
  direction on the tangent circle. Only the RNG consumption order and the
  last-bit rounding differ.
- The unused `pi` constant was removed from the vector vMF assembly.

## Benchmarks (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-host A/B runs at the previous commit and with the change:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea watson 3d` | 20.0M samples/s | 30.8M samples/s | +54% |
| `alea von mises-fisher 3d` | 44.8M samples/s | 58.9M samples/s | +32% |
| `alea vector von mises-fisher f64x4 3d` | 10.6M vectors/s | 11.4M vectors/s | +7% |
| `alea vector watson f64x4 3d` | 7.2M vectors/s | 7.9M vectors/s | +9% |

The checksums change because the circle sampler consumes a different number
of raw draws than the angle-based path; they are stable across runs.

## Validation

- All 22 von Mises-Fisher and 14 Watson tests pass, including the scalar and
  vector moment/validity gates.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further directional assembly tuning, or newly discovered core gaps.
