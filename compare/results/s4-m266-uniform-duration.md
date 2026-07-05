# S4-M266 UniformDuration Sampler

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes a reusable duration-range sampler through
the uniform module:

- `~/Work/rand/src/distr/uniform.rs` re-exports
  `UniformDuration` from `uniform_other.rs`.
- `~/Work/rand/src/distr/uniform_other.rs` implements `SampleUniform for
  core::time::Duration` with a `UniformDuration` backend.
- The Rust backend supports half-open `new`, inclusive `new_inclusive`, and
  reusable `sample` workflows.

Alea already had equivalent one-shot and allocation-returning duration range
helpers on `Rng`, but did not expose a reusable distribution-namespace duration
sampler.

## Alea Change

Alea now provides `distributions.UniformDuration` with:

- `init` / `new` for half-open `[low, high)` duration ranges;
- `initInclusive` / `newInclusive` for closed `[low, high]` ranges;
- `lowValue`, `highValue`, and `isInclusive` diagnostics;
- `sample` / `sampleFrom` for reusable draws;
- `fill` / `fillFrom` for caller-owned duration slices.

The sampler delegates to the existing `Rng.durationRangeLessThan*` and
`Rng.durationRangeAtMost*` helper semantics, including inclusive point-mass
no-consume behavior for `low == high`.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `UniformDuration sampler mirrors duration helpers` verifies constructors,
  accessors, facade/direct-source sample stream shape, fill stream shape,
  inclusive point-mass no-consume behavior, and invalid range errors.

Documentation/example updates:

- `examples/range_sampling.zig` prints
  `UniformDuration.newInclusive [10ms,20ms]`.
- `tools/examplecheck.zig` guards that token.
- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`,
  `docs/examples.md`, and `compare/results/distribution-parity-matrix.md`
  document the sampler.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M267.

Validation commands for this milestone:

```sh
zig test src/distributions.zig --test-filter "UniformDuration"
zig build run-range-sampling
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```
