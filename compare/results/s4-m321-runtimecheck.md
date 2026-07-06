# S4-M321 Runtime Runner Availability Checker

Date: 2026-07-06

## Purpose

S4-M11 has a runtime-runner branch: if a genuinely different architecture or
runtime becomes available, accepted profile validation should be run there before
continuing to treat the branch as blocked. Previously this was tracked by manual
`command -v` audits in the blocker evidence. S4-M321 adds an explicit checker.

## Change

Added:

```sh
zig build runtimecheck
```

The checker:

- requires current local tools `node`, `cargo`, and `rustc`;
- reports missing opportunity runners `qemu-aarch64`, `qemu-riscv64`,
  `qemu-x86_64`, `wine`, `wine64`, `wasmtime`, and `wasmer`;
- fails if any opportunity runner is found, prompting an S4-M11 blocker refresh;
- is included in `zig build validate-local` alongside native validation and
  `surfacecheck`.

Current output:

```text
runtimecheck required node: found /home/passchaos/.pixi/bin/node
runtimecheck required cargo: found /home/passchaos/.cargo/bin/cargo
runtimecheck required rustc: found /home/passchaos/.cargo/bin/rustc
runtimecheck opportunity qemu-aarch64: missing
runtimecheck opportunity qemu-riscv64: missing
runtimecheck opportunity qemu-x86_64: missing
runtimecheck opportunity wine: missing
runtimecheck opportunity wine64: missing
runtimecheck opportunity wasmtime: missing
runtimecheck opportunity wasmer: missing
runtimecheck ok: no additional runtime runner available
```

Documentation and guards were updated so `runtimecheck` is listed in README,
API/core/tooling docs, `readmecheck`, `toolingcheck`, `validate-local`, and the
S4-M11 blocker audit.

## Validation

Relevant validation:

```sh
zig fmt build.zig tools/runtimecheck.zig tools/readmecheck.zig tools/toolingcheck.zig tools/roadmapcheck.zig
zig build runtimecheck
zig build toolingcheck
zig build readmecheck
zig build roadmapcheck
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone automates a blocker check but confirms no additional runtime
runner is currently available. It does not resolve S4-M11's exact/default-
compatible dense SIMD normal/exponential blocker, does not execute an additional
architecture/runtime runner, and is not whole-goal completion evidence.
