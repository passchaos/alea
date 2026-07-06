# S4-M411 WASI Runner Dry-Run Help Prose

## Gap

`tools/run_wasi_test.js --help` listed the dry-run form, but only the self-test
line explained the no-wasm behavior. Users invoking the runner directly had to
infer that `--dry-run` prints argv without reading or executing wasm from deeper
docs or from behavior.

## Change

`tools/run_wasi_test.js --help` now prints:

```text
--dry-run prints WASI argv without reading or executing wasm
```

`tools/toolingcheck.zig` requires that runner token so the usage text cannot
silently lose the no-wasm dry-run semantics.

## Validation

Observed help output:

```text
$ node tools/run_wasi_test.js --help
usage: run_wasi_test.js [--dry-run] <test.wasm> [args...]
       run_wasi_test.js --self-test
       --dry-run prints WASI argv without reading or executing wasm
       --self-test validates dry-run and missing-argument paths without wasm
```

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

S4-M411 is closed for the current bar: direct WASI runner help documents the
no-wasm dry-run behavior and toolingcheck guards it. This is portability tooling
reliability only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
