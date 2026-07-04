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
| `StandardUniform` integers/floats/bools/bytes | Covered by `Rng.value`, scalar helpers, `float`, `boolean`, caller-owned bytes, and allocation-returning `bytesAlloc` |
| `StandardUniform` arrays/tuples | Covered by `Rng.value` arrays and tuples plus allocation-returning `Rng.valueBatch` / `Rng.valueBatchChecked` repeated samples |
| `StandardUniform` char | Covered by explicit `Rng.unicodeScalar`, caller-owned `fillUnicodeScalar`, owned `unicodeScalarBatch`, range helpers, and Unicode UTF-8 helpers, including caller-owned-buffer UTF-8 output |
| `Uniform` integer/float ranges | Covered by `Uniform(T)`, `Open01`, `OpenClosed01`, scalar/vector range helpers, caller-owned range/strict-interval fills, owned `Rng.rangeBatch` / `vectorRangeBatch` / `openBatch` / `openClosedBatch` / `vectorOpenBatch` / `vectorOpenClosedBatch` batches, endpoint/inclusivity, and range/strict-interval moment accessors |
| `UniformChar` | Covered by `unicodeScalarRangeLessThan` / `unicodeScalarRangeAtMost`, caller-owned `fillUnicodeScalarRangeLessThan` / `fillUnicodeScalarRangeAtMost`, and owned `unicodeScalarRangeLessThanBatch` / `unicodeScalarRangeAtMostBatch`; Zig uses `u21` scalar values instead of a native `char` type |
| `UniformDuration` | Covered by `durationRangeLessThan`, `durationRangeAtMost`, and owned duration range batches for `std.Io.Duration` |
| `Bernoulli` | Covered by `Bernoulli`, `chance`, `ratio`, checked variants, caller-owned and allocation-returning scalar/vector chance/ratio batches, and probability/moment/mode/support accessors |
| `Alphanumeric`, `Alphabetic` | Covered by ASCII charsets and `Charset`, including charset byte/emptiness/membership/probability diagnostics |
| `Slice::Choose` and fixed-size slice samples | Covered by `Rng.chooseIndex`, `Rng.chooseIndexU32`, `Rng.choose`, `Rng.chooseConstPtr`, `Rng.choosePtr`, `seq.chooseIndex`, `seq.chooseIndexU32`, `seq.choose`, `seq.chooseConstPtr`, `seq.choosePtr`, `seq.fillChooseIndex`, `seq.fillChooseIndexU32`, `seq.fillChoose`, `seq.fillChooseConstPtr`, `seq.fillChoosePtr`, `seq.chooseIndexBatch`, `seq.chooseIndexU32Batch`, `seq.chooseBatch`, `seq.chooseConstPtrBatch`, `seq.choosePtrBatch`, full in-place `seq.shuffle` / `seq.shuffleFrom`, head-selected `partialShuffle*` and Rust-style tail-selected `partialShuffleTail*`, `seq.Choice` value/pointer/index samples, fills, fixed-size value/pointer/index arrays, and owned value/pointer/index batches, `chooseIter`, `chooseArray`, `sampleItemsArray`, `sampleArray`, and `sampleArrayU32`; item-slice/emptiness diagnostics plus single, fixed-size value/const-pointer/mutable-pointer arrays with both `choose*Array` and `sample*Array` naming, allocated value/const-pointer/mutable-pointer subset slices with both `chooseMultiple*` and `sampleItems*` / `samplePtrs*` / `sampleMutPtrs*` naming, caller-owned value/const-pointer/mutable-pointer subset buffers with matching sample aliases, allocated value/const-pointer/mutable-pointer reservoir samples, caller-owned value/const-pointer/mutable-pointer reservoir buffers, compact `IndexVec` lazy/caller-owned/allocation-returning value/const-pointer/mutable-pointer/u32 export mapping, and fixed-size iterator, caller-owned iterator reservoir exports are available |
| `WeightedIndex` | Covered by `Rng.weightedIndex`, generic `seq.weightedIndex`, `AliasTable`, `WeightedChoice`; checked paths reject non-finite weights and overflowing totals, and `AliasTable.update` / `WeightedChoice.update` support weight replacement |

## Historical Rust `rand` Non-Uniform Distributions

| Rust distribution family | Alea status |
| --- | --- |
| Normal / StandardNormal | Covered: `standardNormal`, `StandardNormal(T)`, `normal`, `Normal(T)`, `Rng.standardNormalBatch`, `Rng.normalBatch`, `Rng.vectorStandardNormalBatch`, `Rng.vectorNormalBatch`, including coefficient-of-variation construction/accessor, z-score conversion, and standard-parameter/moment/median/mode/support accessors; explicit opt-in `StandardNormalNativeF32` / `NormalNativeF32` / `VectorNormalNativeF32` provide separate native-f32 throughput/output profiles, and `VectorStandardNormalTableF32` / `VectorNormalTableF32` and `VectorStandardNormalTableF64` / `VectorNormalTableF64` provide vector-only table-quantile throughput/output profiles |
| LogNormal | Covered: `logNormal`, `LogNormal(T)`, including linear-space mean/coefficient-of-variation construction and accessors, median/mode diagnostics, z-score conversion, log-space, moment, support accessors, f32/f64 benchmark rows, explicit opt-in native-f32 profile `LogNormalNativeF32` / `VectorLogNormalNativeF32`, explicit opt-in f32 approximation paths `LogNormalApproxF32` / `LogNormalExp2F32`, and combined native-normal/exp2 opt-in profile `LogNormalNativeExp2F32` / `VectorLogNormalNativeExp2F32` |
| Exponential / Exp1 | Covered: `standardExponential`, `StandardExponential(T)`, `exponential`, `Exponential(T)`, `Rng.standardExponentialBatch`, `Rng.exponentialBatch`, `Rng.vectorStandardExponentialBatch`, `Rng.vectorExponentialBatch`, including reusable-sampler and standard rate/moment/median/mode/support accessors plus infinite-rate point masses; explicit opt-in `StandardExponentialNativeF32` / `ExponentialNativeF32` / `VectorExponentialNativeF32` provide separate native-f32 throughput/output profiles, `VectorStandardExponentialApproxLogF32` / `VectorExponentialApproxLogF32` provide a vector-only f32 approximate-log throughput profile, and `VectorStandardExponentialTableF32/F64` / `VectorExponentialTableF32/F64` provide vector-only table-quantile throughput/output profiles |
| Gamma | Covered: `gamma`, `Gamma(T)`, including shape/scale/moment/mode/support accessors and collapsed `scale == 0` point masses |
| ChiSquared | Covered: `chiSquared`, `ChiSquared(T)`, including dof/moment/mode/support accessors and collapsed `dof == 0` point masses |
| FisherF | Covered: `fisherF`, `FisherF(T)`, including d1/d2, finite-moment, support accessors, and both-infinite-dof point masses |
| StudentT | Covered: `studentT`, `StudentT(T)`, including dof/finite-moment/support accessors and infinite-dof standard-normal limits |
| Gumbel | Covered: `gumbel`, `Gumbel(T)`, including location/scale/moment/median/mode/support accessors and collapsed `scale == 0` point masses |
| Frechet | Covered: `frechet`, `Frechet(T)`, including location/scale/shape, finite-moment, median/mode, and support accessors plus collapsed `scale == 0` and infinite-shape point masses |
| SkewNormal | Covered: `skewNormal`, `SkewNormal(T)`, including parameter/moment/support accessors and collapsed `scale == 0` point masses |
| Pert | Covered: `pert`, `Pert(T)`, including default-shape, mean, range-builder constructors, builder diagnostics, parameter/moment accessors, collapsed `min == mode == max` point masses, and infinite-shape mode point masses |
| UnitCircle / UnitDisc | Covered: `unitCircle`, `unitDisc`, `UnitCircle(T)`, `UnitDisc(T)`, including geometry, coordinate-moment, and radial-moment accessors |
| UnitSphere / UnitBall | Covered: `unitSphere`, `unitBall`, `UnitSphere(T)`, `UnitBall(T)`, including geometry, coordinate-moment, and radial-moment accessors |
| Poisson | Covered: `poisson`, `Poisson`, large-lambda PTRS path, and lambda/moment/support accessors |
| Binomial | Covered: `binomial`, `Binomial`, exact small/p=0.5/large rejection paths, explicit sparse Poisson approximation helper, and trials/probability/moment/support accessors |
| Geometric / StandardGeometric | Covered: one-based `Geometric`, rand-style failure-count `GeometricFailures`, probability/moment/mode/support accessors, and p=0.5 `StandardGeometric` fast path/accessor |
| Hypergeometric | Covered: `Hypergeometric`, including parameter/moment/support accessors and HIN inverse-transform fast path for small-mode regimes; large-parameter H2PE-equivalent performance remains tracked in `performance-triage.md` |
| WeightedChoice / weighted slice choice | Covered: one-shot `weightedIndex` / `Rng.weightedIndexU32` / `weightedIndexU32` plus `chooseWeighted` / `chooseWeightedConstPtr` / `chooseWeightedPtr`, accessor-based `weightedIndexBy` / `weightedIndexU32By` plus caller-owned repeated `fillWeightedIndexBy` / `fillWeightedIndexU32By`, allocation-returning repeated `weightedIndexBatchBy` / `weightedIndexU32BatchBy`, and `chooseWeightedBy` / `chooseWeightedConstPtrBy` / `chooseWeightedPtrBy`, caller-owned repeated `fillChooseWeightedBy` / `fillChooseWeightedConstPtrBy` / `fillChooseWeightedPtrBy`, allocation-returning repeated `chooseWeightedBatchBy` / `chooseWeightedConstPtrBatchBy` / `chooseWeightedPtrBatchBy`, and `sampleWeightedIndexArrayBy` / `sampleWeightedIndexArrayU32By` / `sampleWeightedArrayBy` / `sampleWeightedPtrArrayBy` / `sampleWeightedMutPtrArrayBy`, `sampleWeightedIndicesBy` / `sampleWeightedIndicesU32By` / `sampleWeightedIndexVecBy`, index-weighted `weightedIndexByIndex` / `weightedIndexU32ByIndex`, caller-owned `fillWeightedIndexByIndex` / `fillWeightedIndexU32ByIndex`, allocation-returning `weightedIndexBatchByIndex` / `weightedIndexU32BatchByIndex`, value/const-pointer/mutable-pointer `chooseWeightedByIndex` / `chooseWeightedConstPtrByIndex` / `chooseWeightedPtrByIndex` plus caller-owned repeated `fillChooseWeightedByIndex` / `fillChooseWeightedConstPtrByIndex` / `fillChooseWeightedPtrByIndex` and allocation-returning repeated `chooseWeightedBatchByIndex` / `chooseWeightedConstPtrBatchByIndex` / `chooseWeightedPtrBatchByIndex`, and `sampleWeightedIndicesByIndex` / `sampleWeightedIndicesU32ByIndex` / `sampleWeightedIndexVecByIndex` plus caller-owned `sampleWeightedIndicesByIndexInto` / `sampleWeightedIndicesU32ByIndexInto` and fixed-size `sampleWeightedIndexArrayByIndex` / `sampleWeightedIndexArrayU32ByIndex` for Rust `index::sample_weighted(..., |index| ...)` workflows, `sampleWeightedBy` / `sampleWeightedPtrsBy` / `sampleWeightedMutPtrsBy`, plus caller-owned `sampleWeighted*ByInto` helpers for item-embedded or derived weights, allocation-returning `sampleWeighted` / `sampleWeightedPtrs` / `sampleWeightedIndicesU32`, compact `sampleWeightedIndexVec`, caller-owned `sampleWeightedIndicesInto` / `sampleWeightedIndicesU32Into` / `sampleWeightedInto` / `sampleWeightedPtrsInto`, fixed-size `sampleWeightedIndexArray` / `sampleWeightedIndexArrayU32` / `sampleWeightedArray` / `sampleWeightedPtrArray` / `sampleIteratorWeightedArray` / `sampleIteratorWeightedInto`, reusable item- or index-accessor-constructible `WeightedChoice` value/pointer/index samples, fills, fixed-size index arrays, updates, and owned value/pointer/index batches, item/emptiness diagnostics, weight/probability diagnostics and exports, weight updates, single/bulk weight introspection, `chooseIteratorStable`, `sampleIteratorFill`, `chooseIteratorWeighted`, `sampleIteratorWeighted` |
| WeightedAliasIndex | Covered: `AliasTable(Weight)` for O(1) repeated weighted sampling, including `initBy` / `updateBy` item-accessor helpers, `initByIndex` / `updateByIndex` index-accessor helpers, `len`, `isEmpty`, `totalWeight`, `weightAt`, `probabilityAt`, deterministic `constantIndex`, `sampleIndex` / `fillIndices` aliases matching reusable `WeightedChoice` naming, compact `sampleU32` / `fillU32` output when populations fit `u32`, owned `indices` / `indicesU32` repeated-sample batches, fixed-size `indexArray` / `indexArrayU32` output, repeated `iter` / `iterU32` index streams, and allocation-returning or caller-buffer weight/probability reconstruction |
| WeightedTreeIndex | Covered: `WeightedTree(Weight)` for generic weights and `WeightedIntTree(Weight)` for faster unsigned integer sample/update/push/pop workloads, including `initBy` / `updateAllBy` item-accessor helpers, `initByIndex` / `updateAllByIndex` index-weight accessor helpers, `sampleIndex` / `fillIndices` aliases matching reusable `WeightedChoice` naming, compact `sampleU32` / `fillU32` output when populations fit `u32`, owned `indices` / `indicesU32` repeated-sample batches, fixed-size `indexArray` / `indexArrayU32` output, and `iter` / `iterU32` repeated index streams; both expose single-weight/probability lookup plus `weights` / `weightsInto` and `probabilities` / `probabilitiesInto` export for diagnostics; `WeightedIntTree` stores subtotals in `u64` and rejects wider integer values that do not fit |
| InverseGaussian | Covered: `inverseGaussian`, `InverseGaussian(T)`, including mean/shape/moment/support accessors and collapsed `mean == 0` / infinite-shape point masses |
| NormalInverseGaussian | Covered: `normalInverseGaussian`, `NormalInverseGaussian(T)`, including alpha/beta/gamma, moment/support accessors, and infinite-alpha point masses |
| Zipf | Covered: `zipf`, `Zipf(T)`, including n/exponent and support-bound accessors |
| Zeta | Covered: `zeta`, `Zeta(T)`, including exponent and support-bound accessors |

## Additional Alea Core Distributions

These are not in current Rust `rand` default crate, but are useful core random
toolkit functionality and reduce reliance on companion crates:

| Alea distribution | Status |
| --- | --- |
| Beta | Covered: `beta`, `Beta(T)`, including alpha/beta/moment/mode/support accessors and infinite-shape boundary point masses |
| Triangular | Covered: `triangular`, `Triangular(T)`, including min/mode/max/moment/median accessors and collapsed `min == mode == max` point masses |
| Arcsine | Covered: `arcsine`, `Arcsine(T)`, including min/max/moment/median accessors and collapsed `min == max` point masses |
| Cauchy | Covered: `cauchy`, `Cauchy(T)`, including median/mode/scale, undefined-moment, support accessors, and collapsed `scale == 0` point masses |
| Laplace | Covered: `laplace`, `Laplace(T)`, including location/scale/median/mode/moment/support accessors and collapsed `scale == 0` point masses |
| Logistic | Covered: `logistic`, `Logistic(T)`, including location/scale/median/mode/moment/support accessors and collapsed `scale == 0` point masses |
| Rayleigh | Covered: `rayleigh`, `Rayleigh(T)`, including scale/moment/median/mode/support accessors and collapsed `scale == 0` point masses |
| HalfNormal | Covered: `halfNormal`, `HalfNormal(T)`, including scale/moment/support accessors and collapsed `scale == 0` point masses |
| Maxwell | Covered: `maxwell`, `Maxwell(T)`, including scale/moment/mode/support accessors and collapsed `scale == 0` point masses |
| Chi | Covered: `chi`, `Chi(T)`, including dof/moment/mode/support accessors and collapsed `dof == 0` point masses |
| Erlang | Covered: `erlang`, `Erlang(T)`, including shape/scale/moment/mode/support accessors and collapsed `scale == 0` point masses |
| LogLogistic | Covered: `logLogistic`, `LogLogistic(T)`, including scale/shape, finite-moment, median/mode, and support accessors plus collapsed `scale == 0` and infinite-shape point masses |
| Kumaraswamy | Covered: `kumaraswamy`, `Kumaraswamy(T)`, including alpha/beta/moment/median/mode/support accessors and infinite-shape boundary point masses |
| PowerFunction | Covered: `powerFunction`, `PowerFunction(T)`, including min/max/shape/moment/median accessors, collapsed `min == max` point masses, and infinite-shape upper-endpoint point masses |
| Pareto | Covered: `pareto`, `Pareto(T)`, including scale/shape, finite-moment, median/mode, and support accessors plus collapsed `scale == 0` and infinite-shape point masses |
| Weibull | Covered: `weibull`, `Weibull(T)`, including scale/shape/moment/median/mode/support accessors plus collapsed `scale == 0` and infinite-shape point masses |
| Dirichlet | Covered: `Dirichlet(T)`, allocation and `sampleInto` APIs, including alpha/mean/variance/covariance export, dimension/total-alpha accessors, one-dimensional point masses, and single-infinite-alpha vertex point masses |
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
