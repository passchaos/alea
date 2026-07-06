# S4-M380 Rust Comparison Bench Parser Tests

## Gap

Alea's Zig throughput benchmarks now helper-test `[bytes] [filter]` and
filter-only argument parsing before benchmark execution. The local Rust
comparison harness in `compare/rand_bench/src/main.rs` still kept equivalent
argument parsing inline in `main`, so a parser regression could silently skew
focused local `rand` / `rand_distr` comparison runs.

## Change

`compare/rand_bench/src/main.rs` now uses a small `Options` / `parse_options`
helper for default byte counts, explicit byte counts, filter-only arguments, and
byte-count-plus-filter arguments. Focused Rust unit tests cover those cases and
the legacy two-filter behavior where the first filter wins.

`build.zig` adds `zig build rand-bench-test`, which runs:

```text
cargo test --manifest-path compare/rand_bench/Cargo.toml
```

The build step registers `compare/rand_bench/Cargo.toml`,
`compare/rand_bench/Cargo.lock`, and `compare/rand_bench/src/main.rs` as inputs,
and `zig build validate-local` now depends on this Rust comparison helper-test
step before `surfacecheck` / `runtimecheck`. `docs/tooling.md`, README, the core
guide, and the API reference document the step; `toolingcheck` and `readmecheck`
guard the new discovery/dependency shape.

## Validation

Focused validation commands:

```text
$ cargo test --manifest-path compare/rand_bench/Cargo.toml
running 5 tests
...
test result: ok. 5 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```

```text
$ zig build rand-bench-test
running 5 tests
...
test result: ok. 5 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
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
runtimecheck summary: required found=3 missing=0; opportunities found=0 missing=10
runtimecheck ok: no additional runtime runner available
surfacecheck ok
...
readmecheck ok
toolingcheck ok
distcheck ok
distcheck ok
```

## Result

S4-M380 is closed for the current bar: the local Rust comparison benchmark now
has helper-tested argument parsing and a guarded build step that participates in
`validate-local`. This improves local comparison benchmark reliability only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
