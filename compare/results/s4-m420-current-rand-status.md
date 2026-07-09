# S4-M420 Current Local Rand Comparison Status

Date: 2026-07-09

## Summary

Against the locally available Rust evidence on this Linux host:

- local `~/Work/rand` is the `rand` baseline;
- cached `rand_distr 0.6.0` is the distribution baseline;
- `zig build validate-local` currently passes;
- `zig build surfacecheck` currently passes for local `rand`, resolved
  `rand_core`, and cached `rand_distr` manifests;
- the local Rust comparison benchmark parser tests and tiny filtered smoke run
  currently pass;
- Wasmtime 31.0.0 has now executed the accepted profile long sweep directly,
  closing S4-M11's additional-runtime branch for the current bar;
- S4-M1124 restored the post-S4-M11 `validate-all` aggregate;
- S4-M1127/S4-M1128 closed direct-source f64x4 standard normal/exponential fill specializations;
- S4-M1130 refreshed full `validate-all` evidence after those changes;
- S4-M1133-S4-M1137 closed standard-parameter/rate-one normal/exponential delegation fixes;
- no new unblocked local Rust public-surface or comparison-benchmark gap is known.

## Latest Evidence

S4-M1140 refreshed status output after updating `latest_validate_local_evidence` in
`rand-status-json` to the post-S4-M1139 status evidence. The passing run included:

```text
rand_distr standard-normal: 42.2 M samples/s checksum=-3.640
rand_distr standard-normal f32: 38.8 M samples/s checksum=-3.640
1
Alea local rand/rand_distr status (2026-07-09)
  "schema_version": 1,
  "current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1139 follow-ups closed for current bar",
  "remaining_blocker": "S4-M1141 post-S4-M1140 next product bar",
  "validate_local_passes": true,
  "opportunity_runners_available": false,
  "no_known_unblocked_gap": true,
  "s4_m11_blocked": false,
  "local_rand_status": "compare/results/s4-m420-current-rand-status.md",
  "blocker_audit": "compare/results/s4-m11-blocker-audit.md",
  "latest_validate_local_evidence": "compare/results/s4-m1140-post-s4-m1139-rand-status-refresh.md",
rand-status self-test ok
test result: ok. 5 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand_bench_smoke self-test ok
wasmtime 31.0.0 (7a9be587f 2025-03-20)
profilelongcheck ok
```

S4-M419 synchronized validate-local signals into `compare/results/s4-m11-blocker-audit.md`; S4-M428 confirmed `rand-status` output is part of the local aggregate; S4-M433 confirmed stable JSON status output is part of the local aggregate; S4-M437 additionally confirms the `rand-status` self-test is part of the local aggregate; S4-M442 keeps the JSON boolean status fields visible in this snapshot; S4-M444 keeps the JSON schema version visible here; S4-M448 confirms the schema-version build step is part of the local aggregate; S4-M459 keeps the latest validate-local evidence pointer visible here; S4-M462 keeps the blocker-audit pointer visible here; S4-M463 confirms that pointer is present in the latest validate-local aggregate output; S4-M466 also keeps the explicit local-status pointer visible here; S4-M469 refreshed the latest validate-local evidence pointer to the then-current artifact, S4-M1125 refreshed it after S4-M1124 restored validate-all, and S4-M1129 refreshed it after S4-M1127/S4-M1128 direct-source f64x4 fill improvements, and S4-M1131 refreshed it after the S4-M1130 validate-all evidence refresh, S4-M1138 refreshed it after S4-M1133-S4-M1137 delegation fixes, and S4-M1140 refreshes it again after the S4-M1139 evidence-map fix.

## Current Post-S4-M1140 Bar

The long-term product goal is not complete. S4-M11 is closed for the current bar
by direct Wasmtime profilelongcheck evidence in
`compare/results/s4-m1123-wasmtime-profilelongcheck.md`, S4-M1124 restored the
post-S4-M11 `validate-all` aggregate, S4-M1127/S4-M1128 closed direct-source
f64x4 standard normal/exponential fill specializations, S4-M1130 refreshed full
validate-all evidence, S4-M1133-S4-M1137 closed delegation fixes, S4-M1139 fixed
roadmapcheck evidence mapping, and S4-M1140 refreshed this status after that fix.
The next bar is S4-M1141: pursue exact/default-compatible
dense SIMD normal/exponential kernels, additional non-WASI OS/architecture
execution, broader/longer validation, or newly discovered local `rand` /
`rand_distr` gaps.

## Result

S4-M420 is a status snapshot only: current local Rust comparison evidence shows
no known unblocked core RNG gap versus locally available `rand` / `rand_distr`,
while the post-S4-M1140 S4-M1141 bar continues to block whole-goal completion.
