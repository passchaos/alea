# S4-M379 Bench-Libc Parser Helper Tests

## Gap

S4-M378 wired parser tests into the main `zig build bench` step. The libc-linked
benchmark uses the same `bench/throughput.zig` source and argument parser, but
`zig build bench-libc` did not yet run those helper tests before the executable.

## Change

`build.zig` now creates `alea-bench-libc-tests` with `link_libc = true` and runs
it before `alea-throughput-libc`. `tools/toolingcheck.zig` guards the dependency
shape, and `docs/tooling.md` documents that `bench-libc` accepts `[bytes]
[filter]` or filter-only arguments.

## Validation

Focused validation command:

```text
$ zig build bench-libc -- 1024 standard-normal
```

Broader validation commands:

```text
$ zig build toolingcheck
toolingcheck ok
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M379 is closed for the current bar: libc-linked throughput benchmarks now run
parser helper tests before execution. This is performance-tooling ergonomics only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
