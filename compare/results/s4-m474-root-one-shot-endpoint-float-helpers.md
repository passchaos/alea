# S4-M474 Root One-Shot Endpoint-Float Helpers

## Gap

The root system-entropy API covered random scalars, ranges, fills, batches, and
string helpers, but endpoint-sensitive float workflows still required manual
secure-engine construction plus `Rng.fillOpen` / `Rng.fillOpenClosed` or their
batch helpers. These `(0,1)` and `(0,1]` shapes are common in distribution
composition and should be directly available from the root one-shot API.

## API Added

`src/root.zig` now exposes:

- `fillOpen`
- `openBatch`
- `fillOpenClosed`
- `openClosedBatch`

Empty output buffers and zero-count batches return without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `root endpoint float helpers` output.
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

Runnable example and guard checks:

```text
$ zig build run-basic
root endpoint float helpers: openFill={ 0.48848712, 0.92412174, 0.37637943, 0.7932042 }, openBatch={ 0.24750146889908542, 0.25323305438407895, 0.5875842113595219, 0.5607711137503705 }, openClosedFill={ 0.96256906, 0.29729158, 0.82242817, 0.88131565 }, openClosedBatch={ 0.2026563072544646, 0.523465530415208, 0.4446519023534331, 0.5574610904158922 }
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
readmecheck ok
examplecheck ok
toolingcheck ok
apicheck ok
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M474 is closed for the current bar: root system-entropy callers can fill or
allocate strict `(0,1)` and `(0,1]` float samples without manually constructing a
secure engine. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
