# S4-M1507 Wishart Bartlett `L·A` Product Fix

Date: 2026-11-15

## Change

Both Wishart samplers build the Bartlett matrix `A` (lower triangular,
`A[i][i] = √χ²(ν−i)`, `A[i][j] ~ N(0,1)` for `j < i`) and compute
`X = L A Aᵀ Lᵀ` with `V = L Lᵀ`. The `L·A` product used a truncated index
range:

```
LA[i][j] = Σ_{k ≤ min(i,j)} L[i][k]·A[k][j]     (wrong)
LA[i][j] = Σ_{j ≤ k ≤ i}   L[i][k]·A[k][j]     (fixed)
```

The truncation dropped every below-diagonal Gaussian term `L[i][k]·A[k][j]`
with `k > j`, so:

- with an identity scale (`L = I`) the product `LA` was strictly diagonal, so
  every Wishart draw was exactly diagonal (`W[i][j] = 0` for `i ≠ j`);
- with a non-diagonal scale the off-diagonal variances collapsed and the
  diagonal means were biased low (for `V = [[2, 0.5], [0.5, 1]]`, `ν = 6`,
  `E[W₁₁] = 5.13` instead of 6).

`StaticWishart` had the same comptime loop condition, and
`StaticInverseWishart`/`InverseWishart` inherit the fix through their inner
Wishart sampler on the precision matrix. The dynamic helper
`wishartBartlettProductFlatScratch` and the static `sampleFrom` now iterate
`k = j..i`.

This is a deliberate versioned stream change for all Wishart and
Inverse-Wishart draws.

## Before/After

100,000 samples, `V = [[2, 0.5], [0.5, 1]]`, `ν = 6`. Reference values:
`E[W] = νV`; `Cov(W_ij, W_kl) = ν(σ_ik σ_jl + σ_il σ_jk)`.

| quantity | before | after | reference |
| --- | --- | --- | --- |
| `E[W₀₀]` | 12.0027 | 12.0027 | 12 |
| `E[W₀₁]` | 3.0007 | 2.9991 | 3 |
| `E[W₁₁]` | 5.1344 | 6.0139 | 6 |
| `Var(W₀₀)` | 47.8266 | 47.8266 | 48 |
| `Var(W₀₁)` | 2.9892 | 13.5384 | 13.5 |
| `Var(W₁₁)` | 7.8899 | 12.1446 | 12 |
| `Cov(W₀₀, W₁₁)` | 2.9785 | 2.9623 | 3 |
| `Cov(W₀₀, W₀₁)` | 11.9567 | 11.9428 | 12 |
| `Cov(W₀₁, W₁₁)` | 0.7446 | 6.0502 | 6 |

Inverse-Wishart with `Ψ = [[2, 0.5], [0.5, 1]]`, `ν = 6` (`E = Ψ/3`):

| quantity | before | after | reference |
| --- | --- | --- | --- |
| `E[X₀₀]` | 0.5187 | 0.6641 | 0.6667 |
| `E[X₀₁]` | 0.1659 | 0.1670 | 0.1667 |
| `E[X₁₁]` | 0.3317 | 0.3317 | 0.3333 |

The static identity-scale check `E[X₀₁²] = ν` measured exactly 0 before the
fix (all off-diagonals zero) and 5.0 after (`ν = 5`, 20,000 samples).

## Regression Gates

New unit tests:

- `Wishart (dynamic) recovers non-diagonal scale covariance` — mean,
  variances, `Cov(W₀₀, W₀₁)`, and `Cov(W₀₁, W₁₁)` at 40,000 samples.
- `StaticWishart recovers non-diagonal scale covariance` — the same moments
  through the comptime path.
- `StaticWishart identity scale df=dim=2 produces ChiSquared marginals` now
  also checks `E[X₀₁²] = df` so a diagonal-only draw fails.

A/B verification: reverting only the two product loops makes all three new
checks fail (identity off-diagonal actual `0`, static `E[W₁₁]` actual
`5.0898`, dynamic `E[W₁₁]` actual `5.1218`), and re-applying the fix passes
all 16 `Wishart`-filtered tests.

New `distcheck` gates in `checkAdvancedMultivariate`:

- `wishart identity off-diagonal` in `[4.5, 5.5]` (reference 5);
- `wishart mean00` / `mean01` / `mean11` in `[11.6, 12.4]` / `[2.85, 3.15]` /
  `[5.7, 6.3]`;
- `wishart off-diagonal variance` in `[11.5, 15.5]` (reference 13.5).

## Multivariate Transform Audit

The same audit that found this bug re-checked the other matrix-variate
transforms with empirical moments:

- `MultivariateNormal` / `StaticMultivariateNormal`, `MultivariateT`,
  `MultivariateLaplace`: empirical covariance matches the accessors.
- `MultivariateSkewNormal`: empirical mean/covariance matches
  `ξ + √(2/π)δ` and `Ψ − (2/π)δδᵀ` (already covered by the Azzalini unit test
  and distcheck gate).
- `MatrixNormal` 2×2 with non-diagonal `U`/`V`: all four variances and six
  covariances match `Cov(X_ij, X_kl) = U_ik V_jl`, including the
  `Cov(X₀₁, X₁₁) = U₀₁V₁₁` cross term.
- `MatrixT`: variance matches `U_rr V_cc ν/(ν−2)` (unit test plus distcheck
  gate).
- `Dirichlet(2, 3, 5)`: means, variances, and all pairwise covariances match
  the closed forms.

Only the Wishart `L·A` truncation was incorrect.

## Validation

- `zig build test -Dtest-filter=Wishart --summary all` passes 16/16
  `alea-tests`.
- `zig build distcheck --summary all` passes with the new gates.
- `zig build test --summary all` passes 932/932 (native `alea-tests`
  913/913), including the two new Wishart regression tests.
- The aggregate `validate-all` refresh is tracked as the following milestone.
