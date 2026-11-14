# S4-M1408 — Zeta rejection-inversion fast paths

## Goal

Replace the two `std.math.pow` calls in the Zeta rejection-inversion loop with
closed forms for the common integer and half-integer `s − 1` values, and share
one sampling loop across the sample/fill entry points.

## Implementation

- `Zeta` now stores `neg_inv_exponent_minus_one = −1/(s−1)` at init instead of
  recomputing it per draw.
- A shared `inline fn nextSampleFrom` replaces the four duplicated rejection
  loops; `sample`, `sampleFrom`, `fill`, and `fillFrom` delegate to it.
- `invCdf(u) = u^{−1/(s−1)}` uses closed forms for `s−1 = 2` (`1/√u`), `1`
  (`1/u`), `0.5` (`1/u²`), `3` (`1/∛u`), and `0.25` (`1/(√u)²`).
- `correction(base) = base^{s−1}` uses `base²`, `base`, `√base`, `base³`, and
  `base·√base` for `s−1 = 2, 1, 0.5, 3, 1.5`.
- Other exponents keep the generic `std.math.pow` path, so the earlier
  exp/log rejection for the generic power stays in force.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea zeta` | 82.8M samples/s | 243.6-250.3M samples/s | +194-202% |
| `alea zeta direct` | 88.7M samples/s | 270.2-272.4M samples/s | +205-207% |
| `alea Zeta.fillFrom direct` | 84.7M samples/s | 237.3-239.9M samples/s | +180-183% |

The closed forms are mathematically exact; rounding differs in the last bits,
so the checksums shift and are stable (`178339.000` / `178497.000`).

## Validation

- All Zeta/Zipf tests pass, including the CDF/quantile consistency and moment
  checks.
- `zig build test` passes 901/901 (882 library tests plus 19 tool gates),
  including `apicheck` and `roadmapcheck`.
- `zig build distcheck` passes and `zig build statcheck` passes.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners, closed-form fast paths for other rejection-inversion
samplers, or newly discovered core gaps.
