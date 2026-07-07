# S4-M594 Root Const-Pointer Choose Fill/Batch Empty-Input Prevalidation

## Gap

Root const-pointer `chooseConstPtr`, `chooseConstPtrChecked`, and fixed-size
const-pointer array helpers already handle empty item slices deterministically
before requesting entropy. However, `fillChooseConstPtr` and
`chooseConstPtrBatch` could still construct a secure engine for non-empty
requests with empty item slices before lower-level assertions or random paths
were reached.

This milestone aligns the fill and allocation-returning const-pointer choose
helpers with the checked root const-pointer choose behavior: impossible non-empty
empty-input requests fail before entropy is requested, while empty destinations
and zero-count batches remain cheap deterministic no-ops/empty allocations.

## API Changed

`src/root.zig` now prevalidates:

- `fillChooseConstPtr`
- `chooseConstPtrBatch`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Empty destinations still return before validating items or drawing entropy.
- Zero-count batches still return empty allocations before validating items or
  drawing entropy.
- Non-empty empty-item fill/batch requests return `error.EmptyRange` before
  secure-engine construction.
- Singleton item slices still fill/return repeated pointers to the singleton
  before entropy is requested.
- Multi-item slices still construct the root secure engine and delegate to the
  existing random fill paths.

## Adoption and Documentation

- Focused root tests cover non-empty empty-input failures, empty
  destination/zero-count behavior, existing singleton deterministic paths, and
  failing-entropy random paths.
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
readmecheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M594 is closed for the current bar: root const-pointer choose fill and batch
helpers now reject non-empty empty-input requests before secure-engine
construction. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
