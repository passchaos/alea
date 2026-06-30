# Alea Core Guide

This guide summarizes the core random-number functionality expected by
`AGENTS.md`. It is intentionally Zig-native rather than a port of Rust `rand`
traits.

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
  floats, vectors, enums, arrays, and tuples
- bulk sampling: `fill` / `fillFrom` for scalar and vector slices,
  `fillSample`, `fillSampleFrom`, `fillRange`, `fillRangeFrom`, `fillOpen`, `fillOpenClosed`, `fillChance`, `fillRatio`,
  `fillVectorChance`, `fillVectorRatio`, `fillVectorRange`,
  `fillVectorOpen`, `fillVectorOpenClosed`, `fillVectorOpenFrom`, `fillVectorOpenClosedFrom`, `fillStandardNormal`,
  `fillNormal`, `fillLogNormal`, `fillVectorStandardNormal`, `fillVectorNormal`,
  `fillStandardExponential`, `fillExponential`, `fillVectorStandardExponential`,
  and `fillVectorExponential`

Checked variants exist for user-supplied probabilities and scalar ranges,
including direct-source `From` helpers for single scalar draws and scalar
fills, including duration ranges. The same checked/error-returning style is
available for vector ranges, vector probabilities, and parameterized vector
normal/exponential sampling, including direct-source `From` helpers for ranges,
probability vectors, and parameterized normal/exponential vectors/fills when
the engine type is comptime-known.
Use `standardNormalFastFrom`, `normalFastFrom`,
`standardExponentialFastFrom`, and `exponentialFastFrom` when a comptime-known
engine pointer is available and the workload is dominated by scalar
distribution sampling.

## Distributions

Single-shot helpers and reusable samplers cover:

- uniform, Bernoulli, binomial
- standard normal, normal, log-normal, half-normal, standard exponential, exponential
- poisson, geometric
- gamma, chi-squared, chi, erlang, beta, Fisher F, Student t
- triangular, arcsine, cauchy, laplace, logistic, log-logistic, kumaraswamy,
  power-function, rayleigh, maxwell, pareto, weibull
- gumbel, frechet, skew-normal, PERT
- inverse Gaussian, normal-inverse Gaussian, Zipf, Zeta
- unit circle/disc and unit sphere/ball geometry samplers
- dirichlet

Reusable samplers expose `sample(rng)`, and direct-source samplers expose
`sampleFrom(source)` where comptime-known engine dispatch is useful. They can be
used with `rng.sampleIter(T, sampler)` or
`Rng.sampleIterFrom(source, T, sampler)` when the sample type is scalar. `Dirichlet`
supports allocation-returning `sample(allocator, rng)` and allocation-free
`sampleInto(rng, out)` / `sampleIntoFrom(source, out)` and flat
`sampleManyInto` / `sampleManyIntoFrom` batch APIs. Unit geometry samplers also
expose `fill` / `fillFrom`, and the module-level `fillUnitCircle`,
`fillUnitDisc`, `fillUnitSphere`, and `fillUnitBall` helpers fill slices of
fixed-size point arrays.

## Sequence And Collection Sampling

Use:

- `rng.choose`, `Rng.chooseFrom`, `rng.choosePtr`, `Rng.choosePtrFrom`
- `rng.shuffle`, `Rng.shuffleFrom`
- `seq.partialShuffle`, `seq.partialShuffleFrom`
- `seq.reservoirSample`, `seq.reservoirSampleFrom`
- `seq.sampleIndices`, `seq.sampleIndicesCheckedFrom`, `seq.sampleIndexVec`,
  `seq.sampleIndexVecCheckedFrom`, `seq.sampleIndicesU32`,
  `seq.sampleIndicesU32CheckedFrom`
- `seq.sampleArray`, `seq.sampleArrayFrom`
- `seq.chooseMultiple`, `seq.chooseMultipleFrom`
- `seq.chooseIterator`, `seq.chooseIteratorFrom`, `seq.sampleIterator`,
  `seq.sampleIteratorFrom`
- `seq.chooseIteratorWeighted`, `seq.chooseIteratorWeightedFrom`,
  `seq.sampleIteratorWeighted`, `seq.sampleIteratorWeightedFrom`
- `seq.sampleWeightedIndices`, `seq.sampleWeightedIndicesFrom`,
  `seq.sampleWeighted`, `seq.sampleWeightedFrom`
- `seq.Choice`, `seq.chooseIterFrom`, `seq.WeightedChoice`, including
  `Choice.iterFrom` and `WeightedChoice.iterFrom`
- `distributions.AliasTable` for O(1) repeated weighted index sampling
- `distributions.WeightedTree` for O(log n) dynamic weight update, push, pop,
  and sampling workloads
- `distributions.WeightedIntTree` for unsigned integer weights when dynamic
  update/sample throughput matters

Prefer `sampleIndexVec` or `sampleIndicesU32` for compact, high-throughput index
sampling. Use `sampleIndices` when a `[]usize` result is more convenient.
Use `Rng.weightedIndexFrom`, `Rng.sampleWithoutReplacementFrom`,
`sampleWeightedFrom`, `Choice.iterFrom`, `WeightedChoice.iterFrom`,
`AliasTable.sampleFrom`, and `WeightedChoice.sampleValueFrom` for weighted or
collection sampling with a comptime-known engine source.

## Strings

`ascii.zig` includes ASCII `Alphanumeric`, `Alphabetic`, `Lowercase`,
`Uppercase`, `Digits`, custom `Charset`, and Unicode scalar UTF-8 string
generation. Use `Charset.sampleFrom`, `Charset.fillFrom`,
`Charset.allocFrom`, `charFrom`, `stringFrom`, `unicodeScalarFrom`, and
`unicodeUtf8AllocFrom` when the engine type is comptime-known.

## Validation

Run:

```sh
zig build test
zig build apicheck
zig build validate
zig build -Doptimize=ReleaseFast statcheck
zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 1048576 > /tmp/alea.bin
sh tools/practrand.sh fast 1073741824
```

PractRand reports are stored under `compare/results/`.

## Benchmarks

Run:

```sh
zig build -Doptimize=ReleaseFast -Dcpu=native bench
zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench
RUSTFLAGS="-C target-cpu=native" cargo run --release --manifest-path compare/rand_bench/Cargo.toml
```

The benchmark intentionally separates facade/type-erased paths from direct
static engine paths. `alea.Rng` has function-pointer dispatch comparable to
`std.Random`; direct helpers are closer to Rust's monomorphized `SmallRng`
benchmark shape.
