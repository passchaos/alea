# S4-M11 Resolution Audit

Date: 2026-07-10

S4-M11 asked for one of three ways to keep raising the accepted vector profile
bar:

1. land an exact/default-compatible dense SIMD normal/exponential kernel that
   beats scalar ziggurat lane-fill in the real `vectorbench` harness;
2. execute accepted profile validation on another genuine architecture/runtime
   target beyond native glibc, x86_64-linux-musl, and Node WASI;
3. find and close a new local `rand` / `rand_distr` core gap.

## Current Evidence

| Check | Result |
| --- | --- |
| Exact/default-compatible dense SIMD kernel | No default/exact dense SIMD winner is claimed. Prior ziggurat repair, block-fallback, all-accepted, mask-redraw, lane-local, Marsaglia polar, ratio-of-uniforms, inverse-CDF, CLT, libmvec vector-log, and f64 approx-log attempts remain rejected in `simd-distribution-kernel-notes.md` and `performance-triage.md`. Default vector normal/exponential APIs still intentionally use scalar ziggurat lane-fill. |
| Additional architecture/runtime runner | Closed for the current bar by executing accepted profile validation under Wasmtime 31.0.0 (`wasmtime 31.0.0 (7a9be587f 2025-03-20)`) using the locally downloaded upstream `wasmtime-v31.0.0-x86_64-linux` release. `compare/results/s4-m1123-wasmtime-profilelongcheck.md` records direct Wasmtime execution of `alea-wasi-profilecheck.wasm` and `alea-wasi-profilelongcheck.wasm`; the long run ends with `profilelongcheck ok`. This is a genuine non-Node WASI runtime in addition to prior native glibc, x86_64-linux-musl, and Node WASI evidence. Other non-WASI runners (`qemu-aarch64`, `qemu-aarch64-static`, `qemu-riscv64`, `qemu-riscv64-static`, `qemu-x86_64`, `qemu-x86_64-static`, `wine`, `wine64`, and `wasmer`) are still not part of the current executed evidence. |
| Local `rand` / `rand_distr` public-surface and comparison-benchmark gap | No new unblocked local Rust public-surface or comparison-benchmark gap is identified by the current local scan and smoke coverage. `zig build surfacecheck` covers 25 local `rand` files, 6 resolved `rand_core` files, and 34 cached `rand_distr` files. `zig build validate-local` continues to aggregate native validation with local public-surface scan plus `rand-bench-test`, `rand-bench-smoke`, `rand-bench-smoke-self-test`, `rand-status`, `rand-status-json`, `rand-status-schema-version`, and `rand-status-self-test`. |
| Local `rand` SIMD/non-uniform surface | Re-auditing `~/Work/rand` still finds `simd_support` for uniform/integer/wide values and uniform float/range APIs only. Cached `rand_distr 0.6.0` still has scalar ZIGNOR `StandardNormal`/`Exp1` with f32 delegating through f64 and no SIMD non-uniform implementation. |

## Local Status Tokens

The current status and local-comparison signals retained for roadmap guards are:

```text
surfacecheck local rand
zig build validate-local
zig build rand-bench-test
zig build rand-bench-smoke
zig build rand-bench-smoke-self-test
zig build rand-status
zig build rand-status-json
zig build rand-status-self-test
zig build rand-status-schema-version
compare/results/s4-m1203-parameterized-vectorbench-refresh.md
compare/results/s4-m1202-f64x4-vectorbench-refresh.md
compare/results/s4-m1201-f32x8-vectorbench-refresh.md
compare/results/s4-m1200-post-s4-m1199-validate-all.md
compare/results/s4-m1199-ziggurat-table-surface-guard.md
compare/results/s4-m1198-post-s4-m1197-validate-all.md
compare/results/s4-m1197-poisson-max-lambda-constants.md
compare/results/s4-m1196-weighted-manifest-root-alias-refresh.md
compare/results/s4-m1195-root-weighted-sampler-aliases.md
compare/results/s4-m1194-weighted-namespace-aliases.md
compare/results/s4-m1193-post-s4-m1192-validate-local.md
compare/results/s4-m1192-rand-status-post-bar-drift.md
compare/results/s4-m1191-rand-status-post-bar-drift.md
compare/results/s4-m1190-post-s4-m1189-validate-all.md
compare/results/s4-m1189-dynamic-tree-typed-total.md
compare/results/s4-m1188-post-s4-m1187-validate-all.md
compare/results/s4-m1187-dynamic-tree-typed-diagnostics.md
compare/results/s4-m1186-post-s4-m1185-validate-local.md
compare/results/s4-m1185-dense-simd-probe-refresh.md
compare/results/s4-m1184-post-s4-m1183-validate-all.md
compare/results/s4-m1183-weighted-choice-typed-diagnostics.md
compare/results/s4-m1182-weighted-manifest-refresh.md
compare/results/s4-m1181-post-s4-m1180-validate-all.md
compare/results/s4-m1180-typed-static-weighted-diagnostics.md
compare/results/s4-m1179-post-s4-m1178-validate-local.md
compare/results/s4-m1178-weighted-manifest-refresh.md
compare/results/s4-m1177-post-s4-m1176-validate-all.md
compare/results/s4-m1176-root-weighted-error-aliases.md
compare/results/s4-m1175-post-s4-m1174-validate-all.md
compare/results/s4-m1174-weighted-error-message.md
compare/results/s4-m1173-post-s4-m1172-validate-all.md
compare/results/s4-m1172-weighted-iterator-clone-format.md
compare/results/s4-m1171-post-s4-m1170-validate-all.md
compare/results/s4-m1170-weighted-tree-try-sample.md
compare/results/s4-m1169-weighted-tree-default.md
compare/results/s4-m1168-weighted-sampler-format.md
compare/results/s4-m1167-weighted-sampler-clone-eql.md
compare/results/s4-m1166-post-s4-m1165-validate-all.md
compare/results/s4-m1165-weighted-int-tree-overflow.md
compare/results/s4-m1164-weighted-tree-zero-total.md
compare/results/s4-m1163-alias-table-max-weight.md
compare/results/s4-m1162-beta-dirichlet-tiny-shape.md
compare/results/s4-m1161-dirichlet-subnormal-alpha.md
compare/results/s4-m1160-hypergeometric-large-population.md
compare/results/s4-m1159-nig-alpha-infinity.md
`1`
Alea local rand/rand_distr status (2026-07-10)
"schema_version"
"baseline"
"validate_local_passes"
"opportunity_runners_available"
"current_conclusion"
"no_known_unblocked_gap"
"s4_m11_blocked"
"local_rand_status"
"blocker_audit"
"latest_validate_local_evidence"
"compare/results/s4-m1203-parameterized-vectorbench-refresh.md"
"compare/results/s4-m1202-f64x4-vectorbench-refresh.md"
"compare/results/s4-m1201-f32x8-vectorbench-refresh.md"
"compare/results/s4-m1200-post-s4-m1199-validate-all.md"
"compare/results/s4-m1199-ziggurat-table-surface-guard.md"
"compare/results/s4-m1198-post-s4-m1197-validate-all.md"
"compare/results/s4-m1197-poisson-max-lambda-constants.md"
"compare/results/s4-m1196-weighted-manifest-root-alias-refresh.md"
"compare/results/s4-m1195-root-weighted-sampler-aliases.md"
"compare/results/s4-m1194-weighted-namespace-aliases.md"
"compare/results/s4-m1193-post-s4-m1192-validate-local.md"
"compare/results/s4-m1192-rand-status-post-bar-drift.md"
"compare/results/s4-m1191-rand-status-post-bar-drift.md"
"compare/results/s4-m1190-post-s4-m1189-validate-all.md"
"compare/results/s4-m1189-dynamic-tree-typed-total.md"
"compare/results/s4-m1188-post-s4-m1187-validate-all.md"
"compare/results/s4-m1187-dynamic-tree-typed-diagnostics.md"
"compare/results/s4-m1186-post-s4-m1185-validate-local.md"
"compare/results/s4-m1185-dense-simd-probe-refresh.md"
"compare/results/s4-m1184-post-s4-m1183-validate-all.md"
"compare/results/s4-m1183-weighted-choice-typed-diagnostics.md"
"compare/results/s4-m1182-weighted-manifest-refresh.md"
"compare/results/s4-m1181-post-s4-m1180-validate-all.md"
"compare/results/s4-m1180-typed-static-weighted-diagnostics.md"
"compare/results/s4-m1179-post-s4-m1178-validate-local.md"
"compare/results/s4-m1178-weighted-manifest-refresh.md"
"compare/results/s4-m1177-post-s4-m1176-validate-all.md"
"compare/results/s4-m1176-root-weighted-error-aliases.md"
"compare/results/s4-m1175-post-s4-m1174-validate-all.md"
"compare/results/s4-m1174-weighted-error-message.md"
"compare/results/s4-m1173-post-s4-m1172-validate-all.md"
"compare/results/s4-m1172-weighted-iterator-clone-format.md"
"compare/results/s4-m1171-post-s4-m1170-validate-all.md"
"compare/results/s4-m1170-weighted-tree-try-sample.md"
"compare/results/s4-m1169-weighted-tree-default.md"
"compare/results/s4-m1168-weighted-sampler-format.md"
"compare/results/s4-m1167-weighted-sampler-clone-eql.md"
"compare/results/s4-m1166-post-s4-m1165-validate-all.md"
"compare/results/s4-m1165-weighted-int-tree-overflow.md"
"compare/results/s4-m1164-weighted-tree-zero-total.md"
"compare/results/s4-m1163-alias-table-max-weight.md"
rand-status self-test ok
rand_distr standard-normal
five passing Rust parser tests
rand_bench_smoke self-test ok
ALEA_RAND_BENCH_MANIFEST
ALEA_RAND_BENCH_EXPECTED_ROW
zig build runtimecheck
No new unblocked public-surface or local comparison-benchmark gap
```

## Decision

S4-M11 is closed for the current bar via the additional-runtime branch. The
accepted vector approximation profiles now have long-sweep evidence across
native glibc, x86_64-linux-musl, Node WASI, and direct Wasmtime execution.

This does not replace exact/default vector normal/exponential APIs: those remain
scalar ziggurat lane-fill until an exact/default-compatible dense SIMD kernel
wins in the real vector-slice harness. It also does not complete the long-term
product objective. The roadmap is raised to S4-M1124 for the next stricter bar:
continue exact/default dense-kernel research, seek additional non-WASI OS or
architecture execution, and keep local `rand` / `rand_distr` audits current.

Do not call `update_goal(status=complete)` from this audit: S4-M11 is resolved
for the current milestone only, while the product goal deliberately keeps
raising the bar.
S4-M1125 post-S4-M11 next product bar remains active after S4-M1124 restores validate-all.
S4-M1126 post-S4-M1125 next product bar remains active after S4-M1125 refreshes rand-status.
S4-M1126 remains active after `compare/results/s4-m1126-f32x8-dense-simd-probe.md` found no checksum-preserving f32x8 dense SIMD winner.
S4-M1128 remains active after S4-M1127 closes `compare/results/s4-m1127-f64x4-standard-normal-direct-fill.md` for direct-source f64x4 standard-normal fills.
S4-M1129 remains active after S4-M1128 closes `compare/results/s4-m1128-f64x4-standard-exponential-direct-fill.md` for direct-source f64x4 standard-exponential fills.
S4-M1130 remains active after S4-M1129 refreshes rand-status in `compare/results/s4-m1129-post-s4-m1128-rand-status-refresh.md`.
S4-M1131 remains active after S4-M1130 refreshes validate-all in `compare/results/s4-m1130-post-s4-m1129-validate-all.md`.
S4-M1132 remains active after S4-M1131 refreshes rand-status in `compare/results/s4-m1131-post-s4-m1130-rand-status-refresh.md`.
S4-M1133 remains active after S4-M1132 refreshes f32x8 direct-source evidence in `compare/results/s4-m1132-f32x8-direct-source-probe.md`.
S4-M1134 remains active after S4-M1133 closes rate-one vector exponential delegation in `compare/results/s4-m1133-vector-exponential-rate-one-delegate.md`.
S4-M1135 remains active after S4-M1134 closes single-vector rate-one exponential delegation in `compare/results/s4-m1134-single-vector-exponential-rate-one-delegate.md`.
S4-M1136 remains active after S4-M1135 closes scalar rate-one exponential fill delegation in `compare/results/s4-m1135-scalar-exponential-rate-one-fill.md`.
S4-M1137 remains active after S4-M1136 closes scalar rate-one exponential sample delegation in `compare/results/s4-m1136-scalar-exponential-rate-one-sample.md`.
S4-M1138 remains active after S4-M1137 closes scalar standard-normal sample delegation in `compare/results/s4-m1137-scalar-normal-standard-sample.md`.
S4-M1139 remains active after S4-M1138 refreshes rand-status in `compare/results/s4-m1138-post-s4-m1137-rand-status-refresh.md`.
S4-M1140 remains active after S4-M1139 fixes roadmapcheck evidence mapping in `compare/results/s4-m1139-roadmapcheck-evidence-map-fix.md`.
S4-M1141 remains active after S4-M1140 refreshes rand-status in `compare/results/s4-m1140-post-s4-m1139-rand-status-refresh.md`.
S4-M1142 remains active after S4-M1141 extends f64x4 facade standard-vector fills in `compare/results/s4-m1141-f64x4-facade-standard-vector-fill.md`.
S4-M1143 remains active after S4-M1142 specializes parameterized f64x4 vector fills in `compare/results/s4-m1142-parameterized-f64x4-vector-fill.md`.

S4-M1144 remains active after S4-M1143 aligns zero-rate exponential semantics in `compare/results/s4-m1143-zero-rate-exponential.md`.

S4-M1145 remains active after S4-M1144 aligns negative normal stddev semantics in `compare/results/s4-m1144-negative-normal-stddev.md`.
S4-M1146 remains active after S4-M1145 aligns unrestricted normal/log-normal log-space mean semantics in `compare/results/s4-m1145-nonfinite-normal-mean.md`.

S4-M1147 remains active after S4-M1146 aligns exact reusable mean/CV edge semantics in `compare/results/s4-m1146-mean-cv-edge.md`.

S4-M1148 remains active after S4-M1147 aligns Gamma-family infinity semantics in `compare/results/s4-m1147-gamma-infinity.md`.

S4-M1149 remains active after S4-M1148 aligns FisherF infinity semantics in `compare/results/s4-m1148-fisher-f-infinity.md`.

S4-M1150 remains active after S4-M1149 aligns StudentT infinity semantics in `compare/results/s4-m1149-student-t-infinity.md`.

S4-M1151 remains active after S4-M1150 aligns Cauchy non-finite parameter semantics in `compare/results/s4-m1150-cauchy-nonfinite.md`.

S4-M1152 remains active after S4-M1151 aligns Pareto/Weibull infinite-scale semantics in `compare/results/s4-m1151-pareto-weibull-infinite-scale.md`.

S4-M1153 remains active after S4-M1152 aligns Beta infinity semantics in `compare/results/s4-m1152-beta-infinity.md`.

S4-M1154 remains active after S4-M1153 aligns Triangular non-finite bound semantics in `compare/results/s4-m1153-triangular-nonfinite.md`.

S4-M1155 remains active after S4-M1154 aligns PERT infinite-shape semantics in `compare/results/s4-m1154-pert-infinite-shape.md`.

S4-M1156 remains active after S4-M1155 aligns Poisson max-lambda semantics in `compare/results/s4-m1155-poisson-max-lambda.md`.

S4-M1157 remains active after S4-M1156 aligns Geometric zero-probability semantics in `compare/results/s4-m1156-geometric-zero-probability.md`.

S4-M1158 remains active after S4-M1157 aligns InverseGaussian infinity semantics in `compare/results/s4-m1157-inverse-gaussian-infinity.md`.

S4-M1159 remains active after S4-M1158 aligns SkewNormal unrestricted-location semantics in `compare/results/s4-m1158-skew-normal-location.md`.

S4-M1160 is closed after aligning Hypergeometric large-population semantics in `compare/results/s4-m1160-hypergeometric-large-population.md`.

S4-M1161 is closed after aligning Dirichlet subnormal-alpha semantics in `compare/results/s4-m1161-dirichlet-subnormal-alpha.md`.

S4-M1162 is closed after aligning Beta/Dirichlet tiny-shape semantics in `compare/results/s4-m1162-beta-dirichlet-tiny-shape.md`.

S4-M1163 is closed after aligning AliasTable per-weight maximum semantics in `compare/results/s4-m1163-alias-table-max-weight.md`.

S4-M1164 is closed after aligning WeightedTree zero-total checked sampling semantics in `compare/results/s4-m1164-weighted-tree-zero-total.md`.

S4-M1165 is closed after aligning WeightedIntTree integer overflow semantics in `compare/results/s4-m1165-weighted-int-tree-overflow.md`.

S4-M1166 is closed after refreshing validate-all evidence in `compare/results/s4-m1166-post-s4-m1165-validate-all.md`.

S4-M1167 is closed after adding weighted sampler clone/equality helpers in `compare/results/s4-m1167-weighted-sampler-clone-eql.md`.

S4-M1168 is closed after adding weighted sampler format helpers in `compare/results/s4-m1168-weighted-sampler-format.md`.

S4-M1169 is closed after adding weighted-tree constructor/default helpers in `compare/results/s4-m1169-weighted-tree-default.md`.

S4-M1170 is closed after adding weighted-tree trySample aliases in `compare/results/s4-m1170-weighted-tree-try-sample.md`.

S4-M1171 is closed after refreshing validate-all evidence in `compare/results/s4-m1171-post-s4-m1170-validate-all.md`.

S4-M1172 is closed after adding weighted iterator clone/format helpers in `compare/results/s4-m1172-weighted-iterator-clone-format.md`.

S4-M1173 is closed after refreshing validate-all evidence in `compare/results/s4-m1173-post-s4-m1172-validate-all.md`.

S4-M1174 is closed after adding weighted error message helpers in `compare/results/s4-m1174-weighted-error-message.md`.

S4-M1175 is closed after refreshing validate-all evidence in `compare/results/s4-m1175-post-s4-m1174-validate-all.md`.

S4-M1176 is closed after adding root/prelude weighted error aliases in `compare/results/s4-m1176-root-weighted-error-aliases.md`.

S4-M1177 is closed after refreshing validate-all evidence in `compare/results/s4-m1177-post-s4-m1176-validate-all.md`.

S4-M1178 is closed after refreshing weighted manifest coverage in `compare/results/s4-m1178-weighted-manifest-refresh.md`.

S4-M1179 is closed after refreshing validate-local evidence in `compare/results/s4-m1179-post-s4-m1178-validate-local.md`.

S4-M1180 is closed after adding typed static weighted diagnostics in `compare/results/s4-m1180-typed-static-weighted-diagnostics.md`.

S4-M1181 is closed after refreshing validate-all evidence in `compare/results/s4-m1181-post-s4-m1180-validate-all.md`.

S4-M1182 is closed after refreshing weighted manifests in `compare/results/s4-m1182-weighted-manifest-refresh.md`.

S4-M1183 is closed after adding WeightedChoice typed diagnostics in `compare/results/s4-m1183-weighted-choice-typed-diagnostics.md`.

S4-M1184 is closed after refreshing validate-all evidence in `compare/results/s4-m1184-post-s4-m1183-validate-all.md`.

S4-M1185 is closed after refreshing dense SIMD vectorbench evidence in `compare/results/s4-m1185-dense-simd-probe-refresh.md`.

S4-M1186 is closed after refreshing validate-local evidence in `compare/results/s4-m1186-post-s4-m1185-validate-local.md`.

S4-M1187 is closed after adding dynamic weighted-tree typed diagnostics in `compare/results/s4-m1187-dynamic-tree-typed-diagnostics.md`.

S4-M1188 is closed after refreshing full validate-all evidence in `compare/results/s4-m1188-post-s4-m1187-validate-all.md`.

S4-M1189 is closed after adding dynamic weighted-tree typed total diagnostics in `compare/results/s4-m1189-dynamic-tree-typed-total.md`.

S4-M1190 is closed after refreshing full validate-all evidence in `compare/results/s4-m1190-post-s4-m1189-validate-all.md`.

S4-M1191 is closed after repairing rand-status post-bar drift in `compare/results/s4-m1191-rand-status-post-bar-drift.md`.

S4-M1192 is closed after repairing follow-up rand-status post-bar drift in `compare/results/s4-m1192-rand-status-post-bar-drift.md`.

S4-M1193 is closed after refreshing validate-local evidence in `compare/results/s4-m1193-post-s4-m1192-validate-local.md`.

S4-M1194 is closed after adding weighted namespace aliases in `compare/results/s4-m1194-weighted-namespace-aliases.md`.

S4-M1195 is closed after adding root/prelude weighted sampler aliases in `compare/results/s4-m1195-root-weighted-sampler-aliases.md`.

S4-M1196 is closed after refreshing weighted manifest root-alias evidence in `compare/results/s4-m1196-weighted-manifest-root-alias-refresh.md`.

S4-M1197 is closed after exposing Poisson max-lambda public constants in `compare/results/s4-m1197-poisson-max-lambda-constants.md`.

S4-M1198 is closed after refreshing validate-all evidence in `compare/results/s4-m1198-post-s4-m1197-validate-all.md`.

S4-M1199 is closed after expanding ziggurat-table surface guards in `compare/results/s4-m1199-ziggurat-table-surface-guard.md`.

S4-M1200 is closed after refreshing validate-all evidence in `compare/results/s4-m1200-post-s4-m1199-validate-all.md`.

S4-M1201 is closed after refreshing f32x8 vectorbench evidence in `compare/results/s4-m1201-f32x8-vectorbench-refresh.md`.

S4-M1202 is closed after refreshing f64x4 vectorbench evidence in `compare/results/s4-m1203-parameterized-vectorbench-refresh.md`.

S4-M1203 is closed after refreshing parameterized vectorbench evidence in `compare/results/s4-m1203-parameterized-vectorbench-refresh.md`.

S4-M1204 remains active after S4-M1203 refreshes parameterized vectorbench evidence.
