# S4-M1513 Literal and Mixed Arguments in Peer-Type Diagnostics Helpers

Date: 2026-11-15

## Change

The free CDF/quantile diagnostics helpers used `anytype` parameters and
returned `@TypeOf(...)`. Zig's peer type resolution set the return type to
f64 for mixed literal/runtime calls, but the literal parameters themselves
kept their `comptime_float`/`comptime_int` types, so the body failed to
compile at the first generic math call:

```
betaIncomplete(0.5, 2.0, 3.0)     -> error: expected float type, found comptime_float
betaIncomplete(0.5, runtime_a, runtime_b) -> same
studentTCdf(0.5, runtime_nu)      -> error inside normCdf(comptime_float)
poissonCdf(3, runtime_lambda)     -> error inside gammaIncompleteQ(comptime_int)
binomialCdf(3, runtime_n, runtime_p) -> same
```

Every one of these natural calls required `@as(f64, ...)` annotations on the
first argument.

All 88 peer-type helpers now follow a wrapper plus typed implementation
pattern:

```zig
pub fn betaIncomplete(x: anytype, a: anytype, b: anytype) resolvedFloatType(@TypeOf(x, a, b)) {
    return betaIncompleteImpl(resolvedFloatType(@TypeOf(x, a, b)), x, a, b);
}
fn betaIncompleteImpl(comptime PeerType: type, x: PeerType, a: PeerType, b: PeerType) PeerType {
    ...original body...
}
```

`resolvedFloatType` maps `comptime_float`/`comptime_int` to f64 and keeps
runtime f32/f64 and vector types unchanged. The transformed surface covers
`normPdf`, `normCdf`, `probit`, `betaIncomplete`, `studentTCdf`, and the CDF
and quantile pairs for beta, Fisher F, Student t, gamma, chi-squared, Poisson,
binomial, geometric, negative binomial, hypergeometric, Zipf, Zeta, Bernoulli,
exponential, log-normal, half-normal, chi, Erlang, Maxwell, beta-prime,
log-logistic, inverse gamma, Nakagami, ExGaussian, inverse Gaussian,
skew-normal, PERT, Rice, Hoyt, Laplace, logistic, Cauchy, Rayleigh, Weibull,
Gumbel, Frechet, Pareto, power-function, Kumaraswamy, arcsine, and triangular
distributions.

Return types for calls that already compiled are unchanged: a runtime f64
call still returns f64 and an f32 call still returns f32. Fully literal calls
now default to f64. No RNG stream or sampling code changed.

## Before/After

| call | before | after |
| --- | --- | --- |
| `betaIncomplete(0.5, 2.0, 3.0)` | compile error | 0.6875 |
| `betaCdf(0.5, 2, 3)` | compile error | 0.6875 |
| `studentTCdf(0.5, 2)` | compile error | 0.6666666666666666 |
| `poissonCdf(3, 2)` | compile error | 0.857123460498547 |
| `binomialCdf(3, 2, 0.4)` | compile error | 1 |
| `gammaCdf(3, 1, 1)` | compile error | 0.950212931632136 |
| `normCdf(0.5)` | compile error | 0.691462462723994 (A&S erf accuracy) |
| `probit(0.5)` | compile error | 0 |

## Validation

- New unit test `distribution helpers accept literal and mixed argument
  types` covers fully literal, mixed literal/runtime f64, and explicit f32
  calls.
- `zig build test --summary all` passes 935/935 (native `alea-tests`
  916/916).
- `zig build distcheck` passes.
