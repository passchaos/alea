# S4-M328 Runtimecheck Documentation Token Guard

Date: 2026-07-06

## Purpose

S4-M326 documented the runtimecheck required and opportunity runner sets in
`docs/tooling.md`, but `toolingcheck` only guarded a subset of that list. S4-M328
makes the documentation guard cover the full current runner set.

## Change

`tools/toolingcheck.zig` now requires `docs/tooling.md` to mention:

- `zig build runtimecheck`
- required tools: `node`, `cargo`, `rustc`
- opportunity runners: `qemu-aarch64`, `qemu-riscv64`, `qemu-x86_64`, `wine`,
  `wine64`, `wasmtime`, `wasmer`

## Validation

Relevant validation:

```sh
zig fmt tools/toolingcheck.zig tools/roadmapcheck.zig
zig build toolingcheck
zig build roadmapcheck
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone improves documentation guardrails for the runtime-runner blocker
check. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not execute an additional architecture/runtime
runner, and is not whole-goal completion evidence.
