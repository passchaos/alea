# S4-M264 Distribution ASCII Aliases

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes reusable ASCII distributions from the
distribution namespace:

- `~/Work/rand/src/distr/mod.rs` contains
  `pub use self::other::{Alphabetic, Alphanumeric};`.
- `~/Work/rand/src/distr/other.rs` defines `pub struct Alphanumeric;` and
  `pub struct Alphabetic;`.
- The Rust docs show `rng.sample(Alphanumeric)` /
  `rng.sample(Alphabetic)` and `SampleString` workflows.

Alea already had equivalent ASCII samplers in `ascii.Alphanumeric` and
`ascii.Alphabetic`, backed by `Charset`, plus SampleString-style
`sampleString*` / `appendString*` methods. The distribution namespace did not
yet expose the local Rust discovery names.

## Alea Change

Alea now provides distribution-namespace aliases:

```zig
pub const Alphanumeric = ascii.Alphanumeric;
pub const Alphabetic = ascii.Alphabetic;
```

These are aliases over the canonical `ascii.Charset` values, not a second ASCII
sampling implementation. They therefore keep all existing `Charset` diagnostics,
`sample` / `sampleFrom`, `fill` / `fillFrom`, allocation-returning string, and
append-string workflows, while allowing callers porting local Rust examples to
write `alea.distributions.Alphanumeric` / `Alphabetic`.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `distribution ascii aliases mirror ascii namespace` verifies the alias byte
  sets, facade `Rng.sample`, direct-source `Rng.sampleFrom`, fill output, and
  stream-state equality against the canonical `ascii` namespace values.

Documentation/example updates:

- `examples/string_generation.zig` prints
  `distribution Alphanumeric/Alphabetic bytes`.
- `tools/examplecheck.zig` guards that token.
- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`,
  `docs/examples.md`, and `compare/results/distribution-parity-matrix.md`
  document the aliases.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M265.

Validation commands for this milestone:

```sh
zig test src/distributions.zig --test-filter "distribution ascii aliases"
zig build run-string-generation
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```
