# S4-M341 Active Completion Criteria Guard

## Gap

The active goal must not be marked complete while S4-M11 remains blocked. The
active audit already spelled out the concrete required-next-work criteria, but
`roadmapcheck` only guarded broad unresolved/blocker language. A future audit edit
could weaken or remove the exact completion criteria while keeping generic
"S4-M11 remains unresolved" wording.

## Change

`tools/roadmapcheck.zig` now verifies that
`compare/results/active-goal-completion-audit.md` retains the Required Next Work
section and the concrete criteria:

- `## Required Next Work Before Completion`
- default/exact-compatible dense SIMD normal/exponential candidate
- beats scalar lane-fill in the real vector-slice harness
- preserving or deliberately versioning rejected-lane stream shape
- later roadmap audit may raise/reshape the bar
- do not call `update_goal(status=complete)` until then

## Validation

Focused validation command:

```text
$ zig build roadmapcheck
roadmapcheck ok
```

Broader documentation/roadmap validation command:

```text
$ zig build doccheck
apicheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M341 is closed for the current bar: the active audit's concrete completion
criteria are now checked by tooling, reducing the chance of a proxy or stale
success signal being mistaken for whole-goal completion. This is evidence/tooling
hardening only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
