# S4-M279 IndexedSamples Aliases

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout re-exports sampled slice iterator names from
`~/Work/rand/src/seq/mod.rs` and defines them in `~/Work/rand/src/seq/slice.rs`:

- `pub use slice::IndexedSamples;`
- deprecated alias `pub type SliceChooseIter<'a, S, T> = IndexedSamples<'a, S, T>;`

These iterators yield sampled immutable references and report exact-size
iterator diagnostics.

## Alea Change

Alea already had owned sampled no-replacement iterator implementations:

- `SampledPtrIterator(T)` for sampled `*const T` references;
- `SampledValueIterator(T)` and `SampledMutPtrIterator(T)` as Zig-native
  extensions.

S4-M279 adds discovery aliases over the const-pointer iterator:

```zig
pub fn IndexedSamples(comptime T: type) type { return SampledPtrIterator(T); }
pub fn SliceChooseIter(comptime T: type) type { return IndexedSamples(T); }
```

The aliases preserve allocator-owned sampled index cleanup, exact `len` /
`sizeHint` diagnostics, `fill` helpers, and pointer stream shape.

## Tests and Validation

Focused test coverage in `src/seq.zig`:

- `IndexedSamples aliases sampled pointer iterators` verifies alias type equality,
  exact-size diagnostics, pointer stream shape against `SampledPtrIterator`, and
  matching source advancement.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `compare/results/distribution-parity-matrix.md` document the aliases.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M280.

Validation commands for this milestone:

```sh
zig fmt src/seq.zig tools/roadmapcheck.zig
zig test src/seq.zig --test-filter "IndexedSamples aliases"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This milestone closes an unblocked local Rust sequence iterator discovery gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
