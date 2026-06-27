# Alea vs Rust Rand Comparison

Timestamp: 2026-06-27 21:45:41 CST

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
rand SmallRng: 5924.5 MiB/s checksum=177
rand StdRng: 1682.0 MiB/s checksum=98

fill-only throughput
rand SmallRng fill-only: 5642.4 MiB/s tail=243
rand StdRng fill-only: 1797.1 MiB/s tail=20

range throughput
rand bounded u32: 235.1 M samples/s checksum=8389761636971

sequence throughput
rand sample indices: 107046.9 K chosen/s checksum=4981333120
```

## Alea

```text
byte throughput
alea4x64: 2236.6 MiB/s checksum=169
xoshiro256++: 1958.6 MiB/s checksum=177
wyhash64: 2271.4 MiB/s checksum=138
xoshiro256**: 1865.2 MiB/s checksum=121
pcg64: 1763.3 MiB/s checksum=180
chacha12: 1041.2 MiB/s checksum=108

fill-only throughput
alea4x64 fill-only: 11251.5 MiB/s tail=233
xoshiro256++ fill-only: 6327.3 MiB/s tail=243

range throughput
alea bounded u32: 905.7 M samples/s checksum=8388872893949

sequence throughput
alea sample indices: 123328.9 K chosen/s checksum=4989562697
alea sample index vec: 151039.1 K chosen/s checksum=4989562697
alea sample indices u32: 154839.5 K chosen/s checksum=4989562697
```

## Result

- RNG fill body: `alea4x64 fill-only` is 1.99x `rand SmallRng fill-only`.
- Bounded u32 range: `alea bounded u32` is 3.85x `rand bounded u32`.
- Public sequence sampling: `alea sample indices` is 1.15x `rand sample indices`.
- Compact sequence sampling: `alea sample index vec` is 1.41x `rand sample indices`.
- Direct u32 sequence sampling: `alea sample indices u32` is 1.45x `rand sample indices`.

The checksum-heavy byte-throughput row includes an artificial per-byte XOR pass.
It is retained as an end-to-end stress row, but the fill-only row is the direct
RNG bulk-fill comparison.

## Feature Surface Notes

Compared with Rust `rand`'s default crate surface, `alea` now includes:

- Multiple engines: `Alea4x64`, `Wyhash64`, `Xoshiro256PlusPlus`,
  `Xoshiro256`, `Pcg64`, `ChaCha12`, `SplitMix64`.
- `Rng.value(T)` for scalar, enum, tuple, and array sampling.
- `Rng.fill(T, slice)`, `chance`, `ratio`, open/open-closed float APIs.
- Reusable `Uniform(T)`, `Bernoulli`, alias-table samplers.
- Built-in non-uniform distributions: normal, exponential, poisson, geometric,
  gamma, beta, triangular.
- ASCII string/charset generation.
- Adaptive index sampling with compact `IndexVec` backing.
- System secure seeding via Zig 0.16 `std.Io.randomSecure`.
