# S4-M1381 — Noinline scalar tail for the vector Kent Wood proposal

## Goal

Reinstate the vector Kent Wood scalar tail that was reverted in S4-M1375 for
a skew-normal layout regression, this time as an out-of-line helper so the
scalar and skew-normal code layout stays intact.

## Implementation

- Added `noinline fn vectorKentWoodTailFrom`, which completes the remaining
  pending lanes with the scalar Wood proposal (including the
  `proposal_lambda == 0` uniform-sphere case).
- `vectorWoodW` counts pending lanes after each vector round; when at most
  four remain it calls the helper and exits the loop.
- Keeping the helper out of line is what avoids the S4-M1370 regression:
  the inlined version shifted the hot skew-normal loop layout by about 13%.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea vector kent f64x4 3d` | 4.1M vectors/s | 4.6M vectors/s | +12% |
| `alea kent 3d` | 27.2M samples/s | 27.2M samples/s | unchanged |
| `alea skew-normal` | 575-585M samples/s | 573-589M samples/s | within noise |

The vector checksum changes to `7297499978426234569` (same tail algorithm as
S4-M1370) and is stable; the scalar Kent and skew-normal checksums are
unchanged (`9761654497349534419` / `74340.801`).

## Validation

- All 10 scalar/vector Kent tests pass.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further vector rejection-loop tuning, or newly discovered core gaps.
