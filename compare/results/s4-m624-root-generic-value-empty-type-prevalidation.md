# S4-M624 Root Generic Value Empty-Type Prevalidation

## Gap

Root generic value scalar/fill/sample helpers could construct a secure engine
before reporting uninhabited output value types. Such requests cannot produce
values and should fail before entropy is requested for scalar and non-empty fill
requests.

This milestone aligns generic scalar/fill/sample behavior with root value batch
empty-type validation.

## API Changed

`src/root.zig` now prevalidates:

- `randomValue`
- `fill`
- `sample`
- `fillSample`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Empty fill destinations still return before validating the output type or
  drawing entropy.
- Scalar or non-empty fill requests for uninhabited output types return
  `error.EmptyRange` before secure-engine construction.
- Habitable output types still construct the root secure engine and delegate to
  the existing random value/sample/fill paths.

## Adoption and Documentation

- Focused root tests cover empty-type failures before entropy, empty-output
  behavior, and failing-entropy random paths.
- Tests avoid formatting empty-enum values on unexpected success by manually
  checking the exact error for scalar `sample`.
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
apicheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M624 is closed for the current bar: root generic value scalar/fill/sample
helpers now prevalidate uninhabited output types before secure-engine
construction. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
