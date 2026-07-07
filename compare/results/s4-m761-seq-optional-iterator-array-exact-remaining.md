# S4-M761 Seq Optional Iterator Array Exact-Remaining Prevalidation

## Gap

S4-M760 tightened checked iterator sampling helpers using exact `remaining` /
`sizeHint` information. The optional fixed-size iterator array helpers could use
the same exact-short signal to return `null` before consuming the iterator or
random stream.

## Local `rand` Baseline

The local Rust iterator sampling APIs use exact-size iterator information where
available. Alea's optional fixed-size iterator array helpers can similarly avoid
unnecessary iterator consumption when the source is known to be too short.

## Implementation

`src/seq.zig` now prevalidates exact remaining counts in:

- `sampleIteratorArrayFrom`;
- `sampleIteratorWeightedArrayFrom`.

If an exact `remaining`/`sizeHint` proves the iterator cannot produce `N` items,
the helper returns `null` before consuming the iterator or using randomness.

## Validation

Focused sequence tests:

```text
$ zig test src/seq.zig --test-filter "optional iterator arrays use exact remaining"
1/2 seq.test.optional iterator arrays use exact remaining before consuming...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "optional weighted iterator arrays use exact remaining"
1/2 seq.test.optional weighted iterator arrays use exact remaining before consuming...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
apicheck ok
toolingcheck ok
readmecheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M761 is closed for the current bar: optional unweighted and weighted
fixed-size iterator array helpers now use exact remaining information to return
`null` before consuming exact-size short sources. This is reliability/validation
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
