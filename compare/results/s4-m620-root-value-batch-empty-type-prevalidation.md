# S4-M620 Root Value Batch Empty-Type Prevalidation

## Gap

Root `valueBatch` allocated its output buffer before validating uninhabited value
types. Non-zero requests for empty enum-containing value types should fail before
random-output allocation and before root secure-engine construction.

This milestone aligns unchecked value batch behavior with checked `valueBatch`
and root `randomValueChecked` validation.

## API Changed

`src/root.zig` now prevalidates:

- `valueBatch`

The public signature is unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-count batches still return empty allocations before validating the value
  type or drawing entropy.
- Non-zero uninhabited value type requests return `error.EmptyRange` before
  allocation or entropy.
- Habitable value types still allocate the output buffer, construct the root
  secure engine, and delegate to the existing fill path.

## Adoption and Documentation

- Focused root tests cover empty-type failure before allocation, zero-count
  behavior, and failing-entropy random paths.
- The test avoids formatting empty-enum values on unexpected success, so it
  checks the exact error manually instead of through `expectError` formatting.
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
examplecheck ok
toolingcheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M620 is closed for the current bar: root value batch helper now prevalidates
non-zero uninhabited value types before random-output allocation and
secure-engine construction. This is reliability and ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
