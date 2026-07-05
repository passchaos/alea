# S4-M283 Rust Trait Surface Audit

Date: 2026-07-06

## Purpose

After the S4-M262 through S4-M282 discovery-name work, the remaining prominent
local Rust `rand` public names are mostly trait machinery, marker traits, or
hidden thread-local RNG entry points. This audit records why they are not direct
Alea implementation gaps under the project mission's Zig-native API rule.

## Local Rust Surface Reviewed

Audited local `~/Work/rand/src` public names and references:

- root re-exports: `Rng`, `RngExt`, `Fill`, `SeedableRng`, `TryRng`,
  `CryptoRng`, `TryCryptoRng`;
- distribution traits: `Distribution`, `SampleString`, `SampleUniform`,
  `UniformSampler`, `SampleBorrow`, `SampleRange`, hidden `IntoFloat`;
- sequence traits: `IndexedRandom`, `IndexedMutRandom`, `SliceRandom`,
  `IteratorRandom`;
- hidden-state RNGs: `ThreadRng` / `rng()`;
- modules/namespaces already handled: `distr`, `rngs`, `prelude`,
  root `RngReader`, `seq` sampled iterator names, uniform backend names,
  weighted error names.

## Alea Position

Alea intentionally does not copy Rust traits or marker-trait machinery into Zig.
The equivalent workflows are provided through concrete modules, comptime
dispatch, explicit source parameters, and explicit ownership:

- Rust `Rng` / `RngExt` method workflows are covered by `Rng` facade methods,
  direct-source `Rng.*From` helpers, root explicit-I/O random helpers, and raw
  engine aliases.
- Rust `Fill` is covered by `Rng.fill`, `fillFrom`, `fillBytes`,
  `tryFillBytes`, value/sample fills, and reusable sampler `fillFrom` methods.
- Rust `SeedableRng` / `TryRng` construction and raw fallible methods are
  covered by engine `seedFromU64`, `fromSeed`, `fromSeedBytes`, `fromRng`,
  `tryFromRng`, `fork`, `tryFork`, `tryNext*`, and `tryFillBytes` aliases.
- Rust `CryptoRng` / `TryCryptoRng` are marker traits. Alea instead uses named
  secure-style engines and sources (`SecurePrng`, `StdRng`, `ChaCha*Rng`,
  `SysRng`) with explicit documentation of reproducibility and entropy
  contracts.
- Rust `Distribution`, `SampleUniform`, `UniformSampler`, `SampleBorrow`, and
  `SampleRange` are trait abstractions. Alea exposes concrete reusable samplers,
  `Rng.sample`, direct-source sampling, `tryFromRange` aliases, one-shot
  `sampleSingle` aliases, mapped samplers, sample iterators, and bulk fills.
- Rust `SampleString` is covered by ASCII `Charset` and `UnicodeCharset`
  `sampleString*` / `appendString*` APIs.
- Rust sequence traits are covered by `seq` functions and reusable `Choice` /
  `WeightedChoice` samplers, including Rust-discoverable function aliases,
  sampled iterator aliases, and no-replacement / weighted workflows.
- Rust `ThreadRng` / hidden `rng()` are intentionally not copied: Alea keeps
  entropy and RNG ownership explicit via `sysRng(io)`, `makeRng(Engine, io)`,
  and root explicit-I/O helpers.
- Rust hidden `IntoFloat` is an internal implementation detail for float
  conversions and not a user-facing Zig API gap.

## Result

No new unblocked core RNG implementation gap is identified from the remaining
local Rust public trait/marker/thread-local surface. Future work should only
reopen these names if there is a concrete Zig-native workflow gap, not merely
because a Rust trait name exists.

## Validation

This is documentation/evidence only. Relevant validation:

```sh
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This audit does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
