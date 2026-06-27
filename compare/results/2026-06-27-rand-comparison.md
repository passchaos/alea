# Alea vs Rust Rand Comparison

Timestamp: 2026-06-28 03:31:00 CST

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
rand SmallRng: 8228.4 MiB/s checksum=177
rand StdRng: 3434.4 MiB/s checksum=98

fill-only throughput
rand SmallRng fill-only: 8682.5 MiB/s tail=243
rand StdRng fill-only: 3548.4 MiB/s tail=20

range throughput
rand bounded u32: 861.1 M samples/s checksum=8389761636971

sequence throughput
rand sample indices: 106849.0 K chosen/s checksum=4981333120
```

## Alea

```text
byte throughput
alea4x64: 3075.8 MiB/s checksum=169
xoshiro256++: 2646.3 MiB/s checksum=177
wyhash64: 3261.0 MiB/s checksum=138
xoshiro256**: 2709.9 MiB/s checksum=121
pcg64: 2332.9 MiB/s checksum=180
chacha12: 1297.0 MiB/s checksum=108

fill-only throughput
alea4x64 fill-only: 15402.4 MiB/s tail=233
xoshiro256++ fill-only: 8618.9 MiB/s tail=243

range throughput
alea bounded u32 facade: 1154.4 M samples/s checksum=8388872893949
alea bounded u32 direct: 1171.9 M samples/s checksum=8388872893949

sequence throughput
alea sample indices facade: 105011.1 K chosen/s checksum=5000272639
alea sample indices direct: 104851.5 K chosen/s checksum=5000272639
alea sample index vec facade: 109325.5 K chosen/s checksum=5000272639
alea sample index vec direct: 130055.9 K chosen/s checksum=5000272639
alea sample indices u32 facade: 117486.7 K chosen/s checksum=5000272639
alea sample indices u32 direct: 144938.0 K chosen/s checksum=5000272639
```

## Result

- RNG fill body: `alea4x64 fill-only` is 1.77x `rand SmallRng fill-only`.
- Bounded u32 range through the `alea.Rng` facade is 1.34x `rand bounded u32`;
  the direct static `FastPrng` path is 1.36x.
- The `sampleIndices` convenience API returns `[]usize` and is 0.98x `rand`
  `IndexVec` on this run.
- The comparable compact `sampleIndexVec` API is 1.02x through the facade and
  1.22x through the direct static path.
- Direct u32 sequence sampling is 1.10x through the facade and 1.36x through the
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
