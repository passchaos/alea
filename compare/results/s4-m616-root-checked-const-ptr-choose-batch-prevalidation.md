# S4-M616 Root Checked Const-Pointer Choose Batch Prevalidation

## Gap

Root `chooseConstPtrBatchChecked` allocated its output buffer before validating
non-zero empty-item requests. Empty checked inputs should be reported before
random-output allocation and before root secure-engine construction.

This milestone aligns checked const-pointer choose batch behavior with root fill
helpers and with earlier unchecked batch prevalidation work.

## API Changed

`src/root.zig` now prevalidates:

- `chooseConstPtrBatchChecked`

The public signature is unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-count batches still return empty allocations before validating inputs or
  drawing entropy.
- Non-zero empty-item requests return `error.EmptyRange` before allocation or
  entropy.
- Singleton item slices still allocate and fill deterministic repeated pointers
  before entropy is requested.
- Multi-item slices still allocate the output buffer, construct the root secure
  engine, and delegate to the existing fill path.

## Adoption and Documentation

- Focused root tests cover empty-input failure before allocation, zero-count
  behavior, singleton deterministic paths, and failing-entropy random paths.
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
readmecheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M616 is closed for the current bar: root checked const-pointer choose batch
helper now prevalidates non-zero empty-input requests before random-output
allocation and secure-engine construction. This is reliability and ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
