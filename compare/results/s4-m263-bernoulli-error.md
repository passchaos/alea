# S4-M263 BernoulliError Discovery

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout re-exports Bernoulli's constructor error type
from the distribution namespace:

- `~/Work/rand/src/distr/mod.rs` contains
  `pub use self::bernoulli::{Bernoulli, BernoulliError};`.
- `~/Work/rand/src/distr/bernoulli.rs` defines
  `pub enum BernoulliError { InvalidProbability }`.
- `Bernoulli::new` and `Bernoulli::from_ratio` return
  `Result<Bernoulli, BernoulliError>`.

Alea already returned `error.InvalidProbability` for invalid Bernoulli
parameters, but only through the broad `distributions.Error` set. The
Rust-discoverable `BernoulliError` name was missing.

## Alea Change

Alea now provides `distributions.BernoulliError` as a dedicated error set:

```zig
pub const BernoulliError = error{
    InvalidProbability,
};
```

Scalar `Bernoulli.init`, `Bernoulli.new`, `Bernoulli.initRatio`,
`Bernoulli.newRatio`, and `Bernoulli.fromRatio` now return `BernoulliError`.
The vector `VectorBernoulli(...).init`, `new`, `initRatio`, `newRatio`, and
`fromRatio` constructors do the same. Existing checked top-level distribution
helpers keep their broader `distributions.Error` return type so the rest of the
fallible distribution facade remains stable.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `BernoulliError mirrors local rand error shape` verifies that
  `BernoulliError` contains `InvalidProbability`, that scalar/vector Bernoulli
  constructors expose the dedicated error set, and that invalid probability and
  invalid ratio cases still fail as `error.InvalidProbability`.

Documentation/example updates:

- `examples/discrete_distributions.zig` prints `BernoulliError alias`.
- `tools/examplecheck.zig` guards that token.
- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`,
  `docs/examples.md`, and `compare/results/distribution-parity-matrix.md`
  document the alias.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M264.

Validation commands for this milestone:

```sh
zig test src/distributions.zig --test-filter "BernoulliError"
zig build run-discrete-distributions
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```
