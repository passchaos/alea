# S4-M1523 Incomplete-Beta Continued-Fraction Iteration Cap

Date: 2026-11-15

## Change

`betaContinuedFraction` capped the continued fraction at 300 iterations. For
large `a + b` the fraction converges slowly near the mean `x = a/(a+b)`, so
the cap silently truncated the result:

| a = b | a + b | I_{1/2}(a, a) at 300 iterations | error |
| --- | --- | --- | --- |
| 1,000,000 | 2e6 | 0.499999620346 | -3.8e-7 |
| 2,000,000 | 4e6 | 0.499971134074 | -2.9e-5 |
| 3,000,000 | 6e6 | 0.499803450169 | -2.0e-4 |
| 4,000,000 | 8e6 | 0.499383080811 | -6.2e-4 |
| 4,950,000 | 9.9e6 | 0.498696962098 | -1.3e-3 |

The exact value is 1/2 by symmetry. Raising the cap to 1000 iterations lets
the fraction converge in every case below the `a + b ≥ 1e7` normal-
approximation switch:

| a + b | 300 iterations | 1000 iterations |
| --- | --- | --- |
| 2e6 | -3.8e-7 | +4.7e-10 |
| 4e6 | -2.9e-5 | -3.2e-9 |
| 6e6 | -2.0e-4 | -7.5e-9 |
| 8e6 | -6.2e-4 | +6.4e-9 |
| 9.9e6 | -1.3e-3 | +4.7e-9 |

Away from the mean the fraction already converged within 300 iterations, and
the asymmetric large-`b` case (`a = 2`, `b = 9,999,999`, checked against the
closed-form `I_x(2, b)`) stays at ~4e-8. The fallback above `1e7` is
unchanged and exact at the mean.

This improves `betaCdf`, `betaQuantile`, `studentTCdf`, `fisherFCdf`, and the
beta-based binomial/negative-binomial CDFs for large shapes. It is a
deterministic diagnostics accuracy change; no RNG stream is affected.

## Validation

- New unit test `betaIncomplete large symmetric shapes resolve the mean`
  checks `a = b = 4e6` (`a + b = 8e6`), `a = b = 4,999,999.5`
  (`a + b = 9,999,999`), and the fallback at `a = b = 5,000,000.5`
  (`a + b = 1e7 + 1`) against 0.5 at 1e-7/1e-9.
- `zig build test --summary all` passes 939/939 (native `alea-tests`
  918/918).
- `zig build distcheck` passes.

The aggregate `validate-all` refresh is tracked as the following milestone.
