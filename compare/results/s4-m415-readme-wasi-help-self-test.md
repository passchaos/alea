# S4-M415 README WASI Help-Output Self-Test Prose

## Gap

S4-M412 extended `tools/run_wasi_test.js --self-test` to validate help output,
and S4-M414 documented that expanded scope in `docs/tooling.md`. README still
said the WASI self-test covered dry-run and missing-argument paths, but did not
mention help-output coverage.

## Change

README now explains that `zig build wasi-self-test` or
`node tools/run_wasi_test.js --self-test` validates the Node WASI runner:

- dry-run path;
- help-output path;
- missing-argument path;
- all without wasm.

`tools/readmecheck.zig` requires the updated help-output wording and keeps a
focused helper test for the exact token.

## Validation

Focused validation commands:

```text
$ zig build readmecheck
readmecheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M415 is closed for the current bar: README now keeps the expanded WASI
self-test scope visible. This is portability documentation reliability only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
