# S4-M760 Seq Checked Iterator Exact-Remaining Prevalidation

## Gap

Root-level checked iterator sampling already used exact `remaining` / `sizeHint`
information to reject sources that are too short before allocation or entropy.
The `seq` checked iterator sampling helpers did not use the same prevalidation,
so exact-size short iterators could be partially consumed, allocate output, or
reach random-stream code before reporting `error.InvalidParameter`.

## Local `rand` Baseline

The local Rust iterator sampling APIs respect exact-size iterator information
where available. Alea's Zig-native iterator helpers should use exact hints to
fail early for checked requests that cannot be satisfied.

## Implementation

`src/seq.zig` now prevalidates exact remaining counts before sampling in:

- `sampleIteratorCheckedFrom`;
- `sampleIteratorIntoCheckedFrom`;
- `sampleIteratorFillCheckedFrom` (via `sampleIteratorIntoCheckedFrom`);
- `sampleIteratorArrayCheckedFrom`;
- `sampleIteratorWeightedCheckedFrom`;
- `sampleIteratorWeightedIntoCheckedFrom`;
- `sampleIteratorWeightedArrayCheckedFrom`.

## Validation

Focused sequence tests:

```text
$ zig test src/seq.zig --test-filter "checked iterator samples use exact remaining"
1/2 seq.test.checked iterator samples use exact remaining before allocation...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "checked weighted iterator samples use exact remaining"
1/2 seq.test.checked weighted iterator samples use exact remaining before allocation...OK
2/2 root.test_0...OK
All 2 tests passed.
```

The tests use exact-remaining iterators and verify invalid checked requests fail
before allocation, iterator consumption, or random-stream use.

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
toolingcheck ok
examplecheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M760 is closed for the current bar: checked iterator sampling helpers now use
exact remaining information to reject impossible requests before allocation,
iterator consumption, or random-stream use. This is reliability/validation work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
