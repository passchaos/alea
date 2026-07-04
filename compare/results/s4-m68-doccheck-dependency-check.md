# S4-M68 Doccheck Dependency Hardening

Date: 2026-07-04

Purpose: ensure the aggregate documentation gate keeps running all component
checkers. Recent milestones strengthened `apicheck`, `examplecheck`,
`readmecheck`, and `roadmapcheck`; this milestone makes `toolingcheck` fail if
`zig build doccheck` stops depending on any of them.

## Change

Updated `tools/toolingcheck.zig` to verify these build tokens:

- `doccheck_step.dependOn(&run_apicheck.step)`;
- `doccheck_step.dependOn(&run_examplecheck.step)`;
- `doccheck_step.dependOn(&run_toolingcheck.step)`;
- `doccheck_step.dependOn(&run_readmecheck.step)`;
- `doccheck_step.dependOn(&run_roadmapcheck.step)`.

Updated `docs/tooling.md` to describe `toolingcheck` as verifying the tooling
catalog and doccheck dependency coverage.

## Validation

Commands:

```sh
git diff --check
zig build toolingcheck
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

## S4-M68 Decision

S4-M68 is closed for the current doccheck-dependency hardening bar: normal
validation now checks that the aggregate documentation gate continues to include
all documentation/catalog/roadmap checkers.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
