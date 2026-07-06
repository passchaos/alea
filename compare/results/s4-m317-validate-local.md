# S4-M317 `validate-local` Aggregate

Date: 2026-07-06

## Purpose

The project focus is Linux-first local parity against the available Rust `rand`
/ `rand_distr` evidence. Before S4-M317, `zig build validate` covered native
Alea validation and `zig build surfacecheck` covered local Rust public-surface
manifest drift, but there was no aggregate step that combined both for the local
comparison workflow.
S4-M321 later added `zig build runtimecheck` to the same aggregate so runtime
runner availability evidence is checked with the local public-surface scan.

## Change

Added:

```sh
zig build validate-local
```

The new step depends on:

- `zig build validate`
- `zig build surfacecheck`
- `zig build runtimecheck`

Documentation and guards were updated:

- `README.md`, `docs/api-reference.md`, `docs/core-guide.md`, and
  `docs/tooling.md` list `zig build validate-local`;
- `tools/readmecheck.zig` requires the README command token;
- `tools/toolingcheck.zig` requires the build step and checks that it depends on
  `validate`, `surfacecheck`, and `runtimecheck`.

## Validation

Relevant validation:

```sh
zig fmt build.zig tools/readmecheck.zig tools/toolingcheck.zig tools/roadmapcheck.zig
zig build -Doptimize=ReleaseFast validate-local
zig build toolingcheck
zig build readmecheck
zig build roadmapcheck
git diff --check
```

## Non-Completion Note

This milestone adds a local validation aggregate but does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not add an
additional architecture/runtime runner, and is not whole-goal completion
evidence.
