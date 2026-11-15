# S4-M1592 Wrapped Cauchy CDF and Quantile

Date: 2026-11-15

## Feature

The wrapped Cauchy distribution had closed-form inverse-CDF sampling but no
CDF/quantile diagnostics. Added:

- `wrappedCauchyCdf(x, mu, rho)` and `wrappedCauchyQuantile(p, mu, rho)`
  polymorphic peer-type helpers (f32/f64),
- `WrappedCauchy(T).cdf` and `WrappedCauchy(T).quantile` methods.

## Convention

The sampler returns angles in `(-π, π]`, so the CDF is the representation
integral

```
F(x) = ∫_{-π}^{x} f(t) dt,   x ∈ [-π, π],
```

with `F(-π) = 0`, `F(π) = 1`, continuous elsewhere (the two endpoints are the
same point on the circle). The relative circular CDF with its cut at
`d = ±π` is

```
F0(d) = 1/2 + atan(((1+ρ)/(1−ρ))·tan(d/2))/π,
```

and the representation CDF is `F0(wrap(x−μ)) − C` plus `1` when the forward
arc crosses the cut, where `C = F0(wrap(−π−μ))`. The quantile inverts the same
form (`target = p + C`, wrapped into `(0, 1]`), so it is an exact inverse of
`cdf`, not just the sampler's rotation-equivalent inverse.

`ρ = 1` is the point mass at `μ` (`cdf(x) = 0` below `μ`, `1` at/above it);
`ρ = 0` is uniform on `(-π, π]` (`F(x) = (x+π)/(2π)`, independent of `μ`).

## Validation

- New test `WrappedCauchy CDF and quantile are exact inverses`:
  - `cdf(-π) = 0`, `cdf(π) = 1`, monotone over a 2001-point grid in `[0,1]`
    for `ρ ∈ {0, 0.3, 0.6, 0.9}`;
  - quantile round-trips at `p ∈ {1e-9, 1e-4, 0.1, 0.5, 0.9, 1−1e-4}` within
    `1e-12`;
  - 40k-sample empirical CDF at `x = 0` matches within `0.01`;
  - `ρ = 1` point mass (`quantile(0.3) = μ`, endpoints `±π`), `ρ = 0`
    uniform closed form, f32 path, and NaN parameter rejection.
- `zig build test distcheck --summary all` passes 965/965 tests (native
  944/944).
- Diagnostics-only change: no sampling stream, benchmark, or existing API
  behavior changed.

## Evidence

The formula was checked against numerical integration of the density and
against the sampler's empirical distribution with `μ = 0.4` (the `C` offset
matters when `μ ≠ 0`): the empirical CDF matches the representation integral,
not the unshifted relative CDF.
