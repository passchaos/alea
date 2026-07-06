# S4-M385 S4-M11 Benchmark-Gate Blocker Evidence

## Gap

Recent S4-M380..S4-M384 work added Rust comparison benchmark parser tests,
smoke execution, dry-run previews, smoke self-tests, and smoke override coverage
to the local comparison workflow. The S4-M11 blocker audit still only mentioned
`surfacecheck` as the local `rand` / `rand_distr` no-gap evidence branch, so the
blocker record could drift away from the actual `validate-local` comparison
coverage.

## Change

`compare/results/s4-m11-blocker-audit.md` now records that `zig build
validate-local` includes the Rust comparison benchmark gates:

- `zig build rand-bench-test`
- `zig build rand-bench-smoke`
- `zig build rand-bench-smoke-self-test`
- `ALEA_RAND_BENCH_MANIFEST` / `ALEA_RAND_BENCH_EXPECTED_ROW` smoke override
  coverage

The row now states that no new unblocked public-surface or local
comparison-benchmark gap is identified by the current local scan and smoke
coverage. `tools/roadmapcheck.zig` requires these blocker tokens, so future
blocker refreshes cannot drop the benchmark-gate evidence silently.

## Validation

Focused validation command:

```text
$ zig build roadmapcheck
roadmapcheck ok
```

Additional local comparison validation already run for this sequence:

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

S4-M385 is closed for the current bar: S4-M11 blocker evidence now matches the
current local Rust comparison validation gate shape. This is blocker-evidence
and tooling reliability only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
