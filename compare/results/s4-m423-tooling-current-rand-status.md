# S4-M423 Tooling Current Rand Status Discovery

## Gap

S4-M421 and S4-M422 linked the current local `rand` / `rand_distr` comparison
status snapshot from README, the core guide, and API reference. The tooling
catalog's `validate-local` discussion still lacked the direct status link.

## Change

`docs/tooling.md` now points readers to
`compare/results/s4-m420-current-rand-status.md` from the `validate-local`
discussion.

`tools/toolingcheck.zig` now requires the status snapshot tokens in the tooling
catalog.

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

S4-M423 is closed for the current bar: the tooling catalog exposes the current
local Rust comparison status snapshot. This is documentation discoverability
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
