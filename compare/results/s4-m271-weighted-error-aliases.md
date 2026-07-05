# S4-M271 Distribution Weighted Error Aliases

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes a weighted-distribution error type from
`~/Work/rand/src/distr/weighted/mod.rs`:

- `pub enum Error`;
- it is documented as the error type for `WeightedIndex::new`,
  `WeightedIndex::update_weights`, and other weighted distributions;
- `rand::seq::WeightError` is a re-export of this weighted distribution error.

Alea already exposed the sequence/root `WeightError` discovery names, and all
weighted distribution failures used the existing `distributions.Error` cases.
The distribution-namespace weighted error discovery names were missing.

## Alea Change

Alea now provides:

```zig
pub const WeightedError = Error;
pub const WeightError = Error;
```

These aliases preserve Alea's existing weighted-sampling error contract while
making the distribution namespace easier to discover for callers comparing
against local Rust `rand::distr::weighted::Error`. S4-M281 later extended the
shared distribution error set with the local Rust variant names
`InvalidInput`, `InsufficientNonZero`, and `Overflow` for static
`AliasTable` / `WeightedIndex` diagnostics while preserving the alias
relationship.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `distribution weight error aliases mirror Error` verifies both aliases and
  representative invalid-weight paths through `AliasTable` and `WeightedIndex`.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `compare/results/distribution-parity-matrix.md` document the aliases.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M272.

Validation commands for this milestone:

```sh
zig test src/distributions.zig --test-filter "weight error aliases"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```
