# alea

`alea` is a Zig 0.16 random toolkit for simulations, games, tests, procedural
generation, and reproducible experiments.

The current Linux-first roadmap is intentionally broad:

- multiple deterministic engines: `Wyhash64`, `Xoshiro256`, `Pcg64`
- a `ChaCha12` secure-style stream for secret-seeded randomness
- `Rng`, a small facade with `std.Random` compatibility
- `ScalarPrng = Wyhash64` for scalar-heavy distribution workloads such as
  normal, exponential, and Poisson, alongside `FastPrng = Alea4x64` for
  bulk-fill throughput
- `Rng.value(T)` / `Rng.valueChecked(T)` for scalar, enum, tuple, and array
  sampling, including fallible empty-enum handling
- `Rng.valueIter(T)` and `Rng.sampleIter(T, sampler)` for repeated sampling,
  including bulk `fill` methods where stream policy permits
- bulk `fillSample`, `fillRange`, strict-interval scalar and vector float
  fill, distribution-namespace vector Bernoulli/Poisson/uniform/strict-interval/normal/exponential
  wrappers and reusable vector samplers, `fillNormal`, `fillExponential`, and unit geometry fill APIs for
  high-volume sampling without iterator ceremony
- deterministic seed derivation with named streams and system-entropy helpers
- scalar helpers for integers, floats, durations, ranges, booleans, and bytes
- collection helpers for `choose`, `shuffle`, partial shuffle, weighted indexes,
  repeated choice iterators, weighted choice samplers, weighted sampling without
  replacement, iterator and weighted iterator sampling with and without
  replacement, reservoir sampling, adaptive index sampling, and checked
  variants for fallible user-supplied counts or empty inputs
- reusable uniform, Bernoulli, non-uniform distribution, opt-in bounded f32
  LogNormal approximation, and alias-table samplers
- dynamic weighted trees for frequent update/push/pop/sample/fill weighted
  workloads
- ASCII `Alphanumeric`, `Alphabetic`, custom `Charset`, direct-source charset
  helpers, checked charset methods for fallible custom charsets, and Unicode
  scalar string generation with allocation-returning and caller-owned-buffer
  UTF-8 helpers
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
    const token = try alea.ascii.Alphanumeric.alloc(std.heap.smp_allocator, rng, 16);
    defer std.heap.smp_allocator.free(token);
    const utf8_capacity = try alea.ascii.unicodeUtf8Capacity(8);
    const utf8_buf = try std.heap.smp_allocator.alloc(u8, utf8_capacity);
    defer std.heap.smp_allocator.free(utf8_buf);
    const text = try alea.ascii.unicodeUtf8Into(rng, utf8_buf, 8);

    var items = [_]u32{ 10, 20, 30, 40 };
    const hand = alea.seq.partialShuffle(rng, u32, &items, 2);

    _ = die;
    _ = x;
    _ = outages;
    _ = tuple;
    _ = next_roll;
    _ = token;
    _ = utf8_capacity;
    _ = text;
    _ = hand;
}
```

## Build

```sh
zig build test
zig build apicheck
zig build validate
zig build run-basic
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
distribution-namespace vector Bernoulli/Poisson/uniform/normal/exponential wrappers,
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
`HashPrng` are `Wyhash64`, `ReproduciblePrng` is `Pcg64`, and `SecurePrng` is
`ChaCha12`. Root helpers such as `default`, `fast`, `scalar`, `hash`,
`reproducible`, and their secure-seeded variants initialize the matching
aliases without spelling out the concrete engine type.

See `docs/core-guide.md` for the core API guide, `docs/api-reference.md` for
the public API reference, and
`compare/results/core-rand-coverage.md` for the roadmap and validation matrix.
Current hard performance gaps and rejected optimization attempts are tracked in
`compare/results/performance-triage.md`; LogNormal transform tradeoffs,
including the opt-in bounded f32 approximation, are summarized in
`compare/results/lognormal-transform-notes.md`, and exact
`(0, 1]` f64 endpoint-grid constraints are summarized in
`compare/results/openclosed-endpoint-notes.md`.
