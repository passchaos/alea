# S4-M744 Weighted Tree Checked U32 Iterator Width

## Gap

S4-M740 added checked compact `u32` iterator aliases to dynamic `WeightedTree`
and `WeightedIntTree`, and S4-M742 added invalid-state no-consumption coverage.
The focused tests still did not explicitly prove that oversized dynamic trees
reject checked compact iterator construction before random-stream use.

Dynamic weighted-tree `iterU32CheckedFrom` should have explicit no-consumption
evidence for populations that do not fit `u32`.

## Local `rand` Baseline

The local Rust `rand_distr` weighted tree workflow is index-oriented. Alea adds
compact `u32` output paths where population size permits; checked compact dynamic
tree paths must clearly reject oversized populations without consuming randomness.

## Coverage Added

`src/distributions.zig` extends the focused dynamic-tree iterator test with fake
oversized dynamic trees whose length is `maxInt(u32) + 1`. The test verifies:

- `WeightedTree(Weight).iterU32CheckedFrom` returns `error.InvalidParameter`;
- `WeightedIntTree(Weight).iterU32CheckedFrom` returns `error.InvalidParameter`;
- the random stream is unchanged after each failed checked constructor.

The fake trees are never sampled or deinitialized; they are used only to exercise
the length prevalidation branch without allocating impossible memory.

No public API changed.

## Adoption and Documentation

- Dynamic compact checked iterator width validation now has explicit
  no-consumption test evidence.
- Valid stream-shape parity and invalid all-zero tests from S4-M740/S4-M742
  remain in the same focused test.
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
readmecheck ok
roadmapcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M744 is closed for the current bar: dynamic weighted-tree checked compact
`u32` iterator construction now has explicit oversized-population no-consumption
evidence. This is reliability/validation work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
