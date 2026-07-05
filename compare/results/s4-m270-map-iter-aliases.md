# S4-M270 Distribution Map/Iter Aliases

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout re-exports distribution adapter types from
`~/Work/rand/src/distr/mod.rs`:

- `pub use self::distribution::{Distribution, Iter, Map};`
- `~/Work/rand/src/distr/distribution.rs` defines `pub struct Iter<D, R, T>`.
- `~/Work/rand/src/distr/distribution.rs` defines `pub struct Map<D, F, T, S>`.

Alea already had equivalent concrete functionality through
`distributions.MappedSampler`, `distributions.map`, and the `Rng.SampleIterator`
/ `Rng.SampleIteratorFrom` iterator types. The local Rust-discoverable `Map`
and `Iter` type names were missing from the distribution namespace.

## Alea Change

Alea now provides:

```zig
pub fn Map(comptime Sampler: type, comptime Mapper: type, comptime In: type, comptime Out: type) type {
    return MappedSampler(Sampler, Mapper, In, Out);
}

pub fn Iter(comptime Sampler: type, comptime Source: type, comptime T: type) type {
    return Rng.SampleIteratorFrom(Source, Sampler, T);
}
```

These are type aliases over the existing Zig-native mapped sampler and
direct-source sample iterator implementations, not trait machinery.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `distribution Map and Iter aliases mirror concrete adapter types` verifies
  `Map` type equality against `map(...)` / `MappedSampler`, sample stream shape,
  and `Iter` type equality against `sampleIterFrom`.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, and `docs/api-reference.md` document the
  aliases.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M271.

Validation commands for this milestone:

```sh
zig test src/distributions.zig --test-filter "Map and Iter aliases"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```
