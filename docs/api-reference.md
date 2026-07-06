# Alea API Reference

This reference lists the public API surface by module. See `docs/core-guide.md`
for usage guidance, `docs/examples.md` for runnable examples, `docs/tooling.md`
for build/tool catalogs, and `compare/results/reproducibility-matrix.md` for
stability expectations. See `zig build rand-status`,
`zig build rand-status-json`, `zig build rand-status-schema-version`, `zig build rand-status-self-test`, `zig build rand-status -- --json`, or
`compare/results/s4-m420-current-rand-status.md` for the
current local `rand` / `rand_distr` comparison status, and
`compare/results/s4-m450-rand-status-command-matrix.md` for the latest status
command matrix evidence.

## Root Module

- Modules/namespaces: `Rng`, `Seed`, `distributions`, `distr`, `seq`, `ascii`,
  `quality`, `rngs`, `prelude`
- Engines: `SplitMix64`, `Wyhash64`, `Alea4x64`, `Xoshiro256PlusPlus`,
  `Xoshiro128PlusPlus`, `Xoshiro256`, `Pcg64`, `ChaCha`, `ChaCha8Rng`,
  `ChaCha20Rng`, `StepRng`
- Aliases: `DefaultPrng`, `FastPrng`, `HashPrng`, `ReproduciblePrng`,
  `ScalarPrng`, `SecurePrng`, `ChaCha12Rng`, `StdRng`, `SmallRng`, `SysRng`,
  `SysError`, `WeightError`
- `rngs` namespace aliases: `rngs.StdRng`, `rngs.SmallRng`, `rngs.SysRng`,
  `rngs.SysError`, `rngs.ChaCha8Rng`, `rngs.ChaCha12Rng`,
  `rngs.ChaCha20Rng`, `rngs.Xoshiro128PlusPlus`,
  `rngs.Xoshiro256PlusPlus`
- `prelude` namespace aliases: `prelude.Rng`, `prelude.Seed`,
  `prelude.distributions`, `prelude.seq`, `prelude.ascii`, `prelude.StdRng`,
  `prelude.SmallRng`, `prelude.SysRng`, `prelude.SysError`,
  `prelude.WeightError`
- Constructors: `default`, `defaultSecure`, `fast`, `fastSecure`,
  `scalar`, `scalarSecure`, `hash`, `hashSecure`, `reproducible`, `reproducibleSecure`,
  `secureFromSeed`, `secure`, `secureBytes`, `sysRng`, `stepRng`, `constRng`,
- System-entropy helpers: `makeRng`, `random`, `randomValue`,
  `randomValueChecked`, `randomIter`, `randomRange`, `randomRangeChecked`,
  `randomRangeAtMost`, `randomRangeAtMostChecked`, `randomBool`,
  `randomBoolChecked`, `randomRatio`, `randomRatioChecked`, `fill`,
  `valueBatch`, `valueBatchChecked`, `fillRange`, `fillRangeChecked`,
  `rangeBatch`, `rangeBatchChecked`, `fillRangeAtMost`,
  `fillRangeAtMostChecked`, `rangeAtMostBatch`, `rangeAtMostBatchChecked`,
  `fillRandomBool`, `fillRandomBoolChecked`, `randomBoolBatch`,
  `randomBoolBatchChecked`, `fillRandomRatio`, `fillRandomRatioChecked`,
  `randomRatioBatch`, `randomRatioBatchChecked`, `fillOpen`, `openBatch`,
  `fillOpenClosed`, `openClosedBatch`, `durationRangeLessThan`,
  `durationRangeLessThanChecked`, `durationRangeLessThanBatch`,
  `durationRangeLessThanBatchChecked`, `durationRangeAtMost`,
  `durationRangeAtMostChecked`, `durationRangeAtMostBatch`,
  `durationRangeAtMostBatchChecked`, `char`, `string`, `sampleString`,
  `appendString`, `unicodeScalar`, `unicodeScalarRangeLessThan`,
  `unicodeScalarRangeLessThanChecked`, `unicodeScalarRangeAtMost`,
  `unicodeScalarRangeAtMostChecked`, `fillUnicodeScalar`,
  `fillUnicodeScalarRangeLessThan`, `fillUnicodeScalarRangeLessThanChecked`,
  `fillUnicodeScalarRangeAtMost`, `fillUnicodeScalarRangeAtMostChecked`,
  `unicodeScalarBatch`, `unicodeScalarRangeLessThanBatch`,
  `unicodeScalarRangeLessThanBatchChecked`, `unicodeScalarRangeAtMostBatch`,
  `unicodeScalarRangeAtMostBatchChecked`, `unicodeUtf8Capacity`,
  `unicodeUtf8Into`, `unicodeUtf8Alloc`
- Root reader aliases: `RngReader(Source)`, `rngReader`
- `RandomIterator(T)`: `RandomIterator.next`, `RandomIterator.nextValue`,
  `RandomIterator.fill`, `RandomIterator.sizeHint`
- Facade constructor: `rng`

## Rng

- Error type: `Error`
- System entropy source: `SysRng`, `SysError`, `SysRng.Error`, `SysRng.init`,
  `SysRng.reader`, `SysRng.tryNext`, `SysRng.tryNextU64`,
  `SysRng.tryNextU32`, `SysRng.tryFillBytes`
- Construction and interop: `init`, `fromRandom`, `random`, `reader`,
  `readerFrom`, `RngReader`, `rngReader`
- `RngReader(Source)`: `RngReader.init`, `RngReader.reader`,
  `RngReader.read`, `RngReader.readAll`, `RngReader.lastError`
- Values: `value`, `valueFrom`, `valueChecked`, `valueCheckedFrom`,
  `randomValue`, `randomValueFrom`, `randomValueChecked`,
  `randomValueCheckedFrom`,
  `valueBatch`, `valueBatchFrom`, `valueBatchChecked`,
  `valueBatchCheckedFrom`, `valueIter`, `valueIterFrom`, `randomIter`,
  `randomIterFrom`, `sample`, `sampleFrom`, `sampleIter`, `sampleIterFrom`, `sampleBatch`,
  `sampleBatchFrom`
- Bytes/fill: `bytes`, `fillBytes`, `tryFillBytes`, `fillBytesFrom`,
  `tryFillBytesFrom`,
  `bytesAlloc`, `bytesAllocFrom`, `fill` and `fillFrom` for scalar and vector slices,
  `fillSample`, `fillSampleFrom`, `fillRange`, `fillRangeFrom`,
  `fillRangeChecked`, `fillRangeCheckedFrom`, `fillRangeAtMost`,
  `fillRangeAtMostFrom`, `fillRangeAtMostChecked`,
  `fillRangeAtMostCheckedFrom`, `fillOpen`,
  `fillOpenFrom`, `openBatch`, `openBatchFrom`, `fillOpenClosed`,
  `fillOpenClosedFrom`, `openClosedBatch`, `openClosedBatchFrom`, `fillChance`,
  `fillChanceChecked`, `fillChanceCheckedFrom`, `chanceBatch`,
  `chanceBatchFrom`, `chanceBatchChecked`, `chanceBatchCheckedFrom`,
  `fillRatio`, `fillRatioChecked`, `fillRatioCheckedFrom`, `ratioBatch`,
  `ratioBatchFrom`, `ratioBatchChecked`, `ratioBatchCheckedFrom`,
  `fillStandardNormal`, `fillStandardNormalFrom`, `standardNormalBatch`,
  `standardNormalBatchFrom`, `fillNormal`, `normalBatch`, `normalBatchFrom`,
  `normalBatchChecked`, `normalBatchCheckedFrom`, `fillNormalChecked`,
  `fillNormalCheckedFrom`, `fillStandardExponential`,
  `fillStandardExponentialFrom`, `standardExponentialBatch`,
  `standardExponentialBatchFrom`, `fillExponential`, `exponentialBatch`,
  `exponentialBatchFrom`, `exponentialBatchChecked`, `exponentialBatchCheckedFrom`,
  `fillExponentialChecked`, `fillExponentialCheckedFrom`, `fillVectorRange`,
  `fillVectorRangeAtMost`, `fillVectorRangeAtMostFrom`,
  `fillVectorRangeAtMostChecked`, `fillVectorRangeAtMostCheckedFrom`,
  `fillVectorOpen`, `fillVectorOpenClosed`, `fillVectorRangeChecked`,
  `fillVectorRangeCheckedFrom`, `fillVectorChance`, `fillVectorChanceChecked`,
  `fillVectorRatio`, `fillVectorRatioChecked`, `fillVectorStandardNormal`,
  `fillVectorStandardNormalFrom`, `vectorStandardNormalBatch`,
  `vectorStandardNormalBatchFrom`, `fillVectorNormal`,
  `fillVectorChanceCheckedFrom`, `fillVectorRatioCheckedFrom`,
  `vectorNormalBatch`, `vectorNormalBatchFrom`, `vectorNormalBatchChecked`,
  `vectorNormalBatchCheckedFrom`, `fillVectorNormalChecked`,
  `fillVectorNormalCheckedFrom`, `vectorExponentialBatch`,
  `vectorExponentialBatchFrom`, `vectorExponentialBatchChecked`,
  `vectorExponentialBatchCheckedFrom`, `fillVectorExponential`,
  `fillVectorExponentialChecked`, `fillVectorExponentialCheckedFrom`, `fillNormalFrom`,
  `fillExponentialFrom`, `fillChanceFrom`, `fillRatioFrom`, `fillVectorFrom`,
  `fillVectorOpenFrom`, `fillVectorOpenClosedFrom`, `fillVectorRangeFrom`,
  `fillVectorChanceFrom`, `fillVectorRatioFrom`, `fillVectorNormalFrom`,
  `fillVectorStandardExponential`, `fillVectorStandardExponentialFrom`,
  `vectorStandardExponentialBatch`, `vectorStandardExponentialBatchFrom`,
  `fillVectorExponentialFrom`
- Raw/scalars: `next`, `nextFrom`, `nextU64`, `tryNextU64`, `nextU64From`,
  `tryNextU64From`, `nextU32`, `tryNextU32`, `nextU32From`,
  `tryNextU32From`, `boolean`, `booleanFrom`, `chance`, `chanceChecked`, `ratio`,
  `chanceFrom`, `chanceCheckedFrom`, `ratioFrom`, `ratioChecked`,
  `ratioCheckedFrom`, `randomBool`, `randomBoolFrom`,
  `randomBoolChecked`, `randomBoolCheckedFrom`, `randomRatio`,
  `randomRatioFrom`, `randomRatioChecked`, `randomRatioCheckedFrom`,
  `uint`, `uintLessThan`, `uintLessThanChecked`,
  `uintLessThanCheckedFrom`, `fillUintLessThan`, `fillUintLessThanFrom`,
  `fillUintLessThanChecked`, `fillUintLessThanCheckedFrom`,
  `uintLessThanBatch`, `uintLessThanBatchFrom`, `uintLessThanBatchChecked`,
  `uintLessThanBatchCheckedFrom`, `uintAtMost`, `fillUintAtMost`,
  `fillUintAtMostFrom`, `uintAtMostBatch`, `uintAtMostBatchFrom`,
  `uintFrom`, `uintLessThanFrom`, `uintAtMostFrom`,
  `probabilityThreshold`
- Ranges: `intRangeLessThan`, `intRangeLessThanChecked`, `intRangeAtMost`,
  `intRangeLessThanCheckedFrom`, `intRangeAtMostChecked`,
  `intRangeAtMostCheckedFrom`, `intRangeLessThanFrom`, `intRangeAtMostFrom`,
  `randomRange`, `randomRangeFrom`, `randomRangeChecked`,
  `randomRangeCheckedFrom`, `randomRangeAtMost`, `randomRangeAtMostFrom`,
  `randomRangeAtMostChecked`, `randomRangeAtMostCheckedFrom`,
  `floatRange`, `floatRangeFrom`, `floatRangeChecked`, `floatRangeCheckedFrom`,
  `rangeBatch`, `rangeBatchFrom`, `rangeBatchChecked`,
  `rangeBatchCheckedFrom`, `rangeAtMostBatch`, `rangeAtMostBatchFrom`,
  `rangeAtMostBatchChecked`, `rangeAtMostBatchCheckedFrom`,
  `durationRangeLessThan`,
  `durationRangeLessThanFrom`, `durationRangeLessThanBatch`,
  `durationRangeLessThanBatchFrom`, `durationRangeAtMost`,
  `durationRangeAtMostFrom`, `durationRangeAtMostBatch`,
  `durationRangeAtMostBatchFrom`, `durationRangeLessThanChecked`,
  `durationRangeLessThanCheckedFrom`, `durationRangeLessThanBatchChecked`,
  `durationRangeLessThanBatchCheckedFrom`, `durationRangeAtMostChecked`,
  `durationRangeAtMostCheckedFrom`, `durationRangeAtMostBatchChecked`,
  `durationRangeAtMostBatchCheckedFrom`
- Floats: `float`, `floatFrom`, `floatOpen`, `floatOpenFrom`,
  `floatOpenClosed`, `floatOpenClosedFrom`
- Vectors: `vector`, `vectorOpen`, `vectorOpenClosed`, `vectorRange`,
  `vectorRangeAtMost`, `vectorRangeAtMostFrom`, `vectorRangeAtMostChecked`,
  `vectorRangeAtMostCheckedFrom`, `vectorRangeAtMostBatch`,
  `vectorRangeAtMostBatchFrom`, `vectorRangeAtMostBatchChecked`,
  `vectorRangeAtMostBatchCheckedFrom`, `vectorRangeChecked`, `vectorRangeCheckedFrom`, `vectorRangeBatch`,
  `vectorRangeBatchFrom`, `vectorRangeBatchChecked`,
  `vectorRangeBatchCheckedFrom`, `vectorOpenBatch`, `vectorOpenBatchFrom`,
  `vectorOpenClosedBatch`, `vectorOpenClosedBatchFrom`, `vectorChance`,
  `vectorChanceChecked`, `vectorChanceCheckedFrom`, `vectorChanceBatch`,
  `vectorChanceBatchFrom`, `vectorChanceBatchChecked`,
  `vectorChanceBatchCheckedFrom`, `vectorRatio`, `vectorRatioChecked`,
  `vectorRatioCheckedFrom`, `vectorRatioBatch`, `vectorRatioBatchFrom`,
  `vectorRatioBatchChecked`, `vectorRatioBatchCheckedFrom`,
  `vectorStandardNormal`, `vectorStandardNormalBatch`,
  `vectorStandardNormalBatchFrom`, `vectorNormal`, `vectorNormalChecked`,
  `vectorNormalBatch`, `vectorNormalBatchFrom`, `vectorNormalBatchChecked`,
  `vectorNormalBatchCheckedFrom`, `vectorStandardExponential`,
  `vectorStandardExponentialBatch`, `vectorStandardExponentialBatchFrom`,
  `vectorExponential`, `vectorExponentialChecked`, `vectorExponentialBatch`,
  `vectorExponentialBatchFrom`, `vectorExponentialBatchChecked`,
  `vectorExponentialBatchCheckedFrom`,
  `vectorFrom`, `vectorOpenFrom`, `vectorOpenClosedFrom`,
  `vectorRangeFrom`, `vectorChanceFrom`, `vectorRatioFrom`,
  `vectorStandardNormalFrom`, `vectorNormalFrom`, `vectorNormalCheckedFrom`,
  `vectorStandardExponentialFrom`, `vectorExponentialFrom`,
  `vectorExponentialCheckedFrom`
- Unicode: `unicodeScalar`, `unicodeScalarFrom`, `unicodeScalarRangeLessThan`,
  `unicodeScalarRangeLessThanFrom`, `unicodeScalarRangeLessThanChecked`,
  `unicodeScalarRangeLessThanCheckedFrom`, `unicodeScalarRangeAtMost`,
  `unicodeScalarRangeAtMostFrom`, `unicodeScalarRangeAtMostChecked`,
  `unicodeScalarRangeAtMostCheckedFrom`, `fillUnicodeScalar`,
  `fillUnicodeScalarFrom`, `fillUnicodeScalarRangeLessThan`,
  `fillUnicodeScalarRangeLessThanFrom`,
  `fillUnicodeScalarRangeLessThanChecked`,
  `fillUnicodeScalarRangeLessThanCheckedFrom`,
  `fillUnicodeScalarRangeAtMost`, `fillUnicodeScalarRangeAtMostFrom`,
  `fillUnicodeScalarRangeAtMostChecked`,
  `fillUnicodeScalarRangeAtMostCheckedFrom`, `unicodeScalarBatch`,
  `unicodeScalarBatchFrom`, `unicodeScalarRangeLessThanBatch`,
  `unicodeScalarRangeLessThanBatchFrom`,
  `unicodeScalarRangeLessThanBatchChecked`,
  `unicodeScalarRangeLessThanBatchCheckedFrom`,
  `unicodeScalarRangeAtMostBatch`, `unicodeScalarRangeAtMostBatchFrom`,
  `unicodeScalarRangeAtMostBatchChecked`,
  `unicodeScalarRangeAtMostBatchCheckedFrom`
- Distributions: `standardNormal`, `standardNormalFrom`, `normal`,
  `normalChecked`, `normalCheckedFrom`, `standardExponential`,
  `standardExponentialFrom`, `exponential`, `exponentialChecked`,
  `exponentialCheckedFrom`, `standardNormalFastFrom`,
  `standardExponentialFastFrom`, `normalFastFrom`, `exponentialFastFrom`
- Enums and collections: `enumValue`, `enumValueFrom`, `enumValueChecked`,
  `enumValueCheckedFrom`, `shuffle`, `shuffleFrom`, `choose`,
  `chooseFrom`, `chooseChecked`, `chooseCheckedFrom`, `fillChoose`,
  `fillChooseFrom`, `fillChooseChecked`, `fillChooseCheckedFrom`,
  `chooseValueArray`, `chooseValueArrayFrom`,
  `chooseValueArrayChecked`, `chooseValueArrayCheckedFrom`,
  `chooseBatch`, `chooseBatchFrom`, `chooseBatchChecked`,
  `chooseBatchCheckedFrom`, `chooseIndex`,
  `chooseIndexFrom`, `chooseIndexChecked`, `chooseIndexCheckedFrom`,
  `chooseIndexArray`, `chooseIndexArrayFrom`,
  `chooseIndexArrayChecked`, `chooseIndexArrayCheckedFrom`,
  `fillChooseIndex`, `fillChooseIndexFrom`, `fillChooseIndexChecked`,
  `fillChooseIndexCheckedFrom`, `chooseIndexBatch`, `chooseIndexBatchFrom`,
  `chooseIndexBatchChecked`, `chooseIndexBatchCheckedFrom`,
  `chooseIndexU32`, `chooseIndexU32From`, `chooseIndexU32Checked`,
  `chooseIndexU32CheckedFrom`, `chooseIndexArrayU32`,
  `chooseIndexArrayU32From`, `chooseIndexArrayU32Checked`,
  `chooseIndexArrayU32CheckedFrom`, `fillChooseIndexU32`, `fillChooseIndexU32From`,
  `fillChooseIndexU32Checked`, `fillChooseIndexU32CheckedFrom`,
  `chooseIndexU32Batch`, `chooseIndexU32BatchFrom`,
  `chooseIndexU32BatchChecked`, `chooseIndexU32BatchCheckedFrom`, `chooseConstPtr`,
  `chooseConstPtrFrom`, `chooseConstPtrChecked`,
  `chooseConstPtrCheckedFrom`, `chooseConstPtrArray`,
  `chooseConstPtrArrayFrom`, `chooseConstPtrArrayChecked`,
  `chooseConstPtrArrayCheckedFrom`, `fillChooseConstPtr`,
  `fillChooseConstPtrFrom`, `fillChooseConstPtrChecked`,
  `fillChooseConstPtrCheckedFrom`, `chooseConstPtrBatch`,
  `chooseConstPtrBatchFrom`, `chooseConstPtrBatchChecked`,
  `chooseConstPtrBatchCheckedFrom`, `choosePtr`, `choosePtrFrom`,
  `choosePtrChecked`, `choosePtrCheckedFrom`, `choosePtrArray`,
  `choosePtrArrayFrom`, `choosePtrArrayChecked`,
  `choosePtrArrayCheckedFrom`, `fillChoosePtr`,
  `fillChoosePtrFrom`, `fillChoosePtrChecked`, `fillChoosePtrCheckedFrom`,
  `choosePtrBatch`, `choosePtrBatchFrom`, `choosePtrBatchChecked`,
  `choosePtrBatchCheckedFrom`, `weightedIndex`, `weightedIndexFrom`,
  `fillWeightedIndex`, `fillWeightedIndexFrom`, `fillWeightedIndexChecked`,
  `fillWeightedIndexCheckedFrom`, `weightedIndexBatch`,
  `weightedIndexBatchFrom`, `weightedIndexBatchChecked`,
  `weightedIndexBatchCheckedFrom`, `weightedIndexArray`,
  `weightedIndexArrayFrom`, `weightedIndexArrayChecked`,
  `weightedIndexArrayCheckedFrom`, `weightedIndexChecked`, `weightedIndexCheckedFrom`,
  `weightedIndexU32`, `weightedIndexU32From`, `weightedIndexU32Checked`,
  `weightedIndexU32CheckedFrom`, `fillWeightedIndexU32`,
  `fillWeightedIndexU32From`, `fillWeightedIndexU32Checked`,
  `fillWeightedIndexU32CheckedFrom`, `weightedIndexU32Batch`,
  `weightedIndexU32BatchFrom`, `weightedIndexU32BatchChecked`,
  `weightedIndexU32BatchCheckedFrom`, `weightedIndexU32Array`,
  `weightedIndexU32ArrayFrom`, `weightedIndexU32ArrayChecked`,
  `weightedIndexU32ArrayCheckedFrom`, `chooseWeighted`, `chooseWeightedFrom`,
  `chooseWeightedBy`, `chooseWeightedByFrom`, `chooseWeightedByChecked`,
  `chooseWeightedByCheckedFrom`, `weightedIndexArrayBy`,
  `weightedIndexArrayByFrom`, `weightedIndexArrayByChecked`,
  `weightedIndexArrayByCheckedFrom`, `weightedIndexU32ArrayBy`,
  `weightedIndexU32ArrayByFrom`, `weightedIndexU32ArrayByChecked`,
  `weightedIndexU32ArrayByCheckedFrom`, `chooseWeightedValueArrayBy`,
  `chooseWeightedValueArrayByFrom`, `chooseWeightedValueArrayByChecked`,
  `chooseWeightedValueArrayByCheckedFrom`,
  `fillChooseWeighted`, `fillChooseWeightedFrom`, `fillChooseWeightedChecked`,
  `fillChooseWeightedCheckedFrom`, `chooseWeightedBatch`,
  `chooseWeightedBatchFrom`, `chooseWeightedBatchChecked`,
  `chooseWeightedBatchCheckedFrom`, `chooseWeightedIter`,
  `chooseWeightedIterFrom`, `chooseWeightedIterChecked`,
  `chooseWeightedIterCheckedFrom`, `chooseWeightedIterBy`,
  `chooseWeightedIterByFrom`, `chooseWeightedIterByChecked`,
  `chooseWeightedIterByCheckedFrom`, `chooseWeightedIterByIndex`,
  `chooseWeightedIterByIndexFrom`, `chooseWeightedIterByIndexChecked`,
  `chooseWeightedIterByIndexCheckedFrom`, `chooseWeightedValueArray`,
  `chooseWeightedValueArrayFrom`, `chooseWeightedValueArrayChecked`,
  `chooseWeightedValueArrayCheckedFrom`, `chooseWeightedConstPtr`,
  `chooseWeightedConstPtrFrom`, `chooseWeightedConstPtrChecked`,
  `chooseWeightedConstPtrCheckedFrom`, `chooseWeightedConstPtrBy`,
  `chooseWeightedConstPtrByFrom`, `chooseWeightedConstPtrByChecked`,
  `chooseWeightedConstPtrByCheckedFrom`, `chooseWeightedConstPtrArrayBy`,
  `chooseWeightedConstPtrArrayByFrom`,
  `chooseWeightedConstPtrArrayByChecked`,
  `chooseWeightedConstPtrArrayByCheckedFrom`, `fillChooseWeightedConstPtr`,
  `fillChooseWeightedConstPtrFrom`, `fillChooseWeightedConstPtrChecked`,
  `fillChooseWeightedConstPtrCheckedFrom`, `chooseWeightedConstPtrBatch`,
  `chooseWeightedConstPtrBatchFrom`, `chooseWeightedConstPtrBatchChecked`,
  `chooseWeightedConstPtrBatchCheckedFrom`, `chooseWeightedConstPtrArray`,
  `chooseWeightedConstPtrArrayFrom`, `chooseWeightedConstPtrArrayChecked`,
  `chooseWeightedConstPtrArrayCheckedFrom`, `chooseWeightedPtr`,
  `chooseWeightedPtrFrom`, `chooseWeightedPtrChecked`,
  `chooseWeightedPtrCheckedFrom`, `chooseWeightedPtrBy`,
  `chooseWeightedPtrByFrom`, `chooseWeightedPtrByChecked`,
  `chooseWeightedPtrByCheckedFrom`, `chooseWeightedPtrArrayBy`,
  `chooseWeightedPtrArrayByFrom`, `chooseWeightedPtrArrayByChecked`,
  `chooseWeightedPtrArrayByCheckedFrom`, `fillChooseWeightedPtr`,
  `fillChooseWeightedPtrFrom`, `fillChooseWeightedPtrChecked`,
  `fillChooseWeightedPtrCheckedFrom`, `chooseWeightedPtrBatch`,
  `chooseWeightedPtrBatchFrom`, `chooseWeightedPtrBatchChecked`,
  `chooseWeightedPtrBatchCheckedFrom`, `chooseWeightedPtrArray`,
  `chooseWeightedPtrArrayFrom`, `chooseWeightedPtrArrayChecked`,
  `chooseWeightedPtrArrayCheckedFrom`,
  `sampleWithoutReplacement`, `sampleWithoutReplacementFrom`,
  `sampleWithoutReplacementChecked`, `sampleWithoutReplacementCheckedFrom`
- Iterator types: `ValueIterator(T)`, `ValueIteratorFrom(Source, T)`,
  `ValueIterator.next`, `ValueIterator.nextValue`, `ValueIterator.fill`,
  `ValueIterator.sizeHint`,
  `ValueIteratorFrom.next`, `ValueIteratorFrom.nextValue`,
  `ValueIteratorFrom.fill`, `ValueIteratorFrom.sizeHint`,
  `SampleIterator(Sampler, T)`,
  `SampleIterator.next`, `SampleIterator.nextValue`, `SampleIterator.fill`,
  `SampleIterator.sizeHint`,
  `SampleIteratorFrom(Source, Sampler, T)`, `SampleIteratorFrom.next`,
  `SampleIteratorFrom.nextValue`, `SampleIteratorFrom.fill`,
  `SampleIteratorFrom.sizeHint`

## Seed

- `init`
- `fromBytes`
- `fromString`
- `fromRng`
- `tryFromRng`
- `secure`
- `mix`
- `stream`
- `next`
- `bytes`

## Engines

All engines expose deterministic construction and `random()` interop where
appropriate. Engines with byte fills expose Rust-discoverable `fillBytes`
aliases; all deterministic engines expose Rust-discoverable `nextU64` /
`nextU32` raw aliases alongside `next`, `tryNextU64`, and `tryNextU32`.
Seedable production engines also expose Rust-discoverable `seedFromU64`,
`fromSeed`, and `fromSeedBytes` constructor aliases alongside their Zig-native
seed constructors. Engines with larger state expose Rust-discoverable `fromRng`
and `fork` helpers for
deriving child streams from existing generators, plus `tryFromRng` for
fallible sources exposing `tryNext() !u64` and `tryFork` for fallible
self-forking.

- `SplitMix64`: `init`, `seedFromU64`, `fromSeed`, `fromSeedBytes`, `next`,
  `tryNext`, `nextU64`, `tryNextU64`, `nextU32`, `tryNextU32`, `fromRng`, `tryFromRng`, `fork`,
  `tryFork`
- `Wyhash64`: `init`, `seedFromU64`, `fromSeed`, `fromSeedBytes`,
  `fromState`, `random`, `next`, `tryNext`, `nextU64`, `tryNextU64`,
  `nextU32`, `tryNextU32`, `fill`, `fillBytes`, `tryFillBytes`, `fromRng`,
  `tryFromRng`, `fork`, `tryFork`
- `Alea4x64`: `init`, `seedFromU64`, `fromSeed`, `fromSeedBytes`, `random`,
  `next`, `tryNext`, `nextU64`, `tryNextU64`, `nextU32`, `tryNextU32`,
  `fill`, `fillBytes`, `tryFillBytes`, `fromRng`, `tryFromRng`, `fork`,
  `tryFork`
- `Xoshiro128PlusPlus`: `init`, `seedFromU64`, `fromSeed`, `fromSeedBytes`,
  `seed`, `random`, `next`, `tryNext`, `nextU64`, `tryNextU64`, `nextU32`,
  `tryNextU32`, `fill`, `fillBytes`, `tryFillBytes`, `fromRng`, `tryFromRng`,
  `fork`, `tryFork`
- `Xoshiro256`: `init`, `seedFromU64`, `fromSeed`, `fromSeedBytes`, `seed`,
  `random`, `next`, `tryNext`, `nextU64`, `tryNextU64`, `nextU32`,
  `tryNextU32`, `split`, `jump`, `longJump`, `fill`, `fillBytes`,
  `tryFillBytes`, `fromRng`, `tryFromRng`, `fork`, `tryFork`
- `Xoshiro256PlusPlus`: `init`, `seedFromU64`, `fromSeed`, `fromSeedBytes`,
  `random`, `next`, `tryNext`, `nextU64`, `tryNextU64`, `nextU32`,
  `tryNextU32`, `jump`, `fill`, `fillBytes`, `tryFillBytes`, `fromRng`,
  `tryFromRng`, `fork`, `tryFork`
- `Pcg64`: `init`, `seedFromU64`, `fromSeed`, `fromSeedBytes`, `initTwo`,
  `random`, `next`, `tryNext`, `nextU64`, `tryNextU64`, `nextU32`,
  `tryNextU32`, `fill`, `fillBytes`, `tryFillBytes`, `fromRng`, `tryFromRng`,
  `fork`, `tryFork`
- `ChaCha`: `seed_length`, `init`, `initFromU64`, `random`, `addEntropy`,
  `seedFromU64`, `fromSeed`, `fromSeedBytes`, `next`, `tryNext`, `nextU64`,
  `tryNextU64`, `nextU32`, `tryNextU32`, `fill`, `fillBytes`, `tryFillBytes`,
  `fromRng`, `tryFromRng`, `fork`, `tryFork`
- `ChaCha8Rng`: `seed_length`, `init`, `initFromU64`, `random`, `addEntropy`,
  `seedFromU64`, `fromSeed`, `fromSeedBytes`, `next`, `tryNext`, `nextU64`,
  `tryNextU64`, `nextU32`, `tryNextU32`, `fill`, `fillBytes`, `tryFillBytes`,
  `fromRng`, `tryFromRng`, `fork`, `tryFork`
- `ChaCha20Rng`: `seed_length`, `init`, `initFromU64`, `random`, `addEntropy`,
  `seedFromU64`, `fromSeed`, `fromSeedBytes`, `next`, `tryNext`, `nextU64`,
  `tryNextU64`, `nextU32`, `tryNextU32`, `fill`, `fillBytes`, `tryFillBytes`,
  `fromRng`, `tryFromRng`, `fork`, `tryFork`
- `StepRng`: `init`, `new`, `constant`, `constRng`, `fromSeedBytes`,
  `random`, `next`, `tryNext`, `nextU64`, `tryNextU64`, `nextU32`,
  `tryNextU32`, `fill`, `fillBytes`, `tryFillBytes`

## Distributions

- Error types/aliases: `Error`, `UniformError`, `BernoulliError`,
  `WeightedError`, `WeightError`, `weighted.Error`,
  `weighted.WeightedError`, `weighted.WeightError`, `slice.Empty`,
  `NormalError`, `ExpError`, `GammaError`, `BetaError`, `BinomialError`,
  `CauchyError`, `ChiSquaredError`, `FisherFError`, `FrechetError`,
  `GeoError`, `GumbelError`, `HyperGeoError`, `InverseGaussianError`,
  `NormalInverseGaussianError`, `ParetoError`, `PertError`, `PoissonError`,
  `SkewNormalError`, `TriangularError`, `WeibullError`, `ZetaError`,
  `ZipfError`;
  uniform/range APIs distinguish
  `EmptyRange` from `NonFinite` for non-finite floating-point endpoints or
  widths, while static weighted samplers distinguish `InvalidInput`,
  `InvalidWeight`, `InsufficientNonZero`, and `Overflow`
- Reusable sampler adapters: `StandardUniform`, `StandardUniform.sample`,
  `StandardUniform.sampleFrom`, `StandardUniform.fill`,
  `StandardUniform.fillFrom`, `Choose(T)`, `Alphanumeric`, `Alphabetic`,
  `sampleIter`, `sampleIterFrom`, `Iter(Sampler, Source, T)`, `map`,
  `Map(Sampler, Mapper, In, Out)`, `MappedSampler`, `MappedSampler.sample`,
  `MappedSampler.sampleFrom`, `MappedSampler.fill`,
  `MappedSampler.fillFrom`, `MappedSampler.map`

Single-shot helpers:

- `uniform`, `uniformFrom`, `uniformChecked`, `uniformCheckedFrom`,
  `sampleSingle`, `sampleSingleFrom`, `uniformInclusive`,
  `uniformInclusiveFrom`, `uniformInclusiveChecked`,
  `uniformInclusiveCheckedFrom`, `sampleSingleInclusive`,
  `sampleSingleInclusiveFrom`, `fillUniform`, `fillUniformFrom`,
  `fillUniformChecked`, `fillUniformCheckedFrom`, `fillUniformInclusive`,
  `fillUniformInclusiveFrom`, `fillUniformInclusiveChecked`,
  `fillUniformInclusiveCheckedFrom`, `vectorUniform`, `vectorUniformFrom`,
  `vectorUniformChecked`, `vectorUniformCheckedFrom`, `fillVectorUniform`,
  `fillVectorUniformFrom`, `fillVectorUniformChecked`,
  `fillVectorUniformCheckedFrom`, `vectorUniformInclusive`,
  `vectorUniformInclusiveFrom`, `vectorUniformInclusiveChecked`,
  `vectorUniformInclusiveCheckedFrom`, `fillVectorUniformInclusive`,
  `fillVectorUniformInclusiveFrom`, `fillVectorUniformInclusiveChecked`,
  `fillVectorUniformInclusiveCheckedFrom`
- `bernoulli`, `bernoulliFrom`, `bernoulliChecked`,
  `bernoulliCheckedFrom`, `fillBernoulli`, `fillBernoulliFrom`,
  `fillBernoulliChecked`, `fillBernoulliCheckedFrom`, `vectorBernoulli`,
  `vectorBernoulliFrom`, `vectorBernoulliChecked`,
  `vectorBernoulliCheckedFrom`, `fillVectorBernoulli`,
  `fillVectorBernoulliFrom`, `fillVectorBernoulliChecked`,
  `fillVectorBernoulliCheckedFrom`, `binomial`,
  `binomialFrom`, `binomialChecked`, `binomialCheckedFrom`, `fillBinomial`, `fillBinomialFrom`,
  `fillBinomialChecked`, `fillBinomialCheckedFrom`, `vectorBinomial`,
  `vectorBinomialFrom`, `vectorBinomialChecked`,
  `vectorBinomialCheckedFrom`, `fillVectorBinomial`,
  `fillVectorBinomialFrom`, `fillVectorBinomialChecked`,
  `fillVectorBinomialCheckedFrom`,
  `binomialPoissonApprox`, `binomialPoissonApproxFrom`,
  `binomialPoissonApproxChecked`, `binomialPoissonApproxCheckedFrom`,
  `vectorBinomialPoissonApprox`, `vectorBinomialPoissonApproxFrom`,
  `vectorBinomialPoissonApproxChecked`, `vectorBinomialPoissonApproxCheckedFrom`,
  `fillVectorBinomialPoissonApprox`, `fillVectorBinomialPoissonApproxFrom`,
  `fillVectorBinomialPoissonApproxChecked`, `fillVectorBinomialPoissonApproxCheckedFrom`
- `negativeBinomial`, `negativeBinomialFrom`, `negativeBinomialChecked`,
  `negativeBinomialCheckedFrom`, `fillNegativeBinomial`,
  `fillNegativeBinomialFrom`, `fillNegativeBinomialChecked`,
  `fillNegativeBinomialCheckedFrom`, `vectorNegativeBinomial`,
  `vectorNegativeBinomialFrom`, `vectorNegativeBinomialChecked`,
  `vectorNegativeBinomialCheckedFrom`, `fillVectorNegativeBinomial`,
  `fillVectorNegativeBinomialFrom`, `fillVectorNegativeBinomialChecked`,
  `fillVectorNegativeBinomialCheckedFrom`, `hypergeometric`, `hypergeometricFrom`,
  `hypergeometricChecked`, `hypergeometricCheckedFrom`,
  `fillHypergeometric`, `fillHypergeometricFrom`,
  `fillHypergeometricChecked`, `fillHypergeometricCheckedFrom`,
  `vectorHypergeometric`, `vectorHypergeometricFrom`,
  `vectorHypergeometricChecked`, `vectorHypergeometricCheckedFrom`,
  `fillVectorHypergeometric`, `fillVectorHypergeometricFrom`,
  `fillVectorHypergeometricChecked`, `fillVectorHypergeometricCheckedFrom`
- `standardNormal`, `standardNormalFrom`, `fillStandardNormal`,
  `standardNormalNativeF32`, `standardNormalNativeF32From`,
  `fillStandardNormalNativeF32`, `fillStandardNormalNativeF32From`,
  `vectorStandardNormalNativeF32`, `vectorStandardNormalNativeF32From`,
  `fillVectorStandardNormalNativeF32`,
  `fillVectorStandardNormalNativeF32From`,
  `vectorStandardNormalTableF32`, `vectorStandardNormalTableF32From`,
  `fillVectorStandardNormalTableF32`, `fillVectorStandardNormalTableF32From`,
  `vectorStandardNormalTableF64`, `vectorStandardNormalTableF64From`,
  `fillVectorStandardNormalTableF64`, `fillVectorStandardNormalTableF64From`,
  `fillStandardNormalFrom`, `vectorStandardNormal`,
  `vectorStandardNormalFrom`, `fillVectorStandardNormal`,
  `fillVectorStandardNormalFrom`, `normal`, `normalFrom`, `normalChecked`,
  `normalCheckedFrom`, `normalNativeF32`, `normalNativeF32From`,
  `normalNativeF32Checked`, `normalNativeF32CheckedFrom`, `fillNormal`,
  `fillNormalFrom`, `fillNormalChecked`, `fillNormalCheckedFrom`,
  `fillNormalNativeF32`, `fillNormalNativeF32From`,
  `fillNormalNativeF32Checked`, `fillNormalNativeF32CheckedFrom`,
  `vectorNormalNativeF32`, `vectorNormalNativeF32From`,
  `vectorNormalNativeF32Checked`, `vectorNormalNativeF32CheckedFrom`,
  `fillVectorNormalNativeF32`, `fillVectorNormalNativeF32From`,
  `fillVectorNormalNativeF32Checked`, `fillVectorNormalNativeF32CheckedFrom`,
  `vectorNormalTableF32`, `vectorNormalTableF32From`,
  `vectorNormalTableF32Checked`, `vectorNormalTableF32CheckedFrom`,
  `fillVectorNormalTableF32`, `fillVectorNormalTableF32From`,
  `fillVectorNormalTableF32Checked`, `fillVectorNormalTableF32CheckedFrom`,
  `vectorNormalTableF64`, `vectorNormalTableF64From`,
  `vectorNormalTableF64Checked`, `vectorNormalTableF64CheckedFrom`,
  `fillVectorNormalTableF64`, `fillVectorNormalTableF64From`,
  `fillVectorNormalTableF64Checked`, `fillVectorNormalTableF64CheckedFrom`,
  `vectorNormal`, `vectorNormalFrom`,
  `vectorNormalChecked`, `vectorNormalCheckedFrom`, `fillVectorNormal`,
  `fillVectorNormalFrom`, `fillVectorNormalChecked`,
  `fillVectorNormalCheckedFrom`, `logNormal`, `logNormalFrom`,
  `logNormalChecked`, `logNormalCheckedFrom`, `fillLogNormal`,
  `fillLogNormalFrom`, `fillLogNormalChecked`, `fillLogNormalCheckedFrom`,
  `BufferedLogNormal`, `LogNormalLibmvec`, `LogNormalDlsymExp`,
  `logNormalNativeF32`, `logNormalNativeF32From`,
  `logNormalNativeF32Checked`, `logNormalNativeF32CheckedFrom`,
  `fillLogNormalNativeF32`, `fillLogNormalNativeF32From`,
  `fillLogNormalNativeF32Checked`, `fillLogNormalNativeF32CheckedFrom`,
  `vectorLogNormalNativeF32`, `vectorLogNormalNativeF32From`,
  `vectorLogNormalNativeF32Checked`, `vectorLogNormalNativeF32CheckedFrom`,
  `fillVectorLogNormalNativeF32`, `fillVectorLogNormalNativeF32From`,
  `fillVectorLogNormalNativeF32Checked`,
  `fillVectorLogNormalNativeF32CheckedFrom`,
  `logNormalNativeExp2F32`, `logNormalNativeExp2F32From`,
  `logNormalNativeExp2F32Checked`, `logNormalNativeExp2F32CheckedFrom`,
  `fillLogNormalNativeExp2F32`, `fillLogNormalNativeExp2F32From`,
  `fillLogNormalNativeExp2F32Checked`,
  `fillLogNormalNativeExp2F32CheckedFrom`,
  `vectorLogNormalNativeExp2F32`, `vectorLogNormalNativeExp2F32From`,
  `vectorLogNormalNativeExp2F32Checked`,
  `vectorLogNormalNativeExp2F32CheckedFrom`,
  `fillVectorLogNormalNativeExp2F32`,
  `fillVectorLogNormalNativeExp2F32From`,
  `fillVectorLogNormalNativeExp2F32Checked`,
  `fillVectorLogNormalNativeExp2F32CheckedFrom`,
  `vectorLogNormal`, `vectorLogNormalFrom`, `vectorLogNormalChecked`,
  `vectorLogNormalCheckedFrom`, `fillVectorLogNormal`,
  `fillVectorLogNormalFrom`, `fillVectorLogNormalChecked`,
  `fillVectorLogNormalCheckedFrom`,
  `logNormalApproxF32`, `logNormalApproxF32From`,
  `logNormalApproxF32Checked`, `logNormalApproxF32CheckedFrom`,
  `fillLogNormalApproxF32`, `fillLogNormalApproxF32From`,
  `fillLogNormalApproxF32Checked`, `fillLogNormalApproxF32CheckedFrom`,
  `logNormalExp2F32`, `logNormalExp2F32From`,
  `logNormalExp2F32Checked`, `logNormalExp2F32CheckedFrom`,
  `fillLogNormalExp2F32`, `fillLogNormalExp2F32From`,
  `fillLogNormalExp2F32Checked`, `fillLogNormalExp2F32CheckedFrom`,
  `vectorLogNormalExp2F32`, `vectorLogNormalExp2F32From`,
  `vectorLogNormalExp2F32Checked`, `vectorLogNormalExp2F32CheckedFrom`,
  `fillVectorLogNormalExp2F32`, `fillVectorLogNormalExp2F32From`,
  `fillVectorLogNormalExp2F32Checked`, `fillVectorLogNormalExp2F32CheckedFrom`,
  `vectorLogNormalApproxF32`, `vectorLogNormalApproxF32From`,
  `vectorLogNormalApproxF32Checked`, `vectorLogNormalApproxF32CheckedFrom`,
  `fillVectorLogNormalApproxF32`, `fillVectorLogNormalApproxF32From`,
  `fillVectorLogNormalApproxF32Checked`, `fillVectorLogNormalApproxF32CheckedFrom`,
  `halfNormal`, `halfNormalFrom`, `halfNormalChecked`,
  `halfNormalCheckedFrom`, `fillHalfNormal`, `fillHalfNormalFrom`,
  `fillHalfNormalChecked`, `fillHalfNormalCheckedFrom`, `vectorHalfNormal`,
  `vectorHalfNormalFrom`, `vectorHalfNormalChecked`,
  `vectorHalfNormalCheckedFrom`, `fillVectorHalfNormal`,
  `fillVectorHalfNormalFrom`, `fillVectorHalfNormalChecked`,
  `fillVectorHalfNormalCheckedFrom`, `chi`, `chiFrom`,
  `standardExponential`, `standardExponentialFrom`,
  `fillStandardExponential`, `fillStandardExponentialFrom`,
  `standardExponentialNativeF32`, `standardExponentialNativeF32From`,
  `fillStandardExponentialNativeF32`,
  `fillStandardExponentialNativeF32From`,
  `vectorStandardExponentialNativeF32`,
  `vectorStandardExponentialNativeF32From`,
  `fillVectorStandardExponentialNativeF32`,
  `fillVectorStandardExponentialNativeF32From`,
  `vectorStandardExponentialTableF32`, `vectorStandardExponentialTableF32From`,
  `fillVectorStandardExponentialTableF32`,
  `fillVectorStandardExponentialTableF32From`,
  `vectorStandardExponentialTableF64`, `vectorStandardExponentialTableF64From`,
  `fillVectorStandardExponentialTableF64`,
  `fillVectorStandardExponentialTableF64From`,
  `vectorStandardExponentialApproxLogF32`,
  `vectorStandardExponentialApproxLogF32From`,
  `fillVectorStandardExponentialApproxLogF32`,
  `fillVectorStandardExponentialApproxLogF32From`,
  `vectorStandardExponential`,
  `vectorStandardExponentialFrom`,
  `fillVectorStandardExponential`, `fillVectorStandardExponentialFrom`,
  `exponential`, `exponentialFrom`, `exponentialChecked`,
  `exponentialCheckedFrom`, `exponentialNativeF32`, `exponentialNativeF32From`,
  `exponentialNativeF32Checked`, `exponentialNativeF32CheckedFrom`,
  `fillExponential`, `fillExponentialFrom`, `fillExponentialChecked`,
  `fillExponentialCheckedFrom`, `fillExponentialNativeF32`,
  `fillExponentialNativeF32From`, `fillExponentialNativeF32Checked`,
  `fillExponentialNativeF32CheckedFrom`,
  `vectorExponentialNativeF32`, `vectorExponentialNativeF32From`,
  `vectorExponentialNativeF32Checked`,
  `vectorExponentialNativeF32CheckedFrom`,
  `fillVectorExponentialNativeF32`, `fillVectorExponentialNativeF32From`,
  `fillVectorExponentialNativeF32Checked`,
  `fillVectorExponentialNativeF32CheckedFrom`,
  `vectorExponentialTableF32`, `vectorExponentialTableF32From`,
  `vectorExponentialTableF32Checked`, `vectorExponentialTableF32CheckedFrom`,
  `fillVectorExponentialTableF32`, `fillVectorExponentialTableF32From`,
  `fillVectorExponentialTableF32Checked`,
  `fillVectorExponentialTableF32CheckedFrom`,
  `vectorExponentialTableF64`, `vectorExponentialTableF64From`,
  `vectorExponentialTableF64Checked`, `vectorExponentialTableF64CheckedFrom`,
  `fillVectorExponentialTableF64`, `fillVectorExponentialTableF64From`,
  `fillVectorExponentialTableF64Checked`,
  `fillVectorExponentialTableF64CheckedFrom`,
  `vectorExponentialApproxLogF32`, `vectorExponentialApproxLogF32From`,
  `vectorExponentialApproxLogF32Checked`,
  `vectorExponentialApproxLogF32CheckedFrom`,
  `fillVectorExponentialApproxLogF32`,
  `fillVectorExponentialApproxLogF32From`,
  `fillVectorExponentialApproxLogF32Checked`,
  `fillVectorExponentialApproxLogF32CheckedFrom`,
  `vectorExponential`, `vectorExponentialFrom`, `vectorExponentialChecked`,
  `vectorExponentialCheckedFrom`, `fillVectorExponential`,
  `fillVectorExponentialFrom`, `fillVectorExponentialChecked`,
  `fillVectorExponentialCheckedFrom`
- `poisson`, `poissonFrom`, `poissonChecked`, `poissonCheckedFrom`,
  `fillPoisson`, `fillPoissonFrom`, `fillPoissonChecked`,
  `fillPoissonCheckedFrom`, `vectorPoisson`, `vectorPoissonFrom`,
  `vectorPoissonChecked`, `vectorPoissonCheckedFrom`, `fillVectorPoisson`,
  `fillVectorPoissonFrom`, `fillVectorPoissonChecked`,
  `fillVectorPoissonCheckedFrom`, `geometric`,
  `geometricFrom`, `geometricChecked`, `geometricCheckedFrom`,
  `fillGeometric`, `fillGeometricFrom`, `fillGeometricChecked`,
  `fillGeometricCheckedFrom`, `vectorGeometric`, `vectorGeometricFrom`,
  `vectorGeometricChecked`, `vectorGeometricCheckedFrom`,
  `fillVectorGeometric`, `fillVectorGeometricFrom`,
  `fillVectorGeometricChecked`, `fillVectorGeometricCheckedFrom`,
  `geometricFailures`, `geometricFailuresFrom`, `geometricFailuresChecked`,
  `geometricFailuresCheckedFrom`, `fillGeometricFailures`,
  `fillGeometricFailuresFrom`, `fillGeometricFailuresChecked`,
  `fillGeometricFailuresCheckedFrom`, `vectorGeometricFailures`,
  `vectorGeometricFailuresFrom`, `vectorGeometricFailuresChecked`,
  `vectorGeometricFailuresCheckedFrom`, `fillVectorGeometricFailures`,
  `fillVectorGeometricFailuresFrom`, `fillVectorGeometricFailuresChecked`,
  `fillVectorGeometricFailuresCheckedFrom`, `standardGeometric`,
  `standardGeometricFrom`, `fillStandardGeometric`,
  `fillStandardGeometricFrom`, `vectorStandardGeometric`,
  `vectorStandardGeometricFrom`, `fillVectorStandardGeometric`,
  `fillVectorStandardGeometricFrom`, `poissonAhrensDieter`,
  `poissonAhrensDieterFrom`, `poissonAhrensDieterChecked`,
  `poissonAhrensDieterCheckedFrom`,
  `vectorPoissonAhrensDieter`, `vectorPoissonAhrensDieterFrom`,
  `vectorPoissonAhrensDieterChecked`, `vectorPoissonAhrensDieterCheckedFrom`,
  `fillVectorPoissonAhrensDieter`, `fillVectorPoissonAhrensDieterFrom`,
  `fillVectorPoissonAhrensDieterChecked`, `fillVectorPoissonAhrensDieterCheckedFrom`
- `gamma`, `gammaFrom`, `gammaChecked`, `gammaCheckedFrom`, `fillGamma`,
  `fillGammaFrom`, `fillGammaChecked`, `fillGammaCheckedFrom`,
  `vectorGamma`, `vectorGammaFrom`, `vectorGammaChecked`,
  `vectorGammaCheckedFrom`, `fillVectorGamma`, `fillVectorGammaFrom`,
  `fillVectorGammaChecked`, `fillVectorGammaCheckedFrom`, `chiSquared`,
  `chiSquaredFrom`, `chiSquaredChecked`, `chiSquaredCheckedFrom`,
  `fillChiSquared`, `fillChiSquaredFrom`, `fillChiSquaredChecked`,
  `fillChiSquaredCheckedFrom`, `vectorChiSquared`, `vectorChiSquaredFrom`,
  `vectorChiSquaredChecked`, `vectorChiSquaredCheckedFrom`,
  `fillVectorChiSquared`, `fillVectorChiSquaredFrom`,
  `fillVectorChiSquaredChecked`, `fillVectorChiSquaredCheckedFrom`,
  `chi`, `chiFrom`, `chiChecked`,
  `chiCheckedFrom`, `fillChi`, `fillChiFrom`, `fillChiChecked`,
  `fillChiCheckedFrom`, `vectorChi`, `vectorChiFrom`, `vectorChiChecked`,
  `vectorChiCheckedFrom`, `fillVectorChi`, `fillVectorChiFrom`,
  `fillVectorChiChecked`, `fillVectorChiCheckedFrom`,
  `erlang`, `erlangFrom`, `erlangChecked`,
  `erlangCheckedFrom`, `fillErlang`, `fillErlangFrom`,
  `fillErlangChecked`, `fillErlangCheckedFrom`, `vectorErlang`,
  `vectorErlangFrom`, `vectorErlangChecked`, `vectorErlangCheckedFrom`,
  `fillVectorErlang`, `fillVectorErlangFrom`, `fillVectorErlangChecked`,
  `fillVectorErlangCheckedFrom`, `beta`, `betaFrom`,
  `betaChecked`, `betaCheckedFrom`, `fillBeta`, `fillBetaFrom`,
  `fillBetaChecked`, `fillBetaCheckedFrom`, `vectorBeta`,
  `vectorBetaFrom`, `vectorBetaChecked`, `vectorBetaCheckedFrom`,
  `fillVectorBeta`, `fillVectorBetaFrom`, `fillVectorBetaChecked`,
  `fillVectorBetaCheckedFrom`, `fisherF`, `fisherFFrom`,
  `fisherFChecked`, `fisherFCheckedFrom`, `fillFisherF`,
  `fillFisherFFrom`, `fillFisherFChecked`, `fillFisherFCheckedFrom`,
  `vectorFisherF`, `vectorFisherFFrom`, `vectorFisherFChecked`,
  `vectorFisherFCheckedFrom`, `fillVectorFisherF`,
  `fillVectorFisherFFrom`, `fillVectorFisherFChecked`,
  `fillVectorFisherFCheckedFrom`,
  `studentT`, `studentTFrom`, `studentTChecked`, `studentTCheckedFrom`,
  `fillStudentT`, `fillStudentTFrom`, `fillStudentTChecked`,
  `fillStudentTCheckedFrom`, `vectorStudentT`, `vectorStudentTFrom`,
  `vectorStudentTChecked`, `vectorStudentTCheckedFrom`,
  `fillVectorStudentT`, `fillVectorStudentTFrom`,
  `fillVectorStudentTChecked`, `fillVectorStudentTCheckedFrom`
- `triangular`, `triangularFrom`, `triangularChecked`,
  `triangularCheckedFrom`, `fillTriangular`, `fillTriangularFrom`,
  `fillTriangularChecked`, `fillTriangularCheckedFrom`, `vectorTriangular`,
  `vectorTriangularFrom`, `vectorTriangularChecked`,
  `vectorTriangularCheckedFrom`, `fillVectorTriangular`,
  `fillVectorTriangularFrom`, `fillVectorTriangularChecked`,
  `fillVectorTriangularCheckedFrom`, `arcsine`,
  `arcsineFrom`, `arcsineChecked`, `arcsineCheckedFrom`,
  `fillArcsine`, `fillArcsineFrom`, `fillArcsineChecked`,
  `fillArcsineCheckedFrom`, `vectorArcsine`, `vectorArcsineFrom`,
  `vectorArcsineChecked`, `vectorArcsineCheckedFrom`,
  `fillVectorArcsine`, `fillVectorArcsineFrom`,
  `fillVectorArcsineChecked`, `fillVectorArcsineCheckedFrom`,
  `cauchy`, `cauchyFrom`, `cauchyChecked`, `cauchyCheckedFrom`,
  `fillCauchy`, `fillCauchyFrom`, `fillCauchyChecked`,
  `fillCauchyCheckedFrom`, `vectorCauchy`, `vectorCauchyFrom`,
  `vectorCauchyChecked`, `vectorCauchyCheckedFrom`,
  `fillVectorCauchy`, `fillVectorCauchyFrom`,
  `fillVectorCauchyChecked`, `fillVectorCauchyCheckedFrom`,
  `laplace`, `laplaceFrom`,
  `laplaceChecked`, `laplaceCheckedFrom`, `fillLaplace`, `fillLaplaceFrom`,
  `fillLaplaceChecked`, `fillLaplaceCheckedFrom`, `vectorLaplace`,
  `vectorLaplaceFrom`, `vectorLaplaceChecked`, `vectorLaplaceCheckedFrom`,
  `fillVectorLaplace`, `fillVectorLaplaceFrom`,
  `fillVectorLaplaceChecked`, `fillVectorLaplaceCheckedFrom`,
  `logistic`, `logisticFrom`, `logisticChecked`,
  `logisticCheckedFrom`, `fillLogistic`, `fillLogisticChecked`,
  `fillLogisticFrom`, `fillLogisticCheckedFrom`, `vectorLogistic`,
  `vectorLogisticFrom`, `vectorLogisticChecked`, `vectorLogisticCheckedFrom`,
  `fillVectorLogistic`, `fillVectorLogisticFrom`,
  `fillVectorLogisticChecked`, `fillVectorLogisticCheckedFrom`,
  `logLogistic`, `logLogisticFrom`,
  `logLogisticChecked`, `logLogisticCheckedFrom`,
  `fillLogLogistic`, `fillLogLogisticFrom`, `fillLogLogisticChecked`,
  `fillLogLogisticCheckedFrom`, `vectorLogLogistic`,
  `vectorLogLogisticFrom`, `vectorLogLogisticChecked`,
  `vectorLogLogisticCheckedFrom`, `fillVectorLogLogistic`,
  `fillVectorLogLogisticFrom`, `fillVectorLogLogisticChecked`,
  `fillVectorLogLogisticCheckedFrom`, `kumaraswamy`,
  `kumaraswamyFrom`, `kumaraswamyChecked`, `kumaraswamyCheckedFrom`,
  `fillKumaraswamy`, `fillKumaraswamyFrom`, `fillKumaraswamyChecked`,
  `fillKumaraswamyCheckedFrom`, `vectorKumaraswamy`,
  `vectorKumaraswamyFrom`, `vectorKumaraswamyChecked`,
  `vectorKumaraswamyCheckedFrom`, `fillVectorKumaraswamy`,
  `fillVectorKumaraswamyFrom`, `fillVectorKumaraswamyChecked`,
  `fillVectorKumaraswamyCheckedFrom`,
  `powerFunction`, `powerFunctionFrom`, `powerFunctionChecked`,
  `powerFunctionCheckedFrom`, `fillPowerFunction`,
  `fillPowerFunctionFrom`, `fillPowerFunctionChecked`,
  `fillPowerFunctionCheckedFrom`, `vectorPowerFunction`,
  `vectorPowerFunctionFrom`, `vectorPowerFunctionChecked`,
  `vectorPowerFunctionCheckedFrom`, `fillVectorPowerFunction`,
  `fillVectorPowerFunctionFrom`, `fillVectorPowerFunctionChecked`,
  `fillVectorPowerFunctionCheckedFrom`, `rayleigh`, `rayleighFrom`, `rayleighChecked`,
  `rayleighCheckedFrom`, `fillRayleigh`,
  `fillRayleighFrom`, `fillRayleighChecked`, `fillRayleighCheckedFrom`,
  `vectorRayleigh`, `vectorRayleighFrom`, `vectorRayleighChecked`,
  `vectorRayleighCheckedFrom`, `fillVectorRayleigh`,
  `fillVectorRayleighFrom`, `fillVectorRayleighChecked`,
  `fillVectorRayleighCheckedFrom`,
  `maxwell`, `maxwellFrom`, `maxwellChecked`,
  `maxwellCheckedFrom`, `fillMaxwell`,
  `fillMaxwellFrom`, `fillMaxwellChecked`, `fillMaxwellCheckedFrom`,
  `vectorMaxwell`, `vectorMaxwellFrom`, `vectorMaxwellChecked`,
  `vectorMaxwellCheckedFrom`, `fillVectorMaxwell`,
  `fillVectorMaxwellFrom`, `fillVectorMaxwellChecked`,
  `fillVectorMaxwellCheckedFrom`,
  `pareto`, `paretoFrom`, `paretoChecked`, `paretoCheckedFrom`,
  `fillPareto`, `fillParetoFrom`, `fillParetoChecked`,
  `fillParetoCheckedFrom`, `vectorPareto`, `vectorParetoFrom`,
  `vectorParetoChecked`, `vectorParetoCheckedFrom`,
  `fillVectorPareto`, `fillVectorParetoFrom`,
  `fillVectorParetoChecked`, `fillVectorParetoCheckedFrom`,
  `weibull`, `weibullFrom`,
  `weibullChecked`, `weibullCheckedFrom`, `fillWeibull`, `fillWeibullFrom`,
  `fillWeibullChecked`, `fillWeibullCheckedFrom`,
  `vectorWeibull`, `vectorWeibullFrom`, `vectorWeibullChecked`,
  `vectorWeibullCheckedFrom`, `fillVectorWeibull`,
  `fillVectorWeibullFrom`, `fillVectorWeibullChecked`,
  `fillVectorWeibullCheckedFrom`
- `gumbel`, `gumbelFrom`, `fillGumbel`, `fillGumbelFrom`,
  `fillGumbelChecked`, `fillGumbelCheckedFrom`,
  `gumbelChecked`, `gumbelCheckedFrom`, `vectorGumbel`,
  `vectorGumbelFrom`, `vectorGumbelChecked`, `vectorGumbelCheckedFrom`,
  `fillVectorGumbel`, `fillVectorGumbelFrom`,
  `fillVectorGumbelChecked`, `fillVectorGumbelCheckedFrom`,
  `frechet`, `frechetFrom`, `frechetChecked`, `frechetCheckedFrom`,
  `fillFrechet`, `fillFrechetFrom`, `fillFrechetChecked`,
  `fillFrechetCheckedFrom`, `vectorFrechet`, `vectorFrechetFrom`,
  `vectorFrechetChecked`, `vectorFrechetCheckedFrom`,
  `fillVectorFrechet`, `fillVectorFrechetFrom`,
  `fillVectorFrechetChecked`, `fillVectorFrechetCheckedFrom`,
  `skewNormal`, `skewNormalFrom`, `skewNormalChecked`,
  `skewNormalCheckedFrom`, `fillSkewNormal`, `fillSkewNormalFrom`,
  `fillSkewNormalChecked`, `fillSkewNormalCheckedFrom`,
  `vectorSkewNormal`, `vectorSkewNormalFrom`, `vectorSkewNormalChecked`,
  `vectorSkewNormalCheckedFrom`, `fillVectorSkewNormal`,
  `fillVectorSkewNormalFrom`, `fillVectorSkewNormalChecked`,
  `fillVectorSkewNormalCheckedFrom`,
  `pert`, `pertFrom`, `pertChecked`, `pertCheckedFrom`, `fillPert`,
  `fillPertFrom`, `fillPertChecked`, `fillPertCheckedFrom`,
  `vectorPert`, `vectorPertFrom`, `vectorPertChecked`,
  `vectorPertCheckedFrom`, `fillVectorPert`, `fillVectorPertFrom`,
  `fillVectorPertChecked`, `fillVectorPertCheckedFrom`
- `inverseGaussian`, `inverseGaussianFrom`, `inverseGaussianChecked`,
  `inverseGaussianCheckedFrom`, `fillInverseGaussian`, `fillInverseGaussianFrom`,
  `fillInverseGaussianChecked`, `fillInverseGaussianCheckedFrom`,
  `vectorInverseGaussian`, `vectorInverseGaussianFrom`,
  `vectorInverseGaussianChecked`, `vectorInverseGaussianCheckedFrom`,
  `fillVectorInverseGaussian`, `fillVectorInverseGaussianFrom`,
  `fillVectorInverseGaussianChecked`, `fillVectorInverseGaussianCheckedFrom`,
  `normalInverseGaussian`, `normalInverseGaussianFrom`,
  `normalInverseGaussianChecked`, `normalInverseGaussianCheckedFrom`,
  `fillNormalInverseGaussian`, `fillNormalInverseGaussianFrom`,
  `fillNormalInverseGaussianChecked`, `fillNormalInverseGaussianCheckedFrom`,
  `vectorNormalInverseGaussian`, `vectorNormalInverseGaussianFrom`,
  `vectorNormalInverseGaussianChecked`, `vectorNormalInverseGaussianCheckedFrom`,
  `fillVectorNormalInverseGaussian`, `fillVectorNormalInverseGaussianFrom`,
  `fillVectorNormalInverseGaussianChecked`, `fillVectorNormalInverseGaussianCheckedFrom`,
  `zipf`, `zipfFrom`, `zipfChecked`, `zipfCheckedFrom`, `fillZipf`,
  `fillZipfFrom`, `fillZipfChecked`, `fillZipfCheckedFrom`,
  `vectorZipf`, `vectorZipfFrom`, `vectorZipfChecked`,
  `vectorZipfCheckedFrom`, `fillVectorZipf`, `fillVectorZipfFrom`,
  `fillVectorZipfChecked`, `fillVectorZipfCheckedFrom`, `zeta`,
  `zetaFrom`, `zetaChecked`, `zetaCheckedFrom`, `fillZeta`, `fillZetaFrom`,
  `fillZetaChecked`, `fillZetaCheckedFrom`, `vectorZeta`,
  `vectorZetaFrom`, `vectorZetaChecked`, `vectorZetaCheckedFrom`,
  `fillVectorZeta`, `fillVectorZetaFrom`, `fillVectorZetaChecked`,
  `fillVectorZetaCheckedFrom`
- `unitCircle`, `unitCircleFrom`, `fillUnitCircle`, `fillUnitCircleFrom`,
  `vectorUnitCircle`, `vectorUnitCircleFrom`, `fillVectorUnitCircle`,
  `fillVectorUnitCircleFrom`,
  `unitDisc`, `unitDiscFrom`, `fillUnitDisc`, `fillUnitDiscFrom`,
  `vectorUnitDisc`, `vectorUnitDiscFrom`, `fillVectorUnitDisc`,
  `fillVectorUnitDiscFrom`,
  `unitSphere`, `unitSphereFrom`, `fillUnitSphere`, `fillUnitSphereFrom`,
  `vectorUnitSphere`, `vectorUnitSphereFrom`, `fillVectorUnitSphere`,
  `fillVectorUnitSphereFrom`,
  `unitBall`, `unitBallFrom`, `fillUnitBall`, `fillUnitBallFrom`,
  `vectorUnitBall`, `vectorUnitBallFrom`, `fillVectorUnitBall`,
  `fillVectorUnitBallFrom`

Reusable samplers:

- `Bernoulli`
- `Bernoulli.init`
- `Bernoulli.new`
- `Bernoulli.initRatio`
- `Bernoulli.newRatio`
- `Bernoulli.fromRatio`
- `Bernoulli.probability`
- `Bernoulli.p`
- `Bernoulli.probabilityValue`
- `Bernoulli.expectedValue`
- `Bernoulli.varianceValue`
- `Bernoulli.modeValue`
- `Bernoulli.minValue`
- `Bernoulli.maxValue`
- `Bernoulli.sample`
- `Bernoulli.sampleFrom`
- `Bernoulli.fill`
- `Bernoulli.fillFrom`
- `VectorBernoulli(VectorType)`
- `VectorBernoulli(VectorType).init`
- `VectorBernoulli(VectorType).new`
- `VectorBernoulli(VectorType).initRatio`
- `VectorBernoulli(VectorType).newRatio`
- `VectorBernoulli(VectorType).fromRatio`
- `VectorBernoulli(VectorType).probability`
- `VectorBernoulli(VectorType).p`
- `VectorBernoulli(VectorType).probabilityValue`
- `VectorBernoulli(VectorType).expectedValue`
- `VectorBernoulli(VectorType).varianceValue`
- `VectorBernoulli(VectorType).modeValue`
- `VectorBernoulli(VectorType).minValue`
- `VectorBernoulli(VectorType).maxValue`
- `VectorBernoulli(VectorType).sample`
- `VectorBernoulli(VectorType).sampleFrom`
- `VectorBernoulli(VectorType).fill`
- `VectorBernoulli(VectorType).fillFrom`
- `Binomial`
- `Binomial.init`
- `Binomial.new`
- `Binomial.trialsValue`
- `Binomial.probabilityValue`
- `Binomial.expectedValue`
- `Binomial.varianceValue`
- `Binomial.minValue`
- `Binomial.maxValue`
- `Binomial.sample`
- `Binomial.sampleFrom`
- `Binomial.fill`
- `Binomial.fillFrom`
- `VectorBinomial(VectorType)`
- `VectorBinomial(VectorType).init`
- `VectorBinomial(VectorType).trialsValue`
- `VectorBinomial(VectorType).probabilityValue`
- `VectorBinomial(VectorType).expectedValue`
- `VectorBinomial(VectorType).varianceValue`
- `VectorBinomial(VectorType).minValue`
- `VectorBinomial(VectorType).maxValue`
- `VectorBinomial(VectorType).sample`
- `VectorBinomial(VectorType).sampleFrom`
- `VectorBinomial(VectorType).fill`
- `VectorBinomial(VectorType).fillFrom`
- `Multinomial`
- `Multinomial.init`
- `Multinomial.trialsValue`
- `Multinomial.probabilitiesValue`
- `Multinomial.probabilityAt`
- `Multinomial.normalizedProbabilityAt`
- `Multinomial.normalizedProbabilities`
- `Multinomial.normalizedProbabilitiesInto`
- `Multinomial.expectedCountAt`
- `Multinomial.expectedCounts`
- `Multinomial.expectedCountsInto`
- `Multinomial.varianceAt`
- `Multinomial.variances`
- `Multinomial.variancesInto`
- `Multinomial.covarianceAt`
- `Multinomial.covariances`
- `Multinomial.covariancesInto`
- `Multinomial.categoryCountValue`
- `Multinomial.totalProbabilityValue`
- `Multinomial.sample`
- `Multinomial.sampleFrom`
- `Multinomial.sampleInto`
- `Multinomial.sampleIntoFrom`
- `Multinomial.sampleIntoChecked`
- `Multinomial.sampleIntoCheckedFrom`
- `Multinomial.sampleManyInto`
- `Multinomial.sampleManyIntoFrom`
- `Multinomial.sampleManyIntoChecked`
- `Multinomial.sampleManyIntoCheckedFrom`
- `NegativeBinomial`
- `NegativeBinomial.init`
- `NegativeBinomial.successesValue`
- `NegativeBinomial.probabilityValue`
- `NegativeBinomial.expectedValue`
- `NegativeBinomial.varianceValue`
- `NegativeBinomial.minValue`
- `NegativeBinomial.maxValue`
- `NegativeBinomial.sample`
- `NegativeBinomial.sampleFrom`
- `NegativeBinomial.fill`
- `NegativeBinomial.fillFrom`
- `VectorBinomialPoissonApprox(VectorType)`
- `VectorBinomialPoissonApprox(VectorType).init`
- `VectorBinomialPoissonApprox(VectorType).trialsValue`
- `VectorBinomialPoissonApprox(VectorType).probabilityValue`
- `VectorBinomialPoissonApprox(VectorType).expectedValue`
- `VectorBinomialPoissonApprox(VectorType).varianceValue`
- `VectorBinomialPoissonApprox(VectorType).minValue`
- `VectorBinomialPoissonApprox(VectorType).maxValue`
- `VectorBinomialPoissonApprox(VectorType).sample`
- `VectorBinomialPoissonApprox(VectorType).sampleFrom`
- `VectorBinomialPoissonApprox(VectorType).fill`
- `VectorBinomialPoissonApprox(VectorType).fillFrom`
- `VectorNegativeBinomial(VectorType)`
- `VectorNegativeBinomial(VectorType).init`
- `VectorNegativeBinomial(VectorType).successesValue`
- `VectorNegativeBinomial(VectorType).probabilityValue`
- `VectorNegativeBinomial(VectorType).expectedValue`
- `VectorNegativeBinomial(VectorType).varianceValue`
- `VectorNegativeBinomial(VectorType).minValue`
- `VectorNegativeBinomial(VectorType).maxValue`
- `VectorNegativeBinomial(VectorType).sample`
- `VectorNegativeBinomial(VectorType).sampleFrom`
- `VectorNegativeBinomial(VectorType).fill`
- `VectorNegativeBinomial(VectorType).fillFrom`
- `Hypergeometric`
- `Hypergeometric.init`
- `Hypergeometric.new`
- `Hypergeometric.populationValue`
- `Hypergeometric.successesValue`
- `Hypergeometric.drawsValue`
- `Hypergeometric.expectedValue`
- `Hypergeometric.varianceValue`
- `Hypergeometric.minValue`
- `Hypergeometric.maxValue`
- `Hypergeometric.sample`
- `Hypergeometric.sampleFrom`
- `Hypergeometric.fill`
- `Hypergeometric.fillFrom`
- `VectorHypergeometric(VectorType)`
- `VectorHypergeometric(VectorType).init`
- `VectorHypergeometric(VectorType).populationValue`
- `VectorHypergeometric(VectorType).successesValue`
- `VectorHypergeometric(VectorType).drawsValue`
- `VectorHypergeometric(VectorType).expectedValue`
- `VectorHypergeometric(VectorType).varianceValue`
- `VectorHypergeometric(VectorType).minValue`
- `VectorHypergeometric(VectorType).maxValue`
- `VectorHypergeometric(VectorType).sample`
- `VectorHypergeometric(VectorType).sampleFrom`
- `VectorHypergeometric(VectorType).fill`
- `VectorHypergeometric(VectorType).fillFrom`
- `Uniform(T)`
- `UniformInt(T)`
- `UniformFloat(T)`
- `UniformUsize`
- `Uniform(T).init`
- `Uniform(T).new`
- `Uniform(T).tryFromRange`
- `Uniform(T).initInclusive`
- `Uniform(T).newInclusive`
- `Uniform(T).tryFromRangeInclusive`
- `Uniform(T).lowValue`
- `Uniform(T).highValue`
- `Uniform(T).isInclusive`
- `Uniform(T).expectedValue`
- `Uniform(T).varianceValue`
- `Uniform(T).sample`
- `Uniform(T).sampleFrom`
- `Uniform(T).fill`
- `Uniform(T).fillFrom`
- `UniformDuration`
- `UniformDuration.init`
- `UniformDuration.new`
- `UniformDuration.initInclusive`
- `UniformDuration.newInclusive`
- `UniformDuration.lowValue`
- `UniformDuration.highValue`
- `UniformDuration.isInclusive`
- `UniformDuration.sample`
- `UniformDuration.sampleFrom`
- `UniformDuration.fill`
- `UniformDuration.fillFrom`
- `VectorPoissonAhrensDieter(VectorType)`
- `VectorPoissonAhrensDieter(VectorType).init`
- `VectorPoissonAhrensDieter(VectorType).lambdaValue`
- `VectorPoissonAhrensDieter(VectorType).expectedValue`
- `VectorPoissonAhrensDieter(VectorType).varianceValue`
- `VectorPoissonAhrensDieter(VectorType).minValue`
- `VectorPoissonAhrensDieter(VectorType).maxValue`
- `VectorPoissonAhrensDieter(VectorType).sample`
- `VectorPoissonAhrensDieter(VectorType).sampleFrom`
- `VectorPoissonAhrensDieter(VectorType).fill`
- `VectorPoissonAhrensDieter(VectorType).fillFrom`
- `VectorUniform(VectorType)`
- `VectorUniform(VectorType).init`
- `VectorUniform(VectorType).new`
- `VectorUniform(VectorType).tryFromRange`
- `VectorUniform(VectorType).initInclusive`
- `VectorUniform(VectorType).newInclusive`
- `VectorUniform(VectorType).tryFromRangeInclusive`
- `VectorUniform(VectorType).lowValue`
- `VectorUniform(VectorType).highValue`
- `VectorUniform(VectorType).isInclusive`
- `VectorUniform(VectorType).expectedValue`
- `VectorUniform(VectorType).varianceValue`
- `VectorUniform(VectorType).sample`
- `VectorUniform(VectorType).sampleFrom`
- `VectorUniform(VectorType).fill`
- `VectorUniform(VectorType).fillFrom`
- `Open01`
- `Open01.lowValue`
- `Open01.highValue`
- `Open01.includesLow`
- `Open01.includesHigh`
- `Open01.expectedValue`
- `Open01.varianceValue`
- `Open01.sample`
- `Open01.sampleFrom`
- `Open01.fill`
- `Open01.fillFrom`
- `OpenClosed01`
- `OpenClosed01.lowValue`
- `OpenClosed01.highValue`
- `OpenClosed01.includesLow`
- `OpenClosed01.includesHigh`
- `OpenClosed01.expectedValue`
- `OpenClosed01.varianceValue`
- `OpenClosed01.sample`
- `OpenClosed01.sampleFrom`
- `OpenClosed01.fill`
- `OpenClosed01.fillFrom`
  (`Open01` and `OpenClosed01` sample/fill scalar `f32`/`f64` and float vector
  types such as `@Vector(8, f32)`.)
- `StandardNormal(T)`
- `StandardNormal(T).meanValue`
- `StandardNormal(T).stddevValue`
- `StandardNormal(T).expectedValue`
- `StandardNormal(T).varianceValue`
- `StandardNormal(T).medianValue`
- `StandardNormal(T).modeValue`
- `StandardNormal(T).minValue`
- `StandardNormal(T).maxValue`
- `StandardNormal(T).sample`
- `StandardNormal(T).sampleFrom`
- `StandardNormal(T).fill`
- `StandardNormal(T).fillFrom`
- `StandardNormalNativeF32`
- `StandardNormalNativeF32.meanValue`
- `StandardNormalNativeF32.stddevValue`
- `StandardNormalNativeF32.expectedValue`
- `StandardNormalNativeF32.varianceValue`
- `StandardNormalNativeF32.medianValue`
- `StandardNormalNativeF32.modeValue`
- `StandardNormalNativeF32.minValue`
- `StandardNormalNativeF32.maxValue`
- `StandardNormalNativeF32.sample`
- `StandardNormalNativeF32.sampleFrom`
- `StandardNormalNativeF32.fill`
- `StandardNormalNativeF32.fillFrom`
- `VectorStandardNormalNativeF32(VectorType)`
- `VectorStandardNormalNativeF32(VectorType).meanValue`
- `VectorStandardNormalNativeF32(VectorType).stddevValue`
- `VectorStandardNormalNativeF32(VectorType).expectedValue`
- `VectorStandardNormalNativeF32(VectorType).varianceValue`
- `VectorStandardNormalNativeF32(VectorType).medianValue`
- `VectorStandardNormalNativeF32(VectorType).modeValue`
- `VectorStandardNormalNativeF32(VectorType).minValue`
- `VectorStandardNormalNativeF32(VectorType).maxValue`
- `VectorStandardNormalNativeF32(VectorType).sample`
- `VectorStandardNormalNativeF32(VectorType).sampleFrom`
- `VectorStandardNormalNativeF32(VectorType).fill`
- `VectorStandardNormalNativeF32(VectorType).fillFrom`
- `VectorStandardNormalTableF32(VectorType)`
- `VectorStandardNormalTableF32(VectorType).meanValue`
- `VectorStandardNormalTableF32(VectorType).stddevValue`
- `VectorStandardNormalTableF32(VectorType).expectedValue`
- `VectorStandardNormalTableF32(VectorType).varianceValue`
- `VectorStandardNormalTableF32(VectorType).medianValue`
- `VectorStandardNormalTableF32(VectorType).modeValue`
- `VectorStandardNormalTableF32(VectorType).minValue`
- `VectorStandardNormalTableF32(VectorType).maxValue`
- `VectorStandardNormalTableF32(VectorType).sample`
- `VectorStandardNormalTableF32(VectorType).sampleFrom`
- `VectorStandardNormalTableF32(VectorType).fill`
- `VectorStandardNormalTableF32(VectorType).fillFrom`
- `VectorStandardNormalTableF64(VectorType)`
- `VectorStandardNormalTableF64(VectorType).meanValue`
- `VectorStandardNormalTableF64(VectorType).stddevValue`
- `VectorStandardNormalTableF64(VectorType).expectedValue`
- `VectorStandardNormalTableF64(VectorType).varianceValue`
- `VectorStandardNormalTableF64(VectorType).medianValue`
- `VectorStandardNormalTableF64(VectorType).modeValue`
- `VectorStandardNormalTableF64(VectorType).minValue`
- `VectorStandardNormalTableF64(VectorType).maxValue`
- `VectorStandardNormalTableF64(VectorType).sample`
- `VectorStandardNormalTableF64(VectorType).sampleFrom`
- `VectorStandardNormalTableF64(VectorType).fill`
- `VectorStandardNormalTableF64(VectorType).fillFrom`
- `Normal(T)`
- `Normal(T).init`
- `Normal(T).new`
- `Normal(T).initMeanCv`
- `Normal(T).fromMeanCv`
- `Normal(T).fromZScore`
- `Normal(T).meanValue`
- `Normal(T).meanParameter`
- `Normal(T).stddevValue`
- `Normal(T).stddevParameter`
- `Normal(T).stdDevParameter`
- `Normal(T).expectedValue`
- `Normal(T).varianceValue`
- `Normal(T).medianValue`
- `Normal(T).modeValue`
- `Normal(T).minValue`
- `Normal(T).maxValue`
- `Normal(T).coefficientOfVariationValue`
- `Normal(T).sample`
- `Normal(T).sampleFrom`
- `Normal(T).fill`
- `Normal(T).fillFrom`
- `NormalNativeF32`
- `NormalNativeF32.init`
- `NormalNativeF32.initMeanCv`
- `NormalNativeF32.fromZScore`
- `NormalNativeF32.meanValue`
- `NormalNativeF32.stddevValue`
- `NormalNativeF32.expectedValue`
- `NormalNativeF32.varianceValue`
- `NormalNativeF32.medianValue`
- `NormalNativeF32.modeValue`
- `NormalNativeF32.minValue`
- `NormalNativeF32.maxValue`
- `NormalNativeF32.coefficientOfVariationValue`
- `NormalNativeF32.sample`
- `NormalNativeF32.sampleFrom`
- `NormalNativeF32.fill`
- `NormalNativeF32.fillFrom`
- `VectorNormalNativeF32(VectorType)`
- `VectorNormalNativeF32(VectorType).init`
- `VectorNormalNativeF32(VectorType).initMeanCv`
- `VectorNormalNativeF32(VectorType).fromZScore`
- `VectorNormalNativeF32(VectorType).meanValue`
- `VectorNormalNativeF32(VectorType).stddevValue`
- `VectorNormalNativeF32(VectorType).expectedValue`
- `VectorNormalNativeF32(VectorType).varianceValue`
- `VectorNormalNativeF32(VectorType).medianValue`
- `VectorNormalNativeF32(VectorType).modeValue`
- `VectorNormalNativeF32(VectorType).minValue`
- `VectorNormalNativeF32(VectorType).maxValue`
- `VectorNormalNativeF32(VectorType).coefficientOfVariationValue`
- `VectorNormalNativeF32(VectorType).sample`
- `VectorNormalNativeF32(VectorType).sampleFrom`
- `VectorNormalNativeF32(VectorType).fill`
- `VectorNormalNativeF32(VectorType).fillFrom`
- `VectorNormalTableF32(VectorType)`
- `VectorNormalTableF32(VectorType).init`
- `VectorNormalTableF32(VectorType).initMeanCv`
- `VectorNormalTableF32(VectorType).fromZScore`
- `VectorNormalTableF32(VectorType).meanValue`
- `VectorNormalTableF32(VectorType).stddevValue`
- `VectorNormalTableF32(VectorType).expectedValue`
- `VectorNormalTableF32(VectorType).varianceValue`
- `VectorNormalTableF32(VectorType).medianValue`
- `VectorNormalTableF32(VectorType).modeValue`
- `VectorNormalTableF32(VectorType).minValue`
- `VectorNormalTableF32(VectorType).maxValue`
- `VectorNormalTableF32(VectorType).coefficientOfVariationValue`
- `VectorNormalTableF32(VectorType).sample`
- `VectorNormalTableF32(VectorType).sampleFrom`
- `VectorNormalTableF32(VectorType).fill`
- `VectorNormalTableF32(VectorType).fillFrom`
- `VectorNormalTableF64(VectorType)`
- `VectorNormalTableF64(VectorType).init`
- `VectorNormalTableF64(VectorType).initMeanCv`
- `VectorNormalTableF64(VectorType).fromZScore`
- `VectorNormalTableF64(VectorType).meanValue`
- `VectorNormalTableF64(VectorType).stddevValue`
- `VectorNormalTableF64(VectorType).expectedValue`
- `VectorNormalTableF64(VectorType).varianceValue`
- `VectorNormalTableF64(VectorType).medianValue`
- `VectorNormalTableF64(VectorType).modeValue`
- `VectorNormalTableF64(VectorType).minValue`
- `VectorNormalTableF64(VectorType).maxValue`
- `VectorNormalTableF64(VectorType).coefficientOfVariationValue`
- `VectorNormalTableF64(VectorType).sample`
- `VectorNormalTableF64(VectorType).sampleFrom`
- `VectorNormalTableF64(VectorType).fill`
- `VectorNormalTableF64(VectorType).fillFrom`
- `VectorStandardNormal(VectorType)`
- `VectorStandardNormal(VectorType).meanValue`
- `VectorStandardNormal(VectorType).stddevValue`
- `VectorStandardNormal(VectorType).expectedValue`
- `VectorStandardNormal(VectorType).varianceValue`
- `VectorStandardNormal(VectorType).medianValue`
- `VectorStandardNormal(VectorType).modeValue`
- `VectorStandardNormal(VectorType).minValue`
- `VectorStandardNormal(VectorType).maxValue`
- `VectorStandardNormal(VectorType).sample`
- `VectorStandardNormal(VectorType).sampleFrom`
- `VectorStandardNormal(VectorType).fill`
- `VectorStandardNormal(VectorType).fillFrom`
- `VectorNormal(VectorType)`
- `VectorNormal(VectorType).init`
- `VectorNormal(VectorType).initMeanCv`
- `VectorNormal(VectorType).fromZScore`
- `VectorNormal(VectorType).meanValue`
- `VectorNormal(VectorType).stddevValue`
- `VectorNormal(VectorType).expectedValue`
- `VectorNormal(VectorType).varianceValue`
- `VectorNormal(VectorType).medianValue`
- `VectorNormal(VectorType).modeValue`
- `VectorNormal(VectorType).minValue`
- `VectorNormal(VectorType).maxValue`
- `VectorNormal(VectorType).coefficientOfVariationValue`
- `VectorNormal(VectorType).sample`
- `VectorNormal(VectorType).sampleFrom`
- `VectorNormal(VectorType).fill`
- `VectorNormal(VectorType).fillFrom`
- `StandardExponential(T)`
- `Exp1(T)`
- `StandardExponential(T).rateValue`
- `StandardExponential(T).inverseRateValue`
- `StandardExponential(T).expectedValue`
- `StandardExponential(T).varianceValue`
- `StandardExponential(T).medianValue`
- `StandardExponential(T).modeValue`
- `StandardExponential(T).minValue`
- `StandardExponential(T).maxValue`
- `StandardExponential(T).sample`
- `StandardExponential(T).sampleFrom`
- `StandardExponential(T).fill`
- `StandardExponential(T).fillFrom`
- `StandardExponentialNativeF32`
- `StandardExponentialNativeF32.rateValue`
- `StandardExponentialNativeF32.inverseRateValue`
- `StandardExponentialNativeF32.expectedValue`
- `StandardExponentialNativeF32.varianceValue`
- `StandardExponentialNativeF32.medianValue`
- `StandardExponentialNativeF32.modeValue`
- `StandardExponentialNativeF32.minValue`
- `StandardExponentialNativeF32.maxValue`
- `StandardExponentialNativeF32.sample`
- `StandardExponentialNativeF32.sampleFrom`
- `StandardExponentialNativeF32.fill`
- `StandardExponentialNativeF32.fillFrom`
- `VectorStandardExponentialNativeF32(VectorType)`
- `VectorStandardExponentialNativeF32(VectorType).rateValue`
- `VectorStandardExponentialNativeF32(VectorType).inverseRateValue`
- `VectorStandardExponentialNativeF32(VectorType).expectedValue`
- `VectorStandardExponentialNativeF32(VectorType).varianceValue`
- `VectorStandardExponentialNativeF32(VectorType).medianValue`
- `VectorStandardExponentialNativeF32(VectorType).modeValue`
- `VectorStandardExponentialNativeF32(VectorType).minValue`
- `VectorStandardExponentialNativeF32(VectorType).maxValue`
- `VectorStandardExponentialNativeF32(VectorType).sample`
- `VectorStandardExponentialNativeF32(VectorType).sampleFrom`
- `VectorStandardExponentialNativeF32(VectorType).fill`
- `VectorStandardExponentialNativeF32(VectorType).fillFrom`
- `VectorStandardExponentialTableF32(VectorType)`
- `VectorStandardExponentialTableF32(VectorType).rateValue`
- `VectorStandardExponentialTableF32(VectorType).inverseRateValue`
- `VectorStandardExponentialTableF32(VectorType).expectedValue`
- `VectorStandardExponentialTableF32(VectorType).varianceValue`
- `VectorStandardExponentialTableF32(VectorType).medianValue`
- `VectorStandardExponentialTableF32(VectorType).modeValue`
- `VectorStandardExponentialTableF32(VectorType).minValue`
- `VectorStandardExponentialTableF32(VectorType).maxValue`
- `VectorStandardExponentialTableF32(VectorType).sample`
- `VectorStandardExponentialTableF32(VectorType).sampleFrom`
- `VectorStandardExponentialTableF32(VectorType).fill`
- `VectorStandardExponentialTableF32(VectorType).fillFrom`
- `VectorStandardExponentialTableF64(VectorType)`
- `VectorStandardExponentialTableF64(VectorType).rateValue`
- `VectorStandardExponentialTableF64(VectorType).inverseRateValue`
- `VectorStandardExponentialTableF64(VectorType).expectedValue`
- `VectorStandardExponentialTableF64(VectorType).varianceValue`
- `VectorStandardExponentialTableF64(VectorType).medianValue`
- `VectorStandardExponentialTableF64(VectorType).modeValue`
- `VectorStandardExponentialTableF64(VectorType).minValue`
- `VectorStandardExponentialTableF64(VectorType).maxValue`
- `VectorStandardExponentialTableF64(VectorType).sample`
- `VectorStandardExponentialTableF64(VectorType).sampleFrom`
- `VectorStandardExponentialTableF64(VectorType).fill`
- `VectorStandardExponentialTableF64(VectorType).fillFrom`
- `VectorStandardExponentialApproxLogF32(VectorType)`
- `VectorStandardExponentialApproxLogF32(VectorType).rateValue`
- `VectorStandardExponentialApproxLogF32(VectorType).inverseRateValue`
- `VectorStandardExponentialApproxLogF32(VectorType).expectedValue`
- `VectorStandardExponentialApproxLogF32(VectorType).varianceValue`
- `VectorStandardExponentialApproxLogF32(VectorType).medianValue`
- `VectorStandardExponentialApproxLogF32(VectorType).modeValue`
- `VectorStandardExponentialApproxLogF32(VectorType).minValue`
- `VectorStandardExponentialApproxLogF32(VectorType).maxValue`
- `VectorStandardExponentialApproxLogF32(VectorType).sample`
- `VectorStandardExponentialApproxLogF32(VectorType).sampleFrom`
- `VectorStandardExponentialApproxLogF32(VectorType).fill`
- `VectorStandardExponentialApproxLogF32(VectorType).fillFrom`
- `Exponential(T)`
- `Exp(T)`
- `Exponential(T).init`
- `Exponential(T).new`
- `Exponential(T).rateValue`
- `Exponential(T).inverseRateValue`
- `Exponential(T).expectedValue`
- `Exponential(T).varianceValue`
- `Exponential(T).medianValue`
- `Exponential(T).modeValue`
- `Exponential(T).minValue`
- `Exponential(T).maxValue`
- `Exponential(T).sample`
- `Exponential(T).sampleFrom`
- `Exponential(T).fill`
- `Exponential(T).fillFrom`
- `ExponentialNativeF32`
- `ExponentialNativeF32.init`
- `ExponentialNativeF32.rateValue`
- `ExponentialNativeF32.inverseRateValue`
- `ExponentialNativeF32.expectedValue`
- `ExponentialNativeF32.varianceValue`
- `ExponentialNativeF32.medianValue`
- `ExponentialNativeF32.modeValue`
- `ExponentialNativeF32.minValue`
- `ExponentialNativeF32.maxValue`
- `ExponentialNativeF32.sample`
- `ExponentialNativeF32.sampleFrom`
- `ExponentialNativeF32.fill`
- `ExponentialNativeF32.fillFrom`
- `VectorExponentialNativeF32(VectorType)`
- `VectorExponentialNativeF32(VectorType).init`
- `VectorExponentialNativeF32(VectorType).rateValue`
- `VectorExponentialNativeF32(VectorType).inverseRateValue`
- `VectorExponentialNativeF32(VectorType).expectedValue`
- `VectorExponentialNativeF32(VectorType).varianceValue`
- `VectorExponentialNativeF32(VectorType).medianValue`
- `VectorExponentialNativeF32(VectorType).modeValue`
- `VectorExponentialNativeF32(VectorType).minValue`
- `VectorExponentialNativeF32(VectorType).maxValue`
- `VectorExponentialNativeF32(VectorType).sample`
- `VectorExponentialNativeF32(VectorType).sampleFrom`
- `VectorExponentialNativeF32(VectorType).fill`
- `VectorExponentialNativeF32(VectorType).fillFrom`
- `VectorExponentialTableF32(VectorType)`
- `VectorExponentialTableF32(VectorType).init`
- `VectorExponentialTableF32(VectorType).rateValue`
- `VectorExponentialTableF32(VectorType).inverseRateValue`
- `VectorExponentialTableF32(VectorType).expectedValue`
- `VectorExponentialTableF32(VectorType).varianceValue`
- `VectorExponentialTableF32(VectorType).medianValue`
- `VectorExponentialTableF32(VectorType).modeValue`
- `VectorExponentialTableF32(VectorType).minValue`
- `VectorExponentialTableF32(VectorType).maxValue`
- `VectorExponentialTableF32(VectorType).sample`
- `VectorExponentialTableF32(VectorType).sampleFrom`
- `VectorExponentialTableF32(VectorType).fill`
- `VectorExponentialTableF32(VectorType).fillFrom`
- `VectorExponentialTableF64(VectorType)`
- `VectorExponentialTableF64(VectorType).init`
- `VectorExponentialTableF64(VectorType).rateValue`
- `VectorExponentialTableF64(VectorType).inverseRateValue`
- `VectorExponentialTableF64(VectorType).expectedValue`
- `VectorExponentialTableF64(VectorType).varianceValue`
- `VectorExponentialTableF64(VectorType).medianValue`
- `VectorExponentialTableF64(VectorType).modeValue`
- `VectorExponentialTableF64(VectorType).minValue`
- `VectorExponentialTableF64(VectorType).maxValue`
- `VectorExponentialTableF64(VectorType).sample`
- `VectorExponentialTableF64(VectorType).sampleFrom`
- `VectorExponentialTableF64(VectorType).fill`
- `VectorExponentialTableF64(VectorType).fillFrom`
- `VectorExponentialApproxLogF32(VectorType)`
- `VectorExponentialApproxLogF32(VectorType).init`
- `VectorExponentialApproxLogF32(VectorType).rateValue`
- `VectorExponentialApproxLogF32(VectorType).inverseRateValue`
- `VectorExponentialApproxLogF32(VectorType).expectedValue`
- `VectorExponentialApproxLogF32(VectorType).varianceValue`
- `VectorExponentialApproxLogF32(VectorType).medianValue`
- `VectorExponentialApproxLogF32(VectorType).modeValue`
- `VectorExponentialApproxLogF32(VectorType).minValue`
- `VectorExponentialApproxLogF32(VectorType).maxValue`
- `VectorExponentialApproxLogF32(VectorType).sample`
- `VectorExponentialApproxLogF32(VectorType).sampleFrom`
- `VectorExponentialApproxLogF32(VectorType).fill`
- `VectorExponentialApproxLogF32(VectorType).fillFrom`
- `VectorStandardExponential(VectorType)`
- `VectorStandardExponential(VectorType).rateValue`
- `VectorStandardExponential(VectorType).inverseRateValue`
- `VectorStandardExponential(VectorType).expectedValue`
- `VectorStandardExponential(VectorType).varianceValue`
- `VectorStandardExponential(VectorType).medianValue`
- `VectorStandardExponential(VectorType).modeValue`
- `VectorStandardExponential(VectorType).minValue`
- `VectorStandardExponential(VectorType).maxValue`
- `VectorStandardExponential(VectorType).sample`
- `VectorStandardExponential(VectorType).sampleFrom`
- `VectorStandardExponential(VectorType).fill`
- `VectorStandardExponential(VectorType).fillFrom`
- `VectorExponential(VectorType)`
- `VectorExponential(VectorType).init`
- `VectorExponential(VectorType).rateValue`
- `VectorExponential(VectorType).inverseRateValue`
- `VectorExponential(VectorType).expectedValue`
- `VectorExponential(VectorType).varianceValue`
- `VectorExponential(VectorType).medianValue`
- `VectorExponential(VectorType).modeValue`
- `VectorExponential(VectorType).minValue`
- `VectorExponential(VectorType).maxValue`
- `VectorExponential(VectorType).sample`
- `VectorExponential(VectorType).sampleFrom`
- `VectorExponential(VectorType).fill`
- `VectorExponential(VectorType).fillFrom`
- `LogNormal(T)`
- `LogNormal(T).init`
- `LogNormal(T).new`
- `LogNormal(T).initMeanCv`
- `LogNormal(T).fromMeanCv`
- `LogNormal(T).fromZScore`
- `LogNormal(T).logMean`
- `LogNormal(T).logMeanValue`
- `LogNormal(T).logStddev`
- `LogNormal(T).logStddevValue`
- `LogNormal(T).linearMeanValue`
- `LogNormal(T).medianValue`
- `LogNormal(T).modeValue`
- `LogNormal(T).expectedValue`
- `LogNormal(T).varianceValue`
- `LogNormal(T).minValue`
- `LogNormal(T).maxValue`
- `LogNormal(T).coefficientOfVariationValue`
- `LogNormal(T).sample`
- `LogNormal(T).sampleFrom`
- `LogNormal(T).fill`
- `LogNormal(T).fillFrom`
- `BufferedLogNormal(T, buffer_len)`
- `BufferedLogNormal(T, buffer_len).capacity`
- `BufferedLogNormal(T, buffer_len).init`
- `BufferedLogNormal(T, buffer_len).initMeanCv`
- `BufferedLogNormal(T, buffer_len).logMeanValue`
- `BufferedLogNormal(T, buffer_len).logMean`
- `BufferedLogNormal(T, buffer_len).logStddevValue`
- `BufferedLogNormal(T, buffer_len).logStddev`
- `BufferedLogNormal(T, buffer_len).linearMeanValue`
- `BufferedLogNormal(T, buffer_len).medianValue`
- `BufferedLogNormal(T, buffer_len).modeValue`
- `BufferedLogNormal(T, buffer_len).expectedValue`
- `BufferedLogNormal(T, buffer_len).varianceValue`
- `BufferedLogNormal(T, buffer_len).minValue`
- `BufferedLogNormal(T, buffer_len).maxValue`
- `BufferedLogNormal(T, buffer_len).coefficientOfVariationValue`
- `BufferedLogNormal(T, buffer_len).bufferedValueCount`
- `BufferedLogNormal(T, buffer_len).reset`
- `BufferedLogNormal(T, buffer_len).sample`
- `BufferedLogNormal(T, buffer_len).sampleFrom`
- `BufferedLogNormal(T, buffer_len).fill`
- `BufferedLogNormal(T, buffer_len).fillFrom`
- `LogNormalLibmvec(T, buffer_len)`
- `LogNormalLibmvec(T, buffer_len).capacity`
- `LogNormalLibmvec(T, buffer_len).init`
- `LogNormalLibmvec(T, buffer_len).initMeanCv`
- `LogNormalLibmvec(T, buffer_len).deinit`
- `LogNormalLibmvec(T, buffer_len).logMeanValue`
- `LogNormalLibmvec(T, buffer_len).logStddevValue`
- `LogNormalLibmvec(T, buffer_len).bufferedValueCount`
- `LogNormalLibmvec(T, buffer_len).reset`
- `LogNormalLibmvec(T, buffer_len).sample`
- `LogNormalLibmvec(T, buffer_len).sampleFrom`
- `LogNormalLibmvec(T, buffer_len).fill`
- `LogNormalLibmvec(T, buffer_len).fillFrom`
- `LogNormalDlsymExp(T, buffer_len)`
- `LogNormalDlsymExp(T, buffer_len).capacity`
- `LogNormalDlsymExp(T, buffer_len).init`
- `LogNormalDlsymExp(T, buffer_len).initMeanCv`
- `LogNormalDlsymExp(T, buffer_len).deinit`
- `LogNormalDlsymExp(T, buffer_len).logMeanValue`
- `LogNormalDlsymExp(T, buffer_len).logStddevValue`
- `LogNormalDlsymExp(T, buffer_len).bufferedValueCount`
- `LogNormalDlsymExp(T, buffer_len).reset`
- `LogNormalDlsymExp(T, buffer_len).sample`
- `LogNormalDlsymExp(T, buffer_len).sampleFrom`
- `LogNormalDlsymExp(T, buffer_len).fill`
- `LogNormalDlsymExp(T, buffer_len).fillFrom`
- `LogNormalNativeF32`
- `LogNormalNativeF32.init`
- `LogNormalNativeF32.meanValue`
- `LogNormalNativeF32.stddevValue`
- `LogNormalNativeF32.sample`
- `LogNormalNativeF32.sampleFrom`
- `LogNormalNativeF32.fill`
- `LogNormalNativeF32.fillFrom`
- `VectorLogNormalNativeF32(VectorType)`
- `VectorLogNormalNativeF32(VectorType).init`
- `VectorLogNormalNativeF32(VectorType).meanValue`
- `VectorLogNormalNativeF32(VectorType).stddevValue`
- `VectorLogNormalNativeF32(VectorType).sample`
- `VectorLogNormalNativeF32(VectorType).sampleFrom`
- `VectorLogNormalNativeF32(VectorType).fill`
- `VectorLogNormalNativeF32(VectorType).fillFrom`
- `LogNormalNativeExp2F32`
- `LogNormalNativeExp2F32.max_abs_mean`
- `LogNormalNativeExp2F32.max_stddev`
- `LogNormalNativeExp2F32.init`
- `LogNormalNativeExp2F32.meanValue`
- `LogNormalNativeExp2F32.stddevValue`
- `LogNormalNativeExp2F32.maxAbsMeanValue`
- `LogNormalNativeExp2F32.maxStddevValue`
- `LogNormalNativeExp2F32.sample`
- `LogNormalNativeExp2F32.sampleFrom`
- `LogNormalNativeExp2F32.fill`
- `LogNormalNativeExp2F32.fillFrom`
- `VectorLogNormalNativeExp2F32(VectorType)`
- `VectorLogNormalNativeExp2F32(VectorType).max_abs_mean`
- `VectorLogNormalNativeExp2F32(VectorType).max_stddev`
- `VectorLogNormalNativeExp2F32(VectorType).init`
- `VectorLogNormalNativeExp2F32(VectorType).meanValue`
- `VectorLogNormalNativeExp2F32(VectorType).stddevValue`
- `VectorLogNormalNativeExp2F32(VectorType).maxAbsMeanValue`
- `VectorLogNormalNativeExp2F32(VectorType).maxStddevValue`
- `VectorLogNormalNativeExp2F32(VectorType).sample`
- `VectorLogNormalNativeExp2F32(VectorType).sampleFrom`
- `VectorLogNormalNativeExp2F32(VectorType).fill`
- `VectorLogNormalNativeExp2F32(VectorType).fillFrom`
- `VectorLogNormal(VectorType)`
- `VectorLogNormal(VectorType).init`
- `VectorLogNormal(VectorType).meanValue`
- `VectorLogNormal(VectorType).stddevValue`
- `VectorLogNormal(VectorType).sample`
- `VectorLogNormal(VectorType).sampleFrom`
- `VectorLogNormal(VectorType).fill`
- `VectorLogNormal(VectorType).fillFrom`
- `LogNormalApproxF32`
- `LogNormalApproxF32.max_abs_mean`
- `LogNormalApproxF32.max_stddev`
- `LogNormalApproxF32.init`
- `LogNormalApproxF32.meanValue`
- `LogNormalApproxF32.stddevValue`
- `LogNormalApproxF32.maxAbsMeanValue`
- `LogNormalApproxF32.maxStddevValue`
- `LogNormalApproxF32.sample`
- `LogNormalApproxF32.sampleFrom`
- `LogNormalApproxF32.fill`
- `LogNormalApproxF32.fillFrom`
- `LogNormalExp2F32`
- `LogNormalExp2F32.max_abs_mean`
- `LogNormalExp2F32.max_stddev`
- `LogNormalExp2F32.init`
- `LogNormalExp2F32.meanValue`
- `LogNormalExp2F32.stddevValue`
- `LogNormalExp2F32.maxAbsMeanValue`
- `LogNormalExp2F32.maxStddevValue`
- `LogNormalExp2F32.sample`
- `LogNormalExp2F32.sampleFrom`
- `LogNormalExp2F32.fill`
- `LogNormalExp2F32.fillFrom`
- `VectorLogNormalExp2F32(VectorType)`
- `VectorLogNormalExp2F32(VectorType).max_abs_mean`
- `VectorLogNormalExp2F32(VectorType).max_stddev`
- `VectorLogNormalExp2F32(VectorType).init`
- `VectorLogNormalExp2F32(VectorType).meanValue`
- `VectorLogNormalExp2F32(VectorType).stddevValue`
- `VectorLogNormalExp2F32(VectorType).maxAbsMeanValue`
- `VectorLogNormalExp2F32(VectorType).maxStddevValue`
- `VectorLogNormalExp2F32(VectorType).sample`
- `VectorLogNormalExp2F32(VectorType).sampleFrom`
- `VectorLogNormalExp2F32(VectorType).fill`
- `VectorLogNormalExp2F32(VectorType).fillFrom`
- `VectorLogNormalApproxF32(VectorType)`
- `VectorLogNormalApproxF32(VectorType).max_abs_mean`
- `VectorLogNormalApproxF32(VectorType).max_stddev`
- `VectorLogNormalApproxF32(VectorType).init`
- `VectorLogNormalApproxF32(VectorType).meanValue`
- `VectorLogNormalApproxF32(VectorType).stddevValue`
- `VectorLogNormalApproxF32(VectorType).maxAbsMeanValue`
- `VectorLogNormalApproxF32(VectorType).maxStddevValue`
- `VectorLogNormalApproxF32(VectorType).sample`
- `VectorLogNormalApproxF32(VectorType).sampleFrom`
- `VectorLogNormalApproxF32(VectorType).fill`
- `VectorLogNormalApproxF32(VectorType).fillFrom`
- `HalfNormal(T)`
- `HalfNormal(T).init`
- `HalfNormal(T).scaleValue`
- `HalfNormal(T).expectedValue`
- `HalfNormal(T).varianceValue`
- `HalfNormal(T).minValue`
- `HalfNormal(T).maxValue`
- `HalfNormal(T).sample`
- `HalfNormal(T).sampleFrom`
- `HalfNormal(T).fill`
- `HalfNormal(T).fillFrom`
- `VectorHalfNormal(VectorType)`
- `VectorHalfNormal(VectorType).init`
- `VectorHalfNormal(VectorType).scaleValue`
- `VectorHalfNormal(VectorType).expectedValue`
- `VectorHalfNormal(VectorType).varianceValue`
- `VectorHalfNormal(VectorType).minValue`
- `VectorHalfNormal(VectorType).maxValue`
- `VectorHalfNormal(VectorType).sample`
- `VectorHalfNormal(VectorType).sampleFrom`
- `VectorHalfNormal(VectorType).fill`
- `VectorHalfNormal(VectorType).fillFrom`
- `Poisson`
- `Poisson.init`
- `Poisson.new`
- `Poisson.lambdaValue`
- `Poisson.expectedValue`
- `Poisson.varianceValue`
- `Poisson.minValue`
- `Poisson.maxValue`
- `Poisson.sample`
- `Poisson.sampleFrom`
- `Poisson.fill`
- `Poisson.fillFrom`
- `VectorPoisson(VectorType)`
- `VectorPoisson(VectorType).init`
- `VectorPoisson(VectorType).lambdaValue`
- `VectorPoisson(VectorType).expectedValue`
- `VectorPoisson(VectorType).varianceValue`
- `VectorPoisson(VectorType).minValue`
- `VectorPoisson(VectorType).maxValue`
- `VectorPoisson(VectorType).sample`
- `VectorPoisson(VectorType).sampleFrom`
- `VectorPoisson(VectorType).fill`
- `VectorPoisson(VectorType).fillFrom`
- `Geometric`
- `Geometric.init`
- `Geometric.probabilityValue`
- `Geometric.expectedValue`
- `Geometric.varianceValue`
- `Geometric.modeValue`
- `Geometric.minValue`
- `Geometric.maxValue`
- `Geometric.sample`
- `Geometric.sampleFrom`
- `Geometric.fill`
- `Geometric.fillFrom`
- `VectorGeometric(VectorType)`
- `VectorGeometric(VectorType).init`
- `VectorGeometric(VectorType).probabilityValue`
- `VectorGeometric(VectorType).expectedValue`
- `VectorGeometric(VectorType).varianceValue`
- `VectorGeometric(VectorType).modeValue`
- `VectorGeometric(VectorType).minValue`
- `VectorGeometric(VectorType).maxValue`
- `VectorGeometric(VectorType).sample`
- `VectorGeometric(VectorType).sampleFrom`
- `VectorGeometric(VectorType).fill`
- `VectorGeometric(VectorType).fillFrom`
- `GeometricFailures`
- `GeometricFailures.init`
- `GeometricFailures.new`
- `GeometricFailures.probabilityValue`
- `GeometricFailures.expectedValue`
- `GeometricFailures.varianceValue`
- `GeometricFailures.modeValue`
- `GeometricFailures.minValue`
- `GeometricFailures.maxValue`
- `GeometricFailures.sample`
- `GeometricFailures.sampleFrom`
- `GeometricFailures.fill`
- `GeometricFailures.fillFrom`
- `VectorGeometricFailures(VectorType)`
- `VectorGeometricFailures(VectorType).init`
- `VectorGeometricFailures(VectorType).probabilityValue`
- `VectorGeometricFailures(VectorType).expectedValue`
- `VectorGeometricFailures(VectorType).varianceValue`
- `VectorGeometricFailures(VectorType).modeValue`
- `VectorGeometricFailures(VectorType).minValue`
- `VectorGeometricFailures(VectorType).maxValue`
- `VectorGeometricFailures(VectorType).sample`
- `VectorGeometricFailures(VectorType).sampleFrom`
- `VectorGeometricFailures(VectorType).fill`
- `VectorGeometricFailures(VectorType).fillFrom`
- `StandardGeometric`
- `StandardGeometric.probabilityValue`
- `StandardGeometric.expectedValue`
- `StandardGeometric.varianceValue`
- `StandardGeometric.modeValue`
- `StandardGeometric.minValue`
- `StandardGeometric.maxValue`
- `StandardGeometric.sample`
- `StandardGeometric.sampleFrom`
- `StandardGeometric.fill`
- `StandardGeometric.fillFrom`
- `VectorStandardGeometric(VectorType)`
- `VectorStandardGeometric(VectorType).probabilityValue`
- `VectorStandardGeometric(VectorType).expectedValue`
- `VectorStandardGeometric(VectorType).varianceValue`
- `VectorStandardGeometric(VectorType).modeValue`
- `VectorStandardGeometric(VectorType).minValue`
- `VectorStandardGeometric(VectorType).maxValue`
- `VectorStandardGeometric(VectorType).sample`
- `VectorStandardGeometric(VectorType).sampleFrom`
- `VectorStandardGeometric(VectorType).fill`
- `VectorStandardGeometric(VectorType).fillFrom`
- `Gamma(T)`
- `Gamma(T).init`
- `Gamma(T).new`
- `Gamma(T).shapeValue`
- `Gamma(T).scaleValue`
- `Gamma(T).expectedValue`
- `Gamma(T).varianceValue`
- `Gamma(T).modeValue`
- `Gamma(T).minValue`
- `Gamma(T).maxValue`
- `Gamma(T).sample`
- `Gamma(T).sampleFrom`
- `Gamma(T).fill`
- `Gamma(T).fillFrom`
- `VectorGamma(VectorType)`
- `VectorGamma(VectorType).init`
- `VectorGamma(VectorType).shapeValue`
- `VectorGamma(VectorType).scaleValue`
- `VectorGamma(VectorType).expectedValue`
- `VectorGamma(VectorType).varianceValue`
- `VectorGamma(VectorType).modeValue`
- `VectorGamma(VectorType).minValue`
- `VectorGamma(VectorType).maxValue`
- `VectorGamma(VectorType).sample`
- `VectorGamma(VectorType).sampleFrom`
- `VectorGamma(VectorType).fill`
- `VectorGamma(VectorType).fillFrom`
- `ChiSquared(T)`
- `ChiSquared(T).init`
- `ChiSquared(T).new`
- `ChiSquared(T).dofValue`
- `ChiSquared(T).expectedValue`
- `ChiSquared(T).varianceValue`
- `ChiSquared(T).modeValue`
- `ChiSquared(T).minValue`
- `ChiSquared(T).maxValue`
- `ChiSquared(T).sample`
- `ChiSquared(T).sampleFrom`
- `ChiSquared(T).fill`
- `ChiSquared(T).fillFrom`
- `VectorChiSquared(VectorType)`
- `VectorChiSquared(VectorType).init`
- `VectorChiSquared(VectorType).dofValue`
- `VectorChiSquared(VectorType).expectedValue`
- `VectorChiSquared(VectorType).varianceValue`
- `VectorChiSquared(VectorType).modeValue`
- `VectorChiSquared(VectorType).minValue`
- `VectorChiSquared(VectorType).maxValue`
- `VectorChiSquared(VectorType).sample`
- `VectorChiSquared(VectorType).sampleFrom`
- `VectorChiSquared(VectorType).fill`
- `VectorChiSquared(VectorType).fillFrom`
- `Chi(T)`
- `Chi(T).init`
- `Chi(T).dofValue`
- `Chi(T).expectedValue`
- `Chi(T).varianceValue`
- `Chi(T).modeValue`
- `Chi(T).minValue`
- `Chi(T).maxValue`
- `Chi(T).sample`
- `Chi(T).sampleFrom`
- `Chi(T).fill`
- `Chi(T).fillFrom`
- `VectorChi(VectorType)`
- `VectorChi(VectorType).init`
- `VectorChi(VectorType).dofValue`
- `VectorChi(VectorType).expectedValue`
- `VectorChi(VectorType).varianceValue`
- `VectorChi(VectorType).modeValue`
- `VectorChi(VectorType).minValue`
- `VectorChi(VectorType).maxValue`
- `VectorChi(VectorType).sample`
- `VectorChi(VectorType).sampleFrom`
- `VectorChi(VectorType).fill`
- `VectorChi(VectorType).fillFrom`
- `Erlang(T)`
- `Erlang(T).init`
- `Erlang(T).shapeValue`
- `Erlang(T).scaleValue`
- `Erlang(T).expectedValue`
- `Erlang(T).varianceValue`
- `Erlang(T).modeValue`
- `Erlang(T).minValue`
- `Erlang(T).maxValue`
- `Erlang(T).sample`
- `Erlang(T).sampleFrom`
- `Erlang(T).fill`
- `Erlang(T).fillFrom`
- `VectorErlang(VectorType)`
- `VectorErlang(VectorType).init`
- `VectorErlang(VectorType).shapeValue`
- `VectorErlang(VectorType).scaleValue`
- `VectorErlang(VectorType).expectedValue`
- `VectorErlang(VectorType).varianceValue`
- `VectorErlang(VectorType).modeValue`
- `VectorErlang(VectorType).minValue`
- `VectorErlang(VectorType).maxValue`
- `VectorErlang(VectorType).sample`
- `VectorErlang(VectorType).sampleFrom`
- `VectorErlang(VectorType).fill`
- `VectorErlang(VectorType).fillFrom`
- `Beta(T)`
- `Beta(T).init`
- `Beta(T).new`
- `Beta(T).alphaValue`
- `Beta(T).betaValue`
- `Beta(T).expectedValue`
- `Beta(T).varianceValue`
- `Beta(T).modeValue`
- `Beta(T).minValue`
- `Beta(T).maxValue`
- `Beta(T).sample`
- `Beta(T).sampleFrom`
- `Beta(T).fill`
- `Beta(T).fillFrom`
- `VectorBeta(VectorType)`
- `VectorBeta(VectorType).init`
- `VectorBeta(VectorType).alphaValue`
- `VectorBeta(VectorType).betaValue`
- `VectorBeta(VectorType).expectedValue`
- `VectorBeta(VectorType).varianceValue`
- `VectorBeta(VectorType).modeValue`
- `VectorBeta(VectorType).minValue`
- `VectorBeta(VectorType).maxValue`
- `VectorBeta(VectorType).sample`
- `VectorBeta(VectorType).sampleFrom`
- `VectorBeta(VectorType).fill`
- `VectorBeta(VectorType).fillFrom`
- `FisherF(T)`
- `FisherF(T).init`
- `FisherF(T).new`
- `FisherF(T).d1Value`
- `FisherF(T).d2Value`
- `FisherF(T).expectedValue`
- `FisherF(T).varianceValue`
- `FisherF(T).minValue`
- `FisherF(T).maxValue`
- `FisherF(T).sample`
- `FisherF(T).sampleFrom`
- `FisherF(T).fill`
- `FisherF(T).fillFrom`
- `VectorFisherF(VectorType)`
- `VectorFisherF(VectorType).init`
- `VectorFisherF(VectorType).d1Value`
- `VectorFisherF(VectorType).d2Value`
- `VectorFisherF(VectorType).expectedValue`
- `VectorFisherF(VectorType).varianceValue`
- `VectorFisherF(VectorType).minValue`
- `VectorFisherF(VectorType).maxValue`
- `VectorFisherF(VectorType).sample`
- `VectorFisherF(VectorType).sampleFrom`
- `VectorFisherF(VectorType).fill`
- `VectorFisherF(VectorType).fillFrom`
- `StudentT(T)`
- `StudentT(T).init`
- `StudentT(T).new`
- `StudentT(T).dofValue`
- `StudentT(T).expectedValue`
- `StudentT(T).varianceValue`
- `StudentT(T).minValue`
- `StudentT(T).maxValue`
- `StudentT(T).sample`
- `StudentT(T).sampleFrom`
- `StudentT(T).fill`
- `StudentT(T).fillFrom`
- `VectorStudentT(VectorType)`
- `VectorStudentT(VectorType).init`
- `VectorStudentT(VectorType).dofValue`
- `VectorStudentT(VectorType).expectedValue`
- `VectorStudentT(VectorType).varianceValue`
- `VectorStudentT(VectorType).minValue`
- `VectorStudentT(VectorType).maxValue`
- `VectorStudentT(VectorType).sample`
- `VectorStudentT(VectorType).sampleFrom`
- `VectorStudentT(VectorType).fill`
- `VectorStudentT(VectorType).fillFrom`
- `Triangular(T)`
- `Triangular(T).init`
- `Triangular(T).new`
- `Triangular(T).minValue`
- `Triangular(T).modeValue`
- `Triangular(T).maxValue`
- `Triangular(T).expectedValue`
- `Triangular(T).varianceValue`
- `Triangular(T).medianValue`
- `Triangular(T).sample`
- `Triangular(T).sampleFrom`
- `Triangular(T).fill`
- `Triangular(T).fillFrom`
- `VectorTriangular(VectorType)`
- `VectorTriangular(VectorType).init`
- `VectorTriangular(VectorType).minValue`
- `VectorTriangular(VectorType).modeValue`
- `VectorTriangular(VectorType).maxValue`
- `VectorTriangular(VectorType).expectedValue`
- `VectorTriangular(VectorType).varianceValue`
- `VectorTriangular(VectorType).medianValue`
- `VectorTriangular(VectorType).sample`
- `VectorTriangular(VectorType).sampleFrom`
- `VectorTriangular(VectorType).fill`
- `VectorTriangular(VectorType).fillFrom`
- `Arcsine(T)`
- `Arcsine(T).init`
- `Arcsine(T).minValue`
- `Arcsine(T).maxValue`
- `Arcsine(T).expectedValue`
- `Arcsine(T).varianceValue`
- `Arcsine(T).medianValue`
- `Arcsine(T).sample`
- `Arcsine(T).sampleFrom`
- `Arcsine(T).fill`
- `Arcsine(T).fillFrom`
- `VectorArcsine(VectorType)`
- `VectorArcsine(VectorType).init`
- `VectorArcsine(VectorType).minValue`
- `VectorArcsine(VectorType).maxValue`
- `VectorArcsine(VectorType).expectedValue`
- `VectorArcsine(VectorType).varianceValue`
- `VectorArcsine(VectorType).medianValue`
- `VectorArcsine(VectorType).sample`
- `VectorArcsine(VectorType).sampleFrom`
- `VectorArcsine(VectorType).fill`
- `VectorArcsine(VectorType).fillFrom`
- `Cauchy(T)`
- `Cauchy(T).init`
- `Cauchy(T).new`
- `Cauchy(T).medianValue`
- `Cauchy(T).modeValue`
- `Cauchy(T).scaleValue`
- `Cauchy(T).expectedValue`
- `Cauchy(T).varianceValue`
- `Cauchy(T).minValue`
- `Cauchy(T).maxValue`
- `Cauchy(T).sample`
- `Cauchy(T).sampleFrom`
- `Cauchy(T).fill`
- `Cauchy(T).fillFrom`
- `VectorCauchy(VectorType)`
- `VectorCauchy(VectorType).init`
- `VectorCauchy(VectorType).medianValue`
- `VectorCauchy(VectorType).modeValue`
- `VectorCauchy(VectorType).scaleValue`
- `VectorCauchy(VectorType).expectedValue`
- `VectorCauchy(VectorType).varianceValue`
- `VectorCauchy(VectorType).minValue`
- `VectorCauchy(VectorType).maxValue`
- `VectorCauchy(VectorType).sample`
- `VectorCauchy(VectorType).sampleFrom`
- `VectorCauchy(VectorType).fill`
- `VectorCauchy(VectorType).fillFrom`
- `Laplace(T)`
- `Laplace(T).init`
- `Laplace(T).locationValue`
- `Laplace(T).scaleValue`
- `Laplace(T).medianValue`
- `Laplace(T).modeValue`
- `Laplace(T).expectedValue`
- `Laplace(T).varianceValue`
- `Laplace(T).minValue`
- `Laplace(T).maxValue`
- `Laplace(T).sample`
- `Laplace(T).sampleFrom`
- `Laplace(T).fill`
- `Laplace(T).fillFrom`
- `VectorLaplace(VectorType)`
- `VectorLaplace(VectorType).init`
- `VectorLaplace(VectorType).locationValue`
- `VectorLaplace(VectorType).scaleValue`
- `VectorLaplace(VectorType).medianValue`
- `VectorLaplace(VectorType).modeValue`
- `VectorLaplace(VectorType).expectedValue`
- `VectorLaplace(VectorType).varianceValue`
- `VectorLaplace(VectorType).minValue`
- `VectorLaplace(VectorType).maxValue`
- `VectorLaplace(VectorType).sample`
- `VectorLaplace(VectorType).sampleFrom`
- `VectorLaplace(VectorType).fill`
- `VectorLaplace(VectorType).fillFrom`
- `Logistic(T)`
- `Logistic(T).init`
- `Logistic(T).locationValue`
- `Logistic(T).scaleValue`
- `Logistic(T).medianValue`
- `Logistic(T).modeValue`
- `Logistic(T).expectedValue`
- `Logistic(T).varianceValue`
- `Logistic(T).minValue`
- `Logistic(T).maxValue`
- `Logistic(T).sample`
- `Logistic(T).sampleFrom`
- `Logistic(T).fill`
- `Logistic(T).fillFrom`
- `VectorLogistic(VectorType)`
- `VectorLogistic(VectorType).init`
- `VectorLogistic(VectorType).locationValue`
- `VectorLogistic(VectorType).scaleValue`
- `VectorLogistic(VectorType).medianValue`
- `VectorLogistic(VectorType).modeValue`
- `VectorLogistic(VectorType).expectedValue`
- `VectorLogistic(VectorType).varianceValue`
- `VectorLogistic(VectorType).minValue`
- `VectorLogistic(VectorType).maxValue`
- `VectorLogistic(VectorType).sample`
- `VectorLogistic(VectorType).sampleFrom`
- `VectorLogistic(VectorType).fill`
- `VectorLogistic(VectorType).fillFrom`
- `LogLogistic(T)`
- `LogLogistic(T).init`
- `LogLogistic(T).scaleValue`
- `LogLogistic(T).shapeValue`
- `LogLogistic(T).expectedValue`
- `LogLogistic(T).varianceValue`
- `LogLogistic(T).medianValue`
- `LogLogistic(T).modeValue`
- `LogLogistic(T).minValue`
- `LogLogistic(T).maxValue`
- `LogLogistic(T).sample`
- `LogLogistic(T).sampleFrom`
- `LogLogistic(T).fill`
- `LogLogistic(T).fillFrom`
- `VectorLogLogistic(VectorType)`
- `VectorLogLogistic(VectorType).init`
- `VectorLogLogistic(VectorType).scaleValue`
- `VectorLogLogistic(VectorType).shapeValue`
- `VectorLogLogistic(VectorType).expectedValue`
- `VectorLogLogistic(VectorType).varianceValue`
- `VectorLogLogistic(VectorType).medianValue`
- `VectorLogLogistic(VectorType).modeValue`
- `VectorLogLogistic(VectorType).minValue`
- `VectorLogLogistic(VectorType).maxValue`
- `VectorLogLogistic(VectorType).sample`
- `VectorLogLogistic(VectorType).sampleFrom`
- `VectorLogLogistic(VectorType).fill`
- `VectorLogLogistic(VectorType).fillFrom`
- `Kumaraswamy(T)`
- `Kumaraswamy(T).init`
- `Kumaraswamy(T).alphaValue`
- `Kumaraswamy(T).betaValue`
- `Kumaraswamy(T).expectedValue`
- `Kumaraswamy(T).varianceValue`
- `Kumaraswamy(T).modeValue`
- `Kumaraswamy(T).medianValue`
- `Kumaraswamy(T).minValue`
- `Kumaraswamy(T).maxValue`
- `Kumaraswamy(T).sample`
- `Kumaraswamy(T).sampleFrom`
- `Kumaraswamy(T).fill`
- `Kumaraswamy(T).fillFrom`
- `VectorKumaraswamy(VectorType)`
- `VectorKumaraswamy(VectorType).init`
- `VectorKumaraswamy(VectorType).alphaValue`
- `VectorKumaraswamy(VectorType).betaValue`
- `VectorKumaraswamy(VectorType).expectedValue`
- `VectorKumaraswamy(VectorType).varianceValue`
- `VectorKumaraswamy(VectorType).modeValue`
- `VectorKumaraswamy(VectorType).medianValue`
- `VectorKumaraswamy(VectorType).minValue`
- `VectorKumaraswamy(VectorType).maxValue`
- `VectorKumaraswamy(VectorType).sample`
- `VectorKumaraswamy(VectorType).sampleFrom`
- `VectorKumaraswamy(VectorType).fill`
- `VectorKumaraswamy(VectorType).fillFrom`
- `PowerFunction(T)`
- `PowerFunction(T).init`
- `PowerFunction(T).minValue`
- `PowerFunction(T).maxValue`
- `PowerFunction(T).shapeValue`
- `PowerFunction(T).expectedValue`
- `PowerFunction(T).varianceValue`
- `PowerFunction(T).medianValue`
- `PowerFunction(T).sample`
- `PowerFunction(T).sampleFrom`
- `PowerFunction(T).fill`
- `PowerFunction(T).fillFrom`
- `VectorPowerFunction(VectorType)`
- `VectorPowerFunction(VectorType).init`
- `VectorPowerFunction(VectorType).minValue`
- `VectorPowerFunction(VectorType).maxValue`
- `VectorPowerFunction(VectorType).shapeValue`
- `VectorPowerFunction(VectorType).expectedValue`
- `VectorPowerFunction(VectorType).varianceValue`
- `VectorPowerFunction(VectorType).medianValue`
- `VectorPowerFunction(VectorType).sample`
- `VectorPowerFunction(VectorType).sampleFrom`
- `VectorPowerFunction(VectorType).fill`
- `VectorPowerFunction(VectorType).fillFrom`
- `Rayleigh(T)`
- `Rayleigh(T).init`
- `Rayleigh(T).scaleValue`
- `Rayleigh(T).expectedValue`
- `Rayleigh(T).varianceValue`
- `Rayleigh(T).medianValue`
- `Rayleigh(T).modeValue`
- `Rayleigh(T).minValue`
- `Rayleigh(T).maxValue`
- `Rayleigh(T).sample`
- `Rayleigh(T).sampleFrom`
- `Rayleigh(T).fill`
- `Rayleigh(T).fillFrom`
- `VectorRayleigh(VectorType)`
- `VectorRayleigh(VectorType).init`
- `VectorRayleigh(VectorType).scaleValue`
- `VectorRayleigh(VectorType).expectedValue`
- `VectorRayleigh(VectorType).varianceValue`
- `VectorRayleigh(VectorType).medianValue`
- `VectorRayleigh(VectorType).modeValue`
- `VectorRayleigh(VectorType).minValue`
- `VectorRayleigh(VectorType).maxValue`
- `VectorRayleigh(VectorType).sample`
- `VectorRayleigh(VectorType).sampleFrom`
- `VectorRayleigh(VectorType).fill`
- `VectorRayleigh(VectorType).fillFrom`
- `Maxwell(T)`
- `Maxwell(T).init`
- `Maxwell(T).scaleValue`
- `Maxwell(T).expectedValue`
- `Maxwell(T).varianceValue`
- `Maxwell(T).modeValue`
- `Maxwell(T).minValue`
- `Maxwell(T).maxValue`
- `Maxwell(T).sample`
- `Maxwell(T).sampleFrom`
- `Maxwell(T).fill`
- `Maxwell(T).fillFrom`
- `VectorMaxwell(VectorType)`
- `VectorMaxwell(VectorType).init`
- `VectorMaxwell(VectorType).scaleValue`
- `VectorMaxwell(VectorType).expectedValue`
- `VectorMaxwell(VectorType).varianceValue`
- `VectorMaxwell(VectorType).modeValue`
- `VectorMaxwell(VectorType).minValue`
- `VectorMaxwell(VectorType).maxValue`
- `VectorMaxwell(VectorType).sample`
- `VectorMaxwell(VectorType).sampleFrom`
- `VectorMaxwell(VectorType).fill`
- `VectorMaxwell(VectorType).fillFrom`
- `Pareto(T)`
- `Pareto(T).init`
- `Pareto(T).new`
- `Pareto(T).scaleValue`
- `Pareto(T).shapeValue`
- `Pareto(T).expectedValue`
- `Pareto(T).varianceValue`
- `Pareto(T).medianValue`
- `Pareto(T).modeValue`
- `Pareto(T).minValue`
- `Pareto(T).maxValue`
- `Pareto(T).sample`
- `Pareto(T).sampleFrom`
- `Pareto(T).fill`
- `Pareto(T).fillFrom`
- `VectorPareto(VectorType)`
- `VectorPareto(VectorType).init`
- `VectorPareto(VectorType).scaleValue`
- `VectorPareto(VectorType).shapeValue`
- `VectorPareto(VectorType).expectedValue`
- `VectorPareto(VectorType).varianceValue`
- `VectorPareto(VectorType).medianValue`
- `VectorPareto(VectorType).modeValue`
- `VectorPareto(VectorType).minValue`
- `VectorPareto(VectorType).maxValue`
- `VectorPareto(VectorType).sample`
- `VectorPareto(VectorType).sampleFrom`
- `VectorPareto(VectorType).fill`
- `VectorPareto(VectorType).fillFrom`
- `Weibull(T)`
- `Weibull(T).init`
- `Weibull(T).new`
- `Weibull(T).scaleValue`
- `Weibull(T).shapeValue`
- `Weibull(T).expectedValue`
- `Weibull(T).varianceValue`
- `Weibull(T).medianValue`
- `Weibull(T).modeValue`
- `Weibull(T).minValue`
- `Weibull(T).maxValue`
- `Weibull(T).sample`
- `Weibull(T).sampleFrom`
- `Weibull(T).fill`
- `Weibull(T).fillFrom`
- `VectorWeibull(VectorType)`
- `VectorWeibull(VectorType).init`
- `VectorWeibull(VectorType).scaleValue`
- `VectorWeibull(VectorType).shapeValue`
- `VectorWeibull(VectorType).expectedValue`
- `VectorWeibull(VectorType).varianceValue`
- `VectorWeibull(VectorType).medianValue`
- `VectorWeibull(VectorType).modeValue`
- `VectorWeibull(VectorType).minValue`
- `VectorWeibull(VectorType).maxValue`
- `VectorWeibull(VectorType).sample`
- `VectorWeibull(VectorType).sampleFrom`
- `VectorWeibull(VectorType).fill`
- `VectorWeibull(VectorType).fillFrom`
- `Gumbel(T)`
- `Gumbel(T).init`
- `Gumbel(T).new`
- `Gumbel(T).locationValue`
- `Gumbel(T).scaleValue`
- `Gumbel(T).expectedValue`
- `Gumbel(T).varianceValue`
- `Gumbel(T).medianValue`
- `Gumbel(T).modeValue`
- `Gumbel(T).minValue`
- `Gumbel(T).maxValue`
- `Gumbel(T).sample`
- `Gumbel(T).sampleFrom`
- `Gumbel(T).fill`
- `Gumbel(T).fillFrom`
- `VectorGumbel(VectorType)`
- `VectorGumbel(VectorType).init`
- `VectorGumbel(VectorType).locationValue`
- `VectorGumbel(VectorType).scaleValue`
- `VectorGumbel(VectorType).expectedValue`
- `VectorGumbel(VectorType).varianceValue`
- `VectorGumbel(VectorType).medianValue`
- `VectorGumbel(VectorType).modeValue`
- `VectorGumbel(VectorType).minValue`
- `VectorGumbel(VectorType).maxValue`
- `VectorGumbel(VectorType).sample`
- `VectorGumbel(VectorType).sampleFrom`
- `VectorGumbel(VectorType).fill`
- `VectorGumbel(VectorType).fillFrom`
- `Frechet(T)`
- `Frechet(T).init`
- `Frechet(T).new`
- `Frechet(T).locationValue`
- `Frechet(T).scaleValue`
- `Frechet(T).shapeValue`
- `Frechet(T).expectedValue`
- `Frechet(T).varianceValue`
- `Frechet(T).medianValue`
- `Frechet(T).modeValue`
- `Frechet(T).minValue`
- `Frechet(T).maxValue`
- `Frechet(T).sample`
- `Frechet(T).sampleFrom`
- `Frechet(T).fill`
- `Frechet(T).fillFrom`
- `VectorFrechet(VectorType)`
- `VectorFrechet(VectorType).init`
- `VectorFrechet(VectorType).locationValue`
- `VectorFrechet(VectorType).scaleValue`
- `VectorFrechet(VectorType).shapeValue`
- `VectorFrechet(VectorType).expectedValue`
- `VectorFrechet(VectorType).varianceValue`
- `VectorFrechet(VectorType).medianValue`
- `VectorFrechet(VectorType).modeValue`
- `VectorFrechet(VectorType).minValue`
- `VectorFrechet(VectorType).maxValue`
- `VectorFrechet(VectorType).sample`
- `VectorFrechet(VectorType).sampleFrom`
- `VectorFrechet(VectorType).fill`
- `VectorFrechet(VectorType).fillFrom`
- `SkewNormal(T)`
- `SkewNormal(T).init`
- `SkewNormal(T).new`
- `SkewNormal(T).locationValue`
- `SkewNormal(T).locationParameter`
- `SkewNormal(T).scaleValue`
- `SkewNormal(T).scaleParameter`
- `SkewNormal(T).shapeValue`
- `SkewNormal(T).shapeParameter`
- `SkewNormal(T).expectedValue`
- `SkewNormal(T).varianceValue`
- `SkewNormal(T).minValue`
- `SkewNormal(T).maxValue`
- `SkewNormal(T).sample`
- `SkewNormal(T).sampleFrom`
- `SkewNormal(T).fill`
- `SkewNormal(T).fillFrom`
- `VectorSkewNormal(VectorType)`
- `VectorSkewNormal(VectorType).init`
- `VectorSkewNormal(VectorType).locationValue`
- `VectorSkewNormal(VectorType).locationParameter`
- `VectorSkewNormal(VectorType).scaleValue`
- `VectorSkewNormal(VectorType).scaleParameter`
- `VectorSkewNormal(VectorType).shapeValue`
- `VectorSkewNormal(VectorType).shapeParameter`
- `VectorSkewNormal(VectorType).expectedValue`
- `VectorSkewNormal(VectorType).varianceValue`
- `VectorSkewNormal(VectorType).minValue`
- `VectorSkewNormal(VectorType).maxValue`
- `VectorSkewNormal(VectorType).sample`
- `VectorSkewNormal(VectorType).sampleFrom`
- `VectorSkewNormal(VectorType).fill`
- `VectorSkewNormal(VectorType).fillFrom`
- `Pert(T)`
- `Pert(T).init`
- `Pert(T).new`
- `Pert(T).initDefault`
- `Pert(T).initRange`
- `Pert(T).initMean`
- `Pert(T).minValue`
- `Pert(T).maxValue`
- `Pert(T).shapeValue`
- `Pert(T).modeValue`
- `Pert(T).alphaValue`
- `Pert(T).betaValue`
- `Pert(T).expectedValue`
- `Pert(T).varianceValue`
- `PertBuilder(T).minValue`
- `PertBuilder(T).maxValue`
- `PertBuilder(T).shapeValue`
- `PertBuilder(T).withShape`
- `PertBuilder(T).withMode`
- `PertBuilder(T).withMean`
- `Pert(T).sample`
- `Pert(T).sampleFrom`
- `Pert(T).fill`
- `Pert(T).fillFrom`
- `VectorPert(VectorType)`
- `VectorPert(VectorType).init`
- `VectorPert(VectorType).initDefault`
- `VectorPert(VectorType).initMean`
- `VectorPert(VectorType).minValue`
- `VectorPert(VectorType).maxValue`
- `VectorPert(VectorType).shapeValue`
- `VectorPert(VectorType).modeValue`
- `VectorPert(VectorType).alphaValue`
- `VectorPert(VectorType).betaValue`
- `VectorPert(VectorType).expectedValue`
- `VectorPert(VectorType).varianceValue`
- `VectorPert(VectorType).sample`
- `VectorPert(VectorType).sampleFrom`
- `VectorPert(VectorType).fill`
- `VectorPert(VectorType).fillFrom`
- `InverseGaussian(T)`
- `InverseGaussian(T).init`
- `InverseGaussian(T).new`
- `InverseGaussian(T).meanValue`
- `InverseGaussian(T).shapeValue`
- `InverseGaussian(T).expectedValue`
- `InverseGaussian(T).varianceValue`
- `InverseGaussian(T).minValue`
- `InverseGaussian(T).maxValue`
- `InverseGaussian(T).sample`
- `InverseGaussian(T).sampleFrom`
- `InverseGaussian(T).fill`
- `InverseGaussian(T).fillFrom`
- `VectorInverseGaussian(VectorType)`
- `VectorInverseGaussian(VectorType).init`
- `VectorInverseGaussian(VectorType).meanValue`
- `VectorInverseGaussian(VectorType).shapeValue`
- `VectorInverseGaussian(VectorType).expectedValue`
- `VectorInverseGaussian(VectorType).varianceValue`
- `VectorInverseGaussian(VectorType).minValue`
- `VectorInverseGaussian(VectorType).maxValue`
- `VectorInverseGaussian(VectorType).sample`
- `VectorInverseGaussian(VectorType).sampleFrom`
- `VectorInverseGaussian(VectorType).fill`
- `VectorInverseGaussian(VectorType).fillFrom`
- `NormalInverseGaussian(T)`
- `NormalInverseGaussian(T).init`
- `NormalInverseGaussian(T).new`
- `NormalInverseGaussian(T).alphaValue`
- `NormalInverseGaussian(T).betaValue`
- `NormalInverseGaussian(T).gammaValue`
- `NormalInverseGaussian(T).expectedValue`
- `NormalInverseGaussian(T).varianceValue`
- `NormalInverseGaussian(T).minValue`
- `NormalInverseGaussian(T).maxValue`
- `NormalInverseGaussian(T).sample`
- `NormalInverseGaussian(T).sampleFrom`
- `NormalInverseGaussian(T).fill`
- `NormalInverseGaussian(T).fillFrom`
- `VectorNormalInverseGaussian(VectorType)`
- `VectorNormalInverseGaussian(VectorType).init`
- `VectorNormalInverseGaussian(VectorType).alphaValue`
- `VectorNormalInverseGaussian(VectorType).betaValue`
- `VectorNormalInverseGaussian(VectorType).gammaValue`
- `VectorNormalInverseGaussian(VectorType).expectedValue`
- `VectorNormalInverseGaussian(VectorType).varianceValue`
- `VectorNormalInverseGaussian(VectorType).minValue`
- `VectorNormalInverseGaussian(VectorType).maxValue`
- `VectorNormalInverseGaussian(VectorType).sample`
- `VectorNormalInverseGaussian(VectorType).sampleFrom`
- `VectorNormalInverseGaussian(VectorType).fill`
- `VectorNormalInverseGaussian(VectorType).fillFrom`
- `Zipf(T)`
- `Zipf(T).init`
- `Zipf(T).new`
- `Zipf(T).nValue`
- `Zipf(T).minValue`
- `Zipf(T).maxValue`
- `Zipf(T).exponentValue`
- `Zipf(T).sample`
- `Zipf(T).sampleFrom`
- `Zipf(T).fill`
- `Zipf(T).fillFrom`
- `VectorZipf(VectorType)`
- `VectorZipf(VectorType).init`
- `VectorZipf(VectorType).nValue`
- `VectorZipf(VectorType).minValue`
- `VectorZipf(VectorType).maxValue`
- `VectorZipf(VectorType).exponentValue`
- `VectorZipf(VectorType).sample`
- `VectorZipf(VectorType).sampleFrom`
- `VectorZipf(VectorType).fill`
- `VectorZipf(VectorType).fillFrom`
- `Zeta(T)`
- `Zeta(T).init`
- `Zeta(T).new`
- `Zeta(T).exponentValue`
- `Zeta(T).minValue`
- `Zeta(T).maxValue`
- `Zeta(T).sample`
- `Zeta(T).sampleFrom`
- `Zeta(T).fill`
- `Zeta(T).fillFrom`
- `VectorZeta(VectorType)`
- `VectorZeta(VectorType).init`
- `VectorZeta(VectorType).exponentValue`
- `VectorZeta(VectorType).minValue`
- `VectorZeta(VectorType).maxValue`
- `VectorZeta(VectorType).sample`
- `VectorZeta(VectorType).sampleFrom`
- `VectorZeta(VectorType).fill`
- `VectorZeta(VectorType).fillFrom`
- `UnitCircle(T)`
- `UnitCircle(T).dimensionValue`
- `UnitCircle(T).radiusValue`
- `UnitCircle(T).isSurface`
- `UnitCircle(T).coordinateExpectedValue`
- `UnitCircle(T).coordinateVarianceValue`
- `UnitCircle(T).radialExpectedValue`
- `UnitCircle(T).radialVarianceValue`
- `UnitCircle(T).sample`
- `UnitCircle(T).sampleFrom`
- `UnitCircle(T).fill`
- `UnitCircle(T).fillFrom`
- `VectorUnitCircle(VectorType)`
- `VectorUnitCircle(VectorType).dimensionValue`
- `VectorUnitCircle(VectorType).radiusValue`
- `VectorUnitCircle(VectorType).isSurface`
- `VectorUnitCircle(VectorType).coordinateExpectedValue`
- `VectorUnitCircle(VectorType).coordinateVarianceValue`
- `VectorUnitCircle(VectorType).radialExpectedValue`
- `VectorUnitCircle(VectorType).radialVarianceValue`
- `VectorUnitCircle(VectorType).sample`
- `VectorUnitCircle(VectorType).sampleFrom`
- `VectorUnitCircle(VectorType).fill`
- `VectorUnitCircle(VectorType).fillFrom`
- `VectorUnitDisc(VectorType)`
- `VectorUnitDisc(VectorType).dimensionValue`
- `VectorUnitDisc(VectorType).radiusValue`
- `VectorUnitDisc(VectorType).isSurface`
- `VectorUnitDisc(VectorType).coordinateExpectedValue`
- `VectorUnitDisc(VectorType).coordinateVarianceValue`
- `VectorUnitDisc(VectorType).radialExpectedValue`
- `VectorUnitDisc(VectorType).radialVarianceValue`
- `VectorUnitDisc(VectorType).sample`
- `VectorUnitDisc(VectorType).sampleFrom`
- `VectorUnitDisc(VectorType).fill`
- `VectorUnitDisc(VectorType).fillFrom`
- `UnitDisc(T)`
- `UnitDisc(T).dimensionValue`
- `UnitDisc(T).radiusValue`
- `UnitDisc(T).isSurface`
- `UnitDisc(T).coordinateExpectedValue`
- `UnitDisc(T).coordinateVarianceValue`
- `UnitDisc(T).radialExpectedValue`
- `UnitDisc(T).radialVarianceValue`
- `UnitDisc(T).sample`
- `UnitDisc(T).sampleFrom`
- `UnitDisc(T).fill`
- `UnitDisc(T).fillFrom`
- `UnitSphere(T)`
- `UnitSphere(T).dimensionValue`
- `UnitSphere(T).radiusValue`
- `UnitSphere(T).isSurface`
- `UnitSphere(T).coordinateExpectedValue`
- `UnitSphere(T).coordinateVarianceValue`
- `UnitSphere(T).radialExpectedValue`
- `UnitSphere(T).radialVarianceValue`
- `UnitSphere(T).sample`
- `UnitSphere(T).sampleFrom`
- `UnitSphere(T).fill`
- `UnitSphere(T).fillFrom`
- `VectorUnitSphere(VectorType)`
- `VectorUnitSphere(VectorType).dimensionValue`
- `VectorUnitSphere(VectorType).radiusValue`
- `VectorUnitSphere(VectorType).isSurface`
- `VectorUnitSphere(VectorType).coordinateExpectedValue`
- `VectorUnitSphere(VectorType).coordinateVarianceValue`
- `VectorUnitSphere(VectorType).radialExpectedValue`
- `VectorUnitSphere(VectorType).radialVarianceValue`
- `VectorUnitSphere(VectorType).sample`
- `VectorUnitSphere(VectorType).sampleFrom`
- `VectorUnitSphere(VectorType).fill`
- `VectorUnitSphere(VectorType).fillFrom`
- `UnitBall(T)`
- `UnitBall(T).dimensionValue`
- `UnitBall(T).radiusValue`
- `UnitBall(T).isSurface`
- `UnitBall(T).coordinateExpectedValue`
- `UnitBall(T).coordinateVarianceValue`
- `UnitBall(T).radialExpectedValue`
- `UnitBall(T).radialVarianceValue`
- `UnitBall(T).sample`
- `UnitBall(T).sampleFrom`
- `UnitBall(T).fill`
- `UnitBall(T).fillFrom`
- `VectorUnitBall(VectorType)`
- `VectorUnitBall(VectorType).dimensionValue`
- `VectorUnitBall(VectorType).radiusValue`
- `VectorUnitBall(VectorType).isSurface`
- `VectorUnitBall(VectorType).coordinateExpectedValue`
- `VectorUnitBall(VectorType).coordinateVarianceValue`
- `VectorUnitBall(VectorType).radialExpectedValue`
- `VectorUnitBall(VectorType).radialVarianceValue`
- `VectorUnitBall(VectorType).sample`
- `VectorUnitBall(VectorType).sampleFrom`
- `VectorUnitBall(VectorType).fill`
- `VectorUnitBall(VectorType).fillFrom`
- `Dirichlet(T)`
- `multi`
- `multi.Dirichlet(T)`
- `Dirichlet(T).init`
- `Dirichlet(T).new`
- `Dirichlet(T).alphaValues`
- `Dirichlet(T).alphaAt`
- `Dirichlet(T).meanAt`
- `Dirichlet(T).means`
- `Dirichlet(T).meansInto`
- `Dirichlet(T).varianceAt`
- `Dirichlet(T).variances`
- `Dirichlet(T).variancesInto`
- `Dirichlet(T).covarianceAt`
- `Dirichlet(T).covariances`
- `Dirichlet(T).covariancesInto`
- `Dirichlet(T).dimensionValue`
- `Dirichlet(T).totalAlphaValue`
- `Dirichlet(T).sample`
- `Dirichlet(T).sampleFrom`
- `Dirichlet(T).sampleInto`
- `Dirichlet(T).sampleIntoFrom`
- `Dirichlet(T).sampleIntoChecked`
- `Dirichlet(T).sampleIntoCheckedFrom`
- `Dirichlet(T).sampleManyInto`
- `Dirichlet(T).sampleManyIntoFrom`
- `Dirichlet(T).sampleManyIntoChecked`
- `Dirichlet(T).sampleManyIntoCheckedFrom`
- `AliasTable(Weight)`
- `WeightedTree(Weight)`
- `WeightedIntTree(Weight)`

Alias helpers:

- `aliasTable(T)`
- `WeightedIndex(Weight)`
- `weighted`
- `weighted.Error`
- `weighted.WeightedError`
- `weighted.WeightError`
- `weighted.WeightedIndex(Weight)`
- `AliasTable.init`
- `AliasTable.new`
- `AliasTable.initByIndex`
- `AliasTable.initBy`
- `AliasTable.update`
- `AliasTable.Update`
- `AliasTable.updateMany`
- `AliasTable.updateWeights`
- `AliasTable.updateAt`
- `AliasTable.updateByIndex`
- `AliasTable.updateBy`
- `AliasTable.len`
- `AliasTable.numChoices`
- `AliasTable.isEmpty`
- `AliasTable.totalWeight`
- `AliasTable.positiveCount`
- `AliasTable.weights`
- `AliasTable.weightsInto`
- `AliasTable.probabilities`
- `AliasTable.probabilitiesInto`
- `AliasTable.weightAt`
- `AliasTable.weight`
- `AliasTable.weightIter`
- `AliasTable.WeightIterator`
- `AliasTable.WeightIterator.next`
- `AliasTable.WeightIterator.remaining`
- `AliasTable.WeightIterator.len`
- `AliasTable.WeightIterator.sizeHint`
- `AliasTable.WeightIterator.fill`
- `AliasTable.probabilityAt`
- `AliasTable.probability`
- `AliasTable.probabilityIter`
- `AliasTable.ProbabilityIterator`
- `AliasTable.ProbabilityIterator.next`
- `AliasTable.ProbabilityIterator.remaining`
- `AliasTable.ProbabilityIterator.len`
- `AliasTable.ProbabilityIterator.sizeHint`
- `AliasTable.ProbabilityIterator.fill`
- `AliasTable.constantIndex`
- `AliasTable.sample`
- `AliasTable.sampleIndex`
- `AliasTable.sampleU32`
- `AliasTable.sampleIndexU32`
- `AliasTable.sampleU32Checked`
- `AliasTable.sampleIndexU32Checked`
- `AliasTable.sampleFrom`
- `AliasTable.sampleIndexFrom`
- `AliasTable.sampleU32From`
- `AliasTable.sampleIndexU32From`
- `AliasTable.sampleU32CheckedFrom`
- `AliasTable.sampleIndexU32CheckedFrom`
- `AliasTable.fill`
- `AliasTable.fillIndices`
- `AliasTable.fillU32`
- `AliasTable.fillIndicesU32`
- `AliasTable.fillU32Checked`
- `AliasTable.fillIndicesU32Checked`
- `AliasTable.fillFrom`
- `AliasTable.fillIndicesFrom`
- `AliasTable.fillU32From`
- `AliasTable.fillIndicesU32From`
- `AliasTable.fillU32CheckedFrom`
- `AliasTable.fillIndicesU32CheckedFrom`
- `AliasTable.indices`
- `AliasTable.indicesFrom`
- `AliasTable.indicesU32`
- `AliasTable.indicesU32From`
- `AliasTable.indexArray`
- `AliasTable.indexArrayFrom`
- `AliasTable.indexArrayU32`
- `AliasTable.indexArrayU32Checked`
- `AliasTable.indexArrayU32From`
- `AliasTable.indexArrayU32CheckedFrom`
- `AliasTable.iter`
- `AliasTable.iterFrom`
- `AliasTable.iterU32`
- `AliasTable.iterU32From`
- `AliasTable.U32IndexIterator`
- `AliasTable.U32IndexIterator.next`
- `AliasTable.U32IndexIterator.nextValue`
- `AliasTable.U32IndexIterator.fill`
- `AliasTable.deinit`

Dynamic weighted helpers:

- `WeightedTree.init`
- `WeightedTree.initByIndex`
- `WeightedTree.initBy`
- `WeightedTree.len`
- `WeightedTree.numChoices`
- `WeightedTree.isEmpty`
- `WeightedTree.push`
- `WeightedTree.pop`
- `WeightedTree.update`
- `WeightedTree.Update`
- `WeightedTree.updateMany`
- `WeightedTree.updateWeights`
- `WeightedTree.updateAll`
- `WeightedTree.updateAllByIndex`
- `WeightedTree.updateAllBy`
- `WeightedTree.get`
- `WeightedTree.positiveCount`
- `WeightedTree.constantIndex`
- `WeightedTree.weightAt`
- `WeightedTree.weight`
- `WeightedTree.weightIter`
- `WeightedTree.WeightIterator`
- `WeightedTree.WeightIterator.next`
- `WeightedTree.WeightIterator.remaining`
- `WeightedTree.WeightIterator.len`
- `WeightedTree.WeightIterator.sizeHint`
- `WeightedTree.WeightIterator.fill`
- `WeightedTree.probabilityAt`
- `WeightedTree.probability`
- `WeightedTree.probabilityIter`
- `WeightedTree.ProbabilityIterator`
- `WeightedTree.ProbabilityIterator.next`
- `WeightedTree.ProbabilityIterator.remaining`
- `WeightedTree.ProbabilityIterator.len`
- `WeightedTree.ProbabilityIterator.sizeHint`
- `WeightedTree.ProbabilityIterator.fill`
- `WeightedTree.sample`
- `WeightedTree.sampleIndex`
- `WeightedTree.sampleU32`
- `WeightedTree.sampleIndexU32`
- `WeightedTree.sampleChecked`
- `WeightedTree.sampleIndexChecked`
- `WeightedTree.sampleU32Checked`
- `WeightedTree.sampleIndexU32Checked`
- `WeightedTree.sampleFrom`
- `WeightedTree.sampleIndexFrom`
- `WeightedTree.sampleU32From`
- `WeightedTree.sampleIndexU32From`
- `WeightedTree.sampleCheckedFrom`
- `WeightedTree.sampleIndexCheckedFrom`
- `WeightedTree.sampleU32CheckedFrom`
- `WeightedTree.sampleIndexU32CheckedFrom`
- `WeightedTree.fill`
- `WeightedTree.fillIndices`
- `WeightedTree.fillU32`
- `WeightedTree.fillIndicesU32`
- `WeightedTree.fillChecked`
- `WeightedTree.fillIndicesChecked`
- `WeightedTree.fillU32Checked`
- `WeightedTree.fillIndicesU32Checked`
- `WeightedTree.fillFrom`
- `WeightedTree.fillIndicesFrom`
- `WeightedTree.fillU32From`
- `WeightedTree.fillIndicesU32From`
- `WeightedTree.fillCheckedFrom`
- `WeightedTree.fillIndicesCheckedFrom`
- `WeightedTree.fillU32CheckedFrom`
- `WeightedTree.fillIndicesU32CheckedFrom`
- `WeightedTree.indices`
- `WeightedTree.indicesFrom`
- `WeightedTree.indicesChecked`
- `WeightedTree.indicesCheckedFrom`
- `WeightedTree.indicesU32`
- `WeightedTree.indicesU32From`
- `WeightedTree.indicesU32Checked`
- `WeightedTree.indicesU32CheckedFrom`
- `WeightedTree.indexArray`
- `WeightedTree.indexArrayFrom`
- `WeightedTree.indexArrayChecked`
- `WeightedTree.indexArrayCheckedFrom`
- `WeightedTree.indexArrayU32`
- `WeightedTree.indexArrayU32Checked`
- `WeightedTree.indexArrayU32From`
- `WeightedTree.indexArrayU32CheckedFrom`
- `WeightedTree.iter`
- `WeightedTree.iterFrom`
- `WeightedTree.iterU32`
- `WeightedTree.iterU32From`
- `WeightedTree.U32IndexIterator`
- `WeightedTree.U32IndexIterator.next`
- `WeightedTree.U32IndexIterator.nextValue`
- `WeightedTree.U32IndexIterator.fill`
- `WeightedTree.totalWeight`
- `WeightedTree.weights`
- `WeightedTree.weightsInto`
- `WeightedTree.probabilities`
- `WeightedTree.probabilitiesInto`
- `WeightedTree.isValid`
- `WeightedTree.deinit`
- Prefer `WeightedIntTree` when weights are unsigned integers and frequent
  update/push/pop/sample throughput is the priority.
- `WeightedIntTree.init`
- `WeightedIntTree.initByIndex`
- `WeightedIntTree.initBy`
- `WeightedIntTree.len`
- `WeightedIntTree.numChoices`
- `WeightedIntTree.isEmpty`
- `WeightedIntTree.push`
- `WeightedIntTree.pop`
- `WeightedIntTree.update`
- `WeightedIntTree.Update`
- `WeightedIntTree.updateMany`
- `WeightedIntTree.updateWeights`
- `WeightedIntTree.updateAll`
- `WeightedIntTree.updateAllByIndex`
- `WeightedIntTree.updateAllBy`
- `WeightedIntTree.get`
- `WeightedIntTree.positiveCount`
- `WeightedIntTree.constantIndex`
- `WeightedIntTree.weightAt`
- `WeightedIntTree.weight`
- `WeightedIntTree.weightIter`
- `WeightedIntTree.WeightIterator`
- `WeightedIntTree.WeightIterator.next`
- `WeightedIntTree.WeightIterator.remaining`
- `WeightedIntTree.WeightIterator.len`
- `WeightedIntTree.WeightIterator.sizeHint`
- `WeightedIntTree.WeightIterator.fill`
- `WeightedIntTree.probabilityAt`
- `WeightedIntTree.probability`
- `WeightedIntTree.probabilityIter`
- `WeightedIntTree.ProbabilityIterator`
- `WeightedIntTree.ProbabilityIterator.next`
- `WeightedIntTree.ProbabilityIterator.remaining`
- `WeightedIntTree.ProbabilityIterator.len`
- `WeightedIntTree.ProbabilityIterator.sizeHint`
- `WeightedIntTree.ProbabilityIterator.fill`
- `WeightedIntTree.sample`
- `WeightedIntTree.sampleIndex`
- `WeightedIntTree.sampleU32`
- `WeightedIntTree.sampleIndexU32`
- `WeightedIntTree.sampleChecked`
- `WeightedIntTree.sampleIndexChecked`
- `WeightedIntTree.sampleU32Checked`
- `WeightedIntTree.sampleIndexU32Checked`
- `WeightedIntTree.sampleFrom`
- `WeightedIntTree.sampleIndexFrom`
- `WeightedIntTree.sampleU32From`
- `WeightedIntTree.sampleIndexU32From`
- `WeightedIntTree.sampleCheckedFrom`
- `WeightedIntTree.sampleIndexCheckedFrom`
- `WeightedIntTree.sampleU32CheckedFrom`
- `WeightedIntTree.sampleIndexU32CheckedFrom`
- `WeightedIntTree.fill`
- `WeightedIntTree.fillIndices`
- `WeightedIntTree.fillU32`
- `WeightedIntTree.fillIndicesU32`
- `WeightedIntTree.fillChecked`
- `WeightedIntTree.fillIndicesChecked`
- `WeightedIntTree.fillU32Checked`
- `WeightedIntTree.fillIndicesU32Checked`
- `WeightedIntTree.fillFrom`
- `WeightedIntTree.fillIndicesFrom`
- `WeightedIntTree.fillU32From`
- `WeightedIntTree.fillIndicesU32From`
- `WeightedIntTree.fillCheckedFrom`
- `WeightedIntTree.fillIndicesCheckedFrom`
- `WeightedIntTree.fillU32CheckedFrom`
- `WeightedIntTree.fillIndicesU32CheckedFrom`
- `WeightedIntTree.indices`
- `WeightedIntTree.indicesFrom`
- `WeightedIntTree.indicesChecked`
- `WeightedIntTree.indicesCheckedFrom`
- `WeightedIntTree.indicesU32`
- `WeightedIntTree.indicesU32From`
- `WeightedIntTree.indicesU32Checked`
- `WeightedIntTree.indicesU32CheckedFrom`
- `WeightedIntTree.indexArray`
- `WeightedIntTree.indexArrayFrom`
- `WeightedIntTree.indexArrayChecked`
- `WeightedIntTree.indexArrayCheckedFrom`
- `WeightedIntTree.indexArrayU32`
- `WeightedIntTree.indexArrayU32Checked`
- `WeightedIntTree.indexArrayU32From`
- `WeightedIntTree.indexArrayU32CheckedFrom`
- `WeightedIntTree.iter`
- `WeightedIntTree.iterFrom`
- `WeightedIntTree.iterU32`
- `WeightedIntTree.iterU32From`
- `WeightedIntTree.U32IndexIterator`
- `WeightedIntTree.U32IndexIterator.next`
- `WeightedIntTree.U32IndexIterator.nextValue`
- `WeightedIntTree.U32IndexIterator.fill`
- `WeightedIntTree.totalWeight`
- `WeightedIntTree.weights`
- `WeightedIntTree.weightsInto`
- `WeightedIntTree.probabilities`
- `WeightedIntTree.probabilitiesInto`
- `WeightedIntTree.isValid`
- `WeightedIntTree.deinit`

## Sequence Sampling

- Error aliases: `seq.Error`, `seq.WeightError`; root `WeightError` mirrors
  `seq.WeightError` for local Rust `rand::seq::WeightError` discovery.

- Error type: `Error`; exact-size iterator hint: `SizeHint`
- Index vectors: `IndexVec.fromOwnedSlice`, `IndexVec.fromOwnedU32Slice`,
  `IndexVec.clone`, `IndexVec.len`, `IndexVec.isEmpty`, `IndexVec.at`,
  `IndexVec.index`, `IndexVec.get`, `IndexVec.indexOf`, `IndexVec.contains`, `IndexVec.eql`, `IndexVec.validateItems`,
  `IndexVec.validateDistinctItems`, `IndexVec.copyInto`,
  `IndexVec.copyIntoU32`, `IndexVec.toOwnedSlice`,
  `IndexVec.toOwnedU32Slice`, `IndexVec.intoVec`,
  `IndexVec.intoOwnedSlice`, `IndexVec.intoOwnedU32Slice`, `IndexVec.values`, `IndexVec.valuesChecked`,
  `IndexVec.valuesInto`, `IndexVec.valuesIntoChecked`,
  `IndexVec.valuesOwned`, `IndexVec.valuesOwnedChecked`, `IndexVec.ptrs`,
  `IndexVec.ptrsChecked`, `IndexVec.ptrsInto`, `IndexVec.ptrsIntoChecked`,
  `IndexVec.ptrsOwned`, `IndexVec.ptrsOwnedChecked`, `IndexVec.mutPtrs`,
  `IndexVec.mutPtrsChecked`, `IndexVec.mutPtrsInto`,
  `IndexVec.mutPtrsIntoChecked`, `IndexVec.mutPtrsOwned`,
  `IndexVec.mutPtrsOwnedChecked`,
  `IndexVec.intoIter`, `IndexVec.IntoIterator.next`,
  `IndexVec.IntoIterator.remaining`, `IndexVec.IntoIterator.len`,
  `IndexVec.IntoIterator.sizeHint`, `IndexVec.IntoIterator.fill`,
  `IndexVec.IntoIterator.deinit`,
  `IndexVec.iter`, `IndexVec.Iterator.next`, `IndexVec.Iterator.remaining`,
  `IndexVec.Iterator.len`, `IndexVec.Iterator.sizeHint`,
  `IndexVec.Iterator.fill`,
  `IndexVec.ValueIterator.next`, `IndexVec.ValueIterator.remaining`,
  `IndexVec.ValueIterator.len`, `IndexVec.ValueIterator.sizeHint`,
  `IndexVec.ValueIterator.fill`,
  `PtrIterator`, `PtrIterator.next`, `PtrIterator.remaining`,
  `PtrIterator.len`, `PtrIterator.sizeHint`, `PtrIterator.fill`,
  `MutPtrIterator`, `MutPtrIterator.next`, `MutPtrIterator.remaining`,
  `MutPtrIterator.len`, `MutPtrIterator.sizeHint`, `MutPtrIterator.fill`,
  `IndexVec.deinit`
- Indices: `sampleIndexVec`, `sampleIndexVecFrom`, `sampleIndices`,
  `sampleIndexVecCheckedFrom`, `sampleIndicesFrom`, `sampleIndicesCheckedFrom`,
  `sampleIndicesInto`, `sampleIndicesIntoFrom`, `sampleIndicesIntoChecked`,
  `sampleIndicesIntoCheckedFrom`,
  `sampleIndicesU32`, `sampleIndicesU32From`, `sampleIndicesU32CheckedFrom`,
  `sampleIndicesU32Into`, `sampleIndicesU32IntoFrom`,
  `sampleIndicesU32IntoChecked`, `sampleIndicesU32IntoCheckedFrom`,
  `sampleArray`, `sampleArrayFrom`, `sampleArrayChecked`,
  `sampleArrayCheckedFrom`, `sampleArrayU32`, `sampleArrayU32From`,
  `sampleArrayU32Checked`, `sampleArrayU32CheckedFrom`,
  `chooseIndex`, `chooseIndexFrom`, `chooseIndexChecked`,
  `chooseIndexCheckedFrom`, `chooseIndexArray`, `chooseIndexArrayFrom`,
  `chooseIndexArrayChecked`, `chooseIndexArrayCheckedFrom`,
  `fillChooseIndex`, `fillChooseIndexFrom`,
  `fillChooseIndexChecked`, `fillChooseIndexCheckedFrom`,
  `chooseIndexBatch`, `chooseIndexBatchFrom`, `chooseIndexBatchChecked`,
  `chooseIndexBatchCheckedFrom`, `chooseIndexU32`, `chooseIndexU32From`,
  `chooseIndexU32Checked`, `chooseIndexU32CheckedFrom`,
  `chooseIndexArrayU32`, `chooseIndexArrayU32From`,
  `chooseIndexArrayU32Checked`, `chooseIndexArrayU32CheckedFrom`,
  `fillChooseIndexU32`, `fillChooseIndexU32From`,
  `fillChooseIndexU32Checked`, `fillChooseIndexU32CheckedFrom`,
  `chooseIndexU32Batch`, `chooseIndexU32BatchFrom`,
  `chooseIndexU32BatchChecked`, `chooseIndexU32BatchCheckedFrom`
- Collections: `chooseMultiple`, `chooseMultipleFrom`,
  `choose`, `chooseFrom`, `chooseChecked`, `chooseCheckedFrom`,
  `chooseConstPtr`, `chooseConstPtrFrom`, `chooseConstPtrChecked`,
  `chooseConstPtrCheckedFrom`, `choosePtr`, `choosePtrFrom`,
  `choosePtrChecked`, `choosePtrCheckedFrom`, `choosePtrArray`,
  `choosePtrArrayFrom`, `choosePtrArrayChecked`,
  `choosePtrArrayCheckedFrom`,
  `chooseRepeatedValueArray`, `chooseRepeatedValueArrayFrom`,
  `chooseRepeatedValueArrayChecked`, `chooseRepeatedValueArrayCheckedFrom`,
  `chooseRepeatedConstPtrArray`, `chooseRepeatedConstPtrArrayFrom`,
  `chooseRepeatedConstPtrArrayChecked`,
  `chooseRepeatedConstPtrArrayCheckedFrom`, `chooseRepeatedPtrArray`,
  `chooseRepeatedPtrArrayFrom`, `chooseRepeatedPtrArrayChecked`,
  `chooseRepeatedPtrArrayCheckedFrom`,
  `fillChoose`, `fillChooseFrom`, `fillChooseChecked`,
  `fillChooseCheckedFrom`, `fillChooseConstPtr`, `fillChooseConstPtrFrom`,
  `fillChooseConstPtrChecked`, `fillChooseConstPtrCheckedFrom`,
  `fillChoosePtr`, `fillChoosePtrFrom`, `fillChoosePtrChecked`,
  `fillChoosePtrCheckedFrom`,
  `chooseBatch`, `chooseBatchFrom`, `chooseBatchChecked`,
  `chooseBatchCheckedFrom`, `chooseConstPtrBatch`,
  `chooseConstPtrBatchFrom`, `chooseConstPtrBatchChecked`,
  `chooseConstPtrBatchCheckedFrom`, `choosePtrBatch`, `choosePtrBatchFrom`,
  `choosePtrBatchChecked`, `choosePtrBatchCheckedFrom`,
  `chooseMultipleChecked`, `chooseMultipleCheckedFrom`,
  `sampleItems`, `sampleItemsFrom`, `sampleItemsChecked`,
  `sampleItemsCheckedFrom`, `sampleItemsIter`, `sampleItemsIterFrom`,
  `sampleItemsIterChecked`, `sampleItemsIterCheckedFrom`,
  `SampledValueIterator`, `SampledValueIterator.next`,
  `SampledValueIterator.remaining`, `SampledValueIterator.len`,
  `SampledValueIterator.sizeHint`, `SampledValueIterator.fill`,
  `SampledValueIterator.deinit`,
  `chooseMultiplePtrs`, `chooseMultiplePtrsFrom`,
  `chooseMultiplePtrsChecked`, `chooseMultiplePtrsCheckedFrom`,
  `samplePtrs`, `samplePtrsFrom`, `samplePtrsChecked`,
  `samplePtrsCheckedFrom`, `samplePtrsIter`, `samplePtrsIterFrom`,
  `samplePtrsIterChecked`, `samplePtrsIterCheckedFrom`,
  `IndexedSamples`, `SliceChooseIter`,
  `SampledPtrIterator`, `SampledPtrIterator.next`,
  `SampledPtrIterator.remaining`, `SampledPtrIterator.len`,
  `SampledPtrIterator.sizeHint`, `SampledPtrIterator.fill`,
  `SampledPtrIterator.deinit`,
  `chooseMultipleMutPtrs`, `chooseMultipleMutPtrsFrom`,
  `chooseMultipleMutPtrsChecked`, `chooseMultipleMutPtrsCheckedFrom`,
  `sampleMutPtrs`, `sampleMutPtrsFrom`, `sampleMutPtrsChecked`,
  `sampleMutPtrsCheckedFrom`, `sampleMutPtrsIter`, `sampleMutPtrsIterFrom`,
  `sampleMutPtrsIterChecked`, `sampleMutPtrsIterCheckedFrom`,
  `SampledMutPtrIterator`, `SampledMutPtrIterator.next`,
  `SampledMutPtrIterator.remaining`, `SampledMutPtrIterator.len`,
  `SampledMutPtrIterator.sizeHint`, `SampledMutPtrIterator.fill`,
  `SampledMutPtrIterator.deinit`, `chooseMultipleInto`,
  `chooseMultipleIntoFrom`, `chooseMultipleIntoChecked`,
  `chooseMultipleIntoCheckedFrom`, `sampleItemsInto`,
  `sampleItemsIntoFrom`, `sampleItemsIntoChecked`,
  `sampleItemsIntoCheckedFrom`, `chooseMultiplePtrsInto`,
  `chooseMultiplePtrsIntoFrom`, `chooseMultiplePtrsIntoChecked`,
  `chooseMultiplePtrsIntoCheckedFrom`, `samplePtrsInto`,
  `samplePtrsIntoFrom`, `samplePtrsIntoChecked`,
  `samplePtrsIntoCheckedFrom`, `chooseMultipleMutPtrsInto`,
  `chooseMultipleMutPtrsIntoFrom`, `chooseMultipleMutPtrsIntoChecked`,
  `chooseMultipleMutPtrsIntoCheckedFrom`, `sampleMutPtrsInto`,
  `sampleMutPtrsIntoFrom`, `sampleMutPtrsIntoChecked`,
  `sampleMutPtrsIntoCheckedFrom`, `chooseArray`,
  `chooseArrayFrom`, `chooseArrayChecked`, `chooseArrayCheckedFrom`,
  `sampleItemsArray`, `sampleItemsArrayFrom`, `sampleItemsArrayChecked`,
  `sampleItemsArrayCheckedFrom`,
  `choosePtrArray`, `choosePtrArrayFrom`, `choosePtrArrayChecked`,
  `choosePtrArrayCheckedFrom`, `samplePtrArray`, `samplePtrArrayFrom`,
  `samplePtrArrayChecked`, `samplePtrArrayCheckedFrom`, `chooseMutPtrArray`,
  `chooseMutPtrArrayFrom`, `chooseMutPtrArrayChecked`,
  `chooseMutPtrArrayCheckedFrom`, `sampleMutPtrArray`,
  `sampleMutPtrArrayFrom`, `sampleMutPtrArrayChecked`,
  `sampleMutPtrArrayCheckedFrom`, `shuffle`, `shuffleFrom`, `partialShuffle`,
  `partialShuffleFrom`, `partialShuffleChecked`, `partialShuffleCheckedFrom`,
  `PartialShuffleSplit(T)`, `partialShuffleSplit`, `partialShuffleSplitFrom`,
  `partialShuffleSplitChecked`, `partialShuffleSplitCheckedFrom`,
  `PartialShuffleTailSplit(T)`, `partialShuffleTail`,
  `partialShuffleTailFrom`, `partialShuffleTailChecked`,
  `partialShuffleTailCheckedFrom`, `partialShuffleTailSplit`,
  `partialShuffleTailSplitFrom`, `partialShuffleTailSplitChecked`,
  `partialShuffleTailSplitCheckedFrom`,
  `reservoirSample`, `reservoirSampleFrom`, `reservoirSampleChecked`,
  `reservoirSampleCheckedFrom`, `reservoirSamplePtrs`,
  `reservoirSamplePtrsFrom`, `reservoirSamplePtrsChecked`,
  `reservoirSamplePtrsCheckedFrom`, `reservoirSampleMutPtrs`,
  `reservoirSampleMutPtrsFrom`, `reservoirSampleMutPtrsChecked`,
  `reservoirSampleMutPtrsCheckedFrom`, `reservoirSampleInto`,
  `reservoirSampleIntoFrom`, `reservoirSamplePtrsInto`,
  `reservoirSamplePtrsIntoFrom`, `reservoirSampleMutPtrsInto`,
  `reservoirSampleMutPtrsIntoFrom`
- Iterators: `chooseIterator`, `chooseIteratorFrom`, `chooseIteratorChecked`,
  `chooseIteratorCheckedFrom`, `chooseIteratorHinted`,
  `chooseIteratorHintedFrom`, `chooseIteratorHintedChecked`,
  `chooseIteratorHintedCheckedFrom`, `chooseIteratorStable`,
  `chooseIteratorStableFrom`, `chooseIteratorStableChecked`,
  `chooseIteratorStableCheckedFrom`, `sampleIterator`, `sampleIteratorFrom`,
  `sampleIteratorChecked`, `sampleIteratorCheckedFrom`, `sampleIteratorArray`,
  `sampleIteratorArrayFrom`, `sampleIteratorArrayChecked`,
  `sampleIteratorArrayCheckedFrom`, `sampleIteratorInto`,
  `sampleIteratorIntoFrom`, `sampleIteratorIntoChecked`,
  `sampleIteratorIntoCheckedFrom`, `sampleIteratorFill`,
  `sampleIteratorFillFrom`, `sampleIteratorFillChecked`,
  `sampleIteratorFillCheckedFrom`, `chooseIteratorWeighted`,
  `chooseIteratorWeightedFrom`, `chooseIteratorWeightedChecked`,
  `chooseIteratorWeightedCheckedFrom`, `sampleIteratorWeighted`,
  `sampleIteratorWeightedFrom`, `sampleIteratorWeightedChecked`,
  `sampleIteratorWeightedCheckedFrom`, `sampleIteratorWeightedArray`,
  `sampleIteratorWeightedArrayFrom`, `sampleIteratorWeightedArrayChecked`,
  `sampleIteratorWeightedArrayCheckedFrom`, `sampleIteratorWeightedInto`,
  `sampleIteratorWeightedIntoFrom`, `sampleIteratorWeightedIntoChecked`,
  `sampleIteratorWeightedIntoCheckedFrom`
- Reusable samplers: `Choice(T)`, `distributions.Choose(T)`,
  `distributions.slice.Choose(T)`, `distributions.slice.Empty`,
  `Choose(T).init`, `Choose(T).new`, `Choose(T).initChecked`,
  `Choose(T).newChecked`, `Choose(T).len`, `Choose(T).numChoices`,
  `Choose(T).isEmpty`, `Choose(T).itemsValue`, `Choose(T).sample`,
  `Choose(T).sampleFrom`, `Choose(T).sampleValue`,
  `Choose(T).sampleValueFrom`, `Choose(T).fill`, `Choose(T).fillFrom`,
  `Choose(T).fillValues`, `Choose(T).fillValuesFrom`, `Choose(T).iter`,
  `Choose(T).iterFrom`, `chooseIter`, `chooseIterFrom`,
  `chooseIterChecked`, `chooseIterCheckedFrom`,
  `WeightedChoice(T, Weight)`,
  `Choice.init`, `Choice.new`, `Choice.initChecked`, `Choice.newChecked`, `Choice.len`, `Choice.numChoices`,
  `Choice.constantIndex`, `Choice.isEmpty`, `Choice.itemsValue`, `Choice.itemAt`, `Choice.item`, `Choice.get`, `Choice.probabilityAt`,
  `Choice.probability`, `Choice.probabilityIter`, `Choice.ProbabilityIterator`, `Choice.ProbabilityIterator.next`, `Choice.ProbabilityIterator.remaining`, `Choice.ProbabilityIterator.len`, `Choice.ProbabilityIterator.sizeHint`, `Choice.ProbabilityIterator.fill`, `Choice.probabilities`, `Choice.probabilitiesInto`,
  `Choice.sample`,
  `Choice.sampleFrom`, `Choice.sampleIndex`, `Choice.sampleIndexFrom`,
  `Choice.sampleIndexU32`, `Choice.sampleIndexU32From`,
  `Choice.sampleValue`, `Choice.sampleValueFrom`, `Choice.fill`, `Choice.fillFrom`,
  `Choice.fillValues`, `Choice.fillValuesFrom`, `Choice.ptrs`,
  `Choice.ptrsFrom`, `Choice.values`, `Choice.valuesFrom`,
  `Choice.valueArray`, `Choice.valueArrayFrom`,
  `Choice.ptrArray`, `Choice.ptrArrayFrom`, `Choice.fillIndices`,
  `Choice.fillIndicesFrom`, `Choice.fillIndicesU32`,
  `Choice.fillIndicesU32From`, `Choice.indices`, `Choice.indicesFrom`,
  `Choice.indicesU32`, `Choice.indicesU32From`,
  `Choice.indexArray`, `Choice.indexArrayFrom`, `Choice.indexArrayU32`,
  `Choice.indexArrayU32Checked`, `Choice.indexArrayU32From`,
  `Choice.indexArrayU32CheckedFrom`, `Choice.indexIter`,
  `Choice.indexIterFrom`, `Choice.indexIterU32`, `Choice.indexIterU32From`,
  `Choice.IndexIterator`, `Choice.IndexIterator.next`,
  `Choice.IndexIterator.nextValue`, `Choice.IndexIterator.fill`,
  `Choice.U32IndexIterator`, `Choice.U32IndexIterator.next`,
  `Choice.U32IndexIterator.nextValue`, `Choice.U32IndexIterator.fill`,
  `Choice.iter`, `Choice.iterFrom`,
  `WeightedChoice.init`, `WeightedChoice.new`, `WeightedChoice.initBy`,
  `WeightedChoice.initByIndex`, `WeightedChoice.deinit`,
  `WeightedChoice.len`, `WeightedChoice.numChoices`, `WeightedChoice.isEmpty`,
  `WeightedChoice.itemsValue`, `WeightedChoice.itemAt`, `WeightedChoice.item`, `WeightedChoice.get`,
  `WeightedChoice.totalWeight`, `WeightedChoice.positiveCount`, `WeightedChoice.constantIndex`, `WeightedChoice.weights`,
  `WeightedChoice.weightsInto`, `WeightedChoice.probabilities`,
  `WeightedChoice.probabilitiesInto`, `WeightedChoice.weightAt`,
  `WeightedChoice.weight`, `WeightedChoice.weightIter`, `WeightedChoice.probabilityAt`,
  `WeightedChoice.probability`, `WeightedChoice.probabilityIter`,
  `WeightedChoice.update`, `WeightedChoice.Update`, `WeightedChoice.updateMany`, `WeightedChoice.updateWeights`,
  `WeightedChoice.updateAt`, `WeightedChoice.updateBy`, `WeightedChoice.updateByIndex`, `WeightedChoice.sample`,
  `WeightedChoice.sampleFrom`, `WeightedChoice.sampleIndex`,
  `WeightedChoice.sampleIndexFrom`, `WeightedChoice.sampleIndexU32`,
  `WeightedChoice.sampleIndexU32From`,
  `WeightedChoice.sampleValue`, `WeightedChoice.sampleValueFrom`,
  `WeightedChoice.fill`, `WeightedChoice.fillFrom`,
  `WeightedChoice.fillValues`, `WeightedChoice.fillValuesFrom`,
  `WeightedChoice.ptrs`, `WeightedChoice.ptrsFrom`,
  `WeightedChoice.values`, `WeightedChoice.valuesFrom`,
  `WeightedChoice.valueArray`, `WeightedChoice.valueArrayFrom`,
  `WeightedChoice.ptrArray`, `WeightedChoice.ptrArrayFrom`,
  `WeightedChoice.fillIndices`, `WeightedChoice.fillIndicesFrom`,
  `WeightedChoice.fillIndicesU32`, `WeightedChoice.fillIndicesU32From`,
  `WeightedChoice.indices`, `WeightedChoice.indicesFrom`,
  `WeightedChoice.indicesU32`, `WeightedChoice.indicesU32From`,
  `WeightedChoice.indexArray`, `WeightedChoice.indexArrayFrom`,
  `WeightedChoice.indexArrayU32`, `WeightedChoice.indexArrayU32Checked`,
  `WeightedChoice.indexArrayU32From`,
  `WeightedChoice.indexArrayU32CheckedFrom`, `WeightedChoice.indexIter`,
  `WeightedChoice.indexIterFrom`, `WeightedChoice.indexIterU32`,
  `WeightedChoice.indexIterU32From`, `WeightedChoice.IndexIterator`,
  `WeightedChoice.IndexIterator.next`,
  `WeightedChoice.IndexIterator.nextValue`,
  `WeightedChoice.IndexIterator.fill`, `WeightedChoice.U32IndexIterator`,
  `WeightedChoice.U32IndexIterator.next`,
  `WeightedChoice.U32IndexIterator.nextValue`,
  `WeightedChoice.U32IndexIterator.fill`, `WeightedChoice.iter`,
  `WeightedChoice.iterFrom`, `WeightedChoice.ownedIter`,
  `WeightedChoice.ownedIterFrom`, `WeightedChoice.Iterator`,
  `WeightedChoice.Iterator.next`, `WeightedChoice.Iterator.nextValue`,
  `WeightedChoice.Iterator.fill`, `WeightedChoice.Iterator.deinit`
- Weighted one-shot/index batches: `weightedIndex`, `weightedIndexFrom`,
  `fillWeightedIndex`, `fillWeightedIndexFrom`, `fillWeightedIndexChecked`,
  `fillWeightedIndexCheckedFrom`, `weightedIndexBatch`,
  `weightedIndexBatchFrom`, `weightedIndexBatchChecked`,
  `weightedIndexBatchCheckedFrom`, `weightedIndexArray`,
  `weightedIndexArrayFrom`, `weightedIndexArrayChecked`,
  `weightedIndexArrayCheckedFrom`, `weightedIndexChecked`, `weightedIndexCheckedFrom`, `weightedIndexU32`,
  `weightedIndexU32From`, `fillWeightedIndexU32`, `fillWeightedIndexU32From`,
  `fillWeightedIndexU32Checked`, `fillWeightedIndexU32CheckedFrom`,
  `weightedIndexU32Batch`, `weightedIndexU32BatchFrom`,
  `weightedIndexU32BatchChecked`, `weightedIndexU32BatchCheckedFrom`,
  `weightedIndexU32Array`, `weightedIndexU32ArrayFrom`,
  `weightedIndexU32ArrayChecked`, `weightedIndexU32ArrayCheckedFrom`,
  `weightedIndexU32Checked`, `weightedIndexU32CheckedFrom`,
  `weightedIndexByIndex`, `weightedIndexByIndexFrom`,
  `weightedIndexByIndexChecked`, `weightedIndexByIndexCheckedFrom`,
  `weightedIndexU32ByIndex`, `weightedIndexU32ByIndexFrom`,
  `weightedIndexU32ByIndexChecked`, `weightedIndexU32ByIndexCheckedFrom`,
  `weightedIndexArrayByIndex`, `weightedIndexArrayByIndexFrom`,
  `weightedIndexArrayByIndexChecked`,
  `weightedIndexArrayByIndexCheckedFrom`,
  `weightedIndexU32ArrayByIndex`, `weightedIndexU32ArrayByIndexFrom`,
  `weightedIndexU32ArrayByIndexChecked`,
  `weightedIndexU32ArrayByIndexCheckedFrom`,
  `fillWeightedIndexByIndex`, `fillWeightedIndexByIndexFrom`,
  `fillWeightedIndexByIndexChecked`, `fillWeightedIndexByIndexCheckedFrom`,
  `fillWeightedIndexU32ByIndex`, `fillWeightedIndexU32ByIndexFrom`,
  `fillWeightedIndexU32ByIndexChecked`,
  `fillWeightedIndexU32ByIndexCheckedFrom`,
  `weightedIndexBatchByIndex`, `weightedIndexBatchByIndexFrom`,
  `weightedIndexBatchByIndexChecked`,
  `weightedIndexBatchByIndexCheckedFrom`,
  `weightedIndexU32BatchByIndex`, `weightedIndexU32BatchByIndexFrom`,
  `weightedIndexU32BatchByIndexChecked`,
  `weightedIndexU32BatchByIndexCheckedFrom`,
  `chooseWeightedByIndex`, `chooseWeightedByIndexFrom`,
  `chooseWeightedByIndexChecked`, `chooseWeightedByIndexCheckedFrom`,
  `chooseWeightedConstPtrByIndex`, `chooseWeightedConstPtrByIndexFrom`,
  `chooseWeightedConstPtrByIndexChecked`,
  `chooseWeightedConstPtrByIndexCheckedFrom`, `chooseWeightedPtrByIndex`,
  `chooseWeightedPtrByIndexFrom`, `chooseWeightedPtrByIndexChecked`,
  `chooseWeightedPtrByIndexCheckedFrom`,
  `chooseWeightedValueArrayByIndex`, `chooseWeightedValueArrayByIndexFrom`,
  `chooseWeightedValueArrayByIndexChecked`,
  `chooseWeightedValueArrayByIndexCheckedFrom`,
  `chooseWeightedConstPtrArrayByIndex`,
  `chooseWeightedConstPtrArrayByIndexFrom`,
  `chooseWeightedConstPtrArrayByIndexChecked`,
  `chooseWeightedConstPtrArrayByIndexCheckedFrom`,
  `chooseWeightedPtrArrayByIndex`, `chooseWeightedPtrArrayByIndexFrom`,
  `chooseWeightedPtrArrayByIndexChecked`,
  `chooseWeightedPtrArrayByIndexCheckedFrom`,
  `fillChooseWeightedByIndex`, `fillChooseWeightedByIndexFrom`,
  `fillChooseWeightedByIndexChecked`,
  `fillChooseWeightedByIndexCheckedFrom`,
  `fillChooseWeightedConstPtrByIndex`,
  `fillChooseWeightedConstPtrByIndexFrom`,
  `fillChooseWeightedConstPtrByIndexChecked`,
  `fillChooseWeightedConstPtrByIndexCheckedFrom`,
  `fillChooseWeightedPtrByIndex`, `fillChooseWeightedPtrByIndexFrom`,
  `fillChooseWeightedPtrByIndexChecked`,
  `fillChooseWeightedPtrByIndexCheckedFrom`,
  `chooseWeightedBatchByIndex`, `chooseWeightedBatchByIndexFrom`,
  `chooseWeightedBatchByIndexChecked`,
  `chooseWeightedBatchByIndexCheckedFrom`,
  `chooseWeightedConstPtrBatchByIndex`,
  `chooseWeightedConstPtrBatchByIndexFrom`,
  `chooseWeightedConstPtrBatchByIndexChecked`,
  `chooseWeightedConstPtrBatchByIndexCheckedFrom`,
  `chooseWeightedPtrBatchByIndex`, `chooseWeightedPtrBatchByIndexFrom`,
  `chooseWeightedPtrBatchByIndexChecked`,
  `chooseWeightedPtrBatchByIndexCheckedFrom`,
  `weightedIndexBy`, `weightedIndexByFrom`, `weightedIndexByChecked`,
  `weightedIndexByCheckedFrom`, `weightedIndexArrayBy`,
  `weightedIndexArrayByFrom`, `weightedIndexArrayByChecked`,
  `weightedIndexArrayByCheckedFrom`, `weightedIndexU32By`,
  `weightedIndexU32ByFrom`, `weightedIndexU32ByChecked`,
  `weightedIndexU32ByCheckedFrom`, `weightedIndexU32ArrayBy`,
  `weightedIndexU32ArrayByFrom`, `weightedIndexU32ArrayByChecked`,
  `weightedIndexU32ArrayByCheckedFrom`, `fillWeightedIndexBy`,
  `fillWeightedIndexByFrom`, `fillWeightedIndexByChecked`,
  `fillWeightedIndexByCheckedFrom`, `fillWeightedIndexU32By`,
  `fillWeightedIndexU32ByFrom`, `fillWeightedIndexU32ByChecked`,
  `fillWeightedIndexU32ByCheckedFrom`, `weightedIndexBatchBy`,
  `weightedIndexBatchByFrom`, `weightedIndexBatchByChecked`,
  `weightedIndexBatchByCheckedFrom`, `weightedIndexU32BatchBy`,
  `weightedIndexU32BatchByFrom`, `weightedIndexU32BatchByChecked`,
  `weightedIndexU32BatchByCheckedFrom`,
  `chooseWeightedBy`, `chooseWeightedByFrom`, `chooseWeightedByChecked`,
  `chooseWeightedByCheckedFrom`, `chooseWeightedValueArrayBy`,
  `chooseWeightedValueArrayByFrom`, `chooseWeightedValueArrayByChecked`,
  `chooseWeightedValueArrayByCheckedFrom`, `fillChooseWeightedBy`,
  `fillChooseWeightedByFrom`, `fillChooseWeightedByChecked`,
  `fillChooseWeightedByCheckedFrom`, `fillChooseWeighted`,
  `fillChooseWeightedFrom`, `fillChooseWeightedChecked`,
  `fillChooseWeightedCheckedFrom`,
  `chooseWeightedBatchBy`, `chooseWeightedBatchByFrom`,
  `chooseWeightedBatchByChecked`, `chooseWeightedBatchByCheckedFrom`,
  `chooseWeightedBatch`, `chooseWeightedBatchFrom`, `chooseWeightedBatchChecked`,
  `chooseWeightedBatchCheckedFrom`, `chooseWeightedValueArray`,
  `chooseWeightedValueArrayFrom`, `chooseWeightedValueArrayChecked`,
  `chooseWeightedValueArrayCheckedFrom`, `chooseWeightedConstPtr`,
  `chooseWeightedConstPtrFrom`, `chooseWeightedConstPtrChecked`,
  `chooseWeightedConstPtrCheckedFrom`, `chooseWeightedConstPtrBy`,
  `chooseWeightedConstPtrByFrom`, `chooseWeightedConstPtrByChecked`,
  `chooseWeightedConstPtrByCheckedFrom`, `chooseWeightedConstPtrArrayBy`,
  `chooseWeightedConstPtrArrayByFrom`,
  `chooseWeightedConstPtrArrayByChecked`,
  `chooseWeightedConstPtrArrayByCheckedFrom`, `fillChooseWeightedConstPtrBy`,
  `fillChooseWeightedConstPtrByFrom`, `fillChooseWeightedConstPtrByChecked`,
  `fillChooseWeightedConstPtrByCheckedFrom`, `fillChooseWeightedConstPtr`,
  `fillChooseWeightedConstPtrFrom`, `fillChooseWeightedConstPtrChecked`,
  `fillChooseWeightedConstPtrCheckedFrom`, `chooseWeightedConstPtrBatchBy`,
  `chooseWeightedConstPtrBatchByFrom`, `chooseWeightedConstPtrBatchByChecked`,
  `chooseWeightedConstPtrBatchByCheckedFrom`, `chooseWeightedConstPtrBatch`,
  `chooseWeightedConstPtrBatchFrom`, `chooseWeightedConstPtrBatchChecked`,
  `chooseWeightedConstPtrBatchCheckedFrom`, `chooseWeightedConstPtrArray`,
  `chooseWeightedConstPtrArrayFrom`, `chooseWeightedConstPtrArrayChecked`,
  `chooseWeightedConstPtrArrayCheckedFrom`, `chooseWeightedPtr`,
  `chooseWeightedPtrFrom`, `chooseWeightedPtrChecked`,
  `chooseWeightedPtrCheckedFrom`, `chooseWeightedPtrBy`,
  `chooseWeightedPtrByFrom`, `chooseWeightedPtrByChecked`,
  `chooseWeightedPtrByCheckedFrom`, `chooseWeightedPtrArrayBy`,
  `chooseWeightedPtrArrayByFrom`, `chooseWeightedPtrArrayByChecked`,
  `chooseWeightedPtrArrayByCheckedFrom`, `fillChooseWeightedPtrBy`,
  `fillChooseWeightedPtrByFrom`, `fillChooseWeightedPtrByChecked`,
  `fillChooseWeightedPtrByCheckedFrom`, `fillChooseWeightedPtr`,
  `fillChooseWeightedPtrFrom`, `fillChooseWeightedPtrChecked`,
  `fillChooseWeightedPtrCheckedFrom`, `chooseWeightedPtrBatchBy`,
  `chooseWeightedPtrBatchByFrom`, `chooseWeightedPtrBatchByChecked`,
  `chooseWeightedPtrBatchByCheckedFrom`, `chooseWeightedPtrBatch`,
  `chooseWeightedPtrBatchFrom`, `chooseWeightedPtrBatchChecked`,
  `chooseWeightedPtrBatchCheckedFrom`, `chooseWeightedPtrArray`,
  `chooseWeightedPtrArrayFrom`, `chooseWeightedPtrArrayChecked`,
  `chooseWeightedPtrArrayCheckedFrom`
- Weighted one-shot slices: `chooseWeighted`, `chooseWeightedFrom`,
  `chooseWeightedChecked`, `chooseWeightedCheckedFrom`,
  index-weighted `weightedIndexByIndex`, `weightedIndexByIndexFrom`,
  `weightedIndexByIndexChecked`, `weightedIndexByIndexCheckedFrom`,
  `weightedIndexU32ByIndex`, `weightedIndexU32ByIndexFrom`,
  `weightedIndexU32ByIndexChecked`, `weightedIndexU32ByIndexCheckedFrom`,
  `weightedIndexArrayByIndex`, `weightedIndexArrayByIndexFrom`,
  `weightedIndexArrayByIndexChecked`,
  `weightedIndexArrayByIndexCheckedFrom`,
  `weightedIndexU32ArrayByIndex`, `weightedIndexU32ArrayByIndexFrom`,
  `weightedIndexU32ArrayByIndexChecked`,
  `weightedIndexU32ArrayByIndexCheckedFrom`,
  `fillWeightedIndexByIndex`, `fillWeightedIndexByIndexFrom`,
  `fillWeightedIndexByIndexChecked`, `fillWeightedIndexByIndexCheckedFrom`,
  `fillWeightedIndexU32ByIndex`, `fillWeightedIndexU32ByIndexFrom`,
  `fillWeightedIndexU32ByIndexChecked`,
  `fillWeightedIndexU32ByIndexCheckedFrom`,
  `weightedIndexBatchByIndex`, `weightedIndexBatchByIndexFrom`,
  `weightedIndexBatchByIndexChecked`,
  `weightedIndexBatchByIndexCheckedFrom`,
  `weightedIndexU32BatchByIndex`, `weightedIndexU32BatchByIndexFrom`,
  `weightedIndexU32BatchByIndexChecked`,
  `weightedIndexU32BatchByIndexCheckedFrom`,
  `chooseWeightedByIndex`, `chooseWeightedByIndexFrom`,
  `chooseWeightedByIndexChecked`, `chooseWeightedByIndexCheckedFrom`,
  `chooseWeightedConstPtrByIndex`, `chooseWeightedConstPtrByIndexFrom`,
  `chooseWeightedConstPtrByIndexChecked`,
  `chooseWeightedConstPtrByIndexCheckedFrom`, `chooseWeightedPtrByIndex`,
  `chooseWeightedPtrByIndexFrom`, `chooseWeightedPtrByIndexChecked`,
  `chooseWeightedPtrByIndexCheckedFrom`,
  `chooseWeightedValueArrayByIndex`, `chooseWeightedValueArrayByIndexFrom`,
  `chooseWeightedValueArrayByIndexChecked`,
  `chooseWeightedValueArrayByIndexCheckedFrom`,
  `chooseWeightedConstPtrArrayByIndex`,
  `chooseWeightedConstPtrArrayByIndexFrom`,
  `chooseWeightedConstPtrArrayByIndexChecked`,
  `chooseWeightedConstPtrArrayByIndexCheckedFrom`,
  `chooseWeightedPtrArrayByIndex`, `chooseWeightedPtrArrayByIndexFrom`,
  `chooseWeightedPtrArrayByIndexChecked`,
  `chooseWeightedPtrArrayByIndexCheckedFrom`,
  `fillChooseWeightedByIndex`, `fillChooseWeightedByIndexFrom`,
  `fillChooseWeightedByIndexChecked`,
  `fillChooseWeightedByIndexCheckedFrom`,
  `fillChooseWeightedConstPtrByIndex`,
  `fillChooseWeightedConstPtrByIndexFrom`,
  `fillChooseWeightedConstPtrByIndexChecked`,
  `fillChooseWeightedConstPtrByIndexCheckedFrom`,
  `fillChooseWeightedPtrByIndex`, `fillChooseWeightedPtrByIndexFrom`,
  `fillChooseWeightedPtrByIndexChecked`,
  `fillChooseWeightedPtrByIndexCheckedFrom`,
  `chooseWeightedBatchByIndex`, `chooseWeightedBatchByIndexFrom`,
  `chooseWeightedBatchByIndexChecked`,
  `chooseWeightedBatchByIndexCheckedFrom`,
  `chooseWeightedConstPtrBatchByIndex`,
  `chooseWeightedConstPtrBatchByIndexFrom`,
  `chooseWeightedConstPtrBatchByIndexChecked`,
  `chooseWeightedConstPtrBatchByIndexCheckedFrom`,
  `chooseWeightedPtrBatchByIndex`, `chooseWeightedPtrBatchByIndexFrom`,
  `chooseWeightedPtrBatchByIndexChecked`,
  `chooseWeightedPtrBatchByIndexCheckedFrom`,
  `weightedIndexBy`, `weightedIndexByFrom`, `weightedIndexByChecked`,
  `weightedIndexByCheckedFrom`, `weightedIndexArrayBy`,
  `weightedIndexArrayByFrom`, `weightedIndexArrayByChecked`,
  `weightedIndexArrayByCheckedFrom`, `weightedIndexU32By`,
  `weightedIndexU32ByFrom`, `weightedIndexU32ByChecked`,
  `weightedIndexU32ByCheckedFrom`, `weightedIndexU32ArrayBy`,
  `weightedIndexU32ArrayByFrom`, `weightedIndexU32ArrayByChecked`,
  `weightedIndexU32ArrayByCheckedFrom`, `fillWeightedIndexBy`,
  `fillWeightedIndexByFrom`, `fillWeightedIndexByChecked`,
  `fillWeightedIndexByCheckedFrom`, `fillWeightedIndexU32By`,
  `fillWeightedIndexU32ByFrom`, `fillWeightedIndexU32ByChecked`,
  `fillWeightedIndexU32ByCheckedFrom`, `weightedIndexBatchBy`,
  `weightedIndexBatchByFrom`, `weightedIndexBatchByChecked`,
  `weightedIndexBatchByCheckedFrom`, `weightedIndexU32BatchBy`,
  `weightedIndexU32BatchByFrom`, `weightedIndexU32BatchByChecked`,
  `weightedIndexU32BatchByCheckedFrom`,
  `chooseWeightedBy`, `chooseWeightedByFrom`, `chooseWeightedByChecked`,
  `chooseWeightedByCheckedFrom`,
  `fillChooseWeightedBy`, `fillChooseWeightedByFrom`,
  `fillChooseWeightedByChecked`, `fillChooseWeightedByCheckedFrom`,
  `chooseWeightedBatchBy`, `chooseWeightedBatchByFrom`,
  `chooseWeightedBatchByChecked`, `chooseWeightedBatchByCheckedFrom`,
  `chooseWeightedConstPtr`, `chooseWeightedConstPtrFrom`,
  `chooseWeightedConstPtrChecked`, `chooseWeightedConstPtrCheckedFrom`,
  `chooseWeightedConstPtrBy`, `chooseWeightedConstPtrByFrom`,
  `chooseWeightedConstPtrByChecked`, `chooseWeightedConstPtrByCheckedFrom`,
  `fillChooseWeightedConstPtrBy`, `fillChooseWeightedConstPtrByFrom`,
  `fillChooseWeightedConstPtrByChecked`,
  `fillChooseWeightedConstPtrByCheckedFrom`,
  `chooseWeightedConstPtrBatchBy`, `chooseWeightedConstPtrBatchByFrom`,
  `chooseWeightedConstPtrBatchByChecked`,
  `chooseWeightedConstPtrBatchByCheckedFrom`,
  `chooseWeightedPtr`, `chooseWeightedPtrFrom`, `chooseWeightedPtrChecked`,
  `chooseWeightedPtrCheckedFrom`, `chooseWeightedPtrBy`,
  `chooseWeightedPtrByFrom`, `chooseWeightedPtrByChecked`,
  `chooseWeightedPtrByCheckedFrom`, `chooseWeightedPtrArrayBy`,
  `chooseWeightedPtrArrayByFrom`, `chooseWeightedPtrArrayByChecked`,
  `chooseWeightedPtrArrayByCheckedFrom`, `fillChooseWeightedPtrBy`,
  `fillChooseWeightedPtrByFrom`, `fillChooseWeightedPtrByChecked`,
  `fillChooseWeightedPtrByCheckedFrom`, `chooseWeightedPtrBatchBy`,
  `chooseWeightedPtrBatchByFrom`, `chooseWeightedPtrBatchByChecked`,
  `chooseWeightedPtrBatchByCheckedFrom`
- Weighted no-replacement: `sampleWeightedIndices`,
  `sampleWeightedIndicesFrom`, `sampleWeightedIndicesChecked`,
  `sampleWeightedIndicesCheckedFrom`, `sampleWeightedIndicesU32`,
  `sampleWeightedIndicesU32From`, `sampleWeightedIndicesU32Checked`,
  `sampleWeightedIndicesU32CheckedFrom`, `sampleWeightedIndexVec`,
  `sampleWeightedIndexVecFrom`, `sampleWeightedIndexVecChecked`,
  `sampleWeightedIndexVecCheckedFrom`, `sampleWeightedIndicesByIndex`,
  `sampleWeightedIndicesByIndexFrom`,
  `sampleWeightedIndicesByIndexChecked`,
  `sampleWeightedIndicesByIndexCheckedFrom`,
  `sampleWeightedIndicesU32ByIndex`,
  `sampleWeightedIndicesU32ByIndexFrom`,
  `sampleWeightedIndicesU32ByIndexChecked`,
  `sampleWeightedIndicesU32ByIndexCheckedFrom`,
  `sampleWeightedIndexVecByIndex`,
  `sampleWeightedIndexVecByIndexFrom`,
  `sampleWeightedIndexVecByIndexChecked`,
  `sampleWeightedIndexVecByIndexCheckedFrom`,
  `sampleWeightedIndicesByIndexInto`,
  `sampleWeightedIndicesByIndexIntoFrom`,
  `sampleWeightedIndicesByIndexIntoChecked`,
  `sampleWeightedIndicesByIndexIntoCheckedFrom`,
  `sampleWeightedIndicesU32ByIndexInto`,
  `sampleWeightedIndicesU32ByIndexIntoFrom`,
  `sampleWeightedIndicesU32ByIndexIntoChecked`,
  `sampleWeightedIndicesU32ByIndexIntoCheckedFrom`,
  `sampleWeightedIndexArrayByIndex`,
  `sampleWeightedIndexArrayByIndexFrom`,
  `sampleWeightedIndexArrayByIndexChecked`,
  `sampleWeightedIndexArrayByIndexCheckedFrom`,
  `sampleWeightedIndexArrayU32ByIndex`,
  `sampleWeightedIndexArrayU32ByIndexFrom`,
  `sampleWeightedIndexArrayU32ByIndexChecked`,
  `sampleWeightedIndexArrayU32ByIndexCheckedFrom`,
  `sampleWeightedIndicesBy`,
  `sampleWeightedIndicesByFrom`, `sampleWeightedIndicesByChecked`,
  `sampleWeightedIndicesByCheckedFrom`, `sampleWeightedIndicesU32By`,
  `sampleWeightedIndicesU32ByFrom`, `sampleWeightedIndicesU32ByChecked`,
  `sampleWeightedIndicesU32ByCheckedFrom`, `sampleWeightedIndexVecBy`,
  `sampleWeightedIndexVecByFrom`, `sampleWeightedIndexVecByChecked`,
  `sampleWeightedIndexVecByCheckedFrom`, `sampleWeightedIndicesInto`,
  `sampleWeightedIndicesIntoFrom`, `sampleWeightedIndicesIntoChecked`,
  `sampleWeightedIndicesIntoCheckedFrom`, `sampleWeightedIndicesByInto`,
  `sampleWeightedIndicesByIntoFrom`, `sampleWeightedIndicesByIntoChecked`,
  `sampleWeightedIndicesByIntoCheckedFrom`, `sampleWeightedIndicesU32Into`,
  `sampleWeightedIndicesU32IntoFrom`, `sampleWeightedIndicesU32IntoChecked`,
  `sampleWeightedIndicesU32IntoCheckedFrom`, `sampleWeightedIndexArray`,
  `sampleWeightedIndexArrayFrom`, `sampleWeightedIndexArrayChecked`,
  `sampleWeightedIndexArrayCheckedFrom`, `sampleWeightedIndexArrayU32`,
  `sampleWeightedIndexArrayU32From`, `sampleWeightedIndexArrayU32Checked`,
  `sampleWeightedIndexArrayU32CheckedFrom`,
  `sampleWeightedIndexArrayBy`, `sampleWeightedIndexArrayByFrom`,
  `sampleWeightedIndexArrayByChecked`,
  `sampleWeightedIndexArrayByCheckedFrom`, `sampleWeightedIndexArrayU32By`,
  `sampleWeightedIndexArrayU32ByFrom`,
  `sampleWeightedIndexArrayU32ByChecked`,
  `sampleWeightedIndexArrayU32ByCheckedFrom`, `sampleWeighted`,
  `sampleWeightedFrom`,
  `sampleWeightedChecked`, `sampleWeightedCheckedFrom`,
  `sampleWeightedBy`, `sampleWeightedByFrom`,
  `sampleWeightedByChecked`, `sampleWeightedByCheckedFrom`,
  `sampleWeightedPtrs`, `sampleWeightedPtrsFrom`,
  `sampleWeightedPtrsChecked`, `sampleWeightedPtrsCheckedFrom`,
  `sampleWeightedPtrsBy`, `sampleWeightedPtrsByFrom`,
  `sampleWeightedPtrsByChecked`, `sampleWeightedPtrsByCheckedFrom`,
  `sampleWeightedMutPtrs`, `sampleWeightedMutPtrsFrom`,
  `sampleWeightedMutPtrsChecked`, `sampleWeightedMutPtrsCheckedFrom`,
  `sampleWeightedMutPtrsBy`, `sampleWeightedMutPtrsByFrom`,
  `sampleWeightedMutPtrsByChecked`, `sampleWeightedMutPtrsByCheckedFrom`,
  `sampleWeightedInto`, `sampleWeightedIntoFrom`,
  `sampleWeightedIntoChecked`, `sampleWeightedIntoCheckedFrom`,
  `sampleWeightedByInto`, `sampleWeightedByIntoFrom`,
  `sampleWeightedByIntoChecked`, `sampleWeightedByIntoCheckedFrom`,
  `sampleWeightedPtrsInto`, `sampleWeightedPtrsIntoFrom`,
  `sampleWeightedPtrsIntoChecked`, `sampleWeightedPtrsIntoCheckedFrom`,
  `sampleWeightedPtrsByInto`, `sampleWeightedPtrsByIntoFrom`,
  `sampleWeightedPtrsByIntoChecked`, `sampleWeightedPtrsByIntoCheckedFrom`,
  `sampleWeightedMutPtrsInto`, `sampleWeightedMutPtrsIntoFrom`,
  `sampleWeightedMutPtrsIntoChecked`, `sampleWeightedMutPtrsIntoCheckedFrom`,
  `sampleWeightedMutPtrsByInto`, `sampleWeightedMutPtrsByIntoFrom`,
  `sampleWeightedMutPtrsByIntoChecked`,
  `sampleWeightedMutPtrsByIntoCheckedFrom`,
  `sampleWeightedArray`, `sampleWeightedArrayFrom`,
  `sampleWeightedArrayChecked`, `sampleWeightedArrayCheckedFrom`,
  `sampleWeightedArrayBy`, `sampleWeightedArrayByFrom`,
  `sampleWeightedArrayByChecked`, `sampleWeightedArrayByCheckedFrom`,
  `sampleWeightedPtrArray`, `sampleWeightedPtrArrayFrom`,
  `sampleWeightedPtrArrayChecked`, `sampleWeightedPtrArrayCheckedFrom`,
  `sampleWeightedPtrArrayBy`, `sampleWeightedPtrArrayByFrom`,
  `sampleWeightedPtrArrayByChecked`, `sampleWeightedPtrArrayByCheckedFrom`,
  `sampleWeightedMutPtrArray`, `sampleWeightedMutPtrArrayFrom`,
  `sampleWeightedMutPtrArrayChecked`, `sampleWeightedMutPtrArrayCheckedFrom`,
  `sampleWeightedMutPtrArrayBy`, `sampleWeightedMutPtrArrayByFrom`,
  `sampleWeightedMutPtrArrayByChecked`,
  `sampleWeightedMutPtrArrayByCheckedFrom`

## ASCII And Unicode

- Charset constants: `Alphanumeric`, `Alphabetic`, `Lowercase`, `Uppercase`,
  `Digits`
- Distribution Unicode scalar range sampler: `UniformUnicodeScalar`,
  `UniformChar`,
  `UniformUnicodeScalar.init`, `UniformUnicodeScalar.new`,
  `UniformUnicodeScalar.initInclusive`,
  `UniformUnicodeScalar.newInclusive`, `UniformUnicodeScalar.lowValue`,
  `UniformUnicodeScalar.highValue`, `UniformUnicodeScalar.isInclusive`,
  `UniformUnicodeScalar.sample`, `UniformUnicodeScalar.sampleFrom`,
  `UniformUnicodeScalar.fill`, `UniformUnicodeScalar.fillFrom`
- Raw charset byte sets: `alphanumeric`, `alphabetic`, `lowercase`,
  `uppercase`, `digits`
- Charset type: `Charset.init`, `Charset.initChecked`, `Charset.bytesValue`,
  `Charset.len`, `Charset.numChoices`, `Charset.constantIndex`, `Charset.isEmpty`, `Charset.byteAt`, `Charset.item`, `Charset.get`, `Charset.indexOf`,
  `Charset.contains`, `Charset.probabilityAt`, `Charset.probability`,
  `Charset.probabilityIter`, `Charset.ProbabilityIterator`,
  `Charset.ProbabilityIterator.next`, `Charset.ProbabilityIterator.remaining`,
  `Charset.ProbabilityIterator.len`, `Charset.ProbabilityIterator.sizeHint`, `Charset.ProbabilityIterator.fill`,
  `Charset.probabilities`, `Charset.probabilitiesInto`, `Charset.sample`,
  `Charset.sampleChecked`, `Charset.sampleFrom`, `Charset.sampleCheckedFrom`,
  `Charset.fill`, `Charset.fillChecked`, `Charset.fillFrom`,
  `Charset.fillCheckedFrom`, `Charset.alloc`, `Charset.allocChecked`,
  `Charset.allocFrom`, `Charset.allocCheckedFrom`, `Charset.sampleString`,
  `Charset.sampleStringFrom`, `Charset.sampleStringChecked`,
  `Charset.sampleStringCheckedFrom`, `Charset.appendString`,
  `Charset.appendStringFrom`, `Charset.appendStringChecked`,
  `Charset.appendStringCheckedFrom`
- Unicode charset type: `UnicodeCharset.init`, `UnicodeCharset.initChecked`,
  `UnicodeCharset.scalarsValue`, `UnicodeCharset.len`,
  `UnicodeCharset.numChoices`, `UnicodeCharset.constantIndex`,
  `UnicodeCharset.isEmpty`, `UnicodeCharset.scalarAt`,
  `UnicodeCharset.item`, `UnicodeCharset.get`, `UnicodeCharset.indexOf`,
  `UnicodeCharset.contains`, `UnicodeCharset.maxUtf8Len`,
  `UnicodeCharset.utf8Capacity`, `UnicodeCharset.probabilityAt`,
  `UnicodeCharset.probability`, `UnicodeCharset.probabilityIter`,
  `UnicodeCharset.ProbabilityIterator`,
  `UnicodeCharset.ProbabilityIterator.next`,
  `UnicodeCharset.ProbabilityIterator.remaining`,
  `UnicodeCharset.ProbabilityIterator.len`,
  `UnicodeCharset.ProbabilityIterator.sizeHint`,
  `UnicodeCharset.ProbabilityIterator.fill`, `UnicodeCharset.probabilities`,
  `UnicodeCharset.probabilitiesInto`, `UnicodeCharset.sample`,
  `UnicodeCharset.sampleChecked`, `UnicodeCharset.sampleFrom`,
  `UnicodeCharset.sampleCheckedFrom`, `UnicodeCharset.fill`,
  `UnicodeCharset.fillChecked`, `UnicodeCharset.fillFrom`,
  `UnicodeCharset.fillCheckedFrom`, `UnicodeCharset.sampleString`,
  `UnicodeCharset.sampleStringFrom`, `UnicodeCharset.sampleStringChecked`,
  `UnicodeCharset.sampleStringCheckedFrom`, `UnicodeCharset.appendString`,
  `UnicodeCharset.appendStringFrom`, `UnicodeCharset.appendStringChecked`,
  `UnicodeCharset.appendStringCheckedFrom`
- Helpers: `char`, `charFrom`, `string`, `stringFrom`, `sampleString`,
  `sampleStringFrom`, `appendString`, `appendStringFrom`, `unicodeScalar`,
  `unicodeScalarFrom`, `unicodeUtf8Alloc`, `unicodeUtf8AllocFrom`,
  `unicodeUtf8Capacity`, `unicodeUtf8Into`, `unicodeUtf8IntoFrom`

## Validation And Tooling

Selected build steps (see `docs/tooling.md` for the complete catalog):

- `zig build test`
- `zig build run-basic`
- `zig build run-vector-profiles`
- `zig build run-lognormal-profiles`
- `zig build run-native-f32-profiles`
- `zig build run-weighted-sampling`
- `zig build run-multivariate-sampling`
- `zig build run-sequence-sampling`
- `zig build run-caller-owned-sampling`
- `zig build run-string-generation`
- `zig build run-unit-geometry`
- `zig build run-distribution-diagnostics`
- `zig build run-reproducible-streams`
- `zig build run-range-sampling`
- `zig build run-discrete-distributions`
- `zig build run-continuous-distributions`
- `zig build run-advanced-continuous-distributions`
- `zig build run-rank-distributions`
- `zig build examples`
- `zig build examplecheck`
- `zig build toolingcheck`
- `zig build readmecheck`
- `zig build roadmapcheck`
- `zig build surfacecheck`
- `zig build runtimecheck`
- `zig build doccheck`
- `zig build apicheck`
- `zig build validate`
- `zig build practrand-self-test`
- `zig build validate-local`
- `zig build rand-status`
- `zig build rand-status -- --json`
- `zig build rand-bench-test`
- `zig build rand-bench-smoke`
- `zig build rand-bench-smoke-dry-run`
- `zig build rand-bench-smoke-self-test`
- `zig build validate-all`
- `zig build statcheck`
- `zig build distcheck`
- `zig build crosscheck`
- `zig build test-wasi`
- `zig build wasi-dry-run`
- `zig build wasi-self-test`
- `node tools/run_wasi_test.js --dry-run <test.wasm>`
- `node tools/run_wasi_test.js --self-test`
- `zig build wasi-report`
- `zig build stream -- --engine <engine> --bytes <n>`
- `tools/practrand.sh --dry-run fast 1048576`
- `tools/practrand.sh --self-test`
- `zig build practrand-dry-run`
- `zig build practrand-self-test`
- `zig build repro`
- `zig build -Doptimize=ReleaseFast -Dcpu=native bench`
- `zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench`
- `zig build -Doptimize=ReleaseFast -Dcpu=native ziggurat-probe`
- `zig build -Doptimize=ReleaseFast -Dcpu=native cauchy-probe`

Use `zig build validate` for broad native API checks, including `zig build practrand-self-test` for no-external PractRand wrapper validation. Use `zig build
validate-local` when API work changes local `rand` / `rand_distr` comparison
evidence because it adds `rand-bench-test`, `rand-bench-smoke`, `rand-bench-smoke-self-test`, `rand-status`, `rand-status-json`, `rand-status-schema-version`, `rand-status-self-test`, `surfacecheck`, and `runtimecheck`; the smoke wrapper supports `ALEA_RAND_BENCH_MANIFEST` / `ALEA_RAND_BENCH_EXPECTED_ROW` overrides for custom local Rust comparison checks.
Use `zig build validate-all` for portability-sensitive API evidence because it adds cross-target
compile checks, WASI unit tests, WASI dry/self tests, and the chained WASI report. `zig build
crosscheck` compiles `wasm32-wasi`, `aarch64-linux`, `riscv64-linux`,
`x86_64-windows`, `x86_64-macos`, and `aarch64-macos` without executing them.
Use `zig build wasi-dry-run` or `node tools/run_wasi_test.js --dry-run
<test.wasm>` to verify Node WASI runner arguments without reading or executing a
wasm file; use `zig build wasi-self-test` or `node tools/run_wasi_test.js
--self-test` to test runner dry-run, help-output, and missing-argument paths without wasm.

See `docs/tooling.md` for the complete build-step and checked-tool catalog.

Tools:

- `tools/statcheck.zig`
- `docs/tooling.md`
- `tools/apicheck.zig`
- `tools/distcheck.zig`
- `tools/stream.zig`
- `tools/ziggurat_probe.zig`
- `tools/cauchy_probe.zig`
- `tools/repro.zig`
- `tools/readmecheck.zig`
- `tools/roadmapcheck.zig` (roadmap, active-audit evidence,
  public-surface manifest, and S4-M11 blocker-token coverage)
- `tools/runtimecheck.zig`
- `tools/surfacecheck.zig` (optional local Rust `rand` / `rand_core` /
  `rand_distr` manifest drift checker)
- `tools/toolingcheck.zig`
- `tools/practrand.sh`
