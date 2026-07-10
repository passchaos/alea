# S4-M1206 Roadmap Evidence Path Guard

## Gap

Recent status updates repeatedly risked mapping a milestone to a neighboring
evidence file. During the post-S4-M1205 refresh, the same drift showed up again:
S4-M1204 text was accidentally rewritten to point at the S4-M1205 validate-local
artifact.

## Change

- Added a generic `roadmapcheck` guard requiring every `evidence` table path to
  contain the lowercase milestone token (for example, S4-M1204 evidence must
  include `s4-m1204` in its path).
- Added a focused unit test that accepts a matching path and rejects a mismatched
  neighboring milestone path.
- Restored S4-M1204 audit/blocker references to
  `compare/results/s4-m1204-vectorbench-status-drift.md`.

## Validation

```text
$ zig build roadmapcheck
roadmapcheck ok

$ zig build toolingcheck
toolingcheck ok

$ zig build rand-status-self-test
rand-status self-test ok

$ git diff --check
(no output)
```

## Result

S4-M1206 is closed for the current bar: roadmapcheck now has a generic guard for
milestone/evidence path mismatches, and the known S4-M1204 path drift is repaired.
This is status/guard hygiene, not whole-goal completion; S4-M1207 remains active.
