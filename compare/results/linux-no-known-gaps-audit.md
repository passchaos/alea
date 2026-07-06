# Linux No-Known-Gaps Audit

This audit records the current Linux-first evidence for Stage 4 of
`core-rand-coverage.md`.

It is not a claim that the long-term product goal is permanently complete. It
means that, on the current x86_64 Linux environment and against the locally
available Rust evidence listed below, there are no known remaining core RNG
functionality gaps in Alea's current local Linux parity stage. S4-M4 performance
follow-up is closed for the current bar: LogNormal performance is covered by
explicit opt-ins while exact defaults remain a stable-output tradeoff. The S4-M5 policy bar is closed by `s4-m5-approximation-policy.md`, the S4-M6 hardening bar is closed by `2026-07-04-s4-m6-profilecheck.md`, the
S4-M7 tail bar is closed by `2026-07-04-s4-m7-profiletailcheck.md`, the S4-M8
stress bar is closed by `2026-07-04-s4-m8-profilestresscheck.md`, and the S4-M9 long-sweep bar is closed by `2026-07-04-s4-m9-profilelongcheck.md`, and
S4-M10 musl execution is closed by `2026-07-04-s4-m10-profilelong-musl.md`; the
active S4-M11 watch item is blocked on an exact/default-compatible dense SIMD
winner, a newly available architecture/runtime runner, or a newly found local
Rust core gap.

## Scope

Local Rust evidence:

- `~/Work/rand`, used by `compare/rand_bench`
- cached `rand_distr 0.6.0` under `~/.cargo/registry/src`
- local `rand_distr` weighted APIs: `WeightedAliasIndex` and `WeightedTreeIndex`

Local Alea evidence:

- `src/distributions.zig`
- `src/rng.zig`
- `src/seq.zig`
- `src/ascii.zig`
- `tools/distcheck.zig`
- `bench/throughput.zig`
- `compare/rand_bench/src/main.rs`
- `docs/api-reference.md`
- `compare/results/distribution-parity-matrix.md`
- `compare/results/performance-triage.md`
- `compare/results/simd-distribution-kernel-notes.md`
- `compare/results/lognormal-transform-notes.md`
- `compare/results/lognormal-codegen-audit.md`
- `compare/results/s4-m4-remaining-gaps.md`
- `compare/results/rust-benchmark-coverage-audit.md`
- `compare/results/s4-m5-rand-simd-audit.md`
- `compare/results/s4-m5-approximation-policy.md`
- `compare/results/2026-07-04-s4-m6-profilecheck.md`
- `compare/results/2026-07-04-s4-m7-profiletailcheck.md`
- `compare/results/2026-07-04-s4-m8-profilestresscheck.md`
- `compare/results/2026-07-04-s4-m9-profilelongcheck.md`
- `compare/results/2026-07-04-s4-m10-profilelong-musl.md`
- `compare/results/s4-m11-blocker-audit.md`
- `compare/results/s4-m12-vector-profile-example.md`
- `compare/results/s4-m13-lognormal-profile-example.md`
- `compare/results/s4-m14-native-f32-profile-example.md`
- `compare/results/s4-m15-examples-validation.md`
- `compare/results/s4-m16-weighted-sampling-example.md`
- `compare/results/s4-m17-multivariate-sampling-example.md`
- `compare/results/s4-m18-sequence-sampling-example.md`
- `compare/results/s4-m19-string-generation-example.md`
- `compare/results/s4-m20-unit-geometry-example.md`
- `compare/results/s4-m21-distribution-diagnostics-example.md`
- `compare/results/s4-m22-reproducible-streams-example.md`
- `compare/results/s4-m23-range-sampling-example.md`
- `compare/results/s4-m24-discrete-distributions-example.md`
- `compare/results/s4-m25-continuous-distributions-example.md`
- `compare/results/s4-m26-advanced-continuous-distributions-example.md`
- `compare/results/s4-m27-rank-distributions-example.md`
- `compare/results/s4-m28-examples-catalog.md`
- `compare/results/s4-m29-examplecheck.md`
- `compare/results/s4-m30-toolingcheck.md`
- `compare/results/s4-m31-readme-doccheck.md`
- `compare/results/s4-m32-roadmapcheck.md`
- `compare/results/s4-m33-choose-array.md`
- `compare/results/s4-m34-choose-weighted.md`
- `compare/results/s4-m35-reservoir-into.md`
- `compare/results/s4-m36-iterator-into.md`
- `compare/results/s4-m37-weighted-array.md`
- `compare/results/s4-m38-weighted-index-array.md`
- `compare/results/s4-m39-weighted-iterator-array.md`
- `compare/results/s4-m40-iterator-array.md`
- `compare/results/s4-m41-weighted-indices-into.md`
- `compare/results/s4-m42-weighted-into.md`
- `compare/results/s4-m43-weighted-iterator-into.md`
- `compare/results/s4-m44-indices-into.md`
- `compare/results/s4-m45-choose-multiple-into.md`
- `compare/results/s4-m46-partial-shuffle-split.md`
- `compare/results/s4-m47-u32-indices-into.md`
- `compare/results/s4-m48-caller-owned-example.md`
- `compare/results/s4-m49-indexvec-item-iterators.md`
- `compare/results/s4-m50-indexvec-into.md`
- `compare/results/s4-m51-indexvec-mutptrs.md`
- `compare/results/s4-m52-choose-multiple-ptrs-into.md`
- `compare/results/s4-m53-choose-ptr-array.md`
- `compare/results/s4-m54-weighted-ptr-array.md`
- `compare/results/s4-m55-weighted-ptrs-into.md`
- `compare/results/s4-m56-choose-const-ptr.md`
- `compare/results/s4-m57-choose-weighted-const-ptr.md`
- `compare/results/s4-m58-choose-multiple-ptrs.md`
- `compare/results/s4-m59-weighted-ptrs.md`
- `compare/results/s4-m60-reservoir-ptrs.md`
- `compare/results/s4-m61-reservoir-ptrs-into.md`
- `compare/results/s4-m62-caller-owned-pointer-example.md`
- `compare/results/s4-m63-choose-index.md`
- `compare/results/s4-m64-generic-weighted-index.md`
- `compare/results/s4-m65-example-output-check.md`
- `compare/results/s4-m66-s4-m11-blockercheck.md`
- `compare/results/s4-m67-readme-choice-discovery.md`
- `compare/results/s4-m68-doccheck-dependency-check.md`
- `compare/results/s4-m69-weighted-indexvec.md`
- `compare/results/s4-m70-weighted-u32-indices-into.md`
- `compare/results/s4-m71-weighted-u32-index-array.md`
- `compare/results/s4-m72-weighted-u32-indices.md`
- `compare/results/s4-m73-u32-index-array.md`
- `compare/results/s4-m74-indexvec-u32-export.md`
- `compare/results/s4-m75-indexvec-owned-mapping.md`
- `compare/results/s4-m76-choose-index-u32.md`
- `compare/results/s4-m77-generic-weighted-index-u32.md`
- `compare/results/s4-m78-rng-weighted-index-u32.md`
- `compare/results/s4-m79-weighted-choice-index-fills.md`
- `compare/results/s4-m80-choice-index-fills.md`
- `compare/results/s4-m81-choice-sample-index.md`
- `compare/results/s4-m82-choice-owned-indices.md`
- `compare/results/s4-m83-weighted-choice-owned-indices.md`
- `compare/results/s4-m84-choice-owned-values-ptrs.md`
- `compare/results/s4-m85-rng-owned-batches.md`
- `compare/results/s4-m86-rng-owned-bytes.md`
- `compare/results/s4-m87-rng-owned-ranges.md`
- `compare/results/s4-m88-rng-owned-strict-intervals.md`
- `compare/results/s4-m89-rng-owned-probabilities.md`
- `compare/results/s4-m90-rng-owned-normal-exponential.md`
- `compare/results/s4-m91-rng-owned-durations.md`
- `compare/results/s4-m92-rng-owned-vector-ranges.md`
- `compare/results/s4-m93-rng-owned-vector-strict-intervals.md`
- `compare/results/s4-m94-rng-owned-vector-probabilities.md`
- `compare/results/s4-m95-rng-owned-vector-normal-exponential.md`
- `compare/results/s4-m96-rng-owned-standard-normal-exponential.md`
- `compare/results/s4-m97-rng-owned-unicode-scalars.md`
- `compare/results/s4-m98-unicode-scalar-ranges.md`
- `compare/results/s4-m99-rng-owned-bounded-uint.md`
- `compare/results/s4-m100-rng-owned-inclusive-ranges.md`
- `compare/results/s4-m101-rng-owned-vector-inclusive-ranges.md`
- `compare/results/s4-m102-rng-owned-index-choice-batches.md`
- `compare/results/s4-m103-rng-owned-value-choice-batches.md`
- `compare/results/s4-m104-rng-owned-const-ptr-choice-batches.md`
- `compare/results/s4-m105-rng-owned-mut-ptr-choice-batches.md`
- `compare/results/s4-m106-rng-owned-weighted-index-batches.md`
- `compare/results/s4-m107-rng-owned-weighted-u32-index-batches.md`
- `compare/results/s4-m108-rng-owned-weighted-value-batches.md`
- `compare/results/s4-m109-rng-owned-weighted-const-ptr-batches.md`
- `compare/results/s4-m110-rng-owned-weighted-mut-ptr-batches.md`
- `compare/results/s4-m111-generic-weighted-index-batches.md`
- `compare/results/s4-m112-generic-weighted-value-batches.md`
- `compare/results/s4-m113-generic-weighted-const-ptr-batches.md`
- `compare/results/s4-m114-generic-weighted-mut-ptr-batches.md`
- `compare/results/s4-m115-accessor-weighted-choices.md`
- `compare/results/s4-m116-accessor-weighted-samples.md`
- `compare/results/s4-m117-accessor-weighted-into.md`
- `compare/results/s4-m118-accessor-weighted-index-samples.md`
- `compare/results/s4-m119-accessor-weighted-index-arrays.md`
- `compare/results/s4-m120-accessor-weighted-item-arrays.md`
- `compare/results/s4-m121-weightedchoice-accessor-init.md`
- `compare/results/s4-m122-stable-iterator-choice.md`
- `compare/results/s4-m123-iterator-sample-fill.md`
- `compare/results/s4-m124-slice-sample-aliases.md`
- `compare/results/s4-m125-index-weighted-samples.md`
- `compare/results/s4-m126-index-weighted-into.md`
- `compare/results/s4-m127-index-weighted-arrays.md`
- `compare/results/s4-m128-slice-sample-array-aliases.md`
- `compare/results/s4-m129-seq-shuffle-aliases.md`
- `compare/results/s4-m130-tail-partial-shuffle.md`
- `compare/results/s4-m131-seq-choice-aliases.md`
- `compare/results/s4-m132-seq-choice-fills.md`
- `compare/results/s4-m133-seq-owned-choice-batches.md`
- `compare/results/s4-m134-seq-index-choice-aliases.md`
- `compare/results/s4-m135-accessor-weighted-choice-fills.md`
- `compare/results/s4-m136-accessor-weighted-choice-batches.md`
- `compare/results/s4-m137-accessor-weighted-index-choice.md`
- `compare/results/s4-m138-accessor-weighted-index-fills.md`
- `compare/results/s4-m139-accessor-weighted-index-batches.md`
- `compare/results/s4-m140-index-weighted-index-choice.md`
- `compare/results/s4-m141-index-weighted-index-fills.md`
- `compare/results/s4-m142-index-weighted-index-batches.md`
- `compare/results/s4-m143-index-weighted-item-choices.md`
- `compare/results/s4-m144-index-weighted-item-choice-fills.md`
- `compare/results/s4-m145-index-weighted-item-choice-batches.md`
- `compare/results/s4-m146-weightedchoice-index-accessor-init.md`
- `compare/results/s4-m147-weighted-tree-index-accessors.md`
- `compare/results/s4-m148-weighted-tree-item-accessors.md`
- `compare/results/s4-m149-weighted-tree-u32-output.md`
- `compare/results/s4-m150-weighted-tree-owned-indices.md`
- `compare/results/s4-m151-weighted-tree-index-aliases.md`
- `compare/results/s4-m152-weighted-tree-index-iterators.md`
- `compare/results/s4-m153-aliastable-u32-output.md`
- `compare/results/s4-m154-aliastable-owned-indices.md`
- `compare/results/s4-m155-aliastable-index-aliases.md`
- `compare/results/s4-m156-aliastable-index-iterators.md`
- `compare/results/s4-m157-aliastable-index-accessors.md`
- `compare/results/s4-m158-aliastable-item-accessors.md`
- `compare/results/s4-m159-aliastable-index-arrays.md`
- `compare/results/s4-m160-weighted-tree-index-arrays.md`
- `compare/results/s4-m161-weightedchoice-index-arrays.md`
- `compare/results/s4-m162-choice-index-arrays.md`
- `compare/results/s4-m163-choice-value-ptr-arrays.md`
- `compare/results/s4-m164-weightedchoice-value-ptr-arrays.md`
- `compare/results/s4-m165-index-choice-arrays.md`
- `compare/results/s4-m166-rng-choice-arrays.md`
- `compare/results/s4-m167-rng-weighted-choice-arrays.md`
- `compare/results/s4-m168-seq-generic-weighted-choice-arrays.md`
- `compare/results/s4-m169-accessor-weighted-choice-arrays.md`
- `compare/results/s4-m170-index-weighted-choice-arrays.md`
- `compare/results/s4-m171-seq-repeated-choice-arrays.md`
- `compare/results/s4-m172-choice-index-iterators.md`
- `compare/results/s4-m173-indexvec-consuming-owned.md`
- `compare/results/s4-m174-indexvec-equality.md`
- `compare/results/s4-m175-indexvec-owned-constructors.md`
- `compare/results/s4-m176-indexvec-clone.md`
- `compare/results/s4-m177-indexvec-consuming-iterator.md`
- `compare/results/s4-m178-weighted-choice-iterators.md`
- `compare/results/s4-m179-accessor-weighted-choice-iterators.md`
- `compare/results/s4-m180-index-weighted-choice-iterators.md`
- `compare/results/s4-m181-sampled-ptr-iterators.md`
- `compare/results/s4-m182-sampled-value-iterators.md`
- `compare/results/s4-m183-sampled-mut-ptr-iterators.md`
- `compare/results/s4-m184-choice-numchoices.md`
- `compare/results/s4-m185-sampled-iterator-fill.md`
- `compare/results/s4-m186-iterator-len-aliases.md`
- `compare/results/s4-m187-iterator-size-hints.md`
- `compare/results/s4-m188-indexvec-iterator-fill.md`
- `compare/results/s4-m189-indexvec-index-alias.md`
- `compare/results/s4-m190-indexvec-get.md`
- `compare/results/s4-m191-weighted-sampler-weight.md`
- `compare/results/s4-m192-weight-iterators.md`
- `compare/results/s4-m193-weighted-sampler-probability.md`
- `compare/results/s4-m194-probability-iterators.md`
- `compare/results/s4-m195-choice-probability.md`
- `compare/results/s4-m196-choice-probability-iterator.md`
- `compare/results/s4-m197-charset-probability.md`
- `compare/results/s4-m198-charset-probability-iterator.md`
- `compare/results/s4-m199-choice-get.md`
- `compare/results/s4-m200-charset-get.md`
- `compare/results/s4-m201-diagnostic-iterator-sizehints.md`
- `compare/results/s4-m202-charset-numchoices.md`
- `compare/results/s4-m203-choice-item-alias.md`
- `compare/results/s4-m204-charset-item-alias.md`
- `compare/results/s4-m205-tree-weight.md`
- `compare/results/s4-m206-tree-probability.md`
- `compare/results/s4-m207-tree-weight-iterators.md`
- `compare/results/s4-m208-tree-probability-iterators.md`
- `compare/results/s4-m209-aliastable-numchoices.md`
- `compare/results/s4-m226-uniform-new-alias.md`
- `compare/results/s4-m227-bernoulli-fromratio-alias.md`
- `compare/results/s4-m228-bernoulli-p-alias.md`
- `compare/results/s4-m229-uniform-samplesingle-alias.md`
- `compare/results/s4-m230-rng-random-bool-ratio-alias.md`
- `compare/results/s4-m231-rng-random-range-alias.md`
- `compare/results/s4-m232-rng-sample-alias.md`
- `compare/results/s4-m233-rng-random-value-alias.md`
- `compare/results/s4-m234-rng-raw-aliases.md`
- `compare/results/s4-m235-engine-raw-aliases.md`
- `compare/results/s4-m236-engine-seedfromu64-aliases.md`
- `compare/results/s4-m237-engine-fromseed-aliases.md`
- `compare/results/s4-m238-engine-fromrng-fork-aliases.md`
- `compare/results/s4-m239-full-state-fromrng.md`
- `compare/results/s4-m240-engine-fromseedbytes-aliases.md`
- `compare/results/s4-m241-engine-tryfromrng-aliases.md`
- `compare/results/s4-m242-engine-tryfork-aliases.md`
- `compare/results/s4-m243-try-raw-rng-aliases.md`
- `compare/results/s4-m244-rng-try-raw-from-aliases.md`
- `compare/results/s4-m245-root-makerng.md`
- `compare/results/s4-m246-rng-reader.md`
- `compare/results/s4-m247-sysrng.md`
- `compare/results/s4-m248-mapped-sampler.md`
- `compare/results/s4-m249-unbounded-iterator-sizehint.md`
- `compare/results/s4-m250-distribution-sampleiter.md`
- `compare/results/s4-m251-samplestring-aliases.md`
- `compare/results/s4-m252-unicode-charset.md`
- `compare/results/s4-m253-hinted-iterator-choice.md`
- `compare/results/s4-m254-stdrng-smallrng-aliases.md`
- `compare/results/s4-m255-step-rng.md`
- `compare/results/s4-m256-chacha12rng-alias.md`
- `compare/results/s4-m257-chacha8-chacha20-rngs.md`
- `compare/results/s4-m258-xoshiro128plusplus.md`
- `compare/results/s4-m259-root-random-helpers.md`
- `compare/results/s4-m260-syserror-alias.md`
- `compare/results/s4-m261-weighterror-alias.md`
- `compare/results/2026-07-03-repro-wasm32-wasi-node.md`

Out of scope for this Linux-first audit:

- Rust ecosystem mechanisms that are not core RNG functionality in Zig, such as
  Rust traits, serde integration, and crate feature matrices
- cross-platform reproducibility beyond the documented x86_64 Linux evidence
- broader platform claims beyond the local Linux runner
- claims about future `rand` / `rand_distr` releases that are not locally
  available in this environment

## Rust `rand` Default-Crate Surface

| Rust area | Alea status | Evidence |
| --- | --- | --- |
| integer, float, bool, raw draws including Rust-discoverable `nextU64` / `nextU32` / `fillBytes` aliases, range including Rust-discoverable `randomRange` aliases, reusable Uniform with Rust-discoverable scalar/vector `new` aliases, Rust-discoverable `sampleSingle` aliases, Rust-discoverable `Rng.sample`, Rust-discoverable `randomValue`, owned bounded-uint, owned scalar/vector half-open and inclusive range, scalar/vector strict-interval, scalar/vector probability including Rust-discoverable `randomBool` / `randomRatio`, scalar/vector standard-or-parameterized normal/exponential, and duration batches, ratio/chance, caller-owned and allocation-returning bytes | Covered | `Rng`, `Rng.nextU64`, `Rng.nextU32`, `Rng.fillBytes`, `Uniform.new`, `Uniform.newInclusive`, `sampleSingle`, `sampleSingleInclusive`, `VectorUniform.new`, `VectorUniform.newInclusive`, `Rng.sample`, `Rng.randomValue`, `Rng.randomValueChecked`, `Rng.sampleIter`, `Rng.sampleBatch`, `Rng.uintLessThanBatch`, `Rng.uintAtMostBatch`, `Rng.randomRange`, `Rng.randomRangeAtMost`, `Rng.rangeBatch`, `Rng.rangeAtMostBatch`, `Rng.vectorRangeBatch`, `Rng.vectorRangeAtMostBatch`, `Rng.openBatch`, `Rng.openClosedBatch`, `Rng.vectorOpenBatch`, `Rng.vectorOpenClosedBatch`, `Rng.randomBool`, `Rng.randomRatio`, `Rng.chanceBatch`, `Rng.ratioBatch`, `Rng.vectorChanceBatch`, `Rng.vectorRatioBatch`, `Rng.standardNormalBatch`, `Rng.normalBatch`, `Rng.standardExponentialBatch`, `Rng.exponentialBatch`, `Rng.vectorStandardNormalBatch`, `Rng.vectorNormalBatch`, `Rng.vectorStandardExponentialBatch`, `Rng.vectorExponentialBatch`, `Rng.bytesAlloc`, unit tests, Zig/Rust benchmark rows |
| arrays, tuples, enums | Covered | `Rng.value(T)`, `Rng.randomValue(T)`, `Rng.valueBatch(T)`, and checked empty-enum tests |
| Unicode scalar / char-like sampling | Covered in Zig form | `Rng.unicodeScalar`, `Rng.unicodeScalarRangeLessThan`, `Rng.unicodeScalarRangeAtMost`, `Rng.fillUnicodeScalar`, `Rng.fillUnicodeScalarRangeLessThan`, `Rng.fillUnicodeScalarRangeAtMost`, `Rng.unicodeScalarBatch`, `Rng.unicodeScalarRangeLessThanBatch`, `Rng.unicodeScalarRangeAtMostBatch`, `ascii.UnicodeCharset`, `ascii.unicodeUtf8Alloc`, `ascii.unicodeUtf8Into` |
| durations | Covered in Zig form | `durationRangeLessThan`, `durationRangeAtMost`, and owned duration range batches |
| strings / alphanumeric | Covered | `ascii` module, `Charset.constantIndex`, `UnicodeCharset`, Rust alphanumeric benchmark row |
| choose, shuffle, sample indices, fixed-size slice samples, reservoir fills | Covered | `Rng.chooseIndex`, `Rng.chooseIndexArray`, `Rng.chooseIndexBatch`, `Rng.chooseIndexU32`, `Rng.chooseIndexArrayU32`, `Rng.chooseIndexU32Batch`, `Rng.choose`, `Rng.chooseValueArray`, `Rng.chooseBatch`, `Rng.chooseConstPtr`, `Rng.chooseConstPtrArray`, `Rng.chooseConstPtrBatch`, `Rng.choosePtr`, `Rng.choosePtrArray`, `Rng.choosePtrBatch`, `seq.chooseIndex`, `seq.chooseIndexArray`, `seq.fillChooseIndex`, `seq.chooseIndexBatch`, `seq.chooseIndexU32`, `seq.chooseIndexArrayU32`, `seq.fillChooseIndexU32`, `seq.chooseIndexU32Batch`, `seq.choose`, `seq.chooseConstPtr`, `seq.choosePtr`, `seq.chooseRepeatedValueArray`, `seq.chooseRepeatedConstPtrArray`, `seq.chooseRepeatedPtrArray`, `seq.fillChoose`, `seq.fillChooseConstPtr`, `seq.fillChoosePtr`, `seq.chooseBatch`, `seq.chooseConstPtrBatch`, `seq.choosePtrBatch`, `seq` module, `seq.shuffle`, `seq.shuffleFrom`, `sampleArrayU32`, `chooseArray`, `choosePtrArray`, `chooseMultiple`, `chooseMultiplePtrs`, `chooseMultipleInto`, `chooseMultiplePtrsInto`, `seq.sampleItems`, `seq.sampleItemsIter`, `seq.sampleItemsInto`, `seq.sampleItemsArray`, `seq.samplePtrArray`, `seq.sampleMutPtrArray`, `seq.samplePtrs`, `seq.samplePtrsIter`, `seq.samplePtrsInto`, `seq.sampleMutPtrs`, `seq.sampleMutPtrsIter`, `seq.sampleMutPtrsInto`, `seq.chooseIteratorHinted`, `seq.chooseIteratorStable`, `seq.sampleIteratorFill`, `Choice.new`, `Choice.newChecked`, `Choice.numChoices`, `Choice.constantIndex`, `Choice.item`, `Choice.get`, `Choice.ProbabilityIterator.sizeHint`, `Choice.sampleIndex`, `Choice.fill`, `Choice.fillValues`, `Choice.ptrs`, `Choice.values`, `Choice.valueArray`, `Choice.ptrArray`, `Choice.fillIndices`, `Choice.indices`, `Choice.indexArray`, `Choice.indexArrayU32`, `Choice.indexIter`, `Choice.indexIterU32`, `reservoirSample`, `reservoirSamplePtrs`, `reservoirSampleInto`, `reservoirSamplePtrsInto`, `IndexVec` owned-backing adoption, representation-preserving deep clone, Rust-discoverable consuming `intoVec`, consuming index iteration, lazy/caller-owned/allocation-returning/consuming value/const-pointer/mutable-pointer and u32 export mapping plus cross-backing content equality, Rust sequence benchmark row |
| weighted index and weighted item choice | Covered | `Rng.weightedIndex`, `Rng.weightedIndexBatch`, `Rng.weightedIndexArray`, `Rng.weightedIndexU32`, `Rng.weightedIndexU32Batch`, `Rng.weightedIndexU32Array`, `Rng.chooseWeighted`, `Rng.chooseWeightedBatch`, `Rng.chooseWeightedValueArray`, `Rng.chooseWeightedConstPtr`, `Rng.chooseWeightedConstPtrBatch`, `Rng.chooseWeightedConstPtrArray`, `Rng.chooseWeightedPtr`, `Rng.chooseWeightedPtrBatch`, `Rng.chooseWeightedPtrArray`, `seq.weightedIndex`, `seq.weightedIndexBatch`, `seq.weightedIndexArray`, `seq.weightedIndexU32`, `seq.weightedIndexU32Batch`, `seq.weightedIndexU32Array`, `seq.chooseWeighted`, `seq.weightedIndexBy`, `seq.weightedIndexArrayBy`, `seq.weightedIndexU32By`, `seq.weightedIndexU32ArrayBy`, `seq.fillWeightedIndexBy`, `seq.fillWeightedIndexU32By`, `seq.weightedIndexBatchBy`, `seq.weightedIndexU32BatchBy`, `seq.chooseWeightedBy`, `seq.chooseWeightedValueArrayBy`, `seq.fillChooseWeightedBy`, `seq.chooseWeightedBatchBy`, `seq.chooseWeightedBatch`, `seq.chooseWeightedValueArray`, `seq.chooseWeightedConstPtr`, `seq.chooseWeightedConstPtrBy`, `seq.chooseWeightedConstPtrArrayBy`, `seq.fillChooseWeightedConstPtrBy`, `seq.chooseWeightedConstPtrBatchBy`, `seq.chooseWeightedConstPtrBatch`, `seq.chooseWeightedConstPtrArray`, `seq.chooseWeightedPtr`, `seq.chooseWeightedPtrBy`, `seq.chooseWeightedPtrArrayBy`, `seq.fillChooseWeightedPtrBy`, `seq.chooseWeightedPtrBatchBy`, `seq.chooseWeightedPtrBatch`, `seq.chooseWeightedPtrArray`, `seq.weightedIndexByIndex`, `seq.weightedIndexU32ByIndex`, `seq.weightedIndexArrayByIndex`, `seq.weightedIndexU32ArrayByIndex`, `seq.fillWeightedIndexByIndex`, `seq.fillWeightedIndexU32ByIndex`, `seq.weightedIndexBatchByIndex`, `seq.weightedIndexU32BatchByIndex`, `seq.chooseWeightedByIndex`, `seq.chooseWeightedValueArrayByIndex`, `seq.chooseWeightedConstPtrByIndex`, `seq.chooseWeightedConstPtrArrayByIndex`, `seq.chooseWeightedPtrByIndex`, `seq.chooseWeightedPtrArrayByIndex`, `seq.fillChooseWeightedByIndex`, `seq.fillChooseWeightedConstPtrByIndex`, `seq.fillChooseWeightedPtrByIndex`, `seq.chooseWeightedBatchByIndex`, `seq.chooseWeightedConstPtrBatchByIndex`, `seq.chooseWeightedPtrBatchByIndex`, `seq.sampleWeightedIndexArrayBy`, `seq.sampleWeightedIndexArrayU32By`, `seq.sampleWeightedArrayBy`, `seq.sampleWeightedPtrArrayBy`, `seq.sampleWeightedMutPtrArrayBy`, `seq.sampleWeightedIndicesBy`, `seq.sampleWeightedIndicesU32By`, `seq.sampleWeightedIndexVecBy`, `seq.sampleWeightedIndicesByIndex`, `seq.sampleWeightedIndicesU32ByIndex`, `seq.sampleWeightedIndexVecByIndex`, `seq.sampleWeightedIndicesByIndexInto`, `seq.sampleWeightedIndicesU32ByIndexInto`, `seq.sampleWeightedIndexArrayByIndex`, `seq.sampleWeightedIndexArrayU32ByIndex`, `seq.sampleWeightedBy`, `seq.sampleWeightedPtrsBy`, `seq.sampleWeightedMutPtrsBy`, `seq.sampleWeightedIndicesByInto`, `seq.sampleWeightedByInto`, `seq.sampleWeightedPtrsByInto`, `seq.sampleWeightedMutPtrsByInto`, `seq.sampleWeightedIndicesInto`, `seq.sampleWeightedIndicesU32`, `seq.sampleWeightedIndicesU32Into`, `seq.sampleWeightedIndexVec`, `seq.sampleWeightedInto`, `seq.sampleWeightedPtrs`, `seq.sampleWeightedPtrsInto`, `seq.sampleWeightedIndexArray`, `seq.sampleWeightedIndexArrayU32`, `seq.sampleWeightedArray`, `seq.sampleWeightedPtrArray`, `AliasTable`, `AliasTable.new`, `AliasTable.updateWeights`, `AliasTable.updateMany`, `AliasTable.updateAt`, `AliasTable.initBy`, `AliasTable.updateBy`, `AliasTable.initByIndex`, `AliasTable.updateByIndex`, `AliasTable.numChoices`, `AliasTable.positiveCount`, `AliasTable.WeightIterator.sizeHint`, `AliasTable.ProbabilityIterator.sizeHint`, `AliasTable.sampleIndex`, `AliasTable.fillIndices`, `AliasTable.sampleU32`, `AliasTable.fillU32`, `AliasTable.indices`, `AliasTable.indicesU32`, `AliasTable.indexArray`, `AliasTable.indexArrayU32`, `AliasTable.iter`, `AliasTable.iterU32`, `WeightedChoice.new`, `WeightedChoice.updateWeights`, `WeightedChoice.updateMany`, `WeightedChoice.updateAt`, `WeightedChoice.initBy`, `WeightedChoice.updateBy`, `WeightedChoice.initByIndex`, `WeightedChoice.updateByIndex`, `WeightedChoice.numChoices`, `WeightedChoice.positiveCount`, `WeightedChoice.constantIndex`, `WeightedChoice.item`, `WeightedChoice.get`, `WeightedChoice.weightIter().sizeHint`, `WeightedChoice.probabilityIter().sizeHint`, `WeightedChoice.sample`, `WeightedChoice.ptrs`, `WeightedChoice.values`, `WeightedChoice.valueArray`, `WeightedChoice.ptrArray`, `WeightedChoice.iter`, `WeightedChoice.ownedIter`, `seq.chooseWeightedIter`, `seq.chooseWeightedIterBy`, `seq.chooseWeightedIterByIndex`, `WeightedChoice.sampleIndex`, `WeightedChoice.fillIndices`, `WeightedChoice.indices`, `WeightedChoice.indexArray`, `WeightedChoice.indexArrayU32`, `WeightedChoice.indexIter`, `WeightedChoice.indexIterU32`, `WeightedTree`, `WeightedTree.updateWeights`, `WeightedTree.updateMany`, `WeightedTree.numChoices`, `WeightedTree.positiveCount`, `WeightedTree.constantIndex`, `WeightedTree.initBy`, `WeightedTree.updateAllBy`, `WeightedTree.initByIndex`, `WeightedTree.updateAllByIndex`, `WeightedTree.weight`, `WeightedTree.weightIter`, `WeightedTree.probability`, `WeightedTree.probabilityIter`, `WeightedTree.sampleIndex`, `WeightedTree.fillIndices`, `WeightedTree.sampleU32`, `WeightedTree.fillU32`, `WeightedTree.indices`, `WeightedTree.indicesU32`, `WeightedTree.indexArray`, `WeightedTree.indexArrayU32`, `WeightedTree.iter`, `WeightedTree.iterU32`, `WeightedIntTree.updateWeights`, `WeightedIntTree.updateMany`, `WeightedIntTree.numChoices`, `WeightedIntTree.positiveCount`, `WeightedIntTree.constantIndex`, `WeightedIntTree.initBy`, `WeightedIntTree.updateAllBy`, `WeightedIntTree.initByIndex`, `WeightedIntTree.updateAllByIndex`, `WeightedIntTree.weight`, `WeightedIntTree.weightIter`, `WeightedIntTree.probability`, `WeightedIntTree.probabilityIter`, `WeightedIntTree.sampleIndex`, `WeightedIntTree.fillIndices`, `WeightedIntTree.sampleU32`, `WeightedIntTree.fillU32`, `WeightedIntTree.indices`, `WeightedIntTree.indicesU32`, `WeightedIntTree.indexArray`, `WeightedIntTree.indexArrayU32`, `WeightedIntTree.iter`, `WeightedIntTree.iterU32`, benchmark rows |

## `rand_distr` 0.6.0 Distribution Surface

| Local Rust family | Alea API | Validation |
| --- | --- | --- |
| Normal, LogNormal, Exp | `standardNormal`, `normal`, `Normal`, `standardExponential`, `exponential`, `Exponential`, scalar/vector standard and parameterized owned batches, `logNormal`, `LogNormal`, `BufferedLogNormal`, `LogNormalDlsymExp`, `LogNormalLibmvec`, plus explicit bounded/native f32 LogNormal opt-ins, vector-only table-quantile Normal/Exponential opt-ins, and vector-only approximate-log f32 Exponential opt-ins | unit tests, `distcheck`, `distcheck-libc` for f64/f32 libmvec/dlsym availability, vector `distcheck`, benchmark rows |
| Gamma, ChiSquared, Beta | `gamma`, `Gamma`, `chiSquared`, `ChiSquared`, `beta`, `Beta` | unit tests, `distcheck`, benchmark rows |
| FisherF, StudentT | `fisherF`, `FisherF`, `studentT`, `StudentT` | unit tests, `distcheck`, benchmark rows |
| Poisson, Binomial | `poisson`, `Poisson`, `binomial`, `Binomial` | unit tests, `distcheck`, benchmark rows |
| Geometric, Hypergeometric | `geometric`, `Geometric`, `hypergeometric`, `Hypergeometric` | unit tests, `distcheck`, benchmark rows including HIN, balanced large H2PE, and skewed large H2PE parameters |
| Triangular, Cauchy, Pareto, Weibull | `triangular`, `Triangular`, `cauchy`, `Cauchy`, `pareto`, `Pareto`, `weibull`, `Weibull` | unit tests, `distcheck`, benchmark rows |
| Gumbel, Frechet, SkewNormal, PERT | `gumbel`, `Gumbel`, `frechet`, `Frechet`, `skewNormal`, `SkewNormal`, `pert`, `Pert` | unit tests, `distcheck`, benchmark rows |
| InverseGaussian, NormalInverseGaussian | `inverseGaussian`, `InverseGaussian`, `normalInverseGaussian`, `NormalInverseGaussian` | unit tests, `distcheck`, benchmark rows |
| Zipf, Zeta | `zipf`, `Zipf`, `zeta`, `Zeta` | unit tests, `distcheck`, benchmark rows |
| UnitCircle, UnitDisc, UnitSphere, UnitBall | `unitCircle`, `UnitCircle`, `unitDisc`, `UnitDisc`, `unitSphere`, `UnitSphere`, `unitBall`, `UnitBall` | unit tests, `distcheck`, benchmark rows |
| Dirichlet | `Dirichlet(T)` | unit tests, `distcheck`, benchmark row |
| WeightedAliasIndex | `AliasTable(Weight)`, including Rust-discoverable `new`, Rust-discoverable `updateWeights`, ordered partial `updateMany`, single-weight `updateAt`, `initBy` / `updateBy` item-accessor helpers, `initByIndex` / `updateByIndex` index-accessor helpers, `sampleIndex` / `fillIndices` aliases, compact `sampleU32` / `fillU32` output, owned `indices` / `indicesU32` batches, fixed-size `indexArray` / `indexArrayU32` output, and repeated `iter` / `iterU32` index streams | unit tests, benchmark rows for weighted index paths; f32, f64, and u32 `WeightedAliasIndex` rows are exceeded by `AliasTable` evidence |
| WeightedTreeIndex | `WeightedTree(Weight)`, `WeightedIntTree(Weight)`, plus `initBy` / `updateAllBy` item-accessor helpers, `initByIndex` / `updateAllByIndex` index-weight accessor helpers, `sampleIndex` / `fillIndices` aliases, compact `sampleU32` / `fillU32` output, owned `indices` / `indicesU32` batches, fixed-size `indexArray` / `indexArrayU32` output, and repeated `iter` / `iterU32` index streams | unit tests, Zig/Rust update+sample benchmark rows for integer and f64 weights |

## Current Stage 4 Performance Watch Items

These are not functionality gaps. S4-M4 through S4-M10 are closed for the current
bars, while S4-M11 remains active. The current blocker and policy audits are
`s4-m4-remaining-gaps.md`, `s4-m5-approximation-policy.md`,
`2026-07-04-s4-m6-profilecheck.md`,
`2026-07-04-s4-m7-profiletailcheck.md`,
`2026-07-04-s4-m8-profilestresscheck.md`,
`2026-07-04-s4-m9-profilelongcheck.md`, and
`2026-07-04-s4-m10-profilelong-musl.md`. In short:

- `LogNormal` exact defaults remain intentionally stable on Zig `@exp` output
  mapping and still trail local Rust single-sample rows, but the S4-M4
  performance gap is now covered by explicit opt-ins: `BufferedLogNormal`,
  `LogNormalDlsymExp`, `LogNormalLibmvec`, and the bounded/native f32 profiles.
  Current evidence and rejected exact transform shapes are recorded in
  `lognormal-transform-notes.md`, `performance-triage.md`, and
  `s4-m4-remaining-gaps.md`.
- vector normal/exponential APIs have broad Zig-native coverage and strong
  scalar-lane-fill rows, but no genuinely dense SIMD distribution kernel has
  beaten scalar ziggurat lane-fill in the real `vectorbench` harness; the
  repair, block-fallback, all-accepted, mask-redraw, flat-slice, lane-local,
  Marsaglia polar, approximate-log polar, ratio-of-uniforms, inverse-CDF
  variants, libmvec vector-log, f64 approximate-log, and cached-Rng attempts are
  recorded in `simd-distribution-kernel-notes.md`; `s4-m5-rand-simd-audit.md`
  confirms local Rust has no comparable SIMD normal/exponential distribution
  row; the new vector table-quantile
  normal/exponential opt-ins and f32 approximate-log exponential opt-ins narrow
  the vector side for users who accept explicit approximation/output-mapping
  contracts, but do not close f64/default dense-kernel requirements. Current
  evidence is recorded in
  `simd-distribution-kernel-notes.md`,
  `performance-triage.md`, and `s4-m4-remaining-gaps.md`.

## Alea Extras Beyond The Local Rust Surface

These are retained as product advantages rather than parity requirements:

- `Multinomial`
- `NegativeBinomial`
- direct weighted no-replacement sampling
- iterator and weighted-iterator sampling with and without replacement
- compact index sampling APIs
- system-entropy constructors aligned with Zig 0.16 `std.Io`
- reproducibility snapshot tooling
- raw stream exporter and PractRand helper tooling

## Validation Commands

The following validation gates are used for the current Linux-first stage:

```sh
zig build test
zig build -Doptimize=ReleaseFast distcheck
zig build -Doptimize=ReleaseFast distcheck-libc
zig build -Doptimize=ReleaseFast statcheck
# zig build validate now includes distcheck-libc on native builds
zig build -Doptimize=ReleaseFast -Dcpu=native bench
zig build -Doptimize=ReleaseFast -Dcpu=native bench-libc
zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench
zig build rand-bench-test
zig build rand-bench-smoke
zig build rand-bench-smoke-dry-run
zig build rand-bench-smoke-self-test
zig build crosscheck
zig build validate-all
RUSTFLAGS='-C target-cpu=native' cargo run --release --manifest-path compare/rand_bench/Cargo.toml
```

Prior Linux engine validation is recorded in the PractRand reports under
`compare/results/`, including 128GiB reports for the current primary-engine
stage.

## Current Finding

Within this audit's local Linux scope, no known core RNG functionality gap
remains against the locally available `rand` / `rand_distr` evidence.

This does not close the long-term product goal. Stage 4 remains active for the
blocked S4-M11 exact-dense-kernel, future-runner, or new-external-gap bar above.
S4-M12 through S4-M14 add runnable adoption guidance for accepted vector,
LogNormal, and native-f32 opt-in profiles, S4-M15 puts examples under local
validation, S4-M16 adds weighted-sampling adoption guidance, S4-M17 adds
multivariate adoption guidance, S4-M18 adds sequence-sampling adoption guidance,
S4-M19 adds string-generation adoption guidance, S4-M20 adds unit-geometry
adoption guidance, S4-M21 adds distribution diagnostics adoption guidance,
S4-M22 adds reproducible-stream adoption guidance, S4-M23 adds range/uniform
adoption guidance, S4-M24 adds discrete-distribution adoption guidance, S4-M25
adds continuous-distribution adoption guidance, S4-M26 adds advanced-continuous
adoption guidance, S4-M27 adds rank-distribution adoption guidance, S4-M28 adds
a central examples catalog, S4-M29 adds catalog drift checking, S4-M30 adds
build/tooling catalog drift checking, S4-M31 adds README/doccheck discovery
validation, S4-M32 adds roadmap/audit drift checking, S4-M33 adds fixed-size
item array sequence sampling, S4-M34 adds one-shot weighted item/pointer choice,
S4-M35 adds caller-owned reservoir sampling, S4-M36 adds caller-owned iterator
reservoir sampling, and S4-M37 adds fixed-size weighted item array sampling, S4-M38 adds fixed-size
weighted index array sampling, S4-M39 adds fixed-size weighted iterator array
sampling, and S4-M40 adds fixed-size iterator array sampling, S4-M41 adds caller-owned
weighted index sampling, S4-M42 adds caller-owned weighted item sampling, and
S4-M43 adds caller-owned weighted iterator sampling, S4-M44 adds caller-owned
index sampling, and S4-M45 adds caller-owned slice item sampling, and S4-M46 adds selected/rest head partial-shuffle splits, and S4-M47 adds caller-owned `u32` index sampling, and S4-M48 adds a focused caller-owned sampling adoption example, and S4-M49 adds IndexVec item iterators, and S4-M50 adds caller-owned IndexVec item
mapping, and S4-M51 adds checked mutable-pointer IndexVec mapping, and S4-M52 adds
caller-owned pointer subset sampling, and S4-M53 adds fixed-size pointer array
sampling, and S4-M54 adds fixed-size weighted pointer array sampling, and S4-M55 adds
caller-owned weighted pointer subset sampling, and S4-M56 adds const-pointer
single choice, and S4-M57 adds weighted const-pointer single choice, and S4-M58 adds
allocation-returning pointer subset sampling, and S4-M59 adds allocation-returning
weighted pointer subset sampling, and S4-M60 adds allocation-returning reservoir
pointer sampling, and S4-M61 adds caller-owned reservoir pointer sampling, and S4-M62 refreshes
the caller-owned pointer adoption example, and S4-M63 adds one-shot index choice,
and S4-M64 adds generic one-shot weighted index choice, and S4-M65 hardens
example content drift checks, and S4-M66 hardens S4-M11 blocker audit drift
checks, and S4-M67 refreshes README quick-start index/pointer choice discovery, and
S4-M68 hardens doccheck dependency validation, S4-M69 adds weighted IndexVec
sampling, S4-M70 adds caller-owned weighted u32 index buffers, S4-M71 adds
fixed-size weighted u32 index arrays, S4-M72 adds allocation-returning weighted
u32 index slices, S4-M73 adds fixed-size u32 index arrays, S4-M74 adds IndexVec
u32 export mapping, S4-M75 adds IndexVec owned item mapping, S4-M76 adds
one-shot u32 index choice, S4-M77 adds generic weighted u32 index choice, S4-M78
adds f64 weighted u32 index choice, S4-M79 adds WeightedChoice index fills,
S4-M80 adds Choice index fills, S4-M81 adds Choice sampler index samples, and
S4-M82 adds Choice owned index batches, S4-M83 adds WeightedChoice owned
index batches, S4-M84 adds reusable choice owned value/pointer batches, and
S4-M85 adds Rng owned repeated value/sample batches, S4-M86 adds Rng owned
byte buffers, S4-M87 adds Rng owned scalar range batches, and S4-M88 adds
Rng owned strict-interval float batches, and S4-M89 adds Rng owned probability
bool batches, and S4-M90 adds Rng owned normal/exponential batches, S4-M91 adds
Rng owned duration range batches, S4-M92 adds Rng owned vector range batches,
S4-M93 adds Rng owned vector strict-interval batches, S4-M94 adds Rng owned
vector probability bool batches, S4-M95 adds Rng owned vector
normal/exponential batches, S4-M96 adds direct standard normal/exponential
batches, S4-M97 adds Unicode scalar batches, S4-M98 adds Unicode scalar ranges,
S4-M99 through S4-M101 add bounded/inclusive scalar and vector range batches,
S4-M102 through S4-M105 add repeated index/value/pointer choice batches, and
S4-M106 through S4-M114 add repeated weighted
f64/generic index/u32-index plus value/const-pointer/mutable-pointer batches,
S4-M115 adds accessor-based weighted value/const-pointer/mutable-pointer
choices for item-embedded weights, S4-M116 adds matching accessor-based
weighted no-replacement value/const-pointer/mutable-pointer samples, S4-M117
adds caller-owned accessor-weighted no-replacement buffers, S4-M118 adds
allocation-returning accessor-weighted index/u32-index/IndexVec samples, S4-M119 adds accessor-weighted fixed-size index arrays, and S4-M120 adds
accessor-weighted fixed-size value/const-pointer/mutable-pointer arrays, and
S4-M121 adds accessor-based reusable `WeightedChoice` construction/update, S4-M122 adds stable iterator choice aliases, S4-M123 adds iterator
sample-fill aliases, S4-M124 adds slice item/pointer sample aliases, S4-M125
adds index-weighted no-replacement samples, S4-M126 adds caller-owned
index-weighted buffers, S4-M127 adds fixed-size index-weighted arrays, S4-M128
adds fixed-size slice sample aliases, S4-M129 adds `seq.shuffle` aliases,
S4-M130 adds Rust-style tail partial shuffles, S4-M131 adds `seq.choose`
aliases, S4-M132 adds `seq.fillChoose` aliases, S4-M133 adds
`seq.chooseBatch` aliases, and S4-M134 adds `seq.chooseIndex` /
`seq.fillChooseIndex` / `seq.chooseIndexBatch` aliases, S4-M135 adds
accessor-weighted `seq.fillChooseWeighted*By` aliases, and S4-M136 adds
accessor-weighted `seq.chooseWeighted*BatchBy` aliases, and S4-M137 adds
accessor-weighted `seq.weightedIndex*By` aliases, and S4-M138 adds
accessor-weighted `seq.fillWeightedIndex*By` aliases, and S4-M139 adds
accessor-weighted `seq.weightedIndex*BatchBy` aliases, and S4-M140 adds
index-weighted `seq.weightedIndex*ByIndex` aliases, and S4-M141 adds
index-weighted `seq.fillWeightedIndex*ByIndex` aliases, and S4-M142 adds
index-weighted `seq.weightedIndex*BatchByIndex` aliases, and S4-M143 adds
index-weighted `seq.chooseWeighted*ByIndex` aliases, and S4-M144 adds
index-weighted `seq.fillChooseWeighted*ByIndex` aliases, and S4-M145 adds
index-weighted `seq.chooseWeighted*BatchByIndex` aliases, and S4-M146 adds
index-weighted reusable `WeightedChoice.initByIndex` / `updateByIndex`, S4-M147 adds
index-weighted dynamic `WeightedTree` / `WeightedIntTree` construction and refresh, S4-M148 adds
item-accessor dynamic `WeightedTree` / `WeightedIntTree` construction and refresh, and S4-M149 adds
compact `u32` dynamic tree sample/fill output, and S4-M150 adds owned repeated dynamic tree
index/u32-index batches, S4-M151 adds `sampleIndex` / `fillIndices` dynamic tree aliases, S4-M152 adds repeated dynamic tree index/u32-index iterators, S4-M153 adds compact `u32` `AliasTable` sample/fill output, S4-M154 adds owned repeated `AliasTable` index/u32-index batches, S4-M155 adds `sampleIndex` / `fillIndices` `AliasTable` aliases, S4-M156 adds repeated `AliasTable` index/u32-index iterators, S4-M157 adds index-weighted `AliasTable.initByIndex` / `updateByIndex`, S4-M158 adds item-accessor `AliasTable.initBy` / `updateBy`, S4-M159 adds fixed-size `AliasTable` index/u32-index arrays, S4-M160 adds fixed-size dynamic tree index/u32-index arrays, S4-M161 adds fixed-size reusable `WeightedChoice` index/u32-index arrays, S4-M162 adds fixed-size reusable `Choice` index/u32-index arrays, S4-M163 adds fixed-size reusable `Choice` value/pointer arrays, S4-M164 adds fixed-size reusable `WeightedChoice` value/pointer arrays, and S4-M165 adds fixed-size repeated index-choice arrays for `Rng` and `seq`, and S4-M166 adds fixed-size repeated value/pointer choice arrays for `Rng`, and S4-M167 adds fixed-size repeated f64 weighted index/value/pointer arrays for `Rng` (`compare/results/s4-m167-rng-weighted-choice-arrays.md`), and S4-M168 adds fixed-size repeated generic-weight index/value/pointer arrays for `seq` (`compare/results/s4-m168-seq-generic-weighted-choice-arrays.md`), and S4-M169 adds fixed-size repeated item-accessor weighted index/value/pointer arrays for `seq` (`compare/results/s4-m169-accessor-weighted-choice-arrays.md`), and S4-M170 adds fixed-size repeated length/index-weight accessor weighted index/value/pointer arrays for `seq` (`compare/results/s4-m170-index-weighted-choice-arrays.md`), and S4-M171 adds explicit fixed-size repeated value/pointer choice arrays for `seq` (`compare/results/s4-m171-seq-repeated-choice-arrays.md`), and S4-M172 adds reusable `Choice` / `WeightedChoice` repeated index/u32-index iterators (`compare/results/s4-m172-choice-index-iterators.md`), and S4-M173 adds `IndexVec` consuming owned-slice conversions (`compare/results/s4-m173-indexvec-consuming-owned.md`), and S4-M174 adds `IndexVec` content equality (`compare/results/s4-m174-indexvec-equality.md`), and S4-M175 adds `IndexVec` owned backing constructors (`compare/results/s4-m175-indexvec-owned-constructors.md`), and S4-M176 adds `IndexVec` deep clone (`compare/results/s4-m176-indexvec-clone.md`), and S4-M177 adds a consuming `IndexVec` iterator (`compare/results/s4-m177-indexvec-consuming-iterator.md`), and S4-M178 adds repeated weighted choice pointer iterators (`compare/results/s4-m178-weighted-choice-iterators.md`), and S4-M179 adds accessor-weighted repeated pointer iterators (`compare/results/s4-m179-accessor-weighted-choice-iterators.md`), and S4-M180 adds index-weighted repeated pointer iterators (`compare/results/s4-m180-index-weighted-choice-iterators.md`), and S4-M181 adds sampled pointer iterators (`compare/results/s4-m181-sampled-ptr-iterators.md`), and S4-M182 adds sampled value iterators (`compare/results/s4-m182-sampled-value-iterators.md`), and S4-M183 adds sampled mutable-pointer iterators (`compare/results/s4-m183-sampled-mut-ptr-iterators.md`), and S4-M184 adds choice count diagnostics (`compare/results/s4-m184-choice-numchoices.md`), and S4-M185 adds sampled iterator fill helpers (`compare/results/s4-m185-sampled-iterator-fill.md`), and S4-M186 adds exact-size iterator len aliases (`compare/results/s4-m186-iterator-len-aliases.md`), and S4-M187 adds exact-size iterator size hints (`compare/results/s4-m187-iterator-size-hints.md`), and S4-M188 adds IndexVec iterator fill helpers (`compare/results/s4-m188-indexvec-iterator-fill.md`), and S4-M189 adds a Rust-discoverable IndexVec.index alias (`compare/results/s4-m189-indexvec-index-alias.md`), and S4-M190 adds checked IndexVec positional lookup (`compare/results/s4-m190-indexvec-get.md`), and S4-M191 adds optional weighted sampler weight lookup (`compare/results/s4-m191-weighted-sampler-weight.md`), and S4-M192 adds weighted sampler weight iterators (`compare/results/s4-m192-weight-iterators.md`), and S4-M193 adds optional weighted sampler probability lookup (`compare/results/s4-m193-weighted-sampler-probability.md`), and S4-M194 adds weighted sampler probability iterators (`compare/results/s4-m194-probability-iterators.md`), and S4-M195 adds Choice optional probability lookup (`compare/results/s4-m195-choice-probability.md`), and S4-M196 adds a Choice probability iterator (`compare/results/s4-m196-choice-probability-iterator.md`), and S4-M197 adds Charset optional probability lookup (`compare/results/s4-m197-charset-probability.md`), and S4-M198 adds a Charset probability iterator (`compare/results/s4-m198-charset-probability-iterator.md`), and S4-M199 adds reusable choice item lookup (`compare/results/s4-m199-choice-get.md`), and S4-M200 adds Charset optional item lookup (`compare/results/s4-m200-charset-get.md`), and S4-M201 adds diagnostic iterator size hints (`compare/results/s4-m201-diagnostic-iterator-sizehints.md`), and S4-M202 adds Charset count diagnostics (`compare/results/s4-m202-charset-numchoices.md`), and S4-M203 adds reusable choice checked item aliases (`compare/results/s4-m203-choice-item-alias.md`), and S4-M204 adds Charset checked item alias (`compare/results/s4-m204-charset-item-alias.md`), and S4-M205 adds dynamic tree optional weight lookup (`compare/results/s4-m205-tree-weight.md`), and S4-M206 adds dynamic tree optional probability lookup (`compare/results/s4-m206-tree-probability.md`), and S4-M207 adds dynamic tree weight iterators (`compare/results/s4-m207-tree-weight-iterators.md`), and S4-M208 adds dynamic tree probability iterators (`compare/results/s4-m208-tree-probability-iterators.md`), and S4-M209 adds AliasTable count diagnostics (`compare/results/s4-m209-aliastable-numchoices.md`), and S4-M210 adds dynamic tree count diagnostics (`compare/results/s4-m210-tree-numchoices.md`), and S4-M211 adds dynamic tree constant-index diagnostics (`compare/results/s4-m211-tree-constant-index.md`), and S4-M212 adds `WeightedChoice` constant-index diagnostics (`compare/results/s4-m212-weightedchoice-constant-index.md`), and S4-M213 adds reusable `Choice` singleton constant-index diagnostics (`compare/results/s4-m213-choice-constant-index.md`), and S4-M214 adds Charset singleton constant-index diagnostics (`compare/results/s4-m214-charset-constant-index.md`), and S4-M215 adds dynamic tree positive-count diagnostics (`compare/results/s4-m215-tree-positive-count.md`), and S4-M216 adds AliasTable positive-count diagnostics (`compare/results/s4-m216-aliastable-positive-count.md`), and S4-M217 adds `WeightedChoice` positive-count diagnostics (`compare/results/s4-m217-weightedchoice-positive-count.md`), and S4-M218 adds static/reusable weighted single-weight update helpers (`compare/results/s4-m218-weighted-update-at.md`), and S4-M219 adds ordered static/reusable weighted partial update helpers (`compare/results/s4-m219-weighted-update-many.md`), and S4-M220 adds ordered dynamic weighted-tree partial update helpers (`compare/results/s4-m220-tree-update-many.md`), and S4-M221 adds Rust-discoverable weighted `updateWeights` aliases (`compare/results/s4-m221-weighted-updateweights-alias.md`), and S4-M222 adds a Rust-discoverable `IndexVec.intoVec` alias (`compare/results/s4-m222-indexvec-into-vec.md`), and S4-M223 adds Rust-discoverable `Choice.new` aliases (`compare/results/s4-m223-choice-new-alias.md`), and S4-M224 adds Rust-discoverable weighted `new` aliases (`compare/results/s4-m224-weighted-new-alias.md`), and S4-M225 adds Rust-discoverable Bernoulli `new` aliases (`compare/results/s4-m225-bernoulli-new-alias.md`), and S4-M226 adds Rust-discoverable scalar/vector Uniform `new` aliases (`compare/results/s4-m226-uniform-new-alias.md`), and S4-M227 adds Rust-discoverable Bernoulli `fromRatio` aliases (`compare/results/s4-m227-bernoulli-fromratio-alias.md`), and S4-M228 adds Rust-discoverable Bernoulli `p()` aliases (`compare/results/s4-m228-bernoulli-p-alias.md`), and S4-M229 adds Rust-discoverable uniform `sampleSingle` aliases (`compare/results/s4-m229-uniform-samplesingle-alias.md`), and S4-M230 adds Rust-discoverable `Rng.randomBool` / `randomRatio` aliases (`compare/results/s4-m230-rng-random-bool-ratio-alias.md`), and S4-M231 adds Rust-discoverable `Rng.randomRange` aliases (`compare/results/s4-m231-rng-random-range-alias.md`), and S4-M232 adds Rust-discoverable `Rng.sample` aliases (`compare/results/s4-m232-rng-sample-alias.md`), and S4-M233 adds Rust-discoverable `Rng.randomValue` aliases (`compare/results/s4-m233-rng-random-value-alias.md`), and S4-M234 adds Rust-discoverable `Rng.nextU64` / `nextU32` / `fillBytes` raw aliases (`compare/results/s4-m234-rng-raw-aliases.md`), and S4-M235 adds matching Rust-discoverable direct-engine raw aliases (`compare/results/s4-m235-engine-raw-aliases.md`), and S4-M236 adds Rust-discoverable direct-engine `seedFromU64` aliases (`compare/results/s4-m236-engine-seedfromu64-aliases.md`), and S4-M237 adds Rust-discoverable direct-engine `fromSeed` aliases (`compare/results/s4-m237-engine-fromseed-aliases.md`), and S4-M238 adds Rust-discoverable `Seed.fromRng` plus direct-engine `fromRng` / `fork` aliases (`compare/results/s4-m238-engine-fromrng-fork-aliases.md`), and S4-M239 strengthens direct-engine `fromRng` / `fork` to consume full target seed material (`compare/results/s4-m239-full-state-fromrng.md`), and S4-M240 adds Rust-discoverable direct-engine `fromSeedBytes` byte-array seed constructors (`compare/results/s4-m240-engine-fromseedbytes-aliases.md`), and S4-M241 adds Rust-discoverable fallible `tryFromRng` seed constructors (`compare/results/s4-m241-engine-tryfromrng-aliases.md`), and S4-M242 adds Rust-discoverable engine `tryNext` / `tryFork` aliases (`compare/results/s4-m242-engine-tryfork-aliases.md`), and S4-M243 adds Rust-discoverable facade/engine `tryNextU64` / `tryNextU32` / `tryFillBytes` raw aliases (`compare/results/s4-m243-try-raw-rng-aliases.md`), and S4-M244 adds direct-source `Rng.try*From` raw aliases (`compare/results/s4-m244-rng-try-raw-from-aliases.md`), and S4-M245 adds Rust-discoverable root `makeRng(Engine, io)` (`compare/results/s4-m245-root-makerng.md`), but later stages should
keep raising the bar rather than declaring the product permanently finished.
S4-M246 adds a Zig-native `RngReader` / `rngReader` `std.Io.Reader`
byte-stream adapter (`compare/results/s4-m246-rng-reader.md`), closing the
local Rust `rand::RngReader` interop gap for the current Linux bar.
S4-M247 adds a Rust-discoverable `Rng.SysRng` / root `sysRng(io)`
system-entropy source (`compare/results/s4-m247-sysrng.md`), closing the local
Rust `rand::rngs::SysRng` / `getrandom::SysRng` source-shape gap for the
current Linux bar.
S4-M248 adds a mapped reusable-sampler adapter
(`compare/results/s4-m248-mapped-sampler.md`), closing the local Rust
`Distribution::map` ergonomics gap for the current Linux bar without importing
trait machinery.
S4-M249 adds unbounded `sizeHint()` diagnostics to value/random/sample iterators
(`compare/results/s4-m249-unbounded-iterator-sizehint.md`), closing the local
Rust `Distribution::Iter::size_hint` / `random_iter` discoverability gap for
the current Linux bar.
S4-M250 adds distribution-namespace `sampleIter` / `sampleIterFrom` aliases
(`compare/results/s4-m250-distribution-sampleiter.md`), closing the local Rust
`Distribution::sample_iter` naming/discoverability gap for the current Linux
bar.
S4-M251 adds `sampleString` / `appendString` ASCII aliases
(`compare/results/s4-m251-samplestring-aliases.md`), closing the local Rust
`SampleString::sample_string` / `append_string` discoverability gap for the
current Linux bar.
S4-M252 adds reusable Unicode scalar charset strings
(`compare/results/s4-m252-unicode-charset.md`), closing the local Rust
`SampleString for Choose<char>`-style reusable char-alphabet workflow in
Zig-native `u21` / UTF-8 form for the current Linux bar.
S4-M253 adds hint-sensitive iterator choice helpers
(`compare/results/s4-m253-hinted-iterator-choice.md`), closing the local Rust
`IteratorRandom::choose` exact-size-hint workflow while preserving Alea's
stable reservoir iterator choice defaults for the current Linux bar.
S4-M254 adds Rust-discoverable root `StdRng` and `SmallRng` aliases
(`compare/results/s4-m254-stdrng-smallrng-aliases.md`), closing the local Rust
`rand::rngs::{StdRng, SmallRng}` discovery-name gap while preserving Alea's
existing `SecurePrng` and `Xoshiro256PlusPlus` engine contracts.
S4-M255 adds a Rust-discoverable `StepRng` deterministic mock source
(`compare/results/s4-m255-step-rng.md`), closing the local Rust `StepRng`
test/mock byte-stream workflow for the current Linux bar.
S4-M256 adds a Rust-discoverable `ChaCha12Rng` root alias
(`compare/results/s4-m256-chacha12rng-alias.md`), closing the local Rust
optional-`chacha` `rand::rngs::ChaCha12Rng` discovery-name gap while preserving
Alea's existing `ChaCha` / `SecurePrng` engine contract.
S4-M257 adds Rust-discoverable `ChaCha8Rng` and `ChaCha20Rng` engines
(`compare/results/s4-m257-chacha8-chacha20-rngs.md`), closing the remaining
local Rust optional-`chacha` `rand::rngs::{ChaCha8Rng, ChaCha20Rng}`
discovery/workflow gap while preserving Alea's existing ChaCha12 `SecurePrng`
and `StdRng` contract.
S4-M258 adds a Rust-discoverable `Xoshiro128PlusPlus` engine
(`compare/results/s4-m258-xoshiro128plusplus.md`), closing the local Rust
portable 32-bit Xoshiro++ generator discovery/workflow gap while preserving
local 64-bit `SmallRng = Xoshiro256PlusPlus`.
S4-M259 adds explicit-I/O root `random` / `randomIter` / `randomRange` /
`randomBool` / `randomRatio` / `fill` helpers
(`compare/results/s4-m259-root-random-helpers.md`), closing the local Rust
top-level helper workflow gap without introducing hidden thread-local RNG state.
S4-M260 adds a Rust-discoverable root `SysError` alias
(`compare/results/s4-m260-syserror-alias.md`), closing the local Rust
`rand::rngs::SysError` discovery-name gap while preserving Alea's explicit
`SysRng.Error = std.Io.RandomSecureError` contract.
S4-M261 adds Rust-discoverable `seq.WeightError` and root `WeightError` aliases
(`compare/results/s4-m261-weighterror-alias.md`), closing the local Rust
`rand::seq::WeightError` discovery-name gap while preserving Alea's existing
weighted-sampling error contract.
S4-M262 adds distribution-namespace `StandardUniform`
(`compare/results/s4-m262-standard-uniform.md`), closing the local Rust
`rand::distr::StandardUniform` discovery gap by exposing Alea's existing
default-value sampling semantics as a reusable sampler with scalar, direct-source,
primitive/vector fill, and compound repeated-value workflows.
S4-M263 adds `distributions.BernoulliError`
(`compare/results/s4-m263-bernoulli-error.md`), closing the local Rust
`rand::distr::BernoulliError` discovery-name gap while preserving Alea's
invalid-probability semantics for scalar and vector Bernoulli construction.
S4-M264 adds distribution-namespace `Alphanumeric` / `Alphabetic` aliases
(`compare/results/s4-m264-distribution-ascii-aliases.md`), closing the local
Rust `rand::distr::{Alphanumeric, Alphabetic}` discovery-name gap while
preserving Alea's canonical `ascii.Charset` implementation and string APIs.
S4-M265 adds `distributions.WeightedIndex`
(`compare/results/s4-m265-weightedindex-alias.md`), closing the local Rust
`rand::distr::weighted::WeightedIndex` discovery-name gap while preserving
Alea's `AliasTable` static weighted sampler implementation and O(1) repeated
sampling contract.
S4-M266 adds `distributions.UniformDuration`
(`compare/results/s4-m266-uniform-duration.md`), closing the local Rust
`rand::distr::uniform::UniformDuration` discovery-name gap while preserving
Alea's `std.Io.Duration` range helper semantics and inclusive point-mass
no-consume behavior.
S4-M267 adds `distributions.UniformUnicodeScalar`
(`compare/results/s4-m267-uniform-unicode-scalar.md`), closing the local Rust
`rand::distr::uniform::UniformChar` reusable-sampler workflow in Zig-native
`u21` form while preserving surrogate-gap validation and Unicode scalar range
helper stream shape.
S4-M268 adds distribution-namespace `Choose(T)`
(`compare/results/s4-m268-distribution-choose.md`), closing the local Rust
`rand::distr::slice::Choose` discovery-name gap while preserving Alea's
sequence-choice semantics over `[]const T`.
S4-M269 adds `distributions.UniformError`
(`compare/results/s4-m269-uniform-error.md`), closing the local Rust
`rand::distr::uniform::Error` discovery-name gap while preserving Alea's
uniform-family `Error` semantics.
S4-M270 adds distribution-namespace `Map` / `Iter` aliases
(`compare/results/s4-m270-map-iter-aliases.md`), closing the local Rust
`rand::distr::{Map, Iter}` discovery-name gap while preserving Alea's existing
mapped sampler and sample iterator implementations.
S4-M271 adds distribution-namespace `WeightError` / `WeightedError` aliases
(`compare/results/s4-m271-weighted-error-aliases.md`), closing the local Rust
`rand::distr::weighted::Error` discovery-name gap while preserving Alea's
existing weighted-sampling error contract.
S4-M272 adds `UniformInt(T)`, `UniformFloat(T)`, and `UniformUsize`
(`compare/results/s4-m272-uniform-backend-aliases.md`), closing the local Rust
`rand::distr::uniform::{UniformInt, UniformFloat, UniformUsize}` discovery-name
gap while preserving Alea's existing `Uniform(T)` implementation.
S4-M273 adds `distributions.slice.Choose(T)` and `distributions.slice.Empty`
(`compare/results/s4-m273-slice-namespace-aliases.md`), closing the local Rust
`rand::distr::slice::{Choose, Empty}` namespace discovery gap while preserving
Alea's existing `Choose(T)` sampler and distribution error contract.
S4-M274 adds `distributions.UniformChar`
(`compare/results/s4-m274-uniform-char-alias.md`), closing the local Rust
`rand::distr::uniform::UniformChar` discovery-name gap while preserving Alea's
existing `UniformUnicodeScalar` reusable `u21` scalar sampler.
S4-M275 adds `NonFinite` to checked scalar/vector float range and uniform error
paths (`compare/results/s4-m275-uniform-nonfinite.md`), closing the local Rust
`rand::distr::uniform::Error::NonFinite` diagnostics gap while preserving
checked validation before random-stream consumption.
S4-M276 adds `Uniform(T).tryFromRange` / `tryFromRangeInclusive` and matching
`VectorUniform` aliases (`compare/results/s4-m276-uniform-range-constructors.md`),
closing the local Rust `Uniform::try_from(Range)` / `RangeInclusive`
discoverability gap while preserving Alea's existing constructors.
S4-M277 adds the root `rngs` namespace
(`compare/results/s4-m277-rngs-namespace.md`), closing the local Rust
`rand::rngs::*` namespace discoverability gap for Alea's existing explicit
engine aliases and `SysRng` source without adding hidden thread-local RNG state.
S4-M278 adds root `RngReader(Source)` and `rngReader(source, buffer)`
(`compare/results/s4-m278-root-rngreader.md`), closing the local Rust root
`rand::RngReader` discovery gap while preserving Alea's explicit caller-buffer
`std.Io.Reader` adapter design.
S4-M279 adds `seq.IndexedSamples(T)` and `seq.SliceChooseIter(T)`
(`compare/results/s4-m279-indexed-samples-aliases.md`), closing the local Rust
`rand::seq::{IndexedSamples, SliceChooseIter}` discovery gap while preserving
Alea's sampled const-pointer iterator implementation.
S4-M280 adds the root `prelude` namespace
(`compare/results/s4-m280-prelude-namespace.md`), closing the local Rust
`rand::prelude::*` discovery gap for Alea's common modules and aliases without
adding Rust trait machinery.
S4-M281 adds weighted error variant diagnostics
(`compare/results/s4-m281-weighted-error-variants.md`), closing the local Rust
`rand::distr::weighted::Error::{InvalidInput, InvalidWeight,
InsufficientNonZero, Overflow}` diagnostics gap for static `AliasTable` /
`WeightedIndex` workflows while preserving existing weighted error aliases.
S4-M282 adds root `distr` (`compare/results/s4-m282-distr-alias.md`), closing
the local Rust `rand::distr::*` module-name discovery gap while preserving
Alea's canonical `distributions` module name.
S4-M283 audits the remaining local Rust trait/marker/thread-local public
surface (`compare/results/s4-m283-rust-trait-surface-audit.md`) and records that
the remaining names are covered by Zig-native APIs or intentionally not copied
unless a concrete workflow gap appears.
S4-M284 adds the distribution `weighted` namespace
(`compare/results/s4-m284-weighted-namespace.md`), closing the local Rust
`rand::distr::weighted::*` path discovery gap while preserving Alea's canonical
`AliasTable` / `WeightedIndex` implementation and weighted error aliases.
S4-M285 audits the local Rust `rand::distr::uniform::*` namespace path
(`compare/results/s4-m285-uniform-namespace-audit.md`) and records that concrete
uniform workflows are already covered by top-level `distributions.*` APIs, while
the intermediate Rust module path is intentionally not copied because it would
collide with Alea's existing one-shot `uniform(...)` function.
S4-M286 audits the root `rand_core` re-export and resolved `rand_core` 0.10.1
surface (`compare/results/s4-m286-rand-core-reexport-audit.md`) and records that
raw/try/seeding/reader/byte-fill workflows are covered by Alea concrete APIs,
while the remaining names are Rust trait/adaptor/block-generator implementation
machinery intentionally not copied.
S4-M287 audits the local Rust `rand::seq::index` namespace path
(`compare/results/s4-m287-seq-index-namespace-audit.md`) and records that
concrete index, compact-index, fixed-size, weighted-index, and item-mapping
workflows are covered by top-level `seq.*` APIs, while a `seq.index` namespace
would duplicate functionality and collide with existing Zig identifiers.
S4-M288 adds a consolidated local Rust public-surface manifest
(`compare/results/s4-m288-local-rand-public-surface-manifest.md`) mapping the
current root, `rngs`, `distr`, `seq`, and resolved `rand_core` public names to
Alea evidence or intentional exclusions; the manifest identifies no new
unblocked local Rust public-surface gap.
S4-M289 adds local `rand_distr 0.6.0` root error discovery aliases
(`compare/results/s4-m289-rand-distr-error-aliases.md`) such as `NormalError`,
`ExpError`, `GammaError`, `PoissonError`, and `ZipfError` over Alea's shared
distribution error set while preserving Zig-native diagnostics.
S4-M290 adds local `rand_distr` `Exp` / `Exp1` discovery aliases
(`compare/results/s4-m290-exp-aliases.md`) over Alea's existing
`Exponential(T)` and `StandardExponential(T)` samplers.
S4-M291 adds local `rand_distr::multi::Dirichlet` discovery
(`compare/results/s4-m291-multi-dirichlet-alias.md`) over Alea's existing
`Dirichlet(T)` sampler while intentionally not copying Rust multivariate trait
machinery.
S4-M292 adds local `rand_distr` `new(...)` constructor discovery aliases
(`compare/results/s4-m292-rand-distr-new-aliases.md`) for matching scalar
sampler shapes while documenting the Geometric trial/failure semantic
exception.
S4-M293 adds local `rand_distr` `from_mean_cv` constructor discovery aliases
(`compare/results/s4-m293-from-mean-cv-aliases.md`) for `Normal(T)` and
`LogNormal(T)` over Alea's existing `initMeanCv` constructors.
S4-M294 adds a consolidated cached local `rand_distr 0.6.0` public-surface
manifest (`compare/results/s4-m294-rand-distr-public-surface-manifest.md`)
mapping root distribution, error, `multi`, `weighted`, utility, and trait
surfaces to Alea evidence or intentional exclusions; the manifest identifies no
new unblocked local `rand_distr` public-surface gap.
S4-M295 adds `roadmapcheck` guardrails over the S4-M288 and S4-M294 public
surface manifests (`compare/results/s4-m295-public-surface-manifest-guardrails.md`):
the checker now validates scanned-source/version tokens, major public-surface
sections, representative Rust-only exclusions, no-new-gap results, and
non-completion notes so future local `rand` / `rand_distr` comparisons do not
silently regress to file-existence-only evidence.
S4-M296 adds an explicit local source drift checker
(`compare/results/s4-m296-surfacecheck.md`) exposed as `zig build surfacecheck`;
it re-scans the available local Rust `rand`, resolved `rand_core`, and cached
`rand_distr` source files for public declarations/re-exports and checks they are
mapped by the S4-M288/S4-M294 manifests, while documenting that
`rand_distr` `#[cfg(test)]` helpers such as `VoidRng` / `rng` are not public
crate-surface gaps.
S4-M297 strengthens that checker
(`compare/results/s4-m297-surfacecheck-multiline-reexports.md`) so it collects
and validates Rust multiline `pub use ... { ... };` re-export blocks from the
local `rand` / `rand_distr` sources, reducing reliance on manual expected-token
lists when checking manifest drift.
S4-M298 adds SkewNormal parameter discovery aliases
(`compare/results/s4-m298-skewnormal-parameter-aliases.md`) for local
`rand_distr::SkewNormal::{location, scale, shape}` accessor workflows:
`locationParameter`, `scaleParameter`, and `shapeParameter` mirror existing
`locationValue`, `scaleValue`, and `shapeValue` accessors on scalar and vector
samplers while avoiding exact Rust method names that collide with public Zig
fields.
S4-M299 documents the local `rand_distr::weighted::WeightedTreeIndex::is_valid`
surface (`compare/results/s4-m299-weighted-tree-is-valid.md`) as covered by
existing `WeightedTree.isValid` and `WeightedIntTree.isValid` readiness
diagnostics, and makes `surfacecheck` require the manifest token so this mapping
does not silently regress.
S4-M300 adds Normal parameter discovery aliases
(`compare/results/s4-m300-normal-parameter-aliases.md`) for local
`rand_distr::Normal::{mean, std_dev}` accessor workflows:
`meanParameter`, `stddevParameter`, and `stdDevParameter` mirror existing
`meanValue` and `stddevValue` accessors while avoiding exact Rust method names
that collide with public Zig fields.
S4-M301 strengthens the local surface drift checker
(`compare/results/s4-m301-surfacecheck-impl-methods.md`) so it also validates
non-test Rust `impl`-body `pub fn` methods. The newly exposed local method names
are mapped in the S4-M288/S4-M294 manifests to existing Alea APIs or Rust-only
scaffolding, and `zig build surfacecheck` passes with the broader scan.
S4-M302 extends that checker
(`compare/results/s4-m302-surfacecheck-bernoulli-impl.md`) to local
`rand/src/distr/bernoulli.rs`, ensuring the re-exported `Bernoulli::from_ratio`
and `Bernoulli::p` methods remain mapped to Alea `fromRatio` and `p()`.
S4-M303 adds coverage summaries to `zig build surfacecheck`
(`compare/results/s4-m303-surfacecheck-summary.md`), so local `rand`, resolved
`rand_core`, and cached `rand_distr` checks report the number of source files,
manifest expected tokens, and source-discovered tokens validated.
S4-M304 hardens `surfacecheck` token matching
(`compare/results/s4-m304-surfacecheck-token-boundaries.md`) so manifest checks
prefer exact backtick-wrapped code tokens or identifier-boundary matches instead
of accepting arbitrary substrings; this exposed and closed additional local
`rand` manifest mappings for short method names that had previously matched
incidentally.
S4-M305 expands `surfacecheck` file coverage
(`compare/results/s4-m305-surfacecheck-extra-files.md`) to local
`rand/src/distr/other.rs` and cached `rand_distr/src/ziggurat_tables.rs`, so the
source-driven audit covers ASCII distribution aliases and public ziggurat table
type names alongside the existing manifest entries.
S4-M306 adds an unlisted-public-file guard to `surfacecheck`
(`compare/results/s4-m306-surfacecheck-public-file-guard.md`): the checker now
recursively reports `.rs` files under each local baseline root that contain
public declarations or methods but are neither scanned nor explicitly ignored.
S4-M307 refreshes the S4-M11 blocker audit
(`compare/results/s4-m307-blocker-refresh.md`): current runtime command
availability still lacks QEMU/Wine/wasmtime/wasmer runners, `zig build
surfacecheck` passes with the hardened local public-surface scan, and no new
unblocked local `rand` / `rand_distr` public-surface gap is identified.
S4-M308 adds a README discovery guard
(`compare/results/s4-m308-readme-surfacecheck-guard.md`) so `zig build
readmecheck` requires the `zig build surfacecheck` command to stay visible with
the other validation/local-comparison commands.
S4-M309 adds focused unit tests for `surfacecheck` token matching
(`compare/results/s4-m309-surfacecheck-token-tests.md`), covering exact
backtick-wrapped tokens, identifier-boundary matches, short-token false-positive
rejection, and scoped/phrase fallback behavior.
S4-M310 wires those tests into `zig build surfacecheck`
(`compare/results/s4-m310-surfacecheck-build-tests.md`), so the local
public-surface checker validates its token-matching helpers before running the
source/manifest drift scan.
S4-M311 makes `toolingcheck` enforce that surfacecheck dependency shape
(`compare/results/s4-m311-toolingcheck-surfacecheck-deps.md`), ensuring the
helper tests remain wired before the checker executable in future build changes.
S4-M312 adds focused tests for `surfacecheck` public-file guard helpers
(`compare/results/s4-m312-surfacecheck-public-file-tests.md`), covering scanned
file recognition, explicit private-helper ignores, public-looking lines,
`pub(crate)` non-public helpers, and comments.
S4-M313 makes `surfacecheck` default local baseline roots HOME-relative
(`compare/results/s4-m313-surfacecheck-home-roots.md`) while preserving
`ALEA_RAND_ROOT`, `ALEA_RAND_CORE_ROOT`, and `ALEA_RAND_DISTR_ROOT` overrides,
so the local comparison checker is less tied to one absolute home directory.
S4-M314 adds focused tests for that root-resolution helper
(`compare/results/s4-m314-surfacecheck-root-tests.md`), covering `$HOME` suffix
resolution and fallback behavior.
S4-M315 hardens `roadmapcheck`
(`compare/results/s4-m315-roadmapcheck-surface-blocker.md`) so the S4-M11
blocker audit must continue to mention the current `surfacecheck` coverage and
the absence of a new unblocked public-surface gap.
S4-M316 adds a stale-ignore guard to `surfacecheck`
(`compare/results/s4-m316-surfacecheck-ignore-guard.md`), validating that
explicitly ignored public-looking helper files still exist and still contain
public-looking lines.
S4-M317 adds `zig build validate-local`
(`compare/results/s4-m317-validate-local.md`) as a Linux-first aggregate for
native validation plus the local `rand` / `rand_core` / `rand_distr`
public-surface drift checker.
S4-M318 normalizes the `validate-local` evidence
(`compare/results/s4-m318-validate-local-evidence.md`) so the generic feature
command and the actual ReleaseFast validation run are recorded separately.
S4-M319 adds `zig build validate-local` to the S4-M11 blocker audit and
`roadmapcheck` required tokens
(`compare/results/s4-m319-roadmapcheck-validate-local-blocker.md`), keeping the
local aggregate validation entry point tied to blocker evidence.
S4-M320 updates the roadmap Current Rule
(`compare/results/s4-m320-current-rule-validate-local.md`) so changes affecting
local `rand` / `rand_distr` comparison workflows or public-surface evidence use
`zig build validate-local`.
S4-M321 adds `zig build runtimecheck`
(`compare/results/s4-m321-runtimecheck.md`) to automate S4-M11 runtime-runner
availability checks and fail when a new QEMU/Wine/wasmtime/wasmer runner becomes
available for broader validation.
S4-M322 adds focused tests for runtimecheck executable discovery
(`compare/results/s4-m322-runtimecheck-tests.md`) and wires them into
`zig build runtimecheck`.
S4-M323 hardens `roadmapcheck`
(`compare/results/s4-m323-roadmapcheck-runtime-ok.md`) so the S4-M11 blocker
audit must retain the current `runtimecheck ok: no additional runtime runner
available` conclusion.
S4-M324 synchronizes the original `validate-local` evidence
(`compare/results/s4-m324-validate-local-runtime-evidence.md`) with the later
runtimecheck dependency, keeping the aggregate validation documentation accurate.
S4-M325 adds focused decision tests for `runtimecheck`
(`compare/results/s4-m325-runtimecheck-decision-tests.md`), covering pass,
missing-required, opportunity-runner, and missing-required-priority outcomes.
S4-M326 documents the runtimecheck runner sets in the tooling catalog
(`compare/results/s4-m326-runtimecheck-docs.md`) and guards those docs with
`toolingcheck`.
S4-M327 adds runtimecheck summary counts
(`compare/results/s4-m327-runtimecheck-summary.md`) and records the current
required/opportunity counts in S4-M11 blocker evidence.
S4-M328 strengthens runtimecheck documentation guards
(`compare/results/s4-m328-runtimecheck-doc-token-guard.md`) so `toolingcheck`
requires all required and opportunity runner names to remain visible in
`docs/tooling.md`.
S4-M329 syncs the original runtimecheck evidence
(`compare/results/s4-m329-runtimecheck-evidence-sync.md`) with the current
summary-count output added after S4-M327.
S4-M330 syncs `docs/core-guide.md`
(`compare/results/s4-m330-core-guide-runtimecheck.md`) with the exact
runtimecheck required and opportunity runner lists.
S4-M331 adds focused runtimecheck coverage
(`compare/results/s4-m331-runtimecheck-empty-path.md`) for POSIX-style empty
`PATH` segments resolving to the current directory.
S4-M332 documents `validate-local` usage in README prose
(`compare/results/s4-m332-readme-validate-local-prose.md`) and guards the
explanation with `readmecheck`.
S4-M333 expands runtimecheck opportunity-runner detection
(`compare/results/s4-m333-runtimecheck-static-qemu.md`) to include static QEMU
binary names (`qemu-aarch64-static`, `qemu-riscv64-static`, and
`qemu-x86_64-static`), with current opportunity count remaining zero found.

S4-M334 hardens example validation
(`compare/results/s4-m334-example-aggregate-guard.md`) by making `examplecheck`
verify that every cataloged runnable example remains wired into the aggregate
`zig build examples` step used by `zig build validate`. This improves adoption
and validation ergonomics while S4-M11 remains blocked.

S4-M335 hardens the native validation aggregate
(`compare/results/s4-m335-validate-dependency-guard.md`) by making
`toolingcheck` verify all current `zig build validate` dependency tokens: unit
tests, examples, doccheck, statcheck, distcheck, distcheck-libc, and accepted
profilecheck. This improves validation ergonomics while S4-M11 remains blocked.

S4-M336 hardens the broad validation aggregate
(`compare/results/s4-m336-validate-all-dependency-guard.md`) by making
`toolingcheck` verify all current `zig build validate-all` dependency tokens:
native validation, crosscheck, test-wasi, and wasi-report. This improves
portability validation ergonomics while S4-M11 remains blocked.

S4-M337 hardens the WASI report chain
(`compare/results/s4-m337-wasi-report-chain-guard.md`) by making `toolingcheck`
verify the chained repro, statcheck, distcheck, profilecheck, tail, stress, and
long-profile WASI dependency tokens plus the no-Node failure path. This improves
portability evidence ergonomics while S4-M11 remains blocked.

S4-M338 documents `validate-all` usage in README prose
(`compare/results/s4-m338-readme-validate-all-prose.md`) and guards the
portability-sensitive aggregate explanation with `readmecheck`, making the broad
native-plus-cross/WASI validation path easier to discover while S4-M11 remains
blocked.

S4-M339 documents validation aggregate selection in the core guide
(`compare/results/s4-m339-core-guide-validation-prose.md`) and guards the
`validate` / `validate-local` / `validate-all` guidance with `toolingcheck`, so
users can choose the right native, local-comparison, or portability-sensitive
validation path while S4-M11 remains blocked.

S4-M340 documents validation aggregate selection in the API reference
(`compare/results/s4-m340-api-reference-validation-prose.md`) and guards the API
`validate` / `validate-local` / `validate-all` guidance with `toolingcheck`, so
API work can choose the right native, local-comparison, or portability-sensitive
validation path while S4-M11 remains blocked.

S4-M341 hardens active-goal completion criteria evidence
(`compare/results/s4-m341-active-completion-criteria-guard.md`) by making
`roadmapcheck` verify the active audit's Required Next Work section, including
the exact/default dense SIMD candidate criterion, scalar lane-fill comparison,
rejected-lane stream-shape requirement, later-roadmap-audit escape clause, and
no-completion warning while S4-M11 remains blocked.

S4-M342 hardens the roadmap Current Rule
(`compare/results/s4-m342-current-rule-guard.md`) by making `roadmapcheck`
verify concrete prioritization and validation guidance for earliest unblocked
work, blocker evidence, `validate`, `validate-local`, public-surface/local
`rand` evidence, `statcheck`, `stream`, and deferred micro-optimization while
S4-M11 remains blocked.

S4-M343 hardens long-term product-track evidence
(`compare/results/s4-m343-long-term-track-guard.md`) by making `roadmapcheck`
verify the roadmap's Long-Term Product Tracks section, non-completion framing,
feature breadth, statistical confidence, performance, ergonomics, and portability
pressure tokens while S4-M11 remains blocked.

S4-M344 adds roadmapcheck helper tests
(`compare/results/s4-m344-roadmapcheck-helper-tests.md`) and wires them into
`zig build roadmapcheck`, with `toolingcheck` guarding that tests run before the
roadmap/audit executable. This improves evidence-checker reliability while
S4-M11 remains blocked.

S4-M345 adds toolingcheck helper tests
(`compare/results/s4-m345-toolingcheck-helper-tests.md`) and wires them into
`zig build toolingcheck`, with `toolingcheck` guarding that tests run before its
executable audit. This improves tooling-catalog checker reliability while S4-M11
remains blocked.

S4-M346 adds apicheck helper tests
(`compare/results/s4-m346-apicheck-helper-tests.md`) and wires them into
`zig build apicheck`, with `toolingcheck` guarding that tests run before the API
coverage executable. This improves API-reference checker reliability while
S4-M11 remains blocked.

S4-M347 adds examplecheck helper tests
(`compare/results/s4-m347-examplecheck-helper-tests.md`) and wires them into
`zig build examplecheck`, with `toolingcheck` guarding that tests run before the
examples-catalog executable. This improves examples-catalog checker reliability
while S4-M11 remains blocked.

S4-M348 adds readmecheck helper tests
(`compare/results/s4-m348-readmecheck-helper-tests.md`) and wires them into
`zig build readmecheck`, with `toolingcheck` guarding that tests run before the
README discovery executable. This improves README checker reliability while
S4-M11 remains blocked.

S4-M349 adds statcheck helper tests
(`compare/results/s4-m349-statcheck-helper-tests.md`) and wires them into
`zig build statcheck`, with `toolingcheck` guarding that tests run before the
statistical smoke-check executable. This improves statistical checker reliability
while S4-M11 remains blocked.

S4-M350 adds distcheck helper tests
(`compare/results/s4-m350-distcheck-helper-tests.md`) and wires them into
`zig build distcheck` and `zig build distcheck-libc`, with `toolingcheck`
guarding that tests run before the distribution-grid executables. This improves
distribution checker reliability while S4-M11 remains blocked.

S4-M351 adds profilecheck helper tests
(`compare/results/s4-m351-profilecheck-helper-tests.md`) and wires them into
`zig build profilecheck`, with `toolingcheck` guarding that tests run before the
accepted vector-profile executable. This improves profile checker reliability
while S4-M11 remains blocked.

S4-M352 adds profiletailcheck helper tests
(`compare/results/s4-m352-profiletailcheck-helper-tests.md`) and wires them into
`zig build profilecheck-tail`, with `toolingcheck` guarding that tests run before
the accepted vector-profile tail executable. This improves tail checker
reliability while S4-M11 remains blocked.

S4-M353 adds profilestresscheck helper tests
(`compare/results/s4-m353-profilestresscheck-helper-tests.md`), removes duplicate
exponential aggregate-count accumulation in the stress checker, and wires tests
into `zig build profilecheck-stress`, with `toolingcheck` guarding that tests run
before the accepted vector-profile stress executable. This improves stress
checker reliability while S4-M11 remains blocked.

S4-M354 adds profilelongcheck helper tests
(`compare/results/s4-m354-profilelongcheck-helper-tests.md`) and wires them into
`zig build profilecheck-long`, with `toolingcheck` guarding that tests run before
the accepted vector-profile long-sweep executable. This improves long-sweep
checker reliability while S4-M11 remains blocked.

S4-M355 adds stream helper tests
(`compare/results/s4-m355-stream-helper-tests.md`) and wires them into
`zig build stream`, with `toolingcheck` guarding that tests run before raw RNG
bytes are emitted. This improves raw stream exporter reliability while S4-M11
remains blocked.

S4-M356 adds repro helper tests
(`compare/results/s4-m356-repro-helper-tests.md`) and wires them into
`zig build repro`, with `toolingcheck` guarding that tests run before deterministic
snapshot output. This improves reproducibility snapshot reliability while S4-M11
remains blocked.

S4-M357 adds PractRand wrapper dry-run support
(`compare/results/s4-m357-practrand-dry-run.md`), allowing the exact
`zig build stream | RNG_test stdin64` pipeline to be validated without requiring
PractRand and documenting `PRACTRAND_BIN` for alternate executable names. This
improves external statistical evidence ergonomics while S4-M11 remains blocked.

S4-M358 adds a PractRand dry-run build step
(`compare/results/s4-m358-practrand-dry-run-step.md`) so `zig build
practrand-dry-run` prints the default `zig build stream | RNG_test stdin64`
pipeline without requiring PractRand. This improves external statistical
evidence discoverability while S4-M11 remains blocked.

S4-M359 strengthens README PractRand dry-run discovery
(`compare/results/s4-m359-readme-practrand-dry-run-guard.md`) by making
`readmecheck` require README tokens for `tools/practrand.sh --dry-run`,
`zig build practrand-dry-run`, and `PRACTRAND_BIN`. This improves external
statistical evidence discoverability while S4-M11 remains blocked.

S4-M360 strengthens core-guide and API-reference PractRand dry-run discovery
(`compare/results/s4-m360-guide-api-practrand-guards.md`) by making
`toolingcheck` require the dry-run script command, `zig build practrand-dry-run`,
and `PRACTRAND_BIN` guidance in the relevant docs. This improves external
statistical evidence discoverability while S4-M11 remains blocked.

S4-M361 adds a shell-tool executable-bit guard
(`compare/results/s4-m361-shell-tool-executable-guard.md`) by making
`toolingcheck` require executable access for checked-in `.sh` tools such as
`tools/practrand.sh`, protecting script-backed build steps while S4-M11 remains
blocked.

S4-M362 adds Node WASI runner dry-run support
(`compare/results/s4-m362-wasi-runner-dry-run.md`) so WASI argv handling can be
validated without reading or executing a wasm file, and guards those runner tokens
with `toolingcheck`. This improves WASI validation ergonomics while S4-M11
remains blocked.

S4-M363 adds a WASI dry-run build step
(`compare/results/s4-m363-wasi-dry-run-step.md`) so `zig build wasi-dry-run`
exercises `tools/run_wasi_test.js --dry-run sample.wasm --flag` without reading
or executing wasm. This improves WASI validation discoverability while S4-M11
remains blocked.

S4-M364 strengthens README WASI dry-run discovery
(`compare/results/s4-m364-readme-wasi-dry-run-guard.md`) by making
`readmecheck` require the `zig build wasi-dry-run` command in README. This
improves portability validation discoverability while S4-M11 remains blocked.

S4-M365 documents WASI dry-run usage in the core guide
(`compare/results/s4-m365-core-guide-wasi-dry-run.md`) and guards the
`zig build wasi-dry-run` / Node runner dry-run guidance with `toolingcheck`,
improving portability validation discoverability while S4-M11 remains blocked.

S4-M366 documents WASI dry-run usage in README prose
(`compare/results/s4-m366-readme-wasi-dry-run-prose.md`) and guards the
`zig build wasi-dry-run` no-wasm-execution explanation with `readmecheck`,
improving portability validation discoverability while S4-M11 remains blocked.

S4-M367 strengthens tooling-catalog WASI dry-run prose
(`compare/results/s4-m367-tooling-wasi-dry-run-prose.md`) by making
`toolingcheck` require the Node WASI dry-run command and no-read/no-execute
explanation in `docs/tooling.md`, improving portability validation discoverability
while S4-M11 remains blocked.

S4-M368 documents WASI dry-run usage in the API reference
(`compare/results/s4-m368-api-wasi-dry-run-prose.md`) and guards the
`zig build wasi-dry-run` / Node runner dry-run no-wasm-execution explanation with
`toolingcheck`, improving portability validation discoverability while S4-M11
remains blocked.

S4-M369 documents and guards the crosscheck target set
(`compare/results/s4-m369-crosscheck-target-guard.md`) by making `toolingcheck`
verify `wasm32-wasi`, `aarch64-linux`, `riscv64-linux`, `x86_64-windows`,
`x86_64-macos`, and `aarch64-macos` in both `build.zig` and `docs/tooling.md`,
protecting portability compile coverage while S4-M11 remains blocked.

S4-M370 documents the exact crosscheck target set in README
(`compare/results/s4-m370-readme-crosscheck-targets.md`) and guards the target
list plus no-execute guidance with `readmecheck`, improving portability compile
coverage discoverability while S4-M11 remains blocked.

S4-M371 fixes wasm32 crosscheck test portability
(`compare/results/s4-m371-crosscheck-wasm32-usize.md`) by gating `u32.max + 1`
invalid-length tests to targets where `usize` is wider than 32 bits. `zig build
crosscheck` now passes for the documented target set while S4-M11 remains
blocked.

S4-M372 records full `validate-all` evidence after the crosscheck fix
(`compare/results/s4-m372-validate-all-after-crosscheck.md`). The aggregate
passed after S4-M371, covering native validation, crosscheck, test-wasi, and the
chained WASI report while S4-M11 remains blocked.

S4-M373 refreshes current `validate-local` evidence
(`compare/results/s4-m373-validate-local-refresh.md`). The aggregate passed,
covering native validation, local `rand` / `rand_core` / `rand_distr`
`surfacecheck`, and runtimecheck with current opportunity summary
`required found=3 missing=0; opportunities found=0 missing=10` while S4-M11
remains blocked.

S4-M374 documents the exact crosscheck target set in the API reference
(`compare/results/s4-m374-api-crosscheck-targets.md`) and guards the target list
plus no-execute guidance with `toolingcheck`, improving portability compile
coverage discoverability while S4-M11 remains blocked.

S4-M375 documents the exact crosscheck target set in the core guide
(`compare/results/s4-m375-core-guide-crosscheck-targets.md`) and guards the
target list plus no-execute guidance with `toolingcheck`, improving portability
compile coverage discoverability while S4-M11 remains blocked.

S4-M376 guards WASI runner file inputs
(`compare/results/s4-m376-wasi-runner-file-input-guard.md`) by making
`toolingcheck` require `tools/run_wasi_test.js` to be registered as an input for
WASI test, dry-run, and report tool build steps, improving rebuild reliability
while S4-M11 remains blocked.

S4-M377 improves vectorbench filter ergonomics
(`compare/results/s4-m377-vectorbench-filter-args.md`) by making filter-only
arguments work like the main throughput benchmark and by wiring parser tests into
`zig build vectorbench`, improving focused SIMD evidence collection while S4-M11
remains blocked.

S4-M378 adds helper-tested argument parsing for the main throughput benchmark
(`compare/results/s4-m378-bench-parser-tests.md`) and wires tests into
`zig build bench`, improving focused performance evidence ergonomics while S4-M11
remains blocked.

S4-M379 wires throughput parser helper tests into `bench-libc`
(`compare/results/s4-m379-bench-libc-parser-tests.md`), improving libc-linked
benchmark argument reliability for focused performance evidence while S4-M11
remains blocked.

S4-M380 adds helper-tested argument parsing to the Rust comparison benchmark
(`compare/results/s4-m380-rand-bench-parser-tests.md`) and wires `zig build
rand-bench-test` into `validate-local`, improving local `rand` / `rand_distr`
comparison benchmark reliability while S4-M11 remains blocked.

S4-M381 adds a tiny filtered Rust comparison benchmark smoke step
(`compare/results/s4-m381-rand-bench-smoke.md`) and wires `zig build
rand-bench-smoke` into `validate-local`, improving end-to-end local Rust
comparison benchmark reliability while S4-M11 remains blocked.

S4-M382 adds a dry-run preview for the Rust comparison smoke wrapper
(`compare/results/s4-m382-rand-bench-smoke-dry-run.md`) so local comparison
command shape can be checked without running cargo while S4-M11 remains blocked.

S4-M383 adds no-cargo self-tests for the Rust comparison smoke wrapper
(`compare/results/s4-m383-rand-bench-smoke-self-test.md`) so default, filter-only,
count-plus-filter, and invalid filter-only dry-run argument paths are guarded
while S4-M11 remains blocked.

S4-M384 guards Rust comparison smoke wrapper env overrides
(`compare/results/s4-m384-rand-bench-smoke-env-overrides.md`) so
`ALEA_RAND_BENCH_MANIFEST` and `ALEA_RAND_BENCH_EXPECTED_ROW` custom local
comparison paths are self-tested and documented while S4-M11 remains blocked.

S4-M385 synchronizes S4-M11 blocker evidence
(`compare/results/s4-m385-blocker-benchmark-gates.md`) with the current Rust
comparison benchmark gates in `validate-local`, so blocker audits retain
`rand-bench-test`, `rand-bench-smoke`, `rand-bench-smoke-self-test`, and smoke
override coverage while S4-M11 remains blocked.

S4-M386 adds PractRand wrapper self-tests
(`compare/results/s4-m386-practrand-self-test.md`) so default dry-run, custom
`PRACTRAND_BIN`, and invalid argument-count handling are validated without
`RNG_test` while S4-M11 remains blocked.

S4-M387 adds Node WASI runner self-tests
(`compare/results/s4-m387-wasi-runner-self-test.md`) so dry-run argv output and
missing-argument usage diagnostics are validated without reading or executing
wasm while S4-M11 remains blocked.

S4-M388 expands `validate-all` WASI coverage
(`compare/results/s4-m388-validate-all-wasi-self-test.md`) so the aggregate now
includes `wasi-dry-run` and `wasi-self-test` alongside WASI unit execution and
the report chain while S4-M11 remains blocked.

S4-M389 refreshes expanded `validate-all` evidence
(`compare/results/s4-m389-validate-all-refresh.md`). The aggregate passed with
native validation, crosscheck, `test-wasi`, `wasi-dry-run`, `wasi-self-test`, and
the chained WASI report while S4-M11 remains blocked.

S4-M390 guards PractRand wrapper file inputs
(`compare/results/s4-m390-practrand-file-input-guard.md`) so `practrand-dry-run`
and `practrand-self-test` rebuild when `tools/practrand.sh` changes while S4-M11
remains blocked.

S4-M391 adds PractRand wrapper self-tests to native validation
(`compare/results/s4-m391-validate-practrand-self-test.md`) so broad native
validation exercises no-external PractRand wrapper command construction while
S4-M11 remains blocked.

S4-M392 refreshes native validation evidence
(`compare/results/s4-m392-validate-practrand-refresh.md`). `zig build validate`
passed after adding `practrand-self-test`, proving broad native validation now
includes the no-external PractRand wrapper check while S4-M11 remains blocked.

S4-M393 guards validation build-step descriptions
(`compare/results/s4-m393-validation-description-guard.md`) so `validate`,
`validate-local`, and `validate-all` descriptions keep matching their expanded
dependency scopes while S4-M11 remains blocked.

S4-M394 guards `zig build test` tooling documentation
(`compare/results/s4-m394-test-doccheck-description.md`) so the tooling catalog
reflects its full `doccheck` dependency while S4-M11 remains blocked.

S4-M395 guards `validate-all` tooling-row precision
(`compare/results/s4-m395-validate-all-tooling-row.md`) so the tooling catalog
keeps WASI unit execution, dry/self tests, and report-chain coverage visible
while S4-M11 remains blocked.

S4-M396 guards README validate/PractRand prose
(`compare/results/s4-m396-readme-validate-practrand-guard.md`) so README keeps
the no-external PractRand wrapper self-test visible in broad native validation
while S4-M11 remains blocked.

S4-M397 guards API reference validate/PractRand prose
(`compare/results/s4-m397-api-validate-practrand-guard.md`) so API docs keep
no-external PractRand wrapper validation visible while S4-M11 remains blocked.

S4-M398 guards `validate` tooling-row precision
(`compare/results/s4-m398-validate-tooling-row.md`) so the tooling catalog keeps
native unit/example/catalog/API/statistical/distribution/libc/profile and
no-external PractRand wrapper self-test coverage visible while S4-M11 remains
blocked.

S4-M399 guards README `validate-local` smoke coverage
(`compare/results/s4-m399-readme-validate-local-smoke-guard.md`) so README keeps
Rust comparison smoke/self-test, surfacecheck, and runtimecheck coverage visible
while S4-M11 remains blocked.

S4-M400 makes wrapper self-test temp files safe
(`compare/results/s4-m400-wrapper-self-test-tempfiles.md`) by switching
PractRand and Rust comparison smoke wrapper diagnostics to `mktemp` plus trap
cleanup while S4-M11 remains blocked.
