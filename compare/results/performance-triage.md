# Performance Triage

This document tracks benchmark-driven follow-up work for the long-term product
goal. It records both successful optimizations and rejected changes so the
project does not repeat unproductive work.

## Current High-Value Gaps

| Area | Local Rust evidence | Current Alea evidence | Status |
| --- | --- | --- | --- |
| Poisson `lambda = 20` | `rand_distr poisson`: about 69M samples/s | `alea poisson`: about 62M samples/s with `FastPrng`; about 76M samples/s with `ScalarPrng` direct `sampleFrom` | Closed for scalar-fast profile; default `FastPrng` path still trails Rust |
| Normal `f64` facade | `rand_distr standard-normal`: about 466M samples/s; `rand_distr normal`: about 462M samples/s | `alea normal`: about 390M samples/s with direct ziggurat path; `StandardNormal.sampleFrom(ScalarPrng)`: about 426-428M samples/s | Watch: standard direct reusable path added, but still trails Rust |
| Exponential `f64` facade | `rand_distr exp1`: about 452M samples/s; `rand_distr exponential`: about 443M samples/s | `alea exponential`: about 376-378M samples/s after direct ziggurat path; `StandardExponential.sampleFrom(ScalarPrng)`: about 428-430M samples/s | Watch: standard direct reusable path added and close, but still trails |
| Weighted dynamic update+sample | `rand_distr weighted tree`: about 52M ops/s | `alea weighted int tree`: about 52M ops/s; `WeightedIntTree.sampleFrom` about 52M ops/s; generic float tree about 46M ops/s | Closed for unsigned integer weights; generic float-weight tree remains watch |
| Scalar engine choice | Rust `SmallRng` is the baseline scalar engine | `wyhash64 next`: about 2515-2530M next/s; `normal` on `wyhash64`: about 426-427M samples/s; `fillNormal` on `wyhash64`: about 393-397M samples/s; `exponential` on `wyhash64`: about 422-426M samples/s; `fillExponential` on `wyhash64`: about 400-405M samples/s; `poisson` on `wyhash64`: about 76M samples/s | Use `ScalarPrng` for scalar-heavy distribution workloads; `FastPrng` remains best for bulk byte fill |
| Gamma scalar profile | `rand_distr gamma`: about 172M samples/s | `alea gamma`: about 150M samples/s with `FastPrng`; about 172M with cached `Gamma.sampleFrom(ScalarPrng)` | Closed for scalar-fast reusable sampler; default `FastPrng` path remains watch |
| Direct reusable bulk fill | Local Rust evidence uses repeated sampler calls | `fillSample gamma`: about 141M samples/s; `fillSampleFrom` with `ScalarPrng`: about 162M samples/s | Adopted for direct bulk reusable-sampler workflows |
| Multivariate direct source workflows | Local Rust evidence uses repeated sampler calls | `Dirichlet.sampleIntoFrom(ScalarPrng)` improved allocation-free direct sampling from about 29M to about 46M samples/s; `Multinomial.sampleIntoFrom` is roughly neutral around 1.1M samples/s | Adopted for allocation-free direct-engine workflows beyond scalar samplers |
| Extra continuous distribution breadth | No direct local `rand_distr` rows because these are Alea product-breadth additions | Added Laplace, Logistic, Rayleigh, HalfNormal, Maxwell, Chi, Erlang, LogLogistic, Kumaraswamy, Arcsine, and PowerFunction reusable/direct samplers; local throughput rows are about 139M, 150M, 168M, 412M, 149M, 152M, 160M, 30M, 38M, 102M, and 39M samples/s | Adopted for feature breadth beyond the local Rust distribution list |
| Standard normal/exponential reusable samplers | Rust exposes `StandardNormal` / `Exp1` fast-path distribution types and local rows are about 466M / 452M samples/s | `StandardNormal(T)` / `StandardExponential(T)` added; scalar direct benchmark rows are about 426-430M samples/s on the current Linux host | Adopted for feature parity and scalar-fast workflows; still watch raw ziggurat gap |
| Beta/Fisher reusable samplers | `rand_distr beta`: about 16M samples/s | `alea beta`: about 77M single-shot, about 87M cached; `alea fisher-f`: about 88M cached | Closed for current local Rust evidence; cached Gamma composition is substantially faster |
| ChiSquared/StudentT reusable samplers | Local Rust evidence covered by `rand_distr` derived distributions | `alea chi-squared`: about 150M single-shot, about 172M cached; `alea student-t`: about 113M single-shot, about 123M cached | Closed for cached reusable sampler path; keep single-shot path simple |
| LogNormal reusable sampler | `rand_distr log-normal`: about 149M samples/s | `alea log-normal`: about 104M with `FastPrng`; about 119M with reusable `LogNormal.sampleFrom(ScalarPrng)` | Direct source path helps but still trails Rust |
| InverseGaussian/NormalInverseGaussian reusable samplers | `rand_distr inverse-gaussian`: about 77M; `rand_distr normal-inverse-gaussian`: about 67M | `alea inverse-gaussian`: about 68M single-shot, about 74M cached; `alea normal-inverse-gaussian`: about 56M single-shot, about 62M cached/direct | Watch: direct reusable path helps, but NIG still trails Rust |
| SkewNormal scalar profile | `rand_distr skew-normal`: about 263M samples/s | `alea skew-normal`: about 186M with `FastPrng`; about 229M with reusable `SkewNormal.sampleFrom(ScalarPrng)` | Watch: direct source path helps, but still trails Rust |
| Unit geometry scalar profile | `rand_distr unit circle/sphere`: about 159M samples/s; unit ball about 56M | `alea unit circle/disc/sphere`: about 119-128M with `FastPrng`, about 150-162M with `ScalarPrng` direct; unit ball about 59M direct | Mostly closed for scalar-fast profile; `FastPrng` facade still trails Rust surface/sphere rows |
| Alphanumeric strings | `rand alphanumeric`: about 840M chars/s | `alea alphanumeric`: about 949M chars/s | Closed for current local Rust evidence |

## Rejected Or Deferred Attempts

| Attempt | Result | Decision |
| --- | --- | --- |
| Lower Poisson PTRS threshold from `lambda >= 30` to `lambda >= 12` | `lambda = 20` benchmark dropped from about 26M samples/s to about 23M samples/s, while `distcheck` still passed | Rejected. Dedicated medium-lambda Ahrens-Dieter path was adopted instead. |
| Cache Poisson Ahrens-Dieter constants in reusable `Poisson` sampler | `alea poisson cached`: about 52M samples/s, essentially same as single-shot after adoption | Kept for API quality and avoiding recomputation, but not enough to close the remaining Rust performance gap. |
| Direct `normalFrom` helper wrapping `std.Random.floatNorm` | About 208M samples/s, essentially same as facade/direct `std.Random` and still far below `rand_distr` | Rejected as public API. Normal gap needs a faster normal kernel, not another wrapper. |
| SplitMix64 as scalar-fast distribution engine | `splitmix64 next`: about 1980M next/s; `normal splitmix64 direct`: about 375M samples/s | Rejected as scalar-fast profile. `Wyhash64` remains better for scalar-heavy distribution workloads. |
| Force-inline `Wyhash64.next` / `wymix` | No durable benchmark win: standard-normal stayed around 426M samples/s, standard-exponential around 430M, with several derived rows flat or slightly lower | Rejected. Keep engine declarations simple and focus on algorithm-level or compiler-visible call-shape changes. |
| Direct ziggurat normal using engine `next()` instead of `std.Random.int` | About 386-390M samples/s; repeated runs showed `std.Random.floatNorm` can also fall back near 210M | Adopted as default. Still trails `rand_distr`, so keep optimizing. |
| Reusable `Normal(T)` sampler switched from cached Box-Muller to direct ziggurat | `alea log-normal` improved from about 47M to about 104M samples/s and normal-derived reusable samplers benefit | Adopted. Keep Box-Muller only as a possible future specialized sampler if needed. |
| Reusable/direct `LogNormal(T).sampleFrom` and `logNormalFrom` | `alea log-normal scalar direct`: about 119M samples/s versus the facade/cached row around 104M | Adopted. This carries scalar-fast normal sampling into log-normal workflows. |
| LogNormal via `exp2(x * log2e)` | `alea log-normal scalar direct` dropped from about 119M to about 101M samples/s | Rejected. Keep direct `@exp` for log-normal transformation. |
| Direct ziggurat exponential using engine `next()` instead of `std.Random.int` | About 383M samples/s, essentially same as previous stdlib-backed path | Adopted internally for consistency with normal; not enough to close the Rust performance gap. |
| Distribution-layer normal/exponential via `std.Random.floatNorm` / `floatExp` | Older `distributions.normal` and reusable `Exponential.sample` paths used `std.Random`-backed sampling even after `Rng.normal`/`Rng.exponential` had direct ziggurat fast paths | Replaced with direct fast paths and added standard reusable samplers for explicit zero-parameter workflows. |
| Route all non-`Rng` `normalFastFrom` / `exponentialFastFrom` calls through `source.random()` | `normal wyhash64 std.Random` is about 245M samples/s, while `normal wyhash64 direct` is about 427M samples/s | Rejected as a generic rule. Keep direct ziggurat fast path; use explicit benchmarked bulk helpers for ScalarPrng recommendations. |
| Direct discrete reusable sampler methods | `Bernoulli`, `Binomial`, `NegativeBinomial`, `Hypergeometric`, and `Geometric` now expose `sampleFrom`; `binomial` / `negativeBinomial` / `hypergeometric` / `geometric` have direct helper variants | Adopted for API consistency and direct-engine workflows. Keep integer-threshold Bernoulli/binomial paths to avoid float-comparison regressions. |
| Probability bool bulk/vector sampling | No direct Rust row; fills a Zig-native API gap around repeated `chance(p)` workloads | Added `chanceFrom`, `fillChance`, `fillChanceFrom`, and `vectorChance`/`vectorChanceFrom`; p=0.25 uses packed two-bit generation at about 2.85B samples/s and 4.69B lanes/s, while p=0.5 uses packed bool generation around 3.0B samples/s and 9.8B lanes/s | Adopted for ergonomic high-volume probability sampling and vector API coverage. |
| Direct dynamic weighted-tree sampling | `WeightedTree.sampleFrom` was about 46-48M ops/s and `WeightedIntTree.sampleFrom` about 50-52M ops/s in update+sample microbenchmarks | Adopted for API consistency and direct-engine workflows; performance is roughly neutral for generic tree and comparable for integer tree. |
| Reusable/direct `SkewNormal(T).sampleFrom` | `alea skew-normal scalar direct`: about 229M samples/s, up from the `FastPrng` facade around 186M, but still below local Rust around 263M | Adopted as scalar-fast reusable sampler path; keep skew-normal on the watch list for algorithm-level work. |
| Move `SkewNormal` shape +/-1 min/max into special branches | No measurable win: scalar direct stayed around 228M samples/s and occasionally dipped slightly | Rejected. The bottleneck is the two normal samples, not the min/max placement. |
| Unit geometry signed-unit float generation | Replacing `2 * float - 1` with exponent-bit construction for internal `[-1, 1)` candidates raised `unit circle`/`unit disc`/`unit sphere` scalar direct from about 113-120M to about 150-162M samples/s and `unit ball` direct from about 44M to about 59M | Adopted. This matches Rust's efficient uniform-float range strategy without changing the public API. |
| Public `inline` markers on unit-geometry helpers | Adding `inline` to the exported unit-geometry functions did not produce an independent benchmark win once signed-unit float generation was isolated | Rejected. Keep public function declarations normal and let the optimizer handle call boundaries. |
| Default `fillNormal(f32)` via vector Box-Muller | About 125M samples/s, slower than scalar ziggurat bulk around 196M samples/s | Rejected as default. Keep explicit vector normal prototype for experimentation. |
| Paired `fillVectorNormal(f32)` vector generation | `vectorbench` improved from about 74M to about 130M lanes/s | Superseded for slice fill by scalar ziggurat lane-fill; keep single-vector Box-Muller API as an experimental vector math prototype. |
| Scalar ziggurat lane-fill for vector slices | `vectorbench` raised `fillVectorNormal f32x8` from about 129M to about 352M lanes/s, `fillVectorNormal f64x4` from about 93M to about 371M, `fillVectorExponential f32x8` from about 193M to about 359M, and `fillVectorExponential f64x4` from about 119M to about 383M | Adopted as the default vector-slice fill strategy until a true SIMD distribution kernel beats scalar ziggurat lane-fill. |
| `fillVectorNormal(f64)` vector Box-Muller kernel | `vectorbench` reports about 93M lanes/s, slower than scalar bulk normal | Keep as experimental vector API coverage only; do not use as default scalar replacement. |
| `fillVectorExponential(f64)` vector log kernel | `vectorbench` reports about 119M lanes/s, slower than scalar bulk exponential | Keep as experimental vector API coverage only; do not use as default scalar replacement. |
| Default `fillExponential(f32)` via vector log kernel | About 183M samples/s, slower than scalar ziggurat bulk around 320M samples/s | Rejected as default. Keep explicit vector exponential prototype for experimentation. |
| Full benchmark row for vector-slice range fill | Caused anomalously long full benchmark runs | Deferred. API remains tested; design a smaller isolated microbench before re-adding to the full benchmark. |

## Next Candidate

Continue performance triage on the remaining large gaps:

- normal `f64` facade still trails local `rand_distr`,
- scalar-heavy workloads should be benchmarked with `wyhash64` / scalar-fast profile,
- log-normal and NIG still trail local `rand_distr`,
- skew-normal still trails local `rand_distr`,
- SIMD/vector distribution kernels need stronger default-path wins before they
  can replace scalar ziggurat paths.
