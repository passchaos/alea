# S4-M563 Root Item-Accessor Weighted Mutable-Pointer Sample Helpers

## Gap

S4-M562 added root item-accessor weighted const-pointer sample helpers, but
callers that wanted allocation-returning no-replacement weighted `*T` samples
from mutable item-local weights still had to construct a secure engine manually
and call `seq.sampleWeightedMutPtrsBy*`.

Rust `rand`/`rand_distr` exposes weighted no-replacement workflows through
weighted index sampling. Alea already has the lower-level Zig-native sequence
primitive; this milestone closes the root ergonomics gap for writable borrowed
samples without adding Rust trait-shaped API machinery.

## API Added

`src/root.zig` now exposes:

- `sampleWeightedMutPtrsBy`
- `sampleWeightedMutPtrsByChecked`

Both helpers take a mutable item slice and a comptime item-weight accessor. The
unchecked helper returns an allocated slice of mutable pointers with up to
`amount` positive-weight items; the checked helper requires enough
positive-weight items and rejects insufficient/all-zero requests with
`error.InvalidParameter`.

Deterministic pre-entropy behavior is explicit:

- `amount == 0` returns an empty allocated mutable-pointer slice before
  validating weights or drawing entropy.
- Empty unchecked input with `amount > 0` returns `error.EmptyInput`.
- All-zero unchecked item weights return an empty allocated mutable-pointer
  slice.
- All-zero or insufficient checked item weights return `error.InvalidParameter`.
- A single positive item returns a one-pointer allocated slice before entropy is
  requested when the request can be satisfied.
- Invalid weights fail before entropy is requested.
- Multi-positive sampling uses the root secure engine and delegates to
  `seq.sampleWeightedMutPtrsBy*`.

The focused deterministic test writes through a returned pointer on the
single-positive path to prove callers receive mutable borrows into the original
slice.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byMutPtrSample=` in the dedicated
  `root weighted by no-replacement helpers` output line using a mutable slice of
  structs plus an item-weight accessor.
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

Runnable example excerpt showing the guarded root item-accessor weighted mutable-pointer sample token:

```text
$ zig build run-basic | grep "root weighted by no-replacement helpers"
root weighted by no-replacement helpers: bySample=[green, blue], byPtrSample=[blue, red], byMutPtrSample=[red, blue]
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
roadmapcheck ok
examplecheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M563 is closed for the current bar: root system-entropy callers can allocate
no-replacement weighted mutable-pointer samples directly from a mutable item
slice and comptime item-weight accessor without manually constructing a secure
engine or parallel weight slice. This is API ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
