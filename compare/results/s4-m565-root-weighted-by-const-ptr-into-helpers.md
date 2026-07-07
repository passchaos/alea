# S4-M565 Root Item-Accessor Weighted Const-Pointer Into Helpers

## Gap

S4-M564 added root item-accessor weighted value buffer helpers, but callers that
wanted caller-owned no-replacement weighted `*const T` buffers from item-local
weights still had to construct a secure engine manually and call
`seq.sampleWeightedPtrsByInto*`.

Rust `rand` workflows commonly adapt weighted no-replacement sampling into
pre-allocated borrowed-output buffers. Alea already has the lower-level
Zig-native sequence primitive; this milestone closes the root ergonomics gap
for const-pointer buffers without adding Rust trait-shaped API machinery.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedPtrsByInto`
- `sampleWeightedPtrsByIntoChecked`

Both helpers take an item slice, caller-owned const-pointer output buffer,
caller-owned index/key scratch buffers, and a comptime item-weight accessor. The
unchecked helper fills up to `out.len` positive-weight item pointers and returns
the filled count; the checked helper requires enough positive-weight items to
fill the output and rejects insufficient/all-zero requests with
`error.InvalidParameter`.

Deterministic pre-entropy behavior is explicit:

- `out.len == 0` returns before validating weights or drawing entropy.
- Empty unchecked input with non-empty output returns `error.EmptyInput`.
- All-zero unchecked item weights return count `0`.
- All-zero or insufficient checked item weights return `error.InvalidParameter`.
- A single positive item fills one pointer before entropy is requested when the
  request can be satisfied.
- Invalid weights fail before entropy is requested.
- Scratch buffers shorter than the output return `error.LengthMismatch` before
  entropy is requested.
- Multi-positive sampling uses the root secure engine and delegates to
  `seq.sampleWeightedPtrsByInto*`.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byPtrInto=` in the dedicated
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

Runnable example excerpt showing the guarded root item-accessor weighted const-pointer-into token:

```text
$ zig build run-basic | grep "root weighted by no-replacement helpers"
root weighted by no-replacement helpers: bySample=[green, blue], byInto=[green, blue], byPtrInto=[blue, green], byPtrSample=[red, blue], byMutPtrSample=[red, blue]
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
toolingcheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M565 is closed for the current bar: root system-entropy callers can fill
caller-owned no-replacement weighted const-pointer buffers directly from an item
slice and comptime item-weight accessor without manually constructing a secure
engine or parallel weight slice. This is API ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
