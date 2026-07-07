# S4-M585 Root Parallel-Weighted Mutable-Pointer Sample Prevalidation

## Gap

The root parallel-weighted `sampleWeightedMutPtrs` and
`sampleWeightedMutPtrsChecked` helpers always constructed a secure engine for
non-zero requests before delegating to `seq.sampleWeightedMutPtrs*`. The value
and const-pointer sample helpers and item-accessor counterparts already
prevalidate deterministic zero/all-zero/single-positive/invalid paths first.

This milestone aligns the parallel-weighted root mutable-pointer sample helpers
with that behavior so deterministic validation and degenerate cases do not
request system entropy.

## API Changed

`src/root.zig` now prevalidates:

- `sampleWeightedMutPtrs`
- `sampleWeightedMutPtrsChecked`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- `amount == 0` returns an empty allocated pointer slice before validating
  weights or drawing entropy.
- Length mismatch returns `error.LengthMismatch` before entropy.
- Empty unchecked input with `amount > 0` returns `error.EmptyInput`.
- All-zero unchecked weights return an empty allocated pointer slice.
- All-zero or insufficient checked weights return `error.InvalidParameter`.
- A single positive item returns a one-pointer allocated slice before entropy is
  requested when the request can be satisfied.
- Invalid weights fail before entropy is requested.
- Multi-positive sampling still uses the root secure engine and delegates to
  `seq.sampleWeightedMutPtrs*`.

The focused deterministic test writes through a returned pointer on the
single-positive path to prove callers receive mutable borrows into the original
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
roadmapcheck ok
toolingcheck ok
readmecheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M585 is closed for the current bar: root parallel-weighted no-replacement
mutable-pointer sample helpers now validate deterministic no-entropy paths
before secure engine construction. This is reliability and ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
