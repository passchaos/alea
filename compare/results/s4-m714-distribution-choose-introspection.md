# S4-M714 Distribution Choose Introspection

## Gap

Distribution-layer `Choose` now has repeated value, pointer, and index outputs,
but it still lacked the item/introspection helpers available on reusable
`seq.Choice`, forcing users to inspect the original slice separately for common
metadata and item lookup workflows.

Distribution-layer `Choose` should expose basic item metadata and lookup helpers
so sampler-centric code can stay on the sampler object.

## Local `rand` Baseline

The local Rust `rand` checkout exposes slice choice APIs over caller-owned slices;
callers can inspect the slice directly. Alea's reusable `Choose(T)` object wraps
that slice, so Zig-native ergonomics are improved by exposing item metadata and
lookup helpers on the sampler.

## API Added

`src/distributions.zig` adds introspection helpers to `Choose(T)`:

- `Choose(T).constantIndex`
- `Choose(T).itemAt`
- `Choose(T).item`
- `Choose(T).get`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- `constantIndex` returns `0` only for singleton choices.
- `itemAt` / `item` return `error.InvalidParameter` for out-of-range indexes.
- `get` returns `null` for out-of-range indexes.

## Adoption and Documentation

- Focused distribution tests cover `constantIndex`, checked item lookup, optional
  item lookup, and singleton constant-index behavior.
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
readmecheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M714 is closed for the current bar: distribution-layer `Choose` now exposes
basic item introspection and lookup helpers on the sampler. This is ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
