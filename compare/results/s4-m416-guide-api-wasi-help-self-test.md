# S4-M416 Guide/API WASI Help-Output Self-Test Prose

## Gap

S4-M412 extended `tools/run_wasi_test.js --self-test` to validate help output.
README and the tooling catalog were updated in S4-M415/S4-M414, but the core
guide and API reference still described only dry-run and missing-argument
coverage.

## Change

`docs/core-guide.md` and `docs/api-reference.md` now explain that
`zig build wasi-self-test` / `node tools/run_wasi_test.js --self-test` test the
Node WASI runner dry-run, help-output, and missing-argument paths without wasm.

`tools/toolingcheck.zig` now requires the help-output wording in both docs.

## Validation

Focused validation commands:

```text
$ zig build toolingcheck
toolingcheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M416 is closed for the current bar: guide/API WASI self-test prose matches the
expanded runner self-test scope. This is portability documentation reliability
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
