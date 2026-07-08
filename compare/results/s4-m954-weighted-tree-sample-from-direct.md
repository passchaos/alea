# S4-M954 Weighted Tree Sample From Direct Paths

## Gap

Dynamic `WeightedTree.sampleFrom` / `sampleU32From` and the corresponding
`WeightedIntTree` helpers still routed through checked direct-source sample
wrappers. Checked scalar aliases were already direct, so the unchecked canonical
direct-source sample helpers can execute the same total-aware sampling branches
directly while preserving stream shape and unchecked semantics.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows sample indexes directly
from reusable weighted samplers. Alea's dynamic weighted trees extend this model
with mutable weighted-index samplers; canonical direct-source samples should walk
the tree directly rather than entering checked wrapper helpers first.

## Implementation

- `src/distributions.zig` updates `WeightedTree.sampleFrom` and `sampleU32From` to
  validate the unchecked preconditions, handle single-positive no-consume cases,
  and call `sampleWithTotalFrom` directly.
- `src/distributions.zig` applies the same direct sample structure to
  `WeightedIntTree.sampleFrom` and `sampleU32From`.
- Focused tests compare sample/index alias stream shape and fixed-array/fill
  behavior for generic and integer dynamic weighted trees.

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
roadmapcheck ok
toolingcheck ok
apicheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M954 is closed for the current bar: dynamic weighted-tree canonical
direct-source sample helpers now avoid checked sample wrapper aliases while
preserving stream shape and single-positive behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
