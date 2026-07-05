# S4-M246 RngReader Adapter

Date: 2026-07-05

## Local Rust Baseline

The local `~/Work/rand/src/lib.rs` exposes `rand::RngReader<R: TryRng>`, an
adapter whose `std::io::Read::read` implementation fills the caller buffer via
`try_fill_bytes` and returns `Ok(buf.len())`. The local Rust test uses a
`StepRng(255, 1)` source and expects little-endian words in the byte stream:
`255, 0, ..., 0, 1, ..., 1, 1, ...`.

This is core RNG interop functionality because it lets a random source feed APIs
that speak the platform's stream reader abstraction instead of direct RNG helper
calls.

## Alea Change

Alea now provides a Zig-native `std.Io.Reader` adapter without copying Rust's
trait shape:

- `rng.reader(buffer)` creates an adapter from an `Rng` facade.
- `Rng.readerFrom(source, buffer)` and `Rng.rngReader(source, buffer)` create
  adapters from direct sources.
- `Rng.RngReader(Source)` is the concrete adapter type and exposes
  `init`, `reader`, `read`, `readAll`, and `lastError`.
- Pointer sources are borrowed, while value sources are owned by the adapter.
- Byte production prefers `tryFillBytes`, then infallible `fill`, then falls back
  through `tryNextU64` / `tryNext` words with little-endian byte packing.
- Fallible source errors are mapped to `std.Io.Reader` `error.ReadFailed` and
  retained in `lastError()` for diagnostics.

This keeps the API Zig-native (`std.Io.Reader`, explicit caller buffer,
concrete generic adapter type) while matching the useful local Rust behavior:
readers are filled from the RNG byte stream and short reads are not used for
normal RNG output.

## Tests and Validation

Focused tests added in `src/rng.zig`:

- `rng reader adapter streams deterministic bytes` reproduces the local Rust
  `StepRng(255, 1)` byte sequence, verifies pointer-source borrowing, and
  verifies value-source ownership.
- `rng reader adapter integrates with Io stream and discard` checks
  `std.Io.Reader.stream` and limited `discard` against direct engine byte fills.
- `rng reader adapter propagates fallible sources` checks `ReadFailed` plus
  `lastError()` diagnostics for sources that only expose `tryNext`.

Documentation/example updates:

- `README.md` lists the `Rng.reader` / `Rng.rngReader` adapter.
- `docs/core-guide.md` explains local Rust `rand::RngReader` mapping and
  ownership/error behavior.
- `docs/api-reference.md` lists the new public symbols.
- `examples/basic.zig` prints a small `rngReader bytes` demo, and
  `tools/examplecheck.zig` guards that adoption token.
- `compare/results/reproducibility-matrix.md` records the stable byte-stream
  contract and focused evidence.

Validation command for this focused milestone:

```sh
zig test src/rng.zig --test-filter "rng reader adapter"
zig build run-basic
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```
