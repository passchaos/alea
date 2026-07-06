# S4-M367 Tooling WASI Dry-Run Prose Guard

## Gap

`docs/tooling.md` already listed `zig build wasi-dry-run`, but the key prose that
explains the lower-level Node runner dry-run command and that it does not read or
execute a wasm file was not directly guarded.

## Change

`tools/toolingcheck.zig` now requires `docs/tooling.md` to include:

- `node tools/run_wasi_test.js --dry-run <test.wasm> [args...]`
- `verify WASI runner arguments without reading or executing a wasm file`

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

S4-M367 is closed for the current bar: tooling-catalog WASI dry-run prose is now
guarded by `toolingcheck`. This is evidence/tooling hardening only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
