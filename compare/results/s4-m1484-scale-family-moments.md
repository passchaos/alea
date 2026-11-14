# S4-M1484 Scale-Family Extreme-Parameter Moments

Date: 2026-11-14

## Change

The scale-family moment helpers expanded products or subtracted nearly equal
gamma values, so huge scale/shape parameters produced NaN, `-inf`, or a
point-mass value from `inf·0`. This milestone makes them overflow-safe:

- `Weibull` and `Fréchet`: for shape above `1e6` the variance uses the
  asymptotic `Γ(1±2/k) − Γ²(1±1/k) = π²/(6k²) + O(1/k³)` evaluated as
  `(scale/shape)²·π²/6`; the gamma difference cancels in f64 well before that
  shape, and `scale²·(1−1)` previously produced `inf·0 = NaN`.
- `LogLogistic`: factors `scale²` out of the variance bracket
  `2a/sin(2a) − (a/sin a)²` so `inf − inf` cannot occur, and uses
  `(scale·π/shape)²/3` above shape `1e6`.
- `Triangular`: uses the difference form
  `((b−a)² + (c−b)² + (a−c)²)/36`, which avoids the `inf − inf` cancellation
  of the expanded quadratic.
- `PERT`: normalizes `(mode−min)/range` and `(max−mode)/range` before
  multiplying by the shape (so `shape·(mode−min)` cannot overflow), divides
  the normalized alpha fraction before scaling by the range, and evaluates
  the variance as `(range/√(α+β+1))²·p·q` so neither `range²` nor `α·β`
  overflows.
- `Kumaraswamy`: the beta-function moments use the stable log-factorial delta
  `lf(β−1) − lf(β−1+β_arg)` instead of subtracting two huge `lgamma` values,
  and the variance clamps rounding-noise negatives to zero.

No RNG stream changed: these are deterministic moment helpers.

## Before/After

| call | before | after | reference |
| --- | --- | --- | --- |
| `Weibull(1e300, 1e300).varianceValue()` | NaN | 1.644934 | π²/6 |
| `Frechet(0, 1e300, 1e300).varianceValue()` | NaN | 1.644934 | π²/6 |
| `LogLogistic(1e300, 1e300).varianceValue()` | NaN | 3.289868 | π²/3 |
| `Triangular(0, 5e299, 1e300).varianceValue()` | NaN | inf | `1.5e600/36` (overflows f64) |
| `Pert(0, 1e300, 1e300, 1e300).expectedValue()` | NaN | 1e300 | point mass at max |
| `Pert(0, 1e300, 1e300, 1e300).varianceValue()` | NaN | 1 | `range²·αβ/(sum²(sum+1))` |
| `Kumaraswamy(1e300, 1e300).expectedValue()` | 1e300 | 1 | point mass at 1 |
| `Kumaraswamy(1e300, 1e300).varianceValue()` | −inf | 0 | `O((log β)²/α²)` (underflows) |

The existing moderate-parameter tests for `Weibull`, `Frechet`, `Pert`,
`Triangular`, `Kumaraswamy`, and `LogLogistic` pass unchanged, confirming the
scaled forms reproduce the direct formulas.

## Validation

- `zig build test --summary all` passes 921/921 (native `alea-tests` 902/902).
- `zig build statcheck` and `zig build distcheck` pass.
- `zig build roadmapcheck` and the doc checks pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
