# S4-M713 Distribution Choose Index Iterators

## Gap

Distribution-layer `Choose` now has scalar/caller-owned/owned/fixed-size usize and
u32 index outputs. It still lacked reusable index iterators, forcing callers who
want streaming repeated indexes to manually loop over scalar helpers or fill
buffers.

Distribution-layer `Choose` should expose repeated index iterators for both usize
and compact u32 outputs, matching reusable sampler ergonomics in `seq.Choice`.

## Local `rand` Baseline

The local Rust `rand` checkout exposes iterator-oriented repeated sampling
workflows. Alea's distribution-layer `Choose(T)` can provide equivalent
Zig-native repeated index iterators while preserving stream-shape consistency
with its fill helpers.

## API Added

`src/distributions.zig` adds index iterator helpers to `Choose(T)`:

- `Choose(T).indexIter`
- `Choose(T).indexIterFrom`
- `Choose(T).indexIterU32`
- `Choose(T).indexIterU32From`
- `Choose(T).IndexIterator`
- `Choose(T).U32IndexIterator`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Index iterators use the same stream shape as the equivalent index fill helper.
- Singleton choices yield zero without random-stream use.
- u32 iterators return `error.InvalidParameter` for oversized item sets.

## Adoption and Documentation

- Focused distribution tests compare usize and u32 index iterator fills against
  the corresponding fill helpers and cover singleton no-consumption behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
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
apicheck ok
examplecheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M713 is closed for the current bar: distribution-layer `Choose` now has usize
and u32 repeated index iterators aligned with its fill helpers. This is
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
