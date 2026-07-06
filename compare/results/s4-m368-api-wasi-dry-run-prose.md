# S4-M368 API Reference WASI Dry-Run Prose

## Gap

The API reference listed `zig build wasi-dry-run` and the Node dry-run command,
but did not explain when to use them. API users scanning validation commands
should know that WASI dry-run validates runner argv without reading or executing
wasm.

## Change

`docs/api-reference.md` now explains:

```text
Use `zig build wasi-dry-run` or `node tools/run_wasi_test.js --dry-run <test.wasm>`
to verify Node WASI runner arguments without reading or executing a wasm file.
```

`tools/toolingcheck.zig` guards the API-reference guidance tokens.

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

S4-M368 is closed for the current bar: the API reference now explains WASI
dry-run usage and tooling guards it. This is evidence/tooling hardening only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
