# S4-M794 IndexVec Owned U32 Narrowing Prevalidation

## Gap

`IndexVec.intoOwnedU32Slice` converts native `usize` backing to compact `u32`
backing. Before this milestone, it allocated the output slice first and only then
reported `error.InvalidParameter` if a native index did not fit in `u32`.

## Local `rand` Baseline

Rust indexed sample conversions operate over concrete index storage and reject
invalid narrowing before producing the compact result. Alea can preserve this
failure determinism by validating all native indexes before allocating the output
buffer.

## Implementation

- `src/seq.zig` prevalidates every native `usize` index before allocating in
  `IndexVec.intoOwnedU32Slice`.
- The focused conversion test now uses a failing allocator to prove oversized
  native indexes return `error.InvalidParameter` without triggering allocation.

## Validation

Focused sequence test:

```text
$ zig test src/seq.zig --test-filter "index vec consuming owned conversions transfer or narrow backing"
1/2 seq.test.index vec consuming owned conversions transfer or narrow backing...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M794 is closed for the current bar: native-backed IndexVec owned `u32`
narrowing now fails before allocation when an index is out of range. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
