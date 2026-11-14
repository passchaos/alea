# S4-M1536 3x3 Wishart Covariance Audit

Date: 2026-11-15

## Audit

The S4-M1507 Bartlett product fix was regression-tested at 2x2 only, although
the loop change is dimension-general. A 100,000-sample probe checked a 3x3
non-diagonal scale with `nu = 8`:

```
V = [[2, 0.3, 0.1],
     [0.3, 1, 0.2],
     [0.1, 0.2, 1.5]]
```

Empirical means matched `nu·V` and variances matched
`Var(W_ij) = nu·(sigma_ij² + sigma_ii·sigma_jj)`:

| entry | mean empirical | mean reference | variance empirical | variance reference |
| --- | --- | --- | --- | --- |
| W00 | 16.0382 | 16 | 64.1842 | 64 |
| W01 | 2.3949 | 2.4 | 16.7853 | 16.72 |
| W02 | 0.7931 | 0.8 | 24.1442 | 24.08 |
| W11 | 8.0005 | 8 | 16.0053 | 16 |
| W12 | 1.5897 | 1.6 | 12.2713 | 12.32 |
| W22 | 12.0030 | 12 | 36.1222 | 36 |

A 3x2 matrix-normal probe with non-diagonal `U` and `V` also matched
`Cov(X_ij, X_kl) = U_ik·V_jl`:

| covariance | empirical | reference |
| --- | --- | --- |
| (00, 01) | 1.6211 | 1.6 |
| (00, 10) | 1.5048 | 1.5 |
| (00, 11) | 0.3933 | 0.4 |
| (01, 10) | 0.3984 | 0.4 |

## Change

Added the unit test `Wishart recovers non-diagonal 3x3 scale covariance`,
which checks all nine means and six variances at 40,000 samples. This locks
the dimension-general Bartlett product at `dim = 3` in addition to the
existing 2x2 regression, without changing library code.

## Validation

- `zig build test -Dtest-filter="3x3 scale covariance" --summary all`
  passes 21/21 steps and 2/2 `alea-tests`.
- `zig build test --summary all` passes 943/943 (native `alea-tests`
  924/924).
- `zig build distcheck` passes.

The aggregate `validate-all` refresh is tracked as the following milestone.
