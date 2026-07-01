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
  floats, vectors, enums, arrays, and tuples; use `enumValueCheckedFrom` when
  an empty enum type should be reported as `EmptyRange`
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
Distribution-level bulk fills that cache a reusable sampler also keep
assert-fast `fill*` helpers and add checked `fill*Checked` /
`fill*CheckedFrom` variants for common discrete families, core continuous
families, and tail/bounded families such as triangular, arcsine, Cauchy,
Laplace, logistic, log-logistic, Kumaraswamy, power-function, Rayleigh,
Maxwell, Pareto, Weibull, Gumbel, Frechet, skew-normal, PERT, and
inverse-Gaussian-family sampling. Top-level Zipf/Zeta fills mirror their
reusable sampler fills with checked variants for fallible bulk workflows.
The distributions module also mirrors `Rng.fillNormal*` and
`Rng.fillExponential*` as top-level helpers for callers who prefer the
distribution namespace; `fillUniform*` and `fillUniformInclusive*` do the same
for exclusive and inclusive uniform ranges.
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
for user-supplied output buffers. `Normal(T).initMeanCv` and
`LogNormal(T).initMeanCv` cover coefficient-of-variation parameterization
without requiring users to hand-convert to log-space parameters; both samplers
also expose z-score conversion helpers for correlated draws. `Pert(T).initRange`
offers a builder-style range-first constructor with `withShape`, `withMode`,
and `withMean` for workflows that choose range before mode/mean. Unit geometry samplers also
expose `fill` / `fillFrom`, and the module-level `fillUnitCircle`,
`fillUnitDisc`, `fillUnitSphere`, and `fillUnitBall` helpers fill slices of
fixed-size point arrays.

## Sequence And Collection Sampling

Use:

- `rng.choose`, `Rng.chooseFrom`, `Rng.chooseCheckedFrom`,
  `rng.choosePtr`, `Rng.choosePtrFrom`, `Rng.choosePtrCheckedFrom`
- `rng.shuffle`, `Rng.shuffleFrom`
- `seq.partialShuffle`, `seq.partialShuffleFrom`,
  `seq.partialShuffleCheckedFrom`
- `seq.reservoirSample`, `seq.reservoirSampleFrom`,
  `seq.reservoirSampleCheckedFrom`
- `seq.sampleIndices`, `seq.sampleIndicesCheckedFrom`, `seq.sampleIndexVec`,
  `seq.sampleIndexVecCheckedFrom`, `seq.sampleIndicesU32`,
  `seq.sampleIndicesU32CheckedFrom`
- `seq.sampleArray`, `seq.sampleArrayFrom`, `seq.sampleArrayCheckedFrom`
- `seq.chooseMultiple`, `seq.chooseMultipleFrom`,
  `seq.chooseMultipleCheckedFrom`
- `seq.chooseIterator`, `seq.chooseIteratorFrom`,
  `seq.chooseIteratorCheckedFrom`, `seq.sampleIterator`, `seq.sampleIteratorFrom`,
  `seq.sampleIteratorCheckedFrom`
- `seq.chooseIteratorWeighted`, `seq.chooseIteratorWeightedFrom`,
  `seq.chooseIteratorWeightedCheckedFrom`, `seq.sampleIteratorWeighted`,
  `seq.sampleIteratorWeightedFrom`, `seq.sampleIteratorWeightedCheckedFrom`
- `seq.sampleWeightedIndices`, `seq.sampleWeightedIndicesFrom`,
  `seq.sampleWeightedIndicesCheckedFrom`, `seq.sampleWeighted`,
  `seq.sampleWeightedFrom`, `seq.sampleWeightedCheckedFrom`
- `seq.Choice`, `seq.chooseIterFrom`, `seq.chooseIterCheckedFrom`,
  `seq.WeightedChoice`, including `Choice.iterFrom`, `WeightedChoice.update`,
  and `WeightedChoice.iterFrom`
- `distributions.AliasTable` for O(1) repeated weighted index sampling
- `distributions.WeightedTree` for O(log n) dynamic weight update, push, pop,
  and sampling workloads
- `distributions.WeightedIntTree` for unsigned integer weights when dynamic
  update/push/pop/sample throughput matters

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
strict-open/open-closed/range vector float fills, and scalar-lane
normal/exponential vector fills; representative rows are about 1.01B lanes/s
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
