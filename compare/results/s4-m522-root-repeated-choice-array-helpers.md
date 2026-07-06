# S4-M522 Root Repeated With-Replacement Choice Array Helpers

## Gap

Root one-shot choice arrays existed as `chooseValueArray`,
`chooseConstPtrArray`, and `choosePtrArray`, but the root API did not expose the
explicit repeated with-replacement names already available in `seq` as
`chooseRepeated*Array`. Users looking for that terminology had to map it back to
the older root names or construct a secure engine and call `seq` directly.

## API Added

`src/root.zig` now exposes root system-entropy aliases:

- `chooseRepeatedValueArray`
- `chooseRepeatedValueArrayChecked`
- `chooseRepeatedConstPtrArray`
- `chooseRepeatedConstPtrArrayChecked`
- `chooseRepeatedPtrArray`
- `chooseRepeatedPtrArrayChecked`

The aliases preserve existing root no-entropy paths: zero-size arrays return
immediately, empty non-zero checked requests fail before entropy, singleton
requests fill deterministically, and multi-item requests use explicit root system
entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates repeated value, const-pointer, and mutable-
  pointer choice arrays in a dedicated root output line.
- `tools/examplecheck.zig` guards those example tokens.
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

Runnable example excerpt showing the guarded repeated-choice tokens:

```text
$ zig build run-basic
root repeated choice array helpers: values=[green, blue, red, blue], constPtrs=[gold, gold, blue, blue], mutPtrs=[gold, green, green, green]
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
examplecheck ok
apicheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M522 is closed for the current bar: root system-entropy callers can use
explicit repeated with-replacement fixed-size value, const-pointer, and mutable-
pointer choice array names without manually constructing a secure engine. This
is API ergonomics/discoverability work only; it does not resolve S4-M11 and is
not whole-goal completion evidence.
