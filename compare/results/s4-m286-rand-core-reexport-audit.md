# S4-M286 `rand_core` Re-Export Surface Audit

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes the low-level `rand_core` crate at the
root:

- `~/Work/rand/src/lib.rs` contains `pub use rand_core;`.
- The same file re-exports `rand_core::{CryptoRng, Rng, SeedableRng,
  TryCryptoRng, TryRng}`.
- `~/Work/rand/Cargo.lock` resolves `rand_core` to `0.10.1`; the local registry
  source at
  `~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src`
  exposes:
  - core traits and aliases: `Rng`, `TryRng`, `RngCore`, `TryRngCore`,
    `CryptoRng`, `TryCryptoRng`, `SeedableRng`, `Infallible`, `UnwrapErr`;
  - block-generation helpers: `block::Generator`, `block::BlockRng`;
  - implementation utilities: `utils::next_u64_via_u32`,
    `utils::fill_bytes_via_next_word`, `utils::next_word_via_fill`, and
    `utils::read_words`.

## Alea Position

Alea intentionally does not re-export or emulate a `rand_core` crate/module.
That Rust surface is primarily trait and implementation-helper machinery for
Rust's ecosystem and is not a direct Zig-native product gap.

The relevant user workflows are already covered by concrete Alea APIs:

- raw infallible/fallible RNG operations are covered by `Rng.nextU64`,
  `nextU32`, `fillBytes`, `tryNextU64`, `tryNextU32`, `tryFillBytes`, and the
  matching direct-source `*From` helpers;
- exported engines expose Rust-discoverable raw aliases and fallible
  `try*` aliases directly, without requiring trait implementation;
- seeding workflows from `SeedableRng` are covered by `seedFromU64`,
  `fromSeed`, `fromSeedBytes`, `fromRng`, `tryFromRng`, `fork`, and `tryFork`;
- secure-style markers are expressed through named engines/sources
  (`SecurePrng`, `StdRng`, `ChaCha*Rng`, `SysRng`) and documented contracts,
  not marker traits;
- byte-fill and little-endian word conversion workflows are implemented inside
  engines and tested where stream shape matters, including local Rust
  `StepRng(255, 1)` byte-shape evidence and `Xoshiro128PlusPlus` little-endian
  `nextU64`/fill behavior;
- random-byte reader workflows are covered by `Rng.RngReader(Source)`,
  `Rng.rngReader`, and root `RngReader` / `rngReader` aliases;
- fallible-to-infallible wrapper patterns such as Rust `UnwrapErr` are naturally
  represented by Zig error unions and explicit `try`/catch call sites instead
  of a reusable panic adapter;
- `BlockRng` / `Generator` are Rust helper abstractions for implementing PRNG
  traits. Alea engines keep explicit state/fill implementations and do not need
  a public trait-like block generator just to mirror Rust's implementation
  scaffolding.

## Result

No new unblocked core RNG implementation gap is identified from the root
`rand_core` re-export or its low-level helper modules. The remaining names are
either already covered by concrete Alea APIs, Rust-only trait/marker/adaptor
machinery, or implementation scaffolding that should not be exposed unless a
future Zig-native engine-extension workflow requires it.

Future work should reopen this area only for a concrete Alea extension problem,
and if trait-like abstraction is genuinely needed, evaluate the local
`~/project-z/zigraft` library before inventing custom trait machinery.

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
