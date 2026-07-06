# S4-M403 WASI Self-Test Usage Prose

## Gap

`tools/run_wasi_test.js --self-test` exists, but help output only listed the
command. It did not explain that the self-test validates dry-run and
missing-argument paths without reading or executing wasm.

## Change

`tools/run_wasi_test.js --help` now includes:

```text
--self-test validates dry-run and missing-argument paths without wasm
```

`tools/toolingcheck.zig` guards this runner token.

## Validation

Focused validation commands:

```text
$ node --no-warnings tools/run_wasi_test.js --help
usage: run_wasi_test.js [--dry-run] <test.wasm> [args...]
       run_wasi_test.js --self-test
       --self-test validates dry-run and missing-argument paths without wasm
```

```text
$ node --no-warnings tools/run_wasi_test.js --self-test
run_wasi_test self-test ok
```

```text
$ zig build toolingcheck
toolingcheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M403 is closed for the current bar: WASI runner help explains self-test
semantics and toolingcheck guards the text. This is portability tooling
reliability only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
