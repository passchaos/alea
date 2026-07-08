# S4-M951 Weighted Tree Owned Facade Direct Paths

## Gap

Dynamic `WeightedTree` and `WeightedIntTree` allocation-returning facade helpers
still routed through direct-source owned wrappers. Facade fills were already
available, so owned facade helpers can allocate their output slices and fill them
directly while preserving stream shape, allocation-failure behavior, invalid
weight validation, and compact-index validation.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows commonly collect
repeated sampled indexes into owned containers after RNG-driven sampling. Alea's
dynamic weighted trees add allocation-returning `usize` and compact `u32` facade
helpers; those facade variants should allocate and fill directly through the
facade `Rng` instead of routing through direct-source owned wrappers.

## Implementation

- `src/distributions.zig` updates `WeightedTree.indices`, `indicesChecked`,
  `indicesU32`, and `indicesU32Checked` to allocate output slices and call facade
  fills directly after required validation.
- `src/distributions.zig` applies the same direct allocation/fill structure to
  `WeightedIntTree`.
- Focused tests compare facade owned helpers against direct-source owned helpers
  for stream shape and preserve invalid/single-positive/compact behavior.

## Validation

Focused weighted-tree tests:

```text
$ zig test src/distributions.zig --test-filter "weighted tree iterators produce repeated indices"
1/2 distributions.test.weighted tree iterators produce repeated indices...OK
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
examplecheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M951 is closed for the current bar: dynamic weighted-tree owned facade helpers
now avoid direct-source owned wrapper aliases while preserving stream shape,
allocation behavior, invalid-weight validation, and compact-index behavior. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
