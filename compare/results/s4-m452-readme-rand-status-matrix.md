# S4-M452 README Rand-Status Command Matrix Discovery

## Gap

S4-M450 recorded the latest `rand-status` command matrix and S4-M451 guarded it,
but README did not link directly to that evidence file.

## Change

README now points readers to
`compare/results/s4-m450-rand-status-command-matrix.md` for the latest status
command matrix evidence.

`tools/readmecheck.zig` now requires that README token and includes the file in
its discovery list.

## Validation

Focused validation commands:

```text
$ zig build readmecheck
readmecheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M452 is closed for the current bar: README exposes the `rand-status` command
matrix evidence. This is documentation discoverability only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
