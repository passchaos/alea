# S4-M1373 — Faster log in the scalar Bingham acceptance

## Goal

Replace the branchy `std.math.log1p` in the scalar Bingham acceptance with
the libm `@log(1 + x)` form already used by the vector path.

## Implementation

- `Bingham(T, n).sampleFrom` now computes
  `log_ratio = -t + (n/2)·@log(1 + two_over_nu·t)` instead of
  `(n/2)·std.math.log1p(two_over_nu·t)`.
- For small `x = two_over_nu·t`, `log(1 + x)` loses relative precision but the
  absolute log-acceptance error stays around `1e-16`, far below the envelope
  margin and irrelevant for an additive comparison.
- The vector Bingham path already used the `@log` form; only the scalar path
  changed.

## Benchmarks (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-host A/B, three to five runs each:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea bingham 3d` | 24.5M samples/s | 26.7M samples/s | +9% |
| `alea matrix fisher so3` | 27.0M samples/s | 30.2M samples/s | +12% |
| `alea matrix fisher o3` | 19.0M samples/s | 22.5M samples/s | +18% |

All checksums are unchanged (`3229607846008164661`, `7170305455237416037`,
`250858534088675283`), so the acceptance decisions did not flip for these
parameter sets.

## Validation

- All 36 Bingham tests pass.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further Bingham acceptance tuning, or newly discovered core gaps.
