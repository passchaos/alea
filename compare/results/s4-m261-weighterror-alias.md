# S4-M261 WeightError Alias

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout re-exports a weighted-sampling error name from
the sequence namespace:

- `~/Work/rand/src/seq/mod.rs` contains
  `pub use crate::distr::weighted::Error as WeightError;`.

Alea already had weighted-sampling error cases through `seq.Error`, but the
Rust-discoverable `WeightError` name was not available.

## Alea Change

Alea now provides:

- `seq.WeightError = seq.Error`;
- root `WeightError = seq.WeightError`.

These are aliases, not a new error model. They preserve Alea's existing
weighted-index and weighted-choice error contract while making the local Rust
`rand::seq::WeightError` discovery name available.

## Tests and Validation

Focused root tests verify:

- root `WeightError` is assignable as `seq.WeightError`.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, and `docs/api-reference.md` document the
  alias with sequence and weighted APIs.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M262.

Validation commands for this milestone:

```sh
zig test src/root.zig --test-filter "WeightError"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```
