# S4-M1125 Post-S4-M1124 Rand Status Refresh

## Gap

S4-M1124 restored `zig build validate-all` after S4-M11 by making oversized-u32
prevalidation tests portable on 32-bit `usize` targets. The lightweight local
`rand` / `rand_distr` status command and checked-in command matrices still
identified S4-M1124 as the next active bar, which made the current status stale
for scripts and readers.

## Implementation

- Updated `tools/rand_status.zig` text and JSON output so the current conclusion
  says both the S4-M11 Wasmtime runtime branch and the S4-M1124 validate-all
  restoration are closed for the current bar.
- Updated the machine-readable `remaining_blocker` to
  `S4-M1126 post-S4-M1125 next product bar`.
- Refreshed the status snapshots in:
  - `compare/results/s4-m420-current-rand-status.md`
  - `compare/results/s4-m450-rand-status-command-matrix.md`
  - `compare/results/s4-m455-rand-status-direct-matrix.md`
- Advanced the roadmap/audit next-bar language so S4-M1125 is closed as a status
  synchronization milestone and S4-M1126 is the active product bar.

## Validation

Focused status command matrix after the refresh:

```text
$ zig build rand-status
Alea local rand/rand_distr status (2026-07-09)
- Baseline: ~/Work/rand plus cached rand_distr 0.6.0
- Latest gate: zig build validate-local passes
- Public surface: surfacecheck ok for rand/rand_core/rand_distr manifests
- Rust comparison: parser tests and rand-bench-smoke pass
- Runtime runners: node/cargo/rustc found; Wasmtime 31.0.0 profilelongcheck evidence recorded
- Current conclusion: S4-M11 runtime branch closed and S4-M1124 validate-all restoration closed for current bar
- Local Rust gap: no known unblocked local Rust core RNG gap
- Next bar: S4-M1126 post-S4-M1125 exact/default dense SIMD, broader runtime, or new local Rust gap
- Details: compare/results/s4-m420-current-rand-status.md

$ zig build rand-status-json
{
  "schema_version": 1,
  "date": "2026-07-09",
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
  "current_conclusion": "S4-M11 runtime branch closed and S4-M1124 validate-all restoration closed for current bar",
  "no_known_unblocked_gap": true,
  "remaining_blocker": "S4-M1126 post-S4-M1125 next product bar",
  "s4_m11_blocked": false,
  "details": "compare/results/s4-m420-current-rand-status.md",
  "local_rand_status": "compare/results/s4-m420-current-rand-status.md",
  "blocker_audit": "compare/results/s4-m11-blocker-audit.md",
  "latest_validate_local_evidence": "compare/results/s4-m1125-post-s4-m1124-rand-status-refresh.md"
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

$ zig build rand-status -- --json
# same JSON payload as rand-status-json

$ zig build rand-status -- --schema-version
1

$ zig build rand-status -- --self-test
rand-status self-test ok
```



Full local aggregate after updating the latest-evidence pointer:

```text
$ zig build validate-local
...
roadmapcheck ok
toolingcheck ok
{
  "schema_version": 1,
  "current_conclusion": "S4-M11 runtime branch closed and S4-M1124 validate-all restoration closed for current bar",
  "remaining_blocker": "S4-M1126 post-S4-M1125 next product bar",
  "validate_local_passes": true,
  "opportunity_runners_available": false,
  "no_known_unblocked_gap": true,
  "s4_m11_blocked": false,
  "latest_validate_local_evidence": "compare/results/s4-m1125-post-s4-m1124-rand-status-refresh.md"
}
rand-status self-test ok
surfacecheck ok
runtimecheck ok: no additional runtime runner available
rand_bench_smoke self-test ok
rand_distr standard-normal: 42.3 M samples/s checksum=-3.640
rand_distr standard-normal f32: 39.1 M samples/s checksum=-3.640
# command exited 0
```

## Result

S4-M1125 is closed for the current bar: status tooling and checked-in evidence no
longer point at S4-M1124 as active after it closed. This is not whole-goal
completion; the next active product bar is S4-M1126.
