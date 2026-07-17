# S4-M450 `rand-status` Command Matrix Refresh

## Gap

After S4-M1240 aligned Rng.init raw-alias fallback, the
lightweight `rand-status` command matrix needed a fresh recorded run showing the
new current-bar conclusion while keeping the stable JSON schema shape.

## Validation

Observed command matrix:

```text
$ zig build rand-status
Alea local rand/rand_distr status (2026-07-18)
- Baseline: ~/Work/rand plus cached rand_distr 0.6.0
- Latest gate: zig build validate-local passes
- Public surface: surfacecheck ok for rand/rand_core/rand_distr manifests
- Rust comparison: parser tests and rand-bench-smoke pass
- Runtime runners: node/cargo/rustc found; Wasmtime 31.0.0 profilelongcheck evidence recorded
- Current conclusion: S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1240 follow-ups closed for current bar
- Local Rust gap: no known unblocked local Rust core RNG gap
- Next bar: S4-M1241 post-S4-M1240 exact/default dense SIMD, broader runtime, further semantics-preserving performance work, or new core random-workflow gap
- Details: compare/results/s4-m420-current-rand-status.md
$ zig build rand-status-json
{
  "schema_version": 1,
  "date": "2026-07-18",
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
  "current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1240 follow-ups closed for current bar",
  "no_known_unblocked_gap": true,
  "remaining_blocker": "S4-M1241 post-S4-M1240 next product bar",
  "s4_m11_blocked": false,
  "details": "compare/results/s4-m420-current-rand-status.md",
  "local_rand_status": "compare/results/s4-m420-current-rand-status.md",
  "blocker_audit": "compare/results/s4-m11-blocker-audit.md",
  "latest_validate_local_evidence": "compare/results/s4-m1240-rng-init-raw-alias-source.md"
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

S4-M450 is refreshed for the current bar: all `rand-status` command modes pass
and report that the S4-M11 runtime branch and S4-M1124/S4-M1127-S4-M1240 follow-ups
are closed for the current bar while S4-M1241 is the next post-S4-M1240 product bar. This is tooling validation evidence
only; it is not whole-goal completion evidence.
