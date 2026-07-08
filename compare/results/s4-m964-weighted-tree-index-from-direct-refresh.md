# S4-M964 Weighted Tree Index From Direct Refresh

## Gap

A current-code audit found dynamic `WeightedTree.sampleIndexFrom` /
`sampleIndexU32From` and the corresponding `WeightedIntTree` helpers routing
through checked direct-source sample wrappers again. The actual current index
aliases should execute total-aware tree sampling directly while preserving stream
shape and unchecked alias semantics.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows sample indexes directly
from reusable weighted samplers. Alea's dynamic weighted trees are parity-plus
mutable weighted-index samplers, and their direct-source index aliases should
avoid checked wrapper hops in the current codebase.

## Implementation

- `src/distributions.zig` updates `WeightedTree.sampleIndexFrom` and
  `sampleIndexU32From` to validate unchecked preconditions, handle single-positive
  no-consume cases, and call `sampleWithTotalFrom` directly.
- `src/distributions.zig` applies the same direct index alias structure to
  `WeightedIntTree.sampleIndexFrom` and `sampleIndexU32From`.
- Focused tests compare dynamic tree sample/index alias stream shape and
  fixed-array/fill behavior for generic and integer weighted trees.

## Validation

Focused weighted-tree tests:

```text
$ zig test src/distributions.zig --test-filter "weighted tree index aliases mirror sample helpers"
1/2 distributions.test.weighted tree index aliases mirror sample helpers...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "weighted tree fixed index arrays mirror fills"
1/2 distributions.test.weighted tree fixed index arrays mirror fills...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M964 is closed for the current bar: dynamic weighted-tree direct-source index
aliases again match the direct total-aware sampling intent in the current
codebase while preserving stream shape. This is reliability/ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
