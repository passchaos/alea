# S4-M455 Direct `rand-status` Command Matrix

## Gap

S4-M450 recorded the dedicated `rand-status*` build steps plus direct `--help`.
README, the core guide, and the API reference also document direct argument forms
through `zig build rand-status -- --json`, `--schema-version`, and `--self-test`.
Those direct forms needed their own recorded and guarded evidence.

## Validation

Observed direct command matrix:

```text
$ zig build rand-status -- --json
{
  "schema_version": 1,
  "date": "2026-07-06",
  "baseline": {
    "rand": "~/Work/rand",
    "rand_distr": "cached rand_distr 0.6.0"
  },
  "latest_gate": "zig build validate-local passes",
  "validate_local_passes": true,
  "public_surface": "surfacecheck ok for rand/rand_core/rand_distr manifests",
  "rust_comparison": "parser tests and rand-bench-smoke pass",
  "runtime_runners": "node/cargo/rustc found; qemu/wine/wasmtime/wasmer not available",
  "opportunity_runners_available": false,
  "current_conclusion": "no known unblocked local Rust core RNG gap",
  "no_known_unblocked_gap": true,
  "remaining_blocker": "S4-M11 exact/default dense SIMD winner, new runtime, or new local Rust gap",
  "s4_m11_blocked": true,
  "details": "compare/results/s4-m420-current-rand-status.md"
}
$ zig build rand-status -- --schema-version
1
$ zig build rand-status -- --self-test
rand-status self-test ok
```

Focused roadmap validation for this evidence update:

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M455 is closed for the current bar: the documented direct `rand-status`
argument forms pass in a fresh lightweight run. This is tooling validation
evidence only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
