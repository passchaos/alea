# S4-M302 Surfacecheck Bernoulli Impl Coverage

Date: 2026-07-06

## Purpose

S4-M301 broadened `surfacecheck` to validate public methods inside Rust `impl`
blocks, but the local `rand` source-file list still did not include
`src/distr/bernoulli.rs`. That file is not a private helper: `rand::distr`
re-exports `Bernoulli` and `BernoulliError`, so methods such as
`Bernoulli::from_ratio` and `Bernoulli::p` are part of the local public surface.

## Change

`tools/surfacecheck.zig` now scans local `rand/src/distr/bernoulli.rs`, and the
S4-M288 local Rust public-surface manifest explicitly maps:

- `from_ratio` -> Alea `Bernoulli.fromRatio`;
- `p` -> Alea `Bernoulli.p()`.

The private local `rand::seq` helper modules `coin_flipper` and
`increasing_uniform` remain excluded from the scanned public source set because
they are private implementation modules and not re-exported public surface.

## Validation

Relevant validation:

```sh
zig fmt tools/surfacecheck.zig tools/roadmapcheck.zig
zig build surfacecheck
zig build roadmapcheck
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone strengthens local comparison tooling and manifest evidence. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add an additional architecture/runtime runner, and is not
whole-goal completion evidence.
