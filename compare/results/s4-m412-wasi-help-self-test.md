# S4-M412 WASI Runner Help Self-Test Coverage

## Gap

S4-M411 added dry-run explanatory prose to `tools/run_wasi_test.js --help`, but
`tools/run_wasi_test.js --self-test` still only checked dry-run output and the
missing-argument usage path. A regression in help prose could therefore pass the
runner's own self-test and only be caught by outer tooling checks.

## Change

`tools/run_wasi_test.js --self-test` now also spawns `--help` and requires both:

- `--dry-run prints WASI argv without reading or executing wasm`
- `--self-test validates dry-run and missing-argument paths without wasm`

The runner reports `run_wasi_test self-test: help usage mismatch` if those help
semantics drift. `tools/toolingcheck.zig` guards that diagnostic token.

## Validation

Observed self-test output:

```text
$ node tools/run_wasi_test.js --self-test
run_wasi_test self-test ok
```

Focused validation commands:

```text
$ zig build wasi-self-test
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

```text
$ git diff --check
```

## Result

S4-M412 is closed for the current bar: the WASI runner's own no-wasm self-test
now protects help prose for direct dry-run and self-test semantics. This is
portability tooling reliability only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
