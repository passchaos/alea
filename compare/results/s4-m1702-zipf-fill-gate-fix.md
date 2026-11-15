# S4-M1702 Zipf Fill Gate Expected-Value Fix

Date: 2026-11-16

## Bug

The second 1e9 run failed at `long fillZipf(10,1.5) cdf(2)` with an
empirical rate of `0.678362` against `[0.586985, 0.590985]`. The sampler is
correct; the gate used the wrong expected CDF. The discrete block already
had `zipf_dist = Zipf(f64).init(40, 1.5)` for the sample gate, and the new
fill gate reused `zipf_dist.cdf(...)` instead of the `Zipf(10, 1.5)` CDF.

## Fix

Added `zipf_fill_dist = Zipf(f64).init(10, 1.5)` and used its CDF for the
three `fillZipf(10, 1.5)` gates. The exact `P(X <= 2)` for `(10, 1.5)` is
about `0.678`, matching the measured rate.

## Verification

- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` passes the
  full long gate set and prints `distlongcheck ok (10000000 samples)`.
- `zig build test distcheck statcheck --summary all`: 39/39 steps and 970/970
  tests (native 950/950).

## Changed Files

- `tools/distcheck.zig`: the `zipf_fill_dist` sampler and the three fill gate
  expected values.
