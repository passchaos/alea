# S4-M756 Accessor Weighted Iterator Checked-From Coverage

## Gap

Accessor- and index-weighted repeated pointer iterators had facade and direct
unchecked coverage plus checked facade coverage. The direct-source checked
convenience constructors were validated for error paths but did not explicitly
compare stream shape against reusable `WeightedChoice` iterators.

## Local `rand` Baseline

The local Rust weighted slice APIs support closure/index-derived weights for
repeated reference sampling. Alea exposes Zig-native convenience constructors and
reusable `WeightedChoice` samplers; both should preserve deterministic stream
shape for direct-source checked workflows.

## Coverage Added

`src/seq.zig` tests now compare direct-source checked convenience iterators with
reusable weighted choices for:

- `chooseWeightedIterByCheckedFrom`;
- `chooseWeightedIterByIndexCheckedFrom`.

No public API changed.

## Validation

Focused sequence tests:

```text
$ zig test src/seq.zig --test-filter "accessor weighted choice iterator streams repeated const pointers"
1/2 seq.test.accessor weighted choice iterator streams repeated const pointers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "index-weighted choice iterator streams repeated const pointers"
1/2 seq.test.index-weighted choice iterator streams repeated const pointers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
examplecheck ok
apicheck ok
toolingcheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M756 is closed for the current bar: accessor- and index-weighted checked
direct-source convenience iterators now have explicit stream-shape evidence
against reusable `WeightedChoice` iterators. This is reliability/validation work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
