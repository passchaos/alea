# S4-M284 Distribution Weighted Namespace

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes static weighted-index sampling under the
module path `rand::distr::weighted`:

- `~/Work/rand/src/distr/weighted/mod.rs` declares `mod weighted_index;`;
- it re-exports `pub use weighted_index::WeightedIndex;`;
- it defines the public weighted `Error` enum and Rust-only `Weight` trait used
  by `WeightedIndex` construction and updates.

Alea already exposed the sampler as `distributions.WeightedIndex(Weight)`, an
alias for the richer Zig-native `AliasTable(Weight)`, plus
`distributions.WeightError` / `WeightedError` aliases and Rust-compatible
weighted error variant names. The remaining local Rust discovery path was the
intermediate `weighted` namespace itself.

## Alea Change

Alea now provides:

```zig
pub const weighted = struct {
    pub const Error = distributions.Error;
    pub const WeightedError = distributions.WeightedError;
    pub const WeightError = distributions.WeightError;

    pub fn WeightedIndex(comptime Weight: type) type {
        return distributions.WeightedIndex(Weight);
    }
};
```

This is a namespace alias over existing functionality. It does not introduce a
Rust `Weight` trait or a second weighted sampler implementation. The canonical
Zig-native implementation remains `AliasTable(Weight)`, with
`WeightedIndex(Weight)` and `weighted.WeightedIndex(Weight)` as
Rust-discoverable names.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `weighted namespace mirrors Rust weighted module discovery names` verifies
  `weighted.Error`, `weighted.WeightError`, `weighted.WeightedError`, and
  `weighted.WeightedIndex(Weight)` type equality, invalid-input diagnostics,
  and sample stream shape against top-level `WeightedIndex`.
- The existing `WeightedIndex alias mirrors AliasTable` test still verifies that
  the top-level alias and canonical `AliasTable` sampler stay equivalent.

Documentation/example updates:

- `examples/weighted_sampling.zig` prints `weighted namespace numChoices`.
- `tools/examplecheck.zig` guards that token.
- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`,
  `docs/examples.md`, and `compare/results/distribution-parity-matrix.md`
  document the namespace.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M285.

Validation commands for this milestone:

```sh
zig fmt src/distributions.zig tools/examplecheck.zig tools/roadmapcheck.zig
zig test src/distributions.zig --test-filter "weighted namespace"
zig build run-weighted-sampling
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This milestone closes an unblocked local Rust namespace discovery gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
