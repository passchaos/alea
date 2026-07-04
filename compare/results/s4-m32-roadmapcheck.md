# S4-M32 Roadmap And Active-Audit Drift Check

Date: 2026-07-04

Purpose: keep the living roadmap and completion audit synchronized with the
checked-in evidence as post-S4-M11 unblocked milestones continue to close.

## Change

Added `tools/roadmapcheck.zig` and build step:

```sh
zig build roadmapcheck
```

The checker verifies:

- every closed S4-M11 through S4-M32 evidence file listed in the checker exists;
- `compare/results/core-rand-coverage.md` mentions each closed milestone and its
  evidence file;
- `compare/results/active-goal-completion-audit.md` mentions each closed
  milestone;
- `compare/results/linux-no-known-gaps-audit.md` lists post-S4-M11 evidence
  files;
- S4-M11 remains visible as blocked/unresolved evidence;
- the roadmap and active audit both carry the next S4-M33 unblocked-gap row;
- the active audit keeps explicit non-completion language, including the reminder
  not to call `update_goal(status=complete)` while blockers remain;
- `zig build doccheck` depends on `roadmapcheck`;
- `README.md` and `docs/tooling.md` mention `zig build roadmapcheck`.

`zig build doccheck` now runs `roadmapcheck` together with `apicheck`,
`examplecheck`, `toolingcheck`, and `readmecheck`; `zig build test` and
`zig build validate` inherit that coverage through `doccheck`.

## Validation

Commands:

```sh
zig build roadmapcheck
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```

Result: passed. `roadmapcheck` prints `roadmapcheck ok`.

## S4-M32 Decision

S4-M32 is closed for the current roadmap/audit drift bar: the milestone roadmap,
active completion audit, Linux no-known-gaps audit, and checked-in S4 evidence
are now covered by a dedicated verifier included in documentation, test, and
validation gates.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
