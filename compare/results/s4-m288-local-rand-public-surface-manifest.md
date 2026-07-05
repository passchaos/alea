# S4-M288 Local Rust Public Surface Manifest

Date: 2026-07-06

## Purpose

S4-M262 through S4-M287 closed or audited a long run of local Rust `rand`
discovery names and trait-heavy public surfaces. This manifest records the
current scanned public surface from the local Rust checkout and the resolved
`rand_core` dependency, mapping each group to Alea evidence or an explicit
Zig-native exclusion. It is intended to prevent repeatedly rediscovering the
same Rust-only names as new product gaps.

## Scanned Sources

- `~/Work/rand/src/lib.rs`
- `~/Work/rand/src/rng.rs`
- `~/Work/rand/src/prelude.rs`
- `~/Work/rand/src/rngs/*.rs`
- `~/Work/rand/src/distr/*.rs`
- `~/Work/rand/src/distr/weighted/*.rs`
- `~/Work/rand/src/seq/*.rs`
- resolved `rand_core 0.10.1` under
  `~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src`

The scan focused on public declarations and re-exports visible in these files:
`pub mod`, `pub use`, `pub fn`, `pub struct`, `pub enum`, `pub trait`, and
`pub type` declarations.

## Root `rand` Surface

| Local Rust surface | Alea status |
| --- | --- |
| `rand_core` root re-export and `rand_core::{Rng, TryRng, SeedableRng, CryptoRng, TryCryptoRng}` | Audited in `s4-m286-rand-core-reexport-audit.md`; concrete raw/try/seeding/security workflows are covered, Rust trait/helper module is intentionally not copied. |
| `distr`, `rngs`, `seq`, `prelude` modules | Covered by Alea `distributions`, root `distr`, root `rngs`, `seq`, and root `prelude`; see S4-M277, S4-M280, S4-M282. |
| `make_rng` | Covered by root `makeRng(Engine, io)` with explicit engine type and `std.Io` entropy flow; see S4-M245. |
| `RngReader` | Covered by `Rng.RngReader`, `Rng.rngReader`, root `RngReader`, and root `rngReader`; see S4-M246 and S4-M278. |
| `random`, `random_iter`, `random_range`, `random_bool`, `random_ratio`, `fill` | Covered by explicit-IO root helpers and `Rng` facade/direct-source helpers; see S4-M259 and related `Rng` alias milestones. |
| `#[cfg(test)]` root helpers `rng`, `const_rng`, `step_rng`, and `StepRng` | Covered for local test/mock workflows by Alea `StepRng`, root `stepRng`, and root `constRng`; these Rust names are in the local checkout's test-only module and are not crate-root public API gaps. |
| `RngExt`, `Fill` | Audited as Rust extension traits in S4-M283; workflows are covered by concrete `Rng`/root APIs, fills, batches, and samplers. |

## RNG Namespace Surface

| Local Rust surface | Alea status |
| --- | --- |
| `SmallRng`, `StdRng` | Covered by root and `rngs` aliases; see S4-M254 and S4-M277. |
| `Xoshiro128PlusPlus`, `Xoshiro256PlusPlus` | Covered by root and `rngs` engines; see S4-M258 and S4-M277. |
| `ChaCha8Rng`, `ChaCha12Rng`, `ChaCha20Rng` | Covered by root and `rngs` engines/aliases; see S4-M256, S4-M257, and S4-M277. |
| `SysRng`, `SysError` | Covered by `SysRng`, `sysRng(io)`, `SysError`, and `rngs.SysRng` / `rngs.SysError`; see S4-M247, S4-M260, and S4-M277. |
| `ThreadRng`, `rng()` | Audited as hidden thread-local state in S4-M283 and S4-M277; Alea intentionally uses explicit `std.Io` entropy and explicit RNG ownership instead. |
| Test/mock `StepRng` helpers in Rust tests | Covered by Alea `StepRng`, root `stepRng`, and root `constRng`; see S4-M255. |

## Distribution Surface

| Local Rust surface | Alea status |
| --- | --- |
| `StandardUniform` | Covered by `distributions.StandardUniform`; see S4-M262. |
| `Open01`, `OpenClosed01` | Covered by scalar/vector strict interval helpers and reusable samplers; listed in `docs/api-reference.md` and `distribution-parity-matrix.md`. |
| `Uniform`, `UniformInt`, `UniformFloat`, `UniformUsize`, `UniformDuration`, `UniformChar`, `UniformError` | Covered by top-level `distributions.*` APIs and audited against the intermediate Rust namespace in S4-M285; see S4-M266, S4-M269, S4-M272, S4-M274, S4-M275, S4-M276. |
| `Bernoulli`, `BernoulliError` | Covered by `Bernoulli`, vector Bernoulli, aliases, and diagnostics; see S4-M225, S4-M227, S4-M228, S4-M263. |
| `Alphanumeric`, `Alphabetic`, `SampleString` | Covered by distribution namespace aliases, ASCII/Unicode charset samplers, and string sample/append APIs; see S4-M251, S4-M252, S4-M264. |
| `Choose`, `slice::Choose`, `slice::Empty` | Covered by `distributions.Choose`, `distributions.slice.Choose`, and `distributions.slice.Empty`; see S4-M268 and S4-M273. |
| `WeightedIndex`, `WeightedIndexIter`, `weighted::WeightedIndex`, `weighted::Error` | Covered by `WeightedIndex`, `AliasTable`, `distributions.weighted.WeightedIndex`, and weight iterator diagnostics/aliases; see S4-M192, S4-M265, S4-M271, S4-M281, S4-M284. |
| `Distribution`, `Iter`, `Map` | `Iter` / `Map` aliases and sample-iterator/map workflows are covered; Rust `Distribution` trait machinery is intentionally not copied; see S4-M248, S4-M250, S4-M270, S4-M283. |
| `SampleUniform`, `UniformSampler`, `SampleBorrow`, `SampleRange`, hidden `IntoFloat`, hidden `hidden_export` | Audited as Rust trait/internal support machinery in S4-M283 and S4-M285; concrete uniform workflows are covered, and the Rust-only helper path is intentionally not copied. |

## Sequence Surface

| Local Rust surface | Alea status |
| --- | --- |
| `WeightError` | Covered by `seq.WeightError` and root `WeightError`; see S4-M261. |
| `IndexedSamples`, `SliceChooseIter` | Covered by `seq.IndexedSamples(T)` and `seq.SliceChooseIter(T)` aliases; see S4-M279. |
| `IndexedRandom`, `IndexedMutRandom`, `SliceRandom`, `IteratorRandom` | Audited as Rust extension traits in S4-M283; workflows are covered by concrete `seq` and `Rng` functions. |
| `seq::index::{IndexVec, IndexVecIter, IndexVecIntoIter, sample, sample_weighted, sample_array}` | Covered by top-level `seq.IndexVec`, index sample helpers, weighted index helpers, and fixed-size array helpers; the intermediate namespace is audited in S4-M287. |

## `rand_core` Surface

| Local Rust surface | Alea status |
| --- | --- |
| `Rng`, `TryRng`, `RngCore`, `TryRngCore`, `CryptoRng`, `TryCryptoRng`, `SeedableRng`, `Infallible`, `UnwrapErr` | Audited in S4-M286; raw/try/seeding/security workflows are concrete Alea APIs, while traits/adaptors are Rust machinery. |
| `block::{Generator, BlockRng}` | Audited in S4-M286 as Rust implementation scaffolding; Alea engines expose explicit state/fill APIs instead. |
| `utils::{next_u64_via_u32, fill_bytes_via_next_word, next_word_via_fill, read_words, Word}` | Audited in S4-M286; relevant little-endian and byte-fill behavior is implemented and tested in concrete engines. |

## Result

No new unblocked local Rust public-surface gap is identified by the current
manifest. Remaining names are either already mapped to existing Alea APIs and
evidence files, are Rust trait/marker/internal implementation machinery, or are
intentionally not copied because the Rust path layout conflicts with existing
Zig-native API names.

Future local Rust public-surface work should start from this manifest and only
open a new milestone when it identifies a concrete missing Zig-native workflow
or a discovery alias that can be added without breaking existing Alea APIs.

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

This manifest does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
