# S4-M492 Root One-Shot Iterator Choice Helpers

## Gap

Root sequence helpers covered slices, indexes, shuffles, and no-replacement
index samples, but choosing one item from a generic iterator still required
constructing a secure engine and using `seq.chooseIterator*`. Iterator choice is
the root-level counterpart to Rust `IteratorRandom::choose`.

## API Added

`src/root.zig` now exposes:

- `chooseIterator`
- `chooseIteratorChecked`
- `chooseIteratorHinted`
- `chooseIteratorHintedChecked`
- `chooseIteratorStable`
- `chooseIteratorStableChecked`

Empty and singleton iterators return without drawing entropy. Checked helpers
return `EmptyInput` for empty iterators.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `root iterator helpers` output.
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
root iterator helpers: choice=6
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
apicheck ok
toolingcheck ok
roadmapcheck ok
examplecheck ok
readmecheck ok
```

```text
$ git diff --check
```

## Result

S4-M492 is closed for the current bar: root system-entropy callers can choose one
item from iterators without manually constructing a secure engine. This is API
ergonomics work only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
