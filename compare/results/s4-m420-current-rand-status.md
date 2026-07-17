# S4-M420 Current Local Rand Comparison Status

Date: 2026-07-18

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
- S4-M1215 refreshes the local `validate-local` aggregate after the exponential vectorbench probe;
- S4-M1216 refreshes the full `validate-all` aggregate after the local comparison update;
- S4-M1217 refreshes the minimum real-harness dense-SIMD vectorbench gate;
- S4-M1218 refreshes the local `validate-local` aggregate after the vectorbench gate;
- S4-M1219 refreshes the full `validate-all` aggregate after the local comparison update;
- S4-M1220 adds full-covariance multivariate normal sampling;
- S4-M1221 corrects and optimizes small-dimension multivariate-normal throughput and raises the next bar to S4-M1222;
- S4-M1222 adds static allocation-free multivariate normal sampling;
- S4-M1223 fixes ordinary f64 StandardUniform 53-bit grid consistency across facade, direct-source, bulk-fill, iterator/distribution-fill, and vector paths;
- S4-M1224 recovers ordinary f64 StandardUniform throughput while preserving the S4-M1223 53-bit grid;
- S4-M1225 further recovers ordinary f64 uniform throughput via low-bit bitcast and 8-lane bulk chunks;
- S4-M1226 refactors vectorized float slice-fill lane stores to reduce lane-width drift risk;
- S4-M1227 refactors distribution vector lane stores and staged slice transforms;
- S4-M1228 completes the remaining distribution transform lane-store sweep;
- S4-M1229 completes the distribution vector sampler lane-count sweep;
- S4-M1230 refactors the remaining core rng normal affine lane-store helper;
- S4-M1231 hardens rng byte-fill / reader refill correctness;
- S4-M1232 hardens owned byte allocation for fallible byte sources;
- S4-M1233 fixes `std.Random` adapter `nextU32` byte-stream shape;
- S4-M1234 hardens root alphanumeric string preallocation before entropy;
- S4-M1235 aligns fallible direct-source `tryNextU32From` with source-native `nextU32`;
- S4-M1236 aligns direct-source `nextU64From` / `tryNextU64From` with source-native `nextU64`;
- S4-M1237 aligns direct-source byte helpers with source-native `fillBytes` and `nextU64` fallback shapes;
- S4-M1238 aligns generic `nextFrom` direct-source workflows with source-native `nextU64`;
- S4-M1239 aligns seed and engine `fromRng` workflows with source-native `nextU64` / `tryNextU64`;
- S4-M1240 aligns `Rng.init` facade construction with raw-alias-only direct sources;
- no new unblocked local Rust public-surface or comparison-benchmark gap is known.

## Latest Evidence

S4-M1240 aligns `Rng.init` facade construction with raw-alias-only direct sources after S4-M1239
aligned seed/fork native-u64 fallback behavior. The retained status and validation evidence include:

```text
$ zig build validate-all
run_wasi_test self-test ok
roadmapcheck ok
examplecheck ok
distcheck ok
readmecheck ok
toolingcheck ok
statcheck ok
profilecheck ok
profiletailcheck ok
profilestresscheck ok
profilelongcheck ok

$ zig build rand-status-json
  "schema_version": 1,
  "current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1240 follow-ups closed for current bar",
  "remaining_blocker": "S4-M1241 post-S4-M1240 next product bar",
  "validate_local_passes": true,
  "opportunity_runners_available": false,
  "no_known_unblocked_gap": true,
  "s4_m11_blocked": false,
  "local_rand_status": "compare/results/s4-m420-current-rand-status.md",
  "blocker_audit": "compare/results/s4-m11-blocker-audit.md",
  "latest_validate_local_evidence": "compare/results/s4-m1240-rng-init-raw-alias-source.md"

Retained latest local Rust comparison evidence:
$ zig build validate-local
rand_bench_smoke self-test ok
rand_distr standard-normal: 40.4 M samples/s checksum=-3.640
rand_distr standard-normal f32: 37.1 M samples/s checksum=-3.640
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=72 source-tokens=185
surfacecheck ok
runtimecheck ok: no additional runtime runner available

Retained broader-runtime evidence:
wasmtime 31.0.0 (7a9be587f 2025-03-20)
profilelongcheck ok
```

`compare/results/s4-m1123-wasmtime-profilelongcheck.md` records the direct
Wasmtime profilelongcheck run. `compare/results/s4-m1240-rng-init-raw-alias-source.md` records the latest focused facade-constructor raw-alias hardening after S4-M1239.
S4-M11 is closed for the current bar; S4-M1220 through S4-M1240 are also closed for their current bars, but exact/default-compatible dense SIMD
normal/exponential kernels are still not known to beat scalar lane-fill in the
real vector-slice harness.

## Current Post-S4-M1240 Bar

The long-term product goal is not complete. The next bar is S4-M1241: pursue
exact/default-compatible dense SIMD normal/exponential kernels, additional
non-WASI OS/architecture execution, broader/longer validation, further
semantics-preserving performance work, or newly discovered local `rand` /
`rand_distr` gaps.

## Result

S4-M420 is a status snapshot only: current local Rust comparison evidence shows
no known unblocked core RNG gap versus locally available `rand` / `rand_distr`,
while the post-S4-M1240 S4-M1241 bar remains the active follow-up.
