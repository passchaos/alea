# S4-M1446 Core-Guide Engine Adapter Coverage

Date: 2026-11-14

## Gap

`docs/api-reference.md` documents `ReseedingRng`, `ReaderRng`, and `readerRng`,
and `examples/engine_adapters.zig` demonstrates them, but `docs/core-guide.md`
only covered the `rngReader`/`RngReader` byte-stream view. A reader of the
guide's engine section could not discover the reseeding or byte-replay
adapters, their stream contracts, or their prelude names.

## Change

Added a paragraph to the engine section covering:

- `Rng.ReseedingRng(Engine)` / `rngs.ReseedingRng`: the `seedFromU64`
  requirement, the exact `reseed_threshold` cadence, the
  `reseedCount`/`thresholdValue`/`remainingDraws`/`enginePtr` diagnostics, and
  the rule that byte fills never cross a reseed boundary.
- `Rng.ReaderRng` / `rngs.ReaderRng`: the little-endian 8-byte word and 4-byte
  u32 mapping, byte `fill`/`fillBytes`, fallible `tryNext`/`tryFillBytes`, and
  the infallible short-read panic contract.
- The root `readerRng(reader)` constructor, the `random()` `std.Random` views,
  `Rng.init`/`RngOf` integration, and the `prelude.ReseedingRng` /
  `prelude.ReaderRng` aliases.

## Validation

- `zig build roadmapcheck` passes.
- Docs-only change: no source, tests, benchmarks, or public surface changed.
