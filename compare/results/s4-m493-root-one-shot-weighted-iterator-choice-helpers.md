# S4-M493 Root One-Shot Weighted Iterator Choice Helpers

## Gap

S4-M492 added unweighted iterator choice helpers, but weighted iterator choice
still required constructing a secure engine and calling `seq.chooseIteratorWeighted`.
Weighted streaming choice is useful when callers produce weighted entries lazily.

## API Added

`src/root.zig` now exposes:

- `chooseIteratorWeighted`
- `chooseIteratorWeightedChecked`

Empty and all-zero weighted iterators return without drawing entropy. A single
positive-weight entry returns deterministically without drawing entropy. Checked
helpers return `EmptyInput` when no positive-weight item exists.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `weightedChoice` in root iterator helper
  output.
- `tools/examplecheck.zig` guards that example token.
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

Runnable example and guard checks:

```text
$ zig build run-basic
root iterator helpers: choice=6, weightedChoice=20
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

Broader native test gate:

```text
$ zig build test
roadmapcheck ok
examplecheck ok
apicheck ok
readmecheck ok
toolingcheck ok
```

```text
$ git diff --check
```

## Result

S4-M493 is closed for the current bar: root system-entropy callers can choose one
item from weighted iterators without manually constructing a secure engine. This
is API ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
