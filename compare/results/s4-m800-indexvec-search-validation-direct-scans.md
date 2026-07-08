# S4-M800 IndexVec Search and Validation Direct Scans

## Gap

S4-M799 moved borrowed and consuming `IndexVec` iterator fills onto
backing-specific paths, but `IndexVec.indexOf`, `validateItems`, and
`validateDistinctItems` still called `IndexVec.at()` for each inspected item.
Those helpers are used by `contains` and checked value/pointer mapping
constructors, so repeated union dispatch remained in common diagnostic and
checked-API paths.

## Local `rand` Baseline

The local Rust checkout (`/home/passchaos/Work/rand/src/seq/index.rs`) keeps
`IndexVec` operations backing-specific: equality matches concrete variants and
iterator construction returns variant-specific backing iterators instead of
performing a fresh generic index lookup for each item. Alea keeps its broader
Zig-native checked validation surface and applies the same backing-specific
principle to search and validation scans.

## Implementation

- `src/seq.zig` updates `IndexVec.indexOf` to switch once, scan compact `u32`
  backing as `u32`, and return `null` immediately when the requested `usize`
  value cannot fit in compact backing.
- `src/seq.zig` updates `IndexVec.validateItems` to scan compact and native
  backing directly; compact backing skips per-item upper-bound checks when the
  item count exceeds every possible `u32` index.
- `src/seq.zig` updates `IndexVec.validateDistinctItems` to validate and compare
  directly against the active backing slice instead of routing each comparison
  through `at()`.
- Focused tests cover compact oversized search/contains, compact validation with
  oversized item counts, max-`u32` compact bounds, compact duplicate rejection,
  and the existing checked native/mapped consumers.

## Validation

Focused sequence tests:

```text
$ zig test src/seq.zig --test-filter "index vec maps sampled indexes"
1/1 seq.test.index vec maps sampled indexes to slice items...OK
All 1 tests passed.

$ zig test src/seq.zig --test-filter "index vec"
1/10 seq.test.index vec conversion supports native backing...OK
2/10 seq.test.index vec equality compares contents across backing types...OK
3/10 seq.test.index vec owned-slice constructors adopt backing...OK
4/10 seq.test.index vec clone preserves representation and owns copy...OK
5/10 seq.test.index vec consuming iterator owns backing...OK
6/10 seq.test.index vec consuming owned conversions transfer or narrow backing...OK
7/10 seq.test.index vec maps sampled indexes to slice items...OK
8/10 seq.test.index vec iterators fill caller-owned buffers...OK
9/10 seq.test.index vec keeps compact backing for u32 lengths...OK
10/10 root.test_0...OK
All 10 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
examplecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M800 is closed for the current bar: IndexVec search and validation helpers now
avoid per-slot `at()`/union dispatch and scan the active backing storage
directly. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
