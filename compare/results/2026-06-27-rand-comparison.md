# Alea vs Rust Rand Comparison

Timestamp: 2026-06-28 03:02:00 CST

This report compares `alea` against the local Rust `rand` checkout at
`~/Work/rand` using same-machine benchmarks.

## Commands

```sh
zig build test
zig build bench -Doptimize=ReleaseFast
cargo run --release --manifest-path compare/rand_bench/Cargo.toml
```

## Rust rand baseline

```text
byte throughput
rand SmallRng: 7974.6 MiB/s checksum=177
rand StdRng: 3405.3 MiB/s checksum=98

fill-only throughput
rand SmallRng fill-only: 8680.1 MiB/s tail=243
rand StdRng fill-only: 3509.0 MiB/s tail=20

range throughput
rand bounded u32: 860.6 M samples/s checksum=8389761636971

sequence throughput
rand sample indices: 106524.6 K chosen/s checksum=4981333120
```

## Alea

```text
byte throughput
alea4x64: 3081.5 MiB/s checksum=169
xoshiro256++: 2668.5 MiB/s checksum=177
wyhash64: 3256.8 MiB/s checksum=138
xoshiro256**: 2719.6 MiB/s checksum=121
pcg64: 2329.2 MiB/s checksum=180
chacha12: 1284.0 MiB/s checksum=108

fill-only throughput
alea4x64 fill-only: 15406.4 MiB/s tail=233
xoshiro256++ fill-only: 8565.1 MiB/s tail=243

range throughput
alea bounded u32: 1106.5 M samples/s checksum=8388872893949

sequence throughput
alea sample indices: 110324.1 K chosen/s checksum=5000272639
alea sample index vec: 110609.7 K chosen/s checksum=5000272639
alea sample indices u32: 118968.3 K chosen/s checksum=5000272639
```

## Result

- RNG fill body: `alea4x64 fill-only` is 1.78x `rand SmallRng fill-only`.
- Bounded u32 range: `alea bounded u32` is 1.29x `rand bounded u32`.
- Public sequence sampling: `alea sample indices` is 1.04x `rand sample indices`.
- Compact sequence sampling: `alea sample index vec` is 1.04x `rand sample indices`.
- Direct u32 sequence sampling: `alea sample indices u32` is 1.12x `rand sample indices`.

The checksum-heavy byte-throughput row includes an artificial per-byte XOR pass.
It is retained as an end-to-end stress row, but the fill-only row is the direct
RNG bulk-fill comparison.

## Feature Surface Notes

Compared with Rust `rand`'s default crate surface, `alea` now includes:

- Multiple engines: `Alea4x64`, `Wyhash64`, `Xoshiro256PlusPlus`,
  `Xoshiro256`, `Pcg64`, `ChaCha12`, `SplitMix64`.
- `Rng.value(T)` for scalar, enum, tuple, and array sampling.
- `Rng.valueIter(T)`, `randomIter(T)`, and `sampleIter(T, sampler)`.
- `Rng.fill(T, slice)`, `chance`, `ratio`, open/open-closed float APIs.
- Reusable `Uniform(T)`, `Bernoulli`, alias-table samplers.
- Repeated slice choice and weighted slice choice samplers.
- Built-in non-uniform distributions: normal, exponential, poisson, geometric,
  gamma, beta, triangular.
- ASCII string/charset generation.
- Adaptive index sampling with compact `IndexVec` backing.
- System secure seeding via Zig 0.16 `std.Io.randomSecure`.
