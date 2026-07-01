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
- Values: `value`, `valueFrom`, `valueChecked`, `valueCheckedFrom`,
  `valueIter`, `valueIterFrom`, `randomIter`, `randomIterFrom`, `sampleIter`,
  `sampleIterFrom`
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
- Distributions: `normal`, `normalChecked`, `normalCheckedFrom`, `exponential`,
  `exponentialChecked`, `exponentialCheckedFrom`, `standardNormalFastFrom`,
  `standardExponentialFastFrom`, `normalFastFrom`, `exponentialFastFrom`
- Enums and collections: `enumValue`, `enumValueFrom`, `enumValueChecked`,
  `enumValueCheckedFrom`, `shuffle`, `shuffleFrom`, `choose`,
  `chooseFrom`, `chooseChecked`, `chooseCheckedFrom`, `choosePtr`,
  `choosePtrFrom`, `choosePtrChecked`, `choosePtrCheckedFrom`, `weightedIndex`,
  `weightedIndexFrom`, `weightedIndexChecked`, `weightedIndexCheckedFrom`,
  `sampleWithoutReplacement`, `sampleWithoutReplacementFrom`,
  `sampleWithoutReplacementChecked`, `sampleWithoutReplacementCheckedFrom`
- Iterator types: `ValueIterator(T)`, `ValueIteratorFrom(Source, T)`,
  `ValueIterator.next`, `ValueIterator.nextValue`, `ValueIterator.fill`,
  `ValueIteratorFrom.next`, `ValueIteratorFrom.nextValue`,
  `ValueIteratorFrom.fill`, `SampleIterator(Sampler, T)`,
  `SampleIterator.next`, `SampleIterator.nextValue`, `SampleIterator.fill`,
  `SampleIteratorFrom(Source, Sampler, T)`, `SampleIteratorFrom.next`,
  `SampleIteratorFrom.nextValue`, `SampleIteratorFrom.fill`

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

- `uniform`, `uniformFrom`, `uniformChecked`, `uniformCheckedFrom`,
  `uniformInclusive`, `uniformInclusiveFrom`, `uniformInclusiveChecked`,
  `uniformInclusiveCheckedFrom`, `fillUniform`, `fillUniformFrom`,
  `fillUniformChecked`, `fillUniformCheckedFrom`, `fillUniformInclusive`,
  `fillUniformInclusiveFrom`, `fillUniformInclusiveChecked`,
  `fillUniformInclusiveCheckedFrom`
- `bernoulli`, `bernoulliFrom`, `bernoulliChecked`,
  `bernoulliCheckedFrom`, `fillBernoulli`, `fillBernoulliFrom`,
  `fillBernoulliChecked`, `fillBernoulliCheckedFrom`, `binomial`,
  `binomialFrom`, `binomialChecked`, `binomialCheckedFrom`, `fillBinomial`, `fillBinomialFrom`,
  `fillBinomialChecked`, `fillBinomialCheckedFrom`,
  `binomialPoissonApprox`, `binomialPoissonApproxFrom`,
  `binomialPoissonApproxChecked`, `binomialPoissonApproxCheckedFrom`
- `negativeBinomial`, `negativeBinomialFrom`, `negativeBinomialChecked`,
  `negativeBinomialCheckedFrom`, `fillNegativeBinomial`,
  `fillNegativeBinomialFrom`, `fillNegativeBinomialChecked`,
  `fillNegativeBinomialCheckedFrom`, `hypergeometric`, `hypergeometricFrom`,
  `hypergeometricChecked`, `hypergeometricCheckedFrom`,
  `fillHypergeometric`, `fillHypergeometricFrom`,
  `fillHypergeometricChecked`, `fillHypergeometricCheckedFrom`
- `standardNormal`, `standardNormalFrom`, `fillStandardNormal`,
  `fillStandardNormalFrom`, `normal`, `normalFrom`, `normalChecked`,
  `normalCheckedFrom`, `fillNormal`, `fillNormalFrom`, `fillNormalChecked`,
  `fillNormalCheckedFrom`, `logNormal`, `logNormalFrom`, `logNormalChecked`,
  `logNormalCheckedFrom`, `fillLogNormal`, `fillLogNormalFrom`,
  `fillLogNormalChecked`, `fillLogNormalCheckedFrom`, `halfNormal`,
  `halfNormalFrom`, `halfNormalChecked`, `halfNormalCheckedFrom`,
  `fillHalfNormal`, `fillHalfNormalFrom`, `fillHalfNormalChecked`,
  `fillHalfNormalCheckedFrom`, `chi`, `chiFrom`,
  `standardExponential`, `standardExponentialFrom`,
  `fillStandardExponential`, `fillStandardExponentialFrom`, `exponential`,
  `exponentialFrom`, `exponentialChecked`, `exponentialCheckedFrom`,
  `fillExponential`, `fillExponentialFrom`, `fillExponentialChecked`,
  `fillExponentialCheckedFrom`
- `poisson`, `poissonFrom`, `poissonChecked`, `poissonCheckedFrom`,
  `fillPoisson`, `fillPoissonFrom`, `fillPoissonChecked`,
  `fillPoissonCheckedFrom`, `geometric`,
  `geometricFrom`, `geometricChecked`, `geometricCheckedFrom`,
  `fillGeometric`, `fillGeometricFrom`, `fillGeometricChecked`,
  `fillGeometricCheckedFrom`,
  `geometricFailures`, `geometricFailuresFrom`, `geometricFailuresChecked`,
  `geometricFailuresCheckedFrom`, `fillGeometricFailures`,
  `fillGeometricFailuresFrom`, `fillGeometricFailuresChecked`,
  `fillGeometricFailuresCheckedFrom`, `standardGeometric`,
  `standardGeometricFrom`, `fillStandardGeometric`,
  `fillStandardGeometricFrom`, `poissonAhrensDieter`,
  `poissonAhrensDieterFrom`, `poissonAhrensDieterChecked`,
  `poissonAhrensDieterCheckedFrom`
- `gamma`, `gammaFrom`, `gammaChecked`, `gammaCheckedFrom`, `fillGamma`,
  `fillGammaFrom`, `fillGammaChecked`, `fillGammaCheckedFrom`, `chiSquared`,
  `chiSquaredFrom`, `chiSquaredChecked`, `chiSquaredCheckedFrom`,
  `fillChiSquared`, `fillChiSquaredFrom`, `fillChiSquaredChecked`,
  `fillChiSquaredCheckedFrom`, `chi`, `chiFrom`, `chiChecked`,
  `chiCheckedFrom`, `fillChi`, `fillChiFrom`, `fillChiChecked`,
  `fillChiCheckedFrom`, `erlang`, `erlangFrom`, `erlangChecked`,
  `erlangCheckedFrom`, `fillErlang`, `fillErlangFrom`,
  `fillErlangChecked`, `fillErlangCheckedFrom`, `beta`, `betaFrom`,
  `betaChecked`, `betaCheckedFrom`, `fillBeta`, `fillBetaFrom`,
  `fillBetaChecked`, `fillBetaCheckedFrom`, `fisherF`, `fisherFFrom`,
  `fisherFChecked`, `fisherFCheckedFrom`, `fillFisherF`,
  `fillFisherFFrom`, `fillFisherFChecked`, `fillFisherFCheckedFrom`,
  `studentT`, `studentTFrom`, `studentTChecked`, `studentTCheckedFrom`,
  `fillStudentT`, `fillStudentTFrom`, `fillStudentTChecked`,
  `fillStudentTCheckedFrom`
- `triangular`, `triangularFrom`, `triangularChecked`,
  `triangularCheckedFrom`, `fillTriangular`, `fillTriangularFrom`,
  `fillTriangularChecked`, `fillTriangularCheckedFrom`, `arcsine`,
  `arcsineFrom`, `arcsineChecked`, `arcsineCheckedFrom`,
  `fillArcsine`, `fillArcsineFrom`, `fillArcsineChecked`,
  `fillArcsineCheckedFrom`,
  `cauchy`, `cauchyFrom`, `cauchyChecked`, `cauchyCheckedFrom`,
  `fillCauchy`, `fillCauchyFrom`, `fillCauchyChecked`,
  `fillCauchyCheckedFrom`, `laplace`, `laplaceFrom`,
  `laplaceChecked`, `laplaceCheckedFrom`, `fillLaplace`, `fillLaplaceFrom`,
  `fillLaplaceChecked`, `fillLaplaceCheckedFrom`,
  `logistic`, `logisticFrom`, `logisticChecked`,
  `logisticCheckedFrom`, `fillLogistic`, `fillLogisticChecked`,
  `fillLogisticFrom`, `fillLogisticCheckedFrom`,
  `logLogistic`, `logLogisticFrom`,
  `logLogisticChecked`, `logLogisticCheckedFrom`,
  `fillLogLogistic`, `fillLogLogisticFrom`, `fillLogLogisticChecked`,
  `fillLogLogisticCheckedFrom`, `kumaraswamy`,
  `kumaraswamyFrom`, `kumaraswamyChecked`, `kumaraswamyCheckedFrom`,
  `fillKumaraswamy`, `fillKumaraswamyFrom`, `fillKumaraswamyChecked`,
  `fillKumaraswamyCheckedFrom`,
  `powerFunction`, `powerFunctionFrom`, `powerFunctionChecked`,
  `powerFunctionCheckedFrom`, `fillPowerFunction`,
  `fillPowerFunctionFrom`, `fillPowerFunctionChecked`,
  `fillPowerFunctionCheckedFrom`, `rayleigh`, `rayleighFrom`, `rayleighChecked`,
  `rayleighCheckedFrom`, `fillRayleigh`,
  `fillRayleighFrom`, `fillRayleighChecked`, `fillRayleighCheckedFrom`,
  `maxwell`, `maxwellFrom`, `maxwellChecked`,
  `maxwellCheckedFrom`, `fillMaxwell`,
  `fillMaxwellFrom`, `fillMaxwellChecked`, `fillMaxwellCheckedFrom`,
  `pareto`, `paretoFrom`, `paretoChecked`, `paretoCheckedFrom`,
  `fillPareto`, `fillParetoFrom`, `fillParetoChecked`,
  `fillParetoCheckedFrom`, `weibull`, `weibullFrom`,
  `weibullChecked`, `weibullCheckedFrom`, `fillWeibull`, `fillWeibullFrom`,
  `fillWeibullChecked`, `fillWeibullCheckedFrom`
- `gumbel`, `gumbelFrom`, `fillGumbel`, `fillGumbelFrom`,
  `fillGumbelChecked`, `fillGumbelCheckedFrom`,
  `gumbelChecked`, `gumbelCheckedFrom`,
  `frechet`, `frechetFrom`, `frechetChecked`, `frechetCheckedFrom`,
  `fillFrechet`, `fillFrechetFrom`, `fillFrechetChecked`,
  `fillFrechetCheckedFrom`,
  `skewNormal`, `skewNormalFrom`, `skewNormalChecked`,
  `skewNormalCheckedFrom`, `fillSkewNormal`, `fillSkewNormalFrom`,
  `fillSkewNormalChecked`, `fillSkewNormalCheckedFrom`,
  `pert`, `pertFrom`, `pertChecked`, `pertCheckedFrom`, `fillPert`,
  `fillPertFrom`, `fillPertChecked`, `fillPertCheckedFrom`
- `inverseGaussian`, `inverseGaussianFrom`, `inverseGaussianChecked`,
  `inverseGaussianCheckedFrom`, `fillInverseGaussian`, `fillInverseGaussianFrom`,
  `fillInverseGaussianChecked`, `fillInverseGaussianCheckedFrom`,
  `normalInverseGaussian`, `normalInverseGaussianFrom`,
  `normalInverseGaussianChecked`, `normalInverseGaussianCheckedFrom`,
  `fillNormalInverseGaussian`, `fillNormalInverseGaussianFrom`,
  `fillNormalInverseGaussianChecked`, `fillNormalInverseGaussianCheckedFrom`,
  `zipf`, `zipfFrom`, `zipfChecked`, `zipfCheckedFrom`, `fillZipf`,
  `fillZipfFrom`, `fillZipfChecked`, `fillZipfCheckedFrom`, `zeta`,
  `zetaFrom`, `zetaChecked`, `zetaCheckedFrom`, `fillZeta`, `fillZetaFrom`,
  `fillZetaChecked`, `fillZetaCheckedFrom`
- `unitCircle`, `unitCircleFrom`, `fillUnitCircle`, `fillUnitCircleFrom`,
  `unitDisc`, `unitDiscFrom`, `fillUnitDisc`, `fillUnitDiscFrom`,
  `unitSphere`, `unitSphereFrom`, `fillUnitSphere`, `fillUnitSphereFrom`,
  `unitBall`, `unitBallFrom`, `fillUnitBall`, `fillUnitBallFrom`

Reusable samplers:

- `Bernoulli`
- `Bernoulli.init`
- `Bernoulli.initRatio`
- `Bernoulli.probability`
- `Bernoulli.sample`
- `Bernoulli.sampleFrom`
- `Bernoulli.fill`
- `Bernoulli.fillFrom`
- `Binomial`
- `Binomial.init`
- `Binomial.sample`
- `Binomial.sampleFrom`
- `Binomial.fill`
- `Binomial.fillFrom`
- `Multinomial`
- `Multinomial.init`
- `Multinomial.sample`
- `Multinomial.sampleFrom`
- `Multinomial.sampleInto`
- `Multinomial.sampleIntoFrom`
- `Multinomial.sampleIntoChecked`
- `Multinomial.sampleIntoCheckedFrom`
- `Multinomial.sampleManyInto`
- `Multinomial.sampleManyIntoFrom`
- `Multinomial.sampleManyIntoChecked`
- `Multinomial.sampleManyIntoCheckedFrom`
- `NegativeBinomial`
- `NegativeBinomial.init`
- `NegativeBinomial.sample`
- `NegativeBinomial.sampleFrom`
- `NegativeBinomial.fill`
- `NegativeBinomial.fillFrom`
- `Hypergeometric`
- `Hypergeometric.init`
- `Hypergeometric.sample`
- `Hypergeometric.sampleFrom`
- `Hypergeometric.fill`
- `Hypergeometric.fillFrom`
- `Uniform(T)`
- `Uniform(T).init`
- `Uniform(T).initInclusive`
- `Uniform(T).sample`
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
- `Normal(T).init`
- `Normal(T).initMeanCv`
- `Normal(T).fromZScore`
- `Normal(T).meanValue`
- `Normal(T).stddevValue`
- `Normal(T).sample`
- `Normal(T).sampleFrom`
- `Normal(T).fill`
- `Normal(T).fillFrom`
- `StandardExponential(T)`
- `StandardExponential(T).sample`
- `StandardExponential(T).sampleFrom`
- `StandardExponential(T).fill`
- `StandardExponential(T).fillFrom`
- `Exponential(T)`
- `Exponential(T).init`
- `Exponential(T).rateValue`
- `Exponential(T).inverseRateValue`
- `Exponential(T).sample`
- `Exponential(T).sampleFrom`
- `Exponential(T).fill`
- `Exponential(T).fillFrom`
- `LogNormal(T)`
- `LogNormal(T).init`
- `LogNormal(T).initMeanCv`
- `LogNormal(T).fromZScore`
- `LogNormal(T).logMean`
- `LogNormal(T).logStddev`
- `LogNormal(T).sample`
- `LogNormal(T).sampleFrom`
- `LogNormal(T).fill`
- `LogNormal(T).fillFrom`
- `HalfNormal(T)`
- `HalfNormal(T).init`
- `HalfNormal(T).scaleValue`
- `HalfNormal(T).sample`
- `HalfNormal(T).sampleFrom`
- `HalfNormal(T).fill`
- `HalfNormal(T).fillFrom`
- `Poisson`
- `Poisson.init`
- `Poisson.sample`
- `Poisson.sampleFrom`
- `Poisson.fill`
- `Poisson.fillFrom`
- `Geometric`
- `Geometric.init`
- `Geometric.sample`
- `Geometric.sampleFrom`
- `Geometric.fill`
- `Geometric.fillFrom`
- `GeometricFailures`
- `GeometricFailures.init`
- `GeometricFailures.sample`
- `GeometricFailures.sampleFrom`
- `GeometricFailures.fill`
- `GeometricFailures.fillFrom`
- `StandardGeometric`
- `StandardGeometric.sample`
- `StandardGeometric.sampleFrom`
- `StandardGeometric.fill`
- `StandardGeometric.fillFrom`
- `Gamma(T)`
- `Gamma(T).init`
- `Gamma(T).shapeValue`
- `Gamma(T).scaleValue`
- `Gamma(T).sample`
- `Gamma(T).sampleFrom`
- `Gamma(T).fill`
- `Gamma(T).fillFrom`
- `ChiSquared(T)`
- `ChiSquared(T).init`
- `ChiSquared(T).dofValue`
- `ChiSquared(T).sample`
- `ChiSquared(T).sampleFrom`
- `ChiSquared(T).fill`
- `ChiSquared(T).fillFrom`
- `Chi(T)`
- `Chi(T).init`
- `Chi(T).dofValue`
- `Chi(T).sample`
- `Chi(T).sampleFrom`
- `Chi(T).fill`
- `Chi(T).fillFrom`
- `Erlang(T)`
- `Erlang(T).init`
- `Erlang(T).shapeValue`
- `Erlang(T).scaleValue`
- `Erlang(T).sample`
- `Erlang(T).sampleFrom`
- `Erlang(T).fill`
- `Erlang(T).fillFrom`
- `Beta(T)`
- `Beta(T).init`
- `Beta(T).alphaValue`
- `Beta(T).betaValue`
- `Beta(T).sample`
- `Beta(T).sampleFrom`
- `Beta(T).fill`
- `Beta(T).fillFrom`
- `FisherF(T)`
- `FisherF(T).init`
- `FisherF(T).d1Value`
- `FisherF(T).d2Value`
- `FisherF(T).sample`
- `FisherF(T).sampleFrom`
- `FisherF(T).fill`
- `FisherF(T).fillFrom`
- `StudentT(T)`
- `StudentT(T).init`
- `StudentT(T).dofValue`
- `StudentT(T).sample`
- `StudentT(T).sampleFrom`
- `StudentT(T).fill`
- `StudentT(T).fillFrom`
- `Triangular(T)`
- `Triangular(T).init`
- `Triangular(T).sample`
- `Triangular(T).sampleFrom`
- `Triangular(T).fill`
- `Triangular(T).fillFrom`
- `Arcsine(T)`
- `Arcsine(T).init`
- `Arcsine(T).sample`
- `Arcsine(T).sampleFrom`
- `Arcsine(T).fill`
- `Arcsine(T).fillFrom`
- `Cauchy(T)`
- `Cauchy(T).init`
- `Cauchy(T).sample`
- `Cauchy(T).sampleFrom`
- `Cauchy(T).fill`
- `Cauchy(T).fillFrom`
- `Laplace(T)`
- `Laplace(T).init`
- `Laplace(T).sample`
- `Laplace(T).sampleFrom`
- `Laplace(T).fill`
- `Laplace(T).fillFrom`
- `Logistic(T)`
- `Logistic(T).init`
- `Logistic(T).sample`
- `Logistic(T).sampleFrom`
- `Logistic(T).fill`
- `Logistic(T).fillFrom`
- `LogLogistic(T)`
- `LogLogistic(T).init`
- `LogLogistic(T).sample`
- `LogLogistic(T).sampleFrom`
- `LogLogistic(T).fill`
- `LogLogistic(T).fillFrom`
- `Kumaraswamy(T)`
- `Kumaraswamy(T).init`
- `Kumaraswamy(T).sample`
- `Kumaraswamy(T).sampleFrom`
- `Kumaraswamy(T).fill`
- `Kumaraswamy(T).fillFrom`
- `PowerFunction(T)`
- `PowerFunction(T).init`
- `PowerFunction(T).sample`
- `PowerFunction(T).sampleFrom`
- `PowerFunction(T).fill`
- `PowerFunction(T).fillFrom`
- `Rayleigh(T)`
- `Rayleigh(T).init`
- `Rayleigh(T).sample`
- `Rayleigh(T).sampleFrom`
- `Rayleigh(T).fill`
- `Rayleigh(T).fillFrom`
- `Maxwell(T)`
- `Maxwell(T).init`
- `Maxwell(T).sample`
- `Maxwell(T).sampleFrom`
- `Maxwell(T).fill`
- `Maxwell(T).fillFrom`
- `Pareto(T)`
- `Pareto(T).init`
- `Pareto(T).sample`
- `Pareto(T).sampleFrom`
- `Pareto(T).fill`
- `Pareto(T).fillFrom`
- `Weibull(T)`
- `Weibull(T).init`
- `Weibull(T).sample`
- `Weibull(T).sampleFrom`
- `Weibull(T).fill`
- `Weibull(T).fillFrom`
- `Gumbel(T)`
- `Gumbel(T).init`
- `Gumbel(T).sample`
- `Gumbel(T).sampleFrom`
- `Gumbel(T).fill`
- `Gumbel(T).fillFrom`
- `Frechet(T)`
- `Frechet(T).init`
- `Frechet(T).sample`
- `Frechet(T).sampleFrom`
- `Frechet(T).fill`
- `Frechet(T).fillFrom`
- `SkewNormal(T)`
- `SkewNormal(T).init`
- `SkewNormal(T).locationValue`
- `SkewNormal(T).scaleValue`
- `SkewNormal(T).shapeValue`
- `SkewNormal(T).sample`
- `SkewNormal(T).sampleFrom`
- `SkewNormal(T).fill`
- `SkewNormal(T).fillFrom`
- `Pert(T)`
- `Pert(T).init`
- `Pert(T).initDefault`
- `Pert(T).initRange`
- `Pert(T).initMean`
- `PertBuilder(T).withShape`
- `PertBuilder(T).withMode`
- `PertBuilder(T).withMean`
- `Pert(T).sample`
- `Pert(T).sampleFrom`
- `Pert(T).fill`
- `Pert(T).fillFrom`
- `InverseGaussian(T)`
- `InverseGaussian(T).init`
- `InverseGaussian(T).sample`
- `InverseGaussian(T).sampleFrom`
- `InverseGaussian(T).fill`
- `InverseGaussian(T).fillFrom`
- `NormalInverseGaussian(T)`
- `NormalInverseGaussian(T).init`
- `NormalInverseGaussian(T).sample`
- `NormalInverseGaussian(T).sampleFrom`
- `NormalInverseGaussian(T).fill`
- `NormalInverseGaussian(T).fillFrom`
- `Zipf(T)`
- `Zipf(T).init`
- `Zipf(T).sample`
- `Zipf(T).sampleFrom`
- `Zipf(T).fill`
- `Zipf(T).fillFrom`
- `Zeta(T)`
- `Zeta(T).init`
- `Zeta(T).sample`
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
- `Dirichlet(T).init`
- `Dirichlet(T).sample`
- `Dirichlet(T).sampleFrom`
- `Dirichlet(T).sampleInto`
- `Dirichlet(T).sampleIntoFrom`
- `Dirichlet(T).sampleIntoChecked`
- `Dirichlet(T).sampleIntoCheckedFrom`
- `Dirichlet(T).sampleManyInto`
- `Dirichlet(T).sampleManyIntoFrom`
- `Dirichlet(T).sampleManyIntoChecked`
- `Dirichlet(T).sampleManyIntoCheckedFrom`
- `AliasTable(Weight)`
- `WeightedTree(Weight)`
- `WeightedIntTree(Weight)`

Alias helpers:

- `aliasTable(T)`
- `AliasTable.init`
- `AliasTable.update`
- `AliasTable.len`
- `AliasTable.totalWeight`
- `AliasTable.weights`
- `AliasTable.weightsInto`
- `AliasTable.weightAt`
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
- `WeightedTree.weights`
- `WeightedTree.weightsInto`
- `WeightedTree.isValid`
- `WeightedTree.deinit`
- Prefer `WeightedIntTree` when weights are unsigned integers and frequent
  update/push/pop/sample throughput is the priority.
- `WeightedIntTree.init`
- `WeightedIntTree.len`
- `WeightedIntTree.isEmpty`
- `WeightedIntTree.push`
- `WeightedIntTree.pop`
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
- `WeightedIntTree.weights`
- `WeightedIntTree.weightsInto`
- `WeightedIntTree.isValid`
- `WeightedIntTree.deinit`

## Sequence Sampling

- Error type: `Error`
- Index vectors: `IndexVec.len`, `IndexVec.isEmpty`, `IndexVec.at`,
  `IndexVec.copyInto`, `IndexVec.toOwnedSlice`, `IndexVec.iter`,
  `IndexVec.Iterator.next`, `IndexVec.Iterator.remaining`, `IndexVec.deinit`
- Indices: `sampleIndexVec`, `sampleIndexVecFrom`, `sampleIndices`,
  `sampleIndexVecCheckedFrom`, `sampleIndicesFrom`, `sampleIndicesCheckedFrom`,
  `sampleIndicesU32`, `sampleIndicesU32From`, `sampleIndicesU32CheckedFrom`,
  `sampleArray`, `sampleArrayFrom`, `sampleArrayChecked`,
  `sampleArrayCheckedFrom`
- Collections: `chooseMultiple`, `chooseMultipleFrom`,
  `chooseMultipleChecked`, `chooseMultipleCheckedFrom`, `partialShuffle`,
  `partialShuffleFrom`, `partialShuffleChecked`, `partialShuffleCheckedFrom`,
  `reservoirSample`, `reservoirSampleFrom`, `reservoirSampleChecked`,
  `reservoirSampleCheckedFrom`
- Iterators: `chooseIterator`, `chooseIteratorFrom`, `chooseIteratorChecked`,
  `chooseIteratorCheckedFrom`, `sampleIterator`, `sampleIteratorFrom`,
  `sampleIteratorChecked`, `sampleIteratorCheckedFrom`, `chooseIteratorWeighted`,
  `chooseIteratorWeightedFrom`, `chooseIteratorWeightedChecked`,
  `chooseIteratorWeightedCheckedFrom`, `sampleIteratorWeighted`,
  `sampleIteratorWeightedFrom`, `sampleIteratorWeightedChecked`,
  `sampleIteratorWeightedCheckedFrom`
- Reusable samplers: `Choice(T)`, `chooseIter`, `chooseIterFrom`,
  `chooseIterChecked`, `chooseIterCheckedFrom`,
  `WeightedChoice(T, Weight)`,
  `Choice.init`, `Choice.initChecked`, `Choice.len`, `Choice.sample`,
  `Choice.sampleFrom`, `Choice.sampleValue`, `Choice.sampleValueFrom`,
  `Choice.fill`, `Choice.fillFrom`,
  `Choice.fillValues`, `Choice.fillValuesFrom`, `Choice.iter`,
  `Choice.iterFrom`,
  `WeightedChoice.init`, `WeightedChoice.deinit`, `WeightedChoice.len`,
  `WeightedChoice.totalWeight`, `WeightedChoice.weights`,
  `WeightedChoice.weightsInto`, `WeightedChoice.weightAt`,
  `WeightedChoice.update`, `WeightedChoice.sample`,
  `WeightedChoice.sampleFrom`,
  `WeightedChoice.sampleValue`, `WeightedChoice.sampleValueFrom`,
  `WeightedChoice.fill`, `WeightedChoice.fillFrom`,
  `WeightedChoice.fillValues`, `WeightedChoice.fillValuesFrom`,
  `WeightedChoice.iter`, `WeightedChoice.iterFrom`
- Weighted no-replacement: `sampleWeightedIndices`,
  `sampleWeightedIndicesFrom`, `sampleWeightedIndicesChecked`,
  `sampleWeightedIndicesCheckedFrom`, `sampleWeighted`, `sampleWeightedFrom`,
  `sampleWeightedChecked`, `sampleWeightedCheckedFrom`

## ASCII And Unicode

- Charset constants: `Alphanumeric`, `Alphabetic`, `Lowercase`, `Uppercase`,
  `Digits`
- Raw charset byte sets: `alphanumeric`, `alphabetic`, `lowercase`,
  `uppercase`, `digits`
- Charset type: `Charset.init`, `Charset.initChecked`, `Charset.sample`,
  `Charset.sampleChecked`, `Charset.sampleFrom`, `Charset.sampleCheckedFrom`,
  `Charset.fill`, `Charset.fillChecked`, `Charset.fillFrom`,
  `Charset.fillCheckedFrom`, `Charset.alloc`, `Charset.allocChecked`,
  `Charset.allocFrom`, `Charset.allocCheckedFrom`
- Helpers: `char`, `charFrom`, `string`, `stringFrom`, `unicodeScalar`,
  `unicodeScalarFrom`, `unicodeUtf8Alloc`, `unicodeUtf8AllocFrom`,
  `unicodeUtf8Capacity`, `unicodeUtf8Into`, `unicodeUtf8IntoFrom`

## Validation And Tooling

Build steps:

- `zig build test`
- `zig build run-basic`
- `zig build apicheck`
- `zig build validate`
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
