# S4-M390 PractRand Wrapper File-Input Guard

## Gap

`zig build practrand-dry-run` and `zig build practrand-self-test` execute
`tools/practrand.sh`, but the build steps did not register the script as an input.
That made rebuild behavior weaker than the WASI and Rust comparison wrapper
steps, where script/source changes are explicit file inputs.

## Change

`build.zig` now calls `addFileInput(b.path("tools/practrand.sh"))` for both
PractRand wrapper build steps:

- `practrand-dry-run`
- `practrand-self-test`

`tools/toolingcheck.zig` requires both file-input tokens, and `docs/tooling.md`
mentions PractRand wrapper file-input guards.

## Validation

Focused validation commands:

```text
$ zig build practrand-dry-run
zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 1048576 | RNG_test stdin64
```

```text
$ zig build practrand-self-test
practrand self-test ok
```

```text
$ zig build toolingcheck
toolingcheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M390 is closed for the current bar: PractRand wrapper build steps now track
their script input and toolingcheck guards the dependency shape. This is external
statistical tooling reliability only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
