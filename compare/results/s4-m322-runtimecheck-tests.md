# S4-M322 Runtimecheck Helper Tests

Date: 2026-07-06

## Purpose

S4-M321 added `zig build runtimecheck`, but its executable discovery helpers had
no focused unit coverage. S4-M322 adds tests and wires them into the build step,
mirroring the earlier `surfacecheck` helper-test pattern.

## Change

`tools/runtimecheck.zig` now tests:

- PATH-order executable discovery with a temporary executable file;
- missing entries returning no match;
- non-executable files being ignored on platforms with executable permission
  bits.

`build.zig` now creates an `alea-runtimecheck-tests` artifact and makes
`zig build runtimecheck` run those tests before the runtime availability
executable. `tools/toolingcheck.zig` verifies both runtimecheck dependencies, and
`docs/tooling.md` documents that runtimecheck runs helper tests.

## Validation

Relevant validation:

```sh
zig fmt build.zig tools/runtimecheck.zig tools/toolingcheck.zig tools/roadmapcheck.zig
zig test tools/runtimecheck.zig
zig build runtimecheck
zig build toolingcheck
zig build readmecheck
zig build roadmapcheck
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate-local
git diff --check
```

## Non-Completion Note

This milestone improves runtime-checker test coverage. It does not resolve
S4-M11's exact/default-compatible dense SIMD normal/exponential blocker, does not
execute an additional architecture/runtime runner, and is not whole-goal
completion evidence.
