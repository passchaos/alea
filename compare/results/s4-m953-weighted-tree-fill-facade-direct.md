# S4-M953 Weighted Tree Fill Facade Direct Paths

## Gap

Dynamic `WeightedTree` and `WeightedIntTree` facade fill helpers still routed
through checked facade or direct-source fill wrappers. The direct total-aware fill
kernels were already available, so facade fills can validate once and call those
kernels directly while preserving stream shape, zero-length no-validation
behavior, invalid-weight behavior, and compact-index validation.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows fill repeated sampled
indexes by looping over RNG-driven weighted samples. Alea's dynamic weighted-tree
facade fills provide caller-owned buffers for `usize` and compact `u32` outputs;
those facade variants should fill directly through the facade `Rng` instead of
routing through wrapper helpers.

## Implementation

- `src/distributions.zig` updates `WeightedTree.fill`, `fillIndices`,
  `fillChecked`, `fillIndicesChecked`, `fillU32`, `fillIndicesU32`,
  `fillU32Checked`, and `fillIndicesU32Checked` to validate and fill directly.
- `src/distributions.zig` applies the same direct facade fill structure to
  `WeightedIntTree`.
- Focused tests compare facade array/fill stream shape and preserve zero-length
  no-validation/no-consumption behavior.

## Validation

Focused weighted-tree tests:

```text
$ zig test src/distributions.zig --test-filter "weighted tree fixed index arrays mirror fills"
1/2 distributions.test.weighted tree fixed index arrays mirror fills...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length weighted tree fills do not validate or consume random stream"
1/2 distributions.test.zero-length weighted tree fills do not validate or consume random stream...OK
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
examplecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M953 is closed for the current bar: dynamic weighted-tree facade fill helpers
now avoid checked/direct-source fill wrapper aliases while preserving stream
shape and checked behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
