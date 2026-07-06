# S4-M453 Guide/API Rand-Status Matrix Discovery

## Gap

S4-M452 linked the latest `rand-status` command matrix from README. The core
guide and API reference still pointed to the current status snapshot but did not
link the command-matrix evidence.

## Change

`docs/core-guide.md` and `docs/api-reference.md` now point readers to
`compare/results/s4-m450-rand-status-command-matrix.md` for the latest
`rand-status` command matrix evidence.

`tools/toolingcheck.zig` now requires those discovery tokens in both docs.

## Validation

Focused validation commands:

```text
$ zig build toolingcheck
toolingcheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M453 is closed for the current bar: detailed docs expose the latest
`rand-status` command-matrix evidence. This is documentation discoverability
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
