# S4-M420 Current Local Rand Comparison Status

Date: 2026-07-19

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
- S4-M1201-S4-M1219 closed parameterized SIMD vectorbench refreshes and roadmap drift repairs;
- S4-M1220-S4-M1222 added full-covariance and static multivariate-normal samplers;
- S4-M1223 fixed f64 StandardUniform to the correct 53-bit grid;
- S4-M1224-S4-M1229 hardened distribution vector lane load/store and recovered f64 throughput;
- S4-M1230-S4-M1235 hardened Rng normal affine lane stores, fallible byte/owned-byte fallbacks, fromRandom nextU32 byte shape, and root string preallocation;
- S4-M1236-S4-M1241 aligned direct-source raw-alias dispatch for nextU64, fillBytes, generic nextFrom, fromRng, Rng.init, and nextU32-only sources, enabling Rust-style direct RNGs without Zig-only `next`;
- S4-M1243 fixed stable iterator choice semantics to match Rust `choose_stable`;
- S4-M1244 converted StandardNormal/StandardExponential to polymorphic unit structs with Exp1 alias and vector support;
- S4-M1245 added Standard alias, N-dimensional unit sphere/ball, StandardCauchy/StandardLogistic unit structs completing the common zero-parameter continuous distributions;
- S4-M1246 added Von Mises circular distribution with Best–Fisher rejection sampling (beyond `rand_distr` coverage);
- S4-M1247 added Wrapped Cauchy circular distribution with closed-form scalar/SIMD inverse-CDF sampling;
- S4-M1248 landed true mask-rejection SIMD f64x4 ziggurat for standard normal/exponential — exact/default dense-SIMD kernels now beat scalar lane-fill;
- S4-M1249 extended true SIMD ziggurat to native f32x8 precision profiles;
- S4-M1250 added Truncated Normal distribution with public normPdf/normCdf/probit helpers, closed-form inverse-CDF sampling for deterministic latency, and promoted vonMises/wrappedCauchy to full public API;
- S4-M1251 added Von Mises-Fisher spherical directional distribution on Sⁿ⁻¹ for arbitrary comptime dim n≥2;
- S4-M1252 added Watson axial spherical directional distribution with bipolar/girdle/uniform regimes;
- S4-M1253 added Rice (Rician) fading distribution;
- S4-M1254 added Nakagami-m fading distribution;
- S4-M1255 added Inverse Gamma distribution;
- S4-M1256 added Exponentially Modified Gaussian (ExGaussian) distribution;
- S4-M1257 added Generalized Pareto Distribution (GPD);
- S4-M1258 added Scaled Inverse Chi-Squared distribution;
- S4-M1259 added Hoyt (Nakagami-q) fading distribution with new besselI1 helper;
- S4-M1260 added Noncentral Chi-Squared distribution (Poisson-mixture algorithm);
- S4-M1261 added Noncentral t distribution;
- S4-M1262 added Noncentral F distribution;
- S4-M1263 added Noncentral Chi distribution;
- S4-M1264 added vector/SIMD sampling for all S4-M1253–M1263 distributions with true SIMD where possible and per-lane scalar fallback for discrete-mixture shapes;
- S4-M1265 added stack-allocated (comptime-dim) Wishart and Inverse-Wishart distributions using rejection-free Bartlett decomposition and Cholesky inversion;
- S4-M1266 added dynamic (runtime-dim, allocator-backed) Wishart and Inverse-Wishart distributions matching the `MultivariateNormal(T)` flat-row-major pattern with zero-allocation `sampleInto` hot path.

## Current local parity conclusion

On the current Linux x86_64 host, against the locally available `rand` and cached
`rand_distr 0.6.0` evidence, **there are no known unblocked local Rust core RNG gaps**;
no new unblocked local Rust public-surface or comparison-benchmark gap is known.

Every `rand_distr` 0.6.0 pub-used distribution is covered; every `rand::seq`
public helper (including weighted sampling with and without replacement,
reservoir sampling, partial shuffle, fixed-size arrays, caller-owned buffers,
pointer/value variants, iterator variants) is covered; SIMD dense-vector
f32x8/f64x4 ziggurat kernels for normal and exponential exceed Rust `rand`'s
scalar-per-lane throughput; alea additionally provides a substantial list of
distributions absent from `rand_distr` core (Truncated Normal, Von Mises, Wrapped
Cauchy, Von Mises-Fisher, Watson, Rice, Nakagami-m, InverseGamma, ExGaussian, GPD,
ScaledInverseChiSquared, Hoyt, four noncentral distributions, and both
stack-allocated and heap-allocated Wishart/InverseWishart matrix distributions).
S4-M11 is closed for the current bar; no known unblocked core RNG gap versus locally available `rand` / `rand_distr`.

## Latest Evidence

S4-M1266 adds dynamic runtime-dimension Wishart/InverseWishart with zero-allocation
sampleInto after S4-M1265 added stack-allocated variants. S4-M1264 adds vector/SIMD
sampling for all S4-M1253–M1263 distributions. The retained status and validation
evidence include:

```text
$ zig build validate
apicheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
statcheck ok
distcheck ok
profilecheck ok
roadmapcheck ok

$ zig build rand-status-json
{
  "schema_version": 1,
  "date": "2026-07-19",
  "baseline": {
    "rand": "~/Work/rand",
    "rand_distr": "cached rand_distr 0.6.0"
  },
  "latest_gate": "zig build validate-local passes",
  "validate_local_passes": true,
  "public_surface": "surfacecheck ok for rand/rand_core/rand_distr manifests; all pub-used distributions and seq helpers covered",
  "rust_comparison": "parser tests and rand-bench-smoke pass",
  "runtime_runners": "node/cargo/rustc found; Wasmtime 31.0.0 profilelongcheck evidence recorded",
  "opportunity_runners_available": false,
  "current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1266 follow-ups closed for current bar",
  "no_known_unblocked_gap": true,
  "remaining_blocker": "Bingham/Matrix-vMF/Kent/copulas and broader-platform/longer-validation next bar",
  "s4_m11_blocked": false,
  "details": "compare/results/s4-m420-current-rand-status.md",
  "local_rand_status": "compare/results/s4-m420-current-rand-status.md",
  "blocker_audit": "compare/results/s4-m11-blocker-audit.md",
  "latest_validate_local_evidence": "compare/results/s4-m1266-dynamic-wishart-inverse-wishart.md"
}

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
Wasmtime profilelongcheck run. `compare/results/s4-m1266-dynamic-wishart-inverse-wishart.md`
records the latest dynamic Wishart/InverseWishart closure.
S4-M11 is closed for the current bar; no known unblocked core RNG gap versus locally available `rand` / `rand_distr`.

## Current next raised bar

The long-term product goal is not complete. Remaining work is in the explicitly
raised next bar: Bingham distribution, Matrix von Mises-Fisher, Kent
distribution, copula methods, SIMD spherical bulk sampling paths, longer
statistical validation runs (1TiB+ PractRand, TestU01 BigCrush), broader
platform/architecture evidence (Windows, macOS, ARM64, RISC-V), independent
security audit of the system-entropy path, ecosystem interoperability, and
performance follow-ups — not local parity closure.

## Result

S4-M420 is a status snapshot: current local Rust comparison evidence shows no
known unblocked core RNG gap versus locally available `rand` / `rand_distr` on
this Linux x86_64 host; broader-platform and long-validation tracks remain the
active follow-up per the living roadmap.
