# S4-M437 Validate-Local After Rand-Status Self-Test Aggregate

## Gap

S4-M436 added `zig build rand-status-self-test` and included it in
`validate-local`. The local Rust comparison aggregate needed fresh evidence
proving the self-test path runs as part of the aggregate.

## Validation

Full local validation command:

```text
$ zig build validate-local
```

Key output excerpts from the passing run:

```text
rand-status self-test ok
rand_bench_smoke self-test ok
rand_distr standard-normal: 39.6 M samples/s checksum=-3.640
rand_distr standard-normal f32: 37.2 M samples/s checksum=-3.640
test result: ok. 5 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
Alea local rand/rand_distr status (2026-07-06)
{
  "date": "2026-07-06",
  "baseline": {
    "rand": "~/Work/rand",
    "rand_distr": "cached rand_distr 0.6.0"
  },
  "current_conclusion": "no known unblocked local Rust core RNG gap",
  "remaining_blocker": "S4-M11 exact/default dense SIMD winner, new runtime, or new local Rust gap",
  "details": "compare/results/s4-m420-current-rand-status.md"
}
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
runtimecheck summary: required found=3 missing=0; opportunities found=0 missing=10
runtimecheck ok: no additional runtime runner available
toolingcheck ok
readmecheck ok
roadmapcheck ok
```

The run exited successfully. `compare/results/s4-m420-current-rand-status.md`
was refreshed to point at this S4-M437 validation run and its self-test output.

Focused roadmap validation for this evidence update:

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M437 is closed for the current bar: `zig build validate-local` passes with
`rand-status-self-test` included in the local Rust comparison aggregate. This is
validation evidence only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
