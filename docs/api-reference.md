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
  `scalar`, `scalarSecure`, `hash`, `hashSecure`, `reproducible`, `reproducibleSecure`,
  `secureFromSeed`, `secure`, `secureBytes`, `rng`

## Rng

- Error type: `Error`
- Construction and interop: `init`, `fromRandom`, `random`
- Values: `value`, `valueFrom`, `valueIter`, `valueIterFrom`, `randomIter`,
  `randomIterFrom`, `sampleIter`, `sampleIterFrom`
- Bytes/fill: `bytes`, `fill` and `fillFrom` for scalar and vector slices,
  `fillSample`, `fillSampleFrom`, `fillRange`, `fillRangeFrom`,
  `fillRangeChecked`, `fillRangeCheckedFrom`, `fillOpen`,
  `fillOpenFrom`, `fillOpenClosed`, `fillOpenClosedFrom`, `fillChance`,
  `fillChanceChecked`, `fillChanceCheckedFrom`, `fillRatio`,
  `fillRatioChecked`, `fillRatioCheckedFrom`, `fillNormal`, `fillNormalChecked`,
  `fillNormalCheckedFrom`, `fillExponential`, `fillExponentialChecked`,
  `fillExponentialCheckedFrom`, `fillVectorRange`,
  `fillVectorOpen`, `fillVectorOpenClosed`, `fillVectorRangeChecked`,
  `fillVectorRangeCheckedFrom`, `fillVectorChance`, `fillVectorChanceChecked`,
  `fillVectorRatio`, `fillVectorRatioChecked`, `fillVectorStandardNormal`,
  `fillVectorStandardNormalFrom`, `fillVectorNormal`,
  `fillVectorChanceCheckedFrom`, `fillVectorRatioCheckedFrom`,
  `fillVectorNormalChecked`, `fillVectorNormalCheckedFrom`,
  `fillVectorExponential`, `fillVectorExponentialChecked`,
  `fillVectorExponentialCheckedFrom`, `fillNormalFrom`,
  `fillExponentialFrom`, `fillChanceFrom`, `fillRatioFrom`, `fillVectorFrom`,
  `fillVectorOpenFrom`, `fillVectorOpenClosedFrom`, `fillVectorRangeFrom`,
  `fillVectorChanceFrom`, `fillVectorRatioFrom`, `fillVectorNormalFrom`,
  `fillVectorStandardExponential`, `fillVectorStandardExponentialFrom`,
  `fillVectorExponentialFrom`
- Raw/scalars: `next`, `nextFrom`, `boolean`, `booleanFrom`, `chance`, `chanceChecked`, `ratio`,
  `chanceFrom`, `chanceCheckedFrom`, `ratioFrom`, `ratioChecked`,
  `ratioCheckedFrom`, `uint`, `uintLessThan`, `uintLessThanChecked`,
  `uintLessThanCheckedFrom`, `uintAtMost`, `uintFrom`, `uintLessThanFrom`, `uintAtMostFrom`,
  `probabilityThreshold`
- Ranges: `intRangeLessThan`, `intRangeLessThanChecked`, `intRangeAtMost`,
  `intRangeLessThanCheckedFrom`, `intRangeAtMostChecked`,
  `intRangeAtMostCheckedFrom`, `intRangeLessThanFrom`, `intRangeAtMostFrom`,
  `floatRange`, `floatRangeFrom`, `floatRangeChecked`, `floatRangeCheckedFrom`, `durationRangeLessThan`,
  `durationRangeLessThanFrom`, `durationRangeAtMost`, `durationRangeAtMostFrom`,
  `durationRangeLessThanChecked`, `durationRangeLessThanCheckedFrom`,
  `durationRangeAtMostChecked`, `durationRangeAtMostCheckedFrom`
- Floats: `float`, `floatFrom`, `floatOpen`, `floatOpenFrom`,
  `floatOpenClosed`, `floatOpenClosedFrom`
- Vectors: `vector`, `vectorOpen`, `vectorOpenClosed`, `vectorRange`,
  `vectorRangeChecked`, `vectorRangeCheckedFrom`, `vectorChance`,
  `vectorChanceChecked`, `vectorChanceCheckedFrom`, `vectorRatio`,
  `vectorRatioChecked`, `vectorRatioCheckedFrom`,
  `vectorStandardNormal`, `vectorNormal`, `vectorNormalChecked`,
  `vectorStandardExponential`, `vectorExponential`, `vectorExponentialChecked`,
  `vectorFrom`, `vectorOpenFrom`, `vectorOpenClosedFrom`,
  `vectorRangeFrom`, `vectorChanceFrom`, `vectorRatioFrom`,
  `vectorStandardNormalFrom`, `vectorNormalFrom`, `vectorNormalCheckedFrom`,
  `vectorStandardExponentialFrom`, `vectorExponentialFrom`,
  `vectorExponentialCheckedFrom`
- Unicode: `unicodeScalar`, `unicodeScalarFrom`
- Distributions: `normal`, `exponential`, `standardNormalFastFrom`,
  `standardExponentialFastFrom`, `normalFastFrom`, `exponentialFastFrom`
- Enums and collections: `enumValue`, `enumValueFrom`, `shuffle`, `shuffleFrom`, `choose`,
  `chooseFrom`, `choosePtr`, `choosePtrFrom`, `weightedIndex`,
  `weightedIndexFrom`, `weightedIndexChecked`, `weightedIndexCheckedFrom`,
  `sampleWithoutReplacement`, `sampleWithoutReplacementFrom`,
  `sampleWithoutReplacementChecked`, `sampleWithoutReplacementCheckedFrom`
- Iterator types: `ValueIterator(T)`, `ValueIteratorFrom(Source, T)`,
  `ValueIterator.nextValue`, `SampleIterator(Sampler, T)`,
  `SampleIterator.nextValue`, `SampleIteratorFrom(Source, Sampler, T)`

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

- Error type: `Error`

Single-shot helpers:

- `uniform`, `uniformFrom`, `uniformInclusive`, `uniformInclusiveFrom`
- `bernoulli`, `fillBernoulli`, `fillBernoulliFrom`, `binomial`,
  `binomialFrom`, `fillBinomial`, `fillBinomialFrom`,
  `binomialPoissonApprox`
- `negativeBinomial`, `negativeBinomialFrom`, `fillNegativeBinomial`,
  `fillNegativeBinomialFrom`, `hypergeometric`, `hypergeometricFrom`,
  `fillHypergeometric`, `fillHypergeometricFrom`
- `standardNormal`, `standardNormalFrom`, `fillStandardNormal`,
  `fillStandardNormalFrom`, `normal`, `logNormal`,
  `logNormalFrom`, `fillLogNormal`, `fillLogNormalFrom`, `halfNormal`,
  `halfNormalFrom`, `fillHalfNormal`, `fillHalfNormalFrom`, `chi`, `chiFrom`,
  `standardExponential`, `standardExponentialFrom`,
  `fillStandardExponential`, `fillStandardExponentialFrom`, `exponential`
- `poisson`, `fillPoisson`, `fillPoissonFrom`, `geometric`,
  `geometricFrom`, `fillGeometric`, `fillGeometricFrom`,
  `geometricFailures`, `geometricFailuresFrom`, `fillGeometricFailures`,
  `fillGeometricFailuresFrom`, `standardGeometric`,
  `standardGeometricFrom`, `fillStandardGeometric`,
  `fillStandardGeometricFrom`, `poissonAhrensDieter`,
  `poissonAhrensDieterFrom`
- `gamma`, `gammaFrom`, `fillGamma`, `fillGammaFrom`, `chiSquared`,
  `chiSquaredFrom`, `fillChiSquared`, `fillChiSquaredFrom`, `chi`,
  `chiFrom`, `fillChi`, `fillChiFrom`, `erlang`, `erlangFrom`,
  `fillErlang`, `fillErlangFrom`, `beta`, `betaFrom`, `fillBeta`,
  `fillBetaFrom`, `fisherF`, `fisherFFrom`, `fillFisherF`,
  `fillFisherFFrom`, `studentT`, `studentTFrom`, `fillStudentT`,
  `fillStudentTFrom`
- `triangular`, `triangularFrom`, `fillTriangular`, `fillTriangularFrom`,
  `arcsine`, `arcsineFrom`, `fillArcsine`, `fillArcsineFrom`,
  `cauchy`, `cauchyFrom`, `fillCauchy`, `fillCauchyFrom`, `laplace`, `laplaceFrom`, `fillLaplace`,
  `fillLaplaceFrom`, `logistic`, `logisticFrom`, `fillLogistic`,
  `fillLogisticFrom`, `logLogistic`, `logLogisticFrom`,
  `fillLogLogistic`, `fillLogLogisticFrom`, `kumaraswamy`,
  `kumaraswamyFrom`, `fillKumaraswamy`, `fillKumaraswamyFrom`,
  `powerFunction`, `powerFunctionFrom`, `fillPowerFunction`,
  `fillPowerFunctionFrom`, `rayleigh`, `rayleighFrom`, `fillRayleigh`,
  `fillRayleighFrom`, `maxwell`, `maxwellFrom`, `fillMaxwell`,
  `fillMaxwellFrom`,
  `pareto`, `paretoFrom`, `fillPareto`, `fillParetoFrom`, `weibull`,
  `weibullFrom`, `fillWeibull`, `fillWeibullFrom`
- `gumbel`, `gumbelFrom`, `fillGumbel`, `fillGumbelFrom`,
  `frechet`, `frechetFrom`, `fillFrechet`, `fillFrechetFrom`,
  `skewNormal`, `skewNormalFrom`, `fillSkewNormal`, `fillSkewNormalFrom`,
  `pert`, `pertFrom`, `fillPert`, `fillPertFrom`
- `inverseGaussian`, `inverseGaussianFrom`, `fillInverseGaussian`,
  `fillInverseGaussianFrom`,
  `normalInverseGaussian`, `normalInverseGaussianFrom`,
  `fillNormalInverseGaussian`, `fillNormalInverseGaussianFrom`,
  `zipf`, `zipfFrom`, `zeta`, `zetaFrom`
- `unitCircle`, `unitCircleFrom`, `fillUnitCircle`, `fillUnitCircleFrom`,
  `unitDisc`, `unitDiscFrom`, `fillUnitDisc`, `fillUnitDiscFrom`,
  `unitSphere`, `unitSphereFrom`, `fillUnitSphere`, `fillUnitSphereFrom`,
  `unitBall`, `unitBallFrom`, `fillUnitBall`, `fillUnitBallFrom`

Reusable samplers:

- `Bernoulli`
- `Bernoulli.initRatio`
- `Bernoulli.probability`
- `Bernoulli.sampleFrom`
- `Bernoulli.fill`
- `Bernoulli.fillFrom`
- `Binomial`
- `Binomial.sampleFrom`
- `Binomial.fill`
- `Binomial.fillFrom`
- `Multinomial`
- `Multinomial.sampleInto`
- `Multinomial.sampleIntoFrom`
- `Multinomial.sampleManyInto`
- `Multinomial.sampleManyIntoFrom`
- `NegativeBinomial`
- `NegativeBinomial.sampleFrom`
- `NegativeBinomial.fill`
- `NegativeBinomial.fillFrom`
- `Hypergeometric`
- `Hypergeometric.sampleFrom`
- `Hypergeometric.fill`
- `Hypergeometric.fillFrom`
- `Uniform(T)`
- `Uniform(T).initInclusive`
- `Uniform(T).sampleFrom`
- `Uniform(T).fill`
- `Uniform(T).fillFrom`
- `Open01`
- `Open01.sample`
- `Open01.sampleFrom`
- `Open01.fill`
- `Open01.fillFrom`
- `OpenClosed01`
- `OpenClosed01.sample`
- `OpenClosed01.sampleFrom`
- `OpenClosed01.fill`
- `OpenClosed01.fillFrom`
- `StandardNormal(T)`
- `StandardNormal(T).sample`
- `StandardNormal(T).sampleFrom`
- `StandardNormal(T).fill`
- `StandardNormal(T).fillFrom`
- `Normal(T)`
- `Normal(T).sampleFrom`
- `Normal(T).fill`
- `Normal(T).fillFrom`
- `StandardExponential(T)`
- `StandardExponential(T).sample`
- `StandardExponential(T).sampleFrom`
- `StandardExponential(T).fill`
- `StandardExponential(T).fillFrom`
- `Exponential(T)`
- `Exponential(T).sampleFrom`
- `Exponential(T).fill`
- `Exponential(T).fillFrom`
- `LogNormal(T)`
- `LogNormal(T).sampleFrom`
- `LogNormal(T).fill`
- `LogNormal(T).fillFrom`
- `HalfNormal(T)`
- `HalfNormal(T).sampleFrom`
- `HalfNormal(T).fill`
- `HalfNormal(T).fillFrom`
- `Poisson`
- `Poisson.sampleFrom`
- `Poisson.fill`
- `Poisson.fillFrom`
- `Geometric`
- `Geometric.sampleFrom`
- `Geometric.fill`
- `Geometric.fillFrom`
- `GeometricFailures`
- `GeometricFailures.sampleFrom`
- `GeometricFailures.fill`
- `GeometricFailures.fillFrom`
- `StandardGeometric`
- `StandardGeometric.sample`
- `StandardGeometric.sampleFrom`
- `StandardGeometric.fill`
- `StandardGeometric.fillFrom`
- `Gamma(T)`
- `Gamma(T).sampleFrom`
- `Gamma(T).fill`
- `Gamma(T).fillFrom`
- `ChiSquared(T)`
- `ChiSquared(T).sampleFrom`
- `ChiSquared(T).fill`
- `ChiSquared(T).fillFrom`
- `Chi(T)`
- `Chi(T).sampleFrom`
- `Chi(T).fill`
- `Chi(T).fillFrom`
- `Erlang(T)`
- `Erlang(T).sampleFrom`
- `Erlang(T).fill`
- `Erlang(T).fillFrom`
- `Beta(T)`
- `Beta(T).sampleFrom`
- `Beta(T).fill`
- `Beta(T).fillFrom`
- `FisherF(T)`
- `FisherF(T).sampleFrom`
- `FisherF(T).fill`
- `FisherF(T).fillFrom`
- `StudentT(T)`
- `StudentT(T).sampleFrom`
- `StudentT(T).fill`
- `StudentT(T).fillFrom`
- `Triangular(T)`
- `Triangular(T).sampleFrom`
- `Triangular(T).fill`
- `Triangular(T).fillFrom`
- `Arcsine(T)`
- `Arcsine(T).sampleFrom`
- `Arcsine(T).fill`
- `Arcsine(T).fillFrom`
- `Cauchy(T)`
- `Cauchy(T).sampleFrom`
- `Cauchy(T).fill`
- `Cauchy(T).fillFrom`
- `Laplace(T)`
- `Laplace(T).sampleFrom`
- `Laplace(T).fill`
- `Laplace(T).fillFrom`
- `Logistic(T)`
- `Logistic(T).sampleFrom`
- `Logistic(T).fill`
- `Logistic(T).fillFrom`
- `LogLogistic(T)`
- `LogLogistic(T).sampleFrom`
- `LogLogistic(T).fill`
- `LogLogistic(T).fillFrom`
- `Kumaraswamy(T)`
- `Kumaraswamy(T).sampleFrom`
- `Kumaraswamy(T).fill`
- `Kumaraswamy(T).fillFrom`
- `PowerFunction(T)`
- `PowerFunction(T).sampleFrom`
- `PowerFunction(T).fill`
- `PowerFunction(T).fillFrom`
- `Rayleigh(T)`
- `Rayleigh(T).sampleFrom`
- `Rayleigh(T).fill`
- `Rayleigh(T).fillFrom`
- `Maxwell(T)`
- `Maxwell(T).sampleFrom`
- `Maxwell(T).fill`
- `Maxwell(T).fillFrom`
- `Pareto(T)`
- `Pareto(T).sampleFrom`
- `Pareto(T).fill`
- `Pareto(T).fillFrom`
- `Weibull(T)`
- `Weibull(T).sampleFrom`
- `Weibull(T).fill`
- `Weibull(T).fillFrom`
- `Gumbel(T)`
- `Gumbel(T).sampleFrom`
- `Gumbel(T).fill`
- `Gumbel(T).fillFrom`
- `Frechet(T)`
- `Frechet(T).sampleFrom`
- `Frechet(T).fill`
- `Frechet(T).fillFrom`
- `SkewNormal(T)`
- `SkewNormal(T).sampleFrom`
- `SkewNormal(T).fill`
- `SkewNormal(T).fillFrom`
- `Pert(T)`
- `Pert(T).initDefault`
- `Pert(T).initMean`
- `Pert(T).sampleFrom`
- `Pert(T).fill`
- `Pert(T).fillFrom`
- `InverseGaussian(T)`
- `InverseGaussian(T).sampleFrom`
- `InverseGaussian(T).fill`
- `InverseGaussian(T).fillFrom`
- `NormalInverseGaussian(T)`
- `NormalInverseGaussian(T).sampleFrom`
- `NormalInverseGaussian(T).fill`
- `NormalInverseGaussian(T).fillFrom`
- `Zipf(T)`
- `Zipf(T).sampleFrom`
- `Zipf(T).fill`
- `Zipf(T).fillFrom`
- `Zeta(T)`
- `Zeta(T).sampleFrom`
- `Zeta(T).fill`
- `Zeta(T).fillFrom`
- `UnitCircle(T)`
- `UnitCircle(T).sample`
- `UnitCircle(T).sampleFrom`
- `UnitCircle(T).fill`
- `UnitCircle(T).fillFrom`
- `UnitDisc(T)`
- `UnitDisc(T).sample`
- `UnitDisc(T).sampleFrom`
- `UnitDisc(T).fill`
- `UnitDisc(T).fillFrom`
- `UnitSphere(T)`
- `UnitSphere(T).sample`
- `UnitSphere(T).sampleFrom`
- `UnitSphere(T).fill`
- `UnitSphere(T).fillFrom`
- `UnitBall(T)`
- `UnitBall(T).sample`
- `UnitBall(T).sampleFrom`
- `UnitBall(T).fill`
- `UnitBall(T).fillFrom`
- `Dirichlet(T)`
- `Dirichlet(T).sampleInto`
- `Dirichlet(T).sampleIntoFrom`
- `Dirichlet(T).sampleManyInto`
- `Dirichlet(T).sampleManyIntoFrom`
- `AliasTable(Weight)`
- `WeightedTree(Weight)`
- `WeightedIntTree(Weight)`

Alias helpers:

- `aliasTable(T)`
- `AliasTable.init`
- `AliasTable.update`
- `AliasTable.sample`
- `AliasTable.sampleFrom`
- `AliasTable.fill`
- `AliasTable.fillFrom`
- `AliasTable.deinit`

Dynamic weighted helpers:

- `WeightedTree.init`
- `WeightedTree.len`
- `WeightedTree.isEmpty`
- `WeightedTree.push`
- `WeightedTree.pop`
- `WeightedTree.update`
- `WeightedTree.get`
- `WeightedTree.sample`
- `WeightedTree.sampleChecked`
- `WeightedTree.sampleFrom`
- `WeightedTree.sampleCheckedFrom`
- `WeightedTree.fill`
- `WeightedTree.fillChecked`
- `WeightedTree.fillFrom`
- `WeightedTree.fillCheckedFrom`
- `WeightedTree.totalWeight`
- `WeightedTree.isValid`
- `WeightedTree.deinit`
- Prefer `WeightedIntTree` when weights are unsigned integers and frequent
  update/sample throughput is the priority.
- `WeightedIntTree.init`
- `WeightedIntTree.len`
- `WeightedIntTree.update`
- `WeightedIntTree.get`
- `WeightedIntTree.sample`
- `WeightedIntTree.sampleChecked`
- `WeightedIntTree.sampleFrom`
- `WeightedIntTree.sampleCheckedFrom`
- `WeightedIntTree.fill`
- `WeightedIntTree.fillChecked`
- `WeightedIntTree.fillFrom`
- `WeightedIntTree.fillCheckedFrom`
- `WeightedIntTree.totalWeight`
- `WeightedIntTree.deinit`

## Sequence Sampling

- Error type: `Error`
- Index vectors: `IndexVec.len`, `IndexVec.at`, `IndexVec.deinit`
- Indices: `sampleIndexVec`, `sampleIndexVecFrom`, `sampleIndices`,
  `sampleIndexVecCheckedFrom`, `sampleIndicesFrom`, `sampleIndicesCheckedFrom`,
  `sampleIndicesU32`, `sampleIndicesU32From`, `sampleIndicesU32CheckedFrom`,
  `sampleArray`, `sampleArrayFrom`
- Collections: `chooseMultiple`, `chooseMultipleFrom`, `partialShuffle`,
  `partialShuffleFrom`, `reservoirSample`, `reservoirSampleFrom`
- Iterators: `chooseIterator`, `chooseIteratorFrom`, `sampleIterator`,
  `sampleIteratorFrom`, `chooseIteratorWeighted`,
  `chooseIteratorWeightedFrom`, `sampleIteratorWeighted`,
  `sampleIteratorWeightedFrom`
- Reusable samplers: `Choice(T)`, `chooseIter`, `chooseIterFrom`,
  `WeightedChoice(T, Weight)`,
  `Choice.len`, `Choice.sample`, `Choice.sampleFrom`, `Choice.sampleValue`,
  `Choice.sampleValueFrom`, `Choice.fill`, `Choice.fillFrom`,
  `Choice.fillValues`, `Choice.fillValuesFrom`, `Choice.iter`,
  `Choice.iterFrom`,
  `WeightedChoice.deinit`, `WeightedChoice.len`, `WeightedChoice.sample`,
  `WeightedChoice.sampleFrom`,
  `WeightedChoice.sampleValue`, `WeightedChoice.sampleValueFrom`,
  `WeightedChoice.fill`, `WeightedChoice.fillFrom`,
  `WeightedChoice.fillValues`, `WeightedChoice.fillValuesFrom`,
  `WeightedChoice.iter`, `WeightedChoice.iterFrom`
- Weighted no-replacement: `sampleWeightedIndices`,
  `sampleWeightedIndicesFrom`, `sampleWeighted`, `sampleWeightedFrom`

## ASCII And Unicode

- Charset constants: `Alphanumeric`, `Alphabetic`, `Lowercase`, `Uppercase`,
  `Digits`
- Raw charset byte sets: `alphanumeric`, `alphabetic`, `lowercase`,
  `uppercase`, `digits`
- Charset type: `Charset.init`, `Charset.initChecked`, `Charset.sample`,
  `Charset.sampleFrom`, `Charset.fill`, `Charset.fillFrom`, `Charset.alloc`,
  `Charset.allocFrom`
- Helpers: `char`, `charFrom`, `string`, `stringFrom`, `unicodeScalar`,
  `unicodeScalarFrom`, `unicodeUtf8Alloc`, `unicodeUtf8AllocFrom`

## Validation And Tooling

Build steps:

- `zig build test`
- `zig build run-basic`
- `zig build apicheck`
- `zig build statcheck`
- `zig build distcheck`
- `zig build stream -- --engine <engine> --bytes <n>`
- `zig build repro`
- `zig build -Doptimize=ReleaseFast -Dcpu=native bench`
- `zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench`
- `zig build -Doptimize=ReleaseFast -Dcpu=native ziggurat-probe`
- `zig build -Doptimize=ReleaseFast -Dcpu=native cauchy-probe`

Tools:

- `tools/statcheck.zig`
- `tools/apicheck.zig`
- `tools/distcheck.zig`
- `tools/stream.zig`
- `tools/ziggurat_probe.zig`
- `tools/cauchy_probe.zig`
- `tools/repro.zig`
- `tools/practrand.sh`
