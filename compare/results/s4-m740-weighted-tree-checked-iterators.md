# S4-M740 Weighted Tree Checked Iterators

## Gap

Static `AliasTable`, reusable `WeightedChoice`, and distribution-layer `Choose`
now expose checked iterator aliases for repeated weighted/index sampling.
Dynamic `WeightedTree` and `WeightedIntTree` still exposed only unchecked
`iter*` / `iterU32*` iterator constructors, even though dynamic trees can enter
runtime-invalid sampling states after updates and already have checked scalar,
fill, owned, and fixed-array index paths.

Dynamic weighted trees should provide checked iterator aliases that validate
sampling readiness and compact `u32` width before constructing iterators.

## Local `rand` Baseline

The local Rust `rand_distr` weighted tree workflow exposes reusable dynamic
weighted index sampling. Alea's dynamic weighted trees already provide repeated
`usize` and compact `u32` iterator helpers; checked aliases make those paths
explicit and align naming with static and reusable weighted samplers.

## API Added

`src/distributions.zig` adds checked iterator aliases to both dynamic tree types:

- `WeightedTree(Weight).iterChecked`
- `WeightedTree(Weight).iterCheckedFrom`
- `WeightedTree(Weight).iterU32Checked`
- `WeightedTree(Weight).iterU32CheckedFrom`
- `WeightedIntTree(Weight).iterChecked`
- `WeightedIntTree(Weight).iterCheckedFrom`
- `WeightedIntTree(Weight).iterU32Checked`
- `WeightedIntTree(Weight).iterU32CheckedFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Checked `usize` iterator aliases preserve `iterFrom` stream shape after
  validating `isValid()`.
- Checked compact `u32` iterator aliases preserve `iterU32From` stream shape
  after validating both `isValid()` and length fitting in `u32`.
- Invalid dynamic trees return `error.InvalidWeight` before random-stream use.

## Adoption and Documentation

- Focused dynamic-tree tests compare checked and unchecked `usize` / compact
  `u32` iterator scalar draws for generic `WeightedTree` and integer
  `WeightedIntTree` stream parity.
- Existing iterator tests continue to cover fill behavior and single-positive
  no-consumption paths.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "weighted tree iterators produce repeated indices"
1/2 distributions.test.weighted tree iterators produce repeated indices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

No output.

Broader native test gate:

```text
$ zig build test
roadmapcheck ok
toolingcheck ok
apicheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M740 is closed for the current bar: dynamic `WeightedTree` and
`WeightedIntTree` now have checked iterator aliases for `usize` and compact
`u32` index iterators. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
