# S4-M256 ChaCha12Rng Alias

Date: 2026-07-05

## Local Rust Baseline

The local `~/Work/rand/src/rngs/mod.rs` exposes `ChaCha8Rng`,
`ChaCha12Rng`, and `ChaCha20Rng` when the optional `chacha` feature is enabled.
Local `StdRng` currently wraps ChaCha12, and S4-M254 already added the
Rust-discoverable `StdRng` root alias.

Alea already had a concrete Zig-native `ChaCha` engine implementing the
ChaCha12 secure-style stream, plus `SecurePrng = ChaCha` and `StdRng =
SecurePrng`. The remaining local Rust discoverability gap was the explicit
`ChaCha12Rng` name.

## Alea Change

Alea now provides:

- `ChaCha12Rng = ChaCha` at the root.

This is an alias, not a new algorithm. It preserves the existing `ChaCha` /
`SecurePrng` output and seed contracts while making local Rust optional
`rand::rngs::ChaCha12Rng` naming discoverable.

## Tests and Validation

Focused root tests verify:

- `ChaCha12Rng.seedFromU64(seed)` matches `ChaCha.seedFromU64(seed)`.

Documentation/example updates:

- `examples/reproducible_streams.zig` prints `ChaCha12Rng alias`.
- `tools/examplecheck.zig` checks the new example token.
- `README.md`, `docs/core-guide.md`, and `docs/api-reference.md` document the
  alias.
- `compare/results/reproducibility-matrix.md`,
  `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and
  `tools/roadmapcheck.zig` record the milestone and advance the next-gap row to
  S4-M257.

Validation commands for this milestone:

```sh
zig test src/root.zig --test-filter "Rust-discoverable rng aliases"
zig build run-reproducible-streams
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```
