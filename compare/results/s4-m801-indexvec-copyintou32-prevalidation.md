# S4-M801 IndexVec copyIntoU32 No-Partial-Write Prevalidation

## Gap

S4-M794 and S4-M798 tightened allocation-returning native-to-compact `IndexVec`
conversions so oversized `usize` indexes fail before output allocation. The
caller-owned `IndexVec.copyIntoU32` path still validated while writing each slot,
which meant a native-backed vector such as `{ 1, maxInt(u32) + 1 }` could modify
the destination's earlier slots before returning `error.InvalidParameter`.

## Local `rand` Baseline

Rust `rand`'s `IndexVec` conversions in
`/home/passchaos/Work/rand/src/seq/index.rs` materialize owned vectors from the
active backing representation and do not expose a caller-owned compact-copy API
that can partially overwrite a user buffer on conversion failure. Alea's
Zig-native caller-owned helper should preserve deterministic failure semantics:
invalid narrowing is reported before output mutation.

## Implementation

- `src/seq.zig` prevalidates every native `usize` index in `IndexVec.copyIntoU32`
  before narrowing any value into the caller-owned `u32` destination.
- The compact `u32` backing fast path remains a direct copy.
- The focused native-backing conversion test seeds the destination with sentinel
  values and proves an oversized native index returns `error.InvalidParameter`
  without changing any output slot.

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
readmecheck ok
toolingcheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M801 is closed for the current bar: native-backed `IndexVec.copyIntoU32` now
fails before writing to caller-owned output when any index cannot fit in `u32`.
This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
