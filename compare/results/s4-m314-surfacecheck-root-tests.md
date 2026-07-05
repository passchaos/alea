# S4-M314 Surfacecheck Root Resolution Tests

Date: 2026-07-06

## Purpose

S4-M313 made `surfacecheck` default roots resolve relative to `$HOME`, with
literal fallback paths when `$HOME` is unavailable. S4-M314 adds focused helper
tests so this root-resolution behavior does not regress.

## Change

`tools/surfacecheck.zig` now factors default root resolution into a helper and
tests:

- `$HOME` plus `default_home_suffix` returns a joined local baseline path;
- missing `$HOME` falls back to the checked-in literal default root;
- groups without a suffix keep the literal default even when `$HOME` exists.

These tests run through `zig build surfacecheck` via the S4-M310 build-step
wiring.

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

This milestone improves local comparison-tool portability test coverage. It does
not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add an additional architecture/runtime runner, and is not
whole-goal completion evidence.
