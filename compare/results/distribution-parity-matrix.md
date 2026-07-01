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
| `StandardUniform` char | Covered by explicit `Rng.unicodeScalar` and Unicode UTF-8 helpers |
| `Uniform` integer/float ranges | Covered by `Uniform(T)` and range helpers |
| `UniformChar` | Covered by `unicodeScalar`; explicit char-range sampler is not needed because Zig has no native `char` type |
| `UniformDuration` | Covered by `durationRangeLessThan` and `durationRangeAtMost` for `std.Io.Duration` |
| `Bernoulli` | Covered by `Bernoulli`, `chance`, `ratio`, checked variants |
| `Alphanumeric`, `Alphabetic` | Covered by ASCII charsets and `Charset` |
| `Slice::Choose` | Covered by `seq.Choice` and `chooseIter` |
| `WeightedIndex` | Covered by `weightedIndex`, `AliasTable`, `WeightedChoice`; `AliasTable.update` supports weight replacement |

## Historical Rust `rand` Non-Uniform Distributions

| Rust distribution family | Alea status |
| --- | --- |
| Normal / StandardNormal | Covered: `standardNormal`, `StandardNormal(T)`, `normal`, `Normal(T)`, including coefficient-of-variation construction and z-score conversion |
| LogNormal | Covered: `logNormal`, `LogNormal(T)`, including linear-space mean/coefficient-of-variation construction, z-score conversion, and f32/f64 benchmark rows |
| Exponential / Exp1 | Covered: `standardExponential`, `StandardExponential(T)`, `exponential`, `Exponential(T)` |
| Gamma | Covered: `gamma`, `Gamma(T)` |
| ChiSquared | Covered: `chiSquared`, `ChiSquared(T)` |
| FisherF | Covered: `fisherF`, `FisherF(T)` |
| StudentT | Covered: `studentT`, `StudentT(T)` |
| Gumbel | Covered: `gumbel`, `Gumbel(T)` |
| Frechet | Covered: `frechet`, `Frechet(T)` |
| SkewNormal | Covered: `skewNormal`, `SkewNormal(T)`, including parameter accessors |
| Pert | Covered: `pert`, `Pert(T)`, including default-shape, mean, and range-builder constructors |
| UnitCircle / UnitDisc | Covered: `unitCircle`, `unitDisc`, `UnitCircle(T)`, `UnitDisc(T)` |
| UnitSphere / UnitBall | Covered: `unitSphere`, `unitBall`, `UnitSphere(T)`, `UnitBall(T)` |
| Poisson | Covered: `poisson`, `Poisson`, large-lambda PTRS path |
| Binomial | Covered: `binomial`, `Binomial`, exact small/p=0.5/large rejection paths, explicit sparse Poisson approximation helper |
| Geometric / StandardGeometric | Covered: one-based `Geometric`, rand-style failure-count `GeometricFailures`, and p=0.5 `StandardGeometric` fast path |
| Hypergeometric | Covered: `Hypergeometric`, including HIN inverse-transform fast path for small-mode regimes; large-parameter H2PE-equivalent performance remains tracked in `performance-triage.md` |
| WeightedChoice | Covered: `WeightedChoice`, `chooseIteratorWeighted`, `sampleIteratorWeighted` |
| WeightedAliasIndex | Covered: `AliasTable(Weight)` for O(1) repeated weighted sampling |
| WeightedTreeIndex | Covered: `WeightedTree(Weight)` for generic weights and `WeightedIntTree(Weight)` for faster unsigned integer sample/update workloads |
| InverseGaussian | Covered: `inverseGaussian`, `InverseGaussian(T)` |
| NormalInverseGaussian | Covered: `normalInverseGaussian`, `NormalInverseGaussian(T)` |
| Zipf | Covered: `zipf`, `Zipf(T)` |
| Zeta | Covered: `zeta`, `Zeta(T)` |

## Additional Alea Core Distributions

These are not in current Rust `rand` default crate, but are useful core random
toolkit functionality and reduce reliance on companion crates:

| Alea distribution | Status |
| --- | --- |
| Beta | Covered: `beta`, `Beta(T)` |
| Triangular | Covered: `triangular`, `Triangular(T)` |
| Arcsine | Covered: `arcsine`, `Arcsine(T)` |
| Cauchy | Covered: `cauchy`, `Cauchy(T)` |
| Laplace | Covered: `laplace`, `Laplace(T)` |
| Logistic | Covered: `logistic`, `Logistic(T)` |
| Rayleigh | Covered: `rayleigh`, `Rayleigh(T)` |
| HalfNormal | Covered: `halfNormal`, `HalfNormal(T)` |
| Maxwell | Covered: `maxwell`, `Maxwell(T)` |
| Chi | Covered: `chi`, `Chi(T)` |
| Erlang | Covered: `erlang`, `Erlang(T)` |
| LogLogistic | Covered: `logLogistic`, `LogLogistic(T)` |
| Kumaraswamy | Covered: `kumaraswamy`, `Kumaraswamy(T)` |
| PowerFunction | Covered: `powerFunction`, `PowerFunction(T)` |
| Pareto | Covered: `pareto`, `Pareto(T)` |
| Weibull | Covered: `weibull`, `Weibull(T)` |
| Dirichlet | Covered: `Dirichlet(T)`, allocation and `sampleInto` APIs |
| Multinomial | Covered: `Multinomial` |
| NegativeBinomial | Covered: `NegativeBinomial` |

## Explicit Out Of Scope

| Rust ecosystem feature | Rationale |
| --- | --- |
| `Distribution<T>` trait mirroring | Zig-native sampler structs and `Rng.sampleIter` provide the reusable-sampler workflow without copying Rust traits |
| serde integration | Rust ecosystem-specific; not core RNG functionality for Zig |
| crate feature matrices | Rust packaging-specific |
| Rust SIMD `std::simd` distribution implementations | Zig vector/SIMD support should be designed as a separate Zig-native milestone if needed |

## Remaining Follow-Up

- Add a Linux no-known-gaps audit report tying the local `rand_distr` source
  list to Alea exports, tests, docs, and benchmark rows.
- Continue expanding benchmark parity where new local Rust rows reveal concrete
  performance gaps; current follow-up is tracked in `performance-triage.md`.
- Continue Zig-native vector/SIMD sampling after scalar functionality and
  validation remain stable.
