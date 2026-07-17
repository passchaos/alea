# S4-M1244 — Polymorphic StandardNormal / StandardExponential / Exp1 unit-struct samplers

## Summary

S4-M1244 adds polymorphic unit-struct samplers for the standard normal (N(0,1))
and standard exponential (Exp(1)) distributions, completing the ergonomic
`rng.sample(T, StandardNormal{})` / `rng.sample(T, StandardExponential{})`
pattern that matches Rust `rand`'s `StandardNormal` and `Exp1` unit-struct
samplers and is consistent with the existing `StandardUniform`, `Open01`,
`OpenClosed01`, and `StandardGeometric` unit-struct samplers already in alea.

## Local Rust reference

Rust `rand 0.10.1` provides unit-struct samplers:
- `rand::distributions::StandardNormal` — samples N(0,1)
- `rand::distributions::Exp1` — samples Exp(1) (rate 1 exponential)

These are used as `rng.sample(StandardNormal)` and `rng.sample(Exp1)` without
any type parameter, since Rust uses trait-based dispatch. In alea, T is an
explicit comptime parameter to the sample method, enabling the same
single-expression ergonomics while supporting both scalar f32/f64 and SIMD
vector types through one struct.

## Changes

1. **`src/distributions.zig`**: `StandardNormal` and `StandardExponential` are
   now polymorphic unit structs (previously they were per-T factory functions
   returning monomorphic sampler types). They support:
   - `sample(rng, T)` for one-shot draws (f32, f64, vector types)
   - `sampleFrom(source, T)` for direct-source draws
   - `fill(rng, T, dest)` for bulk fills
   - `fillFrom(source, T, dest)` for direct-source bulk fills
   - Moment accessors `meanValue(T)`, `stddevValue(T)`, `expectedValue(T)`,
     `varianceValue(T)`, `medianValue(T)`, `modeValue(T)`, `minValue(T)`,
     `maxValue(T)`
   - `Exp1` is now an alias for `StandardExponential` (Rust naming compatibility)
   - Tests added for scalar f64, f32 (via existing coverage), vector sampling
     and fills, and the Exp1 alias.

2. **Call-site updates**:
   - `src/distributions.zig` tests updated for new API
   - `bench/throughput.zig` standard normal/exponential scalar benchmarks
     updated to use the new polymorphic API
   - All benchmarks, tests, and validation steps compile and pass.

## Ergonomic improvement

Before this change, users had three options for standard normal:
- Free functions: `alea.distributions.standardNormal(rng, f64)`
- Per-T monomorphic sampler: `const dist = alea.distributions.StandardNormal(f64){}; dist.sample(rng)`
- Rng methods: `rng.standardNormal(f64)`

After this change, the distribution-sampler pattern is consistent across all
parameter-free distributions:
```zig
const z = rng.sample(f64, alea.distributions.StandardNormal{});
const x = rng.sample(f64, alea.distributions.StandardExponential{});
const x_rust_name = rng.sample(f32, alea.distributions.Exp1{});
const z_vec = rng.sample(@Vector(4, f64), alea.distributions.StandardNormal{});
rng.fillSample(f64, &buf, alea.distributions.StandardNormal{});
var iter = rng.sampleIter(f64, alea.distributions.StandardNormal{});
```

This matches the existing usage pattern for `StandardUniform{}`, `Open01{}`,
`OpenClosed01{}`, and `StandardGeometric{}`, completing the set of
parameter-free distributions with a uniform API.

## Validation

- `zig build test` passes all unit tests
- `zig build statcheck` passes
- `zig build validate` passes including distcheck, profilecheck, and all examples
- `zig build bench` compiles and runs the throughput benchmarks
- Added vector-sampling tests for StandardNormal and StandardExponential
- Added Exp1 alias equality test

## Notable deviations from Rust

Unlike Rust's trait-based dispatch where the return type is inferred, Zig
requires an explicit comptime T parameter to `sample()`. This is consistent
with all other polymorphic unit-struct samplers in alea (`Open01`,
`OpenClosed01`, `StandardUniform`) and is the Zig-idiomatic design: it makes
the sampled type explicit, supports SIMD vector types naturally, and avoids
type-inference ambiguity.

## Evidence

- Code: `src/distributions.zig` (unit-struct definitions, vector support)
- Benchmarks: `bench/throughput.zig`
- Validation: `zig build validate` (passes)
