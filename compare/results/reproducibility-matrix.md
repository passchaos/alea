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
| `Rng.fill(u8, ...)` / `Rng.bytes` | Same byte stream for fixed engine stream. |
| `ascii.Charset` sampling | Same bytes for fixed engine stream and charset bytes. |
| `seq.sampleIndicesU32`, `sampleIndexVec` with `.u32` backing | Same sampled index sequence for fixed engine stream, length, and amount. |

## Versioned Stable Outputs

These APIs are deterministic but may change when algorithms are intentionally
upgraded. Any change must be documented in the comparison/coverage notes.

| Area | Reason |
| --- | --- |
| Non-uniform distributions and reusable distribution samplers | Algorithms may be improved for statistical quality, endpoint semantics, or speed, as happened with Poisson, binomial, and floating-point inclusive uniform samplers. |
| `Rng.fill` for non-`u8` integer, `f32`, and bool slices; `Rng.fillOpen` / `fillOpenClosed` float slices | Bulk packing and slice conversion policy may change to improve throughput; use scalar `valueIter`, `floatOpen`, or `floatOpenClosed` if per-element draw compatibility is required. |
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
