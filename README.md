# alea

`alea` is a Zig 0.16 random toolkit for simulations, games, tests, procedural
generation, and reproducible experiments.

The current Linux-first roadmap is intentionally broad:

- multiple deterministic engines: `Wyhash64`, `Xoshiro256`, `Pcg64`, plus
  Rust-discoverable `StdRng` / `SmallRng` aliases for standard secure-style and
  small fast generator discovery
- a `ChaCha12` secure-style stream for secret-seeded randomness
- `Rng`, a small facade with `std.Random` compatibility
- Rust-discoverable raw aliases `nextU64()`, `nextU32()`, `fillBytes(out)`,
  `tryNext()`, `tryNextU64()`, `tryNextU32()`, and `tryFillBytes(out)` on
  deterministic engines, alongside Zig-native `next()`, `bytes`, and
  `fill(u8, out)`
- a Zig-native `Rng.reader(buffer)` / `Rng.rngReader(source, buffer)`
  adapter for streaming random bytes through `std.Io.Reader`, matching local
  Rust `rand::RngReader` workflows while preserving Alea's source ownership
  and fallible-source diagnostics
- Rust-discoverable engine `seedFromU64(seed)` constructor aliases alongside
  Zig-native `init` / `initFromU64`
- Rust-discoverable engine `fromSeed(seed)` aliases for Alea `Seed` values
  alongside direct `u64` constructors
- Rust-discoverable engine `fromSeedBytes(seed)` constructors for fixed-size
  little-endian byte-array seeds
- Rust-discoverable `Seed.fromRng(source)`, engine `fromRng(source)`, and
  engine `fork()` helpers for deriving child streams from existing generators
- Rust-discoverable fallible `Seed.tryFromRng(source)` and engine
  `tryFromRng(source)` / `tryFork()` helpers for sources exposing
  `tryNext() !u64`
- Rust-discoverable generic `makeRng(Engine, io)` for system-entropy
  construction of any exported deterministic engine
- Rust-discoverable `Rng.SysRng` / root `sysRng(io)` system-entropy source
  with `tryNextU64`, `tryNextU32`, `tryFillBytes`, and `RngReader` support
- Rust-discoverable `StepRng` plus root `stepRng` / `constRng` helpers for
  deterministic mock streams and byte-shape tests
- `ScalarPrng = Wyhash64` for scalar-heavy distribution workloads such as
  normal, exponential, and Poisson, alongside `FastPrng = Alea4x64` for
  bulk-fill throughput
- `Rng.value(T)` / `Rng.valueChecked(T)` plus Rust-discoverable
  `Rng.randomValue(T)` aliases for scalar, enum, tuple, and array
  sampling, including fallible empty-enum handling
- `Rng.valueBatch(T)` / `Rng.valueBatchChecked(T)`,
  Rust-discoverable `Rng.sample(T, sampler)`, `Rng.sampleBatch(T, sampler)`, bounded-uint `uintLessThanBatch` /
  `uintAtMostBatch`, `Rng.rangeBatch(T, min, max)` / inclusive integer
  `rangeAtMostBatch(T, min, max)`, vector range / inclusive vector range batches, strict interval
  `openBatch` / `openClosedBatch`, probability `chanceBatch` /
  `ratioBatch` / vector probability batches, duration/vector range batches, vector strict-interval batches, and scalar/vector standard-or-parameterized normal/exponential batches for
  allocation-returning repeated samples
- `Rng.valueIter(T)` and `Rng.sampleIter(T, sampler)` for repeated sampling,
  unbounded `sizeHint` diagnostics, and bulk `fill` methods where stream
  policy permits
- bulk `fillSample`, `fillRange`, strict-interval scalar and vector float
  fill, distribution-namespace vector Bernoulli/binomial/binomial-approx/negative-binomial/hypergeometric/geometric/standard-geometric/Poisson/Poisson-AD/uniform/strict-interval/normal/log-normal/approx-log-normal/half-normal/gamma/chi-squared/chi/erlang/beta/fisher-f/student-t/triangular/arcsine/cauchy/laplace/logistic/log-logistic/kumaraswamy/power-function/rayleigh/maxwell/pareto/weibull/gumbel/frechet/skew-normal/PERT/inverse-Gaussian/normal-inverse-Gaussian/Zipf/Zeta/unit-circle/unit-disc/unit-sphere/unit-ball/exponential
  wrappers and reusable vector samplers, `fillNormal`, `fillExponential`, and unit geometry fill APIs for
  high-volume sampling without iterator ceremony
- deterministic seed derivation with named streams and system-entropy helpers
- scalar helpers for integers, floats, durations, ranges including Rust-discoverable `randomRange` aliases, booleans including Rust-discoverable `randomBool` / `randomRatio` aliases, caller-owned bytes, and allocation-returning byte buffers
- collection helpers for one-shot and repeated usize/u32 index, value, const-pointer, and mutable-pointer choice through both `Rng.choose*` and `seq.choose*`, fixed-size repeated usize/u32 index and value/pointer choice arrays through `Rng.choose*Array` and explicit `seq.chooseRepeated*Array` helpers, caller-owned repeated index/value/pointer choice fills through `seq.fillChoose*`, allocation-returning repeated index/value/pointer choice batches through `seq.choose*Batch`, `shuffle` / `seq.shuffle`, fixed-size u32 index and no-replacement item/pointer arrays with both `choose*Array` and Rust-discoverable `sample*Array` naming, allocation-returning, exact-size iterator len/sizeHint/fill diagnostics, and caller-owned item/pointer/mutable-pointer subsets with both `chooseMultiple*` and `sampleItems*` naming, head-selected and Rust-style tail-selected partial shuffle selected/rest splits, compact `IndexVec` index samples with owned-backing adoption, Rust-discoverable and checked index lookup, representation-preserving deep clone, Rust-discoverable consuming intoVec, consuming index iteration, lazy/caller-owned/allocation-returning/consuming value and pointer mapping, u32 export mapping, and cross-backing equality, f64 and generic repeated weighted index/value/pointer batches plus fixed-size f64, generic, item-accessor, and index-weight-accessor weighted repeated index/u32-index/value/const-pointer/mutable-pointer arrays, accessor-based weighted fixed-size index/value/pointer arrays, allocation-returning, caller-owned, and fixed-size index/u32-index/IndexVec samples from item or index weight accessors, plus usize/u32 index choices, caller-owned repeated index fills, allocation-returning repeated index batches, value/const-pointer/mutable-pointer choices, caller-owned repeated value/const-pointer/mutable-pointer choice fills, and allocation-returning repeated value/const-pointer/mutable-pointer choice batches from item or index weight accessors, caller-owned repeated choice fills, allocation-returning repeated choice batches, allocation-returning samples, and caller-owned no-replacement buffers for item-embedded weights, compact weighted IndexVec samples, allocation-returning weighted u32 index slices, fixed-size weighted u32 index arrays, caller-owned weighted u32 index buffers,
  repeated choice iterators with Rust-discoverable new aliases, numChoices, constantIndex, checked item alias and optional item lookup, and optional probability/probability-iterator size-hint diagnostics, value/pointer/index samples, fills, owned value/pointer/index batches, fixed-size repeated value/pointer/index arrays, and usize/u32 index streams, one-shot and repeated weighted item/const-pointer/mutable-pointer helpers, weighted choice samplers including Rust-discoverable new aliases, Rust-discoverable updateWeights, ordered updateMany, and single-weight updateAt plus item- and index-accessor construction/update, numChoices, positiveCount, constantIndex, checked item alias and optional item lookup, optional weight, and weight/probability-iterator size-hint diagnostics, value/pointer/index samples, fills, owned value/pointer/index batches, repeated weighted pointer streams including item- and index-accessor streams, fixed-size repeated value/pointer/index arrays, and usize/u32 index streams, weighted fixed-size pointer arrays, allocation-returning weighted pointer subsets, caller-owned weighted pointer buffers, caller-owned pointer adoption examples, weighted sampling without
  replacement, hint-sensitive and stable iterator choice aliases, iterator and weighted iterator sampling with and without
  replacement, fixed-size and caller-owned/sample-fill iterator sampling, allocated/caller-owned value and pointer reservoir sampling, adaptive, repeated, and caller-owned usize/u32 index sampling, and checked
  variants for fallible user-supplied counts or empty inputs
- reusable sampler `map` adapters for Rust-discoverable `Distribution::map`
  style transformations, distribution-namespace `sampleIter` aliases for
  Rust-discoverable `Distribution::sample_iter` workflows, reusable uniform with Rust-discoverable `new` /
  `newInclusive` and one-shot `sampleSingle` / `sampleSingleInclusive` aliases, Bernoulli with Rust-discoverable `new` / `fromRatio` / `p()` aliases, non-uniform distribution, opt-in bounded f32
  LogNormal approximation, and alias-table samplers with Rust-discoverable new aliases, Rust-discoverable updateWeights, ordered updateMany, and single-weight updateAt, numChoices, positiveCount, compact `u32` index
  output, `sampleIndex` / `fillIndices` aliases, and owned repeated index
  batches, fixed-size index arrays, iterators, plus item- and index-accessor
  construction/update
- dynamic weighted trees for frequent update/push/pop/sample/fill weighted
  workloads, including item- and index-accessor construction/full-refresh
  helpers, `updateWeights` / `updateMany`, `numChoices`, `positiveCount`, `constantIndex`, `sampleIndex` / `fillIndices` aliases, compact `u32` index
  sampling/fills, optional weight diagnostics, owned repeated index batches, fixed-size index arrays, and
  repeated index iterators
- ASCII `Alphanumeric`, `Alphabetic`, custom `Charset`, direct-source charset
  helpers, Rust-discoverable `sampleString` / `appendString` aliases,
  checked charset methods plus numChoices, constantIndex, and checked item alias, optional item, probability, probability-iterator, and size-hint diagnostics for fallible custom charsets, `UnicodeCharset` reusable Unicode scalar alphabets with SampleString-style UTF-8 output, and Unicode
  scalar fill/owned/range batches plus string generation with
  allocation-returning and caller-owned-buffer UTF-8 helpers
- distributions: uniform, bernoulli, binomial, negative-binomial,
  hypergeometric, standard normal, normal, log-normal, half-normal, standard exponential,
  exponential, poisson, gamma,
  chi-squared, chi, erlang, beta, Fisher F, Student t, triangular, arcsine,
  cauchy, laplace, logistic, log-logistic, kumaraswamy, power-function,
  rayleigh, maxwell, pareto, weibull, gumbel, frechet, skew-normal, PERT,
  inverse Gaussian,
  normal-inverse Gaussian, Zipf, Zeta, unit geometry samplers, dirichlet,
  multinomial
- O(1) repeated weighted sampling through alias tables

The local Linux roadmap has progressed beyond basic feature bring-up into
Stage 4 evidence and performance triage. See
`compare/results/core-rand-coverage.md` for the living roadmap and
`compare/results/performance-triage.md` for current hard gaps and rejected
optimization attempts.

## Quick Start

```zig
const std = @import("std");
const alea = @import("alea");

pub fn main() !void {
    var engine = alea.DefaultPrng.init(1234);
    const rng = alea.Rng.init(&engine);

    const die = rng.intRangeAtMost(u8, 1, 6);
    const x = rng.normal(f64, 0.0, 1.0);
    const outages = alea.distributions.binomial(rng, 40, 0.25);
    const tuple = rng.value(struct { u16, bool, f32 });
    var rolls = rng.sampleIter(u8, try alea.distributions.Uniform(u8).initInclusive(1, 6));
    const next_roll = rolls.next().?;
    const random_bytes = try rng.bytesAlloc(std.heap.smp_allocator, 8);
    defer std.heap.smp_allocator.free(random_bytes);
    const random_words = try rng.valueBatch(u16, std.heap.smp_allocator, 4);
    defer std.heap.smp_allocator.free(random_words);
    const token = try alea.ascii.Alphanumeric.alloc(std.heap.smp_allocator, rng, 16);
    defer std.heap.smp_allocator.free(token);
    const utf8_capacity = try alea.ascii.unicodeUtf8Capacity(8);
    const utf8_buf = try std.heap.smp_allocator.alloc(u8, utf8_capacity);
    defer std.heap.smp_allocator.free(utf8_buf);
    const text = try alea.ascii.unicodeUtf8Into(rng, utf8_buf, 8);

    var items = [_]u32{ 10, 20, 30, 40 };
    const item_index = rng.chooseIndex(items.len).?;
    const compact_item_index = rng.chooseIndexU32(@intCast(items.len)).?;
    const item_ptr = rng.chooseConstPtr(u32, &items).?;
    const hand = alea.seq.partialShuffle(rng, u32, &items, 2);

    _ = die;
    _ = x;
    _ = outages;
    _ = tuple;
    _ = next_roll;
    _ = random_bytes;
    _ = random_words;
    _ = token;
    _ = utf8_capacity;
    _ = text;
    _ = item_index;
    _ = item_ptr;
    _ = hand;
}
```

## Build

Run `zig build -l` for the generated list of project-defined build steps. The
most common checks are:

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
zig build run-basic
zig build examples
zig build -Doptimize=ReleaseFast statcheck
zig build -Doptimize=ReleaseFast distcheck
zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 1048576 > /tmp/alea.bin
sh tools/practrand.sh fast 1073741824
zig build -Doptimize=ReleaseFast -Dcpu=native bench
zig build -Doptimize=ReleaseFast -Dcpu=native bench -- "standard-normal"
zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench
zig build -Doptimize=ReleaseFast -Dcpu=native ziggurat-probe
RUSTFLAGS="-C target-cpu=native" cargo run --release --manifest-path compare/rand_bench/Cargo.toml
RUSTFLAGS="-C target-cpu=native" cargo run --release --manifest-path compare/rand_bench/Cargo.toml -- "standard-normal"
```

The Rust command benchmarks against the local `rand` checkout in
`~/Work/rand`. Latest comparison data is kept under
`compare/results/`. Use `vectorbench` for focused vector-slice evidence such
as packed bool chance/ratio, strict-interval vector float fills, vector ranges,
distribution-namespace vector Bernoulli/binomial/binomial-approx/negative-binomial/hypergeometric/geometric/standard-geometric/Poisson/Poisson-AD/uniform/normal/log-normal/approx-log-normal/half-normal/gamma/chi-squared/chi/erlang/beta/fisher-f/student-t/triangular/arcsine/cauchy/laplace/logistic/log-logistic/kumaraswamy/power-function/rayleigh/maxwell/pareto/weibull/gumbel/frechet/skew-normal/PERT/inverse-Gaussian/normal-inverse-Gaussian/Zipf/Zeta/unit-circle/unit-disc/unit-sphere/unit-ball/exponential wrappers,
and scalar-lane normal/exponential
vector fills without slowing the full throughput suite;
`compare/results/simd-distribution-kernel-notes.md` records
requirements for future dense SIMD distribution kernels. The optional
`bench -- [bytes] [filter]` arguments override the byte count and
filter rows by case-insensitive substring, which is useful for focused
full-harness reruns; the Rust comparison binary accepts the same shape. Use
focused probes such as `ziggurat-probe` when investigating a specific hot path
before changing production algorithms, and record accepted/rejected outcomes in
`compare/results/performance-triage.md`.

## Design Notes

`alea` is designed to exceed Rust `rand`'s default crate surface in Zig form:
the core library includes non-uniform distributions, reusable samplers, string
generation, iterator-style repeated sampling, and sequence sampling instead of
pushing most non-uniform sampling to a separate crate. Every engine still
exposes `random()` for standard-library consumers, and `Rng.random()` returns a
`std.Random` interface.

`DefaultPrng` is `Xoshiro256`, `FastPrng` is `Alea4x64`, `ScalarPrng` and
`HashPrng` are `Wyhash64`, `ReproduciblePrng` is `Pcg64`, `SecurePrng` and
Rust-discoverable `StdRng` are `ChaCha12`, Rust-discoverable `SmallRng` is
`Xoshiro256PlusPlus`, and `StepRng` is a deterministic arithmetic-sequence
mock source for tests. Root helpers such as `default`, `fast`, `scalar`, `hash`,
`reproducible`, and their secure-seeded variants initialize the matching
aliases without spelling out the concrete engine type.

See `docs/core-guide.md` for the core API guide, `docs/api-reference.md` for
the public API reference, `docs/examples.md` for runnable examples,
`docs/tooling.md` for the build/tool catalog, and
`compare/results/core-rand-coverage.md` for the roadmap and validation matrix.
Current hard performance gaps and rejected optimization attempts are tracked in
`compare/results/performance-triage.md`; LogNormal transform tradeoffs,
including the opt-in bounded f32 approximation, are summarized in
`compare/results/lognormal-transform-notes.md`, and exact
`(0, 1]` f64 endpoint-grid constraints are summarized in
`compare/results/openclosed-endpoint-notes.md`.
