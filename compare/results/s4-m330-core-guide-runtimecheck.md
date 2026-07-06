# S4-M330 Core-Guide Runtimecheck Runner List

Date: 2026-07-06

## Purpose

`docs/tooling.md` documents the exact `runtimecheck` required and opportunity
runner sets. `docs/core-guide.md` still used a shorter grouped phrase
("QEMU/Wine/wasmtime/wasmer"). S4-M330 syncs the core guide to the exact list so
users can see the same S4-M11 runner set from either guide.

## Change

`docs/core-guide.md` now states that `zig build runtimecheck` requires:

- `node`
- `cargo`
- `rustc`

and fails if any S4-M11 opportunity runner appears:

- `qemu-aarch64`
- `qemu-riscv64`
- `qemu-x86_64`
- `wine`
- `wine64`
- `wasmtime`
- `wasmer`

## Validation

Relevant validation:

```sh
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone improves documentation consistency for the runtime-runner blocker
check. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not execute an additional architecture/runtime
runner, and is not whole-goal completion evidence.
