# S4-M310 Surfacecheck Build-Step Tests

Date: 2026-07-06

## Purpose

S4-M309 added focused unit tests for `tools/surfacecheck.zig` token matching, but
those tests only ran when invoked directly with `zig test tools/surfacecheck.zig`.
S4-M310 wires the tests into the normal local public-surface checker step so the
helper coverage is exercised whenever developers run `zig build surfacecheck`.

## Change

`build.zig` now creates an `alea-surfacecheck-tests` test artifact for
`tools/surfacecheck.zig` and makes the `surfacecheck` build step depend on it
before running the checker executable. `docs/tooling.md` now describes that the
step runs helper tests as part of the local public-surface comparison.

## Validation

Relevant validation:

```sh
zig fmt build.zig tools/roadmapcheck.zig
zig build surfacecheck
zig build toolingcheck
zig build roadmapcheck
zig build doccheck
zig build test
git diff --check
```

`zig build surfacecheck` passes and still reports the current source/manifest
coverage summary:

```text
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
```

## Non-Completion Note

This milestone improves local comparison-tool validation. It does not resolve
S4-M11's exact/default-compatible dense SIMD normal/exponential blocker, does not
add an additional architecture/runtime runner, and is not whole-goal completion
evidence.
