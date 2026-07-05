# S4-M262 StandardUniform Sampler

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes the default-value distribution in
`~/Work/rand/src/distr/mod.rs`:

- `pub struct StandardUniform;`
- docs describe `StandardUniform` as the default distribution used by
  `RngExt::random` / `rand::random`;
- the documented support covers whole-range integers, `[0, 1)` floats, bools,
  Unicode scalar `char`, and compound types whose components are supported.

Alea already had equivalent default-value sampling through `Rng.value(T)`,
`Rng.valueFrom(source, T)`, and Rust-discoverable `randomValue` aliases, but did
not expose a reusable distribution-namespace sampler with the Rust-discoverable
`StandardUniform` name. Alea keeps Unicode scalar generation in the explicit
`Rng.unicodeScalar*` / Unicode UTF-8 helper APIs rather than overloading a Zig
integer as Rust `char`.

## Alea Change

Alea now provides `distributions.StandardUniform` with:

- `sample(rng, T)` delegating to `rng.value(T)`;
- `sampleFrom(source, T)` delegating to `Rng.valueFrom(source, T)`;
- `fill(rng, T, dest)` and `fillFrom(source, T, dest)` for repeated default
  values.

Primitive and vector fills intentionally use the existing stream-compatible
`Rng.fill` / `Rng.fillFrom` fast paths. Compound fills use repeated
`Rng.valueFrom` draws so arrays, tuples, and enums remain available through the
sampler even though `Rng.fill` itself is limited to primitive/vector slices.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `standard uniform sampler mirrors value helpers` verifies facade and
  direct-source scalar samples, primitive bulk fills, compound repeated-value
  fills, output equality, and stream-state equality against the underlying
  `Rng.value` / `Rng.fill` helpers.

Documentation/example updates:

- `examples/range_sampling.zig` prints `StandardUniform pair=...` and a `[0,1)`
  f32 fill; `tools/examplecheck.zig` guards that token.
- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`,
  `docs/examples.md`, `compare/results/distribution-parity-matrix.md`, and
  `compare/results/reproducibility-matrix.md` document the sampler, its
  relationship to `Rng.value`, and its stream-shape contract.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M263.

Validation commands for this milestone:

```sh
zig test src/distributions.zig --test-filter "standard uniform"
zig build run-range-sampling
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```
