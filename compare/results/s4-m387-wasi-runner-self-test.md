# S4-M387 WASI Runner Self-Tests

## Gap

`tools/run_wasi_test.js` had `--dry-run` support, but no self-test that could
validate runner argument handling without reading or executing a wasm file. That
left dry-run output and missing-argument usage diagnostics weaker than other
wrapper tooling such as the Rust benchmark smoke and PractRand helpers.

## Change

`tools/run_wasi_test.js --self-test` now launches the runner through Node to
validate:

- dry-run output for `sample.wasm --flag` is exactly `wasi sample.wasm --flag`;
- missing wasm arguments fail with status 2 and include the usage text.

`build.zig` adds `zig build wasi-self-test` when Node is available and registers
`tools/run_wasi_test.js` as an input. README, the core guide, the API reference,
and `docs/tooling.md` document the self-test. `toolingcheck` guards build-step,
doc, file-input, and runner tokens, while `readmecheck` guards README discovery.

## Validation

Focused validation commands:

```text
$ node --no-warnings tools/run_wasi_test.js --self-test
run_wasi_test self-test ok
```

```text
$ zig build wasi-self-test
run_wasi_test self-test ok
```

Broader validation commands:

```text
$ zig build toolingcheck
toolingcheck ok
```

```text
$ zig build readmecheck
readmecheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M387 is closed for the current bar: the Node WASI runner now has no-wasm
self-tests for dry-run argv and missing-argument usage behavior. This is
portability tooling reliability only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
