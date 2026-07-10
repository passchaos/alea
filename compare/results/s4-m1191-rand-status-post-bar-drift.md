# S4-M1191 Rand-Status Post-Bar Drift Repair

## Gap

After S4-M1190 refreshed full `validate-all` evidence, the status JSON and
status snapshots correctly moved the active blocker to S4-M1191, but the
human-readable suffix drifted to `post-S4-M1191` instead of `post-S4-M1190`.
`tools/roadmapcheck.zig` also mapped the S4-M1190 evidence file to the S4-M1191
milestone in its evidence table. This was a status/tooling drift, not a sampling
algorithm change.

## Change

- `tools/rand_status.zig` now emits
  `"remaining_blocker": "S4-M1191 post-S4-M1190 next product bar"`.
- `compare/results/s4-m420-current-rand-status.md`,
  `compare/results/s4-m450-rand-status-command-matrix.md`, and
  `compare/results/s4-m455-rand-status-direct-matrix.md` now record the same
  non-self-referential blocker text.
- `tools/roadmapcheck.zig` maps
  `compare/results/s4-m1190-post-s4-m1189-validate-all.md` to `S4-M1190`.

## Validation

```text
$ zig build rand-status-self-test
rand-status self-test ok

$ zig build roadmapcheck
roadmapcheck ok

$ zig build toolingcheck
toolingcheck ok

$ git diff --check
(no output)
```

## Result

S4-M1191 is closed for the current bar: current status tooling no longer reports
a self-referential S4-M1191 post-bar string, and roadmap evidence mapping points
S4-M1190 at its own validation artifact. This is tooling/status hygiene, not
whole-goal completion; S4-M1192 remains active.
