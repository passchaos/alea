# S4-M1540 Static Wishart and Static MatrixT 3D Scale Audit

Date: 2026-11-15

## Audit

The dynamic 3D matrix-variate audit (S4-M1536/S4-M1538) is extended to the
comptime-dimension samplers:

- `StaticWishart(3x3)` with non-diagonal `V` and `nu = 8` at 100,000
  samples.
- `StaticMatrixT(3x2)` with non-diagonal `U`/`V` and `nu = 8` at 100,000
  samples.

StaticWishart means and variances:

| entry | mean empirical | mean reference | variance empirical | variance reference |
| --- | --- | --- | --- | --- |
| W00 | 15.9825 | 16 | 64.0247 | 64 |
| W01 | 2.3804 | 2.4 | 16.7499 | 16.72 |
| W02 | 0.7951 | 0.8 | 24.0188 | 24.08 |
| W11 | 7.9927 | 8 | 15.9749 | 16 |
| W12 | 1.6152 | 1.6 | 12.1926 | 12.32 |
| W22 | 12.0043 | 12 | 35.9535 | 36 |

StaticMatrixT 3x2 second moments (`factor = 8/6`):

| quantity | empirical | reference |
| --- | --- | --- |
| Var(X00) | 8.0214 | 8.0000 |
| Var(X01) | 5.3328 | 5.3333 |
| Var(X10) | 4.0128 | 4.0000 |
| Var(X11) | 2.6525 | 2.6667 |
| Cov(X00, X01) | 2.1579 | 2.1333 |
| Cov(X00, X10) | 2.0440 | 2.0000 |
| Cov(X00, X11) | 0.5692 | 0.5333 |
| Cov(X01, X10) | 0.5461 | 0.5333 |

(`Cov(X00, X11)` uses `U[0][1]·V[0][1] = 0.4`, not `U[0][1]·V[1][1]`; the
initial probe printout used the wrong reference index, and the empirical
value matches the correct `0.5333` reference within Monte Carlo error.)

## Change

Added the unit test
`StaticWishart 3x3 and StaticMatrixT 3x2 recover non-diagonal scales`: nine
StaticWishart means and six variances plus four StaticMatrixT variances and
four cross-covariances at 40,000 samples. No library code changed.

## Validation

- `zig build test -Dtest-filter="StaticWishart 3x3 and StaticMatrixT"
  --summary all` passes 21/21 steps and 2/2 `alea-tests`.
- `zig build test --summary all` passes 945/945 (native `alea-tests`
  926/926).
- `zig build distcheck` passes.

The aggregate `validate-all` refresh is tracked as the following milestone.
