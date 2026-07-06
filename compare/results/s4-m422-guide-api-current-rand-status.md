# S4-M422 Guide/API Current Rand Status Discovery

## Gap

S4-M421 linked the current local `rand` / `rand_distr` comparison status snapshot
from README. The core guide and API reference still lacked direct discovery for
that status file.

## Change

`docs/core-guide.md` and `docs/api-reference.md` now point readers to
`compare/results/s4-m420-current-rand-status.md` for the current local `rand` /
`rand_distr` comparison status.

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

S4-M422 is closed for the current bar: detailed docs expose the current local
Rust comparison status snapshot. This is documentation discoverability only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
