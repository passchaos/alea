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
| `Bernoulli` | Covered by `Bernoulli`, `chance`, `ratio`, checked variants, and probability/moment/mode/support accessors |
| `Alphanumeric`, `Alphabetic` | Covered by ASCII charsets and `Charset`, including charset byte/emptiness/membership/probability diagnostics |
| `Slice::Choose` | Covered by `seq.Choice` and `chooseIter`, including item-slice/emptiness diagnostics plus single and bulk uniform-probability exports |
| `WeightedIndex` | Covered by `weightedIndex`, `AliasTable`, `WeightedChoice`; checked paths reject non-finite weights and overflowing totals, and `AliasTable.update` / `WeightedChoice.update` support weight replacement |

## Historical Rust `rand` Non-Uniform Distributions

| Rust distribution family | Alea status |
| --- | --- |
| Normal / StandardNormal | Covered: `standardNormal`, `StandardNormal(T)`, `normal`, `Normal(T)`, including coefficient-of-variation construction/accessor, z-score conversion, and standard-parameter/moment/median/mode/support accessors |
| LogNormal | Covered: `logNormal`, `LogNormal(T)`, including linear-space mean/coefficient-of-variation construction and accessors, median/mode diagnostics, z-score conversion, log-space, moment, and support accessors, and f32/f64 benchmark rows |
| Exponential / Exp1 | Covered: `standardExponential`, `StandardExponential(T)`, `exponential`, `Exponential(T)`, including reusable-sampler and standard rate/moment/median/mode/support accessors |
| Gamma | Covered: `gamma`, `Gamma(T)`, including shape/scale/moment/mode/support accessors |
| ChiSquared | Covered: `chiSquared`, `ChiSquared(T)`, including dof/moment/mode/support accessors |
| FisherF | Covered: `fisherF`, `FisherF(T)`, including d1/d2, finite-moment, and support accessors |
| StudentT | Covered: `studentT`, `StudentT(T)`, including dof/finite-moment and support accessors |
| Gumbel | Covered: `gumbel`, `Gumbel(T)`, including location/scale/moment/median/mode/support accessors |
| Frechet | Covered: `frechet`, `Frechet(T)`, including location/scale/shape, finite-moment, median/mode, and support accessors |
| SkewNormal | Covered: `skewNormal`, `SkewNormal(T)`, including parameter/moment/support accessors |
| Pert | Covered: `pert`, `Pert(T)`, including default-shape, mean, range-builder constructors, builder diagnostics, and parameter/moment accessors |
| UnitCircle / UnitDisc | Covered: `unitCircle`, `unitDisc`, `UnitCircle(T)`, `UnitDisc(T)`, including geometry, coordinate-moment, and radial-moment accessors |
| UnitSphere / UnitBall | Covered: `unitSphere`, `unitBall`, `UnitSphere(T)`, `UnitBall(T)`, including geometry, coordinate-moment, and radial-moment accessors |
| Poisson | Covered: `poisson`, `Poisson`, large-lambda PTRS path, and lambda/moment/support accessors |
| Binomial | Covered: `binomial`, `Binomial`, exact small/p=0.5/large rejection paths, explicit sparse Poisson approximation helper, and trials/probability/moment/support accessors |
| Geometric / StandardGeometric | Covered: one-based `Geometric`, rand-style failure-count `GeometricFailures`, probability/moment/mode/support accessors, and p=0.5 `StandardGeometric` fast path/accessor |
| Hypergeometric | Covered: `Hypergeometric`, including parameter/moment/support accessors and HIN inverse-transform fast path for small-mode regimes; large-parameter H2PE-equivalent performance remains tracked in `performance-triage.md` |
| WeightedChoice | Covered: `WeightedChoice`, including item/emptiness diagnostics, weight/probability diagnostics and exports, weight updates, single/bulk weight introspection, `chooseIteratorWeighted`, `sampleIteratorWeighted` |
| WeightedAliasIndex | Covered: `AliasTable(Weight)` for O(1) repeated weighted sampling, including `len`, `isEmpty`, `totalWeight`, `weightAt`, `probabilityAt`, deterministic `constantIndex`, and allocation-returning or caller-buffer weight/probability reconstruction |
| WeightedTreeIndex | Covered: `WeightedTree(Weight)` for generic weights and `WeightedIntTree(Weight)` for faster unsigned integer sample/update/push/pop workloads; both expose single-weight/probability lookup plus `weights` / `weightsInto` and `probabilities` / `probabilitiesInto` export for diagnostics; `WeightedIntTree` stores subtotals in `u64` and rejects wider integer values that do not fit |
| InverseGaussian | Covered: `inverseGaussian`, `InverseGaussian(T)`, including mean/shape/moment/support accessors |
| NormalInverseGaussian | Covered: `normalInverseGaussian`, `NormalInverseGaussian(T)`, including alpha/beta/gamma and moment/support accessors |
| Zipf | Covered: `zipf`, `Zipf(T)`, including n/exponent and support-bound accessors |
| Zeta | Covered: `zeta`, `Zeta(T)`, including exponent and support-bound accessors |

## Additional Alea Core Distributions

These are not in current Rust `rand` default crate, but are useful core random
toolkit functionality and reduce reliance on companion crates:

| Alea distribution | Status |
| --- | --- |
| Beta | Covered: `beta`, `Beta(T)`, including alpha/beta/moment/mode/support accessors |
| Triangular | Covered: `triangular`, `Triangular(T)`, including min/mode/max/moment/median accessors and collapsed `min == mode == max` point masses |
| Arcsine | Covered: `arcsine`, `Arcsine(T)`, including min/max/moment/median accessors and collapsed `min == max` point masses |
| Cauchy | Covered: `cauchy`, `Cauchy(T)`, including median/mode/scale, undefined-moment, and support accessors |
| Laplace | Covered: `laplace`, `Laplace(T)`, including location/scale/median/mode/moment/support accessors |
| Logistic | Covered: `logistic`, `Logistic(T)`, including location/scale/median/mode/moment/support accessors |
| Rayleigh | Covered: `rayleigh`, `Rayleigh(T)`, including scale/moment/median/mode/support accessors and collapsed `scale == 0` point masses |
| HalfNormal | Covered: `halfNormal`, `HalfNormal(T)`, including scale/moment/support accessors and collapsed `scale == 0` point masses |
| Maxwell | Covered: `maxwell`, `Maxwell(T)`, including scale/moment/mode/support accessors and collapsed `scale == 0` point masses |
| Chi | Covered: `chi`, `Chi(T)`, including dof/moment/mode/support accessors |
| Erlang | Covered: `erlang`, `Erlang(T)`, including shape/scale/moment/mode/support accessors |
| LogLogistic | Covered: `logLogistic`, `LogLogistic(T)`, including scale/shape, finite-moment, median/mode, and support accessors |
| Kumaraswamy | Covered: `kumaraswamy`, `Kumaraswamy(T)`, including alpha/beta/moment/median/mode/support accessors |
| PowerFunction | Covered: `powerFunction`, `PowerFunction(T)`, including min/max/shape/moment/median accessors and collapsed `min == max` point masses |
| Pareto | Covered: `pareto`, `Pareto(T)`, including scale/shape, finite-moment, median/mode, and support accessors |
| Weibull | Covered: `weibull`, `Weibull(T)`, including scale/shape/moment/median/mode/support accessors |
| Dirichlet | Covered: `Dirichlet(T)`, allocation and `sampleInto` APIs, including alpha/mean/variance/covariance export and dimension/total-alpha accessors |
| Multinomial | Covered: `Multinomial`, including trials/category/probability lookup/export and count moment lookup/export accessors |
| NegativeBinomial | Covered: `NegativeBinomial`, including successes/probability/moment/support accessors |

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
