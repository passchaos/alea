# S4-M410 README Direct WASI Dry-Run Command

## Gap

After S4-M409, README documented the direct `node tools/run_wasi_test.js
--self-test` command. The matching direct dry-run command still only appeared in
the deeper guide/API/tooling docs, even though README already described the dry-run
semantics through `zig build wasi-dry-run`.

## Change

README now lists `node tools/run_wasi_test.js --dry-run <test.wasm>` in the
validation command block and explains that either `zig build wasi-dry-run` or the
direct Node command verifies runner argv without reading or executing wasm.

`tools/readmecheck.zig` now requires the direct dry-run command token and extends
the focused WASI guidance helper test to cover it.

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

S4-M410 is closed for the current bar: README preserves direct Node WASI runner
dry-run discovery. This is portability documentation reliability only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
