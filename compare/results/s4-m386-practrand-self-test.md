# S4-M386 PractRand Wrapper Self-Tests

## Gap

`tools/practrand.sh` had `--dry-run` support and a `zig build practrand-dry-run`
step, but the wrapper itself had no no-`RNG_test` self-test. That meant default
pipeline construction, `PRACTRAND_BIN` overrides, and invalid argument-count
usage diagnostics could regress without being caught unless external PractRand
was installed or a maintainer manually inspected dry-run output.

## Change

`tools/practrand.sh --self-test` now validates:

- default dry-run command shape:
  `zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 1073741824 | RNG_test stdin64`;
- custom `PRACTRAND_BIN` dry-run command shape;
- invalid argument-count handling reports the wrapper usage and fails.

`build.zig` adds `zig build practrand-self-test`. README, the core guide, the
API reference, and `docs/tooling.md` document both `tools/practrand.sh
--self-test` and `zig build practrand-self-test`. `toolingcheck` guards the new
build-step dependency and script/doc tokens, and `readmecheck` guards README
discovery.

## Validation

Focused validation commands:

```text
$ tools/practrand.sh --self-test
practrand self-test ok
```

```text
$ zig build practrand-self-test
practrand self-test ok
```

Broader validation commands:

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

## Result

S4-M386 is closed for the current bar: the PractRand wrapper now has no-external
self-tests for dry-run command construction and argument validation. This is
external statistical tooling reliability only; it does not resolve S4-M11 and is
not whole-goal completion evidence.
