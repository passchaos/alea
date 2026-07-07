# S4-M558 Root Item-Accessor Weighted Value Array Helpers

## Gap

S4-M555 added root item-accessor weighted value batch helpers, but callers that
wanted stack-friendly fixed-size repeated weighted values from item-local weights
still had to construct a secure engine manually and call
`seq.chooseWeightedValueArrayBy*`.

## API Added

`src/root.zig` now exposes:

- `chooseWeightedValueArrayBy`
- `chooseWeightedValueArrayByChecked`

Zero-size arrays return before validating weights or drawing entropy. All-zero
item weights return `null` for the nullable helper; the checked helper rejects
them with `error.EmptyInput`. Single-positive item weights fill deterministically
before entropy is requested. Invalid weights fail before entropy is requested.
Multi-positive item weights use the root secure engine through the
item-accessor fill helpers.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `byArray=` in the root weighted value
  repeated helper output using a slice of structs plus an item-weight accessor.
- `tools/examplecheck.zig` guards the new example token.
- `docs/api-reference.md` lists the new root public symbols.
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

Runnable example excerpt showing the guarded item-accessor value array token:

```text
$ zig build run-basic | grep "root weighted value repeated helpers"
root weighted value repeated helpers: fill=[red, blue, green, blue], byArray=[blue, blue, green, blue], array=[blue, blue, blue, blue], batch=[blue, blue, blue, blue]
```

```text
$ zig build examplecheck
examplecheck ok
```

```text
$ zig build apicheck
apicheck ok
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

S4-M558 is closed for the current bar: root system-entropy callers can produce
fixed-size repeated weighted value arrays directly from an item slice and
comptime item-weight accessor without manually constructing a secure engine or
parallel weight slice. This is API ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
