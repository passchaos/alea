# S4-M298 SkewNormal Parameter Discovery Aliases

Date: 2026-07-06

## Purpose

The cached local `rand_distr 0.6.0` `SkewNormal` sampler exposes parameter
accessors named `location()`, `scale()`, and `shape()`. Alea already exposed the
same diagnostics as Zig-native `locationValue()`, `scaleValue()`, and
`shapeValue()`, but the local Rust accessor names remained a small discovery
side gap in the public-surface manifest scan.

## Design

Alea's `SkewNormal(T)` keeps public fields named `location`, `scale`, and
`shape`. Zig does not allow a struct field and method to share the same name, so
copying Rust's exact method names would either fail to compile or require a
source-breaking field rename. S4-M298 therefore adds Zig-native parameter aliases
instead of exact Rust method names:

- `SkewNormal(T).locationParameter()` -> `locationValue()`
- `SkewNormal(T).scaleParameter()` -> `scaleValue()`
- `SkewNormal(T).shapeParameter()` -> `shapeValue()`
- `VectorSkewNormal(VectorType).locationParameter()` -> `locationValue()`
- `VectorSkewNormal(VectorType).scaleParameter()` -> `scaleValue()`
- `VectorSkewNormal(VectorType).shapeParameter()` -> `shapeValue()`

This keeps existing field access and value-accessor names stable while making the
parameter-accessor workflow easier to discover for users comparing against local
`rand_distr::SkewNormal`.

## Validation

Relevant validation:

```sh
zig fmt src/distributions.zig tools/roadmapcheck.zig
zig test src/distributions.zig --test-filter "SkewNormal parameter aliases"
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone closes a small local `rand_distr` accessor-discovery side gap. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add an additional architecture/runtime runner, and is not
whole-goal completion evidence.
