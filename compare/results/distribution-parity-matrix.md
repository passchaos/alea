# Distribution Parity-Plus Matrix

This document compares `alea`'s distribution surface with the locally available
Rust references:

- `~/Work/rand`, current default `rand` checkout
- cached historical `rand` crates under `~/.cargo/registry/src`

The goal is not to mirror Rust traits or feature gates. The goal is to ensure
that core distribution functionality is covered or intentionally excluded in a
Zig-native way.

## Current Rust `rand` Default Crate

| Rust `rand` area | Alea status |
| --- | --- |
| `StandardUniform` integers/floats/bools | Covered by `Rng.value`, scalar helpers, `float`, `boolean` |
| `StandardUniform` arrays/tuples | Covered by `Rng.value` arrays and tuples |
| `StandardUniform` char | Covered by explicit `Rng.unicodeScalar` and Unicode UTF-8 helpers, including caller-owned-buffer UTF-8 output |
| `Uniform` integer/float ranges | Covered by `Uniform(T)`, `Open01`, `OpenClosed01`, and range helpers, including endpoint/inclusivity accessors |
| `UniformChar` | Covered by `unicodeScalar`; explicit char-range sampler is not needed because Zig has no native `char` type |
| `UniformDuration` | Covered by `durationRangeLessThan` and `durationRangeAtMost` for `std.Io.Duration` |
| `Bernoulli` | Covered by `Bernoulli`, `chance`, `ratio`, checked variants, and probability/moment accessors |
| `Alphanumeric`, `Alphabetic` | Covered by ASCII charsets and `Charset`, including charset byte diagnostics |
| `Slice::Choose` | Covered by `seq.Choice` and `chooseIter`, including item-slice diagnostics |
| `WeightedIndex` | Covered by `weightedIndex`, `AliasTable`, `WeightedChoice`; checked paths reject non-finite weights and overflowing totals, and `AliasTable.update` / `WeightedChoice.update` support weight replacement |

## Historical Rust `rand` Non-Uniform Distributions

| Rust distribution family | Alea status |
| --- | --- |
| Normal / StandardNormal | Covered: `standardNormal`, `StandardNormal(T)`, `normal`, `Normal(T)`, including coefficient-of-variation construction/accessor, z-score conversion, and standard-parameter accessors |
| LogNormal | Covered: `logNormal`, `LogNormal(T)`, including linear-space mean/coefficient-of-variation construction and accessors, z-score conversion, log-space accessors, and f32/f64 benchmark rows |
| Exponential / Exp1 | Covered: `standardExponential`, `StandardExponential(T)`, `exponential`, `Exponential(T)`, including reusable-sampler and standard rate/moment accessors |
| Gamma | Covered: `gamma`, `Gamma(T)`, including shape/scale/moment accessors |
| ChiSquared | Covered: `chiSquared`, `ChiSquared(T)`, including dof/moment accessors |
| FisherF | Covered: `fisherF`, `FisherF(T)`, including d1/d2 and finite-moment accessors |
| StudentT | Covered: `studentT`, `StudentT(T)`, including dof/finite-moment accessors |
| Gumbel | Covered: `gumbel`, `Gumbel(T)`, including location/scale accessors |
| Frechet | Covered: `frechet`, `Frechet(T)`, including location/scale/shape accessors |
| SkewNormal | Covered: `skewNormal`, `SkewNormal(T)`, including parameter accessors |
| Pert | Covered: `pert`, `Pert(T)`, including default-shape, mean, range-builder constructors, builder diagnostics, and parameter accessors |
| UnitCircle / UnitDisc | Covered: `unitCircle`, `unitDisc`, `UnitCircle(T)`, `UnitDisc(T)`, including geometry accessors |
| UnitSphere / UnitBall | Covered: `unitSphere`, `unitBall`, `UnitSphere(T)`, `UnitBall(T)`, including geometry accessors |
| Poisson | Covered: `poisson`, `Poisson`, large-lambda PTRS path, and lambda/moment accessors |
| Binomial | Covered: `binomial`, `Binomial`, exact small/p=0.5/large rejection paths, explicit sparse Poisson approximation helper, and trials/probability/moment accessors |
| Geometric / StandardGeometric | Covered: one-based `Geometric`, rand-style failure-count `GeometricFailures`, probability/moment accessors, and p=0.5 `StandardGeometric` fast path/accessor |
| Hypergeometric | Covered: `Hypergeometric`, including parameter/moment accessors and HIN inverse-transform fast path for small-mode regimes; large-parameter H2PE-equivalent performance remains tracked in `performance-triage.md` |
| WeightedChoice | Covered: `WeightedChoice`, including item diagnostics, weight updates, single/bulk weight introspection, `chooseIteratorWeighted`, `sampleIteratorWeighted` |
| WeightedAliasIndex | Covered: `AliasTable(Weight)` for O(1) repeated weighted sampling, including `len`, `totalWeight`, `weightAt`, and allocation-returning or caller-buffer weight reconstruction |
| WeightedTreeIndex | Covered: `WeightedTree(Weight)` for generic weights and `WeightedIntTree(Weight)` for faster unsigned integer sample/update/push/pop workloads; both expose single-weight lookup plus `weights` / `weightsInto` export for diagnostics; `WeightedIntTree` stores subtotals in `u64` and rejects wider integer values that do not fit |
| InverseGaussian | Covered: `inverseGaussian`, `InverseGaussian(T)`, including mean/shape accessors |
| NormalInverseGaussian | Covered: `normalInverseGaussian`, `NormalInverseGaussian(T)`, including alpha/beta accessors |
| Zipf | Covered: `zipf`, `Zipf(T)`, including n/exponent accessors |
| Zeta | Covered: `zeta`, `Zeta(T)`, including exponent accessor |

## Additional Alea Core Distributions

These are not in current Rust `rand` default crate, but are useful core random
toolkit functionality and reduce reliance on companion crates:

| Alea distribution | Status |
| --- | --- |
| Beta | Covered: `beta`, `Beta(T)`, including alpha/beta/moment accessors |
| Triangular | Covered: `triangular`, `Triangular(T)`, including min/mode/max/moment accessors |
| Arcsine | Covered: `arcsine`, `Arcsine(T)`, including min/max/moment accessors |
| Cauchy | Covered: `cauchy`, `Cauchy(T)`, including median/scale accessors |
| Laplace | Covered: `laplace`, `Laplace(T)`, including location/scale/moment accessors |
| Logistic | Covered: `logistic`, `Logistic(T)`, including location/scale/moment accessors |
| Rayleigh | Covered: `rayleigh`, `Rayleigh(T)`, including scale/moment accessors |
| HalfNormal | Covered: `halfNormal`, `HalfNormal(T)`, including scale/moment accessors |
| Maxwell | Covered: `maxwell`, `Maxwell(T)`, including scale/moment accessors |
| Chi | Covered: `chi`, `Chi(T)`, including dof accessor |
| Erlang | Covered: `erlang`, `Erlang(T)`, including shape/scale/moment accessors |
| LogLogistic | Covered: `logLogistic`, `LogLogistic(T)`, including scale/shape and finite-moment accessors |
| Kumaraswamy | Covered: `kumaraswamy`, `Kumaraswamy(T)`, including alpha/beta accessors |
| PowerFunction | Covered: `powerFunction`, `PowerFunction(T)`, including min/max/shape/moment accessors |
| Pareto | Covered: `pareto`, `Pareto(T)`, including scale/shape and finite-moment accessors |
| Weibull | Covered: `weibull`, `Weibull(T)`, including scale/shape accessors |
| Dirichlet | Covered: `Dirichlet(T)`, allocation and `sampleInto` APIs, including alpha/mean/variance/covariance lookup and dimension/total-alpha accessors |
| Multinomial | Covered: `Multinomial`, including trials/category/probability lookup and count moment accessors |
| NegativeBinomial | Covered: `NegativeBinomial`, including successes/probability/moment accessors |

## Explicit Out Of Scope

| Rust ecosystem feature | Rationale |
| --- | --- |
| `Distribution<T>` trait mirroring | Zig-native sampler structs and `Rng.sampleIter` provide the reusable-sampler workflow without copying Rust traits |
| serde integration | Rust ecosystem-specific; not core RNG functionality for Zig |
| crate feature matrices | Rust packaging-specific |
| Rust SIMD `std::simd` distribution implementations | Zig vector/SIMD support should be designed as a separate Zig-native milestone if needed |

## Remaining Follow-Up

- Keep `linux-no-known-gaps-audit.md` current when local `rand` / `rand_distr`
  evidence or Alea's public distribution surface changes.
- Continue expanding benchmark parity where new local Rust rows reveal concrete
  performance gaps; current follow-up is tracked in `performance-triage.md`.
- Continue Zig-native vector/SIMD sampling through the constraints in
  `simd-distribution-kernel-notes.md`.
