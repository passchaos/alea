# S4-M576 Root Length-Weighted Index Into Helpers

## Gap

S4-M575 added root length-weighted `IndexVec` sample helpers, but callers that
wanted caller-owned no-replacement weighted `usize` index buffers from a length
and comptime index-weight accessor still had to construct a secure engine
manually and call `seq.sampleWeightedIndicesByIndexInto*`.

Rust `rand` workflows commonly adapt length-based weighted no-replacement index
sampling into pre-allocated buffers. Alea already has the lower-level Zig-native
sequence primitive; this milestone closes the root ergonomics gap for
length-weighted `usize` index buffers without adding Rust trait-shaped API
machinery.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedIndicesByIndexInto`
- `sampleWeightedIndicesByIndexIntoChecked`

Both helpers take a length, caller-owned `usize` output buffer, caller-owned key
scratch buffer, and a comptime index-weight accessor. The unchecked helper fills
up to `out.len` positive-weight indexes and returns the filled count; the
checked helper requires enough positive-weight indexes to fill the output and
rejects insufficient/all-zero requests with `error.InvalidParameter`.

Deterministic pre-entropy behavior is explicit:

- `out.len == 0` returns before validating weights or drawing entropy.
- Empty unchecked length with non-empty output returns `error.EmptyInput`.
- All-zero unchecked index weights return count `0`.
- All-zero or insufficient checked index weights return `error.InvalidParameter`.
- A single positive index fills one output slot before entropy is requested when
  the request can be satisfied.
- Invalid weights fail before entropy is requested.
- Scratch buffers shorter than the output return `error.LengthMismatch` before
  entropy is requested.
- Multi-positive sampling uses the root secure engine and delegates to
  `seq.sampleWeightedIndicesByIndexInto*`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byIndexIndicesInto=` in the dedicated
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

Runnable example excerpt showing the guarded root length-weighted index-into token:

```text
$ zig build run-basic | grep "root weighted by no-replacement helpers"
root weighted by no-replacement helpers: byIndexIndices={ 1, 2 }, byIndexIndicesInto={ 2, 1 }, byIndexIndicesU32={ 2, 1 }, byIndexVecIndices={ 1, 2 }, byIndices={ 1, 2 }, byIndicesInto={ 1, 2 }, byIndicesU32={ 0, 2 }, byIndexVec={ 0, 2 }, byIndexArray={ 1, 2 }, byIndexArrayU32={ 0, 1 }, bySample=[green, blue], byInto=[green, blue], byPtrInto=[red, blue], byPtrSample=[green, blue], byMutPtrInto=[blue, red], byMutPtrSample=[green, blue]
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
toolingcheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M576 is closed for the current bar: root system-entropy callers can fill
caller-owned no-replacement weighted `usize` index buffers directly from a
length and comptime index-weight accessor without manually constructing a secure
engine or parallel weight slice. This is API ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
