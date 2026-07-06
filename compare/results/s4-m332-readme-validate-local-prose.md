# S4-M332 README `validate-local` Prose

Date: 2026-07-06

## Purpose

README listed `zig build validate-local`, but did not explain when to use it.
S4-M332 adds prose so users know it is the Linux-first local comparison aggregate
for native validation plus local Rust checks.

## Change

`README.md` now says:

```text
Use `zig build validate-local` for Linux-first local `rand` / `rand_distr`
comparison work: it runs native validation plus `surfacecheck` and
`runtimecheck`.
```

`tools/readmecheck.zig` now guards this explanation.

## Validation

Relevant validation:

```sh
zig fmt tools/readmecheck.zig tools/roadmapcheck.zig
zig build readmecheck
zig build roadmapcheck
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone improves README validation guidance. It does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not execute
an additional architecture/runtime runner, and is not whole-goal completion
evidence.
