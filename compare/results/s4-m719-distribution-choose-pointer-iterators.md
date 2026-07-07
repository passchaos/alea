# S4-M719 Distribution Choose Pointer Iterators

## Gap

Distribution-layer `Choose` has fixed-size and owned pointer outputs, and index
iterators. It still lacked reusable pointer iterators, forcing callers to either
use the generic sampler iterator shape or fill buffers manually.

Distribution-layer `Choose` should expose pointer iterators directly, matching
its reference-oriented sampling role and reusable `seq.Choice` ergonomics.

## Local `rand` Baseline

The local Rust `rand` checkout exposes iterator-oriented repeated sampling
workflows over references. Alea's distribution-layer `Choose(T)` can provide
Zig-native repeated pointer iterators while preserving stream-shape consistency
with its pointer fill helpers.

## API Added

`src/distributions.zig` adds pointer iterator helpers to `Choose(T)`:

- `Choose(T).ptrIter`
- `Choose(T).ptrIterFrom`
- `Choose(T).PtrIterator`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Pointer iterators use the same stream shape as the equivalent pointer fill
  helper.
- Singleton choices yield the singleton pointer without random-stream use.

## Adoption and Documentation

- Focused distribution tests compare pointer iterator fills against the
  corresponding pointer fill helper and confirm identical stream shape.
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
toolingcheck ok
apicheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M719 is closed for the current bar: distribution-layer `Choose` now has
reusable pointer iterators aligned with its fill helpers. This is ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
