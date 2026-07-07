# S4-M561 Root Item-Accessor Weighted Value Sample Helpers

## Gap

S4-M558 added root item-accessor weighted value array helpers, but callers that
wanted allocation-returning no-replacement weighted value samples from
item-local weights still had to construct a secure engine manually and call
`seq.sampleWeightedBy*`.

Rust `rand`/`rand_distr` provides no-replacement weighted sequence sampling via
weighted-index workflows; Alea already has the lower-level Zig-native sequence
primitive. This milestone closes the root ergonomics gap for system-entropy
callers without adding Rust trait-shaped API machinery.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedBy`
- `sampleWeightedByChecked`

Both helpers take an item slice and a comptime item-weight accessor. The
unchecked helper returns an allocated slice with up to `amount` positive-weight
items; the checked helper requires enough positive-weight items and rejects
insufficient/all-zero requests with `error.InvalidParameter`.

Deterministic pre-entropy behavior is explicit:

- `amount == 0` returns an empty allocated slice before validating weights or
  drawing entropy.
- Empty unchecked input with `amount > 0` returns `error.EmptyInput`.
- All-zero unchecked item weights return an empty allocated slice.
- All-zero or insufficient checked item weights return `error.InvalidParameter`.
- A single positive item returns a one-element allocated slice before entropy is
  requested when the request can be satisfied.
- Invalid weights fail before entropy is requested.
- Multi-positive sampling uses the root secure engine and delegates to
  `seq.sampleWeightedBy*`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `bySample=` in a dedicated
  `root weighted by no-replacement helpers` output line using a slice of structs
  plus an item-weight accessor.
- `tools/examplecheck.zig` guards the new example tokens.
- `docs/api-reference.md` lists the new root public symbols.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused root tests:

```text
$ zig test src/root.zig --test-filter "root random helpers"
1/3 root.test_0...OK
2/3 root.test.root random helpers use explicit system entropy...OK
3/3 root.test.root random helpers validate deterministic cases before entropy...OK
All 3 tests passed.
```

Runnable example excerpt showing the guarded root item-accessor weighted sample token:

```text
$ zig build run-basic | grep "root weighted by no-replacement helpers"
root weighted by no-replacement helpers: bySample=[green, blue]
```

```text
$ zig build examplecheck
examplecheck ok
```

```text
$ zig build apicheck
apicheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

Broader native test gate:

```text
$ zig build test
examplecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M561 is closed for the current bar: root system-entropy callers can allocate
no-replacement weighted value samples directly from an item slice and comptime
item-weight accessor without manually constructing a secure engine or parallel
weight slice. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
