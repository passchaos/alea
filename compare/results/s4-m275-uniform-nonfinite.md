# S4-M275 Uniform NonFinite Error Parity

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes uniform constructor errors in
`~/Work/rand/src/distr/uniform.rs`:

- `pub enum Error { EmptyRange, NonFinite }`

`~/Work/rand/src/distr/uniform_float.rs` returns `Error::NonFinite` when float
uniform endpoints are non-finite or when the computed float range width is
non-finite, and returns `Error::EmptyRange` for finite reversed/empty ranges.

## Alea Change

Alea now distinguishes the same diagnostics in its checked range/uniform error
sets:

- `Rng.Error` includes `NonFinite`;
- `distributions.Error` / `UniformError` include `NonFinite`;
- checked scalar float range helpers (`floatRangeChecked*`, `randomRangeChecked*`,
  `rangeBatchChecked*`, `fillRangeChecked*`) return `error.NonFinite` for
  non-finite endpoints or widths;
- checked vector float range helpers (`vectorRangeChecked*`,
  `vectorRangeBatchChecked*`, `fillVectorRangeChecked*`) return
  `error.NonFinite` for non-finite endpoints or widths;
- `Uniform(T)` and `VectorUniform(VectorType)` constructors plus checked
  uniform one-shot/fill wrappers propagate `error.NonFinite` on the same
  non-finite float cases.

Finite invalid ranges still return `error.EmptyRange`, and empty output buffers
keep their existing no-validation/no-consume behavior.

## Tests and Validation

Focused coverage updates:

- existing invalid-path tests now expect `error.NonFinite` for non-finite float
  range/uniform inputs while continuing to verify random streams are not
  consumed;
- `UniformError mirrors uniform-family errors` continues to verify the alias
  relationship for the shared distribution error set.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`,
  `compare/results/distribution-parity-matrix.md`, and the historical
  `compare/results/s4-m269-uniform-error.md` evidence now mention `NonFinite`.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M276.

Validation commands for this milestone:

```sh
zig fmt src/rng.zig src/distributions.zig tools/roadmapcheck.zig
zig test src/rng.zig --test-filter "invalid"
zig test src/distributions.zig --test-filter "UniformError"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This milestone closes an unblocked local Rust uniform diagnostics side gap only.
It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
