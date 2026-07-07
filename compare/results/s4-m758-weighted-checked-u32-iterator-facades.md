# S4-M758 Weighted Checked U32 Iterator Facades

## Gap

S4-M754 fixed and covered checked `usize` iterator facades for static and
dynamic weighted samplers. The compact `u32` checked iterator facade constructors
also needed explicit facade/direct stream-shape evidence.

## Local `rand` Baseline

The local Rust weighted-index workflows are iterator-oriented. Alea's compact
`u32` iterator helpers are a Zig-native extension, and both facade `Rng` and
direct-source checked constructors should preserve deterministic stream shape.

## Coverage Added

Focused tests now compare facade checked compact iterators with direct-source
checked compact iterators for:

- `AliasTable.iterU32Checked`;
- `WeightedTree.iterU32Checked`;
- `WeightedIntTree.iterU32Checked`.

No public API changed.

## Validation

Focused distribution tests:

```text
$ zig test src/distributions.zig --test-filter "alias table iterators produce repeated indices"
1/2 distributions.test.alias table iterators produce repeated indices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/distributions.zig --test-filter "weighted tree iterators produce repeated indices"
1/2 distributions.test.weighted tree iterators produce repeated indices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M758 is closed for the current bar: static and dynamic weighted checked
compact `u32` iterator facade constructors now have focused facade/direct
stream-shape evidence. This is reliability/validation work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
