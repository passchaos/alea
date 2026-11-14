# S4-M1441 — std.Random interop and prelude aliases for the engine adapters

## Goal

Finish the adapter ergonomics: give `ReseedingRng` and `ReaderRng` the same
`std.Random` view that concrete engines expose, add a free-function
`readerRng` constructor mirroring `rngReader`, and surface both adapters in
the `prelude` namespace.

## Change

- `ReseedingRng.random()` and `ReaderRng.random()` return
  `std.Random.init(self, fill)` over the adapter's byte fill.
- New `readerRng(reader)` free-function constructor.
- `prelude.ReseedingRng` and `prelude.ReaderRng` aliases; the API reference
  lists the new members.

## Tests

- `reader rng replays a captured byte stream` now also checks
  `readerRng(&reader).random().int(u32) == 0x04030201` from the captured
  bytes.
- `reseeding rng reseeds on cadence and stays deterministic` now checks that
  `random().int(u64)` matches a direct adapter draw with the same seed and
  reseeder stream.

## Evidence

- `zig build test --summary all` passes 906/906, including `apicheck`,
  `toolingcheck`, `examplecheck`, and `readmecheck`.
- `zig build distcheck`, `zig build statcheck`, and the 10M long run pass.

## Next bar

Broader platform runners, vector-directional layout work, or newly discovered
core gaps.
