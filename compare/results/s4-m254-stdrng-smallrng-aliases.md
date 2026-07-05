# S4-M254 StdRng And SmallRng Aliases

Date: 2026-07-05

## Local Rust Baseline

The local `~/Work/rand/src/rngs/std.rs` exports `rand::rngs::StdRng`, currently
wrapping ChaCha12 as a standard secure-style deterministic generator. The local
`~/Work/rand/src/rngs/small.rs` exports `rand::rngs::SmallRng`, which maps to a
small fast Xoshiro-family generator on the current 64-bit target.

Alea already exposed concrete Zig-native names for these roles:

- `SecurePrng = ChaCha`;
- `Xoshiro256PlusPlus`;
- `DefaultPrng`, `FastPrng`, `ScalarPrng`, `HashPrng`, and
  `ReproduciblePrng` aliases for Alea-specific workload guidance.

The remaining gap was discoverability for users arriving from local Rust
`rand::rngs::{StdRng, SmallRng}` naming.

## Alea Change

Alea now provides root aliases:

- `StdRng = SecurePrng = ChaCha`;
- `SmallRng = Xoshiro256PlusPlus`.

These are aliases, not new algorithms. They preserve Alea's existing
reproducibility and security/quality contracts while making Rust naming easier
to find. Existing Zig-native names remain the primary documented workload
guidance.

## Tests and Validation

Focused tests in `src/root.zig` verify:

- `StdRng.seedFromU64` matches `SecurePrng.seedFromU64`;
- `SmallRng.seedFromU64` matches `Xoshiro256PlusPlus.seedFromU64`;
- `StdRng.fromSeed` matches `SecurePrng.fromSeed`;
- `SmallRng.fromSeed` matches `Xoshiro256PlusPlus.fromSeed`.

Documentation/example updates:

- `examples/reproducible_streams.zig` prints `StdRng/ChaCha12 alias` and
  `SmallRng/Xoshiro256++ alias`.
- `tools/examplecheck.zig` checks both example tokens.
- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `docs/examples.md` document the aliases.
- `compare/results/reproducibility-matrix.md`,
  `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and
  `tools/roadmapcheck.zig` record the milestone and advance the next-gap row
  to S4-M255.

Validation commands for this milestone:

```sh
zig test src/root.zig --test-filter "Rust-discoverable rng aliases"
zig build run-reproducible-streams
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```
