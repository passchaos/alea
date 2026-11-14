# S4-M1538 MatrixT and InverseWishart 3D Scale Audit

Date: 2026-11-15

## Audit

The 3x3 Wishart audit (S4-M1536) is now extended to the derived samplers:

- `InverseWishart(3x3)` with non-diagonal `Psi` and `nu = 12`
  (`E[X] = Psi / (nu - dim - 1) = Psi / 8`) at 200,000 samples.
- `MatrixT(3x2)` with non-diagonal `U`/`V` and `nu = 8`
  (`Cov(X_ij, X_kl) = U_ik V_jl nu/(nu-2)`) at 100,000 samples.

InverseWishart means:

| entry | empirical | reference |
| --- | --- | --- |
| X00 | 0.24964 | 0.25000 |
| X01 | 0.03760 | 0.03750 |
| X02 | 0.01249 | 0.01250 |
| X11 | 0.12510 | 0.12500 |
| X12 | 0.02480 | 0.02500 |
| X22 | 0.18759 | 0.18750 |

MatrixT 3x2 second moments (`factor = 8/6`):

| quantity | empirical | reference |
| --- | --- | --- |
| Var(X00) | 8.0623 | 8.0000 |
| Var(X01) | 5.3603 | 5.3333 |
| Var(X10) | 4.0285 | 4.0000 |
| Var(X11) | 2.6817 | 2.6667 |
| Cov(X00, X01) | 2.1363 | 2.1333 |
| Cov(X00, X10) | 2.0404 | 2.0000 |
| Cov(X00, X11) | 0.5570 | 0.5333 |
| Cov(X01, X10) | 0.5742 | 0.5333 |

## Change

Added the unit test `MatrixT 3x2 and InverseWishart 3x3 recover non-diagonal
scales`: 100k-sample InverseWishart mean recovery for all nine entries and
40k-sample MatrixT variance/covariance recovery for four variances and four
cross-covariances. No library code changed.

## Validation

- `zig build test -Dtest-filter="MatrixT 3x2 and InverseWishart" --summary all`
  passes 21/21 steps and 2/2 `alea-tests`.
- `zig build test --summary all` passes 944/944 (native `alea-tests`
  925/925).
- `zig build distcheck` passes.

The aggregate `validate-all` refresh is tracked as the following milestone.
