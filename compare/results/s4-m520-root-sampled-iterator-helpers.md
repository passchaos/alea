# S4-M520 Root Sampled No-Replacement Iterator Helpers

## Gap

Root one-shot no-replacement APIs covered allocation-returning samples,
caller-owned buffers, fixed-size arrays, and `chooseMultiple*` aliases. Lazy
owned sampled value/pointer iterators still required constructing a secure engine
and calling `seq.sampleItemsIter*`, `seq.samplePtrsIter*`, or
`seq.sampleMutPtrsIter*` directly.

## API Added

`src/root.zig` now exposes:

- `sampleItemsIter`
- `sampleItemsIterChecked`
- `samplePtrsIter`
- `samplePtrsIterChecked`
- `sampleMutPtrsIter`
- `sampleMutPtrsIterChecked`

Zero-count iterators and all-item iterators are constructed without drawing
entropy. Checked helpers reject oversized requests before entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates value, const-pointer, and mutable-pointer
  sampled iterator helpers in root no-replacement output.
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

Runnable example excerpt showing the guarded iterator tokens:

```text
$ zig build run-basic
root sampled iterator helpers: sampleItemsIter={ 6, 5, 1 }, samplePtrsIter=[6, 2, 5], sampleMutPtrsIter=[5, 6, 4]
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
examplecheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M520 is closed for the current bar: root system-entropy callers can create
owned sampled no-replacement value, const-pointer, and mutable-pointer iterators
without manually constructing a secure engine. This is API ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
