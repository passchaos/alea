# S4-M267 Uniform Unicode Scalar Sampler

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes reusable Unicode `char` range sampling
through its uniform module:

- `~/Work/rand/src/distr/uniform.rs` re-exports `UniformChar` from
  `uniform_other.rs`.
- `~/Work/rand/src/distr/uniform_other.rs` implements `UniformChar` by
  compressing Unicode scalar values around the UTF-16 surrogate gap, then
  expanding sampled compressed values back to valid `char`s.
- Rust callers usually reach this backend through `Uniform<char>`, but the
  reusable `UniformChar` workflow is part of the local implementation surface.

Alea already exposed one-shot, caller-owned, and owned Unicode scalar range
helpers on `Rng`, using explicit `u21` Unicode scalar values instead of a Rust
`char` type. What was missing was a reusable distribution-namespace sampler
for those bounded Unicode scalar ranges.

## Alea Change

Alea now provides `distributions.UniformUnicodeScalar` with:

- `init` / `new` for half-open `[low, high)` Unicode scalar ranges;
- `initInclusive` / `newInclusive` for closed `[low, high]` ranges;
- `lowValue`, `highValue`, and `isInclusive` diagnostics;
- `sample` / `sampleFrom` for reusable draws;
- `fill` / `fillFrom` for caller-owned `[]u21` buffers.

The sampler intentionally uses Zig-native `u21` scalar values and delegates to
the existing Unicode scalar range helpers. It rejects surrogate endpoints and
empty compressed ranges before drawing.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `UniformUnicodeScalar sampler mirrors unicode range helpers` verifies
  constructors, accessors, facade/direct-source sample stream shape, fill stream
  shape, invalid scalar validation, empty-range validation, and inclusive
  point-mass no-consume behavior.

Documentation/example updates:

- `examples/string_generation.zig` prints `UniformUnicodeScalar range sampler`.
- `tools/examplecheck.zig` guards that token.
- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`,
  `docs/examples.md`, and `compare/results/distribution-parity-matrix.md`
  document the sampler.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M268.

Validation commands for this milestone:

```sh
zig test src/distributions.zig --test-filter "UniformUnicodeScalar"
zig build run-string-generation
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```
