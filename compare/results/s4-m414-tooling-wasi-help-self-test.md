# S4-M414 Tooling Row For WASI Help Self-Test

## Gap

S4-M412 extended `tools/run_wasi_test.js --self-test` to validate help output,
but the tooling catalog's `zig build wasi-self-test` row still described only
dry-run output and missing-argument usage coverage. That row should match the
actual self-test scope.

## Change

`docs/tooling.md` now states that `zig build wasi-self-test` runs Node WASI
runner self-tests for:

- dry-run output;
- help output;
- missing-argument usage;
- all without reading or executing wasm.

`tools/toolingcheck.zig` now requires the full `wasi-self-test` table row so this
scope cannot silently narrow.

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

S4-M414 is closed for the current bar: the tooling catalog accurately documents
and guards the expanded WASI runner self-test scope. This is portability tooling
documentation reliability only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
