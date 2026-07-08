# S4-M798 IndexVec Copied U32 Narrowing Prevalidation

## Gap

S4-M794 tightened consuming `IndexVec.intoOwnedU32Slice` so native `usize`
backing with an oversized index fails before allocating compact `u32` output.
The non-consuming copied conversion `IndexVec.toOwnedU32Slice` still allocated the
output first, then delegated to `copyIntoU32`, which could fail after allocation.

## Local `rand` Baseline

Rust indexed sample conversions operate over concrete index storage and reject
invalid narrowing before producing compact output. Alea can preserve this failure
determinism for both consuming and non-consuming owned conversions.

## Implementation

- `src/seq.zig` prevalidates native `usize` backing in `IndexVec.toOwnedU32Slice`
  before allocating the copied `u32` output slice.
- The focused native-backing conversion test uses a failing allocator to prove an
  oversized native index returns `error.InvalidParameter` without allocation.

## Validation

Focused sequence test:

```text
$ zig test src/seq.zig --test-filter "index vec conversion supports native backing"
1/1 seq.test.index vec conversion supports native backing...OK
All 1 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M798 is closed for the current bar: native-backed IndexVec copied `u32`
narrowing now fails before allocation when an index is out of range. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
