# S4-M949 Weighted Tree Checked Iterator Direct Constructors

## Gap

Dynamic `WeightedTree` and `WeightedIntTree` checked `usize` iterator constructors
still routed through unchecked iterator wrappers after validity checks. The
checked constructors can validate once and build their iterator payloads directly
while preserving stream shape and invalid-weight behavior.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows are iterator-oriented:
construct a reusable or updateable weighted sampler, then repeatedly sample
indexes from an RNG reference. Alea's dynamic weighted trees expose facade and
direct-source checked iterators; those constructors should avoid extra wrapper
hops after validation.

## Implementation

- `src/distributions.zig` updates `WeightedTree.iterChecked` and
  `WeightedTree.iterCheckedFrom` to validate `isValid()` and construct `usize`
  sample iterators directly.
- `src/distributions.zig` applies the same direct checked iterator construction to
  `WeightedIntTree.iterChecked` and `WeightedIntTree.iterCheckedFrom`.
- Focused tests compare checked facade/direct iterators against existing iterator
  stream shape and preserve invalid/single-positive behavior.

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
readmecheck ok
roadmapcheck ok
examplecheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M949 is closed for the current bar: dynamic weighted-tree checked `usize`
iterator constructors now avoid unchecked iterator wrapper aliases while
preserving stream shape and checked validation. This is reliability/ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
