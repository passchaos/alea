# S4-M1797 Halley Dominance Guard for the Quantile Loops

Date: 2026-11-20

## Gap

Every Halley step accepted any candidate inside the bracket when the
denominator `2 f'^2 − f f''` was positive and finite. In a far tail both the
density and its derivative vanish, and the quadratic term dominates: the raw
Halley correction degenerates to `2 f'/f''` — a tiny step that ignores the
residual. The skew-normal quantile at `alpha = 6` stalled there: for
`p = 0.019` it returned `z = -0.382` (CDF `4.5e-4`) instead of `z = -0.115`,
a round-trip error of `1.85e-2`; `alpha = 10` was off by `1.06e-1`. A
1000-point round-trip audit of the committed code reproduced both, and the
same audit at extreme shapes also flagged `beta(0.1,0.1)` and `gamma(0.05,1)`
(the latter is a separate pre-existing CDF-resolution limit, not a Halley
stall).

## Change

All Halley sites (skew-normal, wrapped skew-normal, beta integer/half,
gamma, von Mises, wrapped normal, ex-Gaussian) now require the slope term to
dominate the curvature term:

```zig
const quadratic = f_err * pdf_deriv;
const denom = 2 * d * d - quadratic;
if (denom > 0 and isFinite(denom) and 2 * d * d >= @abs(quadratic)) { ... }
```

The skew-normal loop also uses Newton as its base step (previously
bisection) and clamps an out-of-bracket Newton step to bisection, so a
rejected Halley step still makes fast progress. The other loops already had
the Newton base.

## Measurements

Same-host A/B (`ReleaseFast -Dcpu=native`, `-- 16777216`), old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `skew-normal quantile` | 1.567, 1.572, 1.575 | 1.434, 1.437, 1.443 |
| `beta (2.5,0.5) quantile` | 9.536 | 9.474 |
| `gamma quantile` | 6.673 | 6.694 |
| `von mises quantile` | 3.496 | 3.532 |
| `wrapped normal quantile` | 4.275, 4.280 | 4.270, 4.274 |
| `ex-gaussian quantile` | 3.047 | 2.888 |

The skew-normal quantile pays about 8% for the guard (the S4-M1798 table
recovers and exceeds it); the other rows are neutral. Correctness wins the
trade.

## Correctness audit

1000-point round-trips per shape, after the change:

| Shape | Worst \|CDF(q) − p\| |
| --- | --- |
| skew-normal `alpha = 0.5, 2, 6, 10, -2` | `7.13e-13` (was `1.85e-2` / `1.06e-1` at 6/10) |
| beta `(0.5,0.5)`, `(50,0.5)`, `(2,100)` | `6.44e-15` .. `6.30e-13` |
| gamma `(100,1)`, `(1e4,1)` | `2.97e-13` |
| von Mises `0.01`, `1e4` | `1.44e-13` |
| wrapped normal `0.05`, `5` | `4.99e-10` |
| wrapped skew-normal `6`, `20` | `8.05e-11` |
| chi-squared `1` | `1.78e-15` |

`beta(0.1,0.1)` (`1.99e-2`) and `gamma(0.05,1)` (`7.63e-3`) keep their
pre-existing errors; both reproduce identically on the pre-Halley commit
`205fa9c9` and are CDF-resolution limits at extreme shapes rather than
iteration stalls.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Reuse the fixed-shape Owen T Gauss-Legendre geometry across the skew-normal
quantile's iterations.
