# S4-M257 ChaCha8Rng And ChaCha20Rng Engines

Date: 2026-07-05

## Local Rust Baseline

The local Rust `rand` checkout exposes the full optional-`chacha` RNG family:

- `~/Work/rand/Cargo.toml`: `chacha = ["dep:chacha20"]`
- `~/Work/rand/src/rngs/mod.rs`:
  `pub use chacha20::{ChaCha8Rng, ChaCha12Rng, ChaCha20Rng};`

S4-M256 added `ChaCha12Rng = ChaCha`, but Alea still lacked the explicit
`ChaCha8Rng` and `ChaCha20Rng` names and round-count streams visible in local
Rust when the `chacha` feature is enabled.

Local Zig 0.16 standard-library evidence provides the required ciphers:

- `std.crypto.stream.chacha.ChaCha8IETF`
- `std.crypto.stream.chacha.ChaCha12IETF`
- `std.crypto.stream.chacha.ChaCha20IETF`

## Alea Change

Alea now provides:

- `ChaCha8Rng` in `src/engines/chacha8.zig`;
- `ChaCha20Rng` in `src/engines/chacha20.zig`;
- root exports for both names;
- `makeRng(ChaCha8Rng, io)` and `makeRng(ChaCha20Rng, io)`;
- `zig build stream -- --engine chacha8` and `--engine chacha20`;
- `statcheck` coverage for `chacha8`, `chacha12`, and `chacha20`.

Both new engines mirror the existing `ChaCha` workflow surface:

- `init([32]u8)` and `initFromU64` / `seedFromU64`;
- `fromSeed`, `fromSeedBytes`, `fromRng`, and `tryFromRng`;
- `random()` for `std.Random` interop;
- `addEntropy`;
- `next`, `nextU64`, `nextU32`, and try-shaped aliases;
- `fill`, `fillBytes`, and `tryFillBytes`;
- `fork` and `tryFork`.

This preserves Alea's existing ChaCha12 `SecurePrng`, `StdRng`, and
`ChaCha12Rng` contracts while closing the remaining local Rust optional-`chacha`
round-name gap.

## Tests and Validation

Focused tests cover:

- deterministic byte-stream equality for identical `ChaCha8Rng` and
  `ChaCha20Rng` seeds;
- stable byte snapshots for `fill`;
- stable byte snapshots for `addEntropy`;
- root `ChaCha8Rng` / `ChaCha20Rng` seed alias smoke checks;
- inclusion in shared direct-engine raw alias, seed alias, byte-seed,
  `fromRng`, `tryFromRng`, `fork`, `tryFork`, and `makeRng` tests.

Documentation/tooling updates:

- `examples/reproducible_streams.zig` prints `ChaCha8Rng optional-chacha` and
  `ChaCha20Rng optional-chacha`.
- `tools/examplecheck.zig` checks both example tokens.
- `tools/stream.zig` accepts `chacha8` and `chacha20`, and now frees parsed
  command-line arguments via an arena to keep stream smoke runs leak-clean.
- `README.md`, `docs/core-guide.md`, `docs/examples.md`, and
  `docs/api-reference.md` document the new names.
- `compare/results/reproducibility-matrix.md`,
  `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M258.

Validation commands for this milestone:

```sh
zig test src/engines/chacha8.zig
zig test src/engines/chacha20.zig
zig test src/root.zig --test-filter "chacha"
zig test src/root.zig --test-filter "Rust-discoverable rng aliases"
zig test src/root.zig --test-filter "engine fromSeedBytes"
zig test src/root.zig --test-filter "engine fromRng"
zig test src/root.zig --test-filter "engine tryFromRng"
zig test src/root.zig --test-filter "makeRng"
zig build run-reproducible-streams
zig build repro
zig build -Doptimize=ReleaseFast statcheck
zig build stream -- --engine chacha8 --bytes 32
zig build stream -- --engine chacha20 --bytes 32
zig build -Doptimize=ReleaseFast stream -- --engine chacha8 --bytes 67108864 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 64MB -tlmax 64MB
zig build -Doptimize=ReleaseFast stream -- --engine chacha20 --bytes 67108864 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 64MB -tlmax 64MB
zig build -Doptimize=ReleaseFast stream -- --engine chacha20 --seed 0xd1ce5eed --bytes 67108864 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 64MB -tlmax 64MB
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```

The 64MiB PractRand smoke run for `chacha8` had no anomalies. The first
`chacha20` default-seed 64MiB smoke run reported one PractRand `unusual`
low-bit result, which is not a failure; the same-length alternate-seed rerun
was clean.
