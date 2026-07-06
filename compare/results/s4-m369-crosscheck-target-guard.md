# S4-M369 Crosscheck Target Guard

## Gap

`zig build crosscheck` compiles unit tests for secondary targets, but the tooling
catalog only described them generically as secondary targets. If a target were
removed from `build.zig`, the docs/checks would not make that narrowing obvious.

## Change

`docs/tooling.md` now lists the current crosscheck target set:

- `wasm32-wasi`
- `aarch64-linux`
- `riscv64-linux`
- `x86_64-windows`
- `x86_64-macos`
- `aarch64-macos`

`tools/toolingcheck.zig` now verifies each target token appears in both
`build.zig` and `docs/tooling.md`.

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

S4-M369 is closed for the current bar: cross-target compile coverage is now
explicitly documented and guarded. This is evidence/tooling hardening only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
