# S4-M1364 — Exp(1) race for the Kent small-a angle

## Goal

Remove the explicit `exp` and uniform acceptance test from the small-`a`
Kent conditional-angle rejection sampler.

## Implementation

- `kentConditionalPhiFrom` for `a < 1.5` now accepts a uniform-angle proposal
  when `E >= a·(1 − cos 2φ)`, where `E` comes from the standard exponential
  kernel. This is the same test as `u <= exp(a(cos 2φ − 1))` but avoids the
  transcendental `exp` and the extra uniform draw.
- The density, period-π replication, and the large-`a` von Mises half-angle
  path are unchanged.
- A vectorized version of the same small-`a` branch for `vectorKentPointFrom`
  was probed; it moved `vector kent f64x4 3d` only from 4.1M to 4.2M
  vectors/s (within noise), so it was reverted.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea kent 3d` | 16.1M samples/s | 19.7M samples/s | +22% |
| `alea vector kent f64x4 3d` | 4.1M vectors/s | 4.1M vectors/s | unchanged |

The scalar checksum changes to `9834663377240030722` (stable across runs);
the vector Kent checksum is unchanged (`14944598552313217847`).

## Validation

- All 10 scalar/vector Kent tests pass.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further Kent or multivariate kernel tuning, or newly discovered core gaps.
