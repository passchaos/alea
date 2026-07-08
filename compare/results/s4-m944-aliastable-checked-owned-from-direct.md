# S4-M944 AliasTable Checked Owned From Direct Paths

## Gap

Static `AliasTable` checked direct-source allocation-returning helpers still
routed through unchecked direct-source owned wrappers. Checked direct-source fills
were already available, so the checked owned helpers can allocate their output
slices and fill them directly while preserving stream shape, allocation-failure
behavior, and checked compact-index validation.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows commonly collect
repeated sampled indexes into owned containers after direct RNG-driven sampling.
Alea's `AliasTable` adds allocation-returning `usize` and compact `u32` direct
source helpers; the checked direct-source variants should preserve validation
while avoiding unchecked owned wrapper aliases.

## Implementation

- `src/distributions.zig` updates `AliasTable.indicesCheckedFrom` to allocate the
  `usize` slice and call checked direct-source fill directly.
- `src/distributions.zig` updates `AliasTable.indicesU32CheckedFrom` to keep
  compact output-size prevalidation, allocate the `u32` slice, and call checked
  direct-source compact fill directly.
- Focused tests compare checked direct-source owned helpers against unchecked
  direct-source owned helpers for stream shape and cover oversized compact-index
  preallocation rejection.

## Validation

Focused AliasTable tests:

```text
$ zig test src/distributions.zig --test-filter "alias table owned index batches mirror fills"
1/2 distributions.test.alias table owned index batches mirror fills...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "alias table iterators produce repeated indices"
1/2 distributions.test.alias table iterators produce repeated indices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M944 is closed for the current bar: static `AliasTable` checked direct-source
owned helpers now avoid unchecked direct-source owned wrapper aliases while
preserving stream shape, allocation behavior, and checked behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
