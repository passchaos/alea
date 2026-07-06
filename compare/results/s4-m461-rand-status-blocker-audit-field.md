# S4-M461 Blocker Audit Link In `rand-status-json`

## Gap

`rand-status-json` linked to the current status snapshot and latest validate-local
evidence, but scripts still needed to know the S4-M11 blocker-audit path from
other documentation.

## Change

`tools/rand_status.zig` now emits and tests:

```text
"blocker_audit": "compare/results/s4-m11-blocker-audit.md"
```

`docs/tooling.md` documents the field, and `tools/toolingcheck.zig` guards the
source/docs tokens.

## Validation

Focused validation commands:

```text
$ zig build rand-status-json
```

```text
$ zig build rand-status-self-test
rand-status self-test ok
```

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

S4-M461 is closed for the current bar: script consumers can jump from
`rand-status-json` directly to the S4-M11 blocker audit. This is tooling
ergonomics only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
