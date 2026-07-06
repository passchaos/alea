# S4-M355 Stream Helper Tests

## Gap

`zig build stream` is the raw RNG-byte exporter used by the Current Rule for
external statistical tools such as PractRand. Before S4-M355, the executable
parsed engine names, aliases, seeds, and byte counts inline, and `zig build
stream` did not run focused helper tests before emitting bytes.

## Change

`tools/stream.zig` now factors command-line handling through helper functions and
includes focused tests for:

- documented engine names and aliases (`fast` / `alea4x64`, `default` /
  `xoshiro256`, `xoshiro128++`, `xoshiro256++`, ChaCha variants, etc.);
- default options (`fast`, seed `0x51a7_c0de`, 64 MiB);
- explicit `--engine`, `--seed`, and `--bytes` parsing;
- invalid argument paths for unknown engines, missing values, non-numeric seeds,
  and unknown flags.

`build.zig` now creates `alea-stream-tests` and makes `zig build stream` run
those tests before `alea-stream` writes raw RNG bytes.

`tools/toolingcheck.zig` guards this new dependency shape, and `docs/tooling.md`
documents that stream runs helper tests.

## Validation

Focused validation command:

```text
$ zig build stream -- --engine fast --bytes 16
```

The command first runs helper tests, then writes the requested 16 raw bytes.

Broader documentation/roadmap validation command:

```text
$ zig build doccheck
apicheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M355 is closed for the current bar: the raw stream exporter now validates its
engine-name alias and argument-parsing helpers before emitting bytes. This is
evidence/tooling hardening only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
