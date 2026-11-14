# S4-M1435 — ReseedingRng engine adapter

## Goal

Close the local `rand` `rngs::adapter::ReseedingRng` gap with a Zig-native
adapter. Long-running services can keep a fast engine while bounding how much
output a single state produces by periodically reseeding from a source RNG.

## API

`Rng.ReseedingRng(Engine)` (also exported as `rngs.ReseedingRng`) requires
`Engine.seedFromU64` at comptime and exposes:

- `init(engine, reseeder: Rng, reseed_threshold: u64)`,
- `next`, `nextU64`, `nextU32` (mirrors the wrapped engine's `nextU32` when it
  exposes one), and byte `fill`/`fillBytes` that never cross a reseed
  boundary,
- `reseedCount`, `thresholdValue`, `remainingDraws`, and `enginePtr`
  diagnostics.

The adapter implements the same surface as a concrete engine, so
`Rng.init(&adapter)` and `RngOf(ReseedingRng(Engine))` work unchanged. A
reseeds replaces the inner state with `Engine.seedFromU64(reseeder.nextU64())`
after exactly `reseed_threshold` engine draws.

## Tests

- `reseeding rng reseeds on cadence and stays deterministic`: two adapters
  with identical engine seeds, reseeder streams, and thresholds produce the
  same values; the fifth draw after a threshold of four triggers the first
  reseed; a plain engine with the same initial seed diverges after the
  reseed; the type-erased facade `Rng.init(&adapter)` samples through the
  adapter.
- `reseeding rng byte fill respects the reseed boundary`: a 64-byte fill with
  a two-draw threshold performs exactly three reseeds and leaves zero
  remaining draws; the `nextU32` path reseeds on its own cadence.

## Evidence

- `zig build test --summary all` passes 905/905 (two new adapter tests plus
  `apicheck`).
- `zig build distcheck`, `zig build statcheck`, and the 10M long run pass.
- `compare/results/distribution-parity-matrix.md` records the
  `ReseedingRng` coverage row and
  `compare/results/reproducibility-matrix.md` records the deterministic
  stream contract.

## Benchmark

New rows `alea reseeding-xoshiro256++ fill` and
`alea reseeding-xoshiro256++ next` (threshold `1 << 20` draws) compare the
adapter against the plain engine on the same 16 MiB workload:

- fill: `xoshiro256++` 2899-2914 MiB/s against 2894-2929 MiB/s for the
  adapter (parity, because the adapter chunks at reseed boundaries),
- next: `xoshiro256++` 1453M draws/s against 1427-1430M for the adapter
  (~1.6% for the per-draw reseed check).

## Next bar

Broader platform runners, vector-directional layout work, or newly discovered
core gaps.
