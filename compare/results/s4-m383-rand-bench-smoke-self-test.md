# S4-M383 Rust Bench Smoke Self-Tests

## Gap

S4-M382 added a dry-run preview for the Rust comparison smoke wrapper, but the
shell wrapper's own argument handling still had no no-cargo test coverage. The
wrapper now sits on the local `rand` / `rand_distr` comparison validation path,
so default arguments, filter-only mode, count-plus-filter mode, and invalid
filter-only diagnostics should be checked before `validate-local` relies on it.

## Change

`tools/rand_bench_smoke.sh` now supports `--self-test`. The self-test invokes the
wrapper's `--dry-run` mode to validate:

- default command shape: `1024 standard-normal`;
- filter-only command shape: `normal` becomes `1024 normal`;
- count-plus-filter command shape: `2048 normal` is preserved;
- invalid filter-only extra argument (`normal exp`) fails with the documented
  diagnostic.

`build.zig` adds `zig build rand-bench-smoke-self-test`, registers the smoke
script as an input, and includes the self-test in `zig build validate-local`.
README, the core guide, the API reference, and the tooling catalog document the
self-test step. `toolingcheck` guards the build-step, validate-local dependency,
docs, and script tokens; `readmecheck` guards README discovery.

## Validation

Focused validation commands:

```text
$ tools/rand_bench_smoke.sh --self-test
rand_bench_smoke self-test ok
```

```text
$ zig build rand-bench-smoke-self-test
rand_bench_smoke self-test ok
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

```text
$ zig build validate-local
running 5 tests
...
test result: ok. 5 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
rand_bench_smoke self-test ok
runtimecheck summary: required found=3 missing=0; opportunities found=0 missing=10
runtimecheck ok: no additional runtime runner available
surfacecheck ok
...
toolingcheck ok
roadmapcheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M383 is closed for the current bar: the Rust comparison smoke wrapper now has
no-cargo self-tests for the dry-run argument paths and invalid filter-only
diagnostics, and those self-tests participate in `validate-local`. This is local
comparison tooling reliability only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
