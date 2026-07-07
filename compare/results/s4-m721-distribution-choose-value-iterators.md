# S4-M721 Distribution Choose Value Iterators

## Gap

Distribution-layer `Choose` has value fills, owned values, fixed arrays, and
pointer/index iterators. It still lacked reusable value iterators, forcing callers
who want streaming repeated values to manually loop over scalar value helpers or
fill buffers.

Distribution-layer `Choose` should expose value iterators directly, matching its
value-output helpers and reusable `seq.Choice` ergonomics.

## Local `rand` Baseline

The local Rust `rand` checkout exposes iterator-oriented repeated sampling
workflows. Alea's distribution-layer `Choose(T)` can provide Zig-native repeated
value iterators while preserving stream-shape consistency with its value fill
helpers.

## API Added

`src/distributions.zig` adds value iterator helpers to `Choose(T)`:

- `Choose(T).valueIter`
- `Choose(T).valueIterFrom`
- `Choose(T).ValueIterator`
- `Choose(T).ValueIterator.nextValue`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Value iterators use the same stream shape as the equivalent value fill helper.
- Empty enum-containing value iterators return `null` from `next` before
  random-stream use or value copying.
- Singleton choices yield the singleton value without random-stream use.

## Adoption and Documentation

- Focused distribution tests compare value iterator fills against the
  corresponding value fill helper and confirm identical stream shape. Empty-type
  iterator no-consumption behavior is also covered.
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
roadmapcheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M721 is closed for the current bar: distribution-layer `Choose` now has
reusable value iterators aligned with its fill helpers. This is ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
