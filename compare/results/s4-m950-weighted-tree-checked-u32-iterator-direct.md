# S4-M950 Weighted Tree Checked U32 Iterator Direct Constructors

## Gap

Dynamic `WeightedTree` and `WeightedIntTree` checked compact `u32` iterator
constructors still routed through checked or unchecked iterator wrappers after
validation. The checked compact constructors can validate once and build their
iterator payloads directly while preserving stream shape, width validation, and
invalid-weight behavior.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows are iterator-oriented.
Alea's compact `u32` iterators are Zig-native extensions for smaller index
buffers, and checked facade/direct-source constructors should validate then
construct iterator payloads directly.

## Implementation

- `src/distributions.zig` updates `WeightedTree.iterU32Checked` and
  `WeightedTree.iterU32CheckedFrom` to validate width and `isValid()`, then
  construct compact iterator payloads directly.
- `src/distributions.zig` applies the same direct checked compact iterator
  construction to `WeightedIntTree.iterU32Checked` and
  `WeightedIntTree.iterU32CheckedFrom`.
- Focused tests compare checked compact facade/direct iterators against existing
  compact iterator stream shape and preserve invalid/single-positive behavior.

## Validation

Focused weighted-tree test:

```text
$ zig test src/distributions.zig --test-filter "weighted tree iterators produce repeated indices"
1/2 distributions.test.weighted tree iterators produce repeated indices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
apicheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M950 is closed for the current bar: dynamic weighted-tree checked compact
iterator constructors now avoid iterator wrapper aliases while preserving stream
shape, compact width validation, and checked validation. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
