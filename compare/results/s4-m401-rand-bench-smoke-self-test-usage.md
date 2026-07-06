# S4-M401 Rust Bench Smoke Self-Test Usage

## Gap

`tools/rand_bench_smoke.sh` supports `--self-test`, but its usage text only
listed normal and `--dry-run` forms. The self-test is now part of local
comparison validation, so it should be discoverable from `--help` as well.

## Change

`tools/rand_bench_smoke.sh --help` now lists:

```text
rand_bench_smoke.sh --self-test
```

and explains that `--self-test` validates wrapper argument parsing without
running cargo. `tools/toolingcheck.zig` guards both script tokens.

## Validation

Focused validation commands:

```text
$ tools/rand_bench_smoke.sh --help
usage: rand_bench_smoke.sh [bytes] [filter]
...
       rand_bench_smoke.sh --self-test
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

S4-M401 is closed for the current bar: the Rust comparison smoke wrapper exposes
its self-test mode in help output, and toolingcheck guards that discoverability.
This is local comparison tooling reliability only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
