# S4-M568 Root Item-Accessor Weighted Compact U32 Index Sample Helpers

## Gap

S4-M567 added root item-accessor weighted allocation-returning `usize` index
sample helpers, but callers that wanted compact no-replacement weighted `u32`
index samples from item-local weights still had to construct a secure engine
manually and call `seq.sampleWeightedIndicesU32By*`.

Rust `rand` exposes weighted no-replacement index workflows through weighted
index sampling. Alea already has the lower-level Zig-native sequence primitive;
this milestone closes the root ergonomics gap for compact item-accessor index
samples without adding Rust trait-shaped API machinery.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedIndicesU32By`
- `sampleWeightedIndicesU32ByChecked`

Both helpers take an item slice and a comptime item-weight accessor. The
unchecked helper returns an allocated `[]u32` with up to `amount`
positive-weight item indexes; the checked helper requires enough positive-
weight items and rejects insufficient/all-zero requests with
`error.InvalidParameter`. Both helpers reject item slices longer than
`maxInt(u32)` before attempting to sample.

Deterministic pre-entropy behavior is explicit:

- `amount == 0` returns an empty allocated index slice before validating weights
  or drawing entropy.
- Empty unchecked input with `amount > 0` returns `error.EmptyInput`.
- Oversized input slices return `error.InvalidParameter` before entropy.
- All-zero unchecked item weights return an empty allocated index slice.
- All-zero or insufficient checked item weights return `error.InvalidParameter`.
- A single positive item returns a one-index allocated slice before entropy is
  requested when the request can be satisfied.
- Invalid weights fail before entropy is requested.
- Multi-positive sampling uses the root secure engine and delegates to
  `seq.sampleWeightedIndicesU32By*`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byIndicesU32=` in the dedicated
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

Runnable example excerpt showing the guarded root item-accessor weighted compact u32 index sample token:

```text
$ zig build run-basic | grep "root weighted by no-replacement helpers"
root weighted by no-replacement helpers: byIndices={ 1, 2 }, byIndicesU32={ 1, 2 }, bySample=[blue, green], byInto=[red, blue], byPtrInto=[red, blue], byPtrSample=[red, blue], byMutPtrInto=[red, green], byMutPtrSample=[green, blue]
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
apicheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M568 is closed for the current bar: root system-entropy callers can allocate
no-replacement weighted compact `u32` index samples directly from an item slice
and comptime item-weight accessor without manually constructing a secure engine
or parallel weight slice. This is API ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
