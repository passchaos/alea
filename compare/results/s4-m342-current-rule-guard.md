# S4-M342 Roadmap Current-Rule Guard

## Gap

The roadmap's Current Rule is the living policy for how to continue while an
earlier milestone such as S4-M11 is blocked. Before S4-M342, `roadmapcheck`
required a few broad tokens like `zig build validate-local`, but it did not guard
the full Current Rule: earliest unblocked work, blocker evidence freshness,
validation command selection, `statcheck`, raw stream validation, and deferring
pure micro-optimization.

## Change

`tools/roadmapcheck.zig` now checks Current Rule tokens in
`compare/results/core-rand-coverage.md`, including:

- work on the earliest unblocked stage milestone;
- keep blocker evidence current when an earlier milestone is blocked;
- use `zig build validate` for broad native validation;
- use `zig build validate-local` for local `rand` / `rand_distr` comparison or
  public-surface evidence changes;
- run `zig build statcheck` after engine/distribution/range/sampling-internal
  changes;
- use `zig build stream -- ...` for external raw-engine statistical validation;
- defer pure micro-optimization until feature, correctness, and validation
  milestones are in place.

## Validation

Focused validation command:

```text
$ zig build roadmapcheck
roadmapcheck ok
```

Broader documentation/roadmap validation command:

```text
$ zig build doccheck
roadmapcheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M342 is closed for the current bar: the roadmap's continuation policy is now
checked by tooling rather than only documented. This is evidence/tooling
hardening only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
