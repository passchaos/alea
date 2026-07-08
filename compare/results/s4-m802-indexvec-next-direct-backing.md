# S4-M802 IndexVec Next Direct Backing Paths

## Gap

S4-M799 moved borrowed and consuming `IndexVec` iterator fills to
backing-specific direct storage paths, but the scalar `next()` methods still
called `IndexVec.len()` and `IndexVec.at()` for each yielded item. That repeated
union dispatch in scalar iterator consumers, including downstream sampled
value/pointer iterators that advance one item at a time.

## Local `rand` Baseline

The local Rust checkout (`/home/passchaos/Work/rand/src/seq/index.rs`) models
`IndexVecIter` and `IndexVecIntoIter` as enum wrappers around backing
slice/vector iterators (`slice::Iter<u32>` / `vec::IntoIter<u32>` and, on 64-bit
targets, `u64` variants). Each `next()` dispatches to the active backing iterator
instead of doing an independent `IndexVec::index()` lookup. Alea keeps its
Zig-native iterator structs and applies the same backing-specific read policy to
scalar `next()` calls.

## Implementation

- `src/seq.zig` updates `IndexVec.Iterator.next` to switch once, bounds-check the
  active backing slice directly, and load from compact `u32` or native `usize`
  storage without calling `len()`/`at()`.
- `src/seq.zig` applies the same direct backing read path to
  `IndexVec.IntoIterator.next`, preserving ownership/deinit behavior.
- Existing focused iterator tests cover borrowed native `next()`, consuming
  compact `next()`, consuming native `next()`, and exact remaining/size-hint
  behavior around scalar iteration.

## Validation

Focused sequence tests:

```text
$ zig test src/seq.zig --test-filter "index vec consuming iterator owns backing"
1/1 seq.test.index vec consuming iterator owns backing...OK
All 1 tests passed.

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

S4-M802 is closed for the current bar: borrowed and consuming IndexVec iterator
`next()` calls now avoid per-step `len()`/`at()` dispatch and read directly from
active backing storage. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
