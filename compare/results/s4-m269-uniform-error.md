# S4-M269 UniformError Alias

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes the uniform constructor error type in
`~/Work/rand/src/distr/uniform.rs`:

- `pub enum Error { EmptyRange, NonFinite }`;
- the docs describe it as the error type returned from `Uniform::new` and
  `new_inclusive`;
- local `Uniform`, `UniformChar`, and `UniformDuration` constructors use this
  error shape for invalid ranges or invalid/non-finite range inputs.

Alea already had equivalent invalid uniform-family outcomes through the broader
`distributions.Error` set. The local Rust-discoverable `UniformError` name was
missing.

## Alea Change

Alea now provides:

```zig
pub const UniformError = Error;
```

The alias intentionally preserves Alea's existing uniform-family error contract
instead of introducing a second error model. It covers scalar/vector `Uniform`,
`UniformDuration`, `UniformUnicodeScalar`, one-shot `sampleSingle*`, and the
related checked uniform helper surface.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `UniformError mirrors uniform-family errors` verifies that `UniformError`
  aliases `Error`, that scalar/vector/duration/Unicode uniform constructors
  expose the alias error set, and that representative invalid ranges still
  return `error.EmptyRange`.

Documentation/example updates:

- `examples/range_sampling.zig` prints `UniformError alias`.
- `tools/examplecheck.zig` guards that token.
- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `compare/results/distribution-parity-matrix.md` document the alias.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M270.

Validation commands for this milestone:

```sh
zig test src/distributions.zig --test-filter "UniformError"
zig build run-range-sampling
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```
