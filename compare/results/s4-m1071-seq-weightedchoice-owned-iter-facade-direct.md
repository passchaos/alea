# S4-M1071 Seq WeightedChoice Owned Iterator Facade Direct Path

## Gap

Sequence-layer reusable `WeightedChoice(T).ownedIter` still constructed its facade
iterator by delegating through `ownedIterFrom(rng)`. The direct-source owned
iterator constructor remains useful for explicit source workflows, but the facade
constructor can build the iterator directly with the supplied facade `Rng`.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for repeated weighted
choice iterator behavior. Alea's owned iterator keeps the reusable weighted
choice state in the iterator and exposes explicit cleanup; this change tightens
the facade constructor without changing the iterator sampling contract.

## Implementation

- `src/seq.zig` updates `WeightedChoice(T).ownedIter` to return the iterator
  literal with `.source = rng` and `.choice = self` directly.
- `WeightedChoice(T).ownedIterFrom` remains unchanged for explicit direct-source
  workflows.

## Validation

Focused seq WeightedChoice tests:

```text
$ zig test src/seq.zig --test-filter "weighted choice iterator streams repeated const pointers"
1/4 seq.test.weighted choice iterator streams repeated const pointers...OK
2/4 seq.test.accessor weighted choice iterator streams repeated const pointers...OK
3/4 seq.test.index-weighted choice iterator streams repeated const pointers...OK
4/4 root.test_0...OK
All 4 tests passed.

$ zig test src/seq.zig --test-filter "single-positive weighted choice does not consume random stream"
1/2 seq.test.single-positive weighted choice does not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
apicheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M1071 is closed for the current bar: sequence-layer reusable
`WeightedChoice(T).ownedIter` now avoids the direct-source constructor wrapper
alias while preserving iterator stream shape and single-positive behavior. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
