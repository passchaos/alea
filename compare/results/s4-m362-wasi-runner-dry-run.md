# S4-M362 WASI Runner Dry-Run

## Gap

`tools/run_wasi_test.js` is the Node WASI runner used by `zig build test-wasi`
and the WASI report chain. Before S4-M362, checking argument handling required a
real wasm file because the script immediately read and compiled the path.

## Change

`tools/run_wasi_test.js` now supports:

- `--help` usage output;
- `--dry-run <test.wasm> [args...]`, printing the WASI argv and exiting before
  reading or compiling wasm;
- the existing execution path remains unchanged for normal runs.

`docs/tooling.md` and `docs/api-reference.md` mention the dry-run form, and
`tools/toolingcheck.zig` guards the runner support tokens.

## Validation

Focused validation command:

```text
$ node tools/run_wasi_test.js --dry-run sample.wasm --flag
wasi sample.wasm --flag
```

Broader validation commands:

```text
$ zig build toolingcheck
toolingcheck ok
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M362 is closed for the current bar: WASI runner argument handling can now be
validated without a wasm input file. This is evidence/tooling hardening only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
