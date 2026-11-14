# S4-M1437 — ReaderRng byte-stream adapter

## Goal

Close the local `rand` `rngs::adapter::ReadRng` gap: adapt a `std.Io.Reader`
byte stream into an engine-like source so captured or synthetic randomness can
drive the whole `Rng` surface (replay, deterministic fixtures, recorded
streams).

## API

`Rng.ReaderRng` (also exported as `rngs.ReaderRng`) holds a
`*std.Io.Reader` and implements:

- `next` / `nextU64`: eight little-endian bytes,
- `nextU32`: four little-endian bytes,
- `fill` / `fillBytes`: the requested bytes,
- `tryNext` / `tryFillBytes`: fallible variants returning the reader error,
- the infallible surface panics on a short or failing read, matching the local
  Rust adapter's contract.

The adapter implements the concrete-engine surface, so `Rng.init(&adapter)`
and `RngOf` work unchanged.

## Tests

`reader rng replays a captured byte stream` feeds a 24-byte buffer and checks
`next()` (0x0807060504030201), `nextU32()` (0x0c0b0a09), a 12-byte `fill`,
`error.EndOfStream` from `tryNext` at the end, and facade sampling through
`Rng.init(&adapter)`.

## Evidence

- `zig build test --summary all` passes 906/906 (the new adapter test plus
  `apicheck`).
- `zig build distcheck`, `zig build statcheck`, and the 10M long run pass.
- `compare/results/distribution-parity-matrix.md` records the `ReadRng`
  coverage row and `compare/results/reproducibility-matrix.md` records the
  byte-stream mapping contract.

## Next bar

Broader platform runners, vector-directional layout work, or newly discovered
core gaps.
