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
  `fillSampleFrom`, `fillRange`, `fillRangeChecked`, `fillOpen`,
  `fillOpenFrom`, `fillOpenClosed`, `fillOpenClosedFrom`, `fillChance`,
  `fillChanceChecked`, `fillRatio`, `fillRatioChecked`, `fillNormal`, `fillNormalChecked`,
  `fillExponential`, `fillExponentialChecked`, `fillVectorRange`,
  `fillVectorRangeChecked`, `fillVectorChance`, `fillVectorChanceChecked`,
  `fillVectorRatio`, `fillVectorRatioChecked`, `fillVectorNormal`,
  `fillVectorNormalChecked`, `fillVectorExponential`, `fillVectorExponentialChecked`, `fillNormalFrom`,
  `fillExponentialFrom`, `fillChanceFrom`, `fillRatioFrom`, `fillVectorFrom`,
  `fillVectorOpenFrom`, `fillVectorOpenClosedFrom`, `fillVectorRangeFrom`,
  `fillVectorChanceFrom`, `fillVectorRatioFrom`, `fillVectorNormalFrom`,
  `fillVectorExponentialFrom`
- Raw/scalars: `next`, `boolean`, `chance`, `chanceChecked`, `ratio`,
  `chanceFrom`, `ratioFrom`, `ratioChecked`, `uint`, `uintLessThan`, `uintLessThanChecked`,
  `uintAtMost`, `uintFrom`, `uintLessThanFrom`, `uintAtMostFrom`
- Ranges: `intRangeLessThan`, `intRangeLessThanChecked`, `intRangeAtMost`,
  `intRangeAtMostChecked`, `intRangeLessThanFrom`, `intRangeAtMostFrom`,
  `floatRange`, `floatRangeFrom`, `floatRangeChecked`, `durationRangeLessThan`,
  `durationRangeAtMost`, `durationRangeLessThanChecked`,
  `durationRangeAtMostChecked`
- Floats: `float`, `floatFrom`, `floatOpen`, `floatOpenFrom`,
  `floatOpenClosed`, `floatOpenClosedFrom`
- Vectors: `vector`, `vectorOpen`, `vectorOpenClosed`, `vectorRange`,
  `vectorRangeChecked`, `vectorChance`,
  `vectorChanceChecked`, `vectorRatio`, `vectorRatioChecked`, `vectorNormal`,
  `vectorExponential`, `vectorFrom`, `vectorOpenFrom`, `vectorOpenClosedFrom`,
  `vectorRangeFrom`, `vectorChanceFrom`, `vectorRatioFrom`
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

- `uniform`, `uniformFrom`, `uniformInclusive`, `uniformInclusiveFrom`
- `bernoulli`, `binomial`, `binomialFrom`, `binomialPoissonApprox`
- `negativeBinomial`, `negativeBinomialFrom`, `hypergeometric`,
  `hypergeometricFrom`
- `standardNormal`, `standardNormalFrom`, `normal`, `logNormal`,
  `logNormalFrom`, `halfNormal`, `halfNormalFrom`, `chi`, `chiFrom`,
  `standardExponential`, `standardExponentialFrom`, `exponential`
- `poisson`, `geometric`, `geometricFrom`
- `gamma`, `gammaFrom`, `chiSquared`, `chiSquaredFrom`, `erlang`,
  `erlangFrom`, `beta`, `betaFrom`, `fisherF`, `fisherFFrom`, `studentT`,
  `studentTFrom`
- `triangular`, `triangularFrom`, `arcsine`, `arcsineFrom`,
  `cauchy`, `cauchyFrom`, `laplace`, `laplaceFrom`, `logistic`,
  `logisticFrom`, `logLogistic`, `logLogisticFrom`, `kumaraswamy`,
  `kumaraswamyFrom`, `powerFunction`, `powerFunctionFrom`, `rayleigh`, `rayleighFrom`, `maxwell`, `maxwellFrom`,
  `pareto`, `paretoFrom`, `weibull`, `weibullFrom`
- `gumbel`, `gumbelFrom`, `frechet`, `frechetFrom`, `skewNormal`,
  `skewNormalFrom`, `pert`, `pertFrom`
- `inverseGaussian`, `normalInverseGaussian`, `normalInverseGaussianFrom`,
  `zipf`, `zipfFrom`, `zeta`, `zetaFrom`
- `unitCircle`, `unitCircleFrom`, `fillUnitCircle`, `fillUnitCircleFrom`,
  `unitDisc`, `unitDiscFrom`, `fillUnitDisc`, `fillUnitDiscFrom`,
  `unitSphere`, `unitSphereFrom`, `fillUnitSphere`, `fillUnitSphereFrom`,
  `unitBall`, `unitBallFrom`, `fillUnitBall`, `fillUnitBallFrom`

Reusable samplers:

- `Bernoulli`
- `Bernoulli.sampleFrom`
- `Binomial`
- `Binomial.sampleFrom`
- `Multinomial`
- `Multinomial.sampleIntoFrom`
- `NegativeBinomial`
- `NegativeBinomial.sampleFrom`
- `Hypergeometric`
- `Hypergeometric.sampleFrom`
- `Uniform(T)`
- `Uniform(T).sampleFrom`
- `Open01`
- `Open01.sampleFrom`
- `OpenClosed01`
- `OpenClosed01.sampleFrom`
- `StandardNormal(T)`
- `StandardNormal(T).sampleFrom`
- `Normal(T)`
- `Normal(T).sampleFrom`
- `StandardExponential(T)`
- `StandardExponential(T).sampleFrom`
- `Exponential(T)`
- `Exponential(T).sampleFrom`
- `LogNormal(T)`
- `LogNormal(T).sampleFrom`
- `HalfNormal(T)`
- `HalfNormal(T).sampleFrom`
- `Poisson`
- `Poisson.sampleFrom`
- `Geometric`
- `Geometric.sampleFrom`
- `Gamma(T)`
- `Gamma(T).sampleFrom`
- `ChiSquared(T)`
- `ChiSquared(T).sampleFrom`
- `Chi(T)`
- `Chi(T).sampleFrom`
- `Erlang(T)`
- `Erlang(T).sampleFrom`
- `Beta(T)`
- `Beta(T).sampleFrom`
- `FisherF(T)`
- `FisherF(T).sampleFrom`
- `StudentT(T)`
- `StudentT(T).sampleFrom`
- `Triangular(T)`
- `Triangular(T).sampleFrom`
- `Arcsine(T)`
- `Arcsine(T).sampleFrom`
- `Cauchy(T)`
- `Cauchy(T).sampleFrom`
- `Laplace(T)`
- `Laplace(T).sampleFrom`
- `Logistic(T)`
- `Logistic(T).sampleFrom`
- `LogLogistic(T)`
- `LogLogistic(T).sampleFrom`
- `Kumaraswamy(T)`
- `Kumaraswamy(T).sampleFrom`
- `PowerFunction(T)`
- `PowerFunction(T).sampleFrom`
- `Rayleigh(T)`
- `Rayleigh(T).sampleFrom`
- `Maxwell(T)`
- `Maxwell(T).sampleFrom`
- `Pareto(T)`
- `Pareto(T).sampleFrom`
- `Weibull(T)`
- `Weibull(T).sampleFrom`
- `Gumbel(T)`
- `Gumbel(T).sampleFrom`
- `Frechet(T)`
- `Frechet(T).sampleFrom`
- `SkewNormal(T)`
- `SkewNormal(T).sampleFrom`
- `Pert(T)`
- `Pert(T).sampleFrom`
- `InverseGaussian(T)`
- `InverseGaussian(T).sampleFrom`
- `NormalInverseGaussian(T)`
- `NormalInverseGaussian(T).sampleFrom`
- `Zipf(T)`
- `Zipf(T).sampleFrom`
- `Zeta(T)`
- `Zeta(T).sampleFrom`
- `UnitCircle(T)`
- `UnitCircle(T).sampleFrom`
- `UnitCircle(T).fill`
- `UnitCircle(T).fillFrom`
- `UnitDisc(T)`
- `UnitDisc(T).sampleFrom`
- `UnitDisc(T).fill`
- `UnitDisc(T).fillFrom`
- `UnitSphere(T)`
- `UnitSphere(T).sampleFrom`
- `UnitSphere(T).fill`
- `UnitSphere(T).fillFrom`
- `UnitBall(T)`
- `UnitBall(T).sampleFrom`
- `UnitBall(T).fill`
- `UnitBall(T).fillFrom`
- `Dirichlet(T)`
- `Dirichlet(T).sampleIntoFrom`
- `AliasTable(Weight)`
- `WeightedTree(Weight)`
- `WeightedIntTree(Weight)`

Alias helpers:

- `aliasTable(T)`
- `AliasTable.init`
- `AliasTable.update`
- `AliasTable.sample`
- `AliasTable.sampleFrom`
- `AliasTable.deinit`

Dynamic weighted helpers:

- `WeightedTree.init`
- `WeightedTree.push`
- `WeightedTree.pop`
- `WeightedTree.update`
- `WeightedTree.get`
- `WeightedTree.sample`
- `WeightedTree.sampleChecked`
- `WeightedTree.sampleFrom`
- `WeightedTree.sampleCheckedFrom`
- `WeightedTree.totalWeight`
- `WeightedTree.isValid`
- `WeightedTree.deinit`
- `WeightedIntTree.init`
- `WeightedIntTree.update`
- `WeightedIntTree.get`
- `WeightedIntTree.sample`
- `WeightedIntTree.sampleChecked`
- `WeightedIntTree.sampleFrom`
- `WeightedIntTree.sampleCheckedFrom`
- `WeightedIntTree.totalWeight`
- `WeightedIntTree.deinit`

## Sequence Sampling

- Index vectors: `IndexVec.len`, `IndexVec.at`, `IndexVec.deinit`
- Indices: `sampleIndexVec`, `sampleIndexVecFrom`, `sampleIndices`,
  `sampleIndicesFrom`, `sampleIndicesU32`, `sampleIndicesU32From`,
  `sampleArray`
- Collections: `chooseMultiple`, `partialShuffle`, `reservoirSample`
- Iterators: `chooseIterator`, `sampleIterator`, `chooseIteratorWeighted`,
  `sampleIteratorWeighted`
- Reusable samplers: `Choice(T)`, `chooseIter`, `WeightedChoice(T, Weight)`,
  `WeightedChoice.sample`, `WeightedChoice.sampleFrom`,
  `WeightedChoice.sampleValue`, `WeightedChoice.sampleValueFrom`
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
