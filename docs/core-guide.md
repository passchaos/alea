# Alea Core Guide

This guide summarizes the core random-number functionality expected by
`AGENTS.md`. It is intentionally Zig-native rather than a port of Rust `rand`
traits.

## Engines

- `DefaultPrng = Xoshiro256`: deterministic default for reproducible work.
- `FastPrng = Alea4x64`: high-throughput non-cryptographic generator.
- `ScalarPrng = Wyhash64`: scalar-heavy fast path for workloads dominated by
  repeated `next()` calls or scalar distributions such as normal, exponential,
  and Poisson. Use it with direct helpers such as `normalFastFrom`,
  `fillNormalFrom`, `exponentialFastFrom`, and `fillExponentialFrom` when the
  engine type is known.
- `HashPrng = Wyhash64`: compact hash-style generator.
- `ReproduciblePrng = Pcg64`: stream-selectable reproducible generator.
- `SecurePrng = ChaCha12`: secure-style stream for secret-seeded randomness.

Every engine exposes `next() u64`, `fill([]u8)`, and `random() std.Random`.
Use `alea.Rng.init(&engine)` when you want the ergonomic facade, and direct
engine helpers when benchmark shape matters.

## Seeding

Use `Seed.fromString`, `Seed.fromBytes`, `Seed.mix`, and `Seed.stream` for
stable named streams. Use `Seed.secure(io)`, `defaultSecure`, `fastSecure`,
`reproducibleSecure`, `secure(io)`, or `secureBytes` when the seed must come
from system entropy.

See `compare/results/reproducibility-matrix.md` for stable-output expectations.

## Scalar Sampling

`Rng` supports:

- integers: `uint`, `uintLessThan`, `uintAtMost`
- signed and unsigned ranges: `intRangeLessThan`, `intRangeAtMost`
- floats: `float`, `floatOpen`, `floatOpenClosed`, `floatRange`
- vectors: `value(@Vector(N, T))`, `vectorRange`, `vectorNormal`,
  `vectorExponential`
- booleans: `boolean`, `chance`, `ratio`
- durations: `durationRangeLessThan`, `durationRangeAtMost`
- Unicode scalar values: `unicodeScalar`
- structured values: `value(T)` for bools, ints, floats, enums, arrays, and tuples
- bulk sampling: `fill` for scalar and vector slices, `fillSample`,
  `fillSampleFrom`, `fillRange`, `fillVectorRange`, `fillNormal`, `fillVectorNormal`,
  `fillExponential`, and `fillVectorExponential`

Checked variants exist for user-supplied probabilities and scalar ranges.
Use `normalFastFrom` and `exponentialFastFrom` when a comptime-known engine
pointer is available and the workload is dominated by scalar distribution
sampling.

## Distributions

Single-shot helpers and reusable samplers cover:

- uniform, Bernoulli, binomial
- standard normal, normal, log-normal, half-normal, standard exponential, exponential
- poisson, geometric
- gamma, chi-squared, chi, erlang, beta, Fisher F, Student t
- triangular, cauchy, laplace, logistic, log-logistic, kumaraswamy,
  rayleigh, maxwell, pareto, weibull
- gumbel, frechet, skew-normal, PERT
- inverse Gaussian, normal-inverse Gaussian, Zipf, Zeta
- unit circle/disc and unit sphere/ball geometry samplers
- dirichlet

Reusable samplers expose `sample(rng)`, and scalar-fast samplers expose
`sampleFrom(source)` where direct engine dispatch is useful. They can be used with
`rng.sampleIter(T, sampler)` when the sample type is scalar. `Dirichlet`
supports both allocation-returning `sample(allocator, rng)` and allocation-free
`sampleInto(rng, out)`.

## Sequence And Collection Sampling

Use:

- `rng.choose`, `rng.choosePtr`
- `rng.shuffle`
- `seq.partialShuffle`
- `seq.reservoirSample`
- `seq.sampleIndices`, `seq.sampleIndexVec`, `seq.sampleIndicesU32`
- `seq.sampleArray`
- `seq.chooseMultiple`
- `seq.chooseIterator`, `seq.sampleIterator`
- `seq.chooseIteratorWeighted`, `seq.sampleIteratorWeighted`
- `seq.Choice`, `seq.WeightedChoice`
- `distributions.AliasTable` for O(1) repeated weighted index sampling
- `distributions.WeightedTree` for O(log n) dynamic weight update, push, pop,
  and sampling workloads

Prefer `sampleIndexVec` or `sampleIndicesU32` for compact, high-throughput index
sampling. Use `sampleIndices` when a `[]usize` result is more convenient.

## Strings

`ascii.zig` includes ASCII `Alphanumeric`, `Alphabetic`, `Lowercase`,
`Uppercase`, `Digits`, custom `Charset`, and Unicode scalar UTF-8 string
generation.

## Validation

Run:

```sh
zig build test
zig build -Doptimize=ReleaseFast statcheck
zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 1048576 > /tmp/alea.bin
sh tools/practrand.sh fast 1073741824
```

PractRand reports are stored under `compare/results/`.

## Benchmarks

Run:

```sh
zig build -Doptimize=ReleaseFast -Dcpu=native bench
RUSTFLAGS="-C target-cpu=native" cargo run --release --manifest-path compare/rand_bench/Cargo.toml
```

The benchmark intentionally separates facade/type-erased paths from direct
static engine paths. `alea.Rng` has function-pointer dispatch comparable to
`std.Random`; direct helpers are closer to Rust's monomorphized `SmallRng`
benchmark shape.
