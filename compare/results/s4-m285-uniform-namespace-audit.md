# S4-M285 Uniform Namespace Audit

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes reusable uniform-range implementation
types and traits under `rand::distr::uniform`:

- `~/Work/rand/src/distr/uniform.rs` re-exports `UniformFloat`,
  `UniformInt`, `UniformUsize`, `UniformChar`, and `UniformDuration`.
- The same module defines public trait abstractions `SampleUniform`,
  `UniformSampler`, `SampleBorrow`, and `SampleRange`.
- The root `rand::distr` namespace also re-exports the primary `Uniform`
  sampler, and local examples commonly use both `rand::distr::Uniform` and
  `rand::distr::uniform::{...}` paths.

## Alea Position

Alea already exposes the concrete uniform workflows at the distribution
namespace level:

- `distributions.Uniform(T)` and `VectorUniform(VectorType)` provide reusable
  scalar/vector samplers with `init`, `new`, `initInclusive`, `newInclusive`,
  `tryFromRange`, and `tryFromRangeInclusive` constructors.
- `distributions.UniformInt(T)`, `UniformFloat(T)`, and `UniformUsize` expose
  local Rust backend discovery names as aliases over `Uniform(T)`.
- `distributions.UniformDuration` covers reusable `std.Io.Duration` ranges.
- `distributions.UniformUnicodeScalar` and `UniformChar` cover Rust
  `UniformChar` workflows using Zig-native `u21` Unicode scalar values.
- `distributions.UniformError` aliases the uniform-family error set, including
  the local Rust `NonFinite` diagnostic for non-finite float endpoints or
  widths.
- `distributions.sampleSingle` and `sampleSingleInclusive` cover Rust
  `UniformSampler::sample_single` one-shot discovery while preserving checked
  `uniformChecked*` helpers.

Alea intentionally does not add a `distributions.uniform` namespace today:

- `distributions.uniform(...)` is already a public one-shot half-open uniform
  sampling function. Zig declarations share one namespace, so a new
  `uniform` module/struct would break that existing Zig-native API.
- The remaining Rust `rand::distr::uniform` names are either already available
  as top-level `distributions.*` concrete APIs, or were covered by S4-M283 as
  Rust-specific trait machinery that should not be copied into Zig.
- Adding a differently named namespace such as `uniforms` would not close the
  Rust path-discovery gap and would add redundant surface area.

## Result

No new unblocked implementation gap is identified for local Rust
`rand::distr::uniform::*`. The current Zig-native top-level distribution names
cover the concrete user workflows, and the exact intermediate Rust module path
is intentionally not copied because it collides with Alea's existing one-shot
`uniform` function.

Future work should only reopen this decision if a concrete Zig-native uniform
workflow is missing, not merely because Rust groups these names under an
intermediate module.

## Validation

This is documentation/evidence only. Relevant validation:

```sh
zig fmt tools/roadmapcheck.zig
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This audit does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
