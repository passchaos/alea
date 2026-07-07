# S4-M639 Root Index Allocation Invalid-Count Prevalidation

## Gap

Root unchecked unweighted index allocation helpers relied on assertions or the
checked helper path when callers requested more sample indices than the population
length. Invalid counts should be reported before output allocation and before
secure-engine construction.

This milestone aligns unchecked index allocation helpers with checked variants
and the output-buffer index prevalidation work.

## API Changed

`src/root.zig` now prevalidates:

- `sampleIndexVec`
- `sampleIndices`
- `sampleIndicesU32`

The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-count samples still return empty allocations before drawing entropy.
- Sample amounts larger than the population return `error.InvalidParameter`
  before output allocation and secure-engine construction.
- Full-range small populations still return deterministic identity indices before
  entropy is requested.
- Random valid paths still construct the root secure engine and delegate to the
  existing random sampling paths.

## Adoption and Documentation

- Focused root tests cover invalid-count failures before allocation/entropy,
  zero-output behavior, full-range deterministic paths, and failing-entropy
  random paths.
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

No output.

Broader native test gate:

```text
$ zig build test
toolingcheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M639 is closed for the current bar: root unweighted index allocation helpers
now reject oversized sample amounts before output allocation and secure-engine
construction in unchecked variants. This is reliability and ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
