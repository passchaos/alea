# S4-M630 Root Weighted Value Sample Empty-Type Prevalidation

## Gap

Root parallel-weighted no-replacement value sample helpers could allocate output
buffers or proceed toward secure-engine construction for non-zero requests whose
value type is uninhabited. Such requests cannot produce values and should fail
before allocation or entropy.

This milestone aligns weighted value sampling with generic value batch
empty-type validation.

## API Changed

`src/root.zig` now prevalidates empty value types in:

- `sampleWeighted`
- `sampleWeightedChecked`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-amount samples still return empty allocations before validating the value
  type or drawing entropy.
- Non-zero uninhabited value type requests return `error.EmptyRange` before
  output allocation or entropy when input lengths are otherwise valid.
- Length mismatch and empty input errors still keep their existing precedence.
- Deterministic all-zero and single-positive paths remain allocation-only.
- Random valid paths still allocate/sample through the existing weighted random
  path.

## Adoption and Documentation

- Focused root tests cover empty-type failures before allocation, zero-amount
  behavior, deterministic all-zero/single paths, and failing-entropy random
  paths.
- The empty-type tests avoid formatting empty-enum values on unexpected success,
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
toolingcheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M630 is closed for the current bar: root weighted value sample helpers now
prevalidate non-zero uninhabited value types before random-output allocation and
secure-engine construction. This is reliability and ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
