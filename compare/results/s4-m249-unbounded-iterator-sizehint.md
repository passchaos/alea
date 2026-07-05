# S4-M249 Unbounded Iterator Size Hints

Date: 2026-07-05

## Local Rust Baseline

The local `~/Work/rand/src/distr/distribution.rs` defines `Iter<D, R, T>` for
`Distribution::sample_iter`, `RngExt::sample_iter`, and `random_iter`. Its
`Iterator::size_hint` implementation returns `(usize::MAX, None)` to indicate
an effectively unbounded random stream.

Alea already had unbounded value/random/sample iterators and `fill` methods, but
the unbounded size-hint diagnostic was missing from these iterator types.

## Alea Change

Alea now exposes `sizeHint()` on:

- `Rng.ValueIterator(T)`
- `Rng.ValueIteratorFrom(Source, T)`
- `Rng.SampleIterator(Sampler, T)`
- `Rng.SampleIteratorFrom(Source, Sampler, T)`

The returned shape is `{ .lower = std.math.maxInt(usize), .upper = null }`, a
Zig-native equivalent of local Rust `(usize::MAX, None)` for unbounded streams.
The existing iterator `fill` stream policies are unchanged.

## Tests and Validation

Focused test coverage in `src/rng.zig`:

- `value and sampler iterators produce unbounded samples` now verifies size
  hints for facade/direct value iterators, random iterators, sample iterators,
  and direct-source sample iterators before and after scalar draws and fills.

Documentation/example updates:

- `README.md` and `docs/core-guide.md` document unbounded iterator `sizeHint()`
  diagnostics.
- `docs/api-reference.md` lists the new iterator public methods.
- `examples/basic.zig` prints `sampleIter sizeHint`, and
  `tools/examplecheck.zig` guards that token.
- `docs/examples.md`, `compare/results/reproducibility-matrix.md`,
  `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M250.

Validation commands for this milestone:

```sh
zig test src/rng.zig --test-filter "value and sampler iterators produce unbounded samples"
zig build run-basic
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```
