# S4-M308 README Surfacecheck Guard

Date: 2026-07-06

## Purpose

`zig build surfacecheck` is now the explicit local `rand` / `rand_core` /
`rand_distr` public-surface drift checker. The README already listed it in the
common command block, but `readmecheck` did not enforce that discovery token.
S4-M308 closes that documentation guard gap.

## Change

`tools/readmecheck.zig` now requires `README.md` to contain:

```sh
zig build surfacecheck
```

This keeps the local comparison checker visible alongside `test`, `apicheck`,
`examplecheck`, `toolingcheck`, `roadmapcheck`, `doccheck`, `validate`, and
`validate-all`.

## Validation

Relevant validation:

```sh
zig fmt tools/readmecheck.zig tools/roadmapcheck.zig
zig build readmecheck
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone improves documentation/tooling guardrails. It does not resolve
S4-M11's exact/default-compatible dense SIMD normal/exponential blocker, does not
add an additional architecture/runtime runner, and is not whole-goal completion
evidence.
