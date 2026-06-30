# alea

`alea` is a Zig 0.16 random toolkit for simulations, games, tests, procedural
generation, and reproducible experiments.

The first milestone is intentionally broad:

- multiple deterministic engines: `Wyhash64`, `Xoshiro256`, `Pcg64`
- a `ChaCha12` secure-style stream for secret-seeded randomness
- `Rng`, a small facade with `std.Random` compatibility
- `ScalarPrng = Wyhash64` for scalar-heavy distribution workloads such as
  normal, exponential, and Poisson, alongside `FastPrng = Alea4x64` for
  bulk-fill throughput
- `Rng.value(T)` for scalar, enum, tuple, and array sampling
- `Rng.valueIter(T)` and `Rng.sampleIter(T, sampler)` for repeated sampling
- bulk `fillSample`, `fillRange`, strict-interval scalar and vector float
  fill, standard/parameterized vector normal and exponential fills, `fillNormal`,
  `fillExponential`, and unit geometry fill APIs for high-volume sampling
  without iterator ceremony
- deterministic seed derivation with named streams and system-entropy helpers
- scalar helpers for integers, floats, durations, ranges, booleans, and bytes
- collection helpers for `choose`, `shuffle`, partial shuffle, weighted indexes,
  repeated choice iterators, weighted choice samplers, weighted sampling without
  replacement, iterator and weighted iterator sampling with and without
  replacement, reservoir sampling, and adaptive index sampling
- reusable uniform, Bernoulli, non-uniform distribution, and alias-table samplers
- dynamic weighted trees for frequent update/push/pop weighted sampling
- ASCII `Alphanumeric`, `Alphabetic`, custom `Charset`, direct-source charset
  helpers, and Unicode scalar string generation
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

    var items = [_]u32{ 10, 20, 30, 40 };
    const hand = alea.seq.partialShuffle(rng, u32, &items, 2);

    _ = die;
    _ = x;
    _ = outages;
    _ = tuple;
    _ = next_roll;
    _ = token;
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
and scalar-lane normal/exponential vector fills without slowing the full
throughput suite. The optional second `bench` argument filters rows by
case-insensitive substring, which is useful for focused full-harness reruns; the Rust comparison
binary accepts the same `[bytes] [filter]` argument shape. Use focused probes such as `ziggurat-probe`
when investigating a specific hot path before changing production algorithms.

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
