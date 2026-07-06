# S4-M366 README WASI Dry-Run Prose

## Gap

README listed `zig build wasi-dry-run`, but did not explain when to use it. Since
README is the first-contact command list, the command should carry enough context
to distinguish it from `zig build test-wasi` and `zig build wasi-report`.

## Change

README now explains:

```text
Use `zig build wasi-dry-run` to verify the Node WASI runner arguments without
reading or executing a wasm file.
```

`tools/readmecheck.zig` now guards the usage and no-execution explanation tokens
and includes focused helper coverage for the wording.

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

S4-M366 is closed for the current bar: README now explains `wasi-dry-run` usage,
and the prose is guarded. This is evidence/tooling hardening only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
