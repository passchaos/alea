# S4-M523 Root Iterator sample-fill Aliases

## Gap

Root one-shot caller-owned iterator sampling existed as `sampleIteratorInto` and
`sampleIteratorIntoChecked`. The `seq` module also exposes
`sampleIteratorFill*` aliases matching local Rust `IteratorRandom::sample_fill`
terminology, but root system-entropy callers did not have the same discoverable
names.

## API Added

`src/root.zig` now exposes:

- `sampleIteratorFill`
- `sampleIteratorFillChecked`

These aliases forward to the existing root caller-owned iterator reservoir
sampling helpers, preserving zero-output, short-stream partial-fill, exact-fill,
checked short-stream, and entropy behavior.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `sampleIteratorFill` in the root iterator
  helper output.
- `tools/examplecheck.zig` guards the example token.
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

Runnable example excerpt showing the guarded `sampleFill=` token:

```text
$ zig build run-basic
root iterator helpers: choice=6, weightedChoice=30, sample={ 4, 1, 5, 7 }, sampleInto={ 9, 7, 5, 3 }, sampleFill={ 7, 1, 2, 8 }, sampleArray={ 4, 1, 6, 3 }, weightedSample={ 20, 10 }, weightedInto={ 10, 30 }, weightedArray={ 20, 30 }
```

```text
$ zig build examplecheck
examplecheck ok
```

```text
$ zig build apicheck
apicheck ok
```

Roadmap guard command was run with an explicit status echo because this cached
build step produced no stdout in this run:

```text
$ zig build roadmapcheck; echo roadmap_status:$?
roadmap_status:0
```

```text
$ git diff --check
```

Broader native test gate:

```text
$ zig build test
readmecheck ok
toolingcheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M523 is closed for the current bar: root system-entropy callers can use
Rust-discoverable `sampleIteratorFill*` names for caller-owned iterator reservoir
sampling without manually constructing a secure engine. This is API
ergonomics/discoverability work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
