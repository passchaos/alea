# S4-M424 Current Rand Status Token Guard

## Gap

S4-M420 added a concise current local `rand` / `rand_distr` comparison status
snapshot and S4-M421..S4-M423 made it discoverable from docs. The status file
itself still needed a roadmapcheck guard so key baseline, validation, no-new-gap,
and S4-M11 blocker statements cannot drift or disappear silently.

## Change

`tools/roadmapcheck.zig` now reads
`compare/results/s4-m420-current-rand-status.md` and requires tokens for:

- the local `~/Work/rand` and cached `rand_distr 0.6.0` baselines;
- current `zig build validate-local` pass status;
- no new unblocked local Rust public-surface/comparison-benchmark gap;
- latest S4-M418 benchmark/parser/surface/runtime output excerpts;
- S4-M11 blocker and non-completion language.

## Validation

Focused validation commands:

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M424 is closed for the current bar: the current rand comparison status
snapshot is now guarded by roadmapcheck. This is evidence-quality maintenance
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
