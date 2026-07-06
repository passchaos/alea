# S4-M339 Core Guide Validation Aggregate Prose

## Gap

`docs/core-guide.md` listed validation commands but did not explain how to choose
between the three main aggregate gates: `zig build validate`, `zig build
validate-local`, and `zig build validate-all`. README and the tooling catalog now
explain those aggregates, so the core guide should carry the same adoption
context near its validation section.

## Change

`docs/core-guide.md` now explains:

- use `zig build validate` for broad native checks before ordinary local changes;
- use `zig build validate-local` for Linux-first local `rand` / `rand_distr`
  comparison work because it adds `surfacecheck` and `runtimecheck`;
- use `zig build validate-all` for portability-sensitive changes or evidence
  refreshes because it adds cross-target compile checks, WASI unit tests, and
  the chained WASI report.

`tools/toolingcheck.zig` now guards those core-guide guidance tokens so the
commands cannot regress back to an unexplained list.

## Validation

Focused validation command:

```text
$ zig build toolingcheck
toolingcheck ok
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

S4-M339 is closed for the current bar: the core guide now tells users which
validation aggregate to choose for native changes, local Rust comparison work,
and portability-sensitive evidence refreshes. This is documentation/tooling
hardening only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
