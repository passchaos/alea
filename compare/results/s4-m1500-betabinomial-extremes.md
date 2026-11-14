# S4-M1500 Beta-Binomial Huge-Shape and Huge-Trial Diagnostics

Date: 2026-11-14

## Change

`betaBinomialPmf`/`betaBinomialCdf` subtracted huge `lgamma` values directly,
so `BetaBinomial(10, 1e300, 1e300)` returned `cdf(5) = 638.0`, `pmf(5) = 1.0`
and `quantile(0.5) = 0`. The CDF also summed one PMF term per integer up to
`k`, so a trial count of `1e18` stalled the quantile bisection.

The helpers now:

- evaluate the beta-function ratios through the stable log-factorial delta
  `lf(b) − lf(b+d)`, so huge shapes stay accurate:
  `pmf(k) = logChoose(n,k) − Δ(α−1,k) − Δ(β−1,n−k) + Δ(α+β−1,n)` and the
  CDF seed uses `−Δ(β−1,n) + Δ(α+β−1,n)`;
- switch to an `O(1)` limit above `1_000_000` trials:
  `P(X/n ≤ x) → I_x(α, β)` when `α+β ≤ n` (the scaled-beta limit, which keeps
  uniform/U-shaped shapes correct), and `binomialCdf(k, n, α/(α+β))` when
  `n < α+β` (which carries its own Poisson/normal/exact splits).

## Before/After

| call | before | after | reference |
| --- | --- | --- | --- |
| `BetaBinomial(10, 1e300, 1e300).cdf(5)` | 638.0 | 0.623047 | `638/1024` (Binomial(10, 0.5)) |
| `BetaBinomial(10, 1e300, 1e300).cdf(4)` | 386.0 | 0.376953 | `386/1024` |
| `BetaBinomial(10, 1e300, 1e300).pmf(5)` | 1.0 | 0.246094 | `252/1024` |
| `BetaBinomial(10, 1e300, 1e300).quantile(0.5)` | 0 | 5 | 5 |
| `BetaBinomial(1e18, 1, 1).cdf(2.5e17)` | stall | 0.25 | uniform limit |
| `BetaBinomial(1e18, 1, 1).cdf(5e17)` | stall | 0.5 | uniform limit |
| `BetaBinomial(1e18, 1, 1).quantile(0.5)` | stall | 5e17 | uniform median |
| `BetaBinomial(1e12, 1e6, 1e6).cdf(5e11)` | stall | ≈0.5 | binomial limit |
| `BetaBinomial(1e18, 1, 1e30).cdf(0)` | stall | ≈1 | Poisson(1e-12) |

The moderate-parameter tests (`α = β = 1` uniform values, `α = β = 1e6`
binomial limit, PMF sum, quantile round trips) pass unchanged.

## Validation

- `zig build test --summary all` passes 928/928 (native `alea-tests` 909/909).
- `zig build statcheck` and `zig build distcheck` pass.
- `zig build roadmapcheck` and the doc checks pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
