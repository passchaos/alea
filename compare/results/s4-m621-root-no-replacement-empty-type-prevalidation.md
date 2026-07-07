# S4-M621 Root No-Replacement Empty-Type Prevalidation

## Gap

Root checked no-replacement value sampling could proceed toward random-output
allocation and secure-engine construction for non-zero requests whose value type
is uninhabited. Such requests cannot produce values and should fail before
allocation or entropy.

This milestone aligns checked no-replacement value sampling with root value batch
empty-type validation.

## API Changed

`src/root.zig` now prevalidates:

- `sampleWithoutReplacementChecked`

The public signature is unchanged. The unchecked `sampleWithoutReplacement`
continues to delegate to the checked helper, so it receives the same protection
for non-zero uninhabited value types.

Deterministic pre-entropy behavior is explicit:

- Zero-count samples still return empty allocations before validating the value
  type or drawing entropy.
- Non-zero uninhabited value type requests return `error.EmptyRange` before
  allocation or entropy when the requested count can otherwise be considered
  valid for the supplied slice length.
- Count larger than input length still returns `error.InvalidParameter` first.
- All-item deterministic samples still duplicate the input without entropy.
- Random valid paths still allocate/sample through the existing random path.

## Adoption and Documentation

- Focused root tests cover empty-type failure before allocation, zero-count
  behavior, all-item deterministic paths, and failing-entropy random paths.
- The empty-type test avoids formatting empty-enum values on unexpected success,
  so it checks the exact error manually instead of through `expectError`.
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
toolingcheck ok
readmecheck ok
```

## Result

S4-M621 is closed for the current bar: root checked no-replacement value sampling
now prevalidates non-zero uninhabited value types before random-output allocation
and secure-engine construction. This is reliability and ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
