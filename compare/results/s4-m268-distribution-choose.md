# S4-M268 Distribution Choose Sampler

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes reusable slice choice sampling through
the distribution slice namespace:

- `~/Work/rand/src/distr/slice.rs` defines `pub struct Choose<'a, T>`.
- `Choose::new(slice)` returns `Err(Empty)` for empty slices.
- `Choose::num_choices` reports the non-zero choice count.
- `Choose` implements `Distribution<&T>` and therefore integrates with
  `sample_iter`.

Alea already had broad sequence choice support through `Rng.choose*`, `seq`
helpers, and reusable `seq.Choice(T)`, but the distribution namespace did not
have a local Rust-discoverable `Choose` sampler name.

## Alea Change

Alea now provides `distributions.Choose(T)` with:

- `init` / `new` returning `null` for empty slices;
- `initChecked` / `newChecked` returning `error.EmptyRange` for empty slices;
- `len`, `numChoices`, `isEmpty`, and `itemsValue` diagnostics;
- pointer-returning `sample` / `sampleFrom`;
- value-returning `sampleValue` / `sampleValueFrom`;
- pointer and value fills;
- `iter` / `iterFrom` sample iterators.

This is a Zig-native distribution sampler over `[]const T`. It preserves the
existing Alea choice stream shape and singleton no-consume behavior instead of
copying Rust trait machinery.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `distribution Choose sampler mirrors slice choices` verifies construction,
  diagnostics, value sampling stream shape against `Rng.chooseFrom`, value-fill
  stream shape, iterator stream shape against `Rng.chooseConstPtrFrom`,
  singleton no-consume fill behavior, and empty-slice validation.

Documentation/example updates:

- `examples/sequence_sampling.zig` prints `distribution Choose numChoices`.
- `tools/examplecheck.zig` guards that token.
- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`,
  `docs/examples.md`, and `compare/results/distribution-parity-matrix.md`
  document the sampler.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M269.

Validation commands for this milestone:

```sh
zig test src/distributions.zig --test-filter "distribution Choose"
zig build run-sequence-sampling
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```
