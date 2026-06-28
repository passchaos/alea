# Alea API Reference

This reference lists the public API surface by module. See `docs/core-guide.md`
for usage guidance and `compare/results/reproducibility-matrix.md` for stability
expectations.

## Root Module

- Modules: `Rng`, `Seed`, `distributions`, `seq`, `ascii`, `quality`
- Engines: `SplitMix64`, `Wyhash64`, `Alea4x64`, `Xoshiro256PlusPlus`,
  `Xoshiro256`, `Pcg64`, `ChaCha`
- Aliases: `DefaultPrng`, `FastPrng`, `HashPrng`, `ReproduciblePrng`,
  `ScalarPrng`, `SecurePrng`
- Constructors: `default`, `defaultSecure`, `fast`, `fastSecure`,
  `scalar`, `scalarSecure`, `reproducible`, `reproducibleSecure`,
  `secureFromSeed`, `secure`, `secureBytes`, `rng`

## Rng

- Construction and interop: `init`, `fromRandom`, `random`
- Values: `value`, `valueIter`, `randomIter`, `sampleIter`
- Bytes/fill: `bytes`, `fill` for scalar and vector slices, `fillSample`,
  `fillSampleFrom`, `fillRange`, `fillRangeChecked`, `fillNormal`, `fillNormalChecked`,
  `fillExponential`, `fillExponentialChecked`, `fillVectorRange`,
  `fillVectorRangeChecked`, `fillVectorNormal`, `fillVectorNormalChecked`,
  `fillVectorExponential`, `fillVectorExponentialChecked`, `fillNormalFrom`,
  `fillExponentialFrom`, `fillVectorFrom`, `fillVectorRangeFrom`,
  `fillVectorNormalFrom`, `fillVectorExponentialFrom`
- Raw/scalars: `next`, `boolean`, `chance`, `chanceChecked`, `ratio`,
  `ratioChecked`, `uint`, `uintLessThan`, `uintLessThanChecked`,
  `uintAtMost`, `uintFrom`, `uintLessThanFrom`, `uintAtMostFrom`
- Ranges: `intRangeLessThan`, `intRangeLessThanChecked`, `intRangeAtMost`,
  `intRangeAtMostChecked`, `intRangeLessThanFrom`, `intRangeAtMostFrom`,
  `floatRange`, `floatRangeChecked`, `durationRangeLessThan`,
  `durationRangeAtMost`, `durationRangeLessThanChecked`,
  `durationRangeAtMostChecked`
- Floats: `float`, `floatOpen`, `floatOpenClosed`
- Vectors: `vector`, `vectorRange`, `vectorRangeChecked`, `vectorNormal`,
  `vectorExponential`, `vectorFrom`, `vectorRangeFrom`
- Unicode: `unicodeScalar`
- Distributions: `normal`, `exponential`, `normalFastFrom`,
  `exponentialFastFrom`
- Enums and collections: `enumValue`, `shuffle`, `choose`, `choosePtr`,
  `weightedIndex`, `weightedIndexChecked`, `sampleWithoutReplacement`,
  `sampleWithoutReplacementChecked`
- Iterator types: `ValueIterator(T)`, `SampleIterator(Sampler, T)`

## Seed

- `init`
- `fromBytes`
- `fromString`
- `secure`
- `mix`
- `stream`
- `next`
- `bytes`

## Engines

All engines expose deterministic construction and `random()` interop where
appropriate.

- `SplitMix64`: `init`, `next`
- `Wyhash64`: `init`, `fromState`, `random`, `next`, `fill`
- `Alea4x64`: `init`, `random`, `next`, `fill`
- `Xoshiro256`: `init`, `seed`, `random`, `next`, `split`, `jump`,
  `longJump`, `fill`
- `Xoshiro256PlusPlus`: `init`, `random`, `next`, `jump`, `fill`
- `Pcg64`: `init`, `initTwo`, `random`, `next`, `fill`
- `ChaCha`: `seed_length`, `init`, `initFromU64`, `random`, `addEntropy`,
  `next`, `fill`

## Distributions

Single-shot helpers:

- `uniform`, `uniformInclusive`
- `bernoulli`, `binomial`, `binomialPoissonApprox`
- `negativeBinomial`, `hypergeometric`
- `normal`, `logNormal`, `exponential`
- `poisson`, `geometric`
- `gamma`, `gammaFrom`, `chiSquared`, `beta`, `fisherF`, `studentT`
- `triangular`, `cauchy`, `pareto`, `weibull`
- `gumbel`, `frechet`, `skewNormal`, `pert`
- `inverseGaussian`, `normalInverseGaussian`, `zipf`, `zeta`
- `unitCircle`, `unitDisc`, `unitSphere`, `unitBall`

Reusable samplers:

- `Bernoulli`
- `Binomial`
- `Multinomial`
- `NegativeBinomial`
- `Hypergeometric`
- `Uniform(T)`
- `Open01`
- `OpenClosed01`
- `Normal(T)`
- `Exponential(T)`
- `LogNormal(T)`
- `Poisson`
- `Poisson.sampleFrom`
- `Geometric`
- `Gamma(T)`
- `Gamma(T).sampleFrom`
- `ChiSquared(T)`
- `ChiSquared(T).sampleFrom`
- `Beta(T)`
- `Beta(T).sampleFrom`
- `FisherF(T)`
- `FisherF(T).sampleFrom`
- `StudentT(T)`
- `StudentT(T).sampleFrom`
- `Triangular(T)`
- `Cauchy(T)`
- `Pareto(T)`
- `Weibull(T)`
- `Gumbel(T)`
- `Frechet(T)`
- `SkewNormal(T)`
- `Pert(T)`
- `InverseGaussian(T)`
- `InverseGaussian(T).sampleFrom`
- `NormalInverseGaussian(T)`
- `NormalInverseGaussian(T).sampleFrom`
- `Zipf(T)`
- `Zeta(T)`
- `UnitCircle(T)`
- `UnitDisc(T)`
- `UnitSphere(T)`
- `UnitBall(T)`
- `Dirichlet(T)`
- `AliasTable(Weight)`
- `WeightedTree(Weight)`
- `WeightedIntTree(Weight)`

Alias helpers:

- `aliasTable(T)`
- `AliasTable.init`
- `AliasTable.update`
- `AliasTable.sample`
- `AliasTable.deinit`

Dynamic weighted helpers:

- `WeightedTree.init`
- `WeightedTree.push`
- `WeightedTree.pop`
- `WeightedTree.update`
- `WeightedTree.get`
- `WeightedTree.sample`
- `WeightedTree.sampleChecked`
- `WeightedTree.totalWeight`
- `WeightedTree.isValid`
- `WeightedTree.deinit`

## Sequence Sampling

- Index vectors: `IndexVec.len`, `IndexVec.at`, `IndexVec.deinit`
- Indices: `sampleIndexVec`, `sampleIndexVecFrom`, `sampleIndices`,
  `sampleIndicesFrom`, `sampleIndicesU32`, `sampleIndicesU32From`,
  `sampleArray`
- Collections: `chooseMultiple`, `partialShuffle`, `reservoirSample`
- Iterators: `chooseIterator`, `sampleIterator`, `chooseIteratorWeighted`,
  `sampleIteratorWeighted`
- Reusable samplers: `Choice(T)`, `chooseIter`, `WeightedChoice(T, Weight)`
- Weighted no-replacement: `sampleWeightedIndices`, `sampleWeighted`

## ASCII And Unicode

- Charset constants: `Alphanumeric`, `Alphabetic`, `Lowercase`, `Uppercase`,
  `Digits`
- Charset type: `Charset.init`, `Charset.initChecked`, `Charset.sample`,
  `Charset.fill`, `Charset.alloc`
- Helpers: `char`, `string`, `unicodeScalar`, `unicodeUtf8Alloc`

## Validation And Tooling

Build steps:

- `zig build test`
- `zig build run-basic`
- `zig build statcheck`
- `zig build distcheck`
- `zig build stream -- --engine <engine> --bytes <n>`
- `zig build repro`
- `zig build -Doptimize=ReleaseFast -Dcpu=native bench`
- `zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench`

Tools:

- `tools/statcheck.zig`
- `tools/distcheck.zig`
- `tools/stream.zig`
- `tools/repro.zig`
- `tools/practrand.sh`
