# S4-M384 Rust Bench Smoke Env Overrides

## Gap

The Rust comparison smoke wrapper supports `ALEA_RAND_BENCH_MANIFEST` and
`ALEA_RAND_BENCH_EXPECTED_ROW`, but those override paths were not self-tested or
made visible in the main docs. That left custom local Rust comparison smoke
checks weaker than the default `compare/rand_bench/Cargo.toml` /
filter-substring path.

## Change

`tools/rand_bench_smoke.sh --self-test` now exercises both overrides through the
no-cargo dry-run path:

```text
ALEA_RAND_BENCH_MANIFEST=/tmp/custom-rand-bench.toml \
ALEA_RAND_BENCH_EXPECTED_ROW=custom-row \
tools/rand_bench_smoke.sh --dry-run 4096 exp
```

The self-test verifies that the printed cargo command uses the custom manifest
and that the expected-row substring is `custom-row`. README, the core guide, the
API reference, and the tooling catalog now mention the override names.
`toolingcheck` guards the script and documentation tokens, and `readmecheck`
guards README discovery of both override names.

## Validation

Focused validation command:

```text
$ tools/rand_bench_smoke.sh --self-test
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
rand_bench_smoke self-test ok
running 5 tests
...
test result: ok. 5 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
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

S4-M384 is closed for the current bar: custom manifest and expected-row override
paths for the local Rust comparison smoke wrapper are self-tested and documented.
This is local comparison tooling reliability only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
