# S4-M273 Distribution Slice Namespace Aliases

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes slice-choice distribution names in
`~/Work/rand/src/distr/slice.rs`:

- `pub struct Choose<'a, T>`
- `pub struct Empty`

The module is available as `rand::distr::slice`, so users comparing APIs see
`rand::distr::slice::Choose` and `rand::distr::slice::Empty` in addition to the
broader distribution namespace.

## Alea Change

Alea already had a Zig-native reusable `distributions.Choose(T)` sampler over
`[]const T`. S4-M273 adds the namespace discovery aliases:

```zig
pub const slice = struct {
    pub const Empty = Error;

    pub fn Choose(comptime T: type) type {
        return distributions.Choose(T);
    }
};
```

The aliases intentionally preserve the existing sampler implementation,
constructor behavior, pointer/value sampling, fills, sample iterators, singleton
no-consume behavior, and `Error` contract. They do not introduce Rust traits or a
separate module file solely to mirror Rust's module layout.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `distribution slice aliases mirror Choose and Empty errors` verifies
  `slice.Choose(T)` type equality with `Choose(T)`, matching sample stream shape,
  and `slice.Empty` assignability for the empty-slice constructor error path.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `compare/results/distribution-parity-matrix.md` document the slice namespace
  aliases.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M274.

Validation commands for this milestone:

```sh
zig fmt src/distributions.zig tools/roadmapcheck.zig
zig test src/distributions.zig --test-filter "distribution slice aliases"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This milestone closes an unblocked local Rust discovery-name side gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
