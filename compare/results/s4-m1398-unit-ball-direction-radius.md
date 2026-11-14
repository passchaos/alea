# S4-M1398 — Direction-plus-radius unit ball sampling

## Goal

Replace the cube-rejection unit ball sampler, which draws about 5.7 uniforms
per point (acceptance π/6), with the exact direction-plus-radius decomposition:
a uniform sphere direction scaled by `r = U^{1/3}`.

## Implementation

- `unitBallF64PointFrom` and the f32 `unitBallFrom` now draw a uniform
  direction with `unitSphereFrom` and a radius with `std.math.cbrt` of one
  open uniform. The ball measure factorises as surface measure × `r² dr`, so
  the direction is uniform on S² and `r = U^{1/3}` is independent of it; the
  sampled law is unchanged.
- `fillUnitBallF64From` now loops the point sampler instead of filling three
  candidate arrays and rejecting, so the fill emits exactly the same points as
  repeated `unitBallFrom` calls (the previous batch path had a different
  stream shape).
- The cube rejection remains for the disc, circle, and sphere fills, which
  already draw fewer candidates.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea unit ball` | 77.9M samples/s | 172.9-180.0M samples/s | +122-131% |
| `alea unit ball fast direct` | 78.4M samples/s | 177.5-180.1M samples/s | +127% |
| `alea unit ball scalar direct` | 90.3M samples/s | 189.3-193.8M samples/s | +110-115% |
| `alea fillUnitBall` | 86.5-88.9M samples/s | 149.9-164.6M samples/s | +69-90% |
| `alea fillUnitBall fast direct` | 86.5-88.3M samples/s | 155.6-161.5M samples/s | +78% |
| `alea fillUnitBall scalar direct` | 89.2-91.4M samples/s | 168.0-178.6M samples/s | +88-96% |

The sampled law is unchanged but the consumed stream differs, so the
checksums shift and are stable: `unit ball` `-353.640` (facade) / `-41.927`
(scalar direct), and the fill rows now share those checksums because the fill
uses the same point sampler.

## Validation

- All 14 unit-geometry tests pass, including the ball norm and distribution
  checks.
- `zig build test` passes 899/899, including `apicheck` and `roadmapcheck`.
- `zig build distcheck` passes and `zig build statcheck` passes.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners, similar direct decompositions for other unit
geometry samplers, or newly discovered core gaps.
