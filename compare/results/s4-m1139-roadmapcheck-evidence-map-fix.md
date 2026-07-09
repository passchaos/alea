# S4-M1139 Roadmapcheck Evidence Map Fix

## Gap

While continuing after S4-M1138, the `roadmapcheck` evidence list had drifted:
S4-M1131 was incorrectly mapped to the S4-M1138 status-refresh evidence file.
That made the historical evidence map less precise even though both files exist.

## Implementation

- Restored the S4-M1131 evidence mapping in `tools/roadmapcheck.zig` to
  `compare/results/s4-m1131-post-s4-m1130-rand-status-refresh.md`.
- Left S4-M1138 mapped to
  `compare/results/s4-m1138-post-s4-m1137-rand-status-refresh.md`.

## Validation

```text
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M1139 is closed for the current bar: roadmapcheck's historical evidence map
again points S4-M1131 and S4-M1138 to their own evidence files. This is not
whole-goal completion; S4-M1140 remains active.
