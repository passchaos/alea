# Reproducibility Matrix

This document defines what `alea` treats as reproducible output. It is part of
the core RNG roadmap and is intended to prevent accidental compatibility breaks.

## Stable Outputs

These APIs are expected to produce the same outputs for the same inputs across
Zig 0.16 builds on supported 64-bit targets unless a versioned breaking change
is explicitly documented.

| Area | Stable contract |
| --- | --- |
| `Seed.fromBytes`, `Seed.fromString`, `Seed.mix`, `Seed.stream` | Same `u64` seed state for identical input bytes and stream indexes. |
| `SplitMix64.next` | Same `u64` sequence for identical seed. |
| `Alea4x64.next` / `fill` | Same byte stream for identical seed. |
| `Wyhash64.next` / `fill` | Same byte stream for identical seed. |
| `Xoshiro256.next`, `jump`, `longJump`, `split` | Same stream transitions for identical seed and operation order. |
| `Xoshiro256PlusPlus.next`, `jump` | Same stream transitions for identical seed and operation order. |
| `Pcg64.next` / `initTwo` | Same stream for identical seed and stream id. |
| `ChaCha.init`, `initFromU64`, `addEntropy`, `fill` | Same byte stream for identical seed/entropy operation order. |
| `Rng.uint`, `uintLessThan`, `uintAtMost`, integer ranges | Same output for fixed engine stream, integer type, and bounds on the same integer width. |
| `Rng.float`, `floatOpen`, `floatOpenClosed` | Same output for fixed engine stream and float type. |
| `Rng.value` for bools, ints, floats, enums, tuples, arrays | Same output when all nested sampled types are stable. |
| `Rng.valueIter` / `valueIterFrom` | `nextValue` is scalar `value` sampling; `fill` preserves repeated-`nextValue` stream shape for packed-fill-sensitive types (`bool`, `f32`, `u8`, sub-64-bit integers, and structured values) and may use stream-equivalent bulk fill only for `f64`, 64-bit integers, and matching vectors. |
| `Rng.sampleIter` / `sampleIterFrom` | `nextValue` follows the sampler's scalar `sample` / `sampleFrom` method; `fill` follows the sampler's bulk `fill` / `fillFrom` method when one exists, so high-volume iterator fills inherit each sampler's documented bulk stream policy. |
| `Rng.fill(u8, ...)` / `Rng.bytes` | Same byte stream for fixed engine stream. |
| `ascii.Charset` sampling | Same bytes for fixed engine stream and charset bytes. |
| `seq.sampleIndicesU32`, `sampleIndexVec` with `.u32` backing | Same sampled index sequence for fixed engine stream, length, and amount. |

## Checked-in Snapshot Evidence

The stable contracts above are backed by focused unit snapshots and stream-shape
tests so accidental compatibility drift is caught by `zig build test`.

| Evidence | Covered contract |
| --- | --- |
| `src/seed.zig`: `seed derivation and byte output have stable snapshots` | `Seed.fromBytes`, `Seed.fromString`, `Seed.mix`, `Seed.stream`, `Seed.next`, `Seed.bytes` |
| `src/root.zig`: `root deterministic constructors have stable snapshots` | Root deterministic constructors mirror engine initialization and `secureFromSeed` output |
| `src/engines/splitmix64.zig`: `splitmix64 next has stable snapshots` | `SplitMix64.next` |
| `src/engines/*`: engine `fill has stable byte snapshot` tests | `Alea4x64.fill`, `Wyhash64.fill`, `Xoshiro256.fill`, `Xoshiro256PlusPlus.fill`, `Pcg64.fill`, `ChaCha.fill` |
| `src/engines/xoshiro256.zig`: `xoshiro256 transitions have stable snapshots`; `src/engines/xoshiro256plusplus.zig`: `xoshiro256++ jump has stable snapshots`; `src/engines/pcg64.zig`: `pcg64 initTwo has stable snapshots` | Stable stream transitions for `split`, `jump`, `longJump`, and `initTwo` |
| `src/engines/chacha.zig`: `chacha addEntropy has stable byte snapshot` | `ChaCha.addEntropy` operation-order stability |
| `src/rng.zig`: `scalar sampling has stable snapshots`, `byte fill has stable snapshots`, `value and vector sampling have stable snapshots`, `duration range sampling has stable snapshots` | Scalar, byte, structured-value, vector, and duration sampling contracts |
| `src/rng.zig`: `value iterator fill preserves scalar fallback where bulk fill packs draws` | Iterator fill keeps repeated-`nextValue` stream shape for packed-fill-sensitive value types |
| `src/ascii.zig`: `ascii helpers have stable snapshots` | ASCII charset/string and Unicode scalar UTF-8 generation for a fixed stream |
| `src/seq.zig`: `portable index sampling has stable snapshots` | `sampleIndicesU32` and compact `.u32` `sampleIndexVec` output |
| `src/rng.zig`, `src/seq.zig`, `src/distributions.zig`, `src/ascii.zig`: `preserve direct stream shape` tests | Facade/direct-source helpers preserve stream shape for valid inputs |
| `src/rng.zig`, `src/seq.zig`, `src/distributions.zig`, `src/ascii.zig`: invalid checked/no-consume and zero-length tests | Invalid checked/error paths that can validate before drawing return before consuming randomness, including nested empty-enum `valueCheckedFrom` cases, empty/all-zero weighted iterator choices, length-mismatched `WeightedChoice.update` calls, invalid charset construction, zero-length ASCII/Unicode string allocation, and Unicode UTF-8 allocation length overflow. Single-pass streaming helpers may already have consumed randomness for earlier valid entries before a later invalid entry is discovered. |

## Versioned Stable Outputs

These APIs are deterministic but may change when algorithms are intentionally
upgraded. Any change must be documented in the comparison/coverage notes.

| Area | Reason |
| --- | --- |
| Non-uniform distributions and reusable distribution samplers | Algorithms may be improved for statistical quality, endpoint semantics, or speed, as happened with Poisson, binomial, and floating-point inclusive uniform samplers. |
| LogNormal transform mapping | Alternative exact-transform shapes such as f32 `expm1(x) + 1` may improve a narrow parameter range but change rounding/output mapping; any adoption must be documented as a deliberate versioned distribution change or exposed as an explicit opt-in. Current evidence and requirements are in `compare/results/lognormal-transform-notes.md`. |
| `Rng.fill` for non-`u8` integer, `f32`, and bool slices; `Rng.fillOpen` / `fillOpenClosed` float slices | Bulk packing and slice conversion policy may change to improve throughput; use scalar `valueIter`, `floatOpen`, or `floatOpenClosed` if per-element draw compatibility is required. Exact `(0, 1]` f64 endpoint-grid constraints are tracked in `compare/results/openclosed-endpoint-notes.md`. |
| `seq.sampleIndices` returning `[]usize` | `usize` width and compact conversion policy can vary by target. |
| `seq.sampleWeightedIndices` and weighted no-replacement helpers | Heap ordering ties and floating-point keys are deterministic for a target, but algorithm changes may alter output. |
| `AliasTable` construction | O(1) sampling contract is stable; exact table layout may change with algorithm improvements. |

## Not Stable

| Area | Reason |
| --- | --- |
| `Seed.secure`, `defaultSecure`, `fastSecure`, `reproducibleSecure`, `secure`, `secureBytes` | Source is system entropy. |
| Native benchmark numbers | Hardware, CPU flags, compiler, and system load dependent. |
| PractRand timing | Machine and build dependent; pass/fail/anomaly results are the relevant evidence. |

## Change Policy

- If a stable-output API changes, add a note to this file and the relevant
  comparison report before committing the implementation change.
- If an algorithm is upgraded for quality or performance, prefer adding a
  versioned note rather than preserving weaker output compatibility.
- If architecture-dependent behavior is unavoidable, prefer a compact explicit
  API such as `sampleIndicesU32` for portable snapshots.
