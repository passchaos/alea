# S4-M638 Root Index-Into Invalid-Count Prevalidation

## Gap

Root unchecked unweighted index output-buffer helpers relied on assertions or
lower-level unreachable paths when the caller requested more output indices than
the population length. Invalid counts should be reported before secure-engine
construction.

This milestone aligns unchecked index output-buffer behavior with the checked
variants.

## API Changed

`src/root.zig` now prevalidates:

- `sampleIndicesInto`
- `sampleIndicesU32Into`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Empty output buffers still return before validating counts or drawing entropy.
- Output buffers longer than the population return `error.InvalidParameter`
  before secure-engine construction.
- Full-range small populations still fill deterministic identity indices before
  entropy is requested.
- Random valid paths still construct the root secure engine and delegate to the
  existing random sampling paths.

## Adoption and Documentation

- Focused root tests cover invalid-count failures before entropy, zero-output
  behavior, full-range deterministic paths, and failing-entropy random paths.
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
toolingcheck ok
apicheck ok
```

## Result

S4-M638 is closed for the current bar: root unweighted index output-buffer
helpers now reject oversized output buffers before secure-engine construction in
unchecked variants. This is reliability and ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
