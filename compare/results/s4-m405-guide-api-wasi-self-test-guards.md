# S4-M405 Guide/API WASI Self-Test Prose Guards

## Gap

The core guide and API reference already mention `zig build wasi-self-test` and
`node tools/run_wasi_test.js --self-test`, including that they test dry-run and
missing-argument paths without wasm. `toolingcheck` guarded the runner script and
some dry-run tokens, but not this detailed self-test guidance in both docs.

## Change

`tools/toolingcheck.zig` now requires the core guide and API reference to keep:

- `zig build wasi-self-test`
- `node tools/run_wasi_test.js --self-test`
- `dry-run and missing-argument paths without wasm`

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

S4-M405 is closed for the current bar: detailed WASI runner self-test guidance in
the core guide and API reference is guarded. This is portability documentation
reliability only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
