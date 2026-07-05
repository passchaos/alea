# S4-M312 Surfacecheck Public-File Guard Tests

Date: 2026-07-06

## Purpose

S4-M306 added an unlisted-public-file guard to `surfacecheck`, and S4-M310 wired
`tools/surfacecheck.zig` tests into `zig build surfacecheck`. S4-M312 adds
focused tests for the helper logic behind that guard.

## Change

`tools/surfacecheck.zig` now tests:

- `knownFile` detects explicitly scanned files, including nested paths;
- `ignoredPublicFile` detects explicitly ignored private helper files;
- `hasPublicLine` detects public declarations and indented `pub fn` methods;
- `hasPublicLine` does not treat `pub(crate)` helpers or comments as public
  surface.

These tests run as part of `zig build surfacecheck` because of S4-M310.

## Validation

Relevant validation:

```sh
zig fmt tools/surfacecheck.zig tools/roadmapcheck.zig
zig test tools/surfacecheck.zig
zig build surfacecheck
zig build roadmapcheck
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone improves local comparison-tool test coverage. It does not resolve
S4-M11's exact/default-compatible dense SIMD normal/exponential blocker, does not
add an additional architecture/runtime runner, and is not whole-goal completion
evidence.
