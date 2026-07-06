# S4-M444 Current Status Snapshot Schema Version

## Gap

S4-M443 added `schema_version: 1` to `rand-status-json`. The current status
snapshot `compare/results/s4-m420-current-rand-status.md` still needed to mirror
that field in its latest evidence block and guard it through roadmapcheck.

## Change

`compare/results/s4-m420-current-rand-status.md` now includes:

```text
"schema_version": 1,
```

`tools/roadmapcheck.zig` now guards that token in the current status snapshot.

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

S4-M444 is closed for the current bar: the current local rand comparison status
snapshot mirrors the JSON schema version. This is evidence-quality maintenance
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
