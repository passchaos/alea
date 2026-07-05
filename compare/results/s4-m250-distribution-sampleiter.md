# S4-M250 Distribution sampleIter Aliases

Date: 2026-07-05

## Local Rust Baseline

The local `~/Work/rand/src/distr/distribution.rs` exposes
`Distribution::sample_iter`, allowing callers to create an unbounded iterator
from a reusable distribution directly. Alea already exposed equivalent iterator
functionality through `rng.sampleIter(T, sampler)` and
`Rng.sampleIterFrom(source, T, sampler)`, but the distribution namespace did not
have the Rust-discoverable `sampleIter` spelling.

## Alea Change

Alea now provides distribution-namespace aliases:

- `distributions.sampleIter(rng, T, sampler)` delegates to `rng.sampleIter`.
- `distributions.sampleIterFrom(source, T, sampler)` delegates to
  `Rng.sampleIterFrom`.

The aliases preserve existing Alea iterator behavior, including unbounded
`sizeHint()` and sampler-specific fill stream policies.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `distribution namespace sample iterators mirror rng facade iterators` compares
  namespace iterators to facade/direct-source iterators for reusable `Uniform`
  samplers, verifies unbounded `sizeHint`, fill stream shape, scalar next stream
  shape, and mapped-sampler integration.

Documentation/example updates:

- `README.md`, `docs/core-guide.md`, and `docs/api-reference.md` document the
  aliases.
- `examples/range_sampling.zig` prints `distribution sampleIter die`, and
  `tools/examplecheck.zig` guards that token.
- `docs/examples.md`, `compare/results/reproducibility-matrix.md`,
  `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M251.

Validation commands for this milestone:

```sh
zig test src/distributions.zig --test-filter "distribution namespace sample iterators"
zig build run-range-sampling
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```
