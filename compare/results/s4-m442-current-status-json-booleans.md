# S4-M442 Current Status Snapshot JSON Booleans

## Gap

S4-M440 added stable boolean fields to `rand-status-json`, and S4-M441 synced the
S4-M11 blocker audit with those fields. The current status snapshot
`compare/results/s4-m420-current-rand-status.md` still needed to show and guard
the same JSON boolean signals in its latest evidence block.

## Change

`compare/results/s4-m420-current-rand-status.md` now includes:

- `"validate_local_passes": true`
- `"opportunity_runners_available": false`
- `"no_known_unblocked_gap": true`
- `"s4_m11_blocked": true`

`tools/roadmapcheck.zig` now guards these tokens in the current status snapshot.

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

S4-M442 is closed for the current bar: the current local rand comparison status
snapshot now carries the same script-friendly boolean status signals as
`rand-status-json`. This is evidence-quality maintenance only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
