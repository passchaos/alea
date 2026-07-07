# S4-M586 Root Parallel-Weighted Value Array Prevalidation

## Gap

The root parallel-weighted `sampleWeightedArray` and
`sampleWeightedArrayChecked` helpers always constructed a secure engine for
non-zero arrays before delegating to `seq.sampleWeightedArray*`. The slice
sample helpers and item-accessor counterparts already prevalidate deterministic
zero/all-zero/single-positive/invalid paths first.

This milestone aligns the parallel-weighted root value array helpers with that
behavior so deterministic validation and degenerate cases do not request system
entropy.

## API Changed

`src/root.zig` now prevalidates:

- `sampleWeightedArray`
- `sampleWeightedArrayChecked`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- `N == 0` returns an empty array before validating weights or drawing entropy.
- Length mismatch returns `error.LengthMismatch` before entropy.
- Empty/all-zero unchecked weights return `null` for non-empty arrays.
- All-zero or insufficient checked weights return `error.InvalidParameter`.
- A single positive item returns a one-value array before entropy is requested
  when the request can be satisfied.
- Invalid weights fail before entropy is requested.
- Multi-positive sampling still uses the root secure engine and delegates to
  `seq.sampleWeightedArray*`.

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
toolingcheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M586 is closed for the current bar: root parallel-weighted no-replacement
value array helpers now validate deterministic no-entropy paths before secure
engine construction. This is reliability and ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
