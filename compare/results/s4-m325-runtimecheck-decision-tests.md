# S4-M325 Runtimecheck Decision Tests

Date: 2026-07-06

## Purpose

S4-M322 tested runtime executable discovery, but the final runtimecheck decision
logic also matters: missing required tools and newly available opportunity
runners must fail with the intended blocker outcomes. S4-M325 adds focused tests
for that final decision helper.

## Change

`tools/runtimecheck.zig` now factors the final decision into
`evaluateRuntimeState(missing_required, opportunities)` and tests:

- pass when required tools are present and no opportunity runner is available;
- `RequiredRuntimeMissing` when required tools are missing;
- `RuntimeOpportunityAvailable` when opportunity runners are found;
- missing required tools take priority when both conditions are present.

These tests run as part of `zig build runtimecheck`.

## Validation

Relevant validation:

```sh
zig fmt tools/runtimecheck.zig tools/roadmapcheck.zig
zig test tools/runtimecheck.zig
zig build runtimecheck
zig build roadmapcheck
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone improves runtime-checker coverage. It does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not execute
an additional architecture/runtime runner, and is not whole-goal completion
evidence.
