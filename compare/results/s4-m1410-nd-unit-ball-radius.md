# S4-M1410 — Specialized n-dimensional unit ball radius

## Goal

Replace the generic `std.math.pow(u, 1/n)` radius in the n-dimensional unit
ball sampler with repeated square roots for `n = 4` and `n = 8`, and with one
log/exp pair for other dimensions, and add benchmark rows for 4D and 8D balls.

## Implementation

- `unitBallVolumeFrom` for `n >= 4` now draws a uniform direction on S^{n−1}
  and scales it by `sqrt(sqrt(u))` (n = 4), `sqrt(sqrt(sqrt(u)))` (n = 8), or
  `exp(log(u)/n)` otherwise. The 1D/2D/3D paths are unchanged (3D already uses
  the direction-plus-`cbrt` form from S4-M1398).
- New benchmark rows `alea unit ball 4d` and `alea unit ball 8d` measure the
  general-dimension path through `unitBallVolume`.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-period A/B with the change stashed:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea unit ball 4d` | 54.8M samples/s | 121.7-123.3M samples/s | +122-125% |
| `alea unit ball 8d` | 53.1-54.0M samples/s | 131.4-137.0M samples/s | +143-158% |

The radius forms are exact; the printed checksums are unchanged
(`-141.985` / `31.299`).

## Validation

- All unit-geometry tests pass, including the n-dimensional ball norm checks.
- `zig build test` passes 901/901 (882 library tests plus 19 tool gates),
  including `apicheck` and `roadmapcheck`.
- `zig build distcheck` passes and `zig build statcheck` passes.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig bench/throughput.zig` is clean.

## Next bar

Broader platform runners, specialized radii for more dimensions, or newly
discovered core gaps.
