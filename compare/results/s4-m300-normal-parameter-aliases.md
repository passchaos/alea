# S4-M300 Normal Parameter Discovery Aliases

Date: 2026-07-06

## Purpose

The cached local `rand_distr 0.6.0` `Normal` sampler exposes parameter accessors
named `mean()` and `std_dev()`. Alea already exposed the same diagnostics as
`Normal(T).meanValue()` and `Normal(T).stddevValue()`, but the local Rust
accessor names remained a small discovery side gap in the public-surface scan.

## Design

Alea's `Normal(T)` keeps public fields named `mean` and `stddev` for direct
Zig-native parameter echoing. Zig does not allow a struct field and method to
share the same name, so copying Rust's exact `mean()` method would require a
source-breaking field rename. S4-M300 therefore adds Zig-native parameter aliases
instead of exact Rust method names:

- `Normal(T).meanParameter()` -> `meanValue()`
- `Normal(T).stddevParameter()` -> `stddevValue()`
- `Normal(T).stdDevParameter()` -> `stddevValue()`

The lowercase-`d` alias matches Alea's existing `stddevValue` spelling, while the
camel-case `stdDevParameter` spelling helps users searching for Rust's
`std_dev` wording in Zig style.

## Validation

Relevant validation:

```sh
zig fmt src/distributions.zig tools/surfacecheck.zig tools/roadmapcheck.zig
zig test src/distributions.zig --test-filter "Normal parameter aliases"
zig build surfacecheck
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone closes a small local `rand_distr` accessor-discovery side gap. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add an additional architecture/runtime runner, and is not
whole-goal completion evidence.
