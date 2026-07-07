# S4-M715 Distribution Choose Probability Introspection

## Gap

Distribution-layer `Choose` now exposes item and index introspection helpers. It
still lacked documented/tested probability introspection on the sampler object,
which is useful for diagnostics and parity with reusable sampler metadata.

Distribution-layer `Choose` should expose probability lookup, owned/caller-owned
probability output, and probability iteration with size hints.

## Local `rand` Baseline

The local Rust `rand` checkout exposes slice/distribution metadata through the
underlying slices and weighted distributions. Alea's distribution-layer
`Choose(T)` wraps a uniform choice over a slice, so each item has probability
`1 / len`; exposing this directly improves Zig-native diagnostics and sampler
introspection.

## API Added / Documented

`src/distributions.zig` now exposes probability metadata helpers on `Choose(T)`:

- `Choose(T).probabilityAt`
- `Choose(T).probability`
- `Choose(T).probabilityIter`
- `Choose(T).ProbabilityIterator`
- `Choose(T).probabilities`
- `Choose(T).probabilitiesInto`
- `distributions.SizeHint`

`docs/api-reference.md` lists the public symbols. Existing APIs are unchanged.

Deterministic behavior is explicit:

- `probabilityAt` returns `error.InvalidParameter` for out-of-range indexes.
- `probability` returns `null` for out-of-range indexes.
- `probabilitiesInto` returns `error.InvalidLength` for destination length
  mismatch.
- `ProbabilityIterator` reports exact remaining counts through `remaining`,
  `len`, and `sizeHint`.

## Adoption and Documentation

- Focused distribution tests cover scalar probability lookup, optional lookup,
  owned/caller-owned probability output, iterator fill, exact size hints, and
  invalid-length/index errors.
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
examplecheck ok
apicheck ok
toolingcheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M715 is closed for the current bar: distribution-layer `Choose` now exposes
probability introspection, owned/caller-owned probability output, and exact-size
probability iteration. This is ergonomics/diagnostics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
