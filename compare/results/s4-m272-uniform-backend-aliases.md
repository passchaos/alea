# S4-M272 Uniform Backend Discovery Aliases

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout re-exports uniform backend sampler names from
`~/Work/rand/src/distr/uniform.rs`:

- `pub use float::UniformFloat;`
- `pub use int::{UniformInt, UniformUsize};`

These are backend implementation names behind Rust's `Uniform<X>` / `SampleUniform`
trait shape. Alea does not copy that trait/backend model; the public reusable
sampler is the Zig-native `Uniform(T)` family.

## Alea Change

Alea now provides discovery aliases:

```zig
pub fn UniformInt(comptime T: type) type { ... return Uniform(T); }
pub fn UniformFloat(comptime T: type) type { ... return Uniform(T); }
pub const UniformUsize = Uniform(usize);
```

These aliases keep all existing `Uniform(T)` constructors, diagnostics,
sampling, and fill semantics, while making the local Rust backend names easier
to find for users comparing APIs.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `UniformInt Float Usize aliases mirror Uniform` verifies type equality for
  integer, float, and usize aliases and sample stream shape against the
  canonical `Uniform(T)` samplers.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `compare/results/distribution-parity-matrix.md` document the aliases.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M273.

Validation commands for this milestone:

```sh
zig test src/distributions.zig --test-filter "UniformInt Float Usize"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```
