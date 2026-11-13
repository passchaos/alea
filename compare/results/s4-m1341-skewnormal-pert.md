# S4-M1341 — Skew-normal and PERT CDF/quantile diagnostics

## Goal

Add CDF and quantile diagnostics for the last two advanced continuous
families in the current surface:

- `skewNormalCdf` / `skewNormalQuantile` for
  `F(x) = Φ(z) − 2·T(z, α)`, `z = (x − ξ)/ω`,
- `pertCdf` / `pertQuantile` via the equivalent scaled Beta distribution,
- matching `cdf` / `quantile` methods on `SkewNormal` and `Pert`.

## Implementation

### Owen's T

`owenT(h, a)` integrates `exp(−h²/(2cos²θ))` over `θ ∈ [0, arctan|a|]` with
adaptive Simpson (depth 24, `1e-12` tolerance) and restores the sign of `a`.
`T(h, ±∞) = ±½(1 − Φ(|h|))` uses the closed form, so large finite shapes and
the half-normal limits are handled without a singular integral.

### Skew-normal

`skewNormalCdf` clamps the result to `[0, 1]`, treats `scale = 0` as the point
mass at the location, and handles ±∞. `skewNormalQuantile` bisects on a
`location ± 40·scale` bracket with expansion, so the quantile inherits the
`normCdf`/`probit` approximation accuracy plus the Owen's T integration.

### PERT

`pertCdf`/`pertQuantile` validate the same `(min, mode, max, shape)` domain as
`Pert.init` and map to `Beta(α, β)` with
`α = 1 + shape·(mode − min)/range`, `β = 1 + shape·(max − mode)/range`.
Collapsed ranges are point masses at `min`; infinite shape returns NaN,
matching the sampler's deliberate `rand_distr`-compatible NaN semantics. The
sampler methods use the stored `alpha`/`beta` directly.

## Tests added (1 new, total 895)

`SkewNormal and PERT CDF and quantile helpers` covers the normal limit
(`α = 0`), the exact `SN(0,1,1).cdf(0) = 0.25`, Owen's T reference values
`0.70786098` / `0.02517149` for `z = ±1` and `0.68440837` for `SN(0,1,2)`, the
`F(−x; −α) = 1 − F(x; α)` symmetry, `p = 0.1/0.5/0.9` round-trips,
zero-scale point masses, PERT `Beta(3,3)` exact values (`0.103515625` at
`x = 0.25`), collapsed-range point masses, infinite-shape NaN, invalid
parameters, f32 support, and sampler-method delegation.

## Distcheck and long-run gates

- `checkConstructorErgonomics` adds skew-normal and PERT quantile round-trips.
- The long-run continuous block adds 10,000,000-sample empirical CDF gates for
  `SkewNormal(0,1,1)` at `x = −0.5/0/0.5` and `PERT(0, 0.5, 1, 4)` at
  `x = 0.25/0.5/0.75`. Observed: skew-normal(0) `0.249920` vs `0.250000`,
  pert(0.5) `0.500027` vs `0.500000`.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Validation

- `zig build test` passes 895/895 with all doc gates.
- `zig build distcheck` passes; `zig build wasi-report` ends
  `profilelongcheck ok`.
- `zig fmt --check` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
Rice/Hoyt diagnostics (Marcum Q), or newly discovered core gaps.
