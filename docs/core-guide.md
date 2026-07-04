# Alea Core Guide

This guide summarizes the core random-number functionality expected by
`AGENTS.md`. It is intentionally Zig-native rather than a port of Rust `rand`
traits.

See `docs/examples.md` for a catalog of runnable examples and focused
`zig build run-*` adoption checks. See `docs/tooling.md` for the build-step
and checked-tool catalog maintained by `zig build toolingcheck`.

## Engines

- `DefaultPrng = Xoshiro256`: deterministic default for reproducible work.
- `FastPrng = Alea4x64`: high-throughput non-cryptographic generator.
- `ScalarPrng = Wyhash64`: scalar-heavy fast path for workloads dominated by
  repeated `next()` calls or scalar distributions such as normal, exponential,
  and Poisson. Use it with direct helpers such as `standardNormalFastFrom`,
  `normalFastFrom`, `fillNormalFrom`, `standardExponentialFastFrom`,
  `exponentialFastFrom`, and `fillExponentialFrom` when the engine type is
  known.
- `HashPrng = Wyhash64`: compact hash-style generator.
- `ReproduciblePrng = Pcg64`: stream-selectable reproducible generator.
- `SecurePrng = ChaCha12`: secure-style stream for secret-seeded randomness.

Every engine exposes `next() u64`, `fill([]u8)`, and `random() std.Random`.
Use `alea.Rng.init(&engine)` when you want the ergonomic facade, and direct
engine helpers when benchmark shape matters.

## Seeding

Use `Seed.fromString`, `Seed.fromBytes`, `Seed.mix`, and `Seed.stream` for
stable named streams. Use `Seed.secure(io)`, `defaultSecure`, `fastSecure`,
`scalarSecure`, `hashSecure`, `reproducibleSecure`, `secure(io)`, or
`secureBytes` when the seed must come from system entropy.

See `compare/results/reproducibility-matrix.md` for stable-output expectations.
Run `zig build run-reproducible-streams` for a runnable example of named seeds,
substreams, engine aliases, `Xoshiro` split/jump, and `Pcg64.initTwo` stream
selection.

## Scalar Sampling

`Rng` supports:

- integers: `uint`, `uintLessThan`, `uintAtMost`
- signed and unsigned ranges: `intRangeLessThan`, `intRangeAtMost`
- floats: `float`, `floatOpen`, `floatOpenClosed`, `floatRange`
- vectors: `value(@Vector(N, T))`, `vectorOpen`, `vectorOpenClosed`,
  `vectorRange`, `vectorChance`, `vectorRatio`, `vectorStandardNormal`,
  `vectorNormal`, `vectorStandardExponential`, `vectorExponential` for
  `f32`/`f64`, integer, and boolean lanes
- booleans: `boolean`, `booleanFrom`, `chance`, `chanceFrom`, `ratio`, `ratioFrom`,
  `fillChance`, `fillRatio`
- durations: `durationRangeLessThan`, `durationRangeAtMost`,
  `durationRangeLessThanFrom`, `durationRangeAtMostFrom`
- Unicode scalar values: `unicodeScalar`, `unicodeScalarFrom`
- structured values: `value(T)` / `valueFrom(source, T)` for bools, ints,
  floats, vectors, enums, arrays, and tuples; use `valueChecked` /
  `valueCheckedFrom` or `enumValueChecked` / `enumValueCheckedFrom` when an
  empty enum type should be reported as `EmptyRange` (zero-length arrays are
  valid even when their child type is not sampled, while non-empty arrays or
  tuples containing an empty enum fail before consuming randomness)
- bulk sampling: `fill` / `fillFrom` for scalar and vector slices,
  `fillSample`, `fillSampleFrom`, `fillRange`, `fillRangeFrom`, `fillOpen`, `fillOpenClosed`, `fillChance`, `fillRatio`,
  `fillVectorChance`, `fillVectorRatio`, `fillVectorRange`,
  `fillVectorOpen`, `fillVectorOpenClosed`, `fillVectorOpenFrom`,
  `fillVectorOpenClosedFrom`, `fillStandardNormal`, `fillNormal`,
  `fillLogNormal`, `fillVectorStandardNormal`, `fillVectorNormal`,
  `fillStandardExponential`, `fillExponential`, `fillVectorStandardExponential`,
  and `fillVectorExponential`

Checked variants exist for user-supplied probabilities and scalar ranges,
including facade and direct-source `From` helpers for single scalar draws and
scalar fills, including duration ranges. The same checked/error-returning style
is available for vector ranges, vector probabilities, and parameterized vector
normal/exponential sampling, including facade and direct-source `From` helpers
Run `zig build run-range-sampling` for a runnable comparison of integer ranges,
strict float intervals, bulk range fills, reusable `Uniform` samplers, vector
ranges, duration ranges, collapsed point-masses, and checked range errors.
for ranges, probability vectors, Bernoulli/binomial/binomial-approx/negative-binomial/hypergeometric/geometric/standard-geometric/Poisson/Poisson-AD vectors,
and parameterized normal/exponential vectors/fills when the engine type is
comptime-known.
Zero-length checked scalar and vector fills, including the distribution-namespace
Bernoulli/uniform/normal/exponential wrappers, return before validating
user-supplied range, probability, normal, or exponential parameters.
Distribution-level bulk fills that cache a reusable sampler also keep
assert-fast `fill*` helpers and add checked `fill*Checked` /
`fill*CheckedFrom` variants for common discrete families, core continuous
families, and tail/bounded families such as triangular, arcsine, Cauchy,
Laplace, logistic, log-logistic, Kumaraswamy, power-function, Rayleigh,
Maxwell, Pareto, Weibull, Gumbel, Frechet, skew-normal, PERT, and
inverse-Gaussian-family sampling. Top-level Zipf/Zeta fills mirror their
reusable sampler fills with checked variants for fallible bulk workflows.
Checked distribution facade and direct-source helpers validate parameters
before drawing.
Zero-length checked fills in the core distribution wrapper, discrete families,
core continuous families, derived/tail continuous families, inverse-Gaussian
family, and Zipf/Zeta fills return before validating user parameters.
Run `zig build run-discrete-distributions` for a runnable comparison of
Bernoulli, Binomial, NegativeBinomial, Poisson, Geometric trial/failure counts,
Hypergeometric, and vector discrete samplers.
The distributions module also mirrors `Rng.fillNormal*` and
`Rng.fillExponential*` as top-level helpers for callers who prefer the
distribution namespace; `fillUniform*` and `fillUniformInclusive*` do the same
for exclusive and inclusive uniform ranges. Vector callers can stay in the
same namespace with `vectorBernoulli*`, `fillVectorBernoulli*`,
`vectorBinomial*`, `fillVectorBinomial*`, `vectorBinomialPoissonApprox*`, `fillVectorBinomialPoissonApprox*`, `vectorNegativeBinomial*`, `fillVectorNegativeBinomial*`,
`vectorHypergeometric*`, `fillVectorHypergeometric*`, `vectorGeometric*`,
`fillVectorGeometric*`, `vectorGeometricFailures*`,
`fillVectorGeometricFailures*`, `vectorStandardGeometric*`,
`fillVectorStandardGeometric*`, `vectorPoisson*`, `fillVectorPoisson*`, `vectorPoissonAhrensDieter*`, `fillVectorPoissonAhrensDieter*`,
`vectorUniform*`,
`fillVectorUniform*`, `vectorUniformInclusive*`,
`fillVectorUniformInclusive*`, `vectorStandardNormal*`,
`fillVectorStandardNormal*`, `vectorNormal*`,
`fillVectorNormal*`, `vectorLogNormal*`, `fillVectorLogNormal*`, `vectorLogNormalApproxF32*`, `fillVectorLogNormalApproxF32*`, `vectorHalfNormal*`, `fillVectorHalfNormal*`, `vectorGamma*`,
`fillVectorGamma*`, `vectorChiSquared*`, `fillVectorChiSquared*`,
`vectorChi*`, `fillVectorChi*`, `vectorErlang*`, `fillVectorErlang*`,
`vectorBeta*`, `fillVectorBeta*`, `vectorFisherF*`, `fillVectorFisherF*`, `vectorStudentT*`,
`fillVectorStudentT*`, `vectorTriangular*`, `fillVectorTriangular*`, `vectorArcsine*`, `fillVectorArcsine*`, `vectorCauchy*`, `fillVectorCauchy*`, `vectorLaplace*`, `fillVectorLaplace*`, `vectorLogistic*`, `fillVectorLogistic*`, `vectorLogLogistic*`, `fillVectorLogLogistic*`, `vectorKumaraswamy*`, `fillVectorKumaraswamy*`, `vectorPowerFunction*`, `fillVectorPowerFunction*`, `vectorRayleigh*`, `fillVectorRayleigh*`, `vectorMaxwell*`, `fillVectorMaxwell*`, `vectorPareto*`, `fillVectorPareto*`, `vectorWeibull*`, `fillVectorWeibull*`, `vectorGumbel*`, `fillVectorGumbel*`, `vectorFrechet*`, `fillVectorFrechet*`, `vectorSkewNormal*`, `fillVectorSkewNormal*`, `vectorPert*`, `fillVectorPert*`, `vectorInverseGaussian*`, `fillVectorInverseGaussian*`, `vectorNormalInverseGaussian*`, `fillVectorNormalInverseGaussian*`, `vectorZipf*`, `fillVectorZipf*`, `vectorZeta*`, `fillVectorZeta*`, `vectorUnitCircle*`, `fillVectorUnitCircle*`, `vectorUnitDisc*`, `fillVectorUnitDisc*`, `vectorUnitSphere*`, `fillVectorUnitSphere*`, `vectorUnitBall*`, `fillVectorUnitBall*`,
`vectorStandardExponential*`,
`fillVectorStandardExponential*`, `vectorExponential*`, and
`fillVectorExponential*`; reusable vector samplers `VectorBernoulli`,
`VectorBinomial`, `VectorBinomialPoissonApprox`, `VectorGeometric`, `VectorGeometricFailures`, `VectorStandardGeometric`,
`VectorPoisson`, `VectorPoissonAhrensDieter`, `VectorUniform`, `VectorStandardNormal`, `VectorNormal`, `VectorLogNormal`,
`VectorLogNormalApproxF32`, `VectorHalfNormal`, `VectorGamma`, `VectorChiSquared`, `VectorChi`, `VectorErlang`, `VectorBeta`,
`VectorFisherF`, `VectorStudentT`, `VectorTriangular`, `VectorArcsine`, `VectorCauchy`, `VectorLaplace`, `VectorLogistic`, `VectorLogLogistic`, `VectorKumaraswamy`, `VectorPowerFunction`, `VectorRayleigh`, `VectorMaxwell`, `VectorPareto`, `VectorWeibull`, `VectorGumbel`, `VectorFrechet`, `VectorSkewNormal`, `VectorPert`, `VectorInverseGaussian`, `VectorNormalInverseGaussian`, `VectorZipf`, `VectorZeta`, `VectorUnitCircle`, `VectorUnitDisc`, `VectorUnitSphere`, `VectorUnitBall`, `VectorStandardExponential`, and `VectorExponential`; strict interval samplers
`Open01` and `OpenClosed01` also sample/fill float vector slices.
Use `standardNormalFastFrom`, `normalFastFrom`,
`standardExponentialFastFrom`, and `exponentialFastFrom` when a comptime-known
engine pointer is available and the workload is dominated by scalar
distribution sampling.
Use the `NativeF32` standard/parameterized normal and exponential profiles only
when f32-native throughput matters more than matching the exact/default
f64-backed f32 output mapping. Run `zig build run-native-f32-profiles` for a
small executable comparison of exact/default f32 outputs with native-f32 scalar
and vector profiles.


`LogNormalApproxF32`, `VectorLogNormalApproxF32`, and the `logNormalApproxF32*` /
`fillLogNormalApproxF32*` / `vectorLogNormalApproxF32*` /
`fillVectorLogNormalApproxF32*` helpers are explicitly opt-in: they use
`expm1(x) + 1` for the final transform to target narrow f32 throughput. They
are checked to `|mean| <= LogNormalApproxF32.max_abs_mean` and
`stddev <= LogNormalApproxF32.max_stddev`; use exact `LogNormal(f32)` /
`fillLogNormal` whenever bit-identical `@exp` output or wider parameters are
required. Run `zig build run-lognormal-profiles` for a small executable example
showing exact, buffered, native-f32, exp2, native-exp2, and platform libc-backed
LogNormal profiles when available.

For throughput-first vector normal/exponential workloads, Alea exposes explicit
profile names instead of silently changing the exact/default vector APIs. Use
`VectorStandardNormalTableF32/F64`, `VectorNormalTableF32/F64`,
`VectorStandardExponentialTableF32/F64`, `VectorExponentialTableF32/F64`, or
`VectorStandardExponentialApproxLogF32` / `VectorExponentialApproxLogF32` only
when the caller accepts the documented approximation/output-mapping contract.
The table profiles are discrete/truncated midpoint-quantile lookups; the f32
approx-log exponential profile is approximate and f32-only. Exact/default
`vectorNormal` and `vectorExponential` APIs remain scalar ziggurat lane-fill for
stable exact-output semantics. Run `zig build run-vector-profiles` for a small
executable example comparing exact/default vectors with the accepted throughput
profiles.

## Distributions

Single-shot helpers and reusable samplers cover:

- uniform, Bernoulli, binomial, negative-binomial, vector Bernoulli/binomial/binomial-approx/negative-binomial
Run `zig build run-continuous-distributions` for a runnable comparison of core
continuous reusable samplers, diagnostics, fill APIs, and vector lane batches.
Run `zig build run-advanced-continuous-distributions` for a runnable comparison
of half/chi/Maxwell/skew/inverse-Gaussian and other advanced shape/tail
families.
- standard normal, normal, exact/vector log-normal plus opt-in bounded f32
  approximate log-normal/vector approximate log-normal, half-normal/vector half-normal, standard exponential,
  exponential
- poisson, vector poisson/Poisson-AD, geometric, vector geometric/failures
- gamma/vector gamma, chi-squared/vector chi-squared, chi/vector chi, erlang/vector erlang,
  beta/vector beta, Fisher F/vector Fisher F, Student t/vector Student t
- triangular/vector triangular, arcsine/vector arcsine, cauchy/vector cauchy, laplace/vector laplace, logistic/vector logistic, log-logistic/vector log-logistic, kumaraswamy/vector kumaraswamy,
  power-function/vector power-function, rayleigh/vector rayleigh, maxwell/vector maxwell, pareto/vector pareto, weibull/vector weibull
- gumbel/vector gumbel, frechet/vector frechet, skew-normal/vector skew-normal, PERT/vector PERT
- inverse Gaussian/vector inverse Gaussian, normal-inverse Gaussian/vector normal-inverse Gaussian, Zipf/vector Zipf, Zeta/vector Zeta
- unit circle/vector unit circle, unit disc/vector unit disc, unit sphere/vector unit sphere, and unit ball/vector unit ball geometry samplers
Run `zig build run-rank-distributions` for a runnable comparison of finite
`Zipf`, unbounded `Zeta`, vector rank samplers, and degenerate infinite-exponent
rank-one behavior.
- dirichlet

Reusable samplers expose `sample(rng)`, and direct-source samplers expose
`sampleFrom(source)` where comptime-known engine dispatch is useful. They can be
used with `rng.sampleIter(T, sampler)` or
`Rng.sampleIterFrom(source, T, sampler)` when the sample type is scalar, and
their iterator `fill` methods inherit sampler-specific bulk fills where
available. `valueIter(T)` / `valueIterFrom(source, T)` likewise delegate
iterator fills to `Rng.fill` / `fillFrom` for stream-compatible `f64`,
64-bit integer, and matching vector slice types; packed `bool`, `f32`, `u8`,
and sub-64-bit integer fills keep repeated-`nextValue` stream shape.
`Dirichlet` and `Multinomial` support allocation-returning `sample(allocator, rng)` /
`sampleFrom(allocator, source)` and allocation-free `sampleInto(rng, out)` /
`sampleIntoFrom(source, out)` and flat `sampleManyInto` / `sampleManyIntoFrom`
batch APIs; both also expose checked `sampleInto*` / `sampleManyInto*` variants
for user-supplied output buffers. Invalid checked output lengths and initial
allocation failures in allocation-returning multivariate samples are reported
before any component draws; zero-length checked batch outputs are no-ops.
Run `zig build run-multivariate-sampling` for a runnable comparison of
allocation-returning, caller-owned-buffer, and flat batched Multinomial and
Dirichlet sampling.
`Normal(T).initMeanCv` and
`LogNormal(T).initMeanCv` cover coefficient-of-variation parameterization
without requiring users to hand-convert to log-space parameters; both samplers
also expose z-score conversion helpers for correlated draws. `Pert(T).initRange`
offers a builder-style range-first constructor with `withShape`, `withMode`,
and `withMean` for workflows that choose range before mode/mean. Unit geometry samplers also
Run `zig build run-distribution-diagnostics` for a runnable tour of
constructor/accessor diagnostics such as moments, support, mean/CV constructors,
z-score conversion, and PERT range-first builders.
expose `fill` / `fillFrom`, and the module-level `fillUnitCircle`,
`fillUnitDisc`, `fillUnitSphere`, and `fillUnitBall` helpers fill slices of
fixed-size point arrays.
Run `zig build run-unit-geometry` for a runnable comparison of unit surface,
filled-volume, slice-fill, reusable-sampler diagnostics, and vector-lane unit
geometry helpers.

## Sequence And Collection Sampling

Use:

- `rng.chooseIndex`, `Rng.chooseIndexFrom`, `Rng.chooseIndexCheckedFrom`,
  `rng.chooseIndexU32`, `Rng.chooseIndexU32From`,
  `Rng.chooseIndexU32CheckedFrom`, `rng.choose`, `Rng.chooseFrom`,
  `Rng.chooseCheckedFrom`,
  `rng.chooseConstPtr`, `Rng.chooseConstPtrFrom`,
  `Rng.chooseConstPtrCheckedFrom`, `rng.choosePtr`, `Rng.choosePtrFrom`,
  `Rng.choosePtrCheckedFrom`
- `rng.shuffle`, `Rng.shuffleFrom`
- `seq.partialShuffle`, `seq.partialShuffleFrom`,
  `seq.partialShuffleCheckedFrom`, `seq.partialShuffleSplitFrom`,
  `seq.partialShuffleSplitCheckedFrom`
- `seq.reservoirSample`, `seq.reservoirSampleFrom`,
  `seq.reservoirSampleCheckedFrom`, `seq.reservoirSamplePtrsFrom`,
  `seq.reservoirSamplePtrsCheckedFrom`, `seq.reservoirSampleMutPtrsFrom`,
  `seq.reservoirSampleMutPtrsCheckedFrom`, `seq.reservoirSampleInto`,
  `seq.reservoirSampleIntoFrom`, `seq.reservoirSamplePtrsIntoFrom`,
  `seq.reservoirSampleMutPtrsIntoFrom`
- `seq.sampleIndices`, `seq.sampleIndicesCheckedFrom`,
  `seq.sampleIndicesIntoFrom`, `seq.sampleIndicesIntoCheckedFrom`,
  `seq.sampleIndexVec`,
  `seq.sampleIndexVecCheckedFrom`, `seq.sampleIndicesU32`,
  `seq.sampleIndicesU32CheckedFrom`, `seq.sampleIndicesU32IntoFrom`,
  `seq.sampleIndicesU32IntoCheckedFrom`; compact `IndexVec` results expose
  `len`, `isEmpty`, `at`, `copyInto`, `copyIntoU32`, `toOwnedSlice`,
  `toOwnedU32Slice`, and an exact-size `iter` with `remaining`, plus
  `values` / `ptrs` / `mutPtrs`, `valuesInto` / `ptrsInto` /
  `mutPtrsInto`, `valuesOwned` / `ptrsOwned` / `mutPtrsOwned`, and checked
  variants for mapping indexes back to slice items
- `seq.sampleArray`, `seq.sampleArrayFrom`, `seq.sampleArrayCheckedFrom`,
  `seq.sampleArrayU32`, `seq.sampleArrayU32From`,
  `seq.sampleArrayU32CheckedFrom`
- `seq.chooseMultiple`, `seq.chooseMultipleFrom`,
  `seq.chooseMultipleCheckedFrom`, `seq.chooseMultiplePtrsFrom`,
  `seq.chooseMultiplePtrsCheckedFrom`, `seq.chooseMultipleMutPtrsFrom`,
  `seq.chooseMultipleMutPtrsCheckedFrom`, `seq.chooseMultipleIntoFrom`,
  `seq.chooseMultipleIntoCheckedFrom`, `seq.chooseMultiplePtrsIntoFrom`,
  `seq.chooseMultiplePtrsIntoCheckedFrom`,
  `seq.chooseMultipleMutPtrsIntoFrom`,
  `seq.chooseMultipleMutPtrsIntoCheckedFrom`, `seq.chooseArray`,
  `seq.chooseArrayFrom`, `seq.chooseArrayCheckedFrom`,
  `seq.choosePtrArrayFrom`, `seq.choosePtrArrayCheckedFrom`,
  `seq.chooseMutPtrArrayFrom`, `seq.chooseMutPtrArrayCheckedFrom`
- `seq.chooseIterator`, `seq.chooseIteratorFrom`,
  `seq.chooseIteratorCheckedFrom`, `seq.sampleIterator`, `seq.sampleIteratorFrom`,
  `seq.sampleIteratorCheckedFrom`, `seq.sampleIteratorArrayFrom`,
  `seq.sampleIteratorArrayCheckedFrom`, `seq.sampleIteratorInto`,
  `seq.sampleIteratorIntoFrom`, `seq.sampleIteratorIntoCheckedFrom`
- `seq.chooseIteratorWeighted`, `seq.chooseIteratorWeightedFrom`,
  `seq.chooseIteratorWeightedCheckedFrom`, `seq.sampleIteratorWeighted`,
  `seq.sampleIteratorWeightedFrom`, `seq.sampleIteratorWeightedCheckedFrom`,
  `seq.sampleIteratorWeightedArrayFrom`,
  `seq.sampleIteratorWeightedArrayCheckedFrom`,
  `seq.sampleIteratorWeightedIntoFrom`,
  `seq.sampleIteratorWeightedIntoCheckedFrom`
- `seq.weightedIndex`, `seq.weightedIndexFrom`,
  `seq.weightedIndexCheckedFrom`, `seq.weightedIndexU32From`,
  `seq.weightedIndexU32CheckedFrom`
- `seq.chooseWeighted`, `seq.chooseWeightedFrom`,
  `seq.chooseWeightedCheckedFrom`, `seq.chooseWeightedConstPtrFrom`,
  `seq.chooseWeightedConstPtrCheckedFrom`, `seq.chooseWeightedPtr`,
  `seq.chooseWeightedPtrFrom`, `seq.chooseWeightedPtrCheckedFrom`
- `seq.sampleWeightedIndices`, `seq.sampleWeightedIndicesFrom`,
  `seq.sampleWeightedIndicesCheckedFrom`, `seq.sampleWeightedIndicesU32From`,
  `seq.sampleWeightedIndicesU32CheckedFrom`, `seq.sampleWeightedIndexVecFrom`,
  `seq.sampleWeightedIndexVecCheckedFrom`, `seq.sampleWeightedIndicesIntoFrom`,
  `seq.sampleWeightedIndicesIntoCheckedFrom`,
  `seq.sampleWeightedIndicesU32IntoFrom`,
  `seq.sampleWeightedIndicesU32IntoCheckedFrom`,
  `seq.sampleWeightedIndexArrayFrom`,
  `seq.sampleWeightedIndexArrayCheckedFrom`,
  `seq.sampleWeightedIndexArrayU32From`,
  `seq.sampleWeightedIndexArrayU32CheckedFrom`, `seq.sampleWeighted`,
  `seq.sampleWeightedFrom`, `seq.sampleWeightedCheckedFrom`,
  `seq.sampleWeightedPtrsFrom`, `seq.sampleWeightedPtrsCheckedFrom`,
  `seq.sampleWeightedMutPtrsFrom`, `seq.sampleWeightedMutPtrsCheckedFrom`,
  `seq.sampleWeightedIntoFrom`, `seq.sampleWeightedIntoCheckedFrom`,
  `seq.sampleWeightedPtrsIntoFrom`, `seq.sampleWeightedPtrsIntoCheckedFrom`,
  `seq.sampleWeightedMutPtrsIntoFrom`,
  `seq.sampleWeightedMutPtrsIntoCheckedFrom`,
  `seq.sampleWeightedArrayFrom`, `seq.sampleWeightedArrayCheckedFrom`,
  `seq.sampleWeightedPtrArrayFrom`, `seq.sampleWeightedPtrArrayCheckedFrom`,
  `seq.sampleWeightedMutPtrArrayFrom`,
  `seq.sampleWeightedMutPtrArrayCheckedFrom`
  (`*Checked*` variants require enough positive-weight entries for the
  requested amount; requesting zero samples returns an empty result before
  validating weights; facade and direct-source checked calls validate before
  drawing)
- `seq.Choice`, `seq.chooseIterFrom`, `seq.chooseIterCheckedFrom`,
  `seq.WeightedChoice`, including `Choice.iterFrom`, `WeightedChoice.update`,
  `WeightedChoice.iterFrom`, `WeightedChoice.totalWeight`, and
  `WeightedChoice.weightAt` / `weightsInto`
- `distributions.AliasTable` for O(1) repeated weighted index sampling,
  including `len`, `totalWeight`, and allocation-returning or caller-buffer
  `weightAt` / `weights` reconstruction for diagnostics and parity with Rust weighted
  sampler introspection
- `distributions.WeightedTree` for O(log n) dynamic weight update, push, pop,
  and sampling workloads with weights accumulated as `f64`, including bulk
  `weights` / `weightsInto` export for diagnostics
- `distributions.WeightedIntTree` for unsigned integer weights when dynamic
  update/push/pop/sample throughput matters; weights wider than `u64` are
  accepted only when each value fits the `u64` accumulator
  (failed push/update operations preserve the previous tree totals, and
  zero-length checked fills return before validating totals)
Run `zig build run-weighted-sampling` for a runnable comparison of one-shot
weighted indexes, static alias tables, dynamic weighted trees, weighted choices,
and weighted no-replacement helpers.

Prefer `sampleIndexVec` or `sampleIndicesU32` for compact, high-throughput index
sampling. Use `sampleArrayU32From` for compact fixed-size index arrays when the
population length fits `u32`, and use `sampleIndices` when a `[]usize` result is
more convenient.
Run `zig build run-sequence-sampling` for a runnable comparison of index
sampling, item subsets, partial shuffles, reservoir samples, reusable `Choice`,
and streaming iterator choices. Run `zig build run-caller-owned-sampling` for a
focused tour of caller-owned index, item, iterator, weighted, and scratch-buffer
workflows.
Exact-capacity Floyd-style index samplers return their owned buffers without a
post-sampling shrink allocation.
In-place index samplers prepare their returned output before drawing, so output
allocation failures leave the stream untouched.
Rejection index samplers also clean up staged set allocations before drawing if
their internal set allocation fails.
Use `Rng.weightedIndexFrom`, `Rng.sampleWithoutReplacementFrom`,
`sampleWeightedFrom`, `Choice.iterFrom`, `WeightedChoice.iterFrom`,
`AliasTable.sampleFrom`, and `WeightedChoice.sampleValueFrom` for weighted or
collection sampling with a comptime-known engine source.
Checked sample-without-replacement and iterator-sampling calls with count zero
return an empty result before building temporary storage, reading the iterator,
or drawing from the stream.
Exact-count checked iterator sampling prepares output (and weighted heap storage
when applicable) before reading the iterator or drawing.
Full reservoir iterator samples return their exact-capacity buffer without a
post-sampling ownership allocation.
Checked index-vector, choose-multiple, and reservoir helpers follow the same
zero-count no-draw policy.
Fixed-size index arrays with `N == 0` are valid and return before drawing.
Zero-count partial shuffles are no-ops: they return an empty head without
mutating the input slice or drawing.
Zero-length reusable `Choice` / `WeightedChoice` / `AliasTable` fills are
no-ops and do not draw.
Empty `chooseIter` / `chooseIterChecked` convenience calls return null/errors
before drawing.
Empty optional `chooseIterator` / `chooseIteratorWeighted` streaming calls
return null before drawing; invalid or all-zero weighted iterator choices do
not draw.
Empty streaming `chooseIteratorChecked` / `chooseIteratorWeightedChecked`
facade calls also fail before drawing.
Allocation failures while preparing the sample-without-replacement temporary
pool/output also return before drawing.
Successful sample-without-replacement calls return their exact-capacity output
without a post-sampling ownership allocation.
`chooseMultipleFrom` prepares its output and index storage before drawing, and
`reservoirSampleIntoFrom` validates caller-owned output length before drawing, so
allocation failures leave the stream untouched.
Checked weighted index and item sampling likewise prepare output and temporary
heap/index storage before drawing after validating lengths and positive-weight
availability. Use `sampleWeightedIndicesU32From` for compact
allocation-returning weighted index slices, `sampleWeightedIndexArrayU32From` for
compact fixed-size weighted index arrays, or `sampleWeightedIndicesU32IntoFrom`
when the weight slice fits `u32` and the caller wants compact, allocation-free
runtime-length index output.
Slice weighted sampling validates all weights before drawing, so invalid
weights leave the stream untouched.
The remaining allocation-returning streaming helpers whose result length is not
known until the stream is inspected are explicitly different: short
`sampleIteratorFrom` results, partial weighted-iterator samples, and Unicode
UTF-8 string allocation may need to finalize storage after reading/drawing, so
prefer checked exact-count or caller-owned-buffer forms when no-consume
allocation-failure behavior matters.
`AliasTable.update` and `WeightedChoice.update` build the replacement table
before swapping state, so length, weight, and initial allocation failures leave
the previous valid table usable.
For allocation-returning sequence helpers, initial allocation failures are
reported before drawing from the stream; later one-pass failure paths may have
already consumed randomness for earlier accepted candidates.

## Strings

`ascii.zig` includes ASCII `Alphanumeric`, `Alphabetic`, `Lowercase`,
`Uppercase`, `Digits`, custom `Charset`, and Unicode scalar UTF-8 string
generation. Use `Charset.sampleFrom`, `Charset.fillFrom`,
`Charset.allocFrom`, `charFrom`, `stringFrom`, `unicodeScalarFrom`,
`unicodeUtf8AllocFrom`, `unicodeUtf8Capacity`, and `unicodeUtf8IntoFrom` when
the engine type is comptime-known. Use
`Charset.sampleChecked`, `Charset.sampleCheckedFrom`, `Charset.fillChecked`,
`Charset.fillCheckedFrom`, `Charset.allocChecked`, and
`Charset.allocCheckedFrom` when a manually constructed charset may be empty;
zero-length fills and allocations return empty results before validating charset
contents. Initial allocation failures in ASCII and Unicode string helpers are
reported before any scalar is drawn, so retry/error paths do not silently
advance a deterministic stream. `unicodeUtf8Into` / `unicodeUtf8IntoFrom` let
callers use a caller-owned buffer sized via `unicodeUtf8Capacity`; too-small
buffers fail before drawing.
Run `zig build run-string-generation` for a runnable comparison of predefined
ASCII charsets, custom `Charset` diagnostics, allocation-returning strings,
Unicode scalar generation, and caller-owned UTF-8 buffers.

## Validation

Run:

```sh
zig build test
zig build apicheck
zig build examplecheck
zig build toolingcheck
zig build readmecheck
zig build roadmapcheck
zig build doccheck
zig build validate
zig build validate-all
zig build crosscheck
zig build test-wasi
zig build wasi-report
zig build -Doptimize=ReleaseFast statcheck
zig build -Doptimize=ReleaseFast profilecheck
zig build -Doptimize=ReleaseFast profilecheck-tail
zig build -Doptimize=ReleaseFast profilecheck-stress
zig build -Doptimize=ReleaseFast profilecheck-long
zig build -Doptimize=ReleaseFast wasi-profilecheck
zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 1048576 > /tmp/alea.bin
sh tools/practrand.sh fast 1073741824
```

PractRand reports are stored under `compare/results/`.

## Benchmarks

Run:

```sh
zig build -Doptimize=ReleaseFast -Dcpu=native bench
zig build -Doptimize=ReleaseFast -Dcpu=native bench -- "standard-normal"
zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench
zig build -Doptimize=ReleaseFast -Dcpu=native ziggurat-probe
RUSTFLAGS="-C target-cpu=native" cargo run --release --manifest-path compare/rand_bench/Cargo.toml
RUSTFLAGS="-C target-cpu=native" cargo run --release --manifest-path compare/rand_bench/Cargo.toml -- "standard-normal"
```

The benchmark intentionally separates facade/type-erased paths from direct
static engine paths. `bench -- [bytes] [filter]` optionally overrides the byte
count and filters row names by case-insensitive substring for focused
full-harness reruns; the
Rust comparison binary accepts the same argument shape. `alea.Rng` has
function-pointer dispatch comparable to
`std.Random`; direct helpers are closer to Rust's monomorphized `SmallRng`
benchmark shape.

Use `vectorbench` for focused SIMD/vector-slice evidence without slowing the
full throughput suite. The current local rows cover packed bool chance/ratio,
strict-open/open-closed/range vector float fills, distribution-namespace vector
Bernoulli/binomial/binomial-approx/negative-binomial/hypergeometric/geometric/standard-geometric/Poisson/Poisson-AD/uniform/normal/log-normal/approx-log-normal/half-normal/gamma/chi-squared/chi/erlang/beta/fisher-f/student-t/triangular/arcsine/cauchy/laplace/logistic/log-logistic/kumaraswamy/power-function/rayleigh/maxwell/pareto/weibull/gumbel/frechet/skew-normal/PERT/inverse-Gaussian/normal-inverse-Gaussian/Zipf/Zeta/unit-circle/unit-disc/unit-sphere/unit-ball/exponential wrappers over those kernels, and
scalar-lane normal/exponential vector fills;
representative rows are about 1.01B lanes/s
for `fillVectorRange(f32x8)`, about 694M lanes/s for
`fillVectorRange(f64x4)`, about 498-502M lanes/s for normal vectors, and about
468-473M lanes/s for exponential vectors. Requirements for a future true dense
SIMD distribution kernel are tracked in
`compare/results/simd-distribution-kernel-notes.md`.

Use focused probes such as `ziggurat-probe`, `open-closed-probe`, and the
distribution-specific probes under `tools/` to isolate hot-path expression
shape before changing production algorithms. Keep accepted and rejected probe
outcomes in `compare/results/performance-triage.md`. LogNormal transform
experiments and exact `(0, 1]` endpoint-grid work have additional
accuracy/reproducibility notes in `compare/results/lognormal-transform-notes.md`
and `compare/results/openclosed-endpoint-notes.md`.
