# S4-M409 README Direct WASI Self-Test Command

## Gap

README documented `zig build wasi-self-test`, but unlike the core guide, API
reference, and tooling catalog it did not show the direct
`node tools/run_wasi_test.js --self-test` command. Direct runner invocation is a
useful portability/debugging path because it validates the no-wasm dry-run and
missing-argument paths without running the build graph.

## Change

README now lists `node tools/run_wasi_test.js --self-test` in the validation
command block and explains that either `zig build wasi-self-test` or the direct
Node command self-tests the runner dry-run and missing-argument paths without
wasm.

`tools/readmecheck.zig` now requires the direct command token and extends the
focused WASI guidance helper test to cover it.

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

S4-M409 is closed for the current bar: README preserves direct Node WASI runner
self-test discovery. This is portability documentation reliability only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
