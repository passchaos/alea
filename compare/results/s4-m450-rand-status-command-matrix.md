# S4-M450 `rand-status` Command Matrix Refresh

## Gap

After S4-M431..S4-M449 expanded `rand-status` with JSON, schema-version,
self-test, help, and status evidence synchronization, the lightweight command
matrix needed a fresh recorded run.

## Validation

Observed command matrix:

```text
$ zig build rand-status
Alea local rand/rand_distr status (2026-07-06)
- Baseline: ~/Work/rand plus cached rand_distr 0.6.0
- Latest gate: zig build validate-local passes
- Public surface: surfacecheck ok for rand/rand_core/rand_distr manifests
- Rust comparison: parser tests and rand-bench-smoke pass
- Runtime runners: node/cargo/rustc found; qemu/wine/wasmtime/wasmer not available
- Current conclusion: no known unblocked local Rust core RNG gap
- Remaining blocker: S4-M11 exact/default dense SIMD winner, new runtime, or new local Rust gap
- Details: compare/results/s4-m420-current-rand-status.md
$ zig build rand-status-json
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
$ zig build rand-status-schema-version
1
$ zig build rand-status-self-test
rand-status self-test ok
$ zig build rand-status -- --help
usage: rand-status [--json]
       rand-status --schema-version
       rand-status --self-test
       rand-status --help
       --json prints the current local rand/rand_distr status as stable JSON
       --schema-version prints the stable JSON schema version
       --self-test validates text, JSON, help, and bad-argument paths without Rust tools
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

S4-M450 is closed for the current bar: all `rand-status` command modes pass in a
fresh lightweight run. This is tooling validation evidence only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
