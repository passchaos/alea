# S4-M632 Root Weighted Value Array Empty-Type Prevalidation

## Gap

Root parallel-weighted no-replacement fixed-size value array helpers could proceed
toward secure-engine construction for non-zero requests whose value type is
uninhabited. Such requests cannot produce values and should fail before entropy.

This milestone aligns weighted fixed-size value array sampling with weighted
value sample empty-type validation.

## API Changed

`src/root.zig` now prevalidates empty value types in:

- `sampleWeightedArray`
- `sampleWeightedArrayChecked`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-size arrays still return empty arrays before validating the value type or
  drawing entropy.
- Non-zero uninhabited value type requests return `error.EmptyRange` before
  secure-engine construction when input lengths are otherwise valid.
- Length mismatch and empty input errors still keep their existing precedence.
- Deterministic all-zero and single-positive paths remain no-entropy.
- Random valid paths still sample through the existing weighted random path.

## Adoption and Documentation

- Focused root tests cover empty-type failures before entropy, zero-size
  behavior, deterministic all-zero/single paths, and failing-entropy random
  paths.
- The empty-type tests avoid formatting empty-enum arrays on unexpected success,
  so they check exact errors manually.
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
apicheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M632 is closed for the current bar: root weighted fixed-size value array
helpers now prevalidate non-zero uninhabited value types before secure-engine
construction. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
