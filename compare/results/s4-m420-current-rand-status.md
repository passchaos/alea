# S4-M420 Current Local Rand Comparison Status

Date: 2026-07-10

## Summary

Against the locally available Rust evidence on this Linux host:

- local `~/Work/rand` is the `rand` baseline;
- cached `rand_distr 0.6.0` is the distribution baseline;
- `zig build validate-local` currently passes;
- `zig build surfacecheck` currently passes for local `rand`, resolved
  `rand_core`, and cached `rand_distr` manifests;
- the local Rust comparison benchmark parser tests and tiny filtered smoke run
  currently pass;
- Wasmtime 31.0.0 has executed the accepted profile long sweep directly,
  closing S4-M11's additional-runtime branch for the current bar;
- S4-M1124 restored the post-S4-M11 `validate-all` aggregate;
- S4-M1127/S4-M1128 closed direct-source f64x4 standard normal/exponential fill specializations;
- S4-M1130 refreshed full `validate-all` evidence after those changes;
- S4-M1133-S4-M1137 closed standard-parameter/rate-one normal/exponential delegation fixes;
- S4-M1141-S4-M1165 closed the current local `rand_distr` distribution edge-case and weighted-tree compatibility follow-ups;
- S4-M1166-S4-M1198 added weighted diagnostics/aliases, Poisson max-lambda public constants, and intervening validation refreshes;
- S4-M1199 expands the local `rand_distr` ziggurat table public-surface guard to public `const` / `static` table names;
- S4-M1200 refreshes the full `validate-all` aggregate after that verifier change;
- S4-M1201 refreshes f32x8 standard normal/exponential vectorbench evidence;
- S4-M1202 refreshes f64x4 standard normal/exponential vectorbench evidence;
- S4-M1203 refreshes parameterized f32x8/f64x4 normal/exponential vectorbench evidence;
- S4-M1204 repairs vectorbench status drift;
- S4-M1205 refreshes the local `validate-local` aggregate after the vectorbench status drift repair;
- S4-M1206 adds a generic roadmap evidence-path guard after the latest status drift repair;
- S4-M1207 refreshes the full `validate-all` aggregate after the roadmap evidence-path guard;
- S4-M1208 refreshes the local `validate-local` aggregate after the full validation refresh;
- S4-M1209 refreshes the full `validate-all` aggregate after the local comparison update;
- S4-M1210 refreshes inverse-CDF tail vectorbench evidence after the full validation refresh;
- S4-M1211 refreshes the local `validate-local` aggregate after the dense-SIMD evidence refresh;
- S4-M1212 refreshes the full `validate-all` aggregate after the local comparison update;
- S4-M1213 refreshes the full `validate-all` aggregate after the S4-M1212 status update;
- S4-M1214 refreshes focused exponential vectorbench evidence;
- no new unblocked local Rust public-surface or comparison-benchmark gap is known.

## Latest Evidence

S4-M1214 refreshed focused dense-SIMD exponential research evidence after S4-M1213.
The retained status and local comparison evidence include:

```text
Retained vectorbench:
$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "StandardExponential f32x8 direct"
alea fillVectorStandardExponential f32x8 direct: 326.3 M lanes/s checksum=4197710.000

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "StandardExponential f64x4 direct"
alea fillVectorStandardExponential f64x4 direct: 300.4 M lanes/s checksum=2097619.725

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "fillVectorExponential f32x8 direct"
alea fillVectorExponential f32x8 direct: 315.7 M lanes/s checksum=2098855.000

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "fillVectorExponential f64x4 direct"
alea fillVectorExponential f64x4 direct: 308.5 M lanes/s checksum=1048809.863

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "approx-log candidate"
alea fillVectorStandardExponential f32x8 approx-log candidate: 552.4 M lanes/s checksum=4191017.500
alea fillVectorStandardExponential f64x4 approx-log candidate: 327.3 M lanes/s checksum=2095769.481
alea fillVectorExponential f32x8 approx-log candidate: 556.7 M lanes/s checksum=2095508.800
alea fillVectorExponential f64x4 approx-log candidate: 327.3 M lanes/s checksum=1047884.740

$ zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 4194304 "table-cdf candidate"
alea fillVectorStandardExponential f32x8 table-cdf candidate: 903.5 M lanes/s checksum=4192680.000
alea fillVectorStandardExponential f64x4 table-cdf candidate: 920.7 M lanes/s checksum=2095542.322
alea fillVectorExponential f32x8 table-cdf candidate: 923.7 M lanes/s checksum=2096340.000
alea fillVectorExponential f64x4 table-cdf candidate: 913.7 M lanes/s checksum=1047771.161

$ zig build rand-status-json
  "schema_version": 1,
  "current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1214 follow-ups closed for current bar",
  "remaining_blocker": "S4-M1215 post-S4-M1214 next product bar",
  "validate_local_passes": true,
  "opportunity_runners_available": false,
  "no_known_unblocked_gap": true,
  "s4_m11_blocked": false,
  "local_rand_status": "compare/results/s4-m420-current-rand-status.md",
  "blocker_audit": "compare/results/s4-m11-blocker-audit.md",
  "latest_validate_local_evidence": "compare/results/s4-m1214-exponential-vectorbench-probe.md"

Retained latest local Rust comparison evidence:
$ zig build validate-local
rand_distr standard-normal: 40.8 M samples/s checksum=-3.640
rand_distr standard-normal f32: 38.1 M samples/s checksum=-3.640
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=72 source-tokens=185
surfacecheck ok
rand_bench_smoke self-test ok
runtimecheck ok: no additional runtime runner available

Retained broader-runtime evidence:
wasmtime 31.0.0 (7a9be587f 2025-03-20)
profilelongcheck ok
```

`compare/results/s4-m1123-wasmtime-profilelongcheck.md` records the direct
Wasmtime profilelongcheck run. `compare/results/s4-m1214-exponential-vectorbench-probe.md`
records the latest dense-SIMD research refresh. S4-M11 is closed for the current bar,
but exact/default-compatible dense SIMD normal/exponential kernels are still not
known to beat scalar lane-fill in the real vector-slice harness.

## Current Post-S4-M1214 Bar

The long-term product goal is not complete. The next bar is S4-M1215: pursue
exact/default-compatible dense SIMD normal/exponential kernels, additional
non-WASI OS/architecture execution, broader/longer validation, or newly
discovered local `rand` / `rand_distr` gaps.

## Result

S4-M420 is a status snapshot only: current local Rust comparison evidence shows
no known unblocked core RNG gap versus locally available `rand` / `rand_distr`,
while the post-S4-M1214 S4-M1215 bar remains the active follow-up.
