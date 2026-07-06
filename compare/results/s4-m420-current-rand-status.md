# S4-M420 Current Local Rand Comparison Status

Date: 2026-07-06

## Summary

Against the locally available Rust evidence on this Linux host:

- local `~/Work/rand` is the `rand` baseline;
- cached `rand_distr 0.6.0` is the distribution baseline;
- `zig build validate-local` currently passes;
- `zig build surfacecheck` currently passes for local `rand`, resolved
  `rand_core`, and cached `rand_distr` manifests;
- the local Rust comparison benchmark parser tests and tiny filtered smoke run
  currently pass;
- `zig build runtimecheck` currently finds required `node`, `cargo`, and `rustc`
  but no opportunity runners (`qemu-*`, Wine, wasmtime, wasmer);
- no new unblocked local Rust public-surface or comparison-benchmark gap is known.

## Latest Evidence

S4-M469 refreshed `zig build validate-local` after updating `latest_validate_local_evidence` in
`rand-status-json`. The passing run included:

```text
rand_distr standard-normal: 40.4 M samples/s checksum=-3.640
rand_distr standard-normal f32: 38.4 M samples/s checksum=-3.640
1
Alea local rand/rand_distr status (2026-07-06)
  "schema_version": 1,
  "validate_local_passes": true,
  "opportunity_runners_available": false,
  "no_known_unblocked_gap": true,
  "s4_m11_blocked": true,
  "local_rand_status": "compare/results/s4-m420-current-rand-status.md",
  "blocker_audit": "compare/results/s4-m11-blocker-audit.md",
  "latest_validate_local_evidence": "compare/results/s4-m469-latest-validate-local-evidence-pointer.md",
rand-status self-test ok
test result: ok. 5 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand_bench_smoke self-test ok
runtimecheck summary: required found=3 missing=0; opportunities found=0 missing=10
runtimecheck ok: no additional runtime runner available
```

S4-M419 synchronized validate-local signals into `compare/results/s4-m11-blocker-audit.md`; S4-M428 confirmed `rand-status` output is part of the local aggregate; S4-M433 confirmed stable JSON status output is part of the local aggregate; S4-M437 additionally confirms the `rand-status` self-test is part of the local aggregate; S4-M442 keeps the JSON boolean status fields visible in this snapshot; S4-M444 keeps the JSON schema version visible here; S4-M448 confirms the schema-version build step is part of the local aggregate; S4-M459 keeps the latest validate-local evidence pointer visible here; S4-M462 keeps the blocker-audit pointer visible here; S4-M463 confirms that pointer is present in the latest validate-local aggregate output; S4-M466 also keeps the explicit local-status pointer visible here; S4-M469 refreshes the latest validate-local evidence pointer to the current artifact.

## Current Blocker

The long-term product goal is not complete. S4-M11 remains blocked on one of:

1. an exact/default-compatible dense SIMD normal/exponential kernel that beats
   scalar ziggurat lane-fill in the real harness;
2. a newly available genuine architecture/runtime runner beyond current native
   glibc, x86_64-linux-musl, and Node WASI coverage;
3. a newly found local `rand` / `rand_distr` core gap.

## Result

S4-M420 is a status snapshot only: current local Rust comparison evidence shows
no known unblocked core RNG gap versus locally available `rand` / `rand_distr`,
while S4-M11 continues to block whole-goal completion.
