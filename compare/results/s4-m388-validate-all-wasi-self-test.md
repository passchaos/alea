# S4-M388 Validate-All WASI Dry/Self-Test Aggregate

## Gap

`docs/tooling.md` already said `zig build validate-all` adds `wasi-dry-run`, but
`build.zig` only depended on native validation, crosscheck, `test-wasi`, and
`wasi-report`. After S4-M387 added `zig build wasi-self-test`, the
portability-sensitive aggregate also needed to include the no-wasm runner
self-test so documented coverage and actual build coverage stayed aligned.

## Change

`build.zig` now makes `zig build validate-all` depend on:

- `zig build validate`
- `zig build crosscheck`
- `zig build test-wasi`
- `zig build wasi-dry-run`
- `zig build wasi-self-test`
- `zig build wasi-report`

README, the core guide, the API reference, and `docs/tooling.md` now describe
`validate-all` as including WASI dry/self tests. `tools/toolingcheck.zig` guards
both aggregate dependencies and the updated documentation tokens.

## Validation

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
$ zig build readmecheck
readmecheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ zig build validate-local
runtimecheck summary: required found=3 missing=0; opportunities found=0 missing=10
runtimecheck ok: no additional runtime runner available
surfacecheck ok
...
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M388 is closed for the current bar: the portability-sensitive aggregate now
matches the documented WASI dry-run coverage and includes the WASI runner
self-test. This is portability validation reliability only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
