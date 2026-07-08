# S4-M946 AliasTable Array Direct Paths

## Gap

Static `AliasTable` fixed-array helpers still routed through facade or
direct-source wrapper helpers for checked and compact `u32` variants. Fill paths
were already direct, so fixed-array helpers can allocate their stack arrays and
fill directly while preserving stream shape and compact-index validation.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows commonly collect
repeated sampled indexes into stack-owned arrays or caller-owned buffers. Alea's
`AliasTable` fixed-array helpers should be first-class direct constructors rather
than wrappers around other array helpers.

## Implementation

- `src/distributions.zig` updates `AliasTable.indexArray` and
  `indexArrayChecked` to allocate stack arrays and call facade fills directly.
- `src/distributions.zig` updates `AliasTable.indexArrayCheckedFrom` to allocate a
  stack array and call the checked direct-source fill directly.
- `src/distributions.zig` updates `AliasTable.indexArrayU32`,
  `indexArrayU32Checked`, and `indexArrayU32From` to allocate stack arrays and
  call compact facade/direct-source fills directly.
- Focused tests compare fixed arrays against fill output and checked/direct array
  stream shape, including compact `u32` cases.

## Validation

Focused AliasTable tests:

```text
$ zig test src/distributions.zig --test-filter "alias table fixed index arrays mirror fills"
1/2 distributions.test.alias table fixed index arrays mirror fills...OK
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
roadmapcheck ok
apicheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M946 is closed for the current bar: static `AliasTable` fixed-array helpers
now avoid wrapper aliases while preserving stream shape and checked compact-index
behavior. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
