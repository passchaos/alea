# S4-M626 Root Random Iterator Empty-Type Prevalidation

## Gap

Root `randomIter` constructed a secure engine before validating uninhabited
iterator element types. Such iterators cannot produce values and should fail
before entropy is requested.

This milestone aligns random iterator construction with root generic value
empty-type validation.

## API Changed

`src/root.zig` now prevalidates:

- `randomIter`

The public signature is unchanged.

Deterministic pre-entropy behavior is explicit:

- Uninhabited element types return `error.EmptyRange` before secure-engine
  construction.
- Habitable element types still construct an entropy-backed iterator as before.

## Adoption and Documentation

- Focused root tests cover empty-type failure before entropy and failing-entropy
  random paths.
- The empty-type test avoids formatting empty-enum values on unexpected success,
  so it checks the exact error manually.
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
examplecheck ok
apicheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M626 is closed for the current bar: root random iterator construction now
prevalidates uninhabited element types before secure-engine construction. This is
reliability and ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
