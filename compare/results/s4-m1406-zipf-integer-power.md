# S4-M1406 — Integer-power fast path in the Zipf inverse CDF

## Goal

Replace the generic `std.math.pow` in the Zipf rejection-inversion inverse CDF
with reciprocal products when the stored exponent `q = 1/(1−s)` is a small
negative integer, which covers the common `s = 1.5` (`q = −2`), `s = 2`
(`q = −1`), `s = 4/3` (`q = −3`), and `s = 5/4` (`q = −4`) shapes.

## Implementation

- `Zipf.invCdf` now computes `base = pt·(1−s) + s` and returns `1/base`,
  `1/base²`, `1/base³`, or `1/base⁴` for `q = −1..−4` before falling back to
  `std.math.pow`. The generic path and the `s = 1` exponential branch are
  unchanged.
- The identities are exact; the sampled values match the previous power-based
  form at printed precision, so the benchmark checksums stay `329448.000` /
  `330159.000`.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-host runs with the fast path present:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea zipf` | 48.5M samples/s | 69.2-72.8M samples/s | +43-50% |
| `alea zipf direct` | 51.5M samples/s | 76.0-78.7M samples/s | +48-53% |
| `alea Zipf.fillFrom direct` | 51.0M samples/s | 75.9-77.3M samples/s | +49-52% |

The generic `q` values keep the `std.math.pow` path; the earlier exp/log probe
for the generic Zeta/Zipf powers remains rejected because it was slower there.

## Validation

- All Zipf/Zeta tests pass.
- `zig build test` passes 901/901 (882 library tests plus 19 tool gates),
  including `apicheck` and `roadmapcheck`.
- `zig build distcheck` passes and `zig build statcheck` passes.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners, integer-power fast paths for other inverse-CDF
transforms, or newly discovered core gaps.
