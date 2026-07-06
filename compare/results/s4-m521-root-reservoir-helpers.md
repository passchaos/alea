# S4-M521 Root One-Shot Reservoir Helpers

## Gap

Alea's sequence module already provided reservoir value, const-pointer, mutable-
pointer, and caller-owned reservoir helpers. Root system-entropy callers still
needed to manually construct a secure engine to use those reservoir workflows.

## API Added

`src/root.zig` now exposes:

- `reservoirSample`
- `reservoirSampleChecked`
- `reservoirSamplePtrs`
- `reservoirSamplePtrsChecked`
- `reservoirSampleMutPtrs`
- `reservoirSampleMutPtrsChecked`
- `reservoirSampleInto`
- `reservoirSampleIntoChecked`
- `reservoirSamplePtrsInto`
- `reservoirSamplePtrsIntoChecked`
- `reservoirSampleMutPtrsInto`
- `reservoirSampleMutPtrsIntoChecked`

Zero-count/zero-output and all-item paths return without drawing entropy.
Checked helpers reject oversized requests before entropy is requested.

## Adoption and Documentation

- `examples/basic.zig` demonstrates allocation-returning and caller-owned
  reservoir value, const-pointer, and mutable-pointer helpers.
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

Runnable example excerpt showing the guarded reservoir tokens:

```text
$ zig build run-basic
root reservoir helpers: reservoirSample={ 6, 1, 4 }, reservoirPtrs=[2, 5, 6], reservoirMutPtrs=[1, 5, 4], reservoirInto={ 2, 3, 4 }, reservoirPtrsInto=[2, 5, 1], reservoirMutPtrsInto=[2, 6, 1]
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
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M521 is closed for the current bar: root system-entropy callers can create
allocation-returning and caller-owned value, const-pointer, and mutable-pointer
reservoir samples without manually constructing a secure engine. This is API
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
