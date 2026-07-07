# S4-M742 Weighted Tree Invalid Checked Iterators

## Gap

S4-M740 added checked iterator constructors to dynamic `WeightedTree` and
`WeightedIntTree`. The implementation validates `isValid()` before constructing
iterators, but focused tests only covered valid stream-shape parity. Since dynamic
trees can become invalid sampling sources, the checked iterator contract needs
explicit no-consume evidence for invalid trees.

Checked dynamic-tree iterator construction should reject invalid sampling state
before random-stream use.

## Local `rand` Baseline

The local Rust `rand_distr` weighted tree workflow exposes fallible update and
sampling readiness concepts for dynamic weighted indexes. Alea's checked dynamic
tree APIs should make invalid runtime state deterministic and observable without
consuming random streams.

## Coverage Added

`src/distributions.zig` extends the focused dynamic-tree iterator test to cover:

- `WeightedTree(Weight).iterCheckedFrom` on all-zero invalid trees;
- `WeightedTree(Weight).iterU32CheckedFrom` on all-zero invalid trees;
- `WeightedIntTree(Weight).iterCheckedFrom` on all-zero invalid trees;
- `WeightedIntTree(Weight).iterU32CheckedFrom` on all-zero invalid trees.

Each path returns `error.InvalidWeight` before random-stream use.

No public API changed.

## Adoption and Documentation

- Invalid checked iterator constructors now have explicit no-consumption tests.
- Valid stream-shape parity tests from S4-M740 remain in the same focused test.
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
toolingcheck ok
roadmapcheck ok
readmecheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M742 is closed for the current bar: dynamic weighted-tree checked iterator
constructors now have explicit invalid-state no-consumption evidence. This is
reliability/validation work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
