# S4-M381 Rust Comparison Bench Smoke Step

## Gap

S4-M380 added parser unit tests for the local Rust comparison benchmark, but the
local comparison workflow still lacked a cheap end-to-end check that the Rust
binary actually accepts filtered benchmark arguments and emits the expected
filtered rows. Full Rust comparison runs are intentionally expensive; this gap
only needs a tiny smoke row to catch wiring or filter regressions before relying
on local `rand` / `rand_distr` throughput evidence.

## Change

`tools/rand_bench_smoke.sh` runs a tiny filtered Rust comparison command:

```text
cargo run --manifest-path compare/rand_bench/Cargo.toml -- 1024 standard-normal
```

The wrapper prints the output, verifies that a filtered `rand_distr
standard-normal` row is present, and verifies that an unrelated `rand SmallRng:`
byte-throughput row is not present. It supports `--help`, `[bytes] [filter]`,
and filter-only invocation for focused manual checks.

`build.zig` adds `zig build rand-bench-smoke`, registers the smoke script,
Cargo manifest, Cargo lockfile, and Rust source as inputs, and adds the smoke
step to `zig build validate-local` alongside `rand-bench-test`, `surfacecheck`,
and `runtimecheck`. `docs/tooling.md`, README, the core guide, and the API
reference document the step; `toolingcheck` and `readmecheck` guard the new
build-step/tooling/discovery shape.

## Validation

Focused validation commands:

```text
$ tools/rand_bench_smoke.sh standard-normal
rand_distr standard-normal: ... M samples/s checksum=-3.640
rand_distr standard-normal f32: ... M samples/s checksum=-3.640
```

```text
$ zig build rand-bench-smoke
rand_distr standard-normal: ... M samples/s checksum=-3.640
rand_distr standard-normal f32: ... M samples/s checksum=-3.640
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
rand_distr standard-normal: ... M samples/s checksum=-3.640
rand_distr standard-normal f32: ... M samples/s checksum=-3.640
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

S4-M381 is closed for the current bar: local Rust comparison benchmark argument
filtering now has both parser unit tests and a tiny end-to-end smoke run wired
into `validate-local`. This is comparison-tooling reliability only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
