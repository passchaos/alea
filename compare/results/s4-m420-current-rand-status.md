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
- Wasmtime 31.0.0 has now executed the accepted profile long sweep directly,
  closing S4-M11's additional-runtime branch for the current bar;
- S4-M1124 restored the post-S4-M11 `validate-all` aggregate;
- S4-M1127/S4-M1128 closed direct-source f64x4 standard normal/exponential fill specializations;
- S4-M1130 refreshed full `validate-all` evidence after those changes;
- S4-M1133-S4-M1137 closed standard-parameter/rate-one normal/exponential delegation fixes;
- S4-M1141 extends the f64x4 standard vector fill specializations to facade
  standard-parameter workflows;
- S4-M1142 extends the same exact/default f64x4 draw shape to parameterized
  normal and finite-rate exponential vector fills;
- S4-M1143 aligns zero-rate exponential behavior with local `rand_distr::Exp`;
- S4-M1144 aligns negative normal/log-normal standard-deviation behavior with
  local `rand_distr::Normal` and `LogNormal`;
- S4-M1145 aligns unrestricted normal/log-normal log-space mean behavior with
  local `rand_distr::Normal` and `LogNormal`;
- S4-M1146 aligns Normal/LogNormal mean-CV edge behavior with local
  `rand_distr::from_mean_cv`;
- S4-M1147 aligns Gamma/ChiSquared/Chi infinite-parameter behavior with local
  `rand_distr::Gamma` and `ChiSquared`;
- S4-M1148 aligns FisherF infinite-degree behavior with local
  `rand_distr::FisherF`;
- S4-M1149 aligns StudentT infinite-degree behavior with local
  `rand_distr::StudentT`;
- S4-M1150 aligns Cauchy non-finite parameter acceptance with local
  `rand_distr::Cauchy`;
- S4-M1151 aligns Pareto/Weibull infinite-scale acceptance with local
  `rand_distr`;
- S4-M1152 aligns Beta infinite-shape behavior with local `rand_distr::Beta`;
- S4-M1153 aligns Triangular non-finite bound behavior with local
  `rand_distr::Triangular`;
- S4-M1154 aligns PERT infinite-shape behavior with local `rand_distr::Pert`;
- S4-M1155 aligns Poisson max-lambda validation with local `rand_distr::Poisson`;
- S4-M1156 aligns Geometric failure-count zero-probability behavior with local `rand_distr::Geometric`;
- S4-M1157 aligns InverseGaussian infinite-parameter sampling with local `rand_distr::InverseGaussian`;
- S4-M1158 aligns SkewNormal unrestricted-location behavior with local `rand_distr::SkewNormal`;
- S4-M1159 aligns NormalInverseGaussian alpha-infinity rejection with local `rand_distr::NormalInverseGaussian`;
- S4-M1160 aligns Hypergeometric large-population HIN underflow rejection with local `rand_distr::Hypergeometric`;
- S4-M1161 aligns Dirichlet positive-subnormal alpha rejection with local `rand_distr::multi::Dirichlet`;
- S4-M1162 aligns Beta/Dirichlet tiny-shape sampling stability with local `rand_distr`;
- S4-M1163 aligns AliasTable per-weight maximum validation with local `rand_distr::WeightedAliasIndex`;
- S4-M1164 aligns WeightedTree/WeightedIntTree zero-total checked sampling errors with local `rand_distr::WeightedTreeIndex::try_sample`;
- S4-M1165 aligns WeightedIntTree integer overflow diagnostics with local `rand_distr::WeightedTreeIndex`;
- S4-M1166 refreshes the full `validate-all` aggregate after the latest weighted-tree compatibility changes;
- S4-M1167 adds weighted sampler clone/equality helpers matching local Rust weighted sampler derives;
- S4-M1168 adds weighted sampler `{f}` format helpers matching local Rust weighted sampler `Debug` workflows;
- S4-M1169 adds dynamic weighted-tree `new` and empty/default constructors matching local `rand_distr::WeightedTreeIndex` construction/default workflows;
- S4-M1170 adds dynamic weighted-tree `trySample` / `trySampleFrom` aliases matching local `rand_distr::WeightedTreeIndex::try_sample` checked sampling naming;
- S4-M1171 refreshes the full `validate-all` aggregate after the latest weighted-tree API additions;
- S4-M1172 adds weighted weight/probability iterator `clone` and `{f}` format helpers matching local Rust weighted iterator clone/debug workflows;
- S4-M1173 refreshes the full `validate-all` aggregate after the weighted iterator helper changes;
- S4-M1174 adds weighted error message helpers matching local Rust weighted `Display` diagnostics;
- S4-M1175 refreshes the full `validate-all` aggregate after the weighted error message helper changes;
- S4-M1176 adds root/prelude weighted error aliases for weighted diagnostics discovery;
- S4-M1177 refreshes the full `validate-all` aggregate after the root weighted error alias change;
- S4-M1178 refreshes local `rand` / `rand_distr` weighted manifest coverage after recent weighted closures;
- S4-M1179 refreshes the local `validate-local` aggregate after the weighted manifest update;
- S4-M1180 adds typed static weighted diagnostics matching local Rust `WeightedIndex` typed weight accessors;
- S4-M1181 refreshes the full `validate-all` aggregate after S4-M1180;
- S4-M1182 refreshes weighted public-surface manifests after the typed diagnostics closure;
- S4-M1183 extends typed static weighted diagnostics through `seq.WeightedChoice`;
- S4-M1184 refreshes the full `validate-all` aggregate after S4-M1183;
- S4-M1185 refreshes dense SIMD vectorbench evidence after S4-M1184;
- S4-M1186 refreshes the local `validate-local` aggregate after S4-M1185;
- S4-M1187 adds dynamic weighted-tree typed diagnostics matching local Rust `WeightedTreeIndex::get` workflows;
- S4-M1188 refreshes the full `validate-all` aggregate after S4-M1187;
- no new unblocked local Rust public-surface or comparison-benchmark gap is known.

## Latest Evidence

S4-M1188 refreshed status output after the post-S4-M1187 full
`validate-all` aggregate. The retained broad validation and local comparison
evidence include:

```text
$ zig test src/distributions.zig --test-filter "typed diagnostics preserve original"
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "weighted tree"
All 21 tests passed.

$ zig test src/distributions.zig --test-filter "weighted int tree"
All 7 tests passed.

Retained validation:
$ zig build validate-all
run_wasi_test self-test ok
wasi sample.wasm --flag
readmecheck ok
apicheck ok
statcheck ok
distcheck ok
toolingcheck ok
roadmapcheck ok
examplecheck ok
profilecheck ok
profiletailcheck ok
profilestresscheck ok
profilelongcheck ok

$ zig build rand-status-json
  "schema_version": 1,
  "current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1188 follow-ups closed for current bar",
  "remaining_blocker": "S4-M1189 post-S4-M1188 next product bar",
  "validate_local_passes": true,
  "opportunity_runners_available": false,
  "no_known_unblocked_gap": true,
  "s4_m11_blocked": false,
  "local_rand_status": "compare/results/s4-m420-current-rand-status.md",
  "blocker_audit": "compare/results/s4-m11-blocker-audit.md",
  "latest_validate_local_evidence": "compare/results/s4-m1188-post-s4-m1187-validate-all.md"

Retained latest local Rust comparison evidence:
$ zig build validate-local
rand_distr standard-normal: 23.3 M samples/s checksum=-3.640
rand_distr standard-normal f32: 22.9 M samples/s checksum=-3.640
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand_bench_smoke self-test ok
runtimecheck ok: no additional runtime runner available

Retained broader-runtime evidence:
wasmtime 31.0.0 (7a9be587f 2025-03-20)
profilelongcheck ok
```

S4-M419 synchronized validate-local signals into `compare/results/s4-m11-blocker-audit.md`; S4-M428 confirmed `rand-status` output is part of the local aggregate; S4-M433 confirmed stable JSON status output is part of the local aggregate; S4-M437 additionally confirms the `rand-status` self-test is part of the local aggregate; S4-M442 keeps the JSON boolean status fields visible in this snapshot; S4-M444 keeps the JSON schema version visible here; S4-M448 confirms the schema-version build step is part of the local aggregate; S4-M459 keeps the latest validate-local evidence pointer visible here; S4-M462 keeps the blocker-audit pointer visible here; S4-M463 confirms that pointer is present in the latest validate-local aggregate output; S4-M466 also keeps the explicit local-status pointer visible here; S4-M469 refreshed the latest validate-local evidence pointer to the then-current artifact, S4-M1125 refreshed it after S4-M1124 restored validate-all, and S4-M1129 refreshed it after S4-M1127/S4-M1128 direct-source f64x4 fill improvements, and S4-M1131 refreshed it after the S4-M1130 validate-all evidence refresh, S4-M1138 refreshed it after S4-M1133-S4-M1137 delegation fixes, S4-M1140 refreshed it after the S4-M1139 evidence-map fix, S4-M1141 refreshed it again after the f64x4 facade standard-vector fill closure, S4-M1142 refreshed it after the parameterized f64x4 vector fill closure, S4-M1143 refreshed it after the zero-rate exponential compatibility closure, S4-M1144 refreshed it after the negative normal stddev compatibility closure, S4-M1145 refreshed it after the unrestricted normal mean compatibility closure, S4-M1146 refreshed it after the mean/CV edge compatibility closure, S4-M1147 refreshed it after the Gamma-family infinity compatibility closure, and S4-M1148 refreshed it after the FisherF infinity compatibility closure, and S4-M1149 refreshed it after the StudentT infinity compatibility closure, and S4-M1150 refreshed it after the Cauchy non-finite parameter compatibility closure, and S4-M1151 refreshed it after the Pareto/Weibull infinite-scale compatibility closure, and S4-M1152 refreshed it after the Beta infinity compatibility closure, and S4-M1153 refreshed it after the Triangular non-finite bound compatibility closure, and S4-M1154 refreshes it after the PERT infinite-shape compatibility closure, and S4-M1155 refreshes it after the Poisson max-lambda compatibility closure, and S4-M1156 refreshes it after the Geometric zero-probability compatibility closure, and S4-M1157 refreshes it after the InverseGaussian infinity compatibility closure, and S4-M1158 refreshes it after the SkewNormal unrestricted-location compatibility closure, and S4-M1159 refreshes it after the NormalInverseGaussian alpha-infinity compatibility closure, and S4-M1160 refreshes it after the Hypergeometric large-population compatibility closure, and S4-M1161 refreshes it after the Dirichlet subnormal-alpha compatibility closure, and S4-M1162 refreshes it after the Beta/Dirichlet tiny-shape compatibility closure, S4-M1163 refreshes it after the AliasTable per-weight maximum compatibility closure, S4-M1164 refreshes it after the WeightedTree zero-total sampling compatibility closure, and S4-M1165 refreshes it after the WeightedIntTree integer-overflow compatibility closure, and S4-M1166 refreshes it after the post-S4-M1165 validate-all aggregate, and S4-M1167 refreshes it after the weighted sampler clone/equality closure, and S4-M1168 refreshes it after the weighted sampler format closure, and S4-M1169 refreshes it after the weighted-tree constructor/default closure, and S4-M1170 refreshes it after the weighted-tree trySample closure, and S4-M1171 refreshes it after the post-S4-M1170 validate-all aggregate, and S4-M1172 refreshes it after the weighted iterator clone/format closure, and S4-M1173 refreshes it after the post-S4-M1172 validate-all aggregate, and S4-M1174 refreshes it after the weighted error message closure, and S4-M1175 refreshes it after the post-S4-M1174 validate-all aggregate, and S4-M1176 refreshes it after the root weighted error alias closure, and S4-M1177 refreshes it after the post-S4-M1176 validate-all aggregate, and S4-M1178 refreshes it after the weighted manifest update, and S4-M1179 refreshes it after the post-S4-M1178 validate-local aggregate, and S4-M1180 refreshes it after the typed static weighted diagnostics closure, and S4-M1181 refreshes it after the post-S4-M1180 validate-all aggregate, and S4-M1182 refreshes it after the weighted manifest update, and S4-M1183 refreshes it after the WeightedChoice typed diagnostics closure, and S4-M1184 refreshes it after the post-S4-M1183 validate-all aggregate, and S4-M1185 refreshes it after the dense SIMD vectorbench probe refresh, and S4-M1186 refreshes it after the post-S4-M1185 validate-local aggregate, and S4-M1187 refreshes it after the dynamic weighted-tree typed diagnostics closure, and S4-M1188 refreshes it after the post-S4-M1187 validate-all aggregate.

## Current Post-S4-M1188 Bar

The long-term product goal is not complete. S4-M11 is closed for the current bar
by direct Wasmtime profilelongcheck evidence in
`compare/results/s4-m1123-wasmtime-profilelongcheck.md`, S4-M1124 restored the
post-S4-M11 `validate-all` aggregate, S4-M1127/S4-M1128 closed direct-source
f64x4 standard normal/exponential fill specializations, S4-M1130 refreshed full
validate-all evidence, S4-M1133-S4-M1137 closed delegation fixes, S4-M1139 fixed
roadmapcheck evidence mapping, S4-M1140 refreshed this status after that fix,
S4-M1141 extends f64x4 standard vector fill specializations to facade
standard-parameter workflows, S4-M1142 extends the f64x4 exact/default draw
shape to parameterized normal and finite-rate exponential vector fills,
S4-M1143 aligns zero-rate exponential behavior with local `rand_distr::Exp`,
S4-M1144 aligns negative normal/log-normal stddev behavior with local
`rand_distr`, S4-M1145 aligns unrestricted normal/log-normal log-space mean
behavior with local `rand_distr`, S4-M1146 aligns exact reusable mean-CV edge
behavior with local `rand_distr::from_mean_cv`, S4-M1147 aligns
Gamma-family infinity behavior with local `rand_distr`, S4-M1148 aligns
FisherF infinity behavior with local `rand_distr::FisherF`, S4-M1149 aligns
StudentT infinity behavior with local `rand_distr::StudentT`, S4-M1150
aligns Cauchy non-finite parameter acceptance with local `rand_distr::Cauchy`,
S4-M1151 aligns Pareto/Weibull infinite-scale acceptance with local
`rand_distr`, S4-M1152 aligns Beta infinite-shape behavior with local
`rand_distr::Beta`, S4-M1153 aligns Triangular non-finite bound behavior
with local `rand_distr::Triangular`, S4-M1154 aligns PERT infinite-shape
behavior with local `rand_distr::Pert`, S4-M1155 aligns Poisson max-lambda
validation with local `rand_distr::Poisson`, S4-M1156 aligns Geometric
failure-count zero-probability behavior with local `rand_distr::Geometric`, S4-M1157 aligns
InverseGaussian infinite-parameter sampling with local `rand_distr::InverseGaussian`, S4-M1158 aligns
SkewNormal unrestricted-location behavior with local `rand_distr::SkewNormal`, and S4-M1159 aligns
NormalInverseGaussian alpha-infinity rejection with local `rand_distr::NormalInverseGaussian`, S4-M1160 aligns Hypergeometric large-population HIN underflow rejection with local `rand_distr::Hypergeometric`, S4-M1161 aligns Dirichlet positive-subnormal alpha rejection with local `rand_distr::multi::Dirichlet`, S4-M1162 aligns Beta/Dirichlet tiny-shape sampling stability with local `rand_distr`, S4-M1163 aligns AliasTable per-weight maximum validation with local `rand_distr::WeightedAliasIndex`, S4-M1164 aligns WeightedTree zero-total checked sampling diagnostics with local `rand_distr::WeightedTreeIndex::try_sample`, S4-M1165 aligns WeightedIntTree integer overflow diagnostics with local `rand_distr::WeightedTreeIndex`, S4-M1166 refreshes the full validate-all aggregate, S4-M1167 adds weighted sampler clone/equality helpers, S4-M1168 adds weighted sampler format helpers, S4-M1169 adds weighted-tree constructor/default helpers, S4-M1170 adds weighted-tree trySample aliases, S4-M1171 refreshes the full validate-all aggregate, S4-M1172 adds weighted iterator clone/format helpers, S4-M1173 refreshes the full validate-all aggregate, S4-M1174 adds weighted error message helpers, S4-M1175 refreshes the full validate-all aggregate, S4-M1176 adds root/prelude weighted error aliases, S4-M1177 refreshes the full validate-all aggregate, S4-M1178 refreshes weighted manifest coverage, S4-M1179 refreshes validate-local evidence, S4-M1180 adds typed static weighted diagnostics, S4-M1181 refreshes validate-all evidence, S4-M1182 refreshes weighted public-surface manifests, S4-M1183 extends typed diagnostics through WeightedChoice, S4-M1184 refreshes validate-all evidence, S4-M1185 refreshes dense SIMD vectorbench evidence, S4-M1186 refreshes validate-local evidence, S4-M1187 adds dynamic weighted-tree typed diagnostics, and S4-M1188 refreshes validate-all evidence after that change. The next bar is S4-M1189: pursue exact/default-compatible dense SIMD normal/exponential
kernels, additional non-WASI OS/architecture execution, broader/longer
validation, or newly discovered local `rand` / `rand_distr` gaps.

## Result

S4-M420 is a status snapshot only: current local Rust comparison evidence shows
no known unblocked core RNG gap versus locally available `rand` / `rand_distr`,
while the post-S4-M1188 S4-M1189 bar continues to block whole-goal completion.
