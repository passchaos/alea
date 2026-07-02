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
| `Uniform` integer/float ranges | Covered by `Uniform(T)`, `Open01`, `OpenClosed01`, and range helpers, including endpoint/inclusivity and range/strict-interval moment accessors |
| `UniformChar` | Covered by `unicodeScalar`; explicit char-range sampler is not needed because Zig has no native `char` type |
| `UniformDuration` | Covered by `durationRangeLessThan` and `durationRangeAtMost` for `std.Io.Duration` |
| `Bernoulli` | Covered by `Bernoulli`, `chance`, `ratio`, checked variants, and probability/moment accessors |
| `Alphanumeric`, `Alphabetic` | Covered by ASCII charsets and `Charset`, including charset byte/membership/probability diagnostics |
| `Slice::Choose` | Covered by `seq.Choice` and `chooseIter`, including item-slice diagnostics plus single and bulk uniform-probability exports |
| `WeightedIndex` | Covered by `weightedIndex`, `AliasTable`, `WeightedChoice`; checked paths reject non-finite weights and overflowing totals, and `AliasTable.update` / `WeightedChoice.update` support weight replacement |

## Historical Rust `rand` Non-Uniform Distributions

| Rust distribution family | Alea status |
| --- | --- |
| Normal / StandardNormal | Covered: `standardNormal`, `StandardNormal(T)`, `normal`, `Normal(T)`, including coefficient-of-variation construction/accessor, z-score conversion, and standard-parameter/moment/support accessors |
| LogNormal | Covered: `logNormal`, `LogNormal(T)`, including linear-space mean/coefficient-of-variation construction and accessors, z-score conversion, log-space, moment, and support accessors, and f32/f64 benchmark rows |
| Exponential / Exp1 | Covered: `standardExponential`, `StandardExponential(T)`, `exponential`, `Exponential(T)`, including reusable-sampler and standard rate/moment/support accessors |
| Gamma | Covered: `gamma`, `Gamma(T)`, including shape/scale/moment/support accessors |
| ChiSquared | Covered: `chiSquared`, `ChiSquared(T)`, including dof/moment/support accessors |
| FisherF | Covered: `fisherF`, `FisherF(T)`, including d1/d2, finite-moment, and support accessors |
| StudentT | Covered: `studentT`, `StudentT(T)`, including dof/finite-moment and support accessors |
| Gumbel | Covered: `gumbel`, `Gumbel(T)`, including location/scale/moment accessors |
| Frechet | Covered: `frechet`, `Frechet(T)`, including location/scale/shape and finite-moment accessors |
| SkewNormal | Covered: `skewNormal`, `SkewNormal(T)`, including parameter/moment accessors |
| Pert | Covered: `pert`, `Pert(T)`, including default-shape, mean, range-builder constructors, builder diagnostics, and parameter/moment accessors |
| UnitCircle / UnitDisc | Covered: `unitCircle`, `unitDisc`, `UnitCircle(T)`, `UnitDisc(T)`, including geometry, coordinate-moment, and radial-moment accessors |
| UnitSphere / UnitBall | Covered: `unitSphere`, `unitBall`, `UnitSphere(T)`, `UnitBall(T)`, including geometry, coordinate-moment, and radial-moment accessors |
| Poisson | Covered: `poisson`, `Poisson`, large-lambda PTRS path, and lambda/moment accessors |
| Binomial | Covered: `binomial`, `Binomial`, exact small/p=0.5/large rejection paths, explicit sparse Poisson approximation helper, and trials/probability/moment accessors |
| Geometric / StandardGeometric | Covered: one-based `Geometric`, rand-style failure-count `GeometricFailures`, probability/moment/support accessors, and p=0.5 `StandardGeometric` fast path/accessor |
| Hypergeometric | Covered: `Hypergeometric`, including parameter/moment accessors and HIN inverse-transform fast path for small-mode regimes; large-parameter H2PE-equivalent performance remains tracked in `performance-triage.md` |
| WeightedChoice | Covered: `WeightedChoice`, including item diagnostics, weight/probability diagnostics and exports, weight updates, single/bulk weight introspection, `chooseIteratorWeighted`, `sampleIteratorWeighted` |
| WeightedAliasIndex | Covered: `AliasTable(Weight)` for O(1) repeated weighted sampling, including `len`, `totalWeight`, `weightAt`, `probabilityAt`, and allocation-returning or caller-buffer weight/probability reconstruction |
| WeightedTreeIndex | Covered: `WeightedTree(Weight)` for generic weights and `WeightedIntTree(Weight)` for faster unsigned integer sample/update/push/pop workloads; both expose single-weight/probability lookup plus `weights` / `weightsInto` and `probabilities` / `probabilitiesInto` export for diagnostics; `WeightedIntTree` stores subtotals in `u64` and rejects wider integer values that do not fit |
| InverseGaussian | Covered: `inverseGaussian`, `InverseGaussian(T)`, including mean/shape/moment accessors |
| NormalInverseGaussian | Covered: `normalInverseGaussian`, `NormalInverseGaussian(T)`, including alpha/beta/gamma and moment accessors |
| Zipf | Covered: `zipf`, `Zipf(T)`, including n/exponent and support-bound accessors |
| Zeta | Covered: `zeta`, `Zeta(T)`, including exponent and support-bound accessors |

## Additional Alea Core Distributions

These are not in current Rust `rand` default crate, but are useful core random
toolkit functionality and reduce reliance on companion crates:

| Alea distribution | Status |
| --- | --- |
| Beta | Covered: `beta`, `Beta(T)`, including alpha/beta/moment/support accessors |
| Triangular | Covered: `triangular`, `Triangular(T)`, including min/mode/max/moment accessors |
| Arcsine | Covered: `arcsine`, `Arcsine(T)`, including min/max/moment accessors |
| Cauchy | Covered: `cauchy`, `Cauchy(T)`, including median/scale and undefined-moment accessors |
| Laplace | Covered: `laplace`, `Laplace(T)`, including location/scale/moment accessors |
| Logistic | Covered: `logistic`, `Logistic(T)`, including location/scale/moment accessors |
| Rayleigh | Covered: `rayleigh`, `Rayleigh(T)`, including scale/moment/support accessors |
| HalfNormal | Covered: `halfNormal`, `HalfNormal(T)`, including scale/moment/support accessors |
| Maxwell | Covered: `maxwell`, `Maxwell(T)`, including scale/moment/support accessors |
| Chi | Covered: `chi`, `Chi(T)`, including dof/moment/support accessors |
| Erlang | Covered: `erlang`, `Erlang(T)`, including shape/scale/moment/support accessors |
| LogLogistic | Covered: `logLogistic`, `LogLogistic(T)`, including scale/shape and finite-moment accessors |
| Kumaraswamy | Covered: `kumaraswamy`, `Kumaraswamy(T)`, including alpha/beta/moment accessors |
| PowerFunction | Covered: `powerFunction`, `PowerFunction(T)`, including min/max/shape/moment accessors |
| Pareto | Covered: `pareto`, `Pareto(T)`, including scale/shape and finite-moment accessors |
| Weibull | Covered: `weibull`, `Weibull(T)`, including scale/shape/moment accessors |
| Dirichlet | Covered: `Dirichlet(T)`, allocation and `sampleInto` APIs, including alpha/mean/variance/covariance export and dimension/total-alpha accessors |
| Multinomial | Covered: `Multinomial`, including trials/category/probability lookup/export and count moment lookup/export accessors |
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
