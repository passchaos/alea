# S4-M435 `rand-status-json` Schema Documentation

## Gap

S4-M432 added `zig build rand-status-json`, but the stable JSON fields were only
visible in sample output and tests. Scripts consuming the status output needed a
guarded schema/discovery note.

## Change

`docs/tooling.md` now documents the stable JSON fields emitted by
`zig build rand-status-json`:

- `date`
- `baseline.rand`
- `baseline.rand_distr`
- `latest_gate`
- `public_surface`
- `rust_comparison`
- `runtime_runners`
- `current_conclusion`
- `remaining_blocker`
- `details`

`tools/toolingcheck.zig` now requires these schema tokens in the tooling catalog.

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

S4-M435 is closed for the current bar: scripts have a documented and guarded
`rand-status-json` schema. This is tooling documentation reliability only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
