# S4-M290 `rand_distr` `Exp` / `Exp1` Aliases

Date: 2026-07-06

## Local Rust Baseline

The cached local `rand_distr 0.6.0` crate exposes exponential distribution names
from its root:

- `~/.../rand_distr-0.6.0/src/lib.rs` re-exports
  `pub use self::exponential::{Error as ExpError, Exp, Exp1};`.
- `~/.../rand_distr-0.6.0/src/exponential.rs` defines `pub struct Exp1` for
  the standard exponential distribution and `pub struct Exp<F>` for the
  rate-parameterized exponential distribution.

Alea already had the concrete samplers as `StandardExponential(T)` and
`Exponential(T)`, plus one-shot, fill, batch, vector, and opt-in native/table
profiles. The missing piece was the shorter local `rand_distr` discovery names.

## Alea Change

Alea now provides:

```zig
pub fn Exp1(comptime T: type) type {
    return StandardExponential(T);
}

pub fn Exp(comptime T: type) type {
    return Exponential(T);
}
```

These are pure aliases. They preserve the existing exact/default sampler
implementation, parameter validation, moments/support accessors, direct-source
sampling, bulk fills, and stream shape.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `rand_distr Exp and Exp1 aliases mirror exponential samplers` verifies type
  equality, parameter accessors, one-shot stream shape, source advancement, and
  standard-exponential fill stream shape against the canonical sampler names.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `compare/results/distribution-parity-matrix.md` document the aliases.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M291.

Validation commands for this milestone:

```sh
zig fmt src/distributions.zig tools/roadmapcheck.zig
zig test src/distributions.zig --test-filter "Exp and Exp1 aliases"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This milestone closes a local `rand_distr` discovery-name side gap only. It does
not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
