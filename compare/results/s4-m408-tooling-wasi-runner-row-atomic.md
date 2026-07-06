# S4-M408 Atomic Tooling WASI Runner Row Guard

## Gap

S4-M407 guarded the `tools/run_wasi_test.js` checked-tool row with separate
substrings. That ensured the row heading, `--dry-run` / `--self-test` wording,
and no-wasm semantics all appeared somewhere in `docs/tooling.md`, but the
checker could be made stronger by requiring the full row text so those meanings
remain co-located in the tool inventory.

## Change

`tools/toolingcheck.zig` now requires the complete tooling-catalog row:

```text
`tools/run_wasi_test.js` | Node WASI runner used by WASI build steps, with `--dry-run` argument reporting and `--self-test` coverage for dry-run and missing-argument paths without wasm.
```

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

S4-M408 is closed for the current bar: the checked-tool inventory keeps the WASI
runner dry-run, self-test, and no-wasm missing-argument semantics together in one
guarded row. This is portability documentation reliability only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
