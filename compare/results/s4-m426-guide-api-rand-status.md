# S4-M426 Guide/API `rand-status` Discovery

## Gap

S4-M425 added `zig build rand-status` and documented it in README/tooling. The
core guide and API reference still pointed to the status file only, not the quick
build-step command.

## Change

`docs/core-guide.md` and `docs/api-reference.md` now mention
`zig build rand-status` alongside `compare/results/s4-m420-current-rand-status.md`
for the current local `rand` / `rand_distr` comparison status.

`tools/toolingcheck.zig` now requires the command and status-file tokens in both
docs.

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

S4-M426 is closed for the current bar: guide/API docs expose the quick
`rand-status` command. This is documentation discoverability only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
