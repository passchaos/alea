# S4-M637 Root Value Choose Empty-Type Prevalidation

## Gap

Root unweighted value choose helpers could proceed toward output allocation or
secure-engine construction for non-empty requests whose value type is
uninhabited. Such requests cannot produce values and should fail before
allocation or entropy.

This milestone aligns unweighted value choose helpers with generic value and
weighted value empty-type validation.

## API Changed

`src/root.zig` now prevalidates empty value types in:

- `choose`
- `chooseChecked`
- `fillChoose`
- `fillChooseChecked`
- `chooseBatch`
- `chooseBatchChecked`
- `chooseValueArray`
- `chooseValueArrayChecked`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Empty item slices and empty outputs keep their existing precedence.
- Non-empty uninhabited value type requests return `error.EmptyRange` before
  output allocation or secure-engine construction.
- Singleton habitable item slices still return/fill deterministic values before
  entropy is requested.
- Multi-item habitable item slices still use the existing random paths.

## Adoption and Documentation

- Focused root tests cover empty-type failures before allocation/entropy,
  empty-output behavior, singleton deterministic paths, and failing-entropy
  random paths.
- The empty-type tests avoid formatting empty-enum values or arrays on
  unexpected success, so they check exact errors manually.
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
toolingcheck ok
examplecheck ok
```

## Result

S4-M637 is closed for the current bar: root unweighted value choose helpers now
prevalidate non-empty uninhabited value type requests before output allocation
and secure-engine construction. This is reliability and ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
