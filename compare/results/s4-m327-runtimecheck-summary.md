# S4-M327 Runtimecheck Summary Counts

Date: 2026-07-06

## Purpose

`runtimecheck` listed each required and opportunity runner individually. S4-M327
adds a compact summary line so blocker audits can verify the current runner state
at a glance.

## Change

`tools/runtimecheck.zig` now prints:

```text
runtimecheck summary: required found=3 missing=0; opportunities found=0 missing=10
```

before the final OK/failure decision. The S4-M11 blocker audit now records that
summary, and `roadmapcheck` requires it to remain present.

Current relevant output:

```text
runtimecheck required node: found /home/passchaos/.pixi/bin/node
runtimecheck required cargo: found /home/passchaos/.cargo/bin/cargo
runtimecheck required rustc: found /home/passchaos/.cargo/bin/rustc
runtimecheck opportunity qemu-aarch64: missing
runtimecheck opportunity qemu-aarch64-static: missing
runtimecheck opportunity qemu-riscv64: missing
runtimecheck opportunity qemu-riscv64-static: missing
runtimecheck opportunity qemu-x86_64: missing
runtimecheck opportunity qemu-x86_64-static: missing
runtimecheck opportunity wine: missing
runtimecheck opportunity wine64: missing
runtimecheck opportunity wasmtime: missing
runtimecheck opportunity wasmer: missing
runtimecheck summary: required found=3 missing=0; opportunities found=0 missing=10
runtimecheck ok: no additional runtime runner available
```

## Validation

Relevant validation:

```sh
zig fmt tools/runtimecheck.zig tools/roadmapcheck.zig
zig build runtimecheck
zig build roadmapcheck
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone improves runtime-checker observability and blocker evidence. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not execute an additional architecture/runtime runner, and is not
whole-goal completion evidence.
