# S4-M519 Root chooseMultiple No-Replacement Aliases

## Gap

Root one-shot no-replacement APIs exposed `sampleWithoutReplacement*`,
`samplePtrs*`, `sampleMutPtrs*`, and caller-owned `sample*Into*` names. Users
looking for local Rust `IndexedRandom::choose_multiple` terminology still had to
map that wording to Alea's root sampling helpers or construct a secure engine and
use the `seq.chooseMultiple*` aliases directly.

## API Added

`src/root.zig` now exposes root system-entropy aliases:

- `chooseMultiple`
- `chooseMultipleChecked`
- `chooseMultiplePtrs`
- `chooseMultiplePtrsChecked`
- `chooseMultipleMutPtrs`
- `chooseMultipleMutPtrsChecked`
- `chooseMultipleInto`
- `chooseMultipleIntoChecked`
- `chooseMultiplePtrsInto`
- `chooseMultiplePtrsIntoChecked`
- `chooseMultipleMutPtrsInto`
- `chooseMultipleMutPtrsIntoChecked`

Zero-output/all-item paths and scratch/checked validation are handled before
entropy is requested, matching the root `sample*` helpers while using
Rust-discoverable naming.

## Adoption and Documentation

- `examples/basic.zig` demonstrates allocation-returning and caller-owned
  `chooseMultiple*` aliases in a dedicated root output line.
- `tools/examplecheck.zig` guards the example tokens.
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

Runnable example excerpt showing the guarded aliases:

```text
$ zig build run-basic
root chooseMultiple aliases: chooseMultiple={ 3, 6, 1 }, chooseMultiplePtrs=[2, 4, 1], chooseMultipleMutPtrs=[3, 1, 4], chooseMultipleInto={ 4, 6, 3 }, chooseMultiplePtrsInto=[5, 4, 1], chooseMultipleMutPtrsInto=[2, 4, 3]
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
readmecheck ok
apicheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M519 is closed for the current bar: root system-entropy callers can use
Rust-discoverable `chooseMultiple*` names for allocation-returning and
caller-owned no-replacement value, const-pointer, and mutable-pointer workflows.
This is API ergonomics/discoverability work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
