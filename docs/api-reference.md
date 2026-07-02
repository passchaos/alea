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
  `fillUniformInclusiveCheckedFrom`, `vectorUniform`, `vectorUniformFrom`,
  `vectorUniformChecked`, `vectorUniformCheckedFrom`, `fillVectorUniform`,
  `fillVectorUniformFrom`, `fillVectorUniformChecked`,
  `fillVectorUniformCheckedFrom`, `vectorUniformInclusive`,
  `vectorUniformInclusiveFrom`, `vectorUniformInclusiveChecked`,
  `vectorUniformInclusiveCheckedFrom`, `fillVectorUniformInclusive`,
  `fillVectorUniformInclusiveFrom`, `fillVectorUniformInclusiveChecked`,
  `fillVectorUniformInclusiveCheckedFrom`
- `bernoulli`, `bernoulliFrom`, `bernoulliChecked`,
  `bernoulliCheckedFrom`, `fillBernoulli`, `fillBernoulliFrom`,
  `fillBernoulliChecked`, `fillBernoulliCheckedFrom`, `vectorBernoulli`,
  `vectorBernoulliFrom`, `vectorBernoulliChecked`,
  `vectorBernoulliCheckedFrom`, `fillVectorBernoulli`,
  `fillVectorBernoulliFrom`, `fillVectorBernoulliChecked`,
  `fillVectorBernoulliCheckedFrom`, `binomial`,
  `binomialFrom`, `binomialChecked`, `binomialCheckedFrom`, `fillBinomial`, `fillBinomialFrom`,
  `fillBinomialChecked`, `fillBinomialCheckedFrom`, `vectorBinomial`,
  `vectorBinomialFrom`, `vectorBinomialChecked`,
  `vectorBinomialCheckedFrom`, `fillVectorBinomial`,
  `fillVectorBinomialFrom`, `fillVectorBinomialChecked`,
  `fillVectorBinomialCheckedFrom`,
  `binomialPoissonApprox`, `binomialPoissonApproxFrom`,
  `binomialPoissonApproxChecked`, `binomialPoissonApproxCheckedFrom`
- `negativeBinomial`, `negativeBinomialFrom`, `negativeBinomialChecked`,
  `negativeBinomialCheckedFrom`, `fillNegativeBinomial`,
  `fillNegativeBinomialFrom`, `fillNegativeBinomialChecked`,
  `fillNegativeBinomialCheckedFrom`, `vectorNegativeBinomial`,
  `vectorNegativeBinomialFrom`, `vectorNegativeBinomialChecked`,
  `vectorNegativeBinomialCheckedFrom`, `fillVectorNegativeBinomial`,
  `fillVectorNegativeBinomialFrom`, `fillVectorNegativeBinomialChecked`,
  `fillVectorNegativeBinomialCheckedFrom`, `hypergeometric`, `hypergeometricFrom`,
  `hypergeometricChecked`, `hypergeometricCheckedFrom`,
  `fillHypergeometric`, `fillHypergeometricFrom`,
  `fillHypergeometricChecked`, `fillHypergeometricCheckedFrom`,
  `vectorHypergeometric`, `vectorHypergeometricFrom`,
  `vectorHypergeometricChecked`, `vectorHypergeometricCheckedFrom`,
  `fillVectorHypergeometric`, `fillVectorHypergeometricFrom`,
  `fillVectorHypergeometricChecked`, `fillVectorHypergeometricCheckedFrom`
- `standardNormal`, `standardNormalFrom`, `fillStandardNormal`,
  `fillStandardNormalFrom`, `vectorStandardNormal`,
  `vectorStandardNormalFrom`, `fillVectorStandardNormal`,
  `fillVectorStandardNormalFrom`, `normal`, `normalFrom`, `normalChecked`,
  `normalCheckedFrom`, `fillNormal`, `fillNormalFrom`, `fillNormalChecked`,
  `fillNormalCheckedFrom`, `vectorNormal`, `vectorNormalFrom`,
  `vectorNormalChecked`, `vectorNormalCheckedFrom`, `fillVectorNormal`,
  `fillVectorNormalFrom`, `fillVectorNormalChecked`,
  `fillVectorNormalCheckedFrom`, `logNormal`, `logNormalFrom`,
  `logNormalChecked`, `logNormalCheckedFrom`, `fillLogNormal`,
  `fillLogNormalFrom`, `fillLogNormalChecked`, `fillLogNormalCheckedFrom`,
  `vectorLogNormal`, `vectorLogNormalFrom`, `vectorLogNormalChecked`,
  `vectorLogNormalCheckedFrom`, `fillVectorLogNormal`,
  `fillVectorLogNormalFrom`, `fillVectorLogNormalChecked`,
  `fillVectorLogNormalCheckedFrom`,
  `logNormalApproxF32`, `logNormalApproxF32From`,
  `logNormalApproxF32Checked`, `logNormalApproxF32CheckedFrom`,
  `fillLogNormalApproxF32`, `fillLogNormalApproxF32From`,
  `fillLogNormalApproxF32Checked`, `fillLogNormalApproxF32CheckedFrom`,
  `halfNormal`, `halfNormalFrom`, `halfNormalChecked`,
  `halfNormalCheckedFrom`, `fillHalfNormal`, `fillHalfNormalFrom`,
  `fillHalfNormalChecked`, `fillHalfNormalCheckedFrom`, `vectorHalfNormal`,
  `vectorHalfNormalFrom`, `vectorHalfNormalChecked`,
  `vectorHalfNormalCheckedFrom`, `fillVectorHalfNormal`,
  `fillVectorHalfNormalFrom`, `fillVectorHalfNormalChecked`,
  `fillVectorHalfNormalCheckedFrom`, `chi`, `chiFrom`,
  `standardExponential`, `standardExponentialFrom`,
  `fillStandardExponential`, `fillStandardExponentialFrom`,
  `vectorStandardExponential`, `vectorStandardExponentialFrom`,
  `fillVectorStandardExponential`, `fillVectorStandardExponentialFrom`,
  `exponential`, `exponentialFrom`, `exponentialChecked`,
  `exponentialCheckedFrom`, `fillExponential`, `fillExponentialFrom`,
  `fillExponentialChecked`, `fillExponentialCheckedFrom`,
  `vectorExponential`, `vectorExponentialFrom`, `vectorExponentialChecked`,
  `vectorExponentialCheckedFrom`, `fillVectorExponential`,
  `fillVectorExponentialFrom`, `fillVectorExponentialChecked`,
  `fillVectorExponentialCheckedFrom`
- `poisson`, `poissonFrom`, `poissonChecked`, `poissonCheckedFrom`,
  `fillPoisson`, `fillPoissonFrom`, `fillPoissonChecked`,
  `fillPoissonCheckedFrom`, `vectorPoisson`, `vectorPoissonFrom`,
  `vectorPoissonChecked`, `vectorPoissonCheckedFrom`, `fillVectorPoisson`,
  `fillVectorPoissonFrom`, `fillVectorPoissonChecked`,
  `fillVectorPoissonCheckedFrom`, `geometric`,
  `geometricFrom`, `geometricChecked`, `geometricCheckedFrom`,
  `fillGeometric`, `fillGeometricFrom`, `fillGeometricChecked`,
  `fillGeometricCheckedFrom`, `vectorGeometric`, `vectorGeometricFrom`,
  `vectorGeometricChecked`, `vectorGeometricCheckedFrom`,
  `fillVectorGeometric`, `fillVectorGeometricFrom`,
  `fillVectorGeometricChecked`, `fillVectorGeometricCheckedFrom`,
  `geometricFailures`, `geometricFailuresFrom`, `geometricFailuresChecked`,
  `geometricFailuresCheckedFrom`, `fillGeometricFailures`,
  `fillGeometricFailuresFrom`, `fillGeometricFailuresChecked`,
  `fillGeometricFailuresCheckedFrom`, `vectorGeometricFailures`,
  `vectorGeometricFailuresFrom`, `vectorGeometricFailuresChecked`,
  `vectorGeometricFailuresCheckedFrom`, `fillVectorGeometricFailures`,
  `fillVectorGeometricFailuresFrom`, `fillVectorGeometricFailuresChecked`,
  `fillVectorGeometricFailuresCheckedFrom`, `standardGeometric`,
  `standardGeometricFrom`, `fillStandardGeometric`,
  `fillStandardGeometricFrom`, `vectorStandardGeometric`,
  `vectorStandardGeometricFrom`, `fillVectorStandardGeometric`,
  `fillVectorStandardGeometricFrom`, `poissonAhrensDieter`,
  `poissonAhrensDieterFrom`, `poissonAhrensDieterChecked`,
  `poissonAhrensDieterCheckedFrom`
- `gamma`, `gammaFrom`, `gammaChecked`, `gammaCheckedFrom`, `fillGamma`,
  `fillGammaFrom`, `fillGammaChecked`, `fillGammaCheckedFrom`,
  `vectorGamma`, `vectorGammaFrom`, `vectorGammaChecked`,
  `vectorGammaCheckedFrom`, `fillVectorGamma`, `fillVectorGammaFrom`,
  `fillVectorGammaChecked`, `fillVectorGammaCheckedFrom`, `chiSquared`,
  `chiSquaredFrom`, `chiSquaredChecked`, `chiSquaredCheckedFrom`,
  `fillChiSquared`, `fillChiSquaredFrom`, `fillChiSquaredChecked`,
  `fillChiSquaredCheckedFrom`, `vectorChiSquared`, `vectorChiSquaredFrom`,
  `vectorChiSquaredChecked`, `vectorChiSquaredCheckedFrom`,
  `fillVectorChiSquared`, `fillVectorChiSquaredFrom`,
  `fillVectorChiSquaredChecked`, `fillVectorChiSquaredCheckedFrom`,
  `chi`, `chiFrom`, `chiChecked`,
  `chiCheckedFrom`, `fillChi`, `fillChiFrom`, `fillChiChecked`,
  `fillChiCheckedFrom`, `vectorChi`, `vectorChiFrom`, `vectorChiChecked`,
  `vectorChiCheckedFrom`, `fillVectorChi`, `fillVectorChiFrom`,
  `fillVectorChiChecked`, `fillVectorChiCheckedFrom`,
  `erlang`, `erlangFrom`, `erlangChecked`,
  `erlangCheckedFrom`, `fillErlang`, `fillErlangFrom`,
  `fillErlangChecked`, `fillErlangCheckedFrom`, `vectorErlang`,
  `vectorErlangFrom`, `vectorErlangChecked`, `vectorErlangCheckedFrom`,
  `fillVectorErlang`, `fillVectorErlangFrom`, `fillVectorErlangChecked`,
  `fillVectorErlangCheckedFrom`, `beta`, `betaFrom`,
  `betaChecked`, `betaCheckedFrom`, `fillBeta`, `fillBetaFrom`,
  `fillBetaChecked`, `fillBetaCheckedFrom`, `vectorBeta`,
  `vectorBetaFrom`, `vectorBetaChecked`, `vectorBetaCheckedFrom`,
  `fillVectorBeta`, `fillVectorBetaFrom`, `fillVectorBetaChecked`,
  `fillVectorBetaCheckedFrom`, `fisherF`, `fisherFFrom`,
  `fisherFChecked`, `fisherFCheckedFrom`, `fillFisherF`,
  `fillFisherFFrom`, `fillFisherFChecked`, `fillFisherFCheckedFrom`,
  `vectorFisherF`, `vectorFisherFFrom`, `vectorFisherFChecked`,
  `vectorFisherFCheckedFrom`, `fillVectorFisherF`,
  `fillVectorFisherFFrom`, `fillVectorFisherFChecked`,
  `fillVectorFisherFCheckedFrom`,
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
- `Bernoulli.probabilityValue`
- `Bernoulli.expectedValue`
- `Bernoulli.varianceValue`
- `Bernoulli.modeValue`
- `Bernoulli.minValue`
- `Bernoulli.maxValue`
- `Bernoulli.sample`
- `Bernoulli.sampleFrom`
- `Bernoulli.fill`
- `Bernoulli.fillFrom`
- `VectorBernoulli(VectorType)`
- `VectorBernoulli(VectorType).init`
- `VectorBernoulli(VectorType).initRatio`
- `VectorBernoulli(VectorType).probability`
- `VectorBernoulli(VectorType).probabilityValue`
- `VectorBernoulli(VectorType).expectedValue`
- `VectorBernoulli(VectorType).varianceValue`
- `VectorBernoulli(VectorType).modeValue`
- `VectorBernoulli(VectorType).minValue`
- `VectorBernoulli(VectorType).maxValue`
- `VectorBernoulli(VectorType).sample`
- `VectorBernoulli(VectorType).sampleFrom`
- `VectorBernoulli(VectorType).fill`
- `VectorBernoulli(VectorType).fillFrom`
- `Binomial`
- `Binomial.init`
- `Binomial.trialsValue`
- `Binomial.probabilityValue`
- `Binomial.expectedValue`
- `Binomial.varianceValue`
- `Binomial.minValue`
- `Binomial.maxValue`
- `Binomial.sample`
- `Binomial.sampleFrom`
- `Binomial.fill`
- `Binomial.fillFrom`
- `VectorBinomial(VectorType)`
- `VectorBinomial(VectorType).init`
- `VectorBinomial(VectorType).trialsValue`
- `VectorBinomial(VectorType).probabilityValue`
- `VectorBinomial(VectorType).expectedValue`
- `VectorBinomial(VectorType).varianceValue`
- `VectorBinomial(VectorType).minValue`
- `VectorBinomial(VectorType).maxValue`
- `VectorBinomial(VectorType).sample`
- `VectorBinomial(VectorType).sampleFrom`
- `VectorBinomial(VectorType).fill`
- `VectorBinomial(VectorType).fillFrom`
- `Multinomial`
- `Multinomial.init`
- `Multinomial.trialsValue`
- `Multinomial.probabilitiesValue`
- `Multinomial.probabilityAt`
- `Multinomial.normalizedProbabilityAt`
- `Multinomial.normalizedProbabilities`
- `Multinomial.normalizedProbabilitiesInto`
- `Multinomial.expectedCountAt`
- `Multinomial.expectedCounts`
- `Multinomial.expectedCountsInto`
- `Multinomial.varianceAt`
- `Multinomial.variances`
- `Multinomial.variancesInto`
- `Multinomial.covarianceAt`
- `Multinomial.covariances`
- `Multinomial.covariancesInto`
- `Multinomial.categoryCountValue`
- `Multinomial.totalProbabilityValue`
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
- `NegativeBinomial.successesValue`
- `NegativeBinomial.probabilityValue`
- `NegativeBinomial.expectedValue`
- `NegativeBinomial.varianceValue`
- `NegativeBinomial.minValue`
- `NegativeBinomial.maxValue`
- `NegativeBinomial.sample`
- `NegativeBinomial.sampleFrom`
- `NegativeBinomial.fill`
- `NegativeBinomial.fillFrom`
- `VectorNegativeBinomial(VectorType)`
- `VectorNegativeBinomial(VectorType).init`
- `VectorNegativeBinomial(VectorType).successesValue`
- `VectorNegativeBinomial(VectorType).probabilityValue`
- `VectorNegativeBinomial(VectorType).expectedValue`
- `VectorNegativeBinomial(VectorType).varianceValue`
- `VectorNegativeBinomial(VectorType).minValue`
- `VectorNegativeBinomial(VectorType).maxValue`
- `VectorNegativeBinomial(VectorType).sample`
- `VectorNegativeBinomial(VectorType).sampleFrom`
- `VectorNegativeBinomial(VectorType).fill`
- `VectorNegativeBinomial(VectorType).fillFrom`
- `Hypergeometric`
- `Hypergeometric.init`
- `Hypergeometric.populationValue`
- `Hypergeometric.successesValue`
- `Hypergeometric.drawsValue`
- `Hypergeometric.expectedValue`
- `Hypergeometric.varianceValue`
- `Hypergeometric.minValue`
- `Hypergeometric.maxValue`
- `Hypergeometric.sample`
- `Hypergeometric.sampleFrom`
- `Hypergeometric.fill`
- `Hypergeometric.fillFrom`
- `VectorHypergeometric(VectorType)`
- `VectorHypergeometric(VectorType).init`
- `VectorHypergeometric(VectorType).populationValue`
- `VectorHypergeometric(VectorType).successesValue`
- `VectorHypergeometric(VectorType).drawsValue`
- `VectorHypergeometric(VectorType).expectedValue`
- `VectorHypergeometric(VectorType).varianceValue`
- `VectorHypergeometric(VectorType).minValue`
- `VectorHypergeometric(VectorType).maxValue`
- `VectorHypergeometric(VectorType).sample`
- `VectorHypergeometric(VectorType).sampleFrom`
- `VectorHypergeometric(VectorType).fill`
- `VectorHypergeometric(VectorType).fillFrom`
- `Uniform(T)`
- `Uniform(T).init`
- `Uniform(T).initInclusive`
- `Uniform(T).lowValue`
- `Uniform(T).highValue`
- `Uniform(T).isInclusive`
- `Uniform(T).expectedValue`
- `Uniform(T).varianceValue`
- `Uniform(T).sample`
- `Uniform(T).sampleFrom`
- `Uniform(T).fill`
- `Uniform(T).fillFrom`
- `VectorUniform(VectorType)`
- `VectorUniform(VectorType).init`
- `VectorUniform(VectorType).initInclusive`
- `VectorUniform(VectorType).lowValue`
- `VectorUniform(VectorType).highValue`
- `VectorUniform(VectorType).isInclusive`
- `VectorUniform(VectorType).expectedValue`
- `VectorUniform(VectorType).varianceValue`
- `VectorUniform(VectorType).sample`
- `VectorUniform(VectorType).sampleFrom`
- `VectorUniform(VectorType).fill`
- `VectorUniform(VectorType).fillFrom`
- `Open01`
- `Open01.lowValue`
- `Open01.highValue`
- `Open01.includesLow`
- `Open01.includesHigh`
- `Open01.expectedValue`
- `Open01.varianceValue`
- `Open01.sample`
- `Open01.sampleFrom`
- `Open01.fill`
- `Open01.fillFrom`
- `OpenClosed01`
- `OpenClosed01.lowValue`
- `OpenClosed01.highValue`
- `OpenClosed01.includesLow`
- `OpenClosed01.includesHigh`
- `OpenClosed01.expectedValue`
- `OpenClosed01.varianceValue`
- `OpenClosed01.sample`
- `OpenClosed01.sampleFrom`
- `OpenClosed01.fill`
- `OpenClosed01.fillFrom`
  (`Open01` and `OpenClosed01` sample/fill scalar `f32`/`f64` and float vector
  types such as `@Vector(8, f32)`.)
- `StandardNormal(T)`
- `StandardNormal(T).meanValue`
- `StandardNormal(T).stddevValue`
- `StandardNormal(T).expectedValue`
- `StandardNormal(T).varianceValue`
- `StandardNormal(T).medianValue`
- `StandardNormal(T).modeValue`
- `StandardNormal(T).minValue`
- `StandardNormal(T).maxValue`
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
- `Normal(T).expectedValue`
- `Normal(T).varianceValue`
- `Normal(T).medianValue`
- `Normal(T).modeValue`
- `Normal(T).minValue`
- `Normal(T).maxValue`
- `Normal(T).coefficientOfVariationValue`
- `Normal(T).sample`
- `Normal(T).sampleFrom`
- `Normal(T).fill`
- `Normal(T).fillFrom`
- `VectorStandardNormal(VectorType)`
- `VectorStandardNormal(VectorType).meanValue`
- `VectorStandardNormal(VectorType).stddevValue`
- `VectorStandardNormal(VectorType).expectedValue`
- `VectorStandardNormal(VectorType).varianceValue`
- `VectorStandardNormal(VectorType).medianValue`
- `VectorStandardNormal(VectorType).modeValue`
- `VectorStandardNormal(VectorType).minValue`
- `VectorStandardNormal(VectorType).maxValue`
- `VectorStandardNormal(VectorType).sample`
- `VectorStandardNormal(VectorType).sampleFrom`
- `VectorStandardNormal(VectorType).fill`
- `VectorStandardNormal(VectorType).fillFrom`
- `VectorNormal(VectorType)`
- `VectorNormal(VectorType).init`
- `VectorNormal(VectorType).initMeanCv`
- `VectorNormal(VectorType).fromZScore`
- `VectorNormal(VectorType).meanValue`
- `VectorNormal(VectorType).stddevValue`
- `VectorNormal(VectorType).expectedValue`
- `VectorNormal(VectorType).varianceValue`
- `VectorNormal(VectorType).medianValue`
- `VectorNormal(VectorType).modeValue`
- `VectorNormal(VectorType).minValue`
- `VectorNormal(VectorType).maxValue`
- `VectorNormal(VectorType).coefficientOfVariationValue`
- `VectorNormal(VectorType).sample`
- `VectorNormal(VectorType).sampleFrom`
- `VectorNormal(VectorType).fill`
- `VectorNormal(VectorType).fillFrom`
- `StandardExponential(T)`
- `StandardExponential(T).rateValue`
- `StandardExponential(T).inverseRateValue`
- `StandardExponential(T).expectedValue`
- `StandardExponential(T).varianceValue`
- `StandardExponential(T).medianValue`
- `StandardExponential(T).modeValue`
- `StandardExponential(T).minValue`
- `StandardExponential(T).maxValue`
- `StandardExponential(T).sample`
- `StandardExponential(T).sampleFrom`
- `StandardExponential(T).fill`
- `StandardExponential(T).fillFrom`
- `Exponential(T)`
- `Exponential(T).init`
- `Exponential(T).rateValue`
- `Exponential(T).inverseRateValue`
- `Exponential(T).expectedValue`
- `Exponential(T).varianceValue`
- `Exponential(T).medianValue`
- `Exponential(T).modeValue`
- `Exponential(T).minValue`
- `Exponential(T).maxValue`
- `Exponential(T).sample`
- `Exponential(T).sampleFrom`
- `Exponential(T).fill`
- `Exponential(T).fillFrom`
- `VectorStandardExponential(VectorType)`
- `VectorStandardExponential(VectorType).rateValue`
- `VectorStandardExponential(VectorType).inverseRateValue`
- `VectorStandardExponential(VectorType).expectedValue`
- `VectorStandardExponential(VectorType).varianceValue`
- `VectorStandardExponential(VectorType).medianValue`
- `VectorStandardExponential(VectorType).modeValue`
- `VectorStandardExponential(VectorType).minValue`
- `VectorStandardExponential(VectorType).maxValue`
- `VectorStandardExponential(VectorType).sample`
- `VectorStandardExponential(VectorType).sampleFrom`
- `VectorStandardExponential(VectorType).fill`
- `VectorStandardExponential(VectorType).fillFrom`
- `VectorExponential(VectorType)`
- `VectorExponential(VectorType).init`
- `VectorExponential(VectorType).rateValue`
- `VectorExponential(VectorType).inverseRateValue`
- `VectorExponential(VectorType).expectedValue`
- `VectorExponential(VectorType).varianceValue`
- `VectorExponential(VectorType).medianValue`
- `VectorExponential(VectorType).modeValue`
- `VectorExponential(VectorType).minValue`
- `VectorExponential(VectorType).maxValue`
- `VectorExponential(VectorType).sample`
- `VectorExponential(VectorType).sampleFrom`
- `VectorExponential(VectorType).fill`
- `VectorExponential(VectorType).fillFrom`
- `LogNormal(T)`
- `LogNormal(T).init`
- `LogNormal(T).initMeanCv`
- `LogNormal(T).fromZScore`
- `LogNormal(T).logMean`
- `LogNormal(T).logMeanValue`
- `LogNormal(T).logStddev`
- `LogNormal(T).logStddevValue`
- `LogNormal(T).linearMeanValue`
- `LogNormal(T).medianValue`
- `LogNormal(T).modeValue`
- `LogNormal(T).expectedValue`
- `LogNormal(T).varianceValue`
- `LogNormal(T).minValue`
- `LogNormal(T).maxValue`
- `LogNormal(T).coefficientOfVariationValue`
- `LogNormal(T).sample`
- `LogNormal(T).sampleFrom`
- `LogNormal(T).fill`
- `LogNormal(T).fillFrom`
- `VectorLogNormal(VectorType)`
- `VectorLogNormal(VectorType).init`
- `VectorLogNormal(VectorType).meanValue`
- `VectorLogNormal(VectorType).stddevValue`
- `VectorLogNormal(VectorType).sample`
- `VectorLogNormal(VectorType).sampleFrom`
- `VectorLogNormal(VectorType).fill`
- `VectorLogNormal(VectorType).fillFrom`
- `LogNormalApproxF32`
- `LogNormalApproxF32.max_abs_mean`
- `LogNormalApproxF32.max_stddev`
- `LogNormalApproxF32.init`
- `LogNormalApproxF32.meanValue`
- `LogNormalApproxF32.stddevValue`
- `LogNormalApproxF32.maxAbsMeanValue`
- `LogNormalApproxF32.maxStddevValue`
- `LogNormalApproxF32.sample`
- `LogNormalApproxF32.sampleFrom`
- `LogNormalApproxF32.fill`
- `LogNormalApproxF32.fillFrom`
- `HalfNormal(T)`
- `HalfNormal(T).init`
- `HalfNormal(T).scaleValue`
- `HalfNormal(T).expectedValue`
- `HalfNormal(T).varianceValue`
- `HalfNormal(T).minValue`
- `HalfNormal(T).maxValue`
- `HalfNormal(T).sample`
- `HalfNormal(T).sampleFrom`
- `HalfNormal(T).fill`
- `HalfNormal(T).fillFrom`
- `VectorHalfNormal(VectorType)`
- `VectorHalfNormal(VectorType).init`
- `VectorHalfNormal(VectorType).scaleValue`
- `VectorHalfNormal(VectorType).expectedValue`
- `VectorHalfNormal(VectorType).varianceValue`
- `VectorHalfNormal(VectorType).minValue`
- `VectorHalfNormal(VectorType).maxValue`
- `VectorHalfNormal(VectorType).sample`
- `VectorHalfNormal(VectorType).sampleFrom`
- `VectorHalfNormal(VectorType).fill`
- `VectorHalfNormal(VectorType).fillFrom`
- `Poisson`
- `Poisson.init`
- `Poisson.lambdaValue`
- `Poisson.expectedValue`
- `Poisson.varianceValue`
- `Poisson.minValue`
- `Poisson.maxValue`
- `Poisson.sample`
- `Poisson.sampleFrom`
- `Poisson.fill`
- `Poisson.fillFrom`
- `VectorPoisson(VectorType)`
- `VectorPoisson(VectorType).init`
- `VectorPoisson(VectorType).lambdaValue`
- `VectorPoisson(VectorType).expectedValue`
- `VectorPoisson(VectorType).varianceValue`
- `VectorPoisson(VectorType).minValue`
- `VectorPoisson(VectorType).maxValue`
- `VectorPoisson(VectorType).sample`
- `VectorPoisson(VectorType).sampleFrom`
- `VectorPoisson(VectorType).fill`
- `VectorPoisson(VectorType).fillFrom`
- `Geometric`
- `Geometric.init`
- `Geometric.probabilityValue`
- `Geometric.expectedValue`
- `Geometric.varianceValue`
- `Geometric.modeValue`
- `Geometric.minValue`
- `Geometric.maxValue`
- `Geometric.sample`
- `Geometric.sampleFrom`
- `Geometric.fill`
- `Geometric.fillFrom`
- `VectorGeometric(VectorType)`
- `VectorGeometric(VectorType).init`
- `VectorGeometric(VectorType).probabilityValue`
- `VectorGeometric(VectorType).expectedValue`
- `VectorGeometric(VectorType).varianceValue`
- `VectorGeometric(VectorType).modeValue`
- `VectorGeometric(VectorType).minValue`
- `VectorGeometric(VectorType).maxValue`
- `VectorGeometric(VectorType).sample`
- `VectorGeometric(VectorType).sampleFrom`
- `VectorGeometric(VectorType).fill`
- `VectorGeometric(VectorType).fillFrom`
- `GeometricFailures`
- `GeometricFailures.init`
- `GeometricFailures.probabilityValue`
- `GeometricFailures.expectedValue`
- `GeometricFailures.varianceValue`
- `GeometricFailures.modeValue`
- `GeometricFailures.minValue`
- `GeometricFailures.maxValue`
- `GeometricFailures.sample`
- `GeometricFailures.sampleFrom`
- `GeometricFailures.fill`
- `GeometricFailures.fillFrom`
- `VectorGeometricFailures(VectorType)`
- `VectorGeometricFailures(VectorType).init`
- `VectorGeometricFailures(VectorType).probabilityValue`
- `VectorGeometricFailures(VectorType).expectedValue`
- `VectorGeometricFailures(VectorType).varianceValue`
- `VectorGeometricFailures(VectorType).modeValue`
- `VectorGeometricFailures(VectorType).minValue`
- `VectorGeometricFailures(VectorType).maxValue`
- `VectorGeometricFailures(VectorType).sample`
- `VectorGeometricFailures(VectorType).sampleFrom`
- `VectorGeometricFailures(VectorType).fill`
- `VectorGeometricFailures(VectorType).fillFrom`
- `StandardGeometric`
- `StandardGeometric.probabilityValue`
- `StandardGeometric.expectedValue`
- `StandardGeometric.varianceValue`
- `StandardGeometric.modeValue`
- `StandardGeometric.minValue`
- `StandardGeometric.maxValue`
- `StandardGeometric.sample`
- `StandardGeometric.sampleFrom`
- `StandardGeometric.fill`
- `StandardGeometric.fillFrom`
- `VectorStandardGeometric(VectorType)`
- `VectorStandardGeometric(VectorType).probabilityValue`
- `VectorStandardGeometric(VectorType).expectedValue`
- `VectorStandardGeometric(VectorType).varianceValue`
- `VectorStandardGeometric(VectorType).modeValue`
- `VectorStandardGeometric(VectorType).minValue`
- `VectorStandardGeometric(VectorType).maxValue`
- `VectorStandardGeometric(VectorType).sample`
- `VectorStandardGeometric(VectorType).sampleFrom`
- `VectorStandardGeometric(VectorType).fill`
- `VectorStandardGeometric(VectorType).fillFrom`
- `Gamma(T)`
- `Gamma(T).init`
- `Gamma(T).shapeValue`
- `Gamma(T).scaleValue`
- `Gamma(T).expectedValue`
- `Gamma(T).varianceValue`
- `Gamma(T).modeValue`
- `Gamma(T).minValue`
- `Gamma(T).maxValue`
- `Gamma(T).sample`
- `Gamma(T).sampleFrom`
- `Gamma(T).fill`
- `Gamma(T).fillFrom`
- `VectorGamma(VectorType)`
- `VectorGamma(VectorType).init`
- `VectorGamma(VectorType).shapeValue`
- `VectorGamma(VectorType).scaleValue`
- `VectorGamma(VectorType).expectedValue`
- `VectorGamma(VectorType).varianceValue`
- `VectorGamma(VectorType).modeValue`
- `VectorGamma(VectorType).minValue`
- `VectorGamma(VectorType).maxValue`
- `VectorGamma(VectorType).sample`
- `VectorGamma(VectorType).sampleFrom`
- `VectorGamma(VectorType).fill`
- `VectorGamma(VectorType).fillFrom`
- `ChiSquared(T)`
- `ChiSquared(T).init`
- `ChiSquared(T).dofValue`
- `ChiSquared(T).expectedValue`
- `ChiSquared(T).varianceValue`
- `ChiSquared(T).modeValue`
- `ChiSquared(T).minValue`
- `ChiSquared(T).maxValue`
- `ChiSquared(T).sample`
- `ChiSquared(T).sampleFrom`
- `ChiSquared(T).fill`
- `ChiSquared(T).fillFrom`
- `VectorChiSquared(VectorType)`
- `VectorChiSquared(VectorType).init`
- `VectorChiSquared(VectorType).dofValue`
- `VectorChiSquared(VectorType).expectedValue`
- `VectorChiSquared(VectorType).varianceValue`
- `VectorChiSquared(VectorType).modeValue`
- `VectorChiSquared(VectorType).minValue`
- `VectorChiSquared(VectorType).maxValue`
- `VectorChiSquared(VectorType).sample`
- `VectorChiSquared(VectorType).sampleFrom`
- `VectorChiSquared(VectorType).fill`
- `VectorChiSquared(VectorType).fillFrom`
- `Chi(T)`
- `Chi(T).init`
- `Chi(T).dofValue`
- `Chi(T).expectedValue`
- `Chi(T).varianceValue`
- `Chi(T).modeValue`
- `Chi(T).minValue`
- `Chi(T).maxValue`
- `Chi(T).sample`
- `Chi(T).sampleFrom`
- `Chi(T).fill`
- `Chi(T).fillFrom`
- `VectorChi(VectorType)`
- `VectorChi(VectorType).init`
- `VectorChi(VectorType).dofValue`
- `VectorChi(VectorType).expectedValue`
- `VectorChi(VectorType).varianceValue`
- `VectorChi(VectorType).modeValue`
- `VectorChi(VectorType).minValue`
- `VectorChi(VectorType).maxValue`
- `VectorChi(VectorType).sample`
- `VectorChi(VectorType).sampleFrom`
- `VectorChi(VectorType).fill`
- `VectorChi(VectorType).fillFrom`
- `Erlang(T)`
- `Erlang(T).init`
- `Erlang(T).shapeValue`
- `Erlang(T).scaleValue`
- `Erlang(T).expectedValue`
- `Erlang(T).varianceValue`
- `Erlang(T).modeValue`
- `Erlang(T).minValue`
- `Erlang(T).maxValue`
- `Erlang(T).sample`
- `Erlang(T).sampleFrom`
- `Erlang(T).fill`
- `Erlang(T).fillFrom`
- `VectorErlang(VectorType)`
- `VectorErlang(VectorType).init`
- `VectorErlang(VectorType).shapeValue`
- `VectorErlang(VectorType).scaleValue`
- `VectorErlang(VectorType).expectedValue`
- `VectorErlang(VectorType).varianceValue`
- `VectorErlang(VectorType).modeValue`
- `VectorErlang(VectorType).minValue`
- `VectorErlang(VectorType).maxValue`
- `VectorErlang(VectorType).sample`
- `VectorErlang(VectorType).sampleFrom`
- `VectorErlang(VectorType).fill`
- `VectorErlang(VectorType).fillFrom`
- `Beta(T)`
- `Beta(T).init`
- `Beta(T).alphaValue`
- `Beta(T).betaValue`
- `Beta(T).expectedValue`
- `Beta(T).varianceValue`
- `Beta(T).modeValue`
- `Beta(T).minValue`
- `Beta(T).maxValue`
- `Beta(T).sample`
- `Beta(T).sampleFrom`
- `Beta(T).fill`
- `Beta(T).fillFrom`
- `VectorBeta(VectorType)`
- `VectorBeta(VectorType).init`
- `VectorBeta(VectorType).alphaValue`
- `VectorBeta(VectorType).betaValue`
- `VectorBeta(VectorType).expectedValue`
- `VectorBeta(VectorType).varianceValue`
- `VectorBeta(VectorType).modeValue`
- `VectorBeta(VectorType).minValue`
- `VectorBeta(VectorType).maxValue`
- `VectorBeta(VectorType).sample`
- `VectorBeta(VectorType).sampleFrom`
- `VectorBeta(VectorType).fill`
- `VectorBeta(VectorType).fillFrom`
- `FisherF(T)`
- `FisherF(T).init`
- `FisherF(T).d1Value`
- `FisherF(T).d2Value`
- `FisherF(T).expectedValue`
- `FisherF(T).varianceValue`
- `FisherF(T).minValue`
- `FisherF(T).maxValue`
- `FisherF(T).sample`
- `FisherF(T).sampleFrom`
- `FisherF(T).fill`
- `FisherF(T).fillFrom`
- `VectorFisherF(VectorType)`
- `VectorFisherF(VectorType).init`
- `VectorFisherF(VectorType).d1Value`
- `VectorFisherF(VectorType).d2Value`
- `VectorFisherF(VectorType).expectedValue`
- `VectorFisherF(VectorType).varianceValue`
- `VectorFisherF(VectorType).minValue`
- `VectorFisherF(VectorType).maxValue`
- `VectorFisherF(VectorType).sample`
- `VectorFisherF(VectorType).sampleFrom`
- `VectorFisherF(VectorType).fill`
- `VectorFisherF(VectorType).fillFrom`
- `StudentT(T)`
- `StudentT(T).init`
- `StudentT(T).dofValue`
- `StudentT(T).expectedValue`
- `StudentT(T).varianceValue`
- `StudentT(T).minValue`
- `StudentT(T).maxValue`
- `StudentT(T).sample`
- `StudentT(T).sampleFrom`
- `StudentT(T).fill`
- `StudentT(T).fillFrom`
- `Triangular(T)`
- `Triangular(T).init`
- `Triangular(T).minValue`
- `Triangular(T).modeValue`
- `Triangular(T).maxValue`
- `Triangular(T).expectedValue`
- `Triangular(T).varianceValue`
- `Triangular(T).medianValue`
- `Triangular(T).sample`
- `Triangular(T).sampleFrom`
- `Triangular(T).fill`
- `Triangular(T).fillFrom`
- `Arcsine(T)`
- `Arcsine(T).init`
- `Arcsine(T).minValue`
- `Arcsine(T).maxValue`
- `Arcsine(T).expectedValue`
- `Arcsine(T).varianceValue`
- `Arcsine(T).medianValue`
- `Arcsine(T).sample`
- `Arcsine(T).sampleFrom`
- `Arcsine(T).fill`
- `Arcsine(T).fillFrom`
- `Cauchy(T)`
- `Cauchy(T).init`
- `Cauchy(T).medianValue`
- `Cauchy(T).modeValue`
- `Cauchy(T).scaleValue`
- `Cauchy(T).expectedValue`
- `Cauchy(T).varianceValue`
- `Cauchy(T).minValue`
- `Cauchy(T).maxValue`
- `Cauchy(T).sample`
- `Cauchy(T).sampleFrom`
- `Cauchy(T).fill`
- `Cauchy(T).fillFrom`
- `Laplace(T)`
- `Laplace(T).init`
- `Laplace(T).locationValue`
- `Laplace(T).scaleValue`
- `Laplace(T).medianValue`
- `Laplace(T).modeValue`
- `Laplace(T).expectedValue`
- `Laplace(T).varianceValue`
- `Laplace(T).minValue`
- `Laplace(T).maxValue`
- `Laplace(T).sample`
- `Laplace(T).sampleFrom`
- `Laplace(T).fill`
- `Laplace(T).fillFrom`
- `Logistic(T)`
- `Logistic(T).init`
- `Logistic(T).locationValue`
- `Logistic(T).scaleValue`
- `Logistic(T).medianValue`
- `Logistic(T).modeValue`
- `Logistic(T).expectedValue`
- `Logistic(T).varianceValue`
- `Logistic(T).minValue`
- `Logistic(T).maxValue`
- `Logistic(T).sample`
- `Logistic(T).sampleFrom`
- `Logistic(T).fill`
- `Logistic(T).fillFrom`
- `LogLogistic(T)`
- `LogLogistic(T).init`
- `LogLogistic(T).scaleValue`
- `LogLogistic(T).shapeValue`
- `LogLogistic(T).expectedValue`
- `LogLogistic(T).varianceValue`
- `LogLogistic(T).medianValue`
- `LogLogistic(T).modeValue`
- `LogLogistic(T).minValue`
- `LogLogistic(T).maxValue`
- `LogLogistic(T).sample`
- `LogLogistic(T).sampleFrom`
- `LogLogistic(T).fill`
- `LogLogistic(T).fillFrom`
- `Kumaraswamy(T)`
- `Kumaraswamy(T).init`
- `Kumaraswamy(T).alphaValue`
- `Kumaraswamy(T).betaValue`
- `Kumaraswamy(T).expectedValue`
- `Kumaraswamy(T).varianceValue`
- `Kumaraswamy(T).modeValue`
- `Kumaraswamy(T).medianValue`
- `Kumaraswamy(T).minValue`
- `Kumaraswamy(T).maxValue`
- `Kumaraswamy(T).sample`
- `Kumaraswamy(T).sampleFrom`
- `Kumaraswamy(T).fill`
- `Kumaraswamy(T).fillFrom`
- `PowerFunction(T)`
- `PowerFunction(T).init`
- `PowerFunction(T).minValue`
- `PowerFunction(T).maxValue`
- `PowerFunction(T).shapeValue`
- `PowerFunction(T).expectedValue`
- `PowerFunction(T).varianceValue`
- `PowerFunction(T).medianValue`
- `PowerFunction(T).sample`
- `PowerFunction(T).sampleFrom`
- `PowerFunction(T).fill`
- `PowerFunction(T).fillFrom`
- `Rayleigh(T)`
- `Rayleigh(T).init`
- `Rayleigh(T).scaleValue`
- `Rayleigh(T).expectedValue`
- `Rayleigh(T).varianceValue`
- `Rayleigh(T).medianValue`
- `Rayleigh(T).modeValue`
- `Rayleigh(T).minValue`
- `Rayleigh(T).maxValue`
- `Rayleigh(T).sample`
- `Rayleigh(T).sampleFrom`
- `Rayleigh(T).fill`
- `Rayleigh(T).fillFrom`
- `Maxwell(T)`
- `Maxwell(T).init`
- `Maxwell(T).scaleValue`
- `Maxwell(T).expectedValue`
- `Maxwell(T).varianceValue`
- `Maxwell(T).modeValue`
- `Maxwell(T).minValue`
- `Maxwell(T).maxValue`
- `Maxwell(T).sample`
- `Maxwell(T).sampleFrom`
- `Maxwell(T).fill`
- `Maxwell(T).fillFrom`
- `Pareto(T)`
- `Pareto(T).init`
- `Pareto(T).scaleValue`
- `Pareto(T).shapeValue`
- `Pareto(T).expectedValue`
- `Pareto(T).varianceValue`
- `Pareto(T).medianValue`
- `Pareto(T).modeValue`
- `Pareto(T).minValue`
- `Pareto(T).maxValue`
- `Pareto(T).sample`
- `Pareto(T).sampleFrom`
- `Pareto(T).fill`
- `Pareto(T).fillFrom`
- `Weibull(T)`
- `Weibull(T).init`
- `Weibull(T).scaleValue`
- `Weibull(T).shapeValue`
- `Weibull(T).expectedValue`
- `Weibull(T).varianceValue`
- `Weibull(T).medianValue`
- `Weibull(T).modeValue`
- `Weibull(T).minValue`
- `Weibull(T).maxValue`
- `Weibull(T).sample`
- `Weibull(T).sampleFrom`
- `Weibull(T).fill`
- `Weibull(T).fillFrom`
- `Gumbel(T)`
- `Gumbel(T).init`
- `Gumbel(T).locationValue`
- `Gumbel(T).scaleValue`
- `Gumbel(T).expectedValue`
- `Gumbel(T).varianceValue`
- `Gumbel(T).medianValue`
- `Gumbel(T).modeValue`
- `Gumbel(T).minValue`
- `Gumbel(T).maxValue`
- `Gumbel(T).sample`
- `Gumbel(T).sampleFrom`
- `Gumbel(T).fill`
- `Gumbel(T).fillFrom`
- `Frechet(T)`
- `Frechet(T).init`
- `Frechet(T).locationValue`
- `Frechet(T).scaleValue`
- `Frechet(T).shapeValue`
- `Frechet(T).expectedValue`
- `Frechet(T).varianceValue`
- `Frechet(T).medianValue`
- `Frechet(T).modeValue`
- `Frechet(T).minValue`
- `Frechet(T).maxValue`
- `Frechet(T).sample`
- `Frechet(T).sampleFrom`
- `Frechet(T).fill`
- `Frechet(T).fillFrom`
- `SkewNormal(T)`
- `SkewNormal(T).init`
- `SkewNormal(T).locationValue`
- `SkewNormal(T).scaleValue`
- `SkewNormal(T).shapeValue`
- `SkewNormal(T).expectedValue`
- `SkewNormal(T).varianceValue`
- `SkewNormal(T).minValue`
- `SkewNormal(T).maxValue`
- `SkewNormal(T).sample`
- `SkewNormal(T).sampleFrom`
- `SkewNormal(T).fill`
- `SkewNormal(T).fillFrom`
- `Pert(T)`
- `Pert(T).init`
- `Pert(T).initDefault`
- `Pert(T).initRange`
- `Pert(T).initMean`
- `Pert(T).minValue`
- `Pert(T).maxValue`
- `Pert(T).shapeValue`
- `Pert(T).modeValue`
- `Pert(T).alphaValue`
- `Pert(T).betaValue`
- `Pert(T).expectedValue`
- `Pert(T).varianceValue`
- `PertBuilder(T).minValue`
- `PertBuilder(T).maxValue`
- `PertBuilder(T).shapeValue`
- `PertBuilder(T).withShape`
- `PertBuilder(T).withMode`
- `PertBuilder(T).withMean`
- `Pert(T).sample`
- `Pert(T).sampleFrom`
- `Pert(T).fill`
- `Pert(T).fillFrom`
- `InverseGaussian(T)`
- `InverseGaussian(T).init`
- `InverseGaussian(T).meanValue`
- `InverseGaussian(T).shapeValue`
- `InverseGaussian(T).expectedValue`
- `InverseGaussian(T).varianceValue`
- `InverseGaussian(T).minValue`
- `InverseGaussian(T).maxValue`
- `InverseGaussian(T).sample`
- `InverseGaussian(T).sampleFrom`
- `InverseGaussian(T).fill`
- `InverseGaussian(T).fillFrom`
- `NormalInverseGaussian(T)`
- `NormalInverseGaussian(T).init`
- `NormalInverseGaussian(T).alphaValue`
- `NormalInverseGaussian(T).betaValue`
- `NormalInverseGaussian(T).gammaValue`
- `NormalInverseGaussian(T).expectedValue`
- `NormalInverseGaussian(T).varianceValue`
- `NormalInverseGaussian(T).minValue`
- `NormalInverseGaussian(T).maxValue`
- `NormalInverseGaussian(T).sample`
- `NormalInverseGaussian(T).sampleFrom`
- `NormalInverseGaussian(T).fill`
- `NormalInverseGaussian(T).fillFrom`
- `Zipf(T)`
- `Zipf(T).init`
- `Zipf(T).nValue`
- `Zipf(T).minValue`
- `Zipf(T).maxValue`
- `Zipf(T).exponentValue`
- `Zipf(T).sample`
- `Zipf(T).sampleFrom`
- `Zipf(T).fill`
- `Zipf(T).fillFrom`
- `Zeta(T)`
- `Zeta(T).init`
- `Zeta(T).exponentValue`
- `Zeta(T).minValue`
- `Zeta(T).maxValue`
- `Zeta(T).sample`
- `Zeta(T).sampleFrom`
- `Zeta(T).fill`
- `Zeta(T).fillFrom`
- `UnitCircle(T)`
- `UnitCircle(T).dimensionValue`
- `UnitCircle(T).radiusValue`
- `UnitCircle(T).isSurface`
- `UnitCircle(T).coordinateExpectedValue`
- `UnitCircle(T).coordinateVarianceValue`
- `UnitCircle(T).radialExpectedValue`
- `UnitCircle(T).radialVarianceValue`
- `UnitCircle(T).sample`
- `UnitCircle(T).sampleFrom`
- `UnitCircle(T).fill`
- `UnitCircle(T).fillFrom`
- `UnitDisc(T)`
- `UnitDisc(T).dimensionValue`
- `UnitDisc(T).radiusValue`
- `UnitDisc(T).isSurface`
- `UnitDisc(T).coordinateExpectedValue`
- `UnitDisc(T).coordinateVarianceValue`
- `UnitDisc(T).radialExpectedValue`
- `UnitDisc(T).radialVarianceValue`
- `UnitDisc(T).sample`
- `UnitDisc(T).sampleFrom`
- `UnitDisc(T).fill`
- `UnitDisc(T).fillFrom`
- `UnitSphere(T)`
- `UnitSphere(T).dimensionValue`
- `UnitSphere(T).radiusValue`
- `UnitSphere(T).isSurface`
- `UnitSphere(T).coordinateExpectedValue`
- `UnitSphere(T).coordinateVarianceValue`
- `UnitSphere(T).radialExpectedValue`
- `UnitSphere(T).radialVarianceValue`
- `UnitSphere(T).sample`
- `UnitSphere(T).sampleFrom`
- `UnitSphere(T).fill`
- `UnitSphere(T).fillFrom`
- `UnitBall(T)`
- `UnitBall(T).dimensionValue`
- `UnitBall(T).radiusValue`
- `UnitBall(T).isSurface`
- `UnitBall(T).coordinateExpectedValue`
- `UnitBall(T).coordinateVarianceValue`
- `UnitBall(T).radialExpectedValue`
- `UnitBall(T).radialVarianceValue`
- `UnitBall(T).sample`
- `UnitBall(T).sampleFrom`
- `UnitBall(T).fill`
- `UnitBall(T).fillFrom`
- `Dirichlet(T)`
- `Dirichlet(T).init`
- `Dirichlet(T).alphaValues`
- `Dirichlet(T).alphaAt`
- `Dirichlet(T).meanAt`
- `Dirichlet(T).means`
- `Dirichlet(T).meansInto`
- `Dirichlet(T).varianceAt`
- `Dirichlet(T).variances`
- `Dirichlet(T).variancesInto`
- `Dirichlet(T).covarianceAt`
- `Dirichlet(T).covariances`
- `Dirichlet(T).covariancesInto`
- `Dirichlet(T).dimensionValue`
- `Dirichlet(T).totalAlphaValue`
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
- `AliasTable.isEmpty`
- `AliasTable.totalWeight`
- `AliasTable.weights`
- `AliasTable.weightsInto`
- `AliasTable.probabilities`
- `AliasTable.probabilitiesInto`
- `AliasTable.weightAt`
- `AliasTable.probabilityAt`
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
- `WeightedTree.weightAt`
- `WeightedTree.probabilityAt`
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
- `WeightedTree.probabilities`
- `WeightedTree.probabilitiesInto`
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
- `WeightedIntTree.weightAt`
- `WeightedIntTree.probabilityAt`
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
- `WeightedIntTree.probabilities`
- `WeightedIntTree.probabilitiesInto`
- `WeightedIntTree.isValid`
- `WeightedIntTree.deinit`

## Sequence Sampling

- Error type: `Error`
- Index vectors: `IndexVec.len`, `IndexVec.isEmpty`, `IndexVec.at`,
  `IndexVec.indexOf`, `IndexVec.contains`, `IndexVec.copyInto`,
  `IndexVec.toOwnedSlice`, `IndexVec.iter`,
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
  `Choice.init`, `Choice.initChecked`, `Choice.len`, `Choice.isEmpty`,
  `Choice.itemsValue`, `Choice.itemAt`, `Choice.probabilityAt`,
  `Choice.probabilities`, `Choice.probabilitiesInto`,
  `Choice.sample`,
  `Choice.sampleFrom`, `Choice.sampleValue`, `Choice.sampleValueFrom`,
  `Choice.fill`, `Choice.fillFrom`,
  `Choice.fillValues`, `Choice.fillValuesFrom`, `Choice.iter`,
  `Choice.iterFrom`,
  `WeightedChoice.init`, `WeightedChoice.deinit`, `WeightedChoice.len`,
  `WeightedChoice.isEmpty`,
  `WeightedChoice.itemsValue`, `WeightedChoice.itemAt`,
  `WeightedChoice.totalWeight`, `WeightedChoice.weights`,
  `WeightedChoice.weightsInto`, `WeightedChoice.probabilities`,
  `WeightedChoice.probabilitiesInto`, `WeightedChoice.weightAt`,
  `WeightedChoice.probabilityAt`,
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
- Charset type: `Charset.init`, `Charset.initChecked`, `Charset.bytesValue`,
  `Charset.len`, `Charset.isEmpty`, `Charset.byteAt`, `Charset.indexOf`,
  `Charset.contains`, `Charset.probabilityAt`,
  `Charset.probabilities`, `Charset.probabilitiesInto`, `Charset.sample`,
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
