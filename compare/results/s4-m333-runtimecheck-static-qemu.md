# S4-M333 Runtimecheck Static QEMU Runner Names

Date: 2026-07-06

## Purpose

Some Linux environments expose user-mode QEMU runners under `qemu-*-static`
names instead of only `qemu-*`. S4-M333 expands `runtimecheck` so these static
binaries also trigger the S4-M11 runner-opportunity branch.

## Change

`tools/runtimecheck.zig` now treats these additional names as opportunity
runners:

- `qemu-aarch64-static`
- `qemu-riscv64-static`
- `qemu-x86_64-static`

The S4-M11 blocker audit, tooling docs, core guide, toolingcheck doc-token
guards, and runtimecheck evidence were updated. The current summary is now:

```text
runtimecheck summary: required found=3 missing=0; opportunities found=0 missing=10
```

## Validation

Relevant validation:

```sh
zig fmt tools/runtimecheck.zig tools/toolingcheck.zig tools/roadmapcheck.zig
zig build runtimecheck
zig build toolingcheck
zig build roadmapcheck
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone broadens runner-opportunity detection but finds no currently
available additional runner. It does not resolve S4-M11's exact/default-
compatible dense SIMD normal/exponential blocker, does not execute an additional
architecture/runtime runner, and is not whole-goal completion evidence.
