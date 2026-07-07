# S4-M757 Parallel Weighted Iterator Checked-From Coverage

## Gap

S4-M756 added direct-source checked convenience iterator coverage for accessor-
and index-weighted repeated pointer streams. The parallel-weighted convenience
constructor `chooseWeightedIterCheckedFrom` still lacked the same direct-source
stream-shape comparison against reusable `WeightedChoice`.

## Local `rand` Baseline

The local Rust weighted slice APIs provide repeated weighted reference streams.
Alea exposes parallel-weight convenience constructors and reusable
`WeightedChoice`; checked direct-source convenience paths should preserve the
same deterministic stream shape as the reusable sampler.

## Coverage Added

`src/seq.zig` now tests `chooseWeightedIterCheckedFrom` against direct
`WeightedChoice.iterFrom` using matching engine seeds. No public API changed.

## Validation

Focused sequence test:

```text
$ zig test src/seq.zig --test-filter "weighted choice iterator streams repeated const pointers"
1/4 seq.test.weighted choice iterator streams repeated const pointers...OK
2/4 seq.test.accessor weighted choice iterator streams repeated const pointers...OK
3/4 seq.test.index-weighted choice iterator streams repeated const pointers...OK
4/4 root.test_0...OK
All 4 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
examplecheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M757 is closed for the current bar: the parallel-weight checked direct-source
convenience iterator now has explicit stream-shape evidence against reusable
`WeightedChoice`. This is reliability/validation work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
