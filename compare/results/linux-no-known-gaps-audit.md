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

S4-M401 documents Rust comparison smoke self-test usage
(`compare/results/s4-m401-rand-bench-smoke-self-test-usage.md`) so
`tools/rand_bench_smoke.sh --help` exposes `--self-test` and toolingcheck guards
that discoverability while S4-M11 remains blocked.

S4-M402 documents PractRand wrapper self-test usage
(`compare/results/s4-m402-practrand-self-test-usage.md`) so `tools/practrand.sh
--help` explains no-`RNG_test` command-construction validation while S4-M11
remains blocked.

S4-M403 documents WASI runner self-test usage
(`compare/results/s4-m403-wasi-self-test-usage.md`) so `tools/run_wasi_test.js
--help` explains no-wasm dry-run/missing-argument validation while S4-M11
remains blocked.

S4-M404 guards README WASI self-test prose
(`compare/results/s4-m404-readme-wasi-self-test-guard.md`) so README keeps
no-wasm dry-run/missing-argument runner coverage visible while S4-M11 remains
blocked.

S4-M405 guards core-guide/API WASI self-test prose
(`compare/results/s4-m405-guide-api-wasi-self-test-guards.md`) so detailed docs
keep no-wasm dry-run/missing-argument runner coverage visible while S4-M11
remains blocked.

S4-M406 guards tooling-catalog WASI self-test prose
(`compare/results/s4-m406-tooling-wasi-self-test-guard.md`) so the tooling
catalog keeps no-wasm dry-run/missing-argument runner coverage visible while
S4-M11 remains blocked.

S4-M407 guards the checked-tool row for WASI runner self-test prose
(`compare/results/s4-m407-tooling-wasi-runner-row.md`) so the tooling catalog's
tool inventory keeps no-wasm dry-run/missing-argument runner coverage visible
while S4-M11 remains blocked.

S4-M408 tightens that checked-tool row guard
(`compare/results/s4-m408-tooling-wasi-runner-row-atomic.md`) so the full
`tools/run_wasi_test.js` row keeps dry-run/self-test/no-wasm semantics together
while S4-M11 remains blocked.

S4-M409 documents direct README discovery for the Node WASI runner self-test
(`compare/results/s4-m409-readme-direct-wasi-self-test.md`) so users can run
`node tools/run_wasi_test.js --self-test` without the build graph while S4-M11
remains blocked.

S4-M410 documents direct README discovery for the Node WASI runner dry-run
(`compare/results/s4-m410-readme-direct-wasi-dry-run.md`) so users can run
`node tools/run_wasi_test.js --dry-run <test.wasm>` without the build graph
while S4-M11 remains blocked.

S4-M411 documents WASI runner dry-run help
(`compare/results/s4-m411-wasi-dry-run-help.md`) so `tools/run_wasi_test.js
--help` explains no-wasm argv validation while S4-M11 remains blocked.

S4-M412 extends the WASI runner self-test
(`compare/results/s4-m412-wasi-help-self-test.md`) so the runner verifies its own
help output keeps dry-run and self-test no-wasm semantics while S4-M11 remains
blocked.

S4-M413 refreshes full validate-all evidence
(`compare/results/s4-m413-validate-all-after-wasi-help.md`) after the WASI
runner help/self-test changes; the aggregate still passes while S4-M11 remains
blocked.

S4-M414 documents the tooling row for WASI help self-test coverage
(`compare/results/s4-m414-tooling-wasi-help-self-test.md`) so the tooling catalog
states that `zig build wasi-self-test` covers help output while S4-M11 remains
blocked.

S4-M415 documents README WASI help-output self-test coverage
(`compare/results/s4-m415-readme-wasi-help-self-test.md`) so README states that
`zig build wasi-self-test` / direct runner self-test covers help output while
S4-M11 remains blocked.

S4-M416 documents core-guide/API WASI help-output self-test coverage
(`compare/results/s4-m416-guide-api-wasi-help-self-test.md`) so detailed docs
state that `zig build wasi-self-test` / direct runner self-test covers help
output while S4-M11 remains blocked.

S4-M417 refreshes broad native validate evidence
(`compare/results/s4-m417-validate-after-wasi-help-docs.md`) after the WASI
help-output documentation updates; the aggregate still passes while S4-M11
remains blocked.

S4-M418 refreshes validate-local evidence
(`compare/results/s4-m418-validate-local-after-wasi-help-docs.md`) after the
WASI help-output documentation updates; local Rust comparison, surfacecheck, and
runtimecheck gates still pass while S4-M11 remains blocked.

S4-M419 synchronizes S4-M11 blocker evidence
(`compare/results/s4-m419-blocker-validate-local-sync.md`) with the fresh
S4-M418 `validate-local` output, keeping the no-new-local-gap blocker audit
current while S4-M11 remains blocked.

S4-M420 records a concise current local Rust comparison snapshot
(`compare/results/s4-m420-current-rand-status.md`) summarizing the local
`rand`/`rand_distr` baseline, latest `validate-local` evidence, no-known-gap
finding, and S4-M11 blocker state.

S4-M421 exposes that current comparison snapshot from README
(`compare/results/s4-m421-readme-current-rand-status.md`) so the latest local
`rand`/`rand_distr` status is easy to find while S4-M11 remains blocked.

S4-M422 exposes that current comparison snapshot from the core guide and API
reference (`compare/results/s4-m422-guide-api-current-rand-status.md`) so
detailed docs also point to the latest local `rand`/`rand_distr` status while
S4-M11 remains blocked.

S4-M423 exposes that current comparison snapshot from the tooling catalog
(`compare/results/s4-m423-tooling-current-rand-status.md`) so validation/tooling
docs also point to the latest local `rand`/`rand_distr` status while S4-M11
remains blocked.

S4-M424 guards the current comparison snapshot
(`compare/results/s4-m424-current-rand-status-guard.md`) so
`compare/results/s4-m420-current-rand-status.md` keeps its baseline,
validate-local, no-new-gap, and S4-M11 blocker tokens while S4-M11 remains
blocked.

S4-M425 adds a `rand-status` status printer
(`compare/results/s4-m425-rand-status-step.md`) so `zig build rand-status`
prints the current local `rand`/`rand_distr` comparison status while S4-M11
remains blocked.

S4-M426 exposes `rand-status` from the core guide and API reference
(`compare/results/s4-m426-guide-api-rand-status.md`) so detailed docs mention
the quick current-status command while S4-M11 remains blocked.

S4-M427 includes `rand-status` in `validate-local`
(`compare/results/s4-m427-validate-local-rand-status.md`) so the local Rust
comparison aggregate now exercises the current-status printer while S4-M11
remains blocked.

S4-M428 refreshes validate-local evidence after adding `rand-status`
(`compare/results/s4-m428-validate-local-after-rand-status.md`); the aggregate
passes with status output, Rust smoke/parser tests, surfacecheck, and
runtimecheck while S4-M11 remains blocked.

S4-M429 synchronizes S4-M11 blocker evidence after the rand-status aggregate
refresh (`compare/results/s4-m429-blocker-rand-status-sync.md`), keeping the
blocker audit current with S4-M428 `validate-local` output while S4-M11 remains
blocked.

S4-M430 guards `rand-status` output tokens
(`compare/results/s4-m430-rand-status-output-guard.md`) so the quick status
printer keeps baseline, validation, no-new-gap, details, and S4-M11 blocker
signals while S4-M11 remains blocked.

S4-M431 adds scriptable JSON/help output to `rand-status`
(`compare/results/s4-m431-rand-status-json.md`) so the current local
`rand`/`rand_distr` comparison status can be consumed by scripts while S4-M11
remains blocked.

S4-M432 adds a dedicated `rand-status-json` build step
(`compare/results/s4-m432-rand-status-json-step.md`) and includes it in
`validate-local`, so stable JSON status output is exercised by the local Rust
comparison aggregate while S4-M11 remains blocked.

S4-M433 refreshes validate-local evidence after adding `rand-status-json`
(`compare/results/s4-m433-validate-local-after-rand-status-json.md`); the
aggregate passes with text and JSON status output, Rust smoke/parser tests,
surfacecheck, and runtimecheck while S4-M11 remains blocked.

S4-M434 synchronizes S4-M11 blocker evidence after the rand-status-json
aggregate refresh (`compare/results/s4-m434-blocker-rand-status-json-sync.md`),
keeping the blocker audit current with S4-M433 `validate-local` output while
S4-M11 remains blocked.

S4-M435 documents the `rand-status-json` schema
(`compare/results/s4-m435-rand-status-json-schema.md`) so scripts have guarded
field names for consuming current local `rand`/`rand_distr` status while S4-M11
remains blocked.

S4-M436 adds a `rand-status` self-test
(`compare/results/s4-m436-rand-status-self-test.md`) so text, JSON, and help
status output are validated without Rust tools and through `validate-local`
while S4-M11 remains blocked.

S4-M437 refreshes validate-local evidence after adding `rand-status-self-test`
(`compare/results/s4-m437-validate-local-after-rand-status-self-test.md`); the
aggregate passes with text/JSON/self-test status output, Rust smoke/parser tests,
surfacecheck, and runtimecheck while S4-M11 remains blocked.

S4-M438 synchronizes S4-M11 blocker evidence after the rand-status-self-test
aggregate refresh
(`compare/results/s4-m438-blocker-rand-status-self-test-sync.md`), keeping the
blocker audit current with S4-M437 `validate-local` output while S4-M11 remains
blocked.

S4-M439 aligns the `validate-local` build-step description
(`compare/results/s4-m439-validate-local-status-description.md`) so the build
catalog describes local Rust comparison, status, and runtime checks while S4-M11
remains blocked.

S4-M440 adds stable boolean fields to `rand-status-json`
(`compare/results/s4-m440-rand-status-json-booleans.md`) so scripts can consume
validate-local pass, no-known-gap, S4-M11 blocker, and runtime-opportunity state
without parsing prose while S4-M11 remains blocked.

S4-M441 synchronizes S4-M11 blocker evidence with those JSON boolean fields
(`compare/results/s4-m441-blocker-rand-status-boolean-sync.md`), keeping the
blocker audit current with script-friendly status signals while S4-M11 remains
blocked.

S4-M442 keeps the JSON boolean fields visible in the current status snapshot
(`compare/results/s4-m442-current-status-json-booleans.md`) so
`compare/results/s4-m420-current-rand-status.md` also records script-friendly
status signals while S4-M11 remains blocked.

S4-M443 adds a `schema_version` field to `rand-status-json`
(`compare/results/s4-m443-rand-status-schema-version.md`) so scripts can detect
future status schema changes while S4-M11 remains blocked.

S4-M444 keeps the status schema version visible in the current snapshot
(`compare/results/s4-m444-current-status-schema-version.md`) so
`compare/results/s4-m420-current-rand-status.md` mirrors the script-friendly
schema while S4-M11 remains blocked.

S4-M445 synchronizes S4-M11 blocker evidence with the status schema version
(`compare/results/s4-m445-blocker-rand-status-schema-sync.md`), keeping the
blocker audit current with script-friendly schema signals while S4-M11 remains
blocked.

S4-M446 extends `rand-status` self-tests to the bad-argument path
(`compare/results/s4-m446-rand-status-bad-arg-self-test.md`) so the status tool
guards script misuse diagnostics while S4-M11 remains blocked.

S4-M447 adds a `rand-status` schema-version command
(`compare/results/s4-m447-rand-status-schema-version-step.md`) so scripts can
cheaply check stable JSON schema compatibility while S4-M11 remains blocked.

S4-M448 refreshes validate-local evidence after adding
`rand-status-schema-version`
(`compare/results/s4-m448-validate-local-after-rand-status-schema-version.md`);
the aggregate passes with schema-version, text/JSON/self-test status output,
Rust smoke/parser tests, surfacecheck, and runtimecheck while S4-M11 remains
blocked.

S4-M449 synchronizes S4-M11 blocker evidence after the schema-version aggregate
refresh
(`compare/results/s4-m449-blocker-rand-status-schema-version-sync.md`), keeping
the blocker audit current with S4-M448 `validate-local` output while S4-M11
remains blocked.

S4-M450 refreshes the `rand-status` command matrix
(`compare/results/s4-m450-rand-status-command-matrix.md`) so text, JSON,
schema-version, self-test, and help outputs are all freshly verified while
S4-M11 remains blocked.

S4-M451 guards the `rand-status` command matrix evidence
(`compare/results/s4-m451-rand-status-matrix-guard.md`) so that status command
coverage cannot silently narrow while S4-M11 remains blocked.

S4-M452 exposes the `rand-status` command matrix from README
(`compare/results/s4-m452-readme-rand-status-matrix.md`) so users can find the
latest status command evidence while S4-M11 remains blocked.

S4-M453 exposes the `rand-status` command matrix from the core guide and API
reference (`compare/results/s4-m453-guide-api-rand-status-matrix.md`) so
detailed docs also point to the latest status command evidence while S4-M11
remains blocked.

S4-M454 exposes the `rand-status` command matrix from the tooling catalog
(`compare/results/s4-m454-tooling-rand-status-matrix.md`) so validation/tooling
docs also point to the latest status command evidence while S4-M11 remains
blocked.

S4-M455 records direct `rand-status` command forms
(`compare/results/s4-m455-rand-status-direct-matrix.md`) so the documented
`zig build rand-status -- --json`, `--schema-version`, and `--self-test` paths
stay freshly verified while S4-M11 remains blocked.

S4-M456 refreshes the active completion audit
(`compare/results/s4-m456-active-completion-audit-refresh.md`) with current
rand-status, validate-local, and S4-M11 blocker evidence, preserving the
non-completion decision while S4-M11 remains blocked.

S4-M457 guards that active completion audit refresh
(`compare/results/s4-m457-active-audit-refresh-guard.md`) so roadmapcheck keeps
the objective restatement, evidence chain, S4-M11 non-completion reasons, and
no-`update_goal` instruction visible while S4-M11 remains blocked.

S4-M458 adds a latest validate-local evidence pointer to `rand-status-json`
(`compare/results/s4-m458-rand-status-latest-evidence-field.md`) so scripts can
jump from current status to the latest local comparison validation artifact while
S4-M11 remains blocked.

S4-M459 keeps that latest validate-local evidence pointer visible in the current
status snapshot (`compare/results/s4-m459-current-status-latest-evidence.md`) so
`compare/results/s4-m420-current-rand-status.md` mirrors the script-friendly
status schema while S4-M11 remains blocked.

S4-M460 synchronizes S4-M11 blocker evidence with that latest-evidence JSON
field (`compare/results/s4-m460-blocker-latest-evidence-sync.md`), keeping the
blocker audit current with script-friendly validate-local artifact links while
S4-M11 remains blocked.

S4-M461 adds a blocker-audit link to `rand-status-json`
(`compare/results/s4-m461-rand-status-blocker-audit-field.md`) so scripts can
jump from current status to `compare/results/s4-m11-blocker-audit.md` while
S4-M11 remains blocked.

S4-M462 keeps that blocker-audit link visible in the current status snapshot
(`compare/results/s4-m462-current-status-blocker-audit.md`) so
`compare/results/s4-m420-current-rand-status.md` mirrors the script-friendly
status schema while S4-M11 remains blocked.

S4-M463 refreshes validate-local evidence after adding `blocker_audit` to status output
(`compare/results/s4-m463-validate-local-after-blocker-audit-field.md`); the
aggregate passes with blocker-audit status output, Rust smoke/parser tests,
surfacecheck, and runtimecheck while S4-M11 remains blocked.

S4-M464 synchronizes S4-M11 blocker evidence after that blocker-audit aggregate
refresh (`compare/results/s4-m464-blocker-blocker-audit-field-sync.md`), keeping
the blocker audit current with S4-M463 `validate-local` output while S4-M11
remains blocked.

S4-M465 adds an explicit local-status link to `rand-status-json`
(`compare/results/s4-m465-rand-status-local-status-field.md`) so scripts can
distinguish the current status snapshot from the generic details path while
S4-M11 remains blocked.

S4-M466 keeps that local-status link visible in the current status snapshot
(`compare/results/s4-m466-current-status-local-status.md`) so
`compare/results/s4-m420-current-rand-status.md` mirrors the script-friendly
status schema while S4-M11 remains blocked.

S4-M467 synchronizes S4-M11 blocker evidence with that local-status JSON field
(`compare/results/s4-m467-blocker-local-status-sync.md`), keeping the blocker
audit current with the script-friendly current-status pointer while S4-M11
remains blocked.

S4-M468 refreshes validate-local evidence after adding `local_rand_status` to status output
(`compare/results/s4-m468-validate-local-after-local-status-field.md`); the
aggregate passes with local-status and blocker-audit status output, Rust
smoke/parser tests, surfacecheck, and runtimecheck while S4-M11 remains blocked.


S4-M469 updates `rand-status-json` so `latest_validate_local_evidence` points to
`compare/results/s4-m469-latest-validate-local-evidence-pointer.md`; this keeps
the script-friendly status pointer current with checked-in local validation
evidence while S4-M11 remains blocked.


S4-M470 synchronizes S4-M11 blocker evidence with the S4-M469 latest-evidence
pointer (`compare/results/s4-m470-blocker-latest-evidence-pointer-sync.md`),
keeping the blocker audit current with the script-friendly validate-local
evidence path while S4-M11 remains blocked.


S4-M471 adds root one-shot caller-owned fill helpers
(`compare/results/s4-m471-root-one-shot-fill-helpers.md`): system-entropy
callers can now fill range and probability buffers directly from the root API,
with deterministic no-entropy paths for empty/collapsed cases, while S4-M11
remains blocked.


S4-M472 adds root one-shot allocation-returning batch helpers
(`compare/results/s4-m472-root-one-shot-batch-helpers.md`): system-entropy
callers can now allocate random value, range, and probability batches directly
from the root API, complementing the S4-M471 caller-owned fill helpers while
S4-M11 remains blocked.


S4-M473 adds root one-shot string and Unicode helpers
(`compare/results/s4-m473-root-one-shot-string-helpers.md`): system-entropy
callers can now generate alphanumeric strings plus Unicode scalars/UTF-8 from
the root API without manually constructing a secure engine, while S4-M11 remains
blocked.


S4-M474 adds root one-shot endpoint-float helpers
(`compare/results/s4-m474-root-one-shot-endpoint-float-helpers.md`):
system-entropy callers can now fill or allocate strict `(0,1)` and `(0,1]`
float samples directly from the root API while S4-M11 remains blocked.


S4-M475 adds root one-shot `std.Io.Duration` range helpers
(`compare/results/s4-m475-root-one-shot-duration-helpers.md`): system-entropy
callers can now sample and allocate duration ranges directly from the root API
while S4-M11 remains blocked.


S4-M476 adds root one-shot Unicode scalar range helpers
(`compare/results/s4-m476-root-one-shot-unicode-scalar-helpers.md`):
system-entropy callers can now fill and allocate Unicode scalar ranges directly
from the root API, complementing S4-M473 UTF-8/string helpers while S4-M11
remains blocked.


S4-M477 adds root one-shot sampler helpers
(`compare/results/s4-m477-root-one-shot-sampler-helpers.md`): system-entropy
callers can now sample, fill, and allocate from arbitrary reusable samplers
directly from the root API while S4-M11 remains blocked.


S4-M478 adds root one-shot choice helpers
(`compare/results/s4-m478-root-one-shot-choice-helpers.md`): system-entropy
callers can now choose indices and values directly from the root API while
S4-M11 remains blocked.


S4-M479 adds root one-shot shuffle helpers
(`compare/results/s4-m479-root-one-shot-shuffle-helpers.md`): system-entropy
callers can now run full and partial in-place shuffles directly from the root API
while S4-M11 remains blocked.


S4-M480 adds root one-shot weighted index helpers
(`compare/results/s4-m480-root-one-shot-weighted-index-helpers.md`):
system-entropy callers can now sample weighted indices directly from the root API
while S4-M11 remains blocked.


S4-M481 adds root one-shot compact index choice helpers
(`compare/results/s4-m481-root-one-shot-compact-index-helpers.md`):
system-entropy callers can now choose compact `u32` indices directly from the
root API while S4-M11 remains blocked.


S4-M482 adds root one-shot fixed-size choice-array helpers
(`compare/results/s4-m482-root-one-shot-choice-array-helpers.md`):
system-entropy callers can now produce stack-friendly index and value choice
arrays directly from the root API while S4-M11 remains blocked.


S4-M483 adds root one-shot const-pointer choice helpers
(`compare/results/s4-m483-root-one-shot-const-ptr-choice-helpers.md`):
system-entropy callers can now choose const pointers directly from the root API
while S4-M11 remains blocked.


S4-M484 adds root one-shot mutable-pointer choice helpers
(`compare/results/s4-m484-root-one-shot-mut-ptr-choice-helpers.md`):
system-entropy callers can now choose mutable pointers directly from the root API
while S4-M11 remains blocked.


S4-M485 adds root one-shot compact weighted index helpers
(`compare/results/s4-m485-root-one-shot-weighted-u32-index-helpers.md`):
system-entropy callers can now sample compact `u32` weighted indices directly
from the root API while S4-M11 remains blocked.


S4-M486 adds root one-shot weighted index array helpers
(`compare/results/s4-m486-root-one-shot-weighted-index-array-helpers.md`):
system-entropy callers can now produce fixed-size weighted `usize`/`u32` index
arrays directly from the root API while S4-M11 remains blocked.


S4-M487 adds root one-shot weighted value helpers
(`compare/results/s4-m487-root-one-shot-weighted-value-helpers.md`):
system-entropy callers can now sample weighted values directly from the root API
while S4-M11 remains blocked.


S4-M488 adds root one-shot weighted const-pointer helpers
(`compare/results/s4-m488-root-one-shot-weighted-const-ptr-helpers.md`):
system-entropy callers can now sample weighted borrowed references directly from
the root API while S4-M11 remains blocked.


S4-M489 adds root one-shot weighted mutable-pointer helpers
(`compare/results/s4-m489-root-one-shot-weighted-mut-ptr-helpers.md`):
system-entropy callers can now sample weighted writable references directly from
the root API while S4-M11 remains blocked.


S4-M490 adds root one-shot no-replacement value sampling
(`compare/results/s4-m490-root-one-shot-no-replacement-helpers.md`):
system-entropy callers can now allocate no-replacement value samples directly
from the root API while S4-M11 remains blocked.


S4-M491 adds root one-shot no-replacement index sampling
(`compare/results/s4-m491-root-one-shot-no-replacement-index-helpers.md`):
system-entropy callers can now allocate and fill no-replacement index samples
directly from the root API while S4-M11 remains blocked.


S4-M492 adds root one-shot iterator choice helpers
(`compare/results/s4-m492-root-one-shot-iterator-choice-helpers.md`):
system-entropy callers can now choose one item from iterators directly from the
root API while S4-M11 remains blocked.


S4-M493 adds root one-shot weighted iterator choice helpers
(`compare/results/s4-m493-root-one-shot-weighted-iterator-choice-helpers.md`):
system-entropy callers can now choose one item from weighted iterators directly
from the root API while S4-M11 remains blocked.


S4-M494 adds root one-shot iterator sampling helpers
(`compare/results/s4-m494-root-one-shot-iterator-sampling-helpers.md`):
system-entropy callers can now allocate iterator samples directly from the root
API while S4-M11 remains blocked.


S4-M495 adds root one-shot caller-owned iterator sampling
(`compare/results/s4-m495-root-one-shot-iterator-into-helpers.md`):
system-entropy callers can now fill caller-owned iterator sample buffers
directly from the root API while S4-M11 remains blocked.


S4-M496 adds root one-shot fixed-size iterator sample arrays
(`compare/results/s4-m496-root-one-shot-iterator-array-helpers.md`):
system-entropy callers can now produce fixed-size iterator sample arrays directly
from the root API while S4-M11 remains blocked.


S4-M497 adds root one-shot weighted iterator sampling
(`compare/results/s4-m497-root-one-shot-weighted-iterator-sampling-helpers.md`):
system-entropy callers can now allocate weighted iterator samples directly from
the root API while S4-M11 remains blocked.


S4-M498 adds root one-shot caller-owned weighted iterator sampling
(`compare/results/s4-m498-root-one-shot-weighted-iterator-into-helpers.md`):
system-entropy callers can now fill caller-owned weighted iterator sample buffers
directly from the root API while S4-M11 remains blocked.


S4-M499 adds root one-shot fixed-size weighted iterator arrays
(`compare/results/s4-m499-root-one-shot-weighted-iterator-array-helpers.md`):
system-entropy callers can now produce fixed-size weighted iterator sample arrays
directly from the root API while S4-M11 remains blocked.


S4-M500 adds root one-shot weighted no-replacement index sampling
(`compare/results/s4-m500-root-one-shot-weighted-no-replacement-index-helpers.md`):
system-entropy callers can now allocate weighted no-replacement index samples
directly from the root API while S4-M11 remains blocked.


S4-M501 adds root one-shot weighted no-replacement value sampling
(`compare/results/s4-m501-root-one-shot-weighted-no-replacement-value-helpers.md`):
system-entropy callers can now allocate weighted no-replacement value samples
directly from the root API while S4-M11 remains blocked.


S4-M502 adds root one-shot weighted no-replacement value arrays
(`compare/results/s4-m502-root-one-shot-weighted-no-replacement-array-helpers.md`):
system-entropy callers can now produce fixed-size weighted no-replacement value
arrays directly from the root API while S4-M11 remains blocked.


S4-M503 adds root one-shot weighted no-replacement const-pointer sampling
(`compare/results/s4-m503-root-one-shot-weighted-no-replacement-const-ptr-helpers.md`):
system-entropy callers can now allocate weighted no-replacement borrowed
reference samples directly from the root API while S4-M11 remains blocked.

S4-M504 adds root one-shot weighted no-replacement mutable-pointer sampling
(`compare/results/s4-m504-root-one-shot-weighted-no-replacement-mut-ptr-helpers.md`):
system-entropy callers can now allocate weighted no-replacement mutable borrowed
reference samples directly from the root API while S4-M11 remains blocked.

S4-M505 adds root one-shot weighted no-replacement caller-owned index buffers
(`compare/results/s4-m505-root-one-shot-weighted-no-replacement-index-into-helpers.md`):
system-entropy callers can now fill caller-owned weighted no-replacement usize
and u32 index buffers directly from the root API while S4-M11 remains blocked.

S4-M506 adds root one-shot weighted no-replacement caller-owned value buffers
(`compare/results/s4-m506-root-one-shot-weighted-no-replacement-value-into-helpers.md`):
system-entropy callers can now fill caller-owned weighted no-replacement value
buffers directly from the root API while S4-M11 remains blocked.

S4-M507 adds root one-shot weighted no-replacement caller-owned const-pointer buffers
(`compare/results/s4-m507-root-one-shot-weighted-no-replacement-const-ptr-into-helpers.md`):
system-entropy callers can now fill caller-owned weighted no-replacement const
pointer buffers directly from the root API while S4-M11 remains blocked.

S4-M508 adds root one-shot weighted no-replacement caller-owned mutable-pointer buffers
(`compare/results/s4-m508-root-one-shot-weighted-no-replacement-mut-ptr-into-helpers.md`):
system-entropy callers can now fill caller-owned weighted no-replacement mutable
pointer buffers directly from the root API while S4-M11 remains blocked.

S4-M509 adds root one-shot weighted no-replacement fixed-size index arrays
(`compare/results/s4-m509-root-one-shot-weighted-no-replacement-index-array-helpers.md`):
system-entropy callers can now produce fixed-size weighted no-replacement usize
and u32 index arrays directly from the root API while S4-M11 remains blocked.

S4-M510 adds root one-shot compact IndexVec sampling
(`compare/results/s4-m510-root-one-shot-indexvec-helpers.md`):
system-entropy callers can now allocate compact IndexVec no-replacement samples
directly from the root API while S4-M11 remains blocked.

S4-M511 adds root one-shot weighted no-replacement compact IndexVec sampling
(`compare/results/s4-m511-root-one-shot-weighted-no-replacement-indexvec-helpers.md`):
system-entropy callers can now allocate compact weighted no-replacement IndexVec
samples directly from the root API while S4-M11 remains blocked.

S4-M512 adds root one-shot no-replacement fixed-size index arrays
(`compare/results/s4-m512-root-one-shot-index-array-helpers.md`):
system-entropy callers can now produce fixed-size no-replacement usize and u32
index arrays directly from the root API while S4-M11 remains blocked.

S4-M513 adds root one-shot no-replacement fixed-size value arrays
(`compare/results/s4-m513-root-one-shot-value-array-helpers.md`):
system-entropy callers can now produce fixed-size no-replacement value arrays
directly from the root API while S4-M11 remains blocked.

S4-M514 adds root one-shot no-replacement fixed-size const-pointer arrays
(`compare/results/s4-m514-root-one-shot-const-ptr-array-helpers.md`):
system-entropy callers can now produce fixed-size no-replacement const-pointer
arrays directly from the root API while S4-M11 remains blocked.

S4-M515 adds root one-shot no-replacement fixed-size mutable-pointer arrays
(`compare/results/s4-m515-root-one-shot-mut-ptr-array-helpers.md`):
system-entropy callers can now produce fixed-size no-replacement mutable-pointer
arrays directly from the root API while S4-M11 remains blocked.

S4-M516 adds root one-shot no-replacement const-pointer sampling
(`compare/results/s4-m516-root-one-shot-const-ptr-sampling-helpers.md`):
system-entropy callers can now allocate no-replacement const-pointer samples
directly from the root API while S4-M11 remains blocked.

S4-M517 adds root one-shot no-replacement mutable-pointer sampling
(`compare/results/s4-m517-root-one-shot-mut-ptr-sampling-helpers.md`):
system-entropy callers can now allocate no-replacement mutable-pointer samples
directly from the root API while S4-M11 remains blocked.

S4-M518 adds root one-shot no-replacement caller-owned value and pointer buffers
(`compare/results/s4-m518-root-one-shot-no-replacement-into-helpers.md`):
system-entropy callers can now fill caller-owned no-replacement value,
const-pointer, and mutable-pointer buffers directly from the root API while
S4-M11 remains blocked.

S4-M519 adds root chooseMultiple no-replacement aliases
(`compare/results/s4-m519-root-choose-multiple-aliases.md`):
system-entropy callers can now use Rust-discoverable `chooseMultiple*` names for
no-replacement value, const-pointer, mutable-pointer, and caller-owned buffer
workflows directly from the root API while S4-M11 remains blocked.

S4-M520 adds root sampled no-replacement value and pointer iterators
(`compare/results/s4-m520-root-sampled-iterator-helpers.md`):
system-entropy callers can now create owned sampled value, const-pointer, and
mutable-pointer iterators directly from the root API while S4-M11 remains
blocked.

S4-M521 adds root one-shot reservoir value and pointer helpers
(`compare/results/s4-m521-root-reservoir-helpers.md`):
system-entropy callers can now create allocation-returning and caller-owned
value, const-pointer, and mutable-pointer reservoir samples directly from the
root API while S4-M11 remains blocked.

S4-M522 adds root repeated with-replacement fixed-size choice arrays
(`compare/results/s4-m522-root-repeated-choice-array-helpers.md`):
system-entropy callers can now use explicit repeated-choice value, const-pointer,
and mutable-pointer fixed-size arrays directly from the root API while S4-M11
remains blocked.

S4-M523 adds root iterator sample-fill aliases
(`compare/results/s4-m523-root-iterator-sample-fill-aliases.md`):
system-entropy callers can now use Rust-discoverable `sampleIteratorFill*` names
for caller-owned iterator reservoir sampling directly from the root API while
S4-M11 remains blocked.

S4-M524 adds root no-replacement value array choose aliases
(`compare/results/s4-m524-root-choose-array-aliases.md`):
system-entropy callers can now use `chooseArray*` names for fixed-size
no-replacement value arrays directly from the root API while S4-M11 remains
blocked.

S4-M525 adds root one-shot index-weighted index helpers
(`compare/results/s4-m525-root-weighted-by-index-helpers.md`):
system-entropy callers can now sample one `usize` or `u32` weighted index from a
length and comptime index-weight function directly from the root API while
S4-M11 remains blocked.

S4-M526 adds root one-shot index-weighted fill helpers
(`compare/results/s4-m526-root-weighted-by-index-fill-helpers.md`):
system-entropy callers can now fill caller-owned `usize` or `u32` weighted
indexes from a length and comptime index-weight function directly from the root
API while S4-M11 remains blocked.

S4-M527 adds root one-shot index-weighted batch helpers
(`compare/results/s4-m527-root-weighted-by-index-batch-helpers.md`):
system-entropy callers can now allocate owned `usize` or `u32` weighted index
batches from a length and comptime index-weight function directly from the root
API while S4-M11 remains blocked.

S4-M528 adds root one-shot index-weighted fixed-size array helpers
(`compare/results/s4-m528-root-weighted-by-index-array-helpers.md`):
system-entropy callers can now produce fixed-size `usize` or `u32` weighted
index arrays from a length and comptime index-weight function directly from the
root API while S4-M11 remains blocked.

S4-M529 adds root one-shot index-weighted value choice helpers
(`compare/results/s4-m529-root-weighted-value-by-index-helpers.md`):
system-entropy callers can now choose values from an item slice and comptime
index-weight function directly from the root API while S4-M11 remains blocked.

S4-M530 adds root one-shot index-weighted const-pointer choice helpers
(`compare/results/s4-m530-root-weighted-const-ptr-by-index-helpers.md`):
system-entropy callers can now choose const pointers from an item slice and
comptime index-weight function directly from the root API while S4-M11 remains
blocked.

S4-M531 adds root one-shot index-weighted mutable-pointer choice helpers
(`compare/results/s4-m531-root-weighted-mut-ptr-by-index-helpers.md`):
system-entropy callers can now choose mutable pointers from a mutable item slice
and comptime index-weight function directly from the root API while S4-M11
remains blocked.

S4-M532 adds root one-shot index-weighted value fill helpers
(`compare/results/s4-m532-root-weighted-value-by-index-fill-helpers.md`):
system-entropy callers can now fill caller-owned value buffers from an item
slice and comptime index-weight function directly from the root API while
S4-M11 remains blocked.

S4-M533 adds root one-shot index-weighted const-pointer fill helpers
(`compare/results/s4-m533-root-weighted-const-ptr-by-index-fill-helpers.md`):
system-entropy callers can now fill caller-owned const-pointer buffers from an
item slice and comptime index-weight function directly from the root API while
S4-M11 remains blocked.

S4-M534 adds root one-shot index-weighted mutable-pointer fill helpers
(`compare/results/s4-m534-root-weighted-mut-ptr-by-index-fill-helpers.md`):
system-entropy callers can now fill caller-owned mutable-pointer buffers from a
mutable item slice and comptime index-weight function directly from the root API
while S4-M11 remains blocked.

S4-M535 adds root one-shot index-weighted value batch helpers
(`compare/results/s4-m535-root-weighted-value-by-index-batch-helpers.md`):
system-entropy callers can now allocate value batches from an item slice and
comptime index-weight function directly from the root API while S4-M11 remains
blocked.

S4-M536 adds root one-shot index-weighted const-pointer batch helpers
(`compare/results/s4-m536-root-weighted-const-ptr-by-index-batch-helpers.md`):
system-entropy callers can now allocate const-pointer batches from an item slice
and comptime index-weight function directly from the root API while S4-M11
remains blocked.

S4-M537 adds root one-shot index-weighted mutable-pointer batch helpers
(`compare/results/s4-m537-root-weighted-mut-ptr-by-index-batch-helpers.md`):
system-entropy callers can now allocate mutable-pointer batches from a mutable
item slice and comptime index-weight function directly from the root API while
S4-M11 remains blocked.

S4-M538 adds root one-shot index-weighted value array helpers
(`compare/results/s4-m538-root-weighted-value-by-index-array-helpers.md`):
system-entropy callers can now produce fixed-size value arrays from an item slice
and comptime index-weight function directly from the root API while S4-M11
remains blocked.

S4-M539 adds root one-shot index-weighted const-pointer array helpers
(`compare/results/s4-m539-root-weighted-const-ptr-by-index-array-helpers.md`):
system-entropy callers can now produce fixed-size const-pointer arrays from an
item slice and comptime index-weight function directly from the root API while
S4-M11 remains blocked.

S4-M540 adds root one-shot index-weighted mutable-pointer array helpers
(`compare/results/s4-m540-root-weighted-mut-ptr-by-index-array-helpers.md`):
system-entropy callers can now produce fixed-size mutable-pointer arrays from a
mutable item slice and comptime index-weight function directly from the root API
while S4-M11 remains blocked.

S4-M541 adds root one-shot item-accessor weighted index helpers
(`compare/results/s4-m541-root-weighted-by-helpers.md`): system-entropy callers
can now sample weighted indices directly from an item slice and comptime
item-weight accessor from the root API while S4-M11 remains blocked.

S4-M542 adds root one-shot item-accessor weighted `u32` index helpers
(`compare/results/s4-m542-root-weighted-u32-by-helpers.md`): system-entropy
callers can now sample compact `u32` weighted indices directly from an item
slice and comptime item-weight accessor from the root API while S4-M11 remains
blocked.

S4-M543 adds root item-accessor weighted `usize` index fill helpers
(`compare/results/s4-m543-root-weighted-by-fill-helpers.md`): system-entropy
callers can now fill caller-owned weighted index buffers directly from an item
slice and comptime item-weight accessor from the root API while S4-M11 remains
blocked.

S4-M544 adds root item-accessor weighted `u32` index fill helpers
(`compare/results/s4-m544-root-weighted-u32-by-fill-helpers.md`):
system-entropy callers can now fill caller-owned compact `u32` weighted index
buffers directly from an item slice and comptime item-weight accessor from the
root API while S4-M11 remains blocked.

S4-M545 adds root item-accessor weighted `usize` index batch helpers
(`compare/results/s4-m545-root-weighted-by-batch-helpers.md`): system-entropy
callers can now allocate repeated weighted index batches directly from an item
slice and comptime item-weight accessor from the root API while S4-M11 remains
blocked.

S4-M546 adds root item-accessor weighted `u32` index batch helpers
(`compare/results/s4-m546-root-weighted-u32-by-batch-helpers.md`):
system-entropy callers can now allocate repeated compact `u32` weighted index
batches directly from an item slice and comptime item-weight accessor from the
root API while S4-M11 remains blocked.

S4-M547 adds root item-accessor weighted `usize` index array helpers
(`compare/results/s4-m547-root-weighted-by-array-helpers.md`): system-entropy
callers can now produce fixed-size weighted index arrays directly from an item
slice and comptime item-weight accessor from the root API while S4-M11 remains
blocked.

S4-M548 adds root item-accessor weighted `u32` index array helpers
(`compare/results/s4-m548-root-weighted-u32-by-array-helpers.md`):
system-entropy callers can now produce fixed-size compact `u32` weighted index
arrays directly from an item slice and comptime item-weight accessor from the
root API while S4-M11 remains blocked.

S4-M549 adds root item-accessor weighted value choice helpers
(`compare/results/s4-m549-root-weighted-by-value-helpers.md`): system-entropy
callers can now choose weighted values directly from an item slice and comptime
item-weight accessor from the root API while S4-M11 remains blocked.

S4-M550 adds root item-accessor weighted const-pointer choice helpers
(`compare/results/s4-m550-root-weighted-by-const-ptr-helpers.md`):
system-entropy callers can now choose weighted const pointers directly from an
item slice and comptime item-weight accessor from the root API while S4-M11
remains blocked.

S4-M551 adds root item-accessor weighted mutable-pointer choice helpers
(`compare/results/s4-m551-root-weighted-by-mut-ptr-helpers.md`): system-entropy
callers can now choose weighted mutable pointers directly from a mutable item
slice and comptime item-weight accessor from the root API while S4-M11 remains
blocked.

S4-M552 adds root item-accessor weighted value fill helpers
(`compare/results/s4-m552-root-weighted-by-value-fill-helpers.md`):
system-entropy callers can now fill caller-owned weighted value buffers directly
from an item slice and comptime item-weight accessor from the root API while
S4-M11 remains blocked.

S4-M553 adds root item-accessor weighted const-pointer fill helpers
(`compare/results/s4-m553-root-weighted-by-const-ptr-fill-helpers.md`):
system-entropy callers can now fill caller-owned weighted const-pointer buffers
directly from an item slice and comptime item-weight accessor from the root API
while S4-M11 remains blocked.

S4-M554 adds root item-accessor weighted mutable-pointer fill helpers
(`compare/results/s4-m554-root-weighted-by-mut-ptr-fill-helpers.md`):
system-entropy callers can now fill caller-owned weighted mutable-pointer
buffers directly from a mutable item slice and comptime item-weight accessor
from the root API while S4-M11 remains blocked.

S4-M555 adds root item-accessor weighted value batch helpers
(`compare/results/s4-m555-root-weighted-by-value-batch-helpers.md`):
system-entropy callers can now allocate repeated weighted value batches directly
from an item slice and comptime item-weight accessor from the root API while
S4-M11 remains blocked.

S4-M556 adds root item-accessor weighted const-pointer batch helpers
(`compare/results/s4-m556-root-weighted-by-const-ptr-batch-helpers.md`):
system-entropy callers can now allocate repeated weighted const-pointer batches
directly from an item slice and comptime item-weight accessor from the root API
while S4-M11 remains blocked.

S4-M557 adds root item-accessor weighted mutable-pointer batch helpers
(`compare/results/s4-m557-root-weighted-by-mut-ptr-batch-helpers.md`):
system-entropy callers can now allocate repeated weighted mutable-pointer
batches directly from a mutable item slice and comptime item-weight accessor
from the root API while S4-M11 remains blocked.

S4-M558 adds root item-accessor weighted fixed-size value array helpers
(`compare/results/s4-m558-root-weighted-by-value-array-helpers.md`):
system-entropy callers can now produce fixed-size weighted value arrays directly
from an item slice and comptime item-weight accessor from the root API while
S4-M11 remains blocked.

S4-M559 adds root item-accessor weighted fixed-size const-pointer array helpers
(`compare/results/s4-m559-root-weighted-by-const-ptr-array-helpers.md`):
system-entropy callers can now produce fixed-size weighted const-pointer arrays
directly from an item slice and comptime item-weight accessor from the root API
while S4-M11 remains blocked.

S4-M560 adds root item-accessor weighted fixed-size mutable-pointer array helpers
(`compare/results/s4-m560-root-weighted-by-mut-ptr-array-helpers.md`):
system-entropy callers can now produce fixed-size weighted mutable-pointer
arrays directly from a mutable item slice and comptime item-weight accessor from
the root API while S4-M11 remains blocked.

S4-M561 adds root item-accessor weighted no-replacement value sample helpers
(`compare/results/s4-m561-root-weighted-by-sample-helpers.md`): system-entropy
callers can now allocate no-replacement weighted value samples directly from an
item slice and comptime item-weight accessor from the root API while S4-M11
remains blocked.

S4-M562 adds root item-accessor weighted no-replacement const-pointer sample
helpers (`compare/results/s4-m562-root-weighted-by-const-ptr-sample-helpers.md`):
system-entropy callers can now allocate no-replacement weighted const-pointer
samples directly from an item slice and comptime item-weight accessor from the
root API while S4-M11 remains blocked.

S4-M563 adds root item-accessor weighted no-replacement mutable-pointer sample
helpers (`compare/results/s4-m563-root-weighted-by-mut-ptr-sample-helpers.md`):
system-entropy callers can now allocate no-replacement weighted mutable-pointer
samples directly from a mutable item slice and comptime item-weight accessor
from the root API while S4-M11 remains blocked.

S4-M564 adds root item-accessor weighted no-replacement value into helpers
(`compare/results/s4-m564-root-weighted-by-value-into-helpers.md`):
system-entropy callers can now fill caller-owned no-replacement weighted value
buffers directly from an item slice and comptime item-weight accessor from the
root API while S4-M11 remains blocked.

S4-M565 adds root item-accessor weighted no-replacement const-pointer into
helpers (`compare/results/s4-m565-root-weighted-by-const-ptr-into-helpers.md`):
system-entropy callers can now fill caller-owned no-replacement weighted
const-pointer buffers directly from an item slice and comptime item-weight
accessor from the root API while S4-M11 remains blocked.

S4-M566 adds root item-accessor weighted no-replacement mutable-pointer into
helpers (`compare/results/s4-m566-root-weighted-by-mut-ptr-into-helpers.md`):
system-entropy callers can now fill caller-owned no-replacement weighted
mutable-pointer buffers directly from a mutable item slice and comptime
item-weight accessor from the root API while S4-M11 remains blocked.

S4-M567 adds root item-accessor weighted no-replacement index sample helpers
(`compare/results/s4-m567-root-weighted-by-index-sample-helpers.md`):
system-entropy callers can now allocate no-replacement weighted `usize` index
samples directly from an item slice and comptime item-weight accessor from the
root API while S4-M11 remains blocked.

S4-M568 adds root item-accessor weighted no-replacement compact u32 index sample
helpers (`compare/results/s4-m568-root-weighted-by-u32-index-sample-helpers.md`):
system-entropy callers can now allocate no-replacement weighted compact `u32`
index samples directly from an item slice and comptime item-weight accessor from
the root API while S4-M11 remains blocked.

S4-M569 adds root item-accessor weighted no-replacement IndexVec sample helpers
(`compare/results/s4-m569-root-weighted-by-index-vec-sample-helpers.md`):
system-entropy callers can now allocate no-replacement weighted `IndexVec`
samples directly from an item slice and comptime item-weight accessor from the
root API while S4-M11 remains blocked.

S4-M570 adds root item-accessor weighted no-replacement index into helpers
(`compare/results/s4-m570-root-weighted-by-index-into-helpers.md`):
system-entropy callers can now fill caller-owned no-replacement weighted `usize`
index buffers directly from an item slice and comptime item-weight accessor from
the root API while S4-M11 remains blocked.

S4-M571 adds root item-accessor weighted no-replacement index array helpers
(`compare/results/s4-m571-root-weighted-by-index-array-helpers.md`):
system-entropy callers can now produce fixed-size no-replacement weighted
`usize` index arrays directly from an item slice and comptime item-weight
accessor from the root API while S4-M11 remains blocked.

S4-M572 adds root item-accessor weighted no-replacement compact u32 index array
helpers (`compare/results/s4-m572-root-weighted-by-u32-index-array-helpers.md`):
system-entropy callers can now produce fixed-size no-replacement weighted
compact `u32` index arrays directly from an item slice and comptime item-weight
accessor from the root API while S4-M11 remains blocked.

S4-M573 adds root length-weighted no-replacement index sample helpers
(`compare/results/s4-m573-root-weighted-by-index-index-sample-helpers.md`):
system-entropy callers can now allocate no-replacement weighted `usize` index
samples directly from a length and comptime index-weight accessor from the root
API while S4-M11 remains blocked.

S4-M574 adds root length-weighted no-replacement compact u32 index sample
helpers (`compare/results/s4-m574-root-weighted-by-index-u32-sample-helpers.md`):
system-entropy callers can now allocate no-replacement weighted compact `u32`
index samples directly from a length and comptime index-weight accessor from the
root API while S4-M11 remains blocked.

S4-M575 adds root length-weighted no-replacement IndexVec sample helpers
(`compare/results/s4-m575-root-weighted-by-index-vec-index-sample-helpers.md`):
system-entropy callers can now allocate no-replacement weighted `IndexVec`
samples directly from a length and comptime index-weight accessor from the root
API while S4-M11 remains blocked.

S4-M576 adds root length-weighted no-replacement index into helpers
(`compare/results/s4-m576-root-weighted-by-index-index-into-helpers.md`):
system-entropy callers can now fill caller-owned no-replacement weighted `usize`
index buffers directly from a length and comptime index-weight accessor from the
root API while S4-M11 remains blocked.

S4-M577 adds root length-weighted no-replacement compact u32 index into helpers
(`compare/results/s4-m577-root-weighted-by-index-u32-into-helpers.md`):
system-entropy callers can now fill caller-owned no-replacement weighted compact
`u32` index buffers directly from a length and comptime index-weight accessor
from the root API while S4-M11 remains blocked.

S4-M578 adds root length-weighted no-replacement index array helpers
(`compare/results/s4-m578-root-weighted-by-index-index-array-helpers.md`):
system-entropy callers can now produce fixed-size no-replacement weighted
`usize` index arrays directly from a length and comptime index-weight accessor
from the root API while S4-M11 remains blocked.

S4-M579 adds root length-weighted no-replacement compact u32 index array helpers
(`compare/results/s4-m579-root-weighted-by-index-u32-array-helpers.md`):
system-entropy callers can now produce fixed-size no-replacement weighted
compact `u32` index arrays directly from a length and comptime index-weight
accessor from the root API while S4-M11 remains blocked.

S4-M580 adds root item-accessor weighted no-replacement value array sample
helpers (`compare/results/s4-m580-root-weighted-by-value-array-sample-helpers.md`):
system-entropy callers can now produce fixed-size no-replacement weighted value
arrays directly from an item slice and comptime item-weight accessor from the
root API while S4-M11 remains blocked.

S4-M581 adds root item-accessor weighted no-replacement const-pointer array
sample helpers (`compare/results/s4-m581-root-weighted-by-const-ptr-array-sample-helpers.md`):
system-entropy callers can now produce fixed-size no-replacement weighted
const-pointer arrays directly from an item slice and comptime item-weight
accessor from the root API while S4-M11 remains blocked.

S4-M582 adds root item-accessor weighted no-replacement mutable-pointer array
sample helpers (`compare/results/s4-m582-root-weighted-by-mut-ptr-array-sample-helpers.md`):
system-entropy callers can now produce fixed-size no-replacement weighted
mutable-pointer arrays directly from a mutable item slice and comptime
item-weight accessor from the root API while S4-M11 remains blocked.

S4-M583 adds root parallel-weighted no-replacement value sample prevalidation
(`compare/results/s4-m583-root-weighted-value-sample-prevalidation.md`): root
system-entropy callers now get deterministic zero-count/all-zero/single-positive
and invalid-parameter failures before secure-engine construction for
`sampleWeighted` and `sampleWeightedChecked` while S4-M11 remains blocked.

S4-M584 adds root parallel-weighted no-replacement const-pointer sample
prevalidation (`compare/results/s4-m584-root-weighted-const-ptr-sample-prevalidation.md`):
root system-entropy callers now get deterministic zero-count/all-zero/single-
positive and invalid-parameter failures before secure-engine construction for
`sampleWeightedPtrs` and `sampleWeightedPtrsChecked` while S4-M11 remains
blocked.

S4-M585 adds root parallel-weighted no-replacement mutable-pointer sample
prevalidation (`compare/results/s4-m585-root-weighted-mut-ptr-sample-prevalidation.md`):
root system-entropy callers now get deterministic zero-count/all-zero/single-
positive and invalid-parameter failures before secure-engine construction for
`sampleWeightedMutPtrs` and `sampleWeightedMutPtrsChecked` while S4-M11 remains
blocked.

S4-M586 adds root parallel-weighted no-replacement value array prevalidation
(`compare/results/s4-m586-root-weighted-value-array-prevalidation.md`): root
system-entropy callers now get deterministic zero-size/all-zero/single-positive
and invalid-parameter failures before secure-engine construction for
`sampleWeightedArray` and `sampleWeightedArrayChecked` while S4-M11 remains
blocked.

S4-M587 adds root parallel-weighted no-replacement const-pointer array
prevalidation
(`compare/results/s4-m587-root-weighted-const-ptr-array-prevalidation.md`):
root system-entropy callers now get deterministic zero-size/all-zero/single-
positive and invalid-parameter failures before secure-engine construction for
`sampleWeightedPtrArray` and `sampleWeightedPtrArrayChecked` while S4-M11
remains blocked.

S4-M588 adds root parallel-weighted no-replacement mutable-pointer array
prevalidation
(`compare/results/s4-m588-root-weighted-mut-ptr-array-prevalidation.md`):
root system-entropy callers now get deterministic zero-size/all-zero/single-
positive and invalid-parameter failures before secure-engine construction for
`sampleWeightedMutPtrArray` and `sampleWeightedMutPtrArrayChecked` while S4-M11
remains blocked.

S4-M589 adds root weighted-iterator fixed-array lazy entropy
(`compare/results/s4-m589-root-weighted-iterator-array-lazy-entropy.md`): root
system-entropy callers now get deterministic zero-size/all-zero/single-positive,
insufficient-positive, early-invalid-weight, and checked-error outcomes before
secure-engine construction for `sampleIteratorWeightedArray` and
`sampleIteratorWeightedArrayChecked` while S4-M11 remains blocked.

S4-M590 adds root weighted-iterator allocated sample lazy entropy
(`compare/results/s4-m590-root-weighted-iterator-allocated-lazy-entropy.md`):
root system-entropy callers now get deterministic zero-amount/all-zero/single-
positive, insufficient-positive checked, early-invalid-weight, and checked-error
outcomes before secure-engine construction for `sampleIteratorWeighted` and
`sampleIteratorWeightedChecked` while S4-M11 remains blocked.

S4-M591 adds root weighted-iterator into/fill lazy entropy
(`compare/results/s4-m591-root-weighted-iterator-into-lazy-entropy.md`): root
system-entropy callers now get deterministic zero-output/all-zero/single-
positive, insufficient-positive checked, early-invalid-weight, scratch-mismatch,
and checked-error outcomes before secure-engine construction for
`sampleIteratorWeightedInto` and `sampleIteratorWeightedIntoChecked` while
S4-M11 remains blocked.

S4-M592 adds root index fill/batch empty-range prevalidation
(`compare/results/s4-m592-root-index-fill-batch-empty-range-prevalidation.md`):
root system-entropy callers now get deterministic non-empty zero-range failures
before secure-engine construction for `fillChooseIndex`, `chooseIndexBatch`,
`fillChooseIndexU32`, and `chooseIndexU32Batch`, while zero-count batches still
return empty allocations and S4-M11 remains blocked.

S4-M593 adds root value choose fill/batch empty-input prevalidation
(`compare/results/s4-m593-root-value-choose-fill-batch-empty-input-prevalidation.md`):
root system-entropy callers now get deterministic non-empty empty-input failures
before secure-engine construction for `fillChoose` and `chooseBatch`, while
empty destinations and zero-count batches still return deterministically and
S4-M11 remains blocked.

S4-M594 adds root const-pointer choose fill/batch empty-input prevalidation
(`compare/results/s4-m594-root-const-ptr-choose-fill-batch-empty-input-prevalidation.md`):
root system-entropy callers now get deterministic non-empty empty-input failures
before secure-engine construction for `fillChooseConstPtr` and
`chooseConstPtrBatch`, while empty destinations and zero-count batches still
return deterministically and S4-M11 remains blocked.

S4-M595 adds root mutable-pointer choose fill/batch empty-input prevalidation
(`compare/results/s4-m595-root-mut-ptr-choose-fill-batch-empty-input-prevalidation.md`):
root system-entropy callers now get deterministic non-empty empty-input failures
before secure-engine construction for `fillChoosePtr` and `choosePtrBatch`,
while empty destinations and zero-count batches still return deterministically
and S4-M11 remains blocked.

S4-M596 adds root weighted-index invalid-weight prevalidation
(`compare/results/s4-m596-root-weighted-index-invalid-weight-prevalidation.md`):
root system-entropy callers now get invalid-weight failures before secure-engine
construction for unchecked weighted index helpers, and allocation-returning
batches validate deterministic empty/single/invalid paths before allocating
random-output buffers while S4-M11 remains blocked.

S4-M597 adds root weighted value batch prevalidation
(`compare/results/s4-m597-root-weighted-value-batch-prevalidation.md`): root
system-entropy callers now get length-mismatch, invalid-weight, and checked
empty-range failures before random-output allocation and secure-engine
construction for `chooseWeightedBatch` and `chooseWeightedBatchChecked`, while
deterministic empty/single paths remain allocation-only and S4-M11 remains
blocked.

S4-M598 adds root weighted const-pointer batch prevalidation
(`compare/results/s4-m598-root-weighted-const-ptr-batch-prevalidation.md`): root
system-entropy callers now get length-mismatch, invalid-weight, and checked
empty-range failures before random-output allocation and secure-engine
construction for `chooseWeightedConstPtrBatch` and
`chooseWeightedConstPtrBatchChecked`, while deterministic empty/single paths
remain allocation-only and S4-M11 remains blocked.

S4-M599 adds root weighted mutable-pointer batch prevalidation
(`compare/results/s4-m599-root-weighted-mut-ptr-batch-prevalidation.md`): root
system-entropy callers now get length-mismatch, invalid-weight, and checked
empty-range failures before random-output allocation and secure-engine
construction for `chooseWeightedPtrBatch` and `chooseWeightedPtrBatchChecked`,
while deterministic empty/single paths remain allocation-only and S4-M11 remains
blocked.

S4-M600 adds root item-accessor weighted value batch prevalidation
(`compare/results/s4-m600-root-weighted-by-value-batch-prevalidation.md`): root
system-entropy callers now get invalid-weight and checked empty-input failures
before random-output allocation and secure-engine construction for
`chooseWeightedBatchBy` and `chooseWeightedBatchByChecked`, while deterministic
empty/single paths remain allocation-only and S4-M11 remains blocked.

S4-M601 adds root item-accessor weighted const-pointer batch prevalidation
(`compare/results/s4-m601-root-weighted-by-const-ptr-batch-prevalidation.md`):
root system-entropy callers now get invalid-weight and checked empty-input
failures before random-output allocation and secure-engine construction for
`chooseWeightedConstPtrBatchBy` and `chooseWeightedConstPtrBatchByChecked`,
while deterministic empty/single paths remain allocation-only and S4-M11 remains
blocked.

S4-M602 adds root item-accessor weighted mutable-pointer batch prevalidation
(`compare/results/s4-m602-root-weighted-by-mut-ptr-batch-prevalidation.md`):
root system-entropy callers now get invalid-weight and checked empty-input
failures before random-output allocation and secure-engine construction for
`chooseWeightedPtrBatchBy` and `chooseWeightedPtrBatchByChecked`, while
deterministic empty/single paths remain allocation-only and S4-M11 remains
blocked.

S4-M603 adds root by-index weighted value batch prevalidation
(`compare/results/s4-m603-root-weighted-by-index-value-batch-prevalidation.md`):
root system-entropy callers now get invalid-weight and checked empty-input
failures before random-output allocation and secure-engine construction for
`chooseWeightedBatchByIndex` and `chooseWeightedBatchByIndexChecked`, while
deterministic empty/single paths remain allocation-only and S4-M11 remains
blocked.

S4-M604 adds root by-index weighted const-pointer batch prevalidation
(`compare/results/s4-m604-root-weighted-by-index-const-ptr-batch-prevalidation.md`):
root system-entropy callers now get invalid-weight and checked empty-input
failures before random-output allocation and secure-engine construction for
`chooseWeightedConstPtrBatchByIndex` and
`chooseWeightedConstPtrBatchByIndexChecked`, while deterministic empty/single
paths remain allocation-only and S4-M11 remains blocked.

S4-M605 adds root by-index weighted mutable-pointer batch prevalidation
(`compare/results/s4-m605-root-weighted-by-index-mut-ptr-batch-prevalidation.md`):
root system-entropy callers now get invalid-weight and checked empty-input
failures before random-output allocation and secure-engine construction for
`chooseWeightedPtrBatchByIndex` and `chooseWeightedPtrBatchByIndexChecked`,
while deterministic empty/single paths remain allocation-only and S4-M11 remains
blocked.

S4-M606 adds root item-accessor weighted index batch prevalidation
(`compare/results/s4-m606-root-weighted-by-index-batch-prevalidation.md`): root
system-entropy callers now get invalid-weight and checked empty-input failures
before random-output allocation and secure-engine construction for
`weightedIndexBatchBy` and `weightedIndexBatchByChecked`, while deterministic
empty/single paths remain allocation-only and S4-M11 remains blocked.

S4-M607 adds root item-accessor weighted compact u32 index batch prevalidation
(`compare/results/s4-m607-root-weighted-by-u32-index-batch-prevalidation.md`):
root system-entropy callers now get oversized-input, invalid-weight, and checked
empty-input failures before random-output allocation and secure-engine
construction for `weightedIndexU32BatchBy` and `weightedIndexU32BatchByChecked`,
while deterministic empty/single paths remain allocation-only and S4-M11 remains
blocked.

S4-M608 adds root by-index weighted index batch prevalidation
(`compare/results/s4-m608-root-weighted-by-index-index-batch-prevalidation.md`):
root system-entropy callers now get invalid-weight and checked empty-input
failures before random-output allocation and secure-engine construction for
`weightedIndexBatchByIndex` and `weightedIndexBatchByIndexChecked`, while
deterministic empty/single paths remain allocation-only and S4-M11 remains
blocked.

S4-M609 adds root by-index weighted compact u32 index batch prevalidation
(`compare/results/s4-m609-root-weighted-by-index-u32-index-batch-prevalidation.md`):
root system-entropy callers now get oversized-input, invalid-weight, and checked
empty-input failures before random-output allocation and secure-engine
construction for `weightedIndexU32BatchByIndex` and
`weightedIndexU32BatchByIndexChecked`, while deterministic empty/single paths
remain allocation-only and S4-M11 remains blocked.

S4-M610 adds root checked scalar batch parameter prevalidation
(`compare/results/s4-m610-root-checked-scalar-batch-prevalidation.md`): root
system-entropy callers now get invalid exclusive-range, probability, and ratio
failures before random-output allocation and secure-engine construction for
`rangeBatchChecked`, `randomBoolBatchChecked`, and `randomRatioBatchChecked`,
while zero-count and deterministic collapsed paths remain allocation-only and
S4-M11 remains blocked.

S4-M611 adds root checked inclusive integer batch parameter prevalidation
(`compare/results/s4-m611-root-checked-inclusive-batch-prevalidation.md`): root
system-entropy callers now get invalid inclusive-range failures before
random-output allocation and secure-engine construction for
`rangeAtMostBatchChecked`, while zero-count and deterministic collapsed paths
remain allocation-only and S4-M11 remains blocked.

S4-M612 adds root checked Unicode scalar batch parameter prevalidation
(`compare/results/s4-m612-root-checked-unicode-batch-prevalidation.md`): root
system-entropy callers now get invalid Unicode range and code-point failures
before random-output allocation and secure-engine construction for
`unicodeScalarRangeLessThanBatchChecked` and
`unicodeScalarRangeAtMostBatchChecked`, while zero-count and deterministic
collapsed paths remain allocation-only and S4-M11 remains blocked.

S4-M613 adds root duration range batch parameter prevalidation
(`compare/results/s4-m613-root-duration-batch-prevalidation.md`): root
system-entropy callers now get invalid duration range failures before
random-output allocation and secure-engine construction for duration batch
helpers, while zero-count and deterministic collapsed paths remain allocation-
only and S4-M11 remains blocked.

S4-M614 adds root Unicode scalar batch parameter prevalidation
(`compare/results/s4-m614-root-unicode-batch-prevalidation.md`): root
system-entropy callers now get invalid Unicode range and code-point failures
before random-output allocation and secure-engine construction for
`unicodeScalarRangeLessThanBatch` and `unicodeScalarRangeAtMostBatch`, while
zero-count and deterministic collapsed paths remain allocation-only and S4-M11
remains blocked.

S4-M615 adds root checked value choose batch empty-input prevalidation
(`compare/results/s4-m615-root-checked-value-choose-batch-prevalidation.md`):
root system-entropy callers now get non-zero empty-input failures before
random-output allocation and secure-engine construction for `chooseBatchChecked`,
while zero-count and singleton deterministic paths remain allocation-only and
S4-M11 remains blocked.

S4-M616 adds root checked const-pointer choose batch empty-input prevalidation
(`compare/results/s4-m616-root-checked-const-ptr-choose-batch-prevalidation.md`):
root system-entropy callers now get non-zero empty-input failures before
random-output allocation and secure-engine construction for
`chooseConstPtrBatchChecked`, while zero-count and singleton deterministic paths
remain allocation-only and S4-M11 remains blocked.

S4-M617 adds root checked mutable-pointer choose batch empty-input prevalidation
(`compare/results/s4-m617-root-checked-mut-ptr-choose-batch-prevalidation.md`):
root system-entropy callers now get non-zero empty-input failures before
random-output allocation and secure-engine construction for `choosePtrBatchChecked`,
while zero-count and singleton deterministic paths remain allocation-only and
S4-M11 remains blocked.

S4-M618 adds root scalar range batch parameter prevalidation
(`compare/results/s4-m618-root-scalar-range-batch-prevalidation.md`): root
system-entropy callers now get invalid exclusive and inclusive range failures
before random-output allocation and secure-engine construction for `rangeBatch`
and `rangeAtMostBatch`, while zero-count and deterministic collapsed paths remain
allocation-only and S4-M11 remains blocked.

S4-M619 adds root probability batch parameter prevalidation
(`compare/results/s4-m619-root-probability-batch-prevalidation.md`): root
system-entropy callers now get invalid probability and ratio failures before
random-output allocation and secure-engine construction for `randomBoolBatch` and
`randomRatioBatch`, while zero-count and endpoint deterministic paths remain
allocation-only and S4-M11 remains blocked.

S4-M620 adds root value batch empty-type prevalidation
(`compare/results/s4-m620-root-value-batch-empty-type-prevalidation.md`): root
system-entropy callers now get non-zero uninhabited value type failures before
random-output allocation and secure-engine construction for `valueBatch`, while
zero-count behavior remains allocation-only and S4-M11 remains blocked.

S4-M621 adds root no-replacement value sample empty-type prevalidation
(`compare/results/s4-m621-root-no-replacement-empty-type-prevalidation.md`):
root system-entropy callers now get non-zero uninhabited value type failures
before random-output allocation and secure-engine construction for
`sampleWithoutReplacementChecked`, while zero-count and all-item deterministic
paths remain allocation-only and S4-M11 remains blocked.

S4-M622 adds root Unicode scalar range prevalidation
(`compare/results/s4-m622-root-unicode-range-prevalidation.md`): root
system-entropy callers now get invalid Unicode range and code-point failures
before secure-engine construction for unchecked Unicode scalar range scalar/fill
helpers, while empty-output and deterministic collapsed paths remain no-entropy
and S4-M11 remains blocked.

S4-M623 adds root sampler batch empty-type prevalidation
(`compare/results/s4-m623-root-sampler-batch-empty-type-prevalidation.md`): root
system-entropy callers now get non-zero uninhabited output type failures before
random-output allocation and secure-engine construction for `sampleBatch`, while
zero-count behavior remains allocation-only and S4-M11 remains blocked.

S4-M624 adds root generic value empty-type prevalidation
(`compare/results/s4-m624-root-generic-value-empty-type-prevalidation.md`): root
system-entropy callers now get uninhabited output type failures before
secure-engine construction for `randomValue`, `fill`, `sample`, and
`fillSample`, while empty-output behavior remains no-entropy and S4-M11 remains
blocked.

S4-M625 adds root scalar range prevalidation
(`compare/results/s4-m625-root-scalar-range-prevalidation.md`): root
system-entropy callers now get invalid exclusive and inclusive range failures
before secure-engine construction for `randomRange`, `randomRangeAtMost`,
`fillRange`, and `fillRangeAtMost`, while empty-output and deterministic
collapsed paths remain no-entropy and S4-M11 remains blocked.

S4-M626 adds root random iterator empty-type prevalidation
(`compare/results/s4-m626-root-random-iter-empty-type-prevalidation.md`): root
system-entropy callers now get uninhabited element type failures before
secure-engine construction for `randomIter`, while ordinary iterator creation
remains entropy-backed and S4-M11 remains blocked.

S4-M627 adds root probability scalar/fill prevalidation
(`compare/results/s4-m627-root-probability-scalar-fill-prevalidation.md`): root
system-entropy callers now get invalid probability and ratio failures before
secure-engine construction for `randomBool`, `randomRatio`, `fillRandomBool`, and
`fillRandomRatio`, while empty-output and endpoint deterministic paths remain
no-entropy and S4-M11 remains blocked.

S4-M628 adds root secure bytes empty-output prevalidation
(`compare/results/s4-m628-root-secure-bytes-empty-prevalidation.md`): root
system-entropy callers now get deterministic empty-buffer returns before system
entropy for `secureBytes`, while non-empty buffers still request entropy and
S4-M11 remains blocked.

S4-M629 adds root duration scalar range prevalidation
(`compare/results/s4-m629-root-duration-scalar-prevalidation.md`): root
system-entropy callers now get invalid duration range failures before
secure-engine construction for `durationRangeLessThan` and
`durationRangeAtMost`, while deterministic collapsed inclusive paths remain
no-entropy and S4-M11 remains blocked.

S4-M630 adds root weighted value sample empty-type prevalidation
(`compare/results/s4-m630-root-weighted-value-sample-empty-type-prevalidation.md`):
root system-entropy callers now get non-zero uninhabited value type failures
before random-output allocation and secure-engine construction for
`sampleWeighted` and `sampleWeightedChecked`, while zero-amount and deterministic
all-zero/single paths remain allocation-only and S4-M11 remains blocked.

S4-M631 adds root item-accessor weighted value sample empty-type prevalidation
(`compare/results/s4-m631-root-weighted-by-value-sample-empty-type-prevalidation.md`):
root system-entropy callers now get non-zero uninhabited value type failures
before random-output allocation and secure-engine construction for
`sampleWeightedBy` and `sampleWeightedByChecked`, while zero-amount and
deterministic all-zero/single paths remain allocation-only and S4-M11 remains
blocked.

S4-M632 adds root weighted value array empty-type prevalidation
(`compare/results/s4-m632-root-weighted-value-array-empty-type-prevalidation.md`):
root system-entropy callers now get non-zero uninhabited value type failures
before secure-engine construction for `sampleWeightedArray` and
`sampleWeightedArrayChecked`, while zero-size and deterministic all-zero/single
paths remain no-entropy and S4-M11 remains blocked.

S4-M633 adds root item-accessor weighted value array empty-type prevalidation
(`compare/results/s4-m633-root-weighted-by-value-array-empty-type-prevalidation.md`):
root system-entropy callers now get non-zero uninhabited value type failures
before secure-engine construction for `sampleWeightedArrayBy` and
`sampleWeightedArrayByChecked`, while zero-size and deterministic all-zero/single
paths remain no-entropy and S4-M11 remains blocked.

S4-M634 adds root item-accessor weighted value choose array empty-type
prevalidation
(`compare/results/s4-m634-root-weighted-by-value-choice-array-empty-type-prevalidation.md`):
root system-entropy callers now get non-zero uninhabited value type failures
before secure-engine construction for `chooseWeightedValueArrayBy` and
`chooseWeightedValueArrayByChecked`, while zero-size and deterministic all-zero/
single paths remain no-entropy and S4-M11 remains blocked.

S4-M635 adds root weighted value choice array empty-type prevalidation
(`compare/results/s4-m635-root-weighted-value-choice-array-empty-type-prevalidation.md`):
root system-entropy callers now get non-zero uninhabited value type failures
before secure-engine construction for `chooseWeightedValueArray` and
`chooseWeightedValueArrayChecked`, while zero-size and deterministic all-zero/
single paths remain no-entropy and S4-M11 remains blocked.

S4-M636 adds root by-index weighted value choice array empty-type prevalidation
(`compare/results/s4-m636-root-weighted-by-index-value-choice-array-empty-type-prevalidation.md`):
root system-entropy callers now get non-zero uninhabited value type failures
before secure-engine construction for `chooseWeightedValueArrayByIndex` and
`chooseWeightedValueArrayByIndexChecked`, while zero-size and deterministic
all-zero/single paths remain no-entropy and S4-M11 remains blocked.

S4-M637 adds root unweighted value choose empty-type prevalidation
(`compare/results/s4-m637-root-value-choose-empty-type-prevalidation.md`): root
system-entropy callers now get non-empty uninhabited value type failures before
output allocation and secure-engine construction for unweighted value choose
helpers, while empty-output and singleton deterministic paths remain no-entropy
and S4-M11 remains blocked.

S4-M638 adds root unweighted index-into invalid-count prevalidation
(`compare/results/s4-m638-root-index-into-invalid-count-prevalidation.md`): root
system-entropy callers now get oversized output-buffer failures before
secure-engine construction for `sampleIndicesInto` and `sampleIndicesU32Into`,
while zero-output and full-range deterministic paths remain no-entropy and
S4-M11 remains blocked.

S4-M639 adds root unweighted index allocation invalid-count prevalidation
(`compare/results/s4-m639-root-index-alloc-invalid-count-prevalidation.md`):
root system-entropy callers now get oversized sample amount failures before
allocation and secure-engine construction for `sampleIndexVec`, `sampleIndices`,
and `sampleIndicesU32`, while zero-output and full-range deterministic paths
remain allocation-only and S4-M11 remains blocked.

S4-M640 adds root unweighted no-replacement allocation/iterator invalid-count
prevalidation
(`compare/results/s4-m640-root-no-replacement-alloc-iter-invalid-count-prevalidation.md`):
root system-entropy callers now get oversized sample amount failures before
allocation and secure-engine construction for `sampleWithoutReplacement`,
`samplePtrs`, `sampleMutPtrs`, `sampleItemsIter`, `samplePtrsIter`, and
`sampleMutPtrsIter`, while zero-output and full-range deterministic paths remain
allocation-only and S4-M11 remains blocked.

S4-M641 adds root checked iterator exact-short prevalidation
(`compare/results/s4-m641-root-iterator-exact-short-prevalidation.md`): checked
iterator sample helpers now use exact remaining metadata (`sizeHint`, `len`, or
`remaining`) to reject impossible requests before allocation, secure-engine
construction, and iterator consumption for scalar, into/fill, array, weighted
allocation, weighted into, and weighted array checked paths. This improves
failure determinism but does not resolve S4-M11.

S4-M642 adds root unchecked iterator exact-short prevalidation
(`compare/results/s4-m642-root-unchecked-iterator-exact-short-prevalidation.md`):
unchecked iterator allocation/array helpers now use exact remaining metadata to
avoid oversized allocation and return deterministic short/null results before
secure-engine construction and iterator consumption for `sampleIterator`,
`sampleIteratorArray`, and `sampleIteratorWeightedArray`. This improves
allocation/entropy behavior but does not resolve S4-M11.

S4-M643 adds root weighted index allocation prevalidation
(`compare/results/s4-m643-root-weighted-index-alloc-prevalidation.md`):
parallel-weighted index allocation helpers now resolve empty input, all-zero
weights, single-positive weights, checked oversized requests, invalid weights,
and u32 length limits before secure-engine construction for
`sampleWeightedIndices`, `sampleWeightedIndicesChecked`,
`sampleWeightedIndicesU32`, and `sampleWeightedIndicesU32Checked`. This improves
failure/result determinism but does not resolve S4-M11.

S4-M644 adds direct sequence index allocation invalid-count prevalidation
(`compare/results/s4-m644-seq-index-alloc-invalid-count-prevalidation.md`):
direct `seq` unchecked index allocation helpers now reject oversized sample
amounts before allocation and random-stream use for `sampleIndexVecFrom`,
`sampleIndicesFrom`, and `sampleIndicesU32From`, aligning the direct layer with
the root prevalidation work. This improves failure determinism but does not
resolve S4-M11.

S4-M645 adds `Rng` no-replacement invalid-count prevalidation
(`compare/results/s4-m645-rng-no-replacement-invalid-count-prevalidation.md`):
`Rng.sampleWithoutReplacement` and direct `sampleWithoutReplacementFrom` now
reject oversized sample counts before allocation and random-stream use, aligning
the method/direct RNG layer with the root and direct `seq` prevalidation work.
This improves failure determinism but does not resolve S4-M11.

S4-M646 adds ASCII charset unchecked empty prevalidation
(`compare/results/s4-m646-ascii-charset-unchecked-empty-prevalidation.md`):
ASCII `Charset` allocation/string helpers now reject non-zero empty charsets
before allocation, random-stream use, and append-buffer mutation for
`Charset.allocFrom`, `Charset.sampleStringFrom`, and `Charset.appendStringFrom`,
while zero-length calls remain deterministic no-stream operations. This improves
failure determinism but does not resolve S4-M11.

S4-M647 adds Unicode charset unchecked invalid prevalidation
(`compare/results/s4-m647-unicode-charset-unchecked-invalid-prevalidation.md`):
`UnicodeCharset` UTF-8 string helpers now reject non-zero empty or invalid scalar
sets before allocation, random-stream use, and append-buffer mutation for
`UnicodeCharset.sampleStringFrom` and `UnicodeCharset.appendStringFrom`, while
zero-length calls remain deterministic no-stream operations. This improves
failure determinism but does not resolve S4-M11.

S4-M648 adds `Rng` unchecked repeated choice empty prevalidation
(`compare/results/s4-m648-rng-repeated-choice-empty-prevalidation.md`): repeated
value, const-pointer, mutable-pointer, usize-index, and u32-index batch helpers
now reject non-zero empty inputs before allocation and random-stream use for
`chooseBatchFrom`, `chooseConstPtrBatchFrom`, `choosePtrBatchFrom`,
`chooseIndexBatchFrom`, and `chooseIndexU32BatchFrom`, while zero-count calls
remain deterministic allocation-only operations. This improves failure
determinism but does not resolve S4-M11.

S4-M649 adds `seq` unchecked repeated choice empty prevalidation
(`compare/results/s4-m649-seq-repeated-choice-empty-prevalidation.md`): seq
repeated value, const-pointer, mutable-pointer, usize-index, and u32-index batch
aliases now reject non-zero empty inputs before allocation and random-stream use
for `chooseBatchFrom`, `chooseConstPtrBatchFrom`, `choosePtrBatchFrom`,
`chooseIndexBatchFrom`, and `chooseIndexU32BatchFrom`, preserving seq-style
`error.EmptyInput` while zero-count calls remain deterministic allocation-only
operations. This improves failure determinism but does not resolve S4-M11.

S4-M650 adds `Rng` repeated choice fill empty-output prevalidation
(`compare/results/s4-m650-rng-choice-fill-empty-output-prevalidation.md`):
unchecked repeated value, const-pointer, mutable-pointer, usize-index, and
u32-index fill helpers now treat empty output buffers as deterministic no-ops
before validating empty choice sets or relying on assertions in
`fillChooseFrom`, `fillChooseConstPtrFrom`, `fillChoosePtrFrom`,
`fillChooseIndexFrom`, and `fillChooseIndexU32From`. This improves no-op
determinism but does not resolve S4-M11.

S4-M651 adds `Rng` weighted nullable batch prevalidation
(`compare/results/s4-m651-rng-weighted-nullable-batch-prevalidation.md`):
unchecked weighted nullable fill/batch helpers now resolve invalid weights,
all-zero weights, single-positive weights, u32 length limits, and empty outputs
before repeated one-shot sampling and avoid unnecessary random-stream use for
weighted index, u32 weighted index, weighted value, const-pointer, and
mutable-pointer nullable batch workflows. This improves failure/result
determinism but does not resolve S4-M11.

S4-M652 adds `Rng` scalar fill empty-output prevalidation
(`compare/results/s4-m652-rng-scalar-fill-empty-output-prevalidation.md`):
unchecked scalar range/probability fill helpers now treat empty output buffers as
deterministic no-ops before invalid range/probability assertions in
`fillRangeFrom`, `fillRangeAtMostFrom`, `fillUintLessThanFrom`,
`fillChanceFrom`, and `fillRatioFrom`. This improves no-op determinism but does
not resolve S4-M11.

S4-M653 adds `Rng` vector fill empty-output prevalidation
(`compare/results/s4-m653-rng-vector-fill-empty-output-prevalidation.md`):
unchecked vector range/probability fill helpers now treat empty output buffers as
deterministic no-ops before invalid range/probability assertions in
`fillVectorRangeFrom`, `fillVectorRangeAtMostFrom`, `fillVectorChanceFrom`, and
`fillVectorRatioFrom`. This improves no-op determinism but does not resolve
S4-M11.

S4-M654 adds `Rng` scalar normal/exponential fill empty-output prevalidation
(`compare/results/s4-m654-rng-normal-exponential-fill-empty-output-prevalidation.md`):
unchecked scalar normal and exponential fill helpers now treat empty output
buffers as deterministic no-ops before invalid parameter assertions in
`fillNormalFrom` and `fillExponentialFrom`. This improves no-op determinism but
does not resolve S4-M11.

S4-M655 adds `Rng` vector normal/exponential fill empty-output prevalidation
(`compare/results/s4-m655-rng-vector-normal-exponential-fill-empty-output-prevalidation.md`):
unchecked vector normal and exponential fill helpers now treat empty output
buffers as deterministic no-ops before invalid parameter assertions in
`fillVectorNormalFrom` and `fillVectorExponentialFrom`. This improves no-op
determinism but does not resolve S4-M11.

S4-M656 adds `Rng` scalar normal/exponential batch invalid-parameter
prevalidation
(`compare/results/s4-m656-rng-normal-exponential-batch-invalid-prevalidation.md`):
unchecked scalar normal and exponential allocation-returning batch helpers now
reject invalid parameters before allocation and random-stream use in
`normalBatchFrom` and `exponentialBatchFrom`, while valid allocation failures
remain no-stream. This improves failure determinism but does not resolve S4-M11.

S4-M657 adds `Rng` vector normal/exponential batch invalid-parameter
prevalidation
(`compare/results/s4-m657-rng-vector-normal-exponential-batch-invalid-prevalidation.md`):
unchecked vector normal and exponential allocation-returning batch helpers now
reject invalid parameters before allocation and random-stream use in
`vectorNormalBatchFrom` and `vectorExponentialBatchFrom`, while valid allocation
failures remain no-stream. This improves failure determinism but does not
resolve S4-M11.

S4-M658 adds `Rng` scalar range/probability batch invalid-parameter
prevalidation
(`compare/results/s4-m658-rng-scalar-batch-invalid-prevalidation.md`):
unchecked scalar range and probability allocation-returning batch helpers now
reject invalid parameters before allocation and random-stream use in
`rangeBatchFrom`, `rangeAtMostBatchFrom`, `uintLessThanBatchFrom`,
`chanceBatchFrom`, and `ratioBatchFrom`, while valid allocation failures remain
no-stream. This improves failure determinism but does not resolve S4-M11.

S4-M659 adds `Rng` vector range/probability batch invalid-parameter
prevalidation
(`compare/results/s4-m659-rng-vector-batch-invalid-prevalidation.md`):
unchecked vector range and probability allocation-returning batch helpers now
reject invalid parameters before allocation and random-stream use in
`vectorRangeBatchFrom`, `vectorRangeAtMostBatchFrom`, `vectorChanceBatchFrom`,
and `vectorRatioBatchFrom`, while valid allocation failures remain no-stream.
This improves failure determinism but does not resolve S4-M11.

S4-M660 adds `Rng` duration batch invalid-range prevalidation
(`compare/results/s4-m660-rng-duration-batch-invalid-prevalidation.md`):
unchecked duration allocation-returning range batch helpers now reject invalid
exclusive and inclusive duration ranges before allocation and random-stream use
in `durationRangeLessThanBatchFrom` and `durationRangeAtMostBatchFrom`, while
valid allocation failures remain no-stream. This improves failure determinism but
does not resolve S4-M11.

S4-M661 adds `Rng` Unicode scalar range batch invalid-parameter prevalidation
(`compare/results/s4-m661-rng-unicode-batch-invalid-prevalidation.md`):
unchecked Unicode scalar allocation-returning range batch helpers now reject
invalid scalars and empty ranges before allocation and random-stream use in
`unicodeScalarRangeLessThanBatchFrom` and
`unicodeScalarRangeAtMostBatchFrom`, while valid allocation failures remain
no-stream. This improves failure determinism but does not resolve S4-M11.

S4-M662 adds `Rng` Unicode scalar fill empty-output prevalidation
(`compare/results/s4-m662-rng-unicode-fill-empty-output-prevalidation.md`):
unchecked Unicode scalar range fill helpers now treat empty output buffers as
deterministic no-ops before invalid scalar/range validation in
`fillUnicodeScalarRangeLessThanFrom` and `fillUnicodeScalarRangeAtMostFrom`.
This improves no-op determinism but does not resolve S4-M11.

S4-M663 adds `Rng` value batch empty-type prevalidation
(`compare/results/s4-m663-rng-value-batch-empty-type-prevalidation.md`):
unchecked value allocation-returning batch helpers now reject non-zero empty
enum-containing value types before allocation and random-stream use in
`valueBatchFrom`, while zero-count requests remain deterministic empty
allocations. This improves failure determinism but does not resolve S4-M11.

S4-M664 adds `Rng` sample batch empty-type prevalidation
(`compare/results/s4-m664-rng-sample-batch-empty-type-prevalidation.md`):
unchecked sampler allocation-returning batch helpers now reject non-zero empty
enum-containing output types before allocation and random-stream use in
`sampleBatchFrom`, while zero-count requests remain deterministic empty
allocations. This improves failure determinism but does not resolve S4-M11.

S4-M665 adds `Rng` sampler fill empty-output prevalidation
(`compare/results/s4-m665-rng-sampler-fill-empty-output-prevalidation.md`):
generic sampler fill helpers now treat empty output buffers as deterministic
no-ops before invoking sampler-provided fill hooks in `fillSample` and
`fillSampleFrom`, including iterator fill routes. This improves no-op
determinism but does not resolve S4-M11.

S4-M666 adds root checked index batch empty-range prevalidation
(`compare/results/s4-m666-root-checked-index-batch-empty-range-prevalidation.md`):
root checked index allocation-returning batch helpers now reject non-zero
zero-length usize/u32 ranges before allocation and secure-engine construction in
`chooseIndexBatchChecked` and `chooseIndexU32BatchChecked`, while zero-count
requests remain deterministic empty allocations. This improves failure
determinism but does not resolve S4-M11.

S4-M667 adds `Rng` no-replacement empty-type prevalidation
(`compare/results/s4-m667-rng-no-replacement-empty-type-prevalidation.md`):
`Rng` no-replacement value sampling now rejects non-zero empty enum-containing
value types before allocation and random-stream use in
`sampleWithoutReplacement`, `sampleWithoutReplacementFrom`, and
`sampleWithoutReplacementCheckedFrom`, while zero-count requests remain
deterministic empty allocations. This improves failure determinism but does not
resolve S4-M11.

S4-M668 adds root `chooseMultiple` empty-type prevalidation
(`compare/results/s4-m668-root-choose-multiple-empty-type-prevalidation.md`):
root `chooseMultiple` value alias now rejects non-zero empty enum-containing
value types before allocation and secure-engine construction, including full
count deterministic alias requests, while zero-count requests remain
deterministic empty allocations. This improves failure determinism but does not
resolve S4-M11.

S4-M669 adds root fixed value array empty-type prevalidation
(`compare/results/s4-m669-root-value-array-empty-type-prevalidation.md`):
root fixed-size no-replacement value array helpers now reject non-zero empty
enum-containing value types before secure-engine construction and before
deterministic full-count value copying in `sampleItemsArray` and
`sampleItemsArrayChecked`; `chooseArray` aliases inherit the same behavior. This
improves failure determinism but does not resolve S4-M11.

S4-M670 adds root caller-owned value sample empty-type prevalidation
(`compare/results/s4-m670-root-value-into-empty-type-prevalidation.md`):
root caller-owned no-replacement value buffer helpers now reject non-zero empty
enum-containing value types before secure-engine construction and before
deterministic full-count value copying in `sampleItemsInto` and
`sampleItemsIntoChecked`; `chooseMultipleInto` aliases inherit the same behavior.
This improves failure determinism but does not resolve S4-M11.

S4-M671 adds `seq` fixed value array empty-type prevalidation
(`compare/results/s4-m671-seq-value-array-empty-type-prevalidation.md`): `seq`
fixed-size no-replacement value array helpers now reject non-zero empty
enum-containing value types before index sampling and value copying in
`chooseArrayFrom` and `chooseArrayCheckedFrom`; `sampleItemsArray` aliases
inherit the same behavior. This improves failure determinism but does not
resolve S4-M11.

S4-M672 adds `seq` caller-owned value sample empty-type prevalidation
(`compare/results/s4-m672-seq-value-into-empty-type-prevalidation.md`): `seq`
caller-owned no-replacement value buffer helpers now reject non-zero empty
enum-containing value types before index sampling and value copying in
`chooseMultipleIntoFrom` and `chooseMultipleIntoCheckedFrom`; `sampleItemsInto`
aliases inherit the same behavior. This improves failure determinism but does
not resolve S4-M11.

S4-M673 adds `seq` owned value sample empty-type prevalidation
(`compare/results/s4-m673-seq-owned-value-empty-type-prevalidation.md`): `seq`
allocation-returning no-replacement value sample helpers now reject non-zero
empty enum-containing value types before output/index allocation and
random-stream use in `chooseMultipleFrom` and `chooseMultipleCheckedFrom`;
`sampleItems` aliases inherit the same behavior. This improves failure
determinism but does not resolve S4-M11.

S4-M674 adds `seq` sampled value iterator empty-type prevalidation
(`compare/results/s4-m674-seq-value-iter-empty-type-prevalidation.md`): `seq`
sampled value iterator helpers now reject non-zero empty enum-containing value
types before index allocation and random-stream use in `sampleItemsIterFrom` and
`sampleItemsIterCheckedFrom`. This improves failure determinism but does not
resolve S4-M11.

S4-M675 adds `IndexVec` value mapping empty-type prevalidation
(`compare/results/s4-m675-indexvec-value-empty-type-prevalidation.md`):
`IndexVec` value mapping helpers now reject non-empty empty enum-containing value
types before owned allocation and value copying in `valuesChecked`,
`valuesInto`, and `valuesOwned`; checked/owned wrappers inherit the same
behavior. This improves failure determinism but does not resolve S4-M11.

S4-M676 adds reservoir value sample empty-type prevalidation
(`compare/results/s4-m676-reservoir-value-empty-type-prevalidation.md`):
`seq` and root reservoir value sampling now reject non-zero empty
enum-containing value types before allocation, entropy, random-stream use, and
value copying in `reservoirSample*` and `reservoirSampleInto*` value helpers.
This improves failure determinism but does not resolve S4-M11.

S4-M677 adds `seq` iterator reservoir empty-type prevalidation
(`compare/results/s4-m677-seq-iterator-value-empty-type-prevalidation.md`):
`seq` iterator reservoir value helpers now reject non-zero empty
enum-containing value types before allocation, iterator consumption, and
random-stream use in `sampleIteratorFrom`, `sampleIteratorCheckedFrom`,
`sampleIteratorArrayFrom`, `sampleIteratorArrayCheckedFrom`, and
`sampleIteratorIntoCheckedFrom`. This improves failure determinism but does not
resolve S4-M11.

S4-M678 adds root iterator reservoir empty-type prevalidation
(`compare/results/s4-m678-root-iterator-value-empty-type-prevalidation.md`):
root iterator reservoir value helpers now reject non-zero empty enum-containing
value types before allocation, entropy, iterator consumption, and secure-engine
construction in `sampleIterator`, `sampleIteratorChecked`,
`sampleIteratorInto`, `sampleIteratorIntoChecked`, `sampleIteratorArray`, and
`sampleIteratorArrayChecked`. This improves failure determinism but does not
resolve S4-M11.

S4-M679 adds `seq` weighted iterator reservoir empty-type prevalidation
(`compare/results/s4-m679-seq-weighted-iterator-empty-type-prevalidation.md`):
`seq` weighted iterator reservoir value helpers now reject non-zero empty
enum-containing value types before heap allocation, iterator consumption, and
random-stream use in `sampleIteratorWeightedFrom`,
`sampleIteratorWeightedCheckedFrom`, `sampleIteratorWeightedIntoFrom`,
`sampleIteratorWeightedIntoCheckedFrom`, `sampleIteratorWeightedArrayFrom`, and
`sampleIteratorWeightedArrayCheckedFrom`. This improves failure determinism but
does not resolve S4-M11.

S4-M680 adds root weighted iterator reservoir empty-type prevalidation
(`compare/results/s4-m680-root-weighted-iterator-empty-type-prevalidation.md`):
root weighted iterator reservoir value helpers now reject non-zero empty
enum-containing value types before allocation, entropy, iterator consumption,
heap allocation, and secure-engine construction in `sampleIteratorWeighted`,
`sampleIteratorWeightedChecked`, `sampleIteratorWeightedInto`,
`sampleIteratorWeightedIntoChecked`, `sampleIteratorWeightedArray`, and
`sampleIteratorWeightedArrayChecked`. This improves failure determinism but does
not resolve S4-M11.

S4-M681 adds `seq` weighted value choice empty-type prevalidation
(`compare/results/s4-m681-seq-weighted-value-empty-type-prevalidation.md`):
`seq` weighted value choice helpers now reject non-zero empty enum-containing
value types before weighted-index sampling, allocation, random-stream use, and
value copying in scalar, fill, array, and batch value-choice paths. This improves
failure determinism but does not resolve S4-M11.

S4-M682 adds `seq` accessor-weighted value choice empty-type prevalidation
(`compare/results/s4-m682-seq-weighted-by-value-empty-type-prevalidation.md`):
`seq` item-accessor weighted value choice helpers now reject non-zero
uninhabited value types before accessor weight evaluation, weighted-index
sampling, allocation, random-stream use, and value copying in scalar, fill,
array, and batch value-choice paths. This improves failure determinism but does
not resolve S4-M11.

S4-M683 adds `seq` index-weighted value choice empty-type prevalidation
(`compare/results/s4-m683-seq-weighted-by-index-value-empty-type-prevalidation.md`):
`seq` index-weighted value choice helpers now reject non-zero empty
enum-containing value types before index-weight validation, weighted-index
sampling, allocation, random-stream use, and value copying in scalar, fill,
array, and batch value-choice paths. This improves failure determinism but does
not resolve S4-M11.

S4-M684 adds root accessor-weighted value choice empty-type prevalidation
(`compare/results/s4-m684-root-weighted-by-value-empty-type-prevalidation.md`):
root item-accessor weighted value choice helpers now reject non-zero
uninhabited value types before accessor weight evaluation, allocation, entropy,
and value copying in scalar, fill, array, and batch value-choice paths. This
improves failure determinism but does not resolve S4-M11.

S4-M685 adds root index-weighted value choice empty-type prevalidation
(`compare/results/s4-m685-root-weighted-by-index-value-empty-type-prevalidation.md`):
root index-weighted value choice helpers now reject non-zero empty
enum-containing value types before index-weight validation, allocation, entropy,
and value copying in scalar, fill, array, and batch value-choice paths. This
improves failure determinism but does not resolve S4-M11.

S4-M686 adds root weighted value choice empty-type prevalidation
(`compare/results/s4-m686-root-weighted-value-empty-type-prevalidation.md`):
root parallel-weight value choice helpers now reject non-zero empty
enum-containing value types before weighted-index sampling, allocation, entropy,
and value copying in scalar, fill, array, and batch value-choice paths. This
improves failure determinism but does not resolve S4-M11.

S4-M687 adds `Rng` regular-struct empty-type prevalidation
(`compare/results/s4-m687-rng-regular-struct-empty-type-prevalidation.md`):
`Rng` empty-type detection now rejects regular structs containing empty enum
fields before allocation and random-stream use in value batches, sampler
batches, and no-replacement value samples. This improves failure determinism but
does not resolve S4-M11.

S4-M688 adds `seq` weighted sample empty-type prevalidation
(`compare/results/s4-m688-seq-weighted-sample-empty-type-prevalidation.md`):
`seq` parallel-weighted no-replacement value sample helpers now reject non-zero
empty enum-containing value types before allocation, weighted-key sampling,
random-stream use, and value copying in allocation-returning, caller-owned, and
fixed-array paths. This improves failure determinism but does not resolve
S4-M11.

S4-M689 adds `seq` accessor-weighted sample empty-type prevalidation
(`compare/results/s4-m689-seq-weighted-by-sample-empty-type-prevalidation.md`):
`seq` item-accessor weighted no-replacement value sample helpers now reject
non-zero empty enum-containing value types before accessor weight evaluation,
allocation, weighted-key sampling, random-stream use, and value copying in
allocation-returning, caller-owned, and fixed-array paths. This improves failure
determinism but does not resolve S4-M11.

S4-M690 adds root weighted into empty-type prevalidation
(`compare/results/s4-m690-root-weighted-into-empty-type-prevalidation.md`):
root parallel-weight and item-accessor weighted no-replacement caller-owned value
helpers now reject non-zero empty enum-containing output types before accessor
weight evaluation, entropy, secure-engine construction, weighted-key sampling,
random-stream use, and value copying. This improves failure determinism but does
not resolve S4-M11.

S4-M691 adds `Rng` weighted value empty-type prevalidation
(`compare/results/s4-m691-rng-weighted-value-empty-type-prevalidation.md`):
`Rng` weighted value-choice helpers now reject non-zero empty enum-containing
output types before allocation, weighted-index sampling, random-stream use, and
value copying in scalar, fill, array, and batch paths. This improves failure
determinism but does not resolve S4-M11.

S4-M692 adds `Rng` value choice empty-type prevalidation
(`compare/results/s4-m692-rng-value-choice-empty-type-prevalidation.md`):
`Rng` unweighted value-choice helpers now reject non-zero empty enum-containing
output types before allocation, index sampling, random-stream use, and value
copying in scalar, fill, array, and batch paths. This improves failure
determinism but does not resolve S4-M11.

S4-M693 adds `seq` repeated value array empty-type prevalidation
(`compare/results/s4-m693-seq-repeated-value-array-empty-type-prevalidation.md`):
`seq` repeated with-replacement fixed value arrays now reject non-zero empty
enum-containing output types before random-stream use and value copying. This
improves failure determinism but does not resolve S4-M11.

S4-M694 adds `seq` repeated value fill/batch empty-type prevalidation
(`compare/results/s4-m694-seq-repeated-value-fill-batch-empty-type-prevalidation.md`):
`seq` repeated with-replacement value fill/batch aliases now reject non-zero empty
enum-containing output types before allocation, random-stream use, and value
copying. This improves failure determinism but does not resolve S4-M11.

S4-M695 adds `seq` one-shot choice empty-type prevalidation
(`compare/results/s4-m695-seq-one-shot-choice-empty-type-prevalidation.md`):
`seq` one-shot value choice aliases now reject non-empty empty enum-containing
output types before random-stream use and value copying while preserving
seq-style `error.EmptyInput`. This improves failure determinism but does not
resolve S4-M11.

S4-M696 adds `seq` iterator choice empty-type prevalidation
(`compare/results/s4-m696-seq-iterator-choice-empty-type-prevalidation.md`):
`seq` one-shot iterator value choice helpers now reject empty enum-containing
output types before iterator consumption, random-stream use, and value copying.
This improves failure determinism but does not resolve S4-M11.

S4-M697 adds root iterator choice empty-type prevalidation
(`compare/results/s4-m697-root-iterator-choice-empty-type-prevalidation.md`):
root one-shot iterator value choice helpers now reject empty enum-containing
output types before iterator consumption, entropy, secure-engine construction,
random-stream use, and value copying. This improves failure determinism but does
not resolve S4-M11.

S4-M698 adds root weighted iterator choice empty-type prevalidation
(`compare/results/s4-m698-root-weighted-iterator-choice-empty-type-prevalidation.md`):
root weighted iterator one-shot value choice helpers now reject empty
enum-containing output types before iterator consumption, weight evaluation,
entropy, secure-engine construction, random-stream use, and value copying. This
improves failure determinism but does not resolve S4-M11.

S4-M699 adds root sampled value iterator empty-type prevalidation
(`compare/results/s4-m699-root-sampled-value-iter-empty-type-prevalidation.md`):
root sampled value iterator aliases now reject non-zero empty enum-containing
output types before index allocation, entropy, secure-engine construction,
random-stream use, iterator construction, and value copying. This improves
failure determinism but does not resolve S4-M11.

S4-M700 adds `seq` weighted iterator choice empty-type prevalidation
(`compare/results/s4-m700-seq-weighted-iterator-choice-empty-type-prevalidation.md`):
`seq` weighted iterator one-shot value choice helpers now reject empty
enum-containing output types before iterator consumption, weight evaluation,
random-stream use, and value copying. This improves failure determinism but does
not resolve S4-M11.

S4-M701 adds `seq` unchecked iterator into empty-type prevalidation
(`compare/results/s4-m701-seq-unchecked-iterator-into-empty-type-prevalidation.md`):
`seq` unchecked caller-owned iterator value fills now treat non-empty empty
enum-containing output buffers as zero-fill no-ops before iterator consumption,
random-stream use, and value copying. This improves failure determinism but does
not resolve S4-M11.

S4-M702 adds `seq` weighted choice iterator empty-type prevalidation
(`compare/results/s4-m702-seq-weighted-choice-iter-empty-type-prevalidation.md`):
`seq` reusable weighted choice iterator constructors now reject non-empty empty
enum-containing value types before weight validation/evaluation, allocation,
random-stream use, iterator construction, and value access. This improves
failure determinism but does not resolve S4-M11.

S4-M703 adds `WeightedChoice` value-copy empty-type prevalidation
(`compare/results/s4-m703-weightedchoice-value-copy-empty-type-prevalidation.md`):
reusable `WeightedChoice` value-copy helpers now handle non-empty empty
enum-containing output types before allocation, random-stream use, and value
copying. This improves failure determinism but does not resolve S4-M11.

S4-M704 adds `Choice` value-copy empty-type prevalidation
(`compare/results/s4-m704-choice-value-copy-empty-type-prevalidation.md`):
reusable `Choice` value-copy helpers now handle non-empty empty
enum-containing output types before allocation, random-stream use, and value
copying. This improves failure determinism but does not resolve S4-M11.

S4-M705 adds reusable `Choice` checked value arrays
(`compare/results/s4-m705-choice-checked-value-array.md`): reusable `Choice` now
has checked fixed-size value array helpers that reject non-zero empty
enum-containing output types before random-stream use and value copying. This
improves failure determinism but does not resolve S4-M11.

S4-M706 adds reusable `WeightedChoice` checked value arrays
(`compare/results/s4-m706-weightedchoice-checked-value-array.md`): reusable
`WeightedChoice` now has checked fixed-size value array helpers that reject
non-zero empty enum-containing output types before random-stream use and value
copying. This improves failure determinism but does not resolve S4-M11.

S4-M707 adds distribution-layer `Choose` value-copy empty-type prevalidation
(`compare/results/s4-m707-distribution-choose-value-copy-empty-type-prevalidation.md`):
distribution-layer `Choose` value-copy fills now handle non-empty empty
enum-containing output types before random-stream use and value copying. This
improves failure determinism but does not resolve S4-M11.

S4-M708 adds distribution-layer `Choose` value arrays
(`compare/results/s4-m708-distribution-choose-value-array.md`):
distribution-layer `Choose` now has fixed-size value array helpers, including
checked empty-type failures before random-stream use and value copying. This
improves stack-friendly ergonomics but does not resolve S4-M11.

S4-M709 adds distribution-layer `Choose` owned values
(`compare/results/s4-m709-distribution-choose-owned-values.md`):
distribution-layer `Choose` now has allocation-returning repeated value helpers
with empty-type failures before allocation, random-stream use, and value copying.
This improves owned-output ergonomics but does not resolve S4-M11.

S4-M710 adds distribution-layer `Choose` pointer outputs
(`compare/results/s4-m710-distribution-choose-pointer-outputs.md`):
distribution-layer `Choose` now has fixed-size and owned pointer output helpers
matching reference-oriented choice workflows. This improves ergonomics but does
not resolve S4-M11.

S4-M711 adds distribution-layer `Choose` index outputs
(`compare/results/s4-m711-distribution-choose-index-outputs.md`):
distribution-layer `Choose` now has scalar, caller-owned, owned, and fixed-size
usize index output helpers aligned with item sampling stream shape. This
improves ergonomics but does not resolve S4-M11.

S4-M712 adds distribution-layer `Choose` u32 index outputs
(`compare/results/s4-m712-distribution-choose-u32-index-outputs.md`):
distribution-layer `Choose` now has scalar, caller-owned, owned, and fixed-size
u32 index output helpers aligned with item sampling stream shape. This improves
compact-output ergonomics but does not resolve S4-M11.

S4-M713 adds distribution-layer `Choose` index iterators
(`compare/results/s4-m713-distribution-choose-index-iterators.md`):
distribution-layer `Choose` now has reusable usize and u32 index iterators aligned
with its fill helpers. This improves iterator ergonomics but does not resolve
S4-M11.

S4-M714 adds distribution-layer `Choose` introspection
(`compare/results/s4-m714-distribution-choose-introspection.md`):
distribution-layer `Choose` now exposes item metadata and lookup helpers on the
sampler. This improves ergonomics but does not resolve S4-M11.

S4-M715 adds distribution-layer `Choose` probability introspection
(`compare/results/s4-m715-distribution-choose-probability-introspection.md`):
distribution-layer `Choose` now exposes probability lookup/output/iteration
helpers and exact iterator size hints. This improves diagnostics/ergonomics but
does not resolve S4-M11.

S4-M716 adds distribution-layer `Choose` checked index aliases
(`compare/results/s4-m716-distribution-choose-checked-index-aliases.md`):
distribution-layer `Choose` now has checked aliases for scalar, caller-owned,
owned, and fixed-size usize index outputs. This improves discoverability but does
not resolve S4-M11.

S4-M717 adds distribution-layer `Choose` checked u32 index aliases
(`compare/results/s4-m717-distribution-choose-checked-u32-index-aliases.md`):
distribution-layer `Choose` now has checked aliases for scalar, caller-owned,
owned, and fixed-size u32 index outputs. This improves discoverability but does
not resolve S4-M11.

S4-M718 adds distribution-layer `Choose` checked values
(`compare/results/s4-m718-distribution-choose-checked-values.md`):
distribution-layer `Choose` now has checked scalar value-copy helpers with
empty-type failures before random-stream use and value copying. This improves
fallible value-copy ergonomics but does not resolve S4-M11.

S4-M719 adds distribution-layer `Choose` pointer iterators
(`compare/results/s4-m719-distribution-choose-pointer-iterators.md`):
distribution-layer `Choose` now has reusable pointer iterators aligned with its
fill helpers. This improves iterator ergonomics but does not resolve S4-M11.

S4-M720 adds distribution-layer `Choose` checked pointer aliases
(`compare/results/s4-m720-distribution-choose-checked-pointer-aliases.md`):
distribution-layer `Choose` now has checked aliases for caller-owned, owned, and
fixed-size pointer outputs. This improves discoverability but does not resolve
S4-M11.

S4-M721 adds distribution-layer `Choose` value iterators
(`compare/results/s4-m721-distribution-choose-value-iterators.md`):
distribution-layer `Choose` now has reusable value iterators aligned with its fill
helpers, including empty-type no-consumption behavior. This improves iterator
ergonomics but does not resolve S4-M11.

S4-M722 adds distribution-layer `Choose` checked iterator aliases
(`compare/results/s4-m722-distribution-choose-checked-iterator-aliases.md`):
distribution-layer `Choose` now has checked aliases for value, pointer, and usize
index iterators, including empty-type failures for checked value iterators. This
improves discoverability but does not resolve S4-M11.

S4-M723 adds reusable `Choice` checked scalar values
(`compare/results/s4-m723-choice-checked-values.md`): reusable `Choice` now has
checked scalar value-copy helpers with seq-style empty-type failures before
random-stream use and value copying. This improves fallible value-copy ergonomics
but does not resolve S4-M11.

S4-M724 adds reusable `WeightedChoice` checked scalar values
(`compare/results/s4-m724-weightedchoice-checked-values.md`): reusable
`WeightedChoice` now has checked scalar value-copy helpers with seq-style
empty-type failures before random-stream use and value copying. This improves
weighted fallible value-copy ergonomics but does not resolve S4-M11.

S4-M725 adds reusable `Choice` value iterators
(`compare/results/s4-m725-choice-value-iterators.md`): reusable `Choice` now has
allocation-free value-copy iterators plus checked empty-type construction. This
improves repeated value-copy ergonomics but does not resolve S4-M11.

S4-M726 adds reusable `WeightedChoice` value iterators
(`compare/results/s4-m726-weightedchoice-value-iterators.md`): reusable
`WeightedChoice` now has allocation-free weighted value-copy iterators plus
checked empty-type construction. This improves repeated weighted value-copy
ergonomics but does not resolve S4-M11.

S4-M727 adds reusable `Choice` pointer iterator aliases
(`compare/results/s4-m727-choice-pointer-iterator-aliases.md`): reusable
`Choice` now has explicit `ptrIter*` aliases and checked aliases that preserve
existing pointer iterator stream shape. This improves discoverability but does
not resolve S4-M11.

S4-M728 adds reusable `WeightedChoice` pointer iterator aliases
(`compare/results/s4-m728-weightedchoice-pointer-iterator-aliases.md`):
reusable `WeightedChoice` now has explicit `ptrIter*` aliases and checked
aliases that preserve existing weighted pointer iterator stream shape. This
improves discoverability but does not resolve S4-M11.

S4-M729 adds reusable `Choice` checked pointer aliases
(`compare/results/s4-m729-choice-checked-pointer-aliases.md`): reusable
`Choice` now has checked aliases for caller-owned, owned, and fixed-size pointer
outputs while preserving existing pointer stream shape. This improves
discoverability but does not resolve S4-M11.

S4-M730 adds reusable `WeightedChoice` checked pointer aliases
(`compare/results/s4-m730-weightedchoice-checked-pointer-aliases.md`): reusable
`WeightedChoice` now has checked aliases for caller-owned, owned, and fixed-size
weighted pointer outputs while preserving existing weighted pointer stream shape.
This improves discoverability but does not resolve S4-M11.

S4-M731 adds reusable `Choice` checked `usize` index aliases
(`compare/results/s4-m731-choice-checked-index-aliases.md`): reusable `Choice`
now has checked aliases for scalar, caller-owned, owned, fixed-size, and iterator
`usize` index outputs while preserving existing index stream shape. This improves
discoverability but does not resolve S4-M11.

S4-M732 adds reusable `WeightedChoice` checked `usize` index aliases
(`compare/results/s4-m732-weightedchoice-checked-index-aliases.md`): reusable
`WeightedChoice` now has checked aliases for scalar, caller-owned, owned,
fixed-size, and iterator weighted `usize` index outputs while preserving existing
weighted index stream shape. This improves discoverability but does not resolve
S4-M11.

S4-M733 adds reusable `Choice` checked compact `u32` index aliases
(`compare/results/s4-m733-choice-checked-u32-index-aliases.md`): reusable
`Choice` now has checked aliases for scalar, caller-owned, owned, fixed-size, and
iterator compact `u32` index outputs while preserving existing compact index
stream shape. This improves discoverability but does not resolve S4-M11.

S4-M734 adds reusable `WeightedChoice` checked compact `u32` index aliases
(`compare/results/s4-m734-weightedchoice-checked-u32-index-aliases.md`):
reusable `WeightedChoice` now has checked aliases for scalar, caller-owned,
owned, fixed-size, and iterator compact weighted `u32` index outputs while
preserving existing compact weighted index stream shape. This improves
discoverability but does not resolve S4-M11.

S4-M735 adds reusable `Choice` checked value batches
(`compare/results/s4-m735-choice-checked-value-batches.md`): reusable `Choice`
now has checked aliases for caller-owned and allocation-returning value-copy
batches, including empty-type failures before random-stream use or allocation.
This improves fallible value-copy ergonomics but does not resolve S4-M11.

S4-M736 adds reusable `WeightedChoice` checked value batches
(`compare/results/s4-m736-weightedchoice-checked-value-batches.md`): reusable
`WeightedChoice` now has checked aliases for caller-owned and
allocation-returning weighted value-copy batches, including empty-type failures
before random-stream use or allocation. This improves fallible weighted
value-copy ergonomics but does not resolve S4-M11.

S4-M737 adds distribution-layer `Choose` checked value batches
(`compare/results/s4-m737-distribution-choose-checked-value-batches.md`):
distribution-layer `Choose` now has checked aliases for caller-owned and
allocation-returning value-copy batches, including empty-type failures before
random-stream use or allocation. This improves fallible value-copy ergonomics but
does not resolve S4-M11.

S4-M738 adds distribution-layer `Choose` checked compact `u32` iterators
(`compare/results/s4-m738-distribution-choose-checked-u32-iterators.md`):
distribution-layer `Choose` now has checked aliases for compact `u32` index
iterators while preserving existing stream shape and width validation. This
improves discoverability but does not resolve S4-M11.

S4-M739 adds static `AliasTable` checked iterators
(`compare/results/s4-m739-aliastable-checked-iterators.md`): static
`AliasTable` now has checked aliases for `usize` and compact `u32` index
iterators while preserving existing stream shape and compact width validation.
This improves discoverability but does not resolve S4-M11.

S4-M740 adds dynamic weighted-tree checked iterators
(`compare/results/s4-m740-weighted-tree-checked-iterators.md`): dynamic
`WeightedTree` and `WeightedIntTree` now have checked aliases for `usize` and
compact `u32` index iterators while preserving stream shape, sampling-readiness
validation, and compact width validation. This improves discoverability but does
not resolve S4-M11.

S4-M741 documents static `AliasTable` checked `usize` index APIs
(`compare/results/s4-m741-aliastable-checked-index-docs.md`):
`docs/api-reference.md` now lists the existing checked scalar, fill, owned, and
fixed-array `usize` index APIs for static `AliasTable`. This improves
discoverability but does not resolve S4-M11.

S4-M742 adds dynamic weighted-tree invalid checked iterator coverage
(`compare/results/s4-m742-weighted-tree-invalid-checked-iterators.md`):
checked iterator constructors for `WeightedTree` and `WeightedIntTree` now have
explicit tests proving invalid all-zero trees return `error.InvalidWeight` before
random-stream use. This improves reliability evidence but does not resolve
S4-M11.

S4-M743 adds static `AliasTable` checked compact iterator width coverage
(`compare/results/s4-m743-aliastable-checked-u32-iterator-width.md`):
`AliasTable.iterU32CheckedFrom` now has explicit oversized-population evidence
proving `error.InvalidParameter` is returned before random-stream use when the
table length exceeds `u32`. This improves reliability evidence but does not
resolve S4-M11.

S4-M744 adds dynamic weighted-tree checked compact iterator width coverage
(`compare/results/s4-m744-weighted-tree-checked-u32-iterator-width.md`):
`WeightedTree.iterU32CheckedFrom` and `WeightedIntTree.iterU32CheckedFrom` now
have explicit oversized-population evidence proving `error.InvalidParameter` is
returned before random-stream use when tree length exceeds `u32`. This improves
reliability evidence but does not resolve S4-M11.

S4-M745 adds checked canonical pointer iterator aliases
(`compare/results/s4-m745-choice-checked-pointer-iter-aliases.md`):
distribution-layer `Choose`, reusable `Choice`, and reusable `WeightedChoice`
now expose checked `iter`/`iterFrom` aliases for repeated pointer sampling, with
focused tests proving checked aliases preserve existing pointer iterator stream
shape for scalar draws and fill helpers. This improves API consistency and
adoption ergonomics but does not resolve S4-M11.

S4-M746 tightens owned compact index prevalidation for choice samplers
(`compare/results/s4-m746-choice-owned-u32-index-prevalidation.md`):
distribution-layer `Choose.indicesU32From` / `indicesU32CheckedFrom` and
reusable `Choice.indicesU32From` / `indicesU32CheckedFrom` now reject populations
whose length exceeds `u32` before allocation or random-stream use. This improves
reliability evidence for Alea's compact index extension beyond local Rust's
`usize`-oriented index APIs but does not resolve S4-M11.

S4-M747 tightens owned compact index prevalidation for static alias tables
(`compare/results/s4-m747-aliastable-owned-u32-index-prevalidation.md`):
`AliasTable.indicesU32From` now rejects populations whose length exceeds `u32`
before allocation or random-stream use, matching the surrounding scalar, fill,
fixed-array, and iterator compact width checks. This improves reliability
evidence for Alea's compact weighted-index extension but does not resolve
S4-M11.

S4-M748 tightens owned compact index prevalidation for dynamic weighted trees
(`compare/results/s4-m748-weighted-tree-owned-u32-index-prevalidation.md`):
`WeightedTree.indicesU32From` / `indicesU32CheckedFrom` and
`WeightedIntTree.indicesU32From` / `indicesU32CheckedFrom` now reject oversized
populations before allocation or random-stream use. This improves reliability
evidence for Alea's dynamic compact weighted-index extension but does not
resolve S4-M11.

S4-M749 tightens invalid-state prevalidation for dynamic weighted-tree owned
indexes
(`compare/results/s4-m749-weighted-tree-invalid-owned-indices-prevalidation.md`):
`WeightedTree.indicesCheckedFrom` / `indicesU32CheckedFrom` and
`WeightedIntTree.indicesCheckedFrom` / `indicesU32CheckedFrom` now reject invalid
all-zero trees before allocation or random-stream use for non-zero requests.
This improves reliability evidence for dynamic weighted-index workflows but does
not resolve S4-M11.

S4-M750 adds checked owned compact index aliases for static alias tables
(`compare/results/s4-m750-aliastable-checked-owned-u32-indices.md`):
`AliasTable.indicesU32Checked` / `indicesU32CheckedFrom` now mirror existing
`indicesU32` stream shape and inherit compact width prevalidation. This improves
API consistency for Alea's compact weighted-index extension but does not resolve
S4-M11.

S4-M751 implements documented checked fixed-size index arrays for static alias
tables (`compare/results/s4-m751-aliastable-checked-fixed-index-arrays.md`):
`AliasTable.indexArrayChecked` / `indexArrayCheckedFrom` now exist and preserve
existing fixed-array stream shape. This closes an API-surface correctness gap but
does not resolve S4-M11.

S4-M752 implements documented checked `usize` index aliases for static alias
tables (`compare/results/s4-m752-aliastable-checked-usize-index-aliases.md`):
`AliasTable.sampleChecked`, `fillChecked`, `indicesChecked`, and their index/from
aliases now exist and preserve existing stream shape. This closes an API-surface
correctness gap but does not resolve S4-M11.

S4-M753 clarifies scalar fast-helper namespaces
(`compare/results/s4-m753-rng-fast-helper-namespace-docs.md`):
`docs/api-reference.md` and `docs/core-guide.md` now document the scalar
normal/exponential fast paths as `Rng.standardNormalFastFrom`,
`Rng.normalFastFrom`, `Rng.standardExponentialFastFrom`, and
`Rng.exponentialFastFrom`, matching the actual public namespace. This improves
adoption clarity but does not resolve S4-M11.

S4-M754 fixes checked weighted iterator facade constructors
(`compare/results/s4-m754-weighted-checked-iterator-facades.md`):
`AliasTable.iterChecked`, `WeightedTree.iterChecked`, and
`WeightedIntTree.iterChecked` now return facade iterator types directly and have
focused facade/direct stream-shape coverage. This improves weighted iterator API
correctness but does not resolve S4-M11.

S4-M755 adds checked choice iterator facade coverage
(`compare/results/s4-m755-choice-checked-iterator-facades.md`):
`Choose`, `Choice`, and `WeightedChoice` checked value/index iterator facade
constructors now have focused direct-source stream-shape coverage. This improves
iterator API reliability evidence but does not resolve S4-M11.

S4-M756 adds checked direct-source convenience iterator coverage for weighted
accessor streams
(`compare/results/s4-m756-accessor-weighted-iterator-checked-from.md`):
`chooseWeightedIterByCheckedFrom` and `chooseWeightedIterByIndexCheckedFrom` now
have focused parity evidence against reusable `WeightedChoice` iterators. This
improves iterator API reliability evidence but does not resolve S4-M11.

S4-M757 adds checked direct-source convenience iterator coverage for parallel
weighted streams (`compare/results/s4-m757-parallel-weighted-iterator-checked-from.md`):
`chooseWeightedIterCheckedFrom` now has focused parity evidence against reusable
`WeightedChoice` iterators. This completes the matching direct-source coverage
for parallel/accessor/index weighted iterator convenience helpers but does not
resolve S4-M11.

S4-M758 adds checked compact weighted iterator facade coverage
(`compare/results/s4-m758-weighted-checked-u32-iterator-facades.md`):
`AliasTable.iterU32Checked`, `WeightedTree.iterU32Checked`, and
`WeightedIntTree.iterU32Checked` now have focused facade/direct stream-shape
evidence. This improves compact weighted-index iterator reliability evidence but
does not resolve S4-M11.

S4-M759 adds unweighted checked convenience iterator coverage
(`compare/results/s4-m759-choice-convenience-checked-iterator.md`):
`chooseIterChecked` and `chooseIterCheckedFrom` now have focused stream-shape
evidence against reusable `Choice.iterFrom`. This improves iterator API
reliability evidence but does not resolve S4-M11.

S4-M760 tightens checked iterator sampling exact-remaining prevalidation
(`compare/results/s4-m760-seq-checked-iterator-exact-remaining-prevalidation.md`):
checked allocation-returning, caller-owned, fixed-array, and weighted iterator
sampling helpers now reject exact-size short sources before allocation, iterator
consumption, or random-stream use. This improves iterator sampling reliability
evidence but does not resolve S4-M11.

S4-M761 tightens optional iterator-array exact-remaining prevalidation
(`compare/results/s4-m761-seq-optional-iterator-array-exact-remaining.md`):
optional unweighted and weighted fixed-size iterator array helpers now return
`null` before consuming exact-size short sources. This improves iterator sampling
reliability evidence but does not resolve S4-M11.

S4-M762 tightens iterator exact-empty allocation prevalidation
(`compare/results/s4-m762-iterator-exact-empty-allocation-prevalidation.md`):
seq/root allocation-returning iterator sampling helpers now return empty outputs
for exact-empty sources before reservoir/heap allocation, iterator consumption,
entropy, or random-stream use. This improves iterator sampling reliability
evidence but does not resolve S4-M11.

S4-M763 tightens iterator exact-empty caller-owned prevalidation
(`compare/results/s4-m763-iterator-exact-empty-caller-owned-prevalidation.md`):
seq/root caller-owned iterator sampling helpers now return zero for exact-empty
sources before iterator consumption, entropy, or random-stream use. This
improves iterator sampling reliability evidence but does not resolve S4-M11.

S4-M764 tightens weighted iterator one-shot exact-empty prevalidation
(`compare/results/s4-m764-weighted-iterator-choice-exact-empty-prevalidation.md`):
seq/root weighted iterator one-shot choice helpers now return null or EmptyInput
for exact-empty sources before iterator consumption, entropy, or random-stream
use. This improves weighted iterator choice reliability evidence but does not
resolve S4-M11.

S4-M765 tightens unweighted iterator one-shot exact-empty prevalidation
(`compare/results/s4-m765-iterator-choice-exact-empty-prevalidation.md`):
seq/root unweighted iterator choice helpers now return null or EmptyInput for
exact-empty sources before iterator consumption, entropy, or random-stream use.
This improves iterator choice reliability evidence but does not resolve S4-M11.

S4-M766 tightens root iterator sample exact-empty allocation prevalidation
(`compare/results/s4-m766-root-iterator-sample-exact-empty-prevalidation.md`):
root `sampleIterator` now returns an empty output for exact-empty sources before
reservoir allocation, iterator consumption, entropy, or random-stream use. This
improves iterator sampling reliability evidence but does not resolve S4-M11.

S4-M767 caps exact-short iterator allocation capacity
(`compare/results/s4-m767-iterator-exact-short-allocation-capacity.md`):
seq/root allocation-returning iterator sampling helpers now cap reservoir/heap
capacity by exact remaining counts when returning partial results. This improves
iterator sampling allocation predictability but does not resolve S4-M11.

S4-M768 avoids exact-short iterator end probes
(`compare/results/s4-m768-iterator-exact-short-end-probe.md`):
seq/root allocation-returning unweighted iterator samples now read exactly the
known remaining items and return partial outputs without an extra null probe.
This improves iterator sampling reliability evidence but does not resolve
S4-M11.

S4-M769 avoids exact-short caller-owned iterator end probes
(`compare/results/s4-m769-iterator-exact-short-caller-owned-end-probe.md`):
seq/root caller-owned unweighted iterator fills now read exactly the known
remaining items and return partial counts without an extra null probe. This
improves iterator fill reliability evidence but does not resolve S4-M11.

S4-M770 avoids exact-count checked iterator end probes
(`compare/results/s4-m770-checked-iterator-exact-count-end-probe.md`):
seq/root checked unweighted iterator samples now read exactly the known remaining
items when exact remaining equals the requested count. This improves iterator
sampling reliability evidence but does not resolve S4-M11.

S4-M771 avoids weighted iterator exact-single end probes
(`compare/results/s4-m771-weighted-iterator-choice-exact-single.md`):
seq/root weighted iterator one-shot choices now read exactly one entry for
exact-single sources and return positive/null/error results without extra null
probes or entropy. This improves weighted iterator choice reliability evidence
but does not resolve S4-M11.

S4-M772 avoids weighted iterator exact-single sample heap setup
(`compare/results/s4-m772-weighted-iterator-sample-exact-single.md`):
seq/root allocation-returning weighted iterator samples now resolve exact-single
sources after one validated entry without heap setup, extra probes, entropy, or
random-stream use. This improves weighted iterator sampling reliability evidence
but does not resolve S4-M11.

S4-M773 avoids weighted iterator exact-single fill key sampling
(`compare/results/s4-m773-weighted-iterator-fill-exact-single.md`):
seq/root caller-owned weighted iterator fills now resolve exact-single sources
after one validated entry without key sampling, extra probes, entropy, or
random-stream use. This improves weighted iterator fill reliability evidence but
does not resolve S4-M11.

S4-M774 avoids weighted iterator exact-single fixed-array key sampling
(`compare/results/s4-m774-weighted-iterator-array-exact-single.md`):
seq/root fixed-size weighted iterator arrays now resolve exact-single `N == 1`
sources after one validated entry without key sampling, extra probes, entropy,
or random-stream use. This improves weighted iterator array reliability evidence
but does not resolve S4-M11.

S4-M775 avoids weighted iterator exact-count fixed-array key sampling
(`compare/results/s4-m775-weighted-iterator-array-exact-count.md`):
seq/root fixed-size weighted iterator arrays now resolve all-positive exact-count
sources after reading exactly the known entries without key sampling, extra
probes, entropy, or random-stream use. Zero-weight exact-count sources still
report insufficient positive entries and invalid weights are still validated.
This improves weighted iterator array reliability evidence but does not resolve
S4-M11.

S4-M776 avoids weighted iterator exact-cover sample heap/key setup
(`compare/results/s4-m776-weighted-iterator-sample-exact-cover.md`):
seq/root allocation-returning weighted iterator samples now resolve exact
remaining sources that are fully covered by the request after reading exactly the
known entries, returning the positive-weight subset without weighted heap setup,
key sampling, extra probes, entropy, or random-stream use. Checked variants still
report insufficient positive entries. This improves weighted iterator sampling
reliability evidence but does not resolve S4-M11.

S4-M777 avoids weighted iterator exact-cover fill key sampling
(`compare/results/s4-m777-weighted-iterator-fill-exact-cover.md`):
seq/root caller-owned weighted iterator fills now resolve exact remaining sources
that are fully covered by the output after reading exactly the known entries,
returning the positive-weight subset without key sampling, extra probes, entropy,
or random-stream use. Checked variants still report insufficient positive
entries. This improves weighted iterator fill reliability evidence but does not
resolve S4-M11.

S4-M778 avoids weighted iterator exact-count choice end probes
(`compare/results/s4-m778-weighted-iterator-choice-exact-count.md`):
seq/root weighted iterator one-shot choices now read exact-size sources exactly
for their reported remaining count, preserving exact-single and single-positive
no-entropy behavior while keeping multi-positive stream shape aligned with the
generic weighted choice path. This improves weighted iterator choice reliability
evidence but does not resolve S4-M11.

S4-M779 avoids stable iterator exact-count choice end probes
(`compare/results/s4-m779-stable-iterator-choice-exact-count.md`):
seq/root stable unweighted iterator one-shot choices now read exact-size sources
exactly for their reported remaining count, preserving reservoir stream shape
while avoiding an extra trailing null probe. This improves iterator choice
reliability evidence but does not resolve S4-M11.

S4-M780 avoids duplicate weighted iterator array exact metadata probes
(`compare/results/s4-m780-weighted-iterator-array-exact-metadata.md`):
seq/root fixed-size weighted iterator arrays now reuse exact remaining metadata
between the public wrapper and candidate core, so exact-count paths validate and
sample after one size-hint/remaining query instead of two. This improves weighted
iterator array reliability evidence but does not resolve S4-M11.

S4-M781 avoids duplicate weighted iterator sample exact metadata probes
(`compare/results/s4-m781-weighted-iterator-sample-exact-metadata.md`):
seq/root allocation-returning weighted iterator samples now reuse exact remaining
metadata between public wrappers and weighted sample cores, so exact-cover paths
validate and sample after one size-hint/remaining query instead of two. This
improves weighted iterator sampling reliability evidence but does not resolve
S4-M11.

S4-M782 avoids duplicate weighted iterator fill exact metadata probes
(`compare/results/s4-m782-weighted-iterator-fill-exact-metadata.md`):
root caller-owned weighted iterator fills now reuse exact remaining metadata
between public wrappers and the weighted fill core, so exact-cover paths validate
and fill after one size-hint/remaining query instead of two. This improves
weighted iterator fill reliability evidence but does not resolve S4-M11.

S4-M783 avoids fixed-size iterator array exact-long end probes
(`compare/results/s4-m783-iterator-array-exact-long-end-probe.md`):
seq/root fixed-size unweighted iterator arrays now bound exact-long reservoir
continuation by the known remaining count, avoiding an extra trailing null probe
while preserving stream shape. This improves iterator array reliability evidence
but does not resolve S4-M11.

S4-M784 avoids caller-owned iterator fill exact-long end probes
(`compare/results/s4-m784-iterator-fill-exact-long-end-probe.md`):
seq/root caller-owned unweighted iterator fills now bound exact-long reservoir
continuation by the known remaining count, avoiding an extra trailing null probe
while preserving stream shape. This improves iterator fill reliability evidence
but does not resolve S4-M11.

S4-M785 avoids allocation-returning iterator sample exact-long end probes
(`compare/results/s4-m785-iterator-sample-exact-long-end-probe.md`):
seq/root allocation-returning unweighted iterator samples now bound exact-long
reservoir continuation by the known remaining count, avoiding an extra trailing
null probe while preserving stream shape. This improves iterator sampling
reliability evidence but does not resolve S4-M11.

S4-M786 avoids duplicate root iterator choice exact metadata probes
(`compare/results/s4-m786-root-iterator-choice-exact-metadata.md`):
root unweighted iterator choice helpers now reuse exact remaining metadata across
empty, hinted, and stable reservoir branches, so exact-size choices query
size-hint/remaining once instead of multiple times. This improves iterator choice
reliability evidence but does not resolve S4-M11.

S4-M787 avoids weighted iterator array exact-long end probes
(`compare/results/s4-m787-weighted-iterator-array-exact-long-end-probe.md`):
seq/root fixed-size weighted iterator arrays now bound exact-long candidate
scanning by the known remaining count, avoiding an extra trailing null probe
while preserving weighted-key stream shape. This improves weighted iterator array
reliability evidence but does not resolve S4-M11.

S4-M788 avoids weighted iterator fill exact-long end probes
(`compare/results/s4-m788-weighted-iterator-fill-exact-long-end-probe.md`):
seq/root caller-owned weighted iterator fills now bound exact-long candidate
scanning by the known remaining count, avoiding an extra trailing null probe
while preserving weighted-key stream shape. This improves weighted iterator fill
reliability evidence but does not resolve S4-M11.

S4-M789 avoids weighted iterator sample exact-long end probes
(`compare/results/s4-m789-weighted-iterator-sample-exact-long-end-probe.md`):
seq/root allocation-returning weighted iterator samples now bound exact-long
candidate scanning by the known remaining count, avoiding an extra trailing null
probe while preserving weighted-key stream shape. This improves weighted iterator
sampling reliability evidence but does not resolve S4-M11.

S4-M790 avoids hinted iterator choice fallback metadata re-probes
(`compare/results/s4-m790-hinted-iterator-choice-inexact-metadata.md`):
seq hinted iterator choices now query inexact size-hint/remaining metadata once
before falling back to reservoir choice, preserving fallback stream shape while
avoiding duplicate metadata probes. This improves iterator choice reliability
evidence but does not resolve S4-M11.

S4-M791 reuses sampled iterator index-buffer fills
(`compare/results/s4-m791-sampled-iterator-fill-index-buffer.md`):
seq sampled value/const-pointer/mutable-pointer iterator fills now bulk-fill
owned sampled indices before mapping them to outputs, reducing per-slot iterator
overhead while preserving fill results and stream shape. This improves sampled
iterator fill reliability/ergonomics evidence but does not resolve S4-M11.

S4-M792 reuses IndexVec mapped iterator index-buffer fills
(`compare/results/s4-m792-indexvec-mapped-iterator-fill-index-buffer.md`):
seq non-owned IndexVec value/const-pointer/mutable-pointer iterator fills now
bulk-fill sampled indices before mapping them to outputs, and base IndexVec
iterator fills copy index ranges directly. This improves indexed-sample iterator
fill reliability/ergonomics evidence but does not resolve S4-M11.

S4-M793 uses switch-once IndexVec caller-owned mapping loops
(`compare/results/s4-m793-indexvec-mapped-into-switch-once.md`):
seq IndexVec value/const-pointer/mutable-pointer caller-owned mappings now switch
once on compact/native backing and map outputs directly, avoiding per-slot union
dispatch through `at()`. This improves indexed-sample mapping reliability and
ergonomics evidence but does not resolve S4-M11.

S4-M794 prevalidates IndexVec owned u32 narrowing
(`compare/results/s4-m794-indexvec-owned-u32-prevalidation.md`):
seq IndexVec native `usize` backing is now checked for oversized values before
allocating a compact `u32` output slice. This improves indexed-sample conversion
failure determinism but does not resolve S4-M11.

S4-M795 uses constant fills for uniform choice probability iterators
(`compare/results/s4-m795-choice-probability-fill-constant.md`):
seq reusable `Choice` and distribution-layer `Choose` probability iterators now
fill caller-owned buffers with the constant uniform probability directly instead
of per-slot `next()`/`probability()` calls. This improves choice probability
iterator ergonomics but does not resolve S4-M11.

S4-M796 uses direct storage fills for AliasTable iterators
(`compare/results/s4-m796-aliastable-iterator-fill-direct-storage.md`):
static AliasTable weight/probability iterators now fill caller-owned buffers from
stored weights directly instead of per-slot `next()`/lookup calls. This improves
static weighted iterator ergonomics but does not resolve S4-M11.

S4-M797 uses direct storage fills for weighted tree iterators
(`compare/results/s4-m797-weighted-tree-iterator-fill-direct-storage.md`):
dynamic WeightedTree and WeightedIntTree weight/probability iterators now fill
caller-owned buffers from tree storage directly and cache totals for probability
fills. This improves dynamic weighted iterator ergonomics but does not resolve
S4-M11.

S4-M798 prevalidates IndexVec copied u32 narrowing
(`compare/results/s4-m798-indexvec-copied-u32-prevalidation.md`):
seq IndexVec native `usize` backing is now checked for oversized values before
allocating a copied compact `u32` output slice. This improves indexed-sample
conversion failure determinism but does not resolve S4-M11.

S4-M799 uses direct backing fills for IndexVec iterators
(`compare/results/s4-m799-indexvec-fill-direct-backing.md`):
seq IndexVec borrowed and consuming iterator fills now switch once per fill and
copy/map directly from active backing storage. This improves indexed-sample fill
ergonomics but does not resolve S4-M11.

S4-M800 uses direct backing scans for IndexVec search and validation
(`compare/results/s4-m800-indexvec-search-validation-direct-scans.md`):
seq IndexVec search and validation helpers now switch once per call and scan the
active compact/native backing storage directly. This improves indexed-sample
diagnostic ergonomics but does not resolve S4-M11.

S4-M801 prevalidates IndexVec copyIntoU32 narrowing
(`compare/results/s4-m801-indexvec-copyintou32-prevalidation.md`):
seq IndexVec native `usize` backing is now checked for oversized values before
writing caller-owned compact `u32` output buffers. This improves indexed-sample
conversion failure determinism but does not resolve S4-M11.

S4-M802 uses direct backing reads for IndexVec iterator next calls
(`compare/results/s4-m802-indexvec-next-direct-backing.md`):
seq IndexVec borrowed and consuming iterator `next()` calls now switch once and
read directly from compact/native backing storage. This improves indexed-sample
iterator ergonomics but does not resolve S4-M11.

S4-M803 maps Choice fills directly from generated indexes
(`compare/results/s4-m803-choice-fill-direct-index-mapping.md`):
seq reusable `Choice` and distribution-layer `Choose` pointer/value fills now
generate indexes and map directly into item storage instead of routing each slot
through sample wrappers. This improves unweighted choice fill ergonomics but does
not resolve S4-M11.

S4-M804 maps WeightedChoice fills directly from alias indexes
(`compare/results/s4-m804-weightedchoice-fill-direct-index-mapping.md`):
seq reusable `WeightedChoice` pointer/value fills now sample alias-table indexes
and map directly into item storage instead of routing each slot through sample
wrappers. This improves weighted choice fill ergonomics but does not resolve
S4-M11.

S4-M805 fills AliasTable indexes with direct alias sampling loops
(`compare/results/s4-m805-aliastable-fill-direct-sampling.md`):
static AliasTable usize/u32 index fills now inline both power-of-two one-word and
general alias sampling loops instead of routing each slot through sample wrappers.
This improves static weighted-index fill ergonomics but does not resolve S4-M11.

S4-M806 routes WeightedChoice index fills through AliasTable direct loops
(`compare/results/s4-m806-weightedchoice-index-fill-table-direct.md`):
reusable WeightedChoice usize/u32 index fills now reuse the optimized AliasTable
direct fill loops instead of duplicating per-slot table sampling wrappers. This
improves reusable weighted-choice index fill ergonomics but does not resolve
S4-M11.

S4-M807 fills weighted tree indexes with direct tree-walk loops
(`compare/results/s4-m807-weighted-tree-fill-direct-sampling.md`):
dynamic WeightedTree and WeightedIntTree usize/u32 index fills now run direct
tree-walk sampling loops instead of routing each slot through scalar sample
wrappers. This improves dynamic weighted-tree index fill ergonomics but does not
resolve S4-M11.

S4-M808 fills distribution Choose indexes with direct uniform loops
(`compare/results/s4-m808-distribution-choose-index-fill-direct.md`):
distribution-layer Choose usize index fills now cache length and generate uniform
indexes directly instead of routing each slot through sample wrappers. This
improves distribution choose index fill ergonomics but does not resolve S4-M11.

S4-M809 fills reusable Choice indexes with cached-length direct loops
(`compare/results/s4-m809-choice-index-fill-cached-length.md`):
reusable Choice usize index fills now return early for empty output, cache item
length once, and generate uniform indexes directly. This improves reusable choice
index fill ergonomics but does not resolve S4-M11.

S4-M810 fills distribution Choose u32 indexes with cached-length direct loops
(`compare/results/s4-m810-distribution-choose-u32-index-fill-cached-length.md`):
distribution-layer Choose compact u32 index fills now return early for empty
output, cache item length once, validate compact width, and generate uniform u32
indexes directly. This improves distribution choose compact index fill ergonomics
but does not resolve S4-M11.

S4-M811 fills reusable Choice u32 indexes with cached-length direct loops
(`compare/results/s4-m811-choice-u32-index-fill-cached-length.md`):
reusable Choice compact u32 index fills now return early for empty output, cache
item length once, validate compact width, and generate uniform u32 indexes
directly. This improves reusable choice compact index fill ergonomics but does
not resolve S4-M11.

S4-M812 samples reusable Choice index iterators directly
(`compare/results/s4-m812-choice-index-iterator-direct-sampling.md`):
reusable Choice usize/u32 index iterator next calls now generate uniform indexes
directly from cached choice length instead of routing through sample wrappers.
This improves reusable choice index iterator ergonomics but does not resolve
S4-M11.

S4-M813 samples distribution Choose index iterators directly
(`compare/results/s4-m813-distribution-choose-index-iterator-direct.md`):
distribution-layer Choose usize/u32 index iterator next calls now generate uniform
indexes directly from cached choice length instead of routing through sample
wrappers. This improves distribution choose index iterator ergonomics but does
not resolve S4-M11.

S4-M814 samples WeightedChoice index iterators directly from AliasTable
(`compare/results/s4-m814-weightedchoice-index-iterator-direct-table.md`):
reusable WeightedChoice usize/u32 index iterator next calls now sample the
underlying AliasTable directly instead of routing through WeightedChoice sample
wrappers. This improves reusable weighted-choice index iterator ergonomics but
does not resolve S4-M11.

S4-M815 samples AliasTable u32 iterators through checked table sampling
(`compare/results/s4-m815-aliastable-u32-iterator-direct.md`):
static AliasTable compact u32 iterator next calls now call the checked table
sampler directly instead of routing through sampleU32From. This improves static
weighted-index iterator ergonomics but does not resolve S4-M11.

S4-M816 samples weighted tree u32 iterators through checked tree sampling
(`compare/results/s4-m816-weighted-tree-u32-iterator-direct.md`):
dynamic WeightedTree and WeightedIntTree compact u32 iterator next calls now call
the checked tree sampler directly instead of routing through sampleU32From. This
improves dynamic weighted-tree iterator ergonomics but does not resolve S4-M11.

S4-M817 maps Choice value iterators directly from generated indexes
(`compare/results/s4-m817-choice-value-iterator-direct-index.md`):
reusable Choice value iterator next calls now generate uniform indexes and map
directly into item storage instead of routing through sampleValueFrom. This
improves reusable choice value iterator ergonomics but does not resolve S4-M11.

S4-M818 maps distribution Choose value iterators directly from generated indexes
(`compare/results/s4-m818-distribution-choose-value-iterator-direct.md`):
distribution-layer Choose value iterator next calls now generate uniform indexes
and map directly into item storage instead of routing through sampleValueFrom.
This improves distribution choose value iterator ergonomics but does not resolve
S4-M11.

S4-M819 maps WeightedChoice value iterators directly from AliasTable indexes
(`compare/results/s4-m819-weightedchoice-value-iterator-direct-table.md`):
reusable WeightedChoice value iterator next calls now sample alias-table indexes
and map directly into item storage instead of routing through sampleValueFrom.
This improves reusable weighted-choice value iterator ergonomics but does not
resolve S4-M11.

S4-M820 maps distribution Choose pointer iterators directly from generated indexes
(`compare/results/s4-m820-distribution-choose-ptr-iterator-direct.md`):
distribution-layer Choose pointer iterator next calls now generate uniform indexes
and map directly into item storage instead of routing through sampleFrom. This
improves distribution choose pointer iterator ergonomics but does not resolve
S4-M11.

S4-M821 fills mapped samplers with direct mapper application
(`compare/results/s4-m821-mappedsampler-fill-direct-mapper.md`):
distribution MappedSampler fills now apply the mapper directly to base sampler
outputs instead of routing each slot through MappedSampler.sampleFrom. This
improves mapped sampler fill ergonomics but does not resolve S4-M11.

S4-M822 fills Binomial outputs with direct binomialFrom calls
(`compare/results/s4-m822-binomial-fill-direct-sampler.md`):
Binomial non-degenerate fills now call the underlying binomialFrom sampler
directly instead of routing each slot through Binomial.sampleFrom. This improves
Binomial fill ergonomics but does not resolve S4-M11.

S4-M823 fills NegativeBinomial outputs with direct negativeBinomialFrom calls
(`compare/results/s4-m823-negative-binomial-fill-direct-sampler.md`):
NegativeBinomial non-degenerate fills now call the underlying negativeBinomialFrom
sampler directly instead of routing each slot through NegativeBinomial.sampleFrom.
This improves NegativeBinomial fill ergonomics but does not resolve S4-M11.

S4-M824 fills Hypergeometric outputs with direct method dispatch
(`compare/results/s4-m824-hypergeometric-fill-direct-method.md`):
Hypergeometric fills now switch once on the selected method and call draw-loop,
inverse-transform, or rejection-acceptance samplers directly instead of routing
each slot through Hypergeometric.sampleFrom. This improves Hypergeometric fill
ergonomics but does not resolve S4-M11.

S4-M825 fills Geometric outputs with direct geometricFrom calls
(`compare/results/s4-m825-geometric-fill-direct-sampler.md`):
Geometric non-degenerate fills now call the underlying geometricFrom sampler
directly instead of routing each slot through Geometric.sampleFrom. This improves
Geometric fill ergonomics but does not resolve S4-M11.

S4-M826 fills GeometricFailures outputs with direct geometricFailuresFrom calls
(`compare/results/s4-m826-geometric-failures-fill-direct-sampler.md`):
GeometricFailures non-degenerate fills now call the underlying
geometricFailuresFrom sampler directly instead of routing each slot through
GeometricFailures.sampleFrom. This improves GeometricFailures fill ergonomics but
does not resolve S4-M11.

S4-M827 fills VectorGeometric outputs with direct geometricFrom lane draws
(`compare/results/s4-m827-vector-geometric-fill-direct-sampler.md`):
VectorGeometric non-degenerate fills now draw lanes with the underlying
geometricFrom sampler directly instead of routing each vector through
VectorGeometric.sampleFrom. This improves VectorGeometric fill ergonomics but
does not resolve S4-M11.

S4-M828 fills VectorGeometricFailures outputs with direct geometricFailuresFrom lane draws
(`compare/results/s4-m828-vector-geometric-failures-fill-direct-sampler.md`):
VectorGeometricFailures non-degenerate fills now draw lanes with the underlying
geometricFailuresFrom sampler directly instead of routing each vector through
VectorGeometricFailures.sampleFrom. This improves VectorGeometricFailures fill
ergonomics but does not resolve S4-M11.

S4-M829 fills VectorNegativeBinomial outputs with direct negativeBinomialFrom lane draws
(`compare/results/s4-m829-vector-negative-binomial-fill-direct-sampler.md`):
VectorNegativeBinomial non-degenerate fills now draw lanes with the underlying
negativeBinomialFrom sampler directly instead of routing each vector through
VectorNegativeBinomial.sampleFrom. This improves VectorNegativeBinomial fill
ergonomics but does not resolve S4-M11.

S4-M830 fills VectorBinomial outputs with direct binomialFrom lane draws
(`compare/results/s4-m830-vector-binomial-fill-direct-sampler.md`):
VectorBinomial non-degenerate fills now draw lanes with the underlying
binomialFrom sampler directly instead of routing each vector through
VectorBinomial.sampleFrom. This improves VectorBinomial fill ergonomics but does
not resolve S4-M11.

S4-M831 fills VectorBinomialPoissonApprox outputs with direct approximation lane draws
(`compare/results/s4-m831-vector-binomial-poisson-approx-fill-direct.md`):
VectorBinomialPoissonApprox non-degenerate fills now draw lanes with the
underlying binomialPoissonApproxFrom sampler directly instead of routing each
vector through VectorBinomialPoissonApprox.sampleFrom. This improves vector
binomial approximation fill ergonomics but does not resolve S4-M11.

S4-M832 fills VectorHypergeometric outputs with direct method dispatch
(`compare/results/s4-m832-vector-hypergeometric-fill-direct-method.md`):
VectorHypergeometric fills now switch once on the selected method and call
draw-loop, inverse-transform, or rejection-acceptance samplers directly for each
lane instead of routing each vector through VectorHypergeometric.sampleFrom. This
improves vector hypergeometric fill ergonomics but does not resolve S4-M11.

S4-M833 fills VectorPoisson outputs with direct method dispatch
(`compare/results/s4-m833-vector-poisson-fill-direct-method.md`):
VectorPoisson fills now switch once on zero/product/Ahrens-Dieter methods and
call selected method samplers directly for each lane instead of routing each
vector through VectorPoisson.sampleFrom. This improves VectorPoisson fill
ergonomics but does not resolve S4-M11.

S4-M834 delegates reusable HalfNormal fills to the optimized helper
(`compare/results/s4-m834-halfnormal-fill-helper-delegate.md`):
HalfNormal.fillFrom now delegates to fillHalfNormalFrom, reusing its degenerate
and optimized bulk implementation instead of routing each slot through
HalfNormal.sampleFrom. This improves HalfNormal reusable fill ergonomics but does
not resolve S4-M11.

S4-M835 stages reusable Exponential fills through the standard helper
(`compare/results/s4-m835-exponential-fill-standard-stage.md`):
Exponential.fillFrom now fills standard exponential samples through the shared
bulk helper and scales them in place, while preserving infinite-rate no-consume
behavior and scalar-loop stream shape. This improves Exponential reusable fill
ergonomics but does not resolve S4-M11.

S4-M836 stages reusable VectorExponential fills through the standard helper
(`compare/results/s4-m836-vector-exponential-fill-standard-stage.md`):
VectorExponential.fillFrom now fills standard vector exponential samples through
the shared bulk helper for f32/f64 vector lanes and scales the backing scalar
lanes in place, while preserving infinite-rate no-consume behavior and
scalar-loop stream shape. This improves VectorExponential reusable fill
ergonomics but does not resolve S4-M11.

S4-M837 stages shape-one reusable Gamma fills through the standard helper
(`compare/results/s4-m837-gamma-shape-one-fill-standard-stage.md`):
Gamma.fillFrom now uses the shared standard exponential bulk helper for
shape-one non-degenerate fills and scales the output in place, matching local
rand_distr's `GammaRepr::One(Exp)` decomposition while preserving stream shape.
This improves Gamma shape-one reusable fill ergonomics but does not resolve
S4-M11.

S4-M838 stages shape-one reusable VectorGamma fills through the standard helper
(`compare/results/s4-m838-vector-gamma-shape-one-fill-standard-stage.md`):
VectorGamma.fillFrom now uses the shared standard vector exponential bulk helper
for f32/f64 shape-one non-degenerate fills and scales the backing scalar lanes in
place, matching the same local rand_distr Gamma decomposition for vector fills
while preserving stream shape. This improves VectorGamma shape-one reusable fill
ergonomics but does not resolve S4-M11.

S4-M839 delegates reusable ChiSquared fills to cached Gamma fills
(`compare/results/s4-m839-chi-squared-fill-gamma-delegate.md`):
ChiSquared.fillFrom now delegates to the cached Gamma sampler's fill path,
reusing Gamma's shape-specific bulk handling (including shape-one standard
exponential staging) instead of routing every output through ChiSquared.sampleFrom.
This improves ChiSquared reusable fill ergonomics but does not resolve S4-M11.

S4-M840 delegates reusable VectorChiSquared fills to cached VectorGamma fills
(`compare/results/s4-m840-vector-chi-squared-fill-gamma-delegate.md`):
VectorChiSquared.fillFrom now delegates to VectorGamma over the cached Gamma
sampler, reusing vector Gamma's shape-specific bulk handling (including shape-one
standard-vector-exponential staging) instead of routing every output through
VectorChiSquared.sampleFrom. This improves VectorChiSquared reusable fill
ergonomics but does not resolve S4-M11.

S4-M841 delegates reusable Chi fills to cached ChiSquared fills
(`compare/results/s4-m841-chi-fill-chi-squared-delegate.md`):
Chi.fillFrom now delegates to the cached ChiSquared sampler's fill path and then
applies square root in place, reusing ChiSquared/Gamma bulk handling instead of
routing every output through Chi.sampleFrom. This improves Chi reusable fill
ergonomics but does not resolve S4-M11.

S4-M842 delegates reusable VectorChi fills to cached VectorChiSquared fills
(`compare/results/s4-m842-vector-chi-fill-chi-squared-delegate.md`):
VectorChi.fillFrom now delegates to VectorChiSquared over the cached ChiSquared
sampler and then applies vector square root in place, reusing vector
ChiSquared/Gamma bulk handling instead of routing every output through
VectorChi.sampleFrom. This improves VectorChi reusable fill ergonomics but does
not resolve S4-M11.

S4-M843 delegates reusable Erlang fills to cached Gamma fills
(`compare/results/s4-m843-erlang-fill-gamma-delegate.md`):
Erlang.fillFrom now delegates to the cached Gamma sampler's fill path, reusing
Gamma's shape-specific bulk handling instead of routing every output through
Erlang.sampleFrom. This improves Erlang reusable fill ergonomics but does not
resolve S4-M11.

S4-M844 delegates reusable VectorErlang fills to cached VectorGamma fills
(`compare/results/s4-m844-vector-erlang-fill-gamma-delegate.md`):
VectorErlang.fillFrom now delegates to VectorGamma over the cached Gamma sampler,
reusing vector Gamma's shape-specific bulk handling instead of routing every
output through VectorErlang.sampleFrom. This improves VectorErlang reusable fill
ergonomics but does not resolve S4-M11.

S4-M845 draws reusable FisherF fills through cached Gamma ratio loops
(`compare/results/s4-m845-fisher-f-fill-direct-gamma-ratio.md`):
FisherF.fillFrom now draws numerator and denominator values from its cached Gamma
samplers directly and divides them, instead of routing every output through
FisherF.sampleFrom. This improves FisherF reusable fill ergonomics but does not
resolve S4-M11.

S4-M846 draws reusable VectorFisherF fills through cached Gamma ratio lanes
(`compare/results/s4-m846-vector-fisher-f-fill-direct-gamma-ratio.md`):
VectorFisherF.fillFrom now draws numerator and denominator values from its cached
Gamma samplers directly for each lane and divides them, instead of routing every
output through VectorFisherF.sampleFrom. This improves VectorFisherF reusable
fill ergonomics but does not resolve S4-M11.

S4-M847 draws reusable StudentT fills through direct normal/ChiSquared composition
(`compare/results/s4-m847-student-t-fill-direct-composition.md`):
StudentT.fillFrom now draws standard normal and cached ChiSquared samples
directly for finite degrees of freedom and combines them, instead of routing
every output through StudentT.sampleFrom. This improves StudentT reusable fill
ergonomics but does not resolve S4-M11.

S4-M848 draws reusable VectorStudentT fills through direct normal/ChiSquared lanes
(`compare/results/s4-m848-vector-student-t-fill-direct-composition.md`):
VectorStudentT.fillFrom now draws standard normal and cached ChiSquared samples
directly for each finite-degree vector lane and combines them, instead of routing
every output through VectorStudentT.sampleFrom. This improves VectorStudentT
reusable fill ergonomics but does not resolve S4-M11.

S4-M849 draws reusable VectorTriangular fills through direct vector uniform
transforms (`compare/results/s4-m849-vector-triangular-fill-direct-transform.md`):
VectorTriangular.fillFrom now draws vector uniform values and applies the
triangular transform directly, instead of routing every output through
VectorTriangular.sampleFrom. This improves VectorTriangular reusable fill
ergonomics but does not resolve S4-M11.

S4-M850 draws reusable VectorArcsine fills through direct vector open-uniform
transforms (`compare/results/s4-m850-vector-arcsine-fill-direct-transform.md`):
VectorArcsine.fillFrom now draws vector open-uniform values and applies the
arcsine transform directly, instead of routing every output through
VectorArcsine.sampleFrom. This improves VectorArcsine reusable fill ergonomics
but does not resolve S4-M11.

S4-M851 draws reusable VectorCauchy fills through direct vector open-uniform
transforms (`compare/results/s4-m851-vector-cauchy-fill-direct-transform.md`):
VectorCauchy.fillFrom now draws vector open-uniform values and applies the
Cauchy transform directly, instead of routing every output through
VectorCauchy.sampleFrom. This improves VectorCauchy reusable fill ergonomics but
does not resolve S4-M11.

S4-M852 draws reusable VectorLaplace fills through direct vector open-uniform
transforms (`compare/results/s4-m852-vector-laplace-fill-direct-transform.md`):
VectorLaplace.fillFrom now draws vector open-uniform values and applies the
Laplace transform directly, instead of routing every output through
VectorLaplace.sampleFrom. This improves VectorLaplace reusable fill ergonomics
but does not resolve S4-M11.

S4-M853 draws reusable VectorLogistic fills through direct vector open-uniform
transforms (`compare/results/s4-m853-vector-logistic-fill-direct-transform.md`):
VectorLogistic.fillFrom now draws vector open-uniform values and applies the
Logistic transform directly, instead of routing every output through
VectorLogistic.sampleFrom. This improves VectorLogistic reusable fill ergonomics
but does not resolve S4-M11.

S4-M854 draws reusable VectorLogLogistic fills through direct vector open-uniform
transforms (`compare/results/s4-m854-vector-log-logistic-fill-direct-transform.md`):
VectorLogLogistic.fillFrom now draws vector open-uniform values and applies the
LogLogistic transform directly, including the shape-one ratio path, instead of
routing every output through VectorLogLogistic.sampleFrom. This improves
VectorLogLogistic reusable fill ergonomics but does not resolve S4-M11.

S4-M855 draws reusable VectorKumaraswamy fills through direct vector open-uniform
transforms (`compare/results/s4-m855-vector-kumaraswamy-fill-direct-transform.md`):
VectorKumaraswamy.fillFrom now draws vector open-uniform values and applies the
Kumaraswamy transform directly, including beta-one and alpha-one paths, instead
of routing every output through VectorKumaraswamy.sampleFrom. This improves
VectorKumaraswamy reusable fill ergonomics but does not resolve S4-M11.

S4-M856 draws reusable VectorPowerFunction fills through direct range/open-uniform
transforms (`compare/results/s4-m856-vector-power-function-fill-direct-transform.md`):
VectorPowerFunction.fillFrom now dispatches directly to point-max, uniform range,
square-root, or generic power-function transform paths instead of routing every
output through VectorPowerFunction.sampleFrom. This improves VectorPowerFunction
reusable fill ergonomics but does not resolve S4-M11.

S4-M857 draws reusable VectorRayleigh fills through direct vector open-uniform
transforms (`compare/results/s4-m857-vector-rayleigh-fill-direct-transform.md`):
VectorRayleigh.fillFrom now draws vector open-uniform values and applies the
Rayleigh transform directly, instead of routing every output through
VectorRayleigh.sampleFrom. This improves VectorRayleigh reusable fill ergonomics
but does not resolve S4-M11.

S4-M858 draws reusable VectorMaxwell fills through direct vector normal triples
(`compare/results/s4-m858-vector-maxwell-fill-direct-transform.md`):
VectorMaxwell.fillFrom now draws three vector normal values and applies the
Maxwell norm transform directly, instead of routing every output through
VectorMaxwell.sampleFrom. This improves VectorMaxwell reusable fill ergonomics
but does not resolve S4-M11.

S4-M859 draws reusable VectorPareto fills through direct vector open-uniform
transforms (`compare/results/s4-m859-vector-pareto-fill-direct-transform.md`):
VectorPareto.fillFrom now draws vector open-uniform values and applies the Pareto
transform directly, including the shape-one reciprocal path, instead of routing
every output through VectorPareto.sampleFrom. This improves VectorPareto reusable
fill ergonomics but does not resolve S4-M11.

S4-M860 draws reusable VectorWeibull fills through direct vector open-uniform
transforms (`compare/results/s4-m860-vector-weibull-fill-direct-transform.md`):
VectorWeibull.fillFrom now draws vector open-uniform values and applies the
Weibull transform directly, including the shape-one standard-exponential path,
instead of routing every output through VectorWeibull.sampleFrom. This improves
VectorWeibull reusable fill ergonomics but does not resolve S4-M11.

S4-M861 draws reusable VectorGumbel fills through direct vector open-closed-uniform
transforms (`compare/results/s4-m861-vector-gumbel-fill-direct-transform.md`):
VectorGumbel.fillFrom now draws vector open-closed-uniform values and applies the
Gumbel transform directly, instead of routing every output through
VectorGumbel.sampleFrom. This improves VectorGumbel reusable fill ergonomics but
does not resolve S4-M11.

S4-M862 draws reusable VectorFrechet fills through direct vector
open-closed-uniform transforms
(`compare/results/s4-m862-vector-frechet-fill-direct-transform.md`):
VectorFrechet.fillFrom now draws vector open-closed-uniform values and applies
the Frechet transform directly, including the shape-one path, instead of routing
every output through VectorFrechet.sampleFrom. This improves VectorFrechet
reusable fill ergonomics but does not resolve S4-M11.

S4-M863 draws reusable VectorSkewNormal fills through direct vector normal
composition
(`compare/results/s4-m863-vector-skew-normal-fill-direct-composition.md`):
VectorSkewNormal.fillFrom now draws standard-normal vectors and applies the
skew-normal composition directly, including symmetric and +/-1 shape paths,
instead of routing every output through VectorSkewNormal.sampleFrom. This improves
VectorSkewNormal reusable fill ergonomics but does not resolve S4-M11.

S4-M864 draws reusable VectorPert fills through a cached vector Beta delegate
(`compare/results/s4-m864-vector-pert-fill-beta-delegate.md`):
VectorPert.fillFrom now constructs a VectorBeta sampler from the cached PERT
alpha/beta values, fills beta vectors, and affine-maps them into [min,max]
instead of routing every output through VectorPert.sampleFrom. This improves
VectorPert reusable fill ergonomics but does not resolve S4-M11.

S4-M865 draws reusable VectorInverseGaussian fills through direct vector
normal/uniform composition
(`compare/results/s4-m865-vector-inverse-gaussian-fill-direct-composition.md`):
VectorInverseGaussian.fillFrom now draws vector standard-normal and uniform values
and applies the inverse-Gaussian transform directly instead of routing every
output through VectorInverseGaussian.sampleFrom. This improves
VectorInverseGaussian reusable fill ergonomics but does not resolve S4-M11.

S4-M866 draws reusable VectorNormalInverseGaussian fills through direct vector
composition (`compare/results/s4-m866-vector-nig-fill-direct-composition.md`):
VectorNormalInverseGaussian.fillFrom now draws the embedded inverse-Gaussian
normal/uniform vector pair and final standard-normal vector directly instead of
routing every output through VectorNormalInverseGaussian.sampleFrom. This improves
VectorNormalInverseGaussian reusable fill ergonomics but does not resolve S4-M11.

S4-M867 draws reusable VectorZipf fills through direct cached scalar Zipf lane
sampling (`compare/results/s4-m867-vector-zipf-fill-direct-lanes.md`):
VectorZipf.fillFrom now samples each vector lane directly from the cached scalar
Zipf sampler instead of routing every output through VectorZipf.sampleFrom. This
improves VectorZipf reusable fill ergonomics but does not resolve S4-M11.

S4-M868 draws reusable VectorZeta fills through direct cached scalar Zeta lane
sampling (`compare/results/s4-m868-vector-zeta-fill-direct-lanes.md`):
VectorZeta.fillFrom now samples each vector lane directly from the cached scalar
Zeta sampler instead of routing every output through VectorZeta.sampleFrom. This
improves VectorZeta reusable fill ergonomics but does not resolve S4-M11.

S4-M869 draws reusable VectorBeta fills through direct cached scalar Beta lane
sampling (`compare/results/s4-m869-vector-beta-fill-direct-lanes.md`):
VectorBeta.fillFrom now samples each vector lane directly from the cached scalar
Beta sampler instead of routing every output through VectorBeta.sampleFrom. This
improves VectorBeta reusable fill ergonomics but does not resolve S4-M11.

S4-M870 draws reusable VectorPoissonAhrensDieter fills through direct cached
Ahrens-Dieter lane sampling
(`compare/results/s4-m870-vector-poisson-ad-fill-direct-lanes.md`):
VectorPoissonAhrensDieter.fillFrom now samples each vector lane directly from the
cached Ahrens-Dieter method instead of routing every output through
VectorPoissonAhrensDieter.sampleFrom. This improves VectorPoissonAhrensDieter
reusable fill ergonomics but does not resolve S4-M11.

S4-M871 draws reusable VectorBernoulli generic-probability fills through direct
cached-threshold lane comparisons
(`compare/results/s4-m871-vector-bernoulli-fill-direct-lanes.md`):
VectorBernoulli.fillFrom now draws one raw word per lane and compares against the
cached threshold instead of routing generic-probability outputs through
VectorBernoulli.sampleFrom. This improves VectorBernoulli reusable fill ergonomics
but does not resolve S4-M11.

S4-M872 draws reusable VectorGamma generic-shape fills through direct cached
scalar Gamma lane sampling
(`compare/results/s4-m872-vector-gamma-fill-direct-lanes.md`):
VectorGamma.fillFrom now samples each generic-shape vector lane directly from the
cached scalar Gamma sampler instead of routing every output through
VectorGamma.sampleFrom, while retaining the degenerate and shape-one fast paths.
This improves VectorGamma reusable fill ergonomics but does not resolve S4-M11.

S4-M873 draws reusable Gamma generic-shape fills through direct method dispatch
(`compare/results/s4-m873-gamma-fill-direct-method.md`):
Gamma.fillFrom now dispatches once to the boosted-small-shape or regular Marsaglia
path instead of routing every output through Gamma.sampleFrom, while retaining the
degenerate and shape-one fast paths. This improves Gamma reusable fill ergonomics
but does not resolve S4-M11.

S4-M874 draws reusable Beta generic fills through direct cached Gamma-ratio
composition (`compare/results/s4-m874-beta-fill-direct-gamma-ratio.md`):
Beta.fillFrom now draws gamma_a and gamma_b directly and writes x/(x+y) instead
of routing every output through Beta.sampleFrom, while retaining point-mass,
uniform, and square-root edge paths. This improves Beta reusable fill ergonomics
but does not resolve S4-M11.

S4-M875 draws reusable Pert fills through cached beta-parameter bulk delegation
(`compare/results/s4-m875-pert-fill-beta-delegate.md`):
Pert.fillFrom now fills beta variates with cached alpha/beta values and then
affine-maps them in place instead of routing every output through Pert.sampleFrom.
This improves Pert reusable fill ergonomics but does not resolve S4-M11.

S4-M876 draws reusable Kumaraswamy generic fills through direct inverse-CDF
transforms (`compare/results/s4-m876-kumaraswamy-fill-direct-transform.md`):
Kumaraswamy.fillFrom now draws open-uniform values and applies the generic
Kumaraswamy transform directly instead of routing every output through
Kumaraswamy.sampleFrom, while retaining edge fast paths. This improves
Kumaraswamy reusable fill ergonomics but does not resolve S4-M11.

S4-M877 draws reusable Zipf fills through the direct cached rejection loop
(`compare/results/s4-m877-zipf-fill-direct-rejection.md`):
Zipf.fillFrom now runs the inverse-CDF proposal and uniform rejection check
directly instead of routing every output through Zipf.sampleFrom. This improves
Zipf reusable fill ergonomics but does not resolve S4-M11.

S4-M878 draws reusable Zeta fills through the direct cached rejection loop
(`compare/results/s4-m878-zeta-fill-direct-rejection.md`):
Zeta.fillFrom now runs the open-closed proposal and uniform rejection check
directly instead of routing every output through Zeta.sampleFrom. This improves
Zeta reusable fill ergonomics but does not resolve S4-M11.

S4-M879 draws reusable UniformDuration fills through direct duration range helper
dispatch (`compare/results/s4-m879-uniform-duration-fill-direct-range.md`):
UniformDuration.fillFrom now branches once between half-open and inclusive
duration range helpers instead of routing every output through
UniformDuration.sampleFrom. This improves UniformDuration reusable fill ergonomics
but does not resolve S4-M11.

S4-M880 draws reusable ASCII Charset fills through direct uniform index sampling
(`compare/results/s4-m880-charset-fill-direct-index.md`):
Charset.fillFrom now draws uniform indexes and maps into the byte slice directly
instead of routing every byte through Charset.sampleFrom. This improves ASCII
Charset reusable fill ergonomics but does not resolve S4-M11.

S4-M881 draws reusable UnicodeCharset fills through direct uniform index sampling
(`compare/results/s4-m881-unicode-charset-fill-direct-index.md`):
UnicodeCharset.fillFrom now draws uniform indexes and maps into the scalar slice
directly instead of routing every scalar through UnicodeCharset.sampleFrom. This
improves UnicodeCharset reusable fill ergonomics but does not resolve S4-M11.

S4-M882 draws UnicodeCharset UTF-8 appends through direct uniform index sampling
(`compare/results/s4-m882-unicode-charset-append-direct-index.md`):
UnicodeCharset.appendStringFrom now draws uniform indexes and encodes selected
scalars directly instead of routing every scalar through UnicodeCharset.sampleFrom.
This improves UnicodeCharset string append ergonomics but does not resolve S4-M11.
