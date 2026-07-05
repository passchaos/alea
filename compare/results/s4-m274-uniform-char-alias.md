# S4-M274 UniformChar Discovery Alias

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout re-exports `UniformChar` from
`~/Work/rand/src/distr/uniform.rs`:

- `pub use other::{UniformChar, UniformDuration};`

Rust uses `char` for Unicode scalar values. Alea's Zig-native scalar
representation is `u21`, and the reusable sampler introduced earlier is
`UniformUnicodeScalar`.

## Alea Change

Alea now provides the discovery alias:

```zig
pub const UniformChar = UniformUnicodeScalar;
```

The alias preserves all existing `UniformUnicodeScalar` constructors,
accessors, half-open/inclusive sampling, fills, surrogate-gap validation, and
stream shape. It intentionally does not add a separate Rust-like `char` type;
Zig callers continue to use `u21` Unicode scalar values.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `UniformChar alias mirrors UniformUnicodeScalar` verifies type equality,
  constructor/accessor parity, single-sample and fill stream shape, and invalid
  surrogate endpoint validation.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `compare/results/distribution-parity-matrix.md` document the alias.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M275.

Validation commands for this milestone:

```sh
zig fmt src/distributions.zig tools/roadmapcheck.zig
zig test src/distributions.zig --test-filter "UniformChar alias"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This milestone closes an unblocked local Rust discovery-name side gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
