# S4-M418 Validate-Local After WASI Help-Output Docs

## Gap

S4-M414 through S4-M417 synchronized WASI help-output self-test documentation and
refreshed broad native validation. The Linux-first local `rand` / `rand_distr`
comparison aggregate needed fresh evidence too, because it is the project gate
for local Rust comparison workflows, public-surface drift, and runtime-runner
availability.

## Validation

Full local validation command:

```text
$ zig build validate-local
```

Key output excerpts from the passing run:

```text
practrand self-test ok
rand_distr standard-normal: 41.2 M samples/s checksum=-3.640
rand_distr standard-normal f32: 38.3 M samples/s checksum=-3.640
test result: ok. 5 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
surfacecheck ok
rand_bench_smoke self-test ok
runtimecheck summary: required found=3 missing=0; opportunities found=0 missing=10
runtimecheck ok: no additional runtime runner available
toolingcheck ok
readmecheck ok
roadmapcheck ok
```

The run exited successfully.

Focused roadmap validation for this evidence update:

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M418 is closed for the current bar: `zig build validate-local` passes after
the WASI help-output documentation/guard updates, covering native validation,
Rust comparison parser tests, tiny Rust comparison smoke, smoke self-test,
surfacecheck, and runtimecheck. This is validation evidence only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
