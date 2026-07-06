# S4-M406 Tooling WASI Self-Test Prose Guard

## Gap

After S4-M405, README, the core guide, and the API reference had explicit guards
for the WASI runner self-test semantics. The tooling catalog mentioned
`node tools/run_wasi_test.js --self-test` and `zig build wasi-self-test`, but its
focused toolingcheck token set did not require the exact no-wasm dry-run and
missing-argument semantics.

## Change

`tools/toolingcheck.zig` now requires `docs/tooling.md` to retain:

- `node tools/run_wasi_test.js --self-test`
- `zig build wasi-self-test`
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

S4-M406 is closed for the current bar: the tooling catalog is guarded so it keeps
WASI runner self-test no-wasm semantics visible. This is portability
documentation reliability only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
