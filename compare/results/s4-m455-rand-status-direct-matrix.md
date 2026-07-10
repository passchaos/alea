# S4-M455 Direct `rand-status` Command Matrix

## Gap

After S4-M1168 added weighted sampler format helpers, the documented direct argument forms for
`rand-status` needed a fresh recorded run matching the updated status JSON and
self-test output.

## Validation

Observed direct command matrix:

```text
$ zig build rand-status -- --json
{
  "schema_version": 1,
  "date": "2026-07-10",
  "baseline": {
    "rand": "~/Work/rand",
    "rand_distr": "cached rand_distr 0.6.0"
  },
  "latest_gate": "zig build validate-local passes",
  "validate_local_passes": true,
  "public_surface": "surfacecheck ok for rand/rand_core/rand_distr manifests",
  "rust_comparison": "parser tests and rand-bench-smoke pass",
  "runtime_runners": "node/cargo/rustc found; Wasmtime 31.0.0 profilelongcheck evidence recorded",
  "opportunity_runners_available": false,
  "current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1168 follow-ups closed for current bar",
  "no_known_unblocked_gap": true,
  "remaining_blocker": "S4-M1169 post-S4-M1168 next product bar",
  "s4_m11_blocked": false,
  "details": "compare/results/s4-m420-current-rand-status.md",
  "local_rand_status": "compare/results/s4-m420-current-rand-status.md",
  "blocker_audit": "compare/results/s4-m11-blocker-audit.md",
  "latest_validate_local_evidence": "compare/results/s4-m1168-weighted-sampler-format.md"
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

S4-M455 is refreshed for the current bar: the documented direct `rand-status`
argument forms pass and report that the S4-M11 runtime branch and
S4-M1124/S4-M1127-S4-M1168 follow-ups are closed for the current bar while
S4-M1169 is the next post-S4-M1168 product bar. This is tooling validation
evidence only; it is not whole-goal completion evidence.
