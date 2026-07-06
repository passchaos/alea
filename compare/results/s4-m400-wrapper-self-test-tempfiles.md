# S4-M400 Wrapper Self-Test Temp-File Safety

## Gap

The no-external wrapper self-tests for `tools/practrand.sh` and
`tools/rand_bench_smoke.sh` captured expected-failure diagnostics in fixed
`/tmp/alea-...` paths. Fixed paths can collide when self-tests run concurrently
and can leave stale files behind if a process exits early.

## Change

Both wrappers now use `mktemp` under `${TMPDIR:-/tmp}` and install a trap to
remove the temporary file on exit:

- `tools/practrand.sh --self-test`
- `tools/rand_bench_smoke.sh --self-test`

`tools/toolingcheck.zig` now requires `mktemp` and `trap` tokens in both wrapper
scripts.

## Validation

Focused validation commands:

```text
$ tools/practrand.sh --self-test
practrand self-test ok
```

```text
$ tools/rand_bench_smoke.sh --self-test
rand_bench_smoke self-test ok
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

S4-M400 is closed for the current bar: wrapper self-tests no longer share fixed
`/tmp` diagnostic paths and toolingcheck guards the safer pattern. This is
tooling reliability only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
