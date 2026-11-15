# S4-M1673 Zeta Fast-Path Exponent Gates

Date: 2026-11-16

## Change

The S4-M1670 fix corrected the `Zeta.invCdf` fast path for exponent `1.25`.
The remaining `Zeta.invCdf`/`correction` fast paths (`exponent - 1` equal to
`0.5`, `1`, `1.5`, `2`, and `3`, i.e. exponents `1.5`, `2`, `2.5`, `3`, and
`4`) had no direct statistical gates in `distcheck`. Added `Zeta(1.5)`,
`Zeta(2)`, and `Zeta(4)` samples to the discrete CDF block with thresholds
`1/3/8`, `1/4/8`, and `1/3/8`; the existing `Zeta(1.25)` and `Zeta(2.5)` gates
remain. Tooling-only; no library code changed.

## Audit

Scratch probe with `FastPrng` seed `0x1234`, 400,000 samples per exponent,
comparing the empirical CDF at `1`, `2`, `3`, and `4` with the exact
`Zeta.cdf`:

| Exponent | max abs error |
| --- | --- |
| 1.25 | 0.00032 |
| 1.50 | 0.00041 |
| 1.75 | 0.00092 |
| 2.00 | 0.00100 |
| 2.50 | 0.00086 |
| 3.00 | 0.00088 |
| 4.00 | 0.00054 |
| 5.00 | 0.00006 |

All fast paths agree with the exact generalized-harmonic/`riemannZeta` CDF
within sampling error.

## Validation

- `zig build distcheck --summary all`: 5/5 steps and 2/2 tests with the new
  gates.
- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native 950/950).

## Changed Files

- `tools/distcheck.zig`: `Zeta(1.5)`, `Zeta(2)`, and `Zeta(4)` empirical CDF
  gates.
