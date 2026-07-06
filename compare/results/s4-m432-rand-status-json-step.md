# S4-M432 `rand-status-json` Build Step And Aggregate

## Gap

S4-M431 added `rand-status --json`, but the build graph only exposed JSON via
`zig build rand-status -- --json`. A dedicated build step makes the JSON path more
discoverable and lets `validate-local` exercise it directly.

## Change

- `build.zig` adds `zig build rand-status-json`, which runs `rand_status --json`
  after the rand-status helper tests.
- `zig build validate-local` now depends on both `rand-status` and
  `rand-status-json`.
- README, core guide, API reference, and tooling docs mention the dedicated JSON
  step.
- `tools/readmecheck.zig` and `tools/toolingcheck.zig` guard the new command,
  build-step dependency shape, and docs tokens.

## Validation

Observed JSON step output:

```text
$ zig build rand-status-json
{
  "date": "2026-07-06",
  "baseline": {
    "rand": "~/Work/rand",
    "rand_distr": "cached rand_distr 0.6.0"
  },
  "latest_gate": "zig build validate-local passes",
  "public_surface": "surfacecheck ok for rand/rand_core/rand_distr manifests",
  "rust_comparison": "parser tests and rand-bench-smoke pass",
  "runtime_runners": "node/cargo/rustc found; qemu/wine/wasmtime/wasmer not available",
  "current_conclusion": "no known unblocked local Rust core RNG gap",
  "remaining_blocker": "S4-M11 exact/default dense SIMD winner, new runtime, or new local Rust gap",
  "details": "compare/results/s4-m420-current-rand-status.md"
}
```

Focused validation commands:

```text
$ zig build rand-status-json
```

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
$ git diff --check
```

## Result

S4-M432 is closed for the current bar: stable JSON status output is now a first
class build step and part of `validate-local`. This is local comparison tooling
ergonomics only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
