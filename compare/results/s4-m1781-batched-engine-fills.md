# S4-M1781 Four-Word Batched Engine Fills

Date: 2026-11-20

## Gap

The `Xoshiro256PlusPlus` fill emitted one `u64` per loop iteration with a
separate `writeInt` + `@memcpy`, and the same shape existed in
`Xoshiro256`, `Pcg64`, `Wyhash64`, and `Xoshiro128PlusPlus`. The local
`xoshiro256++ fill-only` row was 10841-10844 MiB/s versus local Rust
`SmallRng` (also xoshiro256++) at 11314 MiB/s.

## Change

Each engine's fill now emits four words per iteration (32-byte stores for the
u64 engines, 16-byte stores for `Xoshiro128PlusPlus`) and keeps the original
per-word tail handling. The emitted word order and the engine stream are
unchanged (the `fill-only` tail byte is unchanged and the engine snapshot tests
pass).

## Measurements

Same host, `ReleaseFast -Dcpu=native`,
`bench -- 16777216 "xoshiro256++ fill-only"`, three runs each:

| Variant | Runs (MiB/s) |
| --- | --- |
| Before (one word per iteration) | 10841.6, 10844.4, 11069.2 |
| After (four-word batches) | 11263.3, 11268.3, 11268.9 |

That is about +4% and reaches parity with local Rust `SmallRng`
(11314 MiB/s). The other batched engines (`xoshiro256**`, `pcg64`,
`wyhash64`, `xoshiro128++`) use the same mechanical change and stream tests;
the harness has no `fill-only` rows for them, and their byte-throughput rows
are limited by the bench's per-byte XOR checksum rather than the engine.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests (engine snapshot
  and stream-shape tests pass).
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- No reproducibility-matrix mapping change is needed because the output stream
  is unchanged.

## Next Bar

Keep the no-known-gaps comparison current and only land further changes that
clear the host noise floor.
