# S4-M258 Xoshiro128PlusPlus Engine

Date: 2026-07-05

## Local Rust Baseline

The local Rust `rand` checkout exposes both Xoshiro++ portable generator names
from `~/Work/rand/src/rngs/mod.rs`:

- `pub use xoshiro128plusplus::Xoshiro128PlusPlus;`
- `pub use xoshiro256plusplus::Xoshiro256PlusPlus;`

Local `SmallRng` maps to `Xoshiro256PlusPlus` on the current 64-bit Linux
target, but the public `Xoshiro128PlusPlus` name remains available as the
32-bit Xoshiro++ portable generator. Alea already exposed
`Xoshiro256PlusPlus` and `SmallRng`; the remaining local Rust RNG-name gap was
`Xoshiro128PlusPlus`.

`~/Work/rand/src/rngs/xoshiro128plusplus.rs` also carries stable reference
vectors:

- `from_seed([1, 2, 3, 4] as little-endian u32 words)` first ten `next_u32`
  values:
  `{641, 1573767, 3222811527, 3517856514, 836907274, 4247214768, 3867114732,
  1355841295, 495546011, 621204420}`;
- `seed_from_u64(0)` and `from_seed([0; 16])` first ten `next_u32` values:
  `{1179900579, 1938959192, 3089844957, 3657088315, 1015453891, 479942911,
  3433842246, 669252886, 3985671746, 2737205563}`.

## Alea Change

Alea now provides:

- `Xoshiro128PlusPlus` in `src/engines/xoshiro128plusplus.zig`;
- a root export;
- `makeRng(Xoshiro128PlusPlus, io)`;
- `zig build stream -- --engine xoshiro128++`;
- `statcheck` coverage for `xoshiro128++`;
- reproducible-streams example output for `Xoshiro128PlusPlus portable-32`.

The engine exposes the same direct-engine workflow family as other production
engines:

- `init(u64)` / `seedFromU64`;
- `fromSeed`, `fromSeedBytes([16]u8)`, `fromRng`, and `tryFromRng`;
- `seed`;
- `random()` for `std.Random` interop;
- `next` / `tryNext` / `nextU64` / `tryNextU64` / `nextU32` / `tryNextU32`;
- `fill`, `fillBytes`, and `tryFillBytes`;
- `fork` and `tryFork`.

`nextU32` implements the local Rust xoshiro128++ transition directly.
`nextU64` consumes two `nextU32` draws and combines them little-endian, matching
local Rust `rand_core::utils::next_u64_via_u32`.
Byte fills use generated `u32` words in little-endian order, matching local Rust
`rand_core::utils::fill_bytes_via_next_word(... try_next_u32 ...)`.

This does not change `SmallRng`: on this local 64-bit platform Alea still maps
`SmallRng = Xoshiro256PlusPlus`.

## Tests and Validation

Focused tests cover:

- local Rust reference `next_u32` values for `[1, 2, 3, 4]` seed words;
- local Rust `seed_from_u64(0)` and all-zero byte seed values;
- `nextU64` little-endian pairing of two `nextU32` draws;
- stable `fill` byte snapshots;
- shared root seed/fromSeedBytes/fromRng/tryFromRng/fork/tryFork/makeRng
  integration.
- `Rng.nextU32From` now dispatches to a direct source `nextU32` when present,
  so 32-bit-word engines such as `Xoshiro128PlusPlus` keep their documented raw
  `next_u32` stream shape in direct-source workflows instead of truncating a
  synthetic `u64` draw.

Documentation/tooling updates:

- `README.md`, `docs/core-guide.md`, `docs/examples.md`, and
  `docs/api-reference.md` document `Xoshiro128PlusPlus`.
- `examples/reproducible_streams.zig` prints `Xoshiro128PlusPlus portable-32`.
- `tools/examplecheck.zig` checks that token.
- `tools/apicheck.zig`, `tools/statcheck.zig`, and `tools/stream.zig` cover the
  new engine.
- `compare/results/reproducibility-matrix.md`,
  `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M259.

Validation commands for this milestone:

```sh
zig test src/engines/xoshiro128plusplus.zig
zig test src/root.zig --test-filter "xoshiro128"
zig test src/root.zig --test-filter "engine fromSeedBytes"
zig test src/root.zig --test-filter "engine fromRng"
zig test src/root.zig --test-filter "engine tryFromRng"
zig test src/root.zig --test-filter "makeRng"
zig test src/root.zig --test-filter "rng direct raw aliases dispatch source native nextU32"
zig build run-reproducible-streams
zig build stream -- --engine xoshiro128++ --bytes 32
zig build -Doptimize=ReleaseFast stream -- --engine xoshiro128++ --bytes 67108864 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 64MB -tlmax 64MB
zig build -Doptimize=ReleaseFast statcheck
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```

The 64MiB PractRand smoke run for `xoshiro128++` reported no anomalies.
