# S4-M524 Root chooseArray No-Replacement Value Array Aliases

## Gap

Root fixed-size no-replacement value arrays were available as
`sampleItemsArray*`. The `seq` module also exposes the Rust-discoverable
`chooseArray*` names for the same no-replacement value-array workflow, but root
system-entropy callers did not have those aliases.

## API Added

`src/root.zig` now exposes:

- `chooseArray`
- `chooseArrayChecked`

The aliases forward to root `sampleItemsArray*`, preserving zero-size, all-item,
checked invalid, and entropy behavior.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `chooseArray` in root no-replacement helper
  output.
- `tools/examplecheck.zig` guards the `chooseArray=` example token.
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

Runnable example excerpt showing the guarded `chooseArray=` token:

```text
$ zig build run-basic
root no-replacement helpers: sample={ 1, 3, 4 }, sampleArray={ 4, 5, 6 }, chooseArray={ 6, 3, 1 }, samplePtrArray=[4, 1, 3], samplePtrs=[6, 1, 4], sampleMutPtrArray=[1, 5, 4], sampleMutPtrs=[2, 6, 1], sampleItemsInto={ 4, 1, 5 }, samplePtrsInto=[3, 5, 1], sampleMutPtrsInto=[4, 2, 1], indices={ 5, 2, 0 }, indexVec={ 0, 5, 2 }, indexArray={ 4, 2, 5 }, indexArrayU32={ 4, 0, 5 }, indicesInto={ 2, 3, 1 }, indicesU32={ 2, 5, 3 }
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
$ git diff --check; echo diffcheck_status:$?
diffcheck_status:0
```

Broader native test gate:

```text
$ zig build test
readmecheck ok
examplecheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M524 is closed for the current bar: root system-entropy callers can use
Rust-discoverable `chooseArray*` names for fixed-size no-replacement value arrays
without manually constructing a secure engine. This is API
ergonomics/discoverability work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
