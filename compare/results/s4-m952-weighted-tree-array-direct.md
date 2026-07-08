# S4-M952 Weighted Tree Array Direct Paths

## Gap

Dynamic `WeightedTree` and `WeightedIntTree` fixed-array helpers still routed
through facade or direct-source wrapper helpers for checked and compact `u32`
variants. Fill paths were already direct, so fixed-array helpers can allocate
their stack arrays and fill directly while preserving stream shape, invalid
weight validation, and compact-index validation.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows commonly collect
repeated sampled indexes into stack-owned arrays or caller-owned buffers. Alea's
dynamic weighted-tree fixed-array helpers should be first-class direct
constructors rather than wrappers around other array helpers.

## Implementation

- `src/distributions.zig` updates `WeightedTree.indexArray`, `indexArrayChecked`,
  `indexArrayU32`, `indexArrayU32Checked`, and `indexArrayU32From` to construct
  stack arrays and call facade/direct-source fills directly.
- `src/distributions.zig` applies the same direct fixed-array construction to
  `WeightedIntTree`.
- Focused tests compare fixed arrays against fill output and checked/direct array
  stream shape, including compact `u32` cases.

## Validation

Focused weighted-tree tests:

```text
$ zig test src/distributions.zig --test-filter "weighted tree fixed index arrays mirror fills"
1/2 distributions.test.weighted tree fixed index arrays mirror fills...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "weighted tree owned index batches mirror fills"
1/2 distributions.test.weighted tree owned index batches mirror fills...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M952 is closed for the current bar: dynamic weighted-tree fixed-array helpers
now avoid wrapper aliases while preserving stream shape, invalid-weight
validation, and checked compact-index behavior. This is reliability/ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
