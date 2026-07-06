# S4-M365 Core-Guide WASI Dry-Run Guidance

## Gap

S4-M363 added `zig build wasi-dry-run`, but the core guide only mentioned
`validate-all` at a high level. Users reading the validation section should see
how to inspect the Node WASI runner argv without requiring a wasm execution.

## Change

`docs/core-guide.md` now:

- lists `zig build wasi-dry-run` in the validation command block;
- explains `node tools/run_wasi_test.js --dry-run <test.wasm>` for validating
  WASI runner arguments without reading or executing a wasm file.

`tools/toolingcheck.zig` guards these core-guide tokens.

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

S4-M365 is closed for the current bar: the core guide now explains WASI dry-run
usage and tooling guards it. This is evidence/tooling hardening only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
