# S4-M407 Tooling WASI Runner Tool-Row Self-Test Semantics

## Gap

The tooling catalog's WASI runtime section and validation prose now preserve the
no-wasm `wasi-self-test` semantics, but the checked-in tool inventory row for
`tools/run_wasi_test.js` still described only generic `--self-test` coverage.
That row is a second discovery path for the runner, so it should retain the same
explicit dry-run and missing-argument semantics.

## Change

`docs/tooling.md` now describes `tools/run_wasi_test.js` as having
`--self-test` coverage for dry-run and missing-argument paths without wasm.
`tools/toolingcheck.zig` guards the checked-tool row tokens:

- `` `tools/run_wasi_test.js` | Node WASI runner used by WASI build steps ``
- `` `--dry-run` argument reporting and `--self-test` coverage ``
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

S4-M407 is closed for the current bar: the tooling catalog's checked-tool row
keeps WASI runner self-test no-wasm semantics visible. This is portability
documentation reliability only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
