# S4-M1670 Zeta Quarter-Exponent Inverse-CDF Fix

Date: 2026-11-16

## Bug

`Zeta.invCdf` has fast paths for common integer and half-integer
`exponent_minus_one` values. The `exponent_minus_one == 0.25` branch
(exponent `1.25`) returned

```zig
const root = @sqrt(u);
return 1 / (root * root); // u^-1
```

instead of the required `u^-4`. The rejection-inversion retry loop could not
correct a wrong proposal scale, so `Zeta(1.25)` sampled the wrong
distribution: `P(X <= 1)` measured `0.572` against the exact `0.218`.

## Fix

```zig
const squared = u * u;
return 1 / (squared * squared); // u^-4
```

The generic `pow(u, -1 / 0.25)` path already produced the correct value; the
special case now matches it without the generic power call.

## Evidence

Scratch probe with `FastPrng` seed `0x1234`, 1,000,000 samples, comparing the
empirical CDF with the exact `Zeta.cdf` (generalized-harmonic/`riemannZeta`
form):

| Threshold | Before | After | Exact |
| --- | --- | --- | --- |
| `P(X <= 1)` | 0.572015 | 0.217802 | 0.217623 |
| `P(X <= 2)` | 0.729796 | 0.309595 | 0.309122 |

`tools/distcheck.zig` now samples `Zeta(1.25)` in the discrete CDF block and
gates `cdf(1)`, `cdf(2)`, and `cdf(4)` at the existing `0.002` tolerance.

## Stream Impact

This is a versioned correctness change for `Zeta`/`VectorZeta` with exponent
`1.25` only. Other exponents, including the benchmarked `Zeta(3)`, keep their
streams and checksums.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native 950/950).
- `zig build distcheck --summary all`: 5/5 steps and 2/2 tests with the new
  `zeta(1.25)` gates.

## Changed Files

- `src/distributions.zig`: corrected the `exponent_minus_one == 0.25`
  `Zeta.invCdf` branch.
- `tools/distcheck.zig`: added the `Zeta(1.25)` empirical CDF gates.
- `compare/results/reproducibility-matrix.md`: records the versioned stream
  change.
