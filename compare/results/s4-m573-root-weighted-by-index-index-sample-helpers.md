# S4-M573 Root Length-Weighted Index Sample Helpers

## Gap

S4-M572 completed the root item-accessor weighted fixed-size compact `u32` index
array helpers, but callers that wanted allocation-returning no-replacement
weighted `usize` index samples from a length and comptime index-weight accessor
still had to construct a secure engine manually and call
`seq.sampleWeightedIndicesByIndex*`.

Rust `rand` exposes length-based weighted no-replacement index workflows through
`index::sample_weighted(rng, length, |index| ...)`. Alea already has the
lower-level Zig-native sequence primitive; this milestone closes the root
ergonomics gap for length-weighted `usize` index samples without adding Rust
trait-shaped API machinery.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedIndicesByIndex`
- `sampleWeightedIndicesByIndexChecked`

Both helpers take a length and a comptime index-weight accessor. The unchecked
helper returns an allocated `[]usize` with up to `amount` positive-weight
indexes; the checked helper requires enough positive-weight indexes and rejects
insufficient/all-zero requests with `error.InvalidParameter`.

Deterministic pre-entropy behavior is explicit:

- `amount == 0` returns an empty allocated index slice before validating weights
  or drawing entropy.
- Empty unchecked length with `amount > 0` returns `error.EmptyInput`.
- All-zero unchecked index weights return an empty allocated index slice.
- All-zero or insufficient checked index weights return `error.InvalidParameter`.
- A single positive index returns a one-index allocated slice before entropy is
  requested when the request can be satisfied.
- Invalid weights fail before entropy is requested.
- Multi-positive sampling uses the root secure engine and delegates to
  `seq.sampleWeightedIndicesByIndex*`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byIndexIndices=` in the dedicated
  `root weighted by no-replacement helpers` output line using a length plus a
  comptime index-weight accessor.
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

Runnable example excerpt showing the guarded root length-weighted index sample token:

```text
$ zig build run-basic | grep "root weighted by no-replacement helpers"
root weighted by no-replacement helpers: byIndexIndices={ 1, 0 }, byIndices={ 1, 2 }, byIndicesInto={ 1, 2 }, byIndicesU32={ 1, 2 }, byIndexVec={ 1, 2 }, byIndexArray={ 1, 2 }, byIndexArrayU32={ 2, 1 }, bySample=[green, blue], byInto=[green, blue], byPtrInto=[blue, green], byPtrSample=[red, blue], byMutPtrInto=[blue, red], byMutPtrSample=[green, blue]
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
roadmapcheck ok
toolingcheck ok
examplecheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M573 is closed for the current bar: root system-entropy callers can allocate
no-replacement weighted `usize` index samples directly from a length and
comptime index-weight accessor without manually constructing a secure engine or
parallel weight slice. This is API ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
