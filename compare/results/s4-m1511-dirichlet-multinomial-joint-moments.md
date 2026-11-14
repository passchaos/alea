# S4-M1511 Dirichlet and Multinomial Joint Moment Tests

Date: 2026-11-15

## Change

The Dirichlet sampler previously had no unit test of its sampling moments
(only marginal CDF/quantile checks), and the Multinomial sampler was covered
only by distcheck marginal means. Two new unit tests gate the full joint
structure:

- `Dirichlet sampling matches marginal means and covariances` samples
  `Dirichlet(2, 3, 5)` 40,000 times and checks `E[X_i]`, `Var(X_i)`, and all
  three pairwise covariances against
  `Var(X_i) = α_i(α₀−α_i)/(α₀²(α₀+1))` and
  `Cov(X_i, X_j) = −α_iα_j/(α₀²(α₀+1))`.
- `Multinomial sampling matches joint means and covariances` samples
  `Multinomial(20, {0.2, 0.3, 0.5})` 40,000 times and checks `E[X_i]`,
  `Var(X_i)`, and all three pairwise covariances against
  `Var(X_i) = n p_i(1−p_i)` and `Cov(X_i, X_j) = −n p_i p_j`.

Both samplers use sequential conditional binomial/gamma draws, so marginal
checks alone would not catch a broken joint coupling. A standalone probe at
the test seeds measured:

| quantity | empirical | reference |
| --- | --- | --- |
| Dirichlet `E[X₀]` | 0.199060 | 0.2 |
| Dirichlet `Var(X₀)` | 0.014301 | 0.014545 |
| Dirichlet `Cov(X₀, X₁)` | -0.005316 | -0.005455 |
| Dirichlet `Cov(X₁, X₂)` | -0.013897 | -0.013636 |
| Multinomial `E[X₂]` | 10.002975 | 10 |
| Multinomial `Var(X₂)` | 5.056016 | 5 |
| Multinomial `Cov(X₀, X₂)` | -2.020459 | -2 |
| Multinomial `Cov(X₁, X₂)` | -3.035557 | -3 |

Tolerances are set at roughly 4–6 standard errors of the fixed-seed sample
statistics, so a wrong coupling (for example zero or positive covariance)
fails while the correct sampler passes.

## Validation

- `zig build test -Dtest-filter=Dirichlet --summary all` passes 4/4
  `alea-tests`.
- `zig build test -Dtest-filter=Multinomial --summary all` passes 3/3
  `alea-tests`.
- `zig build test --summary all` passes 934/934 (native `alea-tests`
  915/915).

No sampling code or RNG stream changed in this milestone.
