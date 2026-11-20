# S4-M1780 ChaCha Fill Consumed-Buffer Zeroing Removal

Date: 2026-11-20

## Gap

The buffered ChaCha engine's `fill` copied each consumed buffer region to the
destination and then zeroed the same region. The copied keystream bytes are
already public output, and the hidden key prefix is overwritten by the next
refill, so the zeroing only added a second memory pass over every emitted byte.
The local ChaCha12 fill-only row was 2400.9 MiB/s versus local Rust `StdRng`
(ChaCha12) at 2947.6 MiB/s; part of that gap is the redundant pass, and part is
the rekeying construction's copy-through (the first 64 bytes of each 512-byte
block are the next key and are never emitted, so a direct into-destination
stream is not possible without changing the versioned stream shape).

## Change

`src/engines/chacha.zig` `fill` no longer zeroes the consumed buffer region.
The stream is unchanged (the benchmark tail byte is unchanged); the engine's
internal buffer is never observable, and the forward-secret key prefix is
regenerated on every refill.

## Measurements

Same host, `ReleaseFast -Dcpu=native`, `bench -- 16777216 "fill"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `chacha12 fill-only` | 2400.9 MiB/s | 2476-2494 MiB/s | about +3.5% |
| `xoshiro256++ fill-only` | 10842.6 MiB/s | 10833.7 MiB/s | unchanged |
| `alea4x64 fill-only` | 22104.5 MiB/s | 22098.2 MiB/s | unchanged |

The remaining gap to Rust `StdRng` is the rekeying construction's
buffer-copy-through, which is a deliberate stream-shape tradeoff rather than a
code inefficiency.

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
