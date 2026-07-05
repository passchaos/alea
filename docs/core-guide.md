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
- `Xoshiro128PlusPlus`: Rust-discoverable 32-bit Xoshiro++ portable generator
  matching local Rust's `rand::rngs::Xoshiro128PlusPlus` algorithm and seed
  vectors; this is separate from local 64-bit `SmallRng`.
- `ChaCha8Rng`: Rust-discoverable optional-`chacha` ChaCha8 stream for users
  intentionally matching local Rust's faster lower-round named generator.
- `ChaCha12Rng = SecurePrng`: Rust-discoverable named ChaCha12 RNG alias,
  matching local Rust's optional `rand::rngs::ChaCha12Rng` discovery.
- `ChaCha20Rng`: Rust-discoverable optional-`chacha` ChaCha20 stream for users
  intentionally matching local Rust's higher-round named generator.
- `StdRng = SecurePrng`: Rust-discoverable standard secure-style RNG alias,
  mirroring local Rust `rand::rngs::StdRng` discovery while preserving Alea's
  explicit `SecurePrng` name.
- `SmallRng = Xoshiro256PlusPlus`: Rust-discoverable small fast RNG alias,
  matching the current local Rust 64-bit `SmallRng` family in Zig-native form.
- `rngs`: a Rust-discoverable namespace for local `rand::rngs::*` comparisons,
  re-exporting Alea's explicit `StdRng`, `SmallRng`, `SysRng`, `SysError`,
  `ChaCha8Rng`, `ChaCha12Rng`, `ChaCha20Rng`, `Xoshiro128PlusPlus`, and
  `Xoshiro256PlusPlus` names without adding Rust's implicit thread-local
  `ThreadRng` model.
- `prelude`: a Rust-discoverable convenience namespace for local
  `rand::prelude::*` comparisons, re-exporting Alea's common modules and
  aliases (`Rng`, `Seed`, `distributions`, `seq`, `ascii`, `StdRng`,
  `SmallRng`, `SysRng`, `SysError`, and `WeightError`) without adding Rust
  traits.
- `StepRng`: deterministic arithmetic-sequence mock source for tests, byte
  stream adapters, and reproducibility examples; use `stepRng(initial,
  increment)` or `constRng(value)` at the root for Rust-discoverable
  construction.

Every engine exposes `next() u64`, `fill([]u8)`, and `random() std.Random`.
Use `alea.Rng.init(&engine)` when you want the ergonomic facade, and direct
engine helpers when benchmark shape matters.
Seedable production engines expose Rust-discoverable `seedFromU64(seed)`
aliases for their deterministic `u64` constructors, mirroring local Rust
`SeedableRng::seed_from_u64` naming while preserving Zig-native `init` /
`initFromU64`. StepRng instead uses `new(initial, increment)` /
`stepRng(initial, increment)` and `constant(value)` / `constRng(value)`.
Seedable production engines also expose `fromSeed(seed)` aliases for Alea `Seed` values, mirroring
local Rust `SeedableRng::from_seed` naming while keeping `Seed.stream(...)`
and `Seed.mix(...)` as the Zig-native derivation tools.
Use `fromSeedBytes(seed)` when you need the Rust-style fixed byte-array seed
shape directly: scalar engines accept 8 bytes, `Pcg64` and
`Xoshiro128PlusPlus` accept 16 bytes, and 32-byte-state/key engines accept
32 bytes. Integer state bytes are interpreted as little-endian words, with
Xoshiro all-zero states remapped through `init(0)`.
`Seed.fromRng(source)`, direct-engine `fromRng(source)`, and engine `fork()`
mirror local Rust `SeedableRng::from_rng` / `fork` naming for deterministic
child derivation from an existing generator; `Seed.fromRng` consumes one `u64`
seed draw, while engine `fromRng` / `fork` consume enough `u64` seed material
to fill the target engine's state or key before constructing the child.
For fallible seed sources, `Seed.tryFromRng(source)` and engine
`tryFromRng(source)` mirror local Rust `SeedableRng::try_from_rng` naming using
a Zig-native `source.tryNext() !u64` contract and propagate source errors
without constructing a child. Engine `tryFork()` mirrors local Rust
`SeedableRng::try_fork` naming by delegating to `tryFromRng(self)`.
Direct engines also expose Rust-discoverable `nextU64()` / `nextU32()` aliases
and fallible-shaped `tryNext()` / `tryNextU64()` / `tryNextU32()` raw draws
(`fillBytes(out)` / `tryFillBytes(out)` where the engine has byte fills), so
callers can use local Rust raw-RNG terminology without wrapping in `Rng`.
The `Rng` facade also exposes Rust-discoverable raw aliases `nextU64()`,
`nextU32()`, `fillBytes(out)`, `tryNextU64()`, `tryNextU32()`, and
`tryFillBytes(out)` (plus `nextU64From`, `nextU32From`, and `fillBytesFrom`
for direct sources) for users mapping local Rust `Rng::next_u64`,
`Rng::next_u32`, `Rng::fill_bytes`, and `TryRng::try_*` terminology.
Use `rng.reader(buffer)`, `Rng.readerFrom(source, buffer)`,
`Rng.rngReader(source, buffer)`, or the root `rngReader(source, buffer)` alias
when you need an infinite `std.Io.Reader` view over a random byte stream,
mirroring local Rust root `rand::RngReader` without introducing trait
machinery. The adapter owns value sources, borrows pointer
sources, fills `std.Io.Reader` destinations completely, and records the
underlying error in `lastError()` when a fallible source reports one through
`tryFillBytes`, `tryNextU64`, or `tryNext`.

## Seeding

Use `Seed.fromString`, `Seed.fromBytes`, `Seed.mix`, and `Seed.stream` for
stable named streams. Use `Seed.secure(io)`, `defaultSecure`, `fastSecure`,
`scalarSecure`, `hashSecure`, `reproducibleSecure`, `secure(io)`, or
`secureBytes` when the seed must come from system entropy. Use
`makeRng(Engine, io)` when you want the Rust-discoverable generic
`rand::make_rng` style entry point for any exported deterministic engine; it
fills the target engine's fixed byte seed from system entropy where possible.
Use `Rng.SysRng.init(io)`, the root `SysRng` alias, or the root `sysRng(io)`
constructor when you want a Rust-discoverable `rand::rngs::SysRng` style source
over `std.Io.randomSecure` itself. The root `SysError` alias mirrors local
Rust's `rand::rngs::SysError` discovery name as `SysRng.Error`. `SysRng`
exposes `tryNextU64`, `tryNextU32`, `tryFillBytes`, and
`reader(buffer)`, so it can seed engines through `tryFromRng`, fill direct
buffers, or stream entropy through the `RngReader` adapter while preserving
`std.Io.RandomSecureError` failures.
For local Rust top-level helper workflows, the root also exposes explicit-I/O
forms of `rand::random`, `random_iter`, `random_range`, `random_bool`,
`random_ratio`, and `fill`: use `random(T, io)`, `randomValue(T, io)`,
`randomIter(T, io)`, `randomRange(T, io, min, max)`,
`randomRangeAtMost(T, io, min, max)`, `randomBool(io, p)`,
`randomRatio(io, numerator, denominator)`, and `fill(T, io, dest)`. Checked
variants validate empty enums, invalid ranges, and invalid probabilities before
requesting entropy, and all root one-shot helpers require an explicit `std.Io`
instead of hiding a thread-local RNG.

See `compare/results/reproducibility-matrix.md` for stable-output expectations.
Run `zig build run-reproducible-streams` for a runnable example of named seeds,
substreams, engine aliases, `Xoshiro` split/jump, and `Pcg64.initTwo` stream
selection.

## Scalar Sampling

`Rng` supports:

- integers: `uint`, `uintLessThan`, `uintAtMost`, `fillUintLessThan`,
  `fillUintAtMost`, `uintLessThanBatch`, and `uintAtMostBatch`
- signed and unsigned ranges: `intRangeLessThan`, `intRangeAtMost`, plus
  Rust-discoverable `randomRange` / `randomRangeAtMost` aliases
- floats: `float`, `floatOpen`, `floatOpenClosed`, `floatRange`,
  `standardNormal`, `standardExponential`
- vectors: `value(@Vector(N, T))`, `vectorOpen`, `vectorOpenClosed`,
  `vectorRange`, `vectorChance`, `vectorRatio`, `vectorStandardNormal`,
  `vectorNormal`, `vectorStandardExponential`, `vectorExponential` for
  `f32`/`f64`, integer, and boolean lanes
- booleans: `boolean`, `booleanFrom`, `chance`, `chanceFrom`, `ratio`, `ratioFrom`,
  Rust-discoverable `randomBool` / `randomRatio` aliases, `fillChance`,
  `fillRatio`, `chanceBatch`, and `ratioBatch`
- durations: `durationRangeLessThan`, `durationRangeAtMost`,
  `durationRangeLessThanFrom`, `durationRangeAtMostFrom`,
  `durationRangeLessThanBatch`, and `durationRangeAtMostBatch`
- Unicode scalar values: `unicodeScalar`, `unicodeScalarFrom`,
  `fillUnicodeScalar`, `fillUnicodeScalarFrom`, `unicodeScalarBatch`, and
  `unicodeScalarBatchFrom`, plus `unicodeScalarRangeLessThan*`,
  `unicodeScalarRangeAtMost*`, `fillUnicodeScalarRangeLessThan*`,
  `fillUnicodeScalarRangeAtMost*`, `unicodeScalarRangeLessThanBatch*`, and
  `unicodeScalarRangeAtMostBatch*` for bounded Unicode scalar ranges
- structured values: `value(T)` / `valueFrom(source, T)` plus
  Rust-discoverable `randomValue(T)` / `randomValueFrom(source, T)` for bools,
  ints, floats, vectors, enums, arrays, and tuples; use `valueChecked` /
  `valueCheckedFrom` or `enumValueChecked` / `enumValueCheckedFrom` when an
  empty enum type should be reported as `EmptyRange` (zero-length arrays are
  valid even when their child type is not sampled, while non-empty arrays or
  tuples containing an empty enum fail before consuming randomness)
- allocation-returning repeated sampling: `valueBatch`, `valueBatchFrom`,
  `valueBatchChecked`, `valueBatchCheckedFrom`, `sampleBatch`,
  `sampleBatchFrom`, `uintLessThanBatch`, `uintLessThanBatchFrom`,
  `uintLessThanBatchChecked`, `uintLessThanBatchCheckedFrom`,
  `uintAtMostBatch`, `uintAtMostBatchFrom`, `rangeBatch`, `rangeBatchFrom`, `rangeBatchChecked`,
  `rangeBatchCheckedFrom`, `rangeAtMostBatch`, `rangeAtMostBatchFrom`,
  `rangeAtMostBatchChecked`, `rangeAtMostBatchCheckedFrom`, `openBatch`, `openBatchFrom`, `openClosedBatch`,
  `openClosedBatchFrom`, `chanceBatch`, `chanceBatchFrom`, `chanceBatchChecked`,
  `chanceBatchCheckedFrom`, `ratioBatch`, `ratioBatchFrom`,
  `ratioBatchChecked`, `ratioBatchCheckedFrom`, `standardNormalBatch`,
  `standardNormalBatchFrom`, `normalBatch`, `normalBatchFrom`,
  `normalBatchChecked`, `normalBatchCheckedFrom`,
  `standardExponentialBatch`, `standardExponentialBatchFrom`,
  `exponentialBatch`, `exponentialBatchFrom`, `exponentialBatchChecked`,
  `exponentialBatchCheckedFrom`, `durationRangeLessThanBatch`,
  `durationRangeLessThanBatchFrom`, `durationRangeLessThanBatchChecked`,
  `durationRangeLessThanBatchCheckedFrom`, `durationRangeAtMostBatch`,
  `durationRangeAtMostBatchFrom`, `durationRangeAtMostBatchChecked`,
  `durationRangeAtMostBatchCheckedFrom`, `vectorRangeBatch`,
  `vectorRangeBatchFrom`, `vectorRangeBatchChecked`, `vectorRangeBatchCheckedFrom`,
  `vectorRangeAtMostBatch`, `vectorRangeAtMostBatchFrom`,
  `vectorRangeAtMostBatchChecked`, `vectorRangeAtMostBatchCheckedFrom`,
  `vectorOpenBatch`, `vectorOpenBatchFrom`, `vectorOpenClosedBatch`,
  `vectorOpenClosedBatchFrom`, `vectorChanceBatch`, `vectorChanceBatchFrom`,
  `vectorChanceBatchChecked`, `vectorChanceBatchCheckedFrom`,
  `vectorRatioBatch`, `vectorRatioBatchFrom`, `vectorRatioBatchChecked`,
  `vectorRatioBatchCheckedFrom`, `vectorStandardNormalBatch`,
  `vectorStandardNormalBatchFrom`, `vectorNormalBatch`,
  `vectorNormalBatchFrom`, `vectorNormalBatchChecked`,
  `vectorNormalBatchCheckedFrom`, `vectorExponentialBatch`,
  `vectorExponentialBatchFrom`, `vectorExponentialBatchChecked`,
  `vectorStandardExponentialBatch`, `vectorStandardExponentialBatchFrom`, and
  `vectorExponentialBatchCheckedFrom` allocate owned slices after validating
  no-consume checked cases; use these when an owned result is more ergonomic
  than a caller buffer or iterator loop
- owned byte buffers: `bytesAlloc` / `bytesAllocFrom` allocate random byte slices after allocation succeeds; use `bytes`, Rust-discoverable `fillBytes`, or `fill(u8, ...)` for caller-owned buffers
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
for ranges, probability vectors,
Bernoulli/binomial/binomial-approx/negative-binomial/hypergeometric/geometric/standard-geometric/Poisson/Poisson-AD vectors,
and parameterized normal/exponential vectors/fills when the engine type is
comptime-known.
Run `zig build run-range-sampling` for a runnable comparison of integer ranges,
strict float intervals, bulk range fills, `StandardUniform`, reusable `Uniform`
samplers, vector ranges, duration ranges, collapsed point-masses, and checked
range errors.
`distributions.StandardUniform` is the distribution-namespace equivalent of
`Rng.value(T)` / `Rng.valueFrom(source, T)` for local Rust
`rand::distr::StandardUniform` discovery: `sample` / `sampleFrom` draw any
supported scalar, vector, enum, array, or tuple value, while `fill` / `fillFrom`
bulk-fill integer, float, bool, and vector slices through the same
stream-compatible `Rng.fill` fast paths and fill enum or compound array/tuple
slices via repeated `valueFrom` draws.
Reusable scalar and vector uniform samplers keep Zig-native `init` /
`initInclusive` constructors and also expose Rust-discoverable `new` /
`newInclusive` aliases and `UniformError` discovery matching local Rust `Uniform::new` /
`Uniform::new_inclusive` semantics, including separate `NonFinite` errors for
non-finite floating-point endpoints or widths. Rust `Uniform::try_from(range)`
workflows map to Zig-native `tryFromRange` / `tryFromRangeInclusive` aliases on
scalar and vector `Uniform` samplers. `UniformInt(T)`, `UniformFloat(T)`, and
`UniformUsize` are discovery aliases over `Uniform(T)` for callers comparing
against local Rust uniform backend names. `UniformDuration` provides the same reusable
half-open/inclusive sampler shape for `std.Io.Duration`, matching local Rust
`UniformDuration` discovery while delegating to Alea's duration range helpers.
The distribution namespace also exposes
Rust-discoverable one-shot checked aliases `sampleSingle` /
`sampleSingleInclusive` (plus direct-source `From` variants), mirroring local
Rust `UniformSampler::sample_single` naming while preserving the existing
`uniformChecked*` helpers.
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
Bernoulli (`new` / `newRatio` / `fromRatio` aliases plus `init` /
`initRatio`, Rust-discoverable `p()` probability lookup, and the
`BernoulliError` invalid-probability error type), Binomial,
NegativeBinomial, Poisson, Geometric trial/failure counts, Hypergeometric, and
vector discrete samplers.
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
  (`distributions.map(In, Out, sampler, mapper)` / `MappedSampler.map`
  adapt reusable sampler outputs through Zig structs exposing `map`, `apply`,
  or `call`, and the distribution namespace exposes Rust-discoverable
  `Map(Sampler, Mapper, In, Out)` / `Iter(Sampler, Source, T)` type aliases
  without adding trait machinery)
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
called through the Rust-discoverable `rng.sample(T, sampler)` /
`Rng.sampleFrom(source, T, sampler)` facade aliases, or used with
`rng.sampleIter(T, sampler)` /
`Rng.sampleIterFrom(source, T, sampler)` when the sample type is scalar. The
distribution namespace (`distributions`, also available as root `distr` for
local Rust `rand::distr::*` comparisons) also exposes `sampleIter(rng, T, sampler)` and
`sampleIterFrom(source, T, sampler)` aliases for callers looking for the local
Rust `Distribution::sample_iter` shape. These unbounded iterators expose
`sizeHint()` as `usize.max..unbounded` while
`fill` methods inherit sampler-specific bulk fills where available.
`valueIter(T)` / `valueIterFrom(source, T)` likewise expose the same unbounded
`sizeHint()` and delegate
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
  `Rng.chooseIndexU32CheckedFrom`, `Rng.fillChooseIndexFrom`,
  `Rng.fillChooseIndexU32From`, `Rng.chooseIndexBatchFrom`,
  `Rng.chooseIndexU32BatchFrom`, `rng.choose`, `Rng.chooseFrom`,
  `Rng.chooseCheckedFrom`, `Rng.fillChooseFrom`, `Rng.chooseValueArrayFrom`,
  `Rng.chooseBatchFrom`, `rng.chooseConstPtr`, `Rng.chooseConstPtrFrom`,
  `Rng.chooseConstPtrCheckedFrom`, `Rng.chooseConstPtrArrayFrom`,
  `Rng.fillChooseConstPtrFrom`, `Rng.chooseConstPtrBatchFrom`, `rng.choosePtr`, `Rng.choosePtrFrom`,
  `Rng.choosePtrCheckedFrom`, `Rng.choosePtrArrayFrom`,
  `Rng.fillChoosePtrFrom`, `Rng.choosePtrBatchFrom`
- `rng.shuffle`, `Rng.shuffleFrom`
- `seq.shuffle`, `seq.shuffleFrom`, `seq.partialShuffle`, `seq.partialShuffleFrom`,
  `seq.partialShuffleCheckedFrom`, `seq.partialShuffleSplitFrom`,
  `seq.partialShuffleSplitCheckedFrom`, `seq.partialShuffleTailFrom`,
  `seq.partialShuffleTailCheckedFrom`, `seq.partialShuffleTailSplitFrom`,
  `seq.partialShuffleTailSplitCheckedFrom`
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
  owned-backing adoption via `fromOwnedSlice` / `fromOwnedU32Slice`,
  representation-preserving deep `clone`, `len`, `isEmpty`, `at` / `index`,
  optional checked positional `get`,
  representation-independent `eql`, `copyInto`, `copyIntoU32`,
  `toOwnedSlice`, `toOwnedU32Slice`, Rust-discoverable consuming `intoVec`,
  consuming `intoOwnedSlice` / `intoOwnedU32Slice`, a consuming `intoIter` with `remaining` / `len` /
  `sizeHint` / `fill` / `deinit`, and exact-size `iter` / mapped item iterators with
  `remaining` / `len` / `sizeHint` / `fill`, plus
  `values` / `ptrs` / `mutPtrs`, `valuesInto` / `ptrsInto` /
  `mutPtrsInto`, `valuesOwned` / `ptrsOwned` / `mutPtrsOwned`, and checked
  variants for mapping indexes back to slice items
- `seq.sampleArray`, `seq.sampleArrayFrom`, `seq.sampleArrayCheckedFrom`,
  `seq.sampleArrayU32`, `seq.sampleArrayU32From`,
  `seq.sampleArrayU32CheckedFrom`
- `seq.choose`, `seq.chooseFrom`, `seq.chooseCheckedFrom`,
  `seq.chooseConstPtrFrom`, `seq.chooseConstPtrCheckedFrom`,
  `seq.choosePtrFrom`, `seq.choosePtrCheckedFrom`,
  `seq.chooseIndexFrom`, `seq.chooseIndexCheckedFrom`,
  `seq.chooseIndexU32From`, `seq.chooseIndexU32CheckedFrom`,
  `seq.fillChooseFrom`, `seq.fillChooseCheckedFrom`,
  `seq.fillChooseConstPtrFrom`, `seq.fillChooseConstPtrCheckedFrom`,
  `seq.fillChoosePtrFrom`, `seq.fillChoosePtrCheckedFrom`,
  `seq.fillChooseIndexFrom`, `seq.fillChooseIndexCheckedFrom`,
  `seq.fillChooseIndexU32From`, `seq.fillChooseIndexU32CheckedFrom`,
  `seq.chooseRepeatedValueArrayFrom`,
  `seq.chooseRepeatedValueArrayCheckedFrom`,
  `seq.chooseRepeatedConstPtrArrayFrom`,
  `seq.chooseRepeatedConstPtrArrayCheckedFrom`,
  `seq.chooseRepeatedPtrArrayFrom`,
  `seq.chooseRepeatedPtrArrayCheckedFrom`,
  `seq.chooseBatchFrom`, `seq.chooseBatchCheckedFrom`,
  `seq.chooseConstPtrBatchFrom`, `seq.chooseConstPtrBatchCheckedFrom`,
  `seq.choosePtrBatchFrom`, `seq.choosePtrBatchCheckedFrom`,
  `seq.chooseIndexBatchFrom`, `seq.chooseIndexBatchCheckedFrom`,
  `seq.chooseIndexU32BatchFrom`, `seq.chooseIndexU32BatchCheckedFrom`,
  `seq.chooseMultiple`,
  `seq.chooseMultipleFrom`,
  `seq.chooseMultipleCheckedFrom`, sample aliases `seq.sampleItemsFrom` /
  `seq.sampleItemsCheckedFrom`, `seq.chooseMultiplePtrsFrom`,
  `seq.chooseMultiplePtrsCheckedFrom`, `seq.samplePtrsFrom` /
  `seq.samplePtrsCheckedFrom`, `seq.chooseMultipleMutPtrsFrom`,
  `seq.chooseMultipleMutPtrsCheckedFrom`, `seq.sampleMutPtrsFrom` /
  `seq.sampleMutPtrsCheckedFrom`, owned sampled iterator forms
  `seq.sampleItemsIterFrom` / `seq.samplePtrsIterFrom` /
  `seq.sampleMutPtrsIterFrom` expose exact `remaining` / `len` / `sizeHint`
  diagnostics plus caller-buffer `fill`, with `seq.IndexedSamples` /
  `seq.SliceChooseIter` aliases over sampled pointer iterators for local Rust
  `rand::seq` discovery, `seq.chooseMultipleIntoFrom`,
  `seq.chooseMultipleIntoCheckedFrom`, `seq.sampleItemsIntoFrom` /
  `seq.sampleItemsIntoCheckedFrom`, `seq.chooseMultiplePtrsIntoFrom`,
  `seq.chooseMultiplePtrsIntoCheckedFrom`, `seq.samplePtrsIntoFrom` /
  `seq.samplePtrsIntoCheckedFrom`,
  `seq.chooseMultipleMutPtrsIntoFrom`,
  `seq.chooseMultipleMutPtrsIntoCheckedFrom`, `seq.sampleMutPtrsIntoFrom` /
  `seq.sampleMutPtrsIntoCheckedFrom`, `seq.chooseArray`,
  `seq.chooseArrayFrom`, `seq.chooseArrayCheckedFrom`, sample-array aliases
  `seq.sampleItemsArrayFrom` / `seq.sampleItemsArrayCheckedFrom`,
  `seq.choosePtrArrayFrom`, `seq.choosePtrArrayCheckedFrom`,
  `seq.samplePtrArrayFrom` / `seq.samplePtrArrayCheckedFrom`,
  `seq.chooseMutPtrArrayFrom`, `seq.chooseMutPtrArrayCheckedFrom`,
  `seq.sampleMutPtrArrayFrom` / `seq.sampleMutPtrArrayCheckedFrom`
  (`chooseRepeated*Array` is with-replacement; `chooseArray` /
  `choosePtrArray` / `chooseMutPtrArray` and `sample*Array` are
  no-replacement)
- `seq.chooseIterator`, `seq.chooseIteratorFrom`,
  `seq.chooseIteratorCheckedFrom`, hint-sensitive exact-size aliases
  `seq.chooseIteratorHintedFrom` / `seq.chooseIteratorHintedCheckedFrom` for
  local Rust `IteratorRandom::choose`-style workflows, stable aliases
  `seq.chooseIteratorStableFrom` and `seq.chooseIteratorStableCheckedFrom`,
  `seq.sampleIterator`, `seq.sampleIteratorFrom`,
  `seq.sampleIteratorCheckedFrom`, `seq.sampleIteratorArrayFrom`,
  `seq.sampleIteratorArrayCheckedFrom`, `seq.sampleIteratorInto`,
  `seq.sampleIteratorIntoFrom`, `seq.sampleIteratorIntoCheckedFrom`,
  `seq.sampleIteratorFillFrom`, `seq.sampleIteratorFillCheckedFrom`
- `seq.chooseIteratorWeighted`, `seq.chooseIteratorWeightedFrom`,
  `seq.chooseIteratorWeightedCheckedFrom`, `seq.sampleIteratorWeighted`,
  `seq.sampleIteratorWeightedFrom`, `seq.sampleIteratorWeightedCheckedFrom`,
  `seq.sampleIteratorWeightedArrayFrom`,
  `seq.sampleIteratorWeightedArrayCheckedFrom`,
  `seq.sampleIteratorWeightedIntoFrom`,
  `seq.sampleIteratorWeightedIntoCheckedFrom`
- `WeightError` / `seq.WeightError` aliases for local Rust `rand::seq::WeightError`
  discovery, and `distributions.WeightError` / `distributions.WeightedError`
  aliases for local Rust `rand::distr::weighted::Error` discovery; static
  `AliasTable` / `WeightedIndex` construction and updates report
  `InvalidInput`, `InvalidWeight`, `InsufficientNonZero`, and `Overflow`
  diagnostics matching local Rust weighted error names, plus `Rng.weightedIndexFrom`, `Rng.fillWeightedIndexFrom`,
  `Rng.weightedIndexArrayFrom`, `Rng.weightedIndexBatchFrom`,
  `Rng.fillWeightedIndexU32From`, `Rng.weightedIndexU32ArrayFrom`,
  `Rng.weightedIndexU32BatchFrom`, `Rng.fillChooseWeightedFrom`,
  `Rng.chooseWeightedValueArrayFrom`, `Rng.chooseWeightedBatchFrom`,
  `Rng.fillChooseWeightedConstPtrFrom`,
  `Rng.chooseWeightedConstPtrArrayFrom`, `Rng.chooseWeightedConstPtrBatchFrom`,
  `Rng.fillChooseWeightedPtrFrom`, `Rng.chooseWeightedPtrArrayFrom`,
  `Rng.chooseWeightedPtrBatchFrom`, `seq.weightedIndex`, `seq.weightedIndexFrom`,
  `seq.weightedIndexCheckedFrom`, `seq.fillWeightedIndexFrom`,
  `seq.weightedIndexArrayFrom`, `seq.weightedIndexBatchFrom`, `seq.weightedIndexU32From`,
  `seq.weightedIndexU32CheckedFrom`, `seq.fillWeightedIndexU32From`,
  `seq.weightedIndexU32ArrayFrom`, `seq.weightedIndexU32BatchFrom`, `seq.weightedIndexByIndexFrom`,
  `seq.weightedIndexByIndexCheckedFrom`, `seq.weightedIndexU32ByIndexFrom`,
  `seq.weightedIndexU32ByIndexCheckedFrom`, `seq.fillWeightedIndexByIndexFrom`,
  `seq.fillWeightedIndexByIndexCheckedFrom`,
  `seq.fillWeightedIndexU32ByIndexFrom`,
  `seq.fillWeightedIndexU32ByIndexCheckedFrom`,
  `seq.weightedIndexBatchByIndexFrom`,
  `seq.weightedIndexBatchByIndexCheckedFrom`,
  `seq.weightedIndexU32BatchByIndexFrom`,
  `seq.weightedIndexU32BatchByIndexCheckedFrom`,
  `seq.chooseWeightedByIndexFrom`, `seq.chooseWeightedByIndexCheckedFrom`,
  `seq.chooseWeightedConstPtrByIndexFrom`,
  `seq.chooseWeightedConstPtrByIndexCheckedFrom`,
  `seq.chooseWeightedPtrByIndexFrom`,
  `seq.chooseWeightedPtrByIndexCheckedFrom`,
  `seq.fillChooseWeightedByIndexFrom`,
  `seq.fillChooseWeightedByIndexCheckedFrom`,
  `seq.fillChooseWeightedConstPtrByIndexFrom`,
  `seq.fillChooseWeightedConstPtrByIndexCheckedFrom`,
  `seq.fillChooseWeightedPtrByIndexFrom`,
  `seq.fillChooseWeightedPtrByIndexCheckedFrom`,
  `seq.chooseWeightedBatchByIndexFrom`,
  `seq.chooseWeightedBatchByIndexCheckedFrom`,
  `seq.chooseWeightedConstPtrBatchByIndexFrom`,
  `seq.chooseWeightedConstPtrBatchByIndexCheckedFrom`,
  `seq.chooseWeightedPtrBatchByIndexFrom`,
  `seq.chooseWeightedPtrBatchByIndexCheckedFrom`, `seq.weightedIndexByFrom`,
  `seq.weightedIndexByCheckedFrom`, `seq.weightedIndexArrayByFrom`,
  `seq.weightedIndexArrayByCheckedFrom`, `seq.weightedIndexU32ByFrom`,
  `seq.weightedIndexU32ByCheckedFrom`, `seq.weightedIndexU32ArrayByFrom`,
  `seq.weightedIndexU32ArrayByCheckedFrom`, `seq.fillWeightedIndexByFrom`,
  `seq.fillWeightedIndexByCheckedFrom`, `seq.fillWeightedIndexU32ByFrom`,
  `seq.fillWeightedIndexU32ByCheckedFrom`, `seq.weightedIndexBatchByFrom`,
  `seq.weightedIndexBatchByCheckedFrom`, `seq.weightedIndexU32BatchByFrom`,
  `seq.weightedIndexU32BatchByCheckedFrom`, `seq.fillChooseWeightedFrom`,
  `seq.chooseWeightedValueArrayFrom`, `seq.chooseWeightedBatchFrom`,
  `seq.chooseWeightedIterFrom`, `seq.chooseWeightedIterCheckedFrom`,
  `seq.chooseWeightedIterByFrom`, `seq.chooseWeightedIterByCheckedFrom`,
  `seq.chooseWeightedIterByIndexFrom`,
  `seq.chooseWeightedIterByIndexCheckedFrom`, `seq.fillChooseWeightedConstPtrFrom`,
  `seq.chooseWeightedConstPtrArrayFrom`, `seq.chooseWeightedConstPtrBatchFrom`,
  `seq.fillChooseWeightedPtrFrom`,
  `seq.chooseWeightedPtrArrayFrom`, `seq.chooseWeightedPtrBatchFrom`
- `seq.chooseWeighted`, `seq.chooseWeightedFrom`,
  `seq.chooseWeightedCheckedFrom`, `seq.chooseWeightedConstPtrFrom`,
  `seq.chooseWeightedConstPtrCheckedFrom`, `seq.chooseWeightedPtr`,
  `seq.chooseWeightedPtrFrom`, `seq.chooseWeightedPtrCheckedFrom`,
  plus index-weighted one-shot and caller-owned `seq.weightedIndexByIndexFrom`,
  `seq.weightedIndexByIndexCheckedFrom`, `seq.weightedIndexU32ByIndexFrom`,
  `seq.weightedIndexU32ByIndexCheckedFrom`, `seq.fillWeightedIndexByIndexFrom`,
  `seq.fillWeightedIndexByIndexCheckedFrom`,
  `seq.fillWeightedIndexU32ByIndexFrom`,
  `seq.fillWeightedIndexU32ByIndexCheckedFrom`,
  `seq.weightedIndexBatchByIndexFrom`,
  `seq.weightedIndexBatchByIndexCheckedFrom`,
  `seq.weightedIndexU32BatchByIndexFrom`, and
  `seq.weightedIndexU32BatchByIndexCheckedFrom`, plus fixed-size repeated
  index-weighted `seq.weightedIndexArrayByIndexFrom`,
  `seq.weightedIndexArrayByIndexCheckedFrom`,
  `seq.weightedIndexU32ArrayByIndexFrom`, and
  `seq.weightedIndexU32ArrayByIndexCheckedFrom`, plus index-weighted
  value/const-pointer/mutable-pointer choices
  `seq.chooseWeightedByIndexFrom`,
  `seq.chooseWeightedByIndexCheckedFrom`,
  `seq.chooseWeightedConstPtrByIndexFrom`,
  `seq.chooseWeightedConstPtrByIndexCheckedFrom`,
  `seq.chooseWeightedPtrByIndexFrom`, and
  `seq.chooseWeightedPtrByIndexCheckedFrom`, plus fixed-size repeated
  index-weighted value/pointer arrays
  `seq.chooseWeightedValueArrayByIndexFrom`,
  `seq.chooseWeightedValueArrayByIndexCheckedFrom`,
  `seq.chooseWeightedConstPtrArrayByIndexFrom`,
  `seq.chooseWeightedConstPtrArrayByIndexCheckedFrom`,
  `seq.chooseWeightedPtrArrayByIndexFrom`, and
  `seq.chooseWeightedPtrArrayByIndexCheckedFrom`, plus caller-owned index-weighted
  repeated choices `seq.fillChooseWeightedByIndexFrom`,
  `seq.fillChooseWeightedByIndexCheckedFrom`,
  `seq.fillChooseWeightedConstPtrByIndexFrom`,
  `seq.fillChooseWeightedConstPtrByIndexCheckedFrom`,
  `seq.fillChooseWeightedPtrByIndexFrom`, and
  `seq.fillChooseWeightedPtrByIndexCheckedFrom`, plus allocation-returning
  index-weighted repeated choice batches `seq.chooseWeightedBatchByIndexFrom`,
  `seq.chooseWeightedBatchByIndexCheckedFrom`,
  `seq.chooseWeightedConstPtrBatchByIndexFrom`,
  `seq.chooseWeightedConstPtrBatchByIndexCheckedFrom`,
  `seq.chooseWeightedPtrBatchByIndexFrom`, and
  `seq.chooseWeightedPtrBatchByIndexCheckedFrom`, plus accessor-based
  `seq.weightedIndexByFrom`,
  `seq.weightedIndexByCheckedFrom`, `seq.weightedIndexArrayByFrom`,
  `seq.weightedIndexArrayByCheckedFrom`, `seq.weightedIndexU32ByFrom`,
  `seq.weightedIndexU32ByCheckedFrom`, `seq.weightedIndexU32ArrayByFrom`,
  `seq.weightedIndexU32ArrayByCheckedFrom`, `seq.fillWeightedIndexByFrom`,
  `seq.fillWeightedIndexByCheckedFrom`, `seq.fillWeightedIndexU32ByFrom`,
  `seq.fillWeightedIndexU32ByCheckedFrom`, `seq.weightedIndexBatchByFrom`,
  `seq.weightedIndexBatchByCheckedFrom`, `seq.weightedIndexU32BatchByFrom`,
  `seq.weightedIndexU32BatchByCheckedFrom`, `seq.chooseWeightedByFrom`,
  `seq.chooseWeightedByCheckedFrom`, `seq.chooseWeightedValueArrayByFrom`,
  `seq.chooseWeightedValueArrayByCheckedFrom`, `seq.chooseWeightedConstPtrByFrom`,
  `seq.chooseWeightedConstPtrByCheckedFrom`,
  `seq.chooseWeightedConstPtrArrayByFrom`,
  `seq.chooseWeightedConstPtrArrayByCheckedFrom`, `seq.chooseWeightedPtrByFrom`,
  `seq.chooseWeightedPtrByCheckedFrom`, `seq.chooseWeightedPtrArrayByFrom`,
  `seq.chooseWeightedPtrArrayByCheckedFrom`, plus caller-owned
  `seq.fillChooseWeightedByFrom`, `seq.fillChooseWeightedByCheckedFrom`,
  `seq.fillChooseWeightedConstPtrByFrom`,
  `seq.fillChooseWeightedConstPtrByCheckedFrom`,
  `seq.fillChooseWeightedPtrByFrom`, and
  `seq.fillChooseWeightedPtrByCheckedFrom`, plus allocation-returning
  `seq.chooseWeightedBatchByFrom`, `seq.chooseWeightedBatchByCheckedFrom`,
  `seq.chooseWeightedConstPtrBatchByFrom`,
  `seq.chooseWeightedConstPtrBatchByCheckedFrom`,
  `seq.chooseWeightedPtrBatchByFrom`, and
  `seq.chooseWeightedPtrBatchByCheckedFrom`, plus item-accessor fixed arrays
  `seq.weightedIndexArrayByFrom`, `seq.weightedIndexU32ArrayByFrom`,
  `seq.chooseWeightedValueArrayByFrom`,
  `seq.chooseWeightedConstPtrArrayByFrom`, and
  `seq.chooseWeightedPtrArrayByFrom`, plus generic-weight
  `seq.weightedIndexArrayFrom`, `seq.weightedIndexU32ArrayFrom`,
  `seq.chooseWeightedValueArrayFrom`,
  `seq.chooseWeightedConstPtrArrayFrom`, and
  `seq.chooseWeightedPtrArrayFrom` for fixed-size repeated with-replacement
  arrays, for Zig-native versions of Rust
  `choose_weighted`, `choose_weighted_mut`, and
  `choose_weighted_iter(...).take(n).collect()` when weights are fields or
  derived from items instead of parallel slices, and allocation-returning
  repeated length/index-weight index batches plus fixed-size
  `weightedIndex*ArrayByIndex` / `chooseWeighted*ArrayByIndex` arrays for
  `index::sample_weighted`-style index weight accessors, while
  `chooseWeighted*ByIndex` maps those length/index-weight choices back to values
  or pointers and
  `fillChooseWeighted*ByIndex` fills caller-owned repeated value/pointer buffers, and `chooseWeighted*BatchByIndex` allocates owned repeated value/pointer batches
- `seq.sampleWeightedIndices`, `seq.sampleWeightedIndicesFrom`,
  `seq.sampleWeightedIndicesCheckedFrom`, `seq.sampleWeightedIndicesU32From`,
  `seq.sampleWeightedIndicesU32CheckedFrom`, `seq.sampleWeightedIndexVecFrom`,
  `seq.sampleWeightedIndexVecCheckedFrom`,
  index-weight accessor helpers `seq.sampleWeightedIndicesByIndexFrom`,
  `seq.sampleWeightedIndicesByIndexCheckedFrom`,
  `seq.sampleWeightedIndicesU32ByIndexFrom`,
  `seq.sampleWeightedIndicesU32ByIndexCheckedFrom`,
  `seq.sampleWeightedIndexVecByIndexFrom`, and
  `seq.sampleWeightedIndexVecByIndexCheckedFrom` for Rust
  `index::sample_weighted(rng, length, |index| ...)`-style no-replacement
  workflows, plus
  caller-owned `seq.sampleWeightedIndicesByIndexIntoFrom`,
  `seq.sampleWeightedIndicesByIndexIntoCheckedFrom`,
  `seq.sampleWeightedIndicesU32ByIndexIntoFrom`, and
  `seq.sampleWeightedIndicesU32ByIndexIntoCheckedFrom`, plus fixed-size
  `seq.sampleWeightedIndexArrayByIndexFrom`,
  `seq.sampleWeightedIndexArrayByIndexCheckedFrom`,
  `seq.sampleWeightedIndexArrayU32ByIndexFrom`, and
  `seq.sampleWeightedIndexArrayU32ByIndexCheckedFrom`,
  item accessor-based
  `seq.sampleWeightedIndicesByFrom`, `seq.sampleWeightedIndicesByCheckedFrom`,
  `seq.sampleWeightedIndicesU32ByFrom`,
  `seq.sampleWeightedIndicesU32ByCheckedFrom`,
  `seq.sampleWeightedIndexVecByFrom`, and
  `seq.sampleWeightedIndexVecByCheckedFrom`, `seq.sampleWeightedIndicesIntoFrom`,
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
  accessor-based `seq.sampleWeightedByFrom`, `seq.sampleWeightedByCheckedFrom`,
  `seq.sampleWeightedPtrsByFrom`, `seq.sampleWeightedPtrsByCheckedFrom`,
  `seq.sampleWeightedMutPtrsByFrom`, and
  `seq.sampleWeightedMutPtrsByCheckedFrom` for Rust `sample_weighted`-style
  item-derived weights,
  `seq.sampleWeightedIntoFrom`, `seq.sampleWeightedIntoCheckedFrom`,
  `seq.sampleWeightedPtrsIntoFrom`, `seq.sampleWeightedPtrsIntoCheckedFrom`,
  `seq.sampleWeightedMutPtrsIntoFrom`,
  `seq.sampleWeightedMutPtrsIntoCheckedFrom`,
  accessor-based caller-owned `seq.sampleWeightedIndicesByIntoFrom`,
  `seq.sampleWeightedIndicesByIntoCheckedFrom`,
  `seq.sampleWeightedByIntoFrom`, `seq.sampleWeightedByIntoCheckedFrom`,
  `seq.sampleWeightedPtrsByIntoFrom`, `seq.sampleWeightedPtrsByIntoCheckedFrom`,
  `seq.sampleWeightedMutPtrsByIntoFrom`, and
  `seq.sampleWeightedMutPtrsByIntoCheckedFrom`,
  accessor-based fixed-size `seq.sampleWeightedArrayByFrom`,
  `seq.sampleWeightedArrayByCheckedFrom`, `seq.sampleWeightedPtrArrayByFrom`,
  `seq.sampleWeightedPtrArrayByCheckedFrom`, `seq.sampleWeightedMutPtrArrayByFrom`,
  `seq.sampleWeightedMutPtrArrayByCheckedFrom`, `seq.sampleWeightedArrayFrom`,
  `seq.sampleWeightedArrayCheckedFrom`, `seq.sampleWeightedPtrArrayFrom`,
  `seq.sampleWeightedPtrArrayCheckedFrom`, `seq.sampleWeightedMutPtrArrayFrom`,
  `seq.sampleWeightedMutPtrArrayCheckedFrom`
  (`*Checked*` variants require enough positive-weight entries for the
  requested amount; requesting zero samples returns an empty result before
  validating weights; facade and direct-source checked calls validate before
  drawing)
- `seq.Choice` plus distribution-namespace `distributions.Choose` and
  `distributions.slice.Choose` for local Rust `rand::distr::slice::Choose`
  discovery, with `distributions.slice.Empty` for the local Rust empty-slice
  error name, including Rust-discoverable
  `Choice.new` / `newChecked`, `seq.chooseIterFrom`, `seq.chooseIterCheckedFrom`,
  `seq.WeightedChoice`, including `Choice.iterFrom`, `Choice.sampleIndexFrom`,
  `Choice.constantIndex`, `Choice.item` / `itemAt` / `get`, `Choice.probability` / `probabilityAt`, lazy `Choice.probabilityIter` size hints,
  `Choice.sampleIndexU32From`, `Choice.fillValuesFrom` / `fillFrom`,
  `Choice.valuesFrom` / `ptrsFrom`, fixed-size `Choice.valueArrayFrom` /
  `ptrArrayFrom`, `Choice.fillIndicesFrom`,
  `Choice.fillIndicesU32From`, `Choice.indicesFrom`, `Choice.indicesU32From`,
  fixed-size `Choice.indexArrayFrom` / `indexArrayU32From`, and
  repeated `Choice.indexIterFrom` / `indexIterU32From` index streams,
  `WeightedChoice.new`, `WeightedChoice.updateMany` / `updateAt`, `WeightedChoice.initBy` / `updateBy`, `WeightedChoice.initByIndex` / `updateByIndex`,
  `WeightedChoice.iterFrom`, `WeightedChoice.totalWeight`, `WeightedChoice.positiveCount`, `WeightedChoice.constantIndex`, `WeightedChoice.item` / `itemAt` / `get`, and
  optional `WeightedChoice.weight` / `probability`, lazy `WeightedChoice.weightIter` / `probabilityIter` size hints, `WeightedChoice.weightAt` / `weightsInto`, `WeightedChoice.sampleIndexFrom` /
  `sampleIndexU32From`, `WeightedChoice.fillValuesFrom` / `fillFrom`,
  `WeightedChoice.valuesFrom` / `ptrsFrom`, fixed-size
  `WeightedChoice.valueArrayFrom` / `ptrArrayFrom`, and
  `WeightedChoice.fillIndicesFrom` / `fillIndicesU32From` plus
  `WeightedChoice.indicesFrom` / `indicesU32From` and fixed-size
  `WeightedChoice.indexArrayFrom` / `indexArrayU32From` repeated index arrays
  plus repeated `WeightedChoice.indexIterFrom` / `indexIterU32From` index
  streams, `WeightedChoice.iterFrom` borrowed pointer streams, and
  `seq.chooseWeightedIterFrom`, accessor-weighted
  `seq.chooseWeightedIterByFrom`, and index-weighted
  `seq.chooseWeightedIterByIndexFrom` owned repeated pointer streams for Rust
  `choose_weighted_iter`-style workflows
- `distributions.AliasTable` for O(1) repeated weighted index sampling
  (`distributions.WeightedIndex` is a Rust-discoverable alias matching local
  Rust `rand::distr::weighted::WeightedIndex` naming, and
  `distributions.weighted.WeightedIndex` / `distributions.weighted.Error` /
  `distributions.weighted.WeightError` mirror the local Rust
  `rand::distr::weighted::*` module path), including
  Rust-discoverable `new`, `len`, `numChoices`, `positiveCount`, `totalWeight`, and allocation-returning or caller-buffer
  optional `weight` / `probability`, lazy `weightIter` / `probabilityIter` size hints, `weightAt` / `weights` reconstruction for diagnostics and parity with Rust weighted
  sampler introspection; use `sampleU32` / `fillU32` variants when population
  indexes fit `u32` and compact output is desired, and `indices` /
  `indicesU32` variants for allocation-returning repeated draws; `indexArray`
  / `indexArrayU32` variants return fixed-size repeated index arrays;
  `sampleIndex` / `fillIndices` aliases mirror `WeightedChoice` naming, and
  `iter` / `iterU32` provide repeated index streams; `updateWeights` is the
  Rust-discoverable alias for ordered partial `updateMany`, and `updateAt`
  refreshes one weight while preserving failed-update table safety, `initByIndex` /
  `updateByIndex` construct and refresh static alias tables from index-weight
  functions, while `initBy` / `updateBy` do the same from item weight accessors
- `distributions.WeightedTree` for O(log n) dynamic weight update, push, pop,
  and sampling workloads with weights accumulated as `f64`, including
  `initBy` / `updateAllBy` from item weight accessors,
  `initByIndex` / `updateAllByIndex` from index-weight accessors,
  `updateWeights` / `updateMany` ordered partial updates, `numChoices` / `len` count diagnostics,
  `positiveCount`, `constantIndex` for single-positive deterministic paths, and
  optional `weight` / `probability`, lazy `weightIter` / `probabilityIter`,
  checked `weightAt` / `probabilityAt` lookup, and bulk
  `weights` / `weightsInto` export for diagnostics; use `sampleU32` /
  `fillU32` variants when population indexes fit `u32` and compact output is
  desired, and `indices` / `indicesU32` variants for allocation-returning
  repeated draws; `indexArray` / `indexArrayU32` variants return fixed-size
  repeated index arrays; `sampleIndex` / `fillIndices` aliases are available
  for users discovering dynamic trees from `WeightedChoice` index naming; use
  `iter` / `iterU32` for repeated with-replacement index streams
- `distributions.WeightedIntTree` for unsigned integer weights when dynamic
  update/push/pop/sample throughput matters, including `updateWeights` /
  `updateMany`,
  `initBy` /
  `updateAllBy` from item weight accessors and `initByIndex` /
  `updateAllByIndex` from index-weight accessors; `numChoices` / `len`, `positiveCount`, `constantIndex`, optional `weight` / `probability`, lazy `weightIter` / `probabilityIter`, and checked `weightAt` / `probabilityAt` lookup mirrors generic trees, and weights wider than `u64` are
  accepted only when each value fits the `u64` accumulator
  (failed push/update operations preserve the previous tree totals, `sampleU32`
  / `fillU32` and `indicesU32` variants mirror compact index output,
  `indexArrayU32` provides fixed-size compact index arrays, `sampleIndex` /
  `fillIndices` aliases mirror `WeightedChoice`, `iter` / `iterU32` provide
  repeated index streams, and zero-length checked fills return before validating
  totals)
Run `zig build run-weighted-sampling` for a runnable comparison of one-shot
weighted indexes, static alias tables, dynamic weighted trees, weighted choices,
and weighted no-replacement helpers.

Prefer `sampleIndexVec` or `sampleIndicesU32` for compact, high-throughput no-replacement index
sampling. Use `sampleArrayU32From` for compact fixed-size no-replacement index arrays when the
population length fits `u32`, use `chooseIndexArrayFrom` / `chooseIndexArrayU32From` for fixed-size repeated with-replacement index choices, and use `sampleIndices` when a `[]usize` result is
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
Use `Rng.weightedIndexFrom`, `Rng.weightedIndexArrayFrom`,
`Rng.weightedIndexU32From`, `Rng.weightedIndexU32ArrayFrom`,
`Rng.chooseWeightedValueArrayFrom`,
`Rng.chooseWeightedConstPtrArrayFrom`, `Rng.chooseWeightedPtrArrayFrom`,
`Rng.sampleWithoutReplacementFrom`, `sampleWeightedFrom`, `Choice.iterFrom`,
`WeightedChoice.iterFrom`, `AliasTable.sampleFrom`, and
`WeightedChoice.sampleValueFrom` for weighted or collection sampling with a
comptime-known engine source.
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
`sampleIteratorFrom` results, partial weighted-iterator samples, and allocation-returning
Unicode UTF-8 strings (including `UnicodeCharset.sampleString*`) may need to
finalize storage after reading/drawing, so
prefer checked exact-count or caller-owned-buffer forms when no-consume
allocation-failure behavior matters.
`AliasTable.update`, `AliasTable.updateWeights` / `updateMany`,
`AliasTable.updateAt`, `WeightedChoice.update`,
`WeightedChoice.updateWeights` / `updateMany`, and `WeightedChoice.updateAt`
build the replacement table
before swapping state, so length, weight, and initial allocation failures leave
the previous valid table usable.
For allocation-returning sequence helpers, initial allocation failures are
reported before drawing from the stream; later one-pass failure paths may have
already consumed randomness for earlier accepted candidates.

## Strings

`ascii.zig` includes ASCII `Alphanumeric`, `Alphabetic`, `Lowercase`,
`Uppercase`, `Digits`, custom byte `Charset`, reusable Unicode scalar
`UnicodeCharset`, and Unicode scalar UTF-8 string generation. The distributions
namespace re-exports `Alphanumeric` and `Alphabetic` as aliases for local Rust
`rand::distr::{Alphanumeric, Alphabetic}` discovery, while the canonical
charset diagnostics remain on `ascii.Charset`. Use
`Charset.sampleFrom`, `Charset.fillFrom`,
`Charset.allocFrom`, Rust-discoverable `Charset.sampleStringFrom` /
`Charset.appendStringFrom`, `Charset.numChoices` / `len`,
`Charset.constantIndex`, `Charset.item` / `byteAt` / `get`,
`Charset.probability` / `probabilityAt`, `Charset.probabilityIter` size hints,
`charFrom`, `stringFrom`, `sampleStringFrom`, `appendStringFrom`,
`UnicodeCharset.init`, `UnicodeCharset.initChecked`,
`UnicodeCharset.sampleFrom`, `UnicodeCharset.fillFrom`,
`UnicodeCharset.sampleStringFrom`, `UnicodeCharset.appendStringFrom`,
`UnicodeCharset.maxUtf8Len` / `utf8Capacity`, Unicode charset diagnostics,
`distributions.UniformUnicodeScalar` for reusable Rust `UniformChar`-style
bounded `u21` Unicode scalar sampling, `distributions.UniformChar` as a
discovery alias for local Rust `rand::distr::uniform::UniformChar`,
`unicodeScalarFrom`,
`unicodeScalarRangeLessThanFrom`, `unicodeScalarRangeAtMostFrom`,
`fillUnicodeScalarFrom`, `fillUnicodeScalarRangeLessThanFrom`,
`fillUnicodeScalarRangeAtMostFrom`, `unicodeScalarBatchFrom`,
`unicodeScalarRangeLessThanBatchFrom`, `unicodeScalarRangeAtMostBatchFrom`,
`unicodeUtf8AllocFrom`, `unicodeUtf8Capacity`, and `unicodeUtf8IntoFrom` when
the engine type is comptime-known. Use
`Charset.sampleChecked`, `Charset.sampleCheckedFrom`, `Charset.fillChecked`,
`Charset.fillCheckedFrom`, `Charset.allocChecked`, `Charset.allocCheckedFrom`,
`Charset.sampleStringChecked`, `Charset.appendStringChecked`,
`UnicodeCharset.sampleStringChecked`, and `UnicodeCharset.appendStringChecked`
when a manually constructed charset may be empty or contain invalid Unicode
scalar values;
zero-length fills and allocations return empty results before validating charset
contents. Initial allocation failures in ASCII and Unicode string helpers are
reported before any scalar is drawn, so retry/error paths do not silently
advance a deterministic stream. `unicodeUtf8Into` / `unicodeUtf8IntoFrom` let
callers use a caller-owned buffer sized via `unicodeUtf8Capacity`; too-small
buffers fail before drawing. Use `fillUnicodeScalar*` for caller-owned `u21`
buffers and `unicodeScalarBatch*` for owned repeated scalar values when callers
want codepoint-level batches instead of UTF-8 strings; use the range variants
when you need a bounded Unicode scalar interval while still skipping UTF-16
surrogate code points.
Run `zig build run-string-generation` for a runnable comparison of predefined
ASCII charsets, distribution-namespace ASCII aliases, custom `Charset` count,
checked-item, optional-item, probability, probability-iterator, and size-hint
diagnostics, allocation-returning strings, Unicode scalar batches and range
batches, reusable Unicode scalar range samplers and charsets, and caller-owned
UTF-8 buffers.

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
