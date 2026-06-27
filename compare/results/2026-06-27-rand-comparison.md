# Alea vs Rust Rand Comparison

Timestamp: 2026-06-28 03:22:00 CST

This report compares `alea` against the local Rust `rand` checkout at
`~/Work/rand` using same-machine benchmarks. Both sides use native CPU tuning:
Zig is run with `-Dcpu=native`, and Rust is run with
`RUSTFLAGS="-C target-cpu=native"`.

## Commands

```sh
zig build test
zig build -Doptimize=ReleaseFast -Dcpu=native bench
RUSTFLAGS="-C target-cpu=native" cargo run --release --manifest-path compare/rand_bench/Cargo.toml
```

## Rust rand baseline

```text
byte throughput
rand SmallRng: 8193.7 MiB/s checksum=177
rand StdRng: 3435.9 MiB/s checksum=98

fill-only throughput
rand SmallRng fill-only: 8667.5 MiB/s tail=243
rand StdRng fill-only: 3547.3 MiB/s tail=20

range throughput
rand bounded u32: 858.9 M samples/s checksum=8389761636971

sequence throughput
rand sample indices: 106548.5 K chosen/s checksum=4981333120
```

## Alea

```text
byte throughput
alea4x64: 3076.9 MiB/s checksum=169
xoshiro256++: 2654.9 MiB/s checksum=177
wyhash64: 3271.8 MiB/s checksum=138
xoshiro256**: 2720.5 MiB/s checksum=121
pcg64: 2341.0 MiB/s checksum=180
chacha12: 1296.6 MiB/s checksum=108

fill-only throughput
alea4x64 fill-only: 14995.8 MiB/s tail=233
xoshiro256++ fill-only: 8576.6 MiB/s tail=243

range throughput
alea bounded u32 facade: 1093.8 M samples/s checksum=8388872893949
alea bounded u32 direct: 1179.1 M samples/s checksum=8388872893949

sequence throughput
alea sample indices facade: 109915.5 K chosen/s checksum=5000272639
alea sample indices direct: 107054.9 K chosen/s checksum=5000272639
alea sample index vec facade: 104848.2 K chosen/s checksum=5000272639
alea sample index vec direct: 113042.9 K chosen/s checksum=5000272639
alea sample indices u32 facade: 109904.6 K chosen/s checksum=5000272639
alea sample indices u32 direct: 118196.3 K chosen/s checksum=5000272639
```

## Result

- RNG fill body: `alea4x64 fill-only` is 1.73x `rand SmallRng fill-only`.
- Bounded u32 range through the `alea.Rng` facade is 1.27x `rand bounded u32`;
  the direct static `FastPrng` path is 1.37x.
- Public sequence sampling through the facade is 1.03x `rand sample indices`;
  the direct static path is 1.00x on this run.
- Compact sequence sampling is 0.98x through the facade and 1.06x through the
  direct static path.
- Direct u32 sequence sampling is 1.03x through the facade and 1.11x through the
  direct static path.

The checksum-heavy byte-throughput row includes an artificial per-byte XOR pass.
It is retained as an end-to-end stress row, but the fill-only row is the direct
RNG bulk-fill comparison.

Rows labelled `facade` use `alea.Rng`, which stores `nextFn`/`fillFn` function
pointers similarly to `std.Random` and therefore includes type-erased dynamic
call overhead. Rows labelled `direct` call `FastPrng` through comptime-generic
helpers and are closer to Rust's monomorphized `SmallRng` benchmark shape.

## Feature Surface Notes

Compared with Rust `rand`'s default crate surface, `alea` now includes:

- Multiple engines: `Alea4x64`, `Wyhash64`, `Xoshiro256PlusPlus`,
  `Xoshiro256`, `Pcg64`, `ChaCha12`, `SplitMix64`.
- `Rng.value(T)` for scalar, enum, tuple, and array sampling.
- `Rng.valueIter(T)`, `randomIter(T)`, and `sampleIter(T, sampler)`.
- `Rng.fill(T, slice)`, `chance`, `ratio`, open/open-closed float APIs.
- Reusable `Uniform(T)`, `Bernoulli`, alias-table samplers.
- Repeated slice choice, weighted slice choice, and weighted sampling without
  replacement.
- Built-in non-uniform distributions: normal, exponential, poisson, geometric,
  gamma, beta, triangular.
- ASCII string/charset generation.
- Adaptive index sampling with compact `IndexVec` backing.
- System secure seeding via Zig 0.16 `std.Io.randomSecure`.
