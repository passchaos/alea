# S4-M1332 — Long-run directional coverage and two von Mises fixes

## Goal

Add long-run gates for the directional kernels changed by the S4-M1331 Exp(1)
race and refresh the 10,000,000-sample evidence:

- scalar Watson bipolar and girdle mean cosine-squared,
- SIMD Watson mean cosine-squared,
- SIMD Bingham axial moment,
- SIMD Kent mean resultant.

## Bugs found by the new gates

### 1. Tiny-κ von Mises stall

`vonMisesFrom` computed the Best–Fisher constant

`rho = (τ − √(2τ))/(2κ)`, `τ = 1 + √(1 + 4κ²)`

which cancels to exactly zero once `4κ²` falls below the f64 epsilon around 1
(κ ≈ 1e-8). Then `r = (1 + ρ²)/(2ρ)` becomes infinite, `f`, `c`, and both
acceptance tests become NaN, and the rejection loop never accepts. A direct
probe of `vonMises(rng, f64, 0, 1e-8)` hung indefinitely, and the vector Kent
sampler hung when its conditional angle concentration `β(1 − w²)` became tiny.

Fix: use the algebraically identical, cancellation-free form

`rho = 2κτ / ((disc + 1)(τ + √(2τ)))`, `disc = √(1 + 4κ²)`,

and fall back to a uniform angle when `r` is still not finite/positive (only
possible for subnormal κ, where the density is uniform to within floating-point
resolution). The SIMD kernel applies the same fallback per lane via an invalid
mask, so mixed batches with some tiny/zero κ lanes terminate.

### 2. Matrix vMF Gibbs conditional on S¹

`runtimeVonMisesFisherInto` used the Wood cosine proposal for every dimension
≥ 2. That proposal is exact for S^{n−1} with n ≥ 3 but biased for n = 2: at
κ = 5 the runtime sampler produced `E[cos θ] = 0.882` instead of the circular
von Mises value `I₁(5)/I₀(5) = 0.893`.

The matrix Langevin Gibbs sampler uses this dispatcher with `d = rows − cols +
1 = 2` for the common 3×2 case, so its conditional draws were biased. A
1,000,000-sample probe of `MatrixVonMisesFisher(3, 2)` with
`F = κ e₃e₁ᵀ` gave a first-column mean of `0.7783` instead of the exact vMF
marginal `coth(5) − 1/5 = 0.80009`, independently of burn-in (100 to 100,000).

Fix: route `dim == 2` in `runtimeVonMisesFisherInto` to the circular von Mises
sampler (`vonMisesFrom` + angle wrap). The same probe now returns
`0.80030-0.80035` for every burn-in. The matrix vMF marginal test tolerance was
tightened from `0.03` to `0.01`, and a direct `runtimeVonMisesFisherInto`
dimension-2 regression test was added.

## Tests added (2 new, total 888)

1. `VonMises tiny kappa stays finite instead of stalling` — κ = 1e-8, 1e-12,
   1e-100 scalar samples are finite, in `(−π, π]`, and uniform-like, plus a
   mixed SIMD lane vector `{1e-8, 2, 0, 5}`.
2. `runtimeVonMisesFisherInto dim2 matches the circular von Mises` — unit
   vectors with mean `I₁(5)/I₀(5)` within `±0.01`; the old Wood path (0.882)
   fails this bound.

## Long-run validation

`zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
`distlongcheck ok (10000000 samples)` in about 9 seconds. The refreshed tail
and copula rates match the S4-M1321 evidence:

- normal `P(|X|>3) = 0.002714` (expected 0.002700),
- exponential `P(X>3) = 0.049740` (expected 0.049787),
- Student-t(5) `P(|T|>3) = 0.030199` (expected 0.030099),
- Gaussian copula 1% joint lower tail `0.001869`, Student-t copula `0.003957`.

The new gates (scalar Watson bipolar/girdle, SIMD Watson/Bingham/Kent) pass at
the `±0.003` tolerance for both 1,000,000 and 10,000,000 samples.

## Validation

- `zig build test` passes 888/888 with all doc gates.
- `zig build distcheck` passes.
- `zig build wasi-report` passes, ending `profilelongcheck ok`.
- `zig fmt --check` is clean for the modified sources.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further long-run goodness-of-fit checks, or newly discovered core gaps against
local Rust `rand` / `rand_distr` evidence.
