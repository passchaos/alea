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
| Deterministic point-mass helpers | Valid collapsed ranges, single-positive weighted-index/static weighted-sampler/weighted no-replacement/weighted-iterator choices, single-root/single-positive weighted trees, single-item choices, single-byte charsets, and degenerate scalar/vector/multivariate distribution parameter sets return or fill their single possible value without consuming randomness. |
| `Rng.value` for bools, ints, floats, enums, tuples, arrays | Same output when all nested sampled types are stable. |
| `Rng.valueIter` / `valueIterFrom` | `nextValue` is scalar `value` sampling; `fill` preserves repeated-`nextValue` stream shape for packed-fill-sensitive types (`bool`, `f32`, `u8`, sub-64-bit integers, and structured values) and may use stream-equivalent bulk fill only for `f64`, 64-bit integers, and matching vectors. |
| `Rng.sampleIter` / `sampleIterFrom` | `nextValue` follows the sampler's scalar `sample` / `sampleFrom` method; `fill` follows the sampler's bulk `fill` / `fillFrom` method when one exists, so high-volume iterator fills inherit each sampler's documented bulk stream policy. |
| `Rng.fill(u8, ...)` / `Rng.bytes` | Same byte stream for fixed engine stream. |
| `ascii.Charset` sampling | Same bytes for fixed engine stream and charset bytes. |
| `ascii.unicodeScalarFrom`, `unicodeUtf8Capacity`, `unicodeUtf8AllocFrom`, `unicodeUtf8IntoFrom` | Same Unicode scalars and UTF-8 bytes for fixed engine stream and requested scalar count; `unicodeUtf8Capacity(len)` is stable as checked `len * 4`. |
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
| `src/rng.zig`: `degenerate range helpers do not consume random stream`, `degenerate vector probability fills do not consume random stream`, `single-positive weighted index does not consume random stream`, `single-item choice helpers do not consume random stream`; `src/distributions.zig`: `single-positive alias table does not consume random stream`, `single-root/single-positive weighted trees, single-item choices do not consume random stream`; `src/seq.zig`: `single-item choice sampler does not consume random stream`, `single-positive weighted choice does not consume random stream`, `single-positive weighted no-replacement does not consume random stream`, `single-positive weighted iterator helpers do not consume random stream`; `src/ascii.zig`: `single-byte charset helpers do not consume random stream`; `src/distributions.zig`: `degenerate normal and log-normal helpers do not consume random stream`, `degenerate gamma helpers do not consume random stream`, `degenerate erlang helpers do not consume random stream`, `degenerate log-logistic helpers do not consume random stream`, `degenerate frechet helpers do not consume random stream`, `degenerate pareto helpers do not consume random stream`, `degenerate skew-normal helpers do not consume random stream`, `degenerate half-normal helpers do not consume random stream`, `degenerate rayleigh helpers do not consume random stream`, `degenerate weibull helpers do not consume random stream`, `degenerate maxwell helpers do not consume random stream`, `degenerate laplace and logistic helpers do not consume random stream`, `degenerate cauchy and gumbel helpers do not consume random stream`, `degenerate triangular helpers do not consume random stream`, `degenerate arcsine helpers do not consume random stream`, `degenerate power-function helpers do not consume random stream`, `degenerate uniform distribution helpers do not consume random stream`, `degenerate discrete distribution helpers do not consume random stream`, `degenerate multivariate samplers do not consume random stream` | Point-mass scalar/vector range and vector probability fill, choice/weighted-index/static weighted-choice/weighted-tree/weighted no-replacement/weighted iterator, single-byte charset, Normal/LogNormal/Gamma/Erlang/LogLogistic/Frechet/Pareto/SkewNormal/HalfNormal/Rayleigh/Maxwell/Laplace/Logistic/Cauchy/Gumbel/Weibull, Triangular/Arcsine/PowerFunction, uniform, Bernoulli/discrete, and one-category/zero-trial/single-positive Multinomial and one-dimensional Dirichlet helpers return/fill deterministic values without consuming randomness |
| `src/rng.zig`: `value iterator fill preserves scalar fallback where bulk fill packs draws` | Iterator fill keeps repeated-`nextValue` stream shape for packed-fill-sensitive value types |
| `src/ascii.zig`: `ascii helpers have stable snapshots` | ASCII charset/string and Unicode scalar UTF-8 generation for a fixed stream |
| `src/seq.zig`: `portable index sampling has stable snapshots` | `sampleIndicesU32` and compact `.u32` `sampleIndexVec` output |
| `src/rng.zig`, `src/seq.zig`, `src/distributions.zig`, `src/ascii.zig`: `preserve direct stream shape` tests | Facade/direct-source helpers preserve stream shape for valid inputs |
| `src/distributions.zig`: `log-normal approximation has stable snapshots` | Current `LogNormalApproxF32` / `logNormalApproxF32*` opt-in output mapping for the bounded f32 approximation |
| `src/rng.zig`, `src/seq.zig`, `src/distributions.zig`, `src/ascii.zig`: invalid checked/no-consume, zero-length, allocation-failure, and failed-update tests | Invalid checked/error paths that can validate before drawing return before consuming randomness, including facade/direct nested empty-enum `valueChecked` / `valueCheckedFrom` cases, zero-count checked sequence helpers, zero-length fixed index arrays, partial shuffles, reusable choice fills, alias table fills, empty `chooseIter` helpers, empty/invalid optional streaming iterator choices, and empty streaming choice facades, zero-count checked sample-without-replacement and iterator sampling, sample-without-replacement allocation/ownership conversion, choose-multiple, checked iterator sampling, facade/direct checked weighted sequence invalid counts, checked weighted index/sample allocation failure, and invalid weighted-index/slice-weight inputs (negative weights, non-finite weights, or overflowing cumulative totals), exact-capacity index/iterator sampler ownership conversion, in-place index output allocation failure, rejection index set allocation failure, empty/all-zero weighted iterator choices, facade/direct checked `Rng` scalar/vector fills, facade/direct checked distribution helpers and fills, weighted tree fills, and zero-length multivariate checked batch outputs, length-mismatched and allocation-failed `WeightedChoice.update` / `AliasTable.update` calls that preserve the old table, invalid charset construction and facade/direct checked charset helpers, zero-length ASCII/Unicode string allocation, too-small caller-owned Unicode UTF-8 output buffers, invalid multivariate checked output lengths, initial sequence/string/multivariate allocation failure, and Unicode UTF-8 allocation/capacity length overflow. Remaining variable-length streaming helpers such as short `sampleIteratorFrom`, partial weighted-iterator samples, and allocation-returning Unicode UTF-8 strings may still need to finalize storage after reading/drawing because the result length is only known after inspecting the stream. |

## Versioned Stable Outputs

These APIs are deterministic but may change when algorithms are intentionally
upgraded. Any change must be documented in the comparison/coverage notes.

| Area | Reason |
| --- | --- |
| Non-uniform distributions and reusable distribution samplers | Algorithms may be improved for statistical quality, endpoint semantics, or speed, as happened with Poisson, binomial, and floating-point inclusive uniform samplers. |
| LogNormal transform mapping | Exact `LogNormal(T)` uses `@exp`, while the opt-in bounded `LogNormalApproxF32` / `logNormalApproxF32*` mapping uses `expm1(x) + 1` and has checked snapshot evidence. Future transform changes may alter output mapping only as a deliberate versioned distribution change or an explicit opt-in. Current evidence and requirements are in `compare/results/lognormal-transform-notes.md`. |
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
