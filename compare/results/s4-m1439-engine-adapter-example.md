# S4-M1439 — Engine adapter adoption example

## Goal

Show the new `ReseedingRng` and `ReaderRng` adapters in a runnable example so
the engine-composition surface is discoverable and covered by the example and
tooling catalogs.

## Change

- New `examples/engine_adapters.zig`:
  - reseeds an `Xoshiro256PlusPlus` adapter from a `SplitMix64` source every
    four draws and prints the draws plus `reseedCount`,
  - replays a captured 16-byte stream through `ReaderRng` (word and u32
    paths),
  - drives the adapter through the comptime-specialized `RngOf` view.
- Registered as `zig build run-engine-adapters`, added to the `examples`
  aggregate, and listed in `docs/examples.md`, `docs/tooling.md`,
  `tools/toolingcheck.zig`, and `tools/examplecheck.zig`.

## Evidence

- `zig build run-engine-adapters` prints the expected deterministic output:
  six reseeding draws with one reseed, the replayed word `0x807060504030201`
  and u32 `0xc0b0a09`, and a specialized uniform.
- `zig build examples --summary all` passes 43/43 steps.
- `zig build test --summary all` passes 906/906, including `apicheck`,
  `toolingcheck`, `examplecheck`, and `readmecheck`.

## Validation

- `zig build distcheck`, `zig build statcheck`, and the 10M long run pass.
- The full 16 MiB benchmark suite keeps all 397 checksums identical to the
  pre-adapter run; the scattered >20% row swings are the documented
  full-suite machine noise, with gains and losses in both directions.

## Next bar

Broader platform runners, vector-directional layout work, or newly discovered
core gaps.
