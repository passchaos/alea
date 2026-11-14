# S4-M1501 Chi and Noncentral-Chi Huge-Parameter Moments

Date: 2026-11-15

## Change

`Chi.expectedValue` and `noncentralChiExpectedValue` subtracted two huge
`lgamma` values (`Γ((k+1)/2)/Γ(k/2)`), which cancels for large degrees of
freedom, and the noncentral mean also multiplied `exp(-λ/2)·₁F₁` (underflow ×
overflow) at huge noncentrality.

- New `gammaShiftHalfRatio(z)` evaluates `Γ(z+1/2)/Γ(z)` with the
  `√z·(1 − 1/(8z) + 1/(128z²))` asymptotic above `z = 1e7` and the
  `lgamma` difference below it; both `Chi` and `NoncentralChi` use it.
- `noncentralChiExpectedValue` returns `√(k+λ)` when `k+λ > 1e12` (the
  distribution concentrates at `√(k+λ)`; the `O(1/(k+λ)^{3/2})` correction is
  far below f64 resolution).
- `NoncentralChi.varianceValue` returns the delta-method limit
  `(k + 2λ)/(2(k+λ))` above `1e12` instead of subtracting two cancelling
  `1e300`-scale values; `Chi.varianceValue` returns `0.5` above `1e12`.

## Before/After

| call | before | after | reference |
| --- | --- | --- | --- |
| `Chi(1e300).expectedValue()` | 1.0 | 1e150 | `√dof` |
| `Chi(1e300).varianceValue()` | 1e300 | 0.5 | `dof − mean² → 1/2` |
| `NoncentralChi(1e300, 0).expectedValue()` | 1.414214 | 1e150 | `√k` |
| `NoncentralChi(1e300, 1e300).expectedValue()` | 0.0 | 1.414214e150 | `√(k+λ)` |
| `NoncentralChi(1e300, 1e300).varianceValue()` | 2e300 | 0.75 | `(k+2λ)/(2(k+λ))` |

Moderate values are unchanged: `Chi(1e8).expectedValue() = 1e4` and the
existing `Chi`/`NoncentralChi` tests pass.

## Validation

- `zig build test --summary all` passes 929/929 (native `alea-tests` 910/910).
- `zig build statcheck` and `zig build distcheck` pass.
- `zig build roadmapcheck` and the doc checks pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
