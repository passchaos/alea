# S4-M668 Root chooseMultiple Empty-Type Prevalidation

## Gap

Root `sampleWithoutReplacementChecked` already rejects non-zero uninhabited value
types before allocation and entropy. The unchecked root `chooseMultiple` value
alias could still take its deterministic full-count branch and duplicate an item
slice before validating that the output value type is inhabited.

Root `chooseMultiple` should reject non-zero empty enum-containing value types
before allocation and before secure-engine construction.

## Local `rand` Baseline

The local Rust `rand` checkout exposes no-replacement slice workflows through
`choose_multiple`. Rust slices cannot contain values of an empty enum in normal
safe code, so comparable invalid value-type states are ruled out before sampling.
Alea's Zig-native generic API can name empty enum-containing value types, so the
explicit validation path is `error.EmptyRange` before allocation or entropy.

## API Changed

`src/root.zig` now prevalidates empty enum-containing value types in:

- `chooseMultiple`

The public signature is unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-count requests still return empty allocations before validating the value
  type.
- Non-zero empty enum-containing value types return `error.EmptyRange` before
  allocation and secure-engine construction, including full-count deterministic
  alias requests.
- Habitable value types keep existing zero/all/random behavior and stream shape.

## Adoption and Documentation

- Focused root tests cover empty enum `chooseMultiple` failure with a failing
  allocator, proving no allocation or entropy request occurs, while existing
  zero-count and normal all-items deterministic paths remain covered.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused root test:

```text
$ zig test src/root.zig --test-filter "root random helpers validate deterministic cases before entropy"
1/2 root.test_0...OK
2/2 root.test.root random helpers validate deterministic cases before entropy...OK
All 2 tests passed.
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

No output.

Broader native test gate:

```text
$ zig build test
apicheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M668 is closed for the current bar: root `chooseMultiple` now rejects non-zero
empty enum-containing value types before allocation, secure-engine construction,
or assertions. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
