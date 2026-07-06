# S4-M375 Core-Guide Crosscheck Target Prose

## Gap

S4-M369/S4-M370/S4-M374 documented the exact `zig build crosscheck` target set
in the tooling catalog, README, and API reference. The core guide's validation
section still lacked the explicit target set.

## Change

`docs/core-guide.md` now states that `zig build crosscheck` compiles these
targets without executing them:

- `wasm32-wasi`
- `aarch64-linux`
- `riscv64-linux`
- `x86_64-windows`
- `x86_64-macos`
- `aarch64-macos`

`tools/toolingcheck.zig` guards the core-guide target-list and no-execute
wording.

## Validation

Focused validation command:

```text
$ zig build toolingcheck
toolingcheck ok
```

Broader roadmap validation command:

```text
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M375 is closed for the current bar: core-guide portability compile coverage is
now explicit and guarded. This is evidence/tooling hardening only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
