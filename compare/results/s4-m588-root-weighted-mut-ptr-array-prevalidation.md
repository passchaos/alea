# S4-M588 Root Parallel-Weighted Mutable-Pointer Array Prevalidation

## Gap

The root parallel-weighted `sampleWeightedMutPtrArray` and
`sampleWeightedMutPtrArrayChecked` helpers constructed a secure engine for
non-zero arrays before delegating to `seq.sampleWeightedMutPtrArray*`. The value
and const-pointer array helpers and item-accessor counterparts already
prevalidate deterministic zero/all-zero/single-positive/invalid paths first.

This milestone aligns the parallel-weighted root mutable-pointer array helpers
with that behavior so deterministic validation and degenerate cases do not
request system entropy.

## API Changed

`src/root.zig` now prevalidates:

- `sampleWeightedMutPtrArray`
- `sampleWeightedMutPtrArrayChecked`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- `N == 0` returns an empty pointer array before validating weights or drawing
  entropy.
- Length mismatch returns `error.LengthMismatch` before entropy.
- Empty/all-zero unchecked weights return `null` for non-empty arrays.
- All-zero or insufficient checked weights return `error.InvalidParameter`.
- A single positive item returns a one-pointer array before entropy is requested
  when the request can be satisfied.
- Invalid weights fail before entropy is requested.
- Multi-positive sampling still uses the root secure engine and delegates to
  `seq.sampleWeightedMutPtrArray*`.

The focused deterministic test writes through returned pointers on the
single-positive paths to prove callers receive mutable borrows into the original
slice.

## Adoption and Documentation

- Focused root tests cover deterministic no-entropy behavior for all new
  prevalidation paths.
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
roadmapcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M588 is closed for the current bar: root parallel-weighted no-replacement
mutable-pointer array helpers now validate deterministic no-entropy paths before
secure engine construction. This is reliability and ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
