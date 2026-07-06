# S4-M326 Runtimecheck Runner-Set Docs

Date: 2026-07-06

## Purpose

`runtimecheck` is now part of the local validation workflow, but the tooling
catalog should make its exact required and opportunity runner sets visible
without forcing readers to open `tools/runtimecheck.zig`.

## Change

`docs/tooling.md` now states that `zig build runtimecheck` treats these as
required local tools:

- `node`
- `cargo`
- `rustc`

It also lists S4-M11 opportunity runners:

- `qemu-aarch64`
- `qemu-riscv64`
- `qemu-x86_64`
- `wine`
- `wine64`
- `wasmtime`
- `wasmer`

`tools/toolingcheck.zig` now verifies that `docs/tooling.md` mentions
`zig build runtimecheck`, `qemu-aarch64`, and `wasmtime`, keeping the runner-set
documentation visible.

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

This milestone improves documentation for the runtime-runner blocker check. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not execute an additional architecture/runtime runner, and is not
whole-goal completion evidence.
