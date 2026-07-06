# S4-M465 Explicit Local-Status Link In `rand-status-json`

## Gap

`rand-status-json` had `details` pointing to the current status snapshot, but the
field name was generic. Scripts benefit from an explicit `local_rand_status`
field that identifies the current local `rand` / `rand_distr` status artifact.

## Change

`tools/rand_status.zig` now emits and tests:

```text
"local_rand_status": "compare/results/s4-m420-current-rand-status.md"
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

S4-M465 is closed for the current bar: script consumers have an explicit current
local rand-status artifact field. This is tooling ergonomics only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
