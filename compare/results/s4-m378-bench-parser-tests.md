# S4-M378 Bench Parser Helper Tests

## Gap

The main throughput benchmark already accepted `[bytes] [filter]` and filter-only
arguments, but this behavior was inline and untested. After S4-M377 improved
`vectorbench`, the primary `bench` entry point needed equivalent helper-test
coverage and build-step wiring.

## Change

`bench/throughput.zig` now parses options through a helper and tests:

- default bytes with no filter;
- explicit byte count;
- filter-only first argument;
- byte count plus filter.

`build.zig` now creates `alea-bench-tests` and makes `zig build bench` run those
tests before the `alea-throughput` executable. `tools/toolingcheck.zig` guards
that dependency shape, and `docs/tooling.md` documents filter-only support.

## Validation

Focused validation command:

```text
$ zig build bench -- 1024 standard-normal
```

Broader validation commands:

```text
$ zig build toolingcheck
toolingcheck ok
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M378 is closed for the current bar: throughput benchmark argument parsing is
helper-tested and build-step guarded. This is performance-tooling ergonomics only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
