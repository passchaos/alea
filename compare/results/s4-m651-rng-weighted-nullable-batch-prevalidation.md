# S4-M651 Rng Weighted Nullable Batch Prevalidation

## Gap

Unchecked `Rng` weighted nullable fill/batch helpers previously implemented
batching by repeatedly calling one-shot weighted choice helpers after allocating
output buffers. This delayed deterministic invalid/all-zero/single-positive
handling and could allocate before discovering invalid weights.

Weighted nullable batch helpers should scan weights once, handle deterministic
results directly, and avoid random-stream use when no random choice is needed.

## Local `rand` Baseline

The local Rust checkout remains the baseline comparison source:

- `/home/passchaos/Work/rand/src/seq/slice.rs` documents weighted choice errors
  for invalid/no-positive weights and repeated workflows via iterators.
- Alea's nullable weighted repeated choice helpers support all-zero weights by
  returning `null` values, while checked helpers use exact non-null semantics.

S4-M651 keeps the nullable semantics but makes invalid/all-zero/single-positive
batch paths deterministic before allocation or repeated one-shot sampling.

## API Changed

`src/rng.zig` now prevalidates and directly fills deterministic paths in:

- `fillWeightedIndexFrom`
- `weightedIndexBatchFrom`
- `fillWeightedIndexU32From`
- `weightedIndexU32BatchFrom`
- `fillChooseWeightedFrom`
- `chooseWeightedBatchFrom`
- `chooseWeightedConstPtrBatchFrom`
- `chooseWeightedPtrBatchFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Empty output buffers return immediately.
- Invalid weights and u32 length limits return before output allocation where
  possible.
- All-zero weights fill allocated nullable outputs with `null` without consuming
  the random stream.
- Single-positive weights fill outputs with the single deterministic choice
  without consuming the random stream.
- Multi-positive valid paths keep existing weighted sampling behavior and stream
  shape.

## Adoption and Documentation

- Focused rng tests cover invalid-weight failures before allocation, all-zero
  nullable outputs, single-positive deterministic outputs, empty-output no-op
  behavior, and random-path preservation.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng tests:

```text
$ zig test src/rng.zig --test-filter "invalid facade weighted helpers"
1/2 rng.test.invalid facade weighted helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

No output.

Broader native test gate:

```text
$ zig build test
roadmapcheck ok
examplecheck ok
toolingcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M651 is closed for the current bar: `Rng` unchecked weighted nullable
fill/batch helpers now resolve invalid weights, all-zero weights,
single-positive weights, u32 limits, and empty outputs deterministically before
unnecessary allocation or random-stream use. This is reliability and ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
