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
| integer, float, bool, range, owned bounded-uint, owned scalar/vector half-open and inclusive range, scalar/vector strict-interval, scalar/vector probability, scalar/vector standard-or-parameterized normal/exponential, and duration batches, ratio/chance, caller-owned and allocation-returning bytes | Covered | `Rng`, `Rng.uintLessThanBatch`, `Rng.uintAtMostBatch`, `Rng.rangeBatch`, `Rng.rangeAtMostBatch`, `Rng.vectorRangeBatch`, `Rng.vectorRangeAtMostBatch`, `Rng.openBatch`, `Rng.openClosedBatch`, `Rng.vectorOpenBatch`, `Rng.vectorOpenClosedBatch`, `Rng.chanceBatch`, `Rng.ratioBatch`, `Rng.vectorChanceBatch`, `Rng.vectorRatioBatch`, `Rng.standardNormalBatch`, `Rng.normalBatch`, `Rng.standardExponentialBatch`, `Rng.exponentialBatch`, `Rng.vectorStandardNormalBatch`, `Rng.vectorNormalBatch`, `Rng.vectorStandardExponentialBatch`, `Rng.vectorExponentialBatch`, `Rng.bytesAlloc`, unit tests, Zig/Rust benchmark rows |
| arrays, tuples, enums | Covered | `Rng.value(T)`, `Rng.valueBatch(T)`, and checked empty-enum tests |
| Unicode scalar / char-like sampling | Covered in Zig form | `Rng.unicodeScalar`, `Rng.unicodeScalarRangeLessThan`, `Rng.unicodeScalarRangeAtMost`, `Rng.fillUnicodeScalar`, `Rng.fillUnicodeScalarRangeLessThan`, `Rng.fillUnicodeScalarRangeAtMost`, `Rng.unicodeScalarBatch`, `Rng.unicodeScalarRangeLessThanBatch`, `Rng.unicodeScalarRangeAtMostBatch`, `ascii.unicodeUtf8Alloc`, `ascii.unicodeUtf8Into` |
| durations | Covered in Zig form | `durationRangeLessThan`, `durationRangeAtMost`, and owned duration range batches |
| strings / alphanumeric | Covered | `ascii` module, Rust alphanumeric benchmark row |
| choose, shuffle, sample indices, fixed-size slice samples, reservoir fills | Covered | `Rng.chooseIndex`, `Rng.chooseIndexArray`, `Rng.chooseIndexBatch`, `Rng.chooseIndexU32`, `Rng.chooseIndexArrayU32`, `Rng.chooseIndexU32Batch`, `Rng.choose`, `Rng.chooseValueArray`, `Rng.chooseBatch`, `Rng.chooseConstPtr`, `Rng.chooseConstPtrArray`, `Rng.chooseConstPtrBatch`, `Rng.choosePtr`, `Rng.choosePtrArray`, `Rng.choosePtrBatch`, `seq.chooseIndex`, `seq.chooseIndexArray`, `seq.fillChooseIndex`, `seq.chooseIndexBatch`, `seq.chooseIndexU32`, `seq.chooseIndexArrayU32`, `seq.fillChooseIndexU32`, `seq.chooseIndexU32Batch`, `seq.choose`, `seq.chooseConstPtr`, `seq.choosePtr`, `seq.chooseRepeatedValueArray`, `seq.chooseRepeatedConstPtrArray`, `seq.chooseRepeatedPtrArray`, `seq.fillChoose`, `seq.fillChooseConstPtr`, `seq.fillChoosePtr`, `seq.chooseBatch`, `seq.chooseConstPtrBatch`, `seq.choosePtrBatch`, `seq` module, `seq.shuffle`, `seq.shuffleFrom`, `sampleArrayU32`, `chooseArray`, `choosePtrArray`, `chooseMultiple`, `chooseMultiplePtrs`, `chooseMultipleInto`, `chooseMultiplePtrsInto`, `seq.sampleItems`, `seq.sampleItemsIter`, `seq.sampleItemsInto`, `seq.sampleItemsArray`, `seq.samplePtrArray`, `seq.sampleMutPtrArray`, `seq.samplePtrs`, `seq.samplePtrsIter`, `seq.samplePtrsInto`, `seq.sampleMutPtrs`, `seq.sampleMutPtrsIter`, `seq.sampleMutPtrsInto`, `seq.chooseIteratorStable`, `seq.sampleIteratorFill`, `Choice.numChoices`, `Choice.item`, `Choice.get`, `Choice.ProbabilityIterator.sizeHint`, `Choice.sampleIndex`, `Choice.fill`, `Choice.fillValues`, `Choice.ptrs`, `Choice.values`, `Choice.valueArray`, `Choice.ptrArray`, `Choice.fillIndices`, `Choice.indices`, `Choice.indexArray`, `Choice.indexArrayU32`, `Choice.indexIter`, `Choice.indexIterU32`, `reservoirSample`, `reservoirSamplePtrs`, `reservoirSampleInto`, `reservoirSamplePtrsInto`, `IndexVec` owned-backing adoption, representation-preserving deep clone, consuming index iteration, lazy/caller-owned/allocation-returning/consuming value/const-pointer/mutable-pointer and u32 export mapping plus cross-backing content equality, Rust sequence benchmark row |
| weighted index and weighted item choice | Covered | `Rng.weightedIndex`, `Rng.weightedIndexBatch`, `Rng.weightedIndexArray`, `Rng.weightedIndexU32`, `Rng.weightedIndexU32Batch`, `Rng.weightedIndexU32Array`, `Rng.chooseWeighted`, `Rng.chooseWeightedBatch`, `Rng.chooseWeightedValueArray`, `Rng.chooseWeightedConstPtr`, `Rng.chooseWeightedConstPtrBatch`, `Rng.chooseWeightedConstPtrArray`, `Rng.chooseWeightedPtr`, `Rng.chooseWeightedPtrBatch`, `Rng.chooseWeightedPtrArray`, `seq.weightedIndex`, `seq.weightedIndexBatch`, `seq.weightedIndexArray`, `seq.weightedIndexU32`, `seq.weightedIndexU32Batch`, `seq.weightedIndexU32Array`, `seq.chooseWeighted`, `seq.weightedIndexBy`, `seq.weightedIndexArrayBy`, `seq.weightedIndexU32By`, `seq.weightedIndexU32ArrayBy`, `seq.fillWeightedIndexBy`, `seq.fillWeightedIndexU32By`, `seq.weightedIndexBatchBy`, `seq.weightedIndexU32BatchBy`, `seq.chooseWeightedBy`, `seq.chooseWeightedValueArrayBy`, `seq.fillChooseWeightedBy`, `seq.chooseWeightedBatchBy`, `seq.chooseWeightedBatch`, `seq.chooseWeightedValueArray`, `seq.chooseWeightedConstPtr`, `seq.chooseWeightedConstPtrBy`, `seq.chooseWeightedConstPtrArrayBy`, `seq.fillChooseWeightedConstPtrBy`, `seq.chooseWeightedConstPtrBatchBy`, `seq.chooseWeightedConstPtrBatch`, `seq.chooseWeightedConstPtrArray`, `seq.chooseWeightedPtr`, `seq.chooseWeightedPtrBy`, `seq.chooseWeightedPtrArrayBy`, `seq.fillChooseWeightedPtrBy`, `seq.chooseWeightedPtrBatchBy`, `seq.chooseWeightedPtrBatch`, `seq.chooseWeightedPtrArray`, `seq.weightedIndexByIndex`, `seq.weightedIndexU32ByIndex`, `seq.weightedIndexArrayByIndex`, `seq.weightedIndexU32ArrayByIndex`, `seq.fillWeightedIndexByIndex`, `seq.fillWeightedIndexU32ByIndex`, `seq.weightedIndexBatchByIndex`, `seq.weightedIndexU32BatchByIndex`, `seq.chooseWeightedByIndex`, `seq.chooseWeightedValueArrayByIndex`, `seq.chooseWeightedConstPtrByIndex`, `seq.chooseWeightedConstPtrArrayByIndex`, `seq.chooseWeightedPtrByIndex`, `seq.chooseWeightedPtrArrayByIndex`, `seq.fillChooseWeightedByIndex`, `seq.fillChooseWeightedConstPtrByIndex`, `seq.fillChooseWeightedPtrByIndex`, `seq.chooseWeightedBatchByIndex`, `seq.chooseWeightedConstPtrBatchByIndex`, `seq.chooseWeightedPtrBatchByIndex`, `seq.sampleWeightedIndexArrayBy`, `seq.sampleWeightedIndexArrayU32By`, `seq.sampleWeightedArrayBy`, `seq.sampleWeightedPtrArrayBy`, `seq.sampleWeightedMutPtrArrayBy`, `seq.sampleWeightedIndicesBy`, `seq.sampleWeightedIndicesU32By`, `seq.sampleWeightedIndexVecBy`, `seq.sampleWeightedIndicesByIndex`, `seq.sampleWeightedIndicesU32ByIndex`, `seq.sampleWeightedIndexVecByIndex`, `seq.sampleWeightedIndicesByIndexInto`, `seq.sampleWeightedIndicesU32ByIndexInto`, `seq.sampleWeightedIndexArrayByIndex`, `seq.sampleWeightedIndexArrayU32ByIndex`, `seq.sampleWeightedBy`, `seq.sampleWeightedPtrsBy`, `seq.sampleWeightedMutPtrsBy`, `seq.sampleWeightedIndicesByInto`, `seq.sampleWeightedByInto`, `seq.sampleWeightedPtrsByInto`, `seq.sampleWeightedMutPtrsByInto`, `seq.sampleWeightedIndicesInto`, `seq.sampleWeightedIndicesU32`, `seq.sampleWeightedIndicesU32Into`, `seq.sampleWeightedIndexVec`, `seq.sampleWeightedInto`, `seq.sampleWeightedPtrs`, `seq.sampleWeightedPtrsInto`, `seq.sampleWeightedIndexArray`, `seq.sampleWeightedIndexArrayU32`, `seq.sampleWeightedArray`, `seq.sampleWeightedPtrArray`, `AliasTable`, `AliasTable.initBy`, `AliasTable.updateBy`, `AliasTable.initByIndex`, `AliasTable.updateByIndex`, `AliasTable.numChoices`, `AliasTable.WeightIterator.sizeHint`, `AliasTable.ProbabilityIterator.sizeHint`, `AliasTable.sampleIndex`, `AliasTable.fillIndices`, `AliasTable.sampleU32`, `AliasTable.fillU32`, `AliasTable.indices`, `AliasTable.indicesU32`, `AliasTable.indexArray`, `AliasTable.indexArrayU32`, `AliasTable.iter`, `AliasTable.iterU32`, `WeightedChoice.initBy`, `WeightedChoice.updateBy`, `WeightedChoice.initByIndex`, `WeightedChoice.updateByIndex`, `WeightedChoice.numChoices`, `WeightedChoice.constantIndex`, `WeightedChoice.item`, `WeightedChoice.get`, `WeightedChoice.weightIter().sizeHint`, `WeightedChoice.probabilityIter().sizeHint`, `WeightedChoice.sample`, `WeightedChoice.ptrs`, `WeightedChoice.values`, `WeightedChoice.valueArray`, `WeightedChoice.ptrArray`, `WeightedChoice.iter`, `WeightedChoice.ownedIter`, `seq.chooseWeightedIter`, `seq.chooseWeightedIterBy`, `seq.chooseWeightedIterByIndex`, `WeightedChoice.sampleIndex`, `WeightedChoice.fillIndices`, `WeightedChoice.indices`, `WeightedChoice.indexArray`, `WeightedChoice.indexArrayU32`, `WeightedChoice.indexIter`, `WeightedChoice.indexIterU32`, `WeightedTree`, `WeightedTree.numChoices`, `WeightedTree.constantIndex`, `WeightedTree.initBy`, `WeightedTree.updateAllBy`, `WeightedTree.initByIndex`, `WeightedTree.updateAllByIndex`, `WeightedTree.weight`, `WeightedTree.weightIter`, `WeightedTree.probability`, `WeightedTree.probabilityIter`, `WeightedTree.sampleIndex`, `WeightedTree.fillIndices`, `WeightedTree.sampleU32`, `WeightedTree.fillU32`, `WeightedTree.indices`, `WeightedTree.indicesU32`, `WeightedTree.indexArray`, `WeightedTree.indexArrayU32`, `WeightedTree.iter`, `WeightedTree.iterU32`, `WeightedIntTree.numChoices`, `WeightedIntTree.constantIndex`, `WeightedIntTree.initBy`, `WeightedIntTree.updateAllBy`, `WeightedIntTree.initByIndex`, `WeightedIntTree.updateAllByIndex`, `WeightedIntTree.weight`, `WeightedIntTree.weightIter`, `WeightedIntTree.probability`, `WeightedIntTree.probabilityIter`, `WeightedIntTree.sampleIndex`, `WeightedIntTree.fillIndices`, `WeightedIntTree.sampleU32`, `WeightedIntTree.fillU32`, `WeightedIntTree.indices`, `WeightedIntTree.indicesU32`, `WeightedIntTree.indexArray`, `WeightedIntTree.indexArrayU32`, `WeightedIntTree.iter`, `WeightedIntTree.iterU32`, benchmark rows |

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
| WeightedAliasIndex | `AliasTable(Weight)`, including `initBy` / `updateBy` item-accessor helpers, `initByIndex` / `updateByIndex` index-accessor helpers, `sampleIndex` / `fillIndices` aliases, compact `sampleU32` / `fillU32` output, owned `indices` / `indicesU32` batches, fixed-size `indexArray` / `indexArrayU32` output, and repeated `iter` / `iterU32` index streams | unit tests, benchmark rows for weighted index paths; f32, f64, and u32 `WeightedAliasIndex` rows are exceeded by `AliasTable` evidence |
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
index/u32-index batches, S4-M151 adds `sampleIndex` / `fillIndices` dynamic tree aliases, S4-M152 adds repeated dynamic tree index/u32-index iterators, S4-M153 adds compact `u32` `AliasTable` sample/fill output, S4-M154 adds owned repeated `AliasTable` index/u32-index batches, S4-M155 adds `sampleIndex` / `fillIndices` `AliasTable` aliases, S4-M156 adds repeated `AliasTable` index/u32-index iterators, S4-M157 adds index-weighted `AliasTable.initByIndex` / `updateByIndex`, S4-M158 adds item-accessor `AliasTable.initBy` / `updateBy`, S4-M159 adds fixed-size `AliasTable` index/u32-index arrays, S4-M160 adds fixed-size dynamic tree index/u32-index arrays, S4-M161 adds fixed-size reusable `WeightedChoice` index/u32-index arrays, S4-M162 adds fixed-size reusable `Choice` index/u32-index arrays, S4-M163 adds fixed-size reusable `Choice` value/pointer arrays, S4-M164 adds fixed-size reusable `WeightedChoice` value/pointer arrays, and S4-M165 adds fixed-size repeated index-choice arrays for `Rng` and `seq`, and S4-M166 adds fixed-size repeated value/pointer choice arrays for `Rng`, and S4-M167 adds fixed-size repeated f64 weighted index/value/pointer arrays for `Rng` (`compare/results/s4-m167-rng-weighted-choice-arrays.md`), and S4-M168 adds fixed-size repeated generic-weight index/value/pointer arrays for `seq` (`compare/results/s4-m168-seq-generic-weighted-choice-arrays.md`), and S4-M169 adds fixed-size repeated item-accessor weighted index/value/pointer arrays for `seq` (`compare/results/s4-m169-accessor-weighted-choice-arrays.md`), and S4-M170 adds fixed-size repeated length/index-weight accessor weighted index/value/pointer arrays for `seq` (`compare/results/s4-m170-index-weighted-choice-arrays.md`), and S4-M171 adds explicit fixed-size repeated value/pointer choice arrays for `seq` (`compare/results/s4-m171-seq-repeated-choice-arrays.md`), and S4-M172 adds reusable `Choice` / `WeightedChoice` repeated index/u32-index iterators (`compare/results/s4-m172-choice-index-iterators.md`), and S4-M173 adds `IndexVec` consuming owned-slice conversions (`compare/results/s4-m173-indexvec-consuming-owned.md`), and S4-M174 adds `IndexVec` content equality (`compare/results/s4-m174-indexvec-equality.md`), and S4-M175 adds `IndexVec` owned backing constructors (`compare/results/s4-m175-indexvec-owned-constructors.md`), and S4-M176 adds `IndexVec` deep clone (`compare/results/s4-m176-indexvec-clone.md`), and S4-M177 adds a consuming `IndexVec` iterator (`compare/results/s4-m177-indexvec-consuming-iterator.md`), and S4-M178 adds repeated weighted choice pointer iterators (`compare/results/s4-m178-weighted-choice-iterators.md`), and S4-M179 adds accessor-weighted repeated pointer iterators (`compare/results/s4-m179-accessor-weighted-choice-iterators.md`), and S4-M180 adds index-weighted repeated pointer iterators (`compare/results/s4-m180-index-weighted-choice-iterators.md`), and S4-M181 adds sampled pointer iterators (`compare/results/s4-m181-sampled-ptr-iterators.md`), and S4-M182 adds sampled value iterators (`compare/results/s4-m182-sampled-value-iterators.md`), and S4-M183 adds sampled mutable-pointer iterators (`compare/results/s4-m183-sampled-mut-ptr-iterators.md`), and S4-M184 adds choice count diagnostics (`compare/results/s4-m184-choice-numchoices.md`), and S4-M185 adds sampled iterator fill helpers (`compare/results/s4-m185-sampled-iterator-fill.md`), and S4-M186 adds exact-size iterator len aliases (`compare/results/s4-m186-iterator-len-aliases.md`), and S4-M187 adds exact-size iterator size hints (`compare/results/s4-m187-iterator-size-hints.md`), and S4-M188 adds IndexVec iterator fill helpers (`compare/results/s4-m188-indexvec-iterator-fill.md`), and S4-M189 adds a Rust-discoverable IndexVec.index alias (`compare/results/s4-m189-indexvec-index-alias.md`), and S4-M190 adds checked IndexVec positional lookup (`compare/results/s4-m190-indexvec-get.md`), and S4-M191 adds optional weighted sampler weight lookup (`compare/results/s4-m191-weighted-sampler-weight.md`), and S4-M192 adds weighted sampler weight iterators (`compare/results/s4-m192-weight-iterators.md`), and S4-M193 adds optional weighted sampler probability lookup (`compare/results/s4-m193-weighted-sampler-probability.md`), and S4-M194 adds weighted sampler probability iterators (`compare/results/s4-m194-probability-iterators.md`), and S4-M195 adds Choice optional probability lookup (`compare/results/s4-m195-choice-probability.md`), and S4-M196 adds a Choice probability iterator (`compare/results/s4-m196-choice-probability-iterator.md`), and S4-M197 adds Charset optional probability lookup (`compare/results/s4-m197-charset-probability.md`), and S4-M198 adds a Charset probability iterator (`compare/results/s4-m198-charset-probability-iterator.md`), and S4-M199 adds reusable choice item lookup (`compare/results/s4-m199-choice-get.md`), and S4-M200 adds Charset optional item lookup (`compare/results/s4-m200-charset-get.md`), and S4-M201 adds diagnostic iterator size hints (`compare/results/s4-m201-diagnostic-iterator-sizehints.md`), and S4-M202 adds Charset count diagnostics (`compare/results/s4-m202-charset-numchoices.md`), and S4-M203 adds reusable choice checked item aliases (`compare/results/s4-m203-choice-item-alias.md`), and S4-M204 adds Charset checked item alias (`compare/results/s4-m204-charset-item-alias.md`), and S4-M205 adds dynamic tree optional weight lookup (`compare/results/s4-m205-tree-weight.md`), and S4-M206 adds dynamic tree optional probability lookup (`compare/results/s4-m206-tree-probability.md`), and S4-M207 adds dynamic tree weight iterators (`compare/results/s4-m207-tree-weight-iterators.md`), and S4-M208 adds dynamic tree probability iterators (`compare/results/s4-m208-tree-probability-iterators.md`), and S4-M209 adds AliasTable count diagnostics (`compare/results/s4-m209-aliastable-numchoices.md`), and S4-M210 adds dynamic tree count diagnostics (`compare/results/s4-m210-tree-numchoices.md`), and S4-M211 adds dynamic tree constant-index diagnostics (`compare/results/s4-m211-tree-constant-index.md`), and S4-M212 adds `WeightedChoice` constant-index diagnostics (`compare/results/s4-m212-weightedchoice-constant-index.md`), but later stages should
keep raising the bar rather than declaring the product permanently finished.
