# S4-M382 Rust Bench Smoke Dry-Run

## Gap

S4-M381 added a tiny end-to-end Rust comparison benchmark smoke run. That smoke
run is cheap, but it still starts Cargo and the Rust benchmark binary. The local
comparison workflow did not yet have a no-Cargo way to verify the smoke command
shape, default byte count, filter handling, and expected-row substring when
editing docs/build wiring or debugging a machine without a ready Rust toolchain.

## Change

`tools/rand_bench_smoke.sh` now supports `--dry-run`. The dry-run mode accepts
the same default, `[bytes] [filter]`, and filter-only argument shapes as the real
smoke run, but prints the cargo command and expected row substring instead of
executing Cargo:

```text
cargo run --manifest-path compare/rand_bench/Cargo.toml -- 1024 standard-normal
expected row substring: standard-normal
```

`build.zig` adds `zig build rand-bench-smoke-dry-run`, which runs
`tools/rand_bench_smoke.sh --dry-run 1024 standard-normal` and registers the
smoke wrapper as an input. README, the core guide, the API reference, and the
tooling catalog document the dry-run step. `toolingcheck` guards the build-step,
documentation, and script tokens; `readmecheck` guards README discovery.

## Validation

Focused validation commands:

```text
$ tools/rand_bench_smoke.sh --dry-run standard-normal
cargo run --manifest-path compare/rand_bench/Cargo.toml -- 1024 standard-normal
expected row substring: standard-normal
```

```text
$ tools/rand_bench_smoke.sh --dry-run 2048 normal
cargo run --manifest-path compare/rand_bench/Cargo.toml -- 2048 normal
expected row substring: normal
```

```text
$ zig build rand-bench-smoke-dry-run
cargo run --manifest-path compare/rand_bench/Cargo.toml -- 1024 standard-normal
expected row substring: standard-normal
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

S4-M382 is closed for the current bar: the Rust comparison smoke wrapper now has
a no-Cargo dry-run command preview that is discoverable through `zig build
rand-bench-smoke-dry-run` and guarded by docs/checkers. This is local comparison
tooling reliability only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
