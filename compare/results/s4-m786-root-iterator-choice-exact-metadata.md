# S4-M786 Root Iterator Choice Exact Metadata Reuse

## Gap

Root unweighted iterator choice helpers use one shared `rootChooseIterator` core.
Before this milestone the core queried exact remaining once for empty detection,
again for hinted selection, and again for stable reservoir exact-size selection.
Iterators with observable or non-trivial `remaining`, `len`, or exact `sizeHint`
methods could therefore be probed multiple times before a one-shot choice.

## Local `rand` Baseline

Rust `IteratorRandom::choose` uses iterator size information where available.
Alea exposes both hint-sensitive and stable root helpers; it can query exact
remaining once, reuse it across empty/hinted/stable branches, and preserve the
existing no-entropy and stream-shape behavior.

## Implementation

- `src/root.zig` caches `rootIteratorExactRemaining` in `rootChooseIterator`.
- The cached metadata is reused for empty exact sources, hinted exact-size choice,
  and stable reservoir exact-size choice.
- Focused root tests count `remaining` calls for singleton, multi-item choice,
  and stable choice paths while preserving exact read counts and no-entropy /
  failing-entropy behavior.

## Validation

Focused root test:

```text
$ zig test src/root.zig --test-filter "root random helpers validate deterministic cases before entropy"
1/2 root.test_0...OK
2/2 root.test.root random helpers validate deterministic cases before entropy...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
toolingcheck ok
readmecheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M786 is closed for the current bar: root unweighted iterator choice helpers
now reuse exact remaining metadata across branch decisions, avoiding duplicate
size-hint/remaining probes while preserving behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
