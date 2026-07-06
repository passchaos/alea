# S4-M370 README Crosscheck Target Prose

## Gap

S4-M369 documented the exact `zig build crosscheck` target set in the tooling
catalog, but README still only listed `zig build crosscheck` and described
`validate-all` generically as cross-target compile checks.

## Change

README now states that `zig build crosscheck` compiles these targets without
executing them:

- `wasm32-wasi`
- `aarch64-linux`
- `riscv64-linux`
- `x86_64-windows`
- `x86_64-macos`
- `aarch64-macos`

`tools/readmecheck.zig` guards representative target-list tokens and the
no-execute guidance, with focused helper coverage.

## Validation

Focused validation command:

```text
$ zig build readmecheck
readmecheck ok
```

Broader roadmap validation command:

```text
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M370 is closed for the current bar: README now makes crosscheck target
coverage explicit, and `readmecheck` guards the wording. This is evidence/tooling
hardening only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
