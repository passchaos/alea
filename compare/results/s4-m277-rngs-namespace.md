# S4-M277 `rngs` Namespace Aliases

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes common RNG names from
`~/Work/rand/src/rngs/mod.rs`:

- `SmallRng`, `StdRng`, `SysRng`, `SysError`;
- optional ChaCha names `ChaCha8Rng`, `ChaCha12Rng`, `ChaCha20Rng`;
- public Xoshiro names `Xoshiro128PlusPlus`, `Xoshiro256PlusPlus`;
- `ThreadRng`, which relies on Rust's hidden thread-local RNG model.

Alea already exposed the deterministic/secure-style engines and `SysRng` at the
root. The remaining discoverability gap was the `rand::rngs::*` namespace shape.

## Alea Change

Alea now provides a root `rngs` namespace aliasing existing explicit engines and
sources:

```zig
rngs.StdRng
rngs.SmallRng
rngs.SysRng
rngs.SysError
rngs.ChaCha8Rng
rngs.ChaCha12Rng
rngs.ChaCha20Rng
rngs.Xoshiro128PlusPlus
rngs.Xoshiro256PlusPlus
```

The namespace intentionally does not introduce `ThreadRng`: Alea keeps entropy
and RNG ownership explicit instead of adding hidden thread-local state.

## Tests and Validation

Focused test coverage in `src/root.zig`:

- `root rngs namespace mirrors root aliases` verifies type equality for every
  namespace alias and matching stream shape for representative deterministic
  aliases.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, and `docs/api-reference.md` document the
  namespace.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M278.

Validation commands for this milestone:

```sh
zig fmt src/root.zig tools/roadmapcheck.zig
zig test src/root.zig --test-filter "rngs namespace"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This milestone closes an unblocked local Rust namespace discoverability gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
