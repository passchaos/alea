# S4-M567 Root Item-Accessor Weighted Index Sample Helpers

## Gap

S4-M566 completed the root item-accessor weighted mutable-pointer caller-owned
buffer helpers, but callers that wanted allocation-returning no-replacement
weighted `usize` index samples from item-local weights still had to construct a
secure engine manually and call `seq.sampleWeightedIndicesBy*`.

Rust `rand` exposes weighted no-replacement index workflows through weighted
index sampling. Alea already has the lower-level Zig-native sequence primitive;
this milestone closes the root ergonomics gap for item-accessor `usize` index
samples without adding Rust trait-shaped API machinery.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedIndicesBy`
- `sampleWeightedIndicesByChecked`

Both helpers take an item slice and a comptime item-weight accessor. The
unchecked helper returns an allocated `[]usize` with up to `amount`
positive-weight item indexes; the checked helper requires enough positive-
weight items and rejects insufficient/all-zero requests with
`error.InvalidParameter`.

Deterministic pre-entropy behavior is explicit:

- `amount == 0` returns an empty allocated index slice before validating weights
  or drawing entropy.
- Empty unchecked input with `amount > 0` returns `error.EmptyInput`.
- All-zero unchecked item weights return an empty allocated index slice.
- All-zero or insufficient checked item weights return `error.InvalidParameter`.
- A single positive item returns a one-index allocated slice before entropy is
  requested when the request can be satisfied.
- Invalid weights fail before entropy is requested.
- Multi-positive sampling uses the root secure engine and delegates to
  `seq.sampleWeightedIndicesBy*`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byIndices=` in the dedicated
  `root weighted by no-replacement helpers` output line using a slice of structs
  plus an item-weight accessor.
- `tools/examplecheck.zig` guards the new example token.
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

Runnable example excerpt showing the guarded root item-accessor weighted index sample token:

```text
$ zig build run-basic | grep "root weighted by no-replacement helpers"
root weighted by no-replacement helpers: byIndices={ 1, 2 }, bySample=[red, green], byInto=[green, blue], byPtrInto=[red, blue], byPtrSample=[red, blue], byMutPtrInto=[green, blue], byMutPtrSample=[green, blue]
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
readmecheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M567 is closed for the current bar: root system-entropy callers can allocate
no-replacement weighted `usize` index samples directly from an item slice and
comptime item-weight accessor without manually constructing a secure engine or
parallel weight slice. This is API ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
