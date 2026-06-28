# Performance Triage

This document tracks benchmark-driven follow-up work for the long-term product
goal. It records both successful optimizations and rejected changes so the
project does not repeat unproductive work.

## Current High-Value Gaps

| Area | Local Rust evidence | Current Alea evidence | Status |
| --- | --- | --- | --- |
| Poisson `lambda = 20` | `rand_distr poisson`: about 69M samples/s | `alea poisson`: about 62M samples/s with `FastPrng`; about 76M samples/s with `ScalarPrng` direct `sampleFrom` | Closed for scalar-fast profile; default `FastPrng` path still trails Rust |
| Normal `f64` facade | `rand_distr normal`: about 462M samples/s | `alea normal`: about 386-390M samples/s with direct ziggurat path | Watch: materially improved from the old 210-224M; still trails Rust |
| Exponential `f64` facade | `rand_distr exponential`: about 446M samples/s | `alea exponential`: about 383M samples/s after direct ziggurat path | Watch: close but still trails |
| Weighted dynamic update+sample | `rand_distr weighted tree`: about 52M ops/s | `alea weighted int tree`: about 52M ops/s; generic float tree about 46M ops/s | Closed for unsigned integer weights; generic float-weight tree remains watch |
| Scalar engine choice | Rust `SmallRng` is the baseline scalar engine | `wyhash64 next`: about 2515-2530M next/s; `normal` on `wyhash64`: about 426-427M samples/s; `fillNormal` on `wyhash64`: about 393-397M samples/s; `exponential` on `wyhash64`: about 422-426M samples/s; `fillExponential` on `wyhash64`: about 400-405M samples/s; `poisson` on `wyhash64`: about 76M samples/s | Use `ScalarPrng` for scalar-heavy distribution workloads; `FastPrng` remains best for bulk byte fill |
| Gamma scalar profile | `rand_distr gamma`: about 172M samples/s | `alea gamma`: about 150M samples/s with `FastPrng`; about 172M with cached `Gamma.sampleFrom(ScalarPrng)` | Closed for scalar-fast reusable sampler; default `FastPrng` path remains watch |
| Direct reusable bulk fill | Local Rust evidence uses repeated sampler calls | `fillSample gamma`: about 141M samples/s; `fillSampleFrom` with `ScalarPrng`: about 162M samples/s | Adopted for direct bulk reusable-sampler workflows |
| Beta/Fisher reusable samplers | `rand_distr beta`: about 16M samples/s | `alea beta`: about 77M single-shot, about 87M cached; `alea fisher-f`: about 88M cached | Closed for current local Rust evidence; cached Gamma composition is substantially faster |
| ChiSquared/StudentT reusable samplers | Local Rust evidence covered by `rand_distr` derived distributions | `alea chi-squared`: about 150M single-shot, about 172M cached; `alea student-t`: about 113M single-shot, about 123M cached | Closed for cached reusable sampler path; keep single-shot path simple |
| InverseGaussian/NormalInverseGaussian reusable samplers | `rand_distr inverse-gaussian`: about 77M; `rand_distr normal-inverse-gaussian`: about 67M | `alea inverse-gaussian`: about 68M single-shot, about 74M cached; `alea normal-inverse-gaussian`: about 58M cached | Watch: direct reusable path helps, but NIG still trails Rust |
| Unit geometry scalar profile | `rand_distr unit circle/sphere`: about 159M samples/s; unit ball about 56M | `alea unit circle/disc/sphere`: about 91-95M with `FastPrng`, about 113-120M with `ScalarPrng` direct; unit ball about 45M direct | Watch: direct scalar path helps, but geometry algorithms still trail Rust |
| Alphanumeric strings | `rand alphanumeric`: about 840M chars/s | `alea alphanumeric`: about 949M chars/s | Closed for current local Rust evidence |

## Rejected Or Deferred Attempts

| Attempt | Result | Decision |
| --- | --- | --- |
| Lower Poisson PTRS threshold from `lambda >= 30` to `lambda >= 12` | `lambda = 20` benchmark dropped from about 26M samples/s to about 23M samples/s, while `distcheck` still passed | Rejected. Dedicated medium-lambda Ahrens-Dieter path was adopted instead. |
| Cache Poisson Ahrens-Dieter constants in reusable `Poisson` sampler | `alea poisson cached`: about 52M samples/s, essentially same as single-shot after adoption | Kept for API quality and avoiding recomputation, but not enough to close the remaining Rust performance gap. |
| Direct `normalFrom` helper wrapping `std.Random.floatNorm` | About 208M samples/s, essentially same as facade/direct `std.Random` and still far below `rand_distr` | Rejected as public API. Normal gap needs a faster normal kernel, not another wrapper. |
| Direct ziggurat normal using engine `next()` instead of `std.Random.int` | About 386-390M samples/s; repeated runs showed `std.Random.floatNorm` can also fall back near 210M | Adopted as default. Still trails `rand_distr`, so keep optimizing. |
| Reusable `Normal(T)` sampler switched from cached Box-Muller to direct ziggurat | `alea log-normal` improved from about 47M to about 104M samples/s and normal-derived reusable samplers benefit | Adopted. Keep Box-Muller only as a possible future specialized sampler if needed. |
| Direct ziggurat exponential using engine `next()` instead of `std.Random.int` | About 383M samples/s, essentially same as previous stdlib-backed path | Adopted internally for consistency with normal; not enough to close the Rust performance gap. |
| Route all non-`Rng` `normalFastFrom` / `exponentialFastFrom` calls through `source.random()` | In one native run `normal wyhash64 direct` dropped to about 243M samples/s, while bulk fills improved; behavior was inconsistent by workload | Rejected as a generic rule. Keep direct ziggurat fast path; use explicit benchmarked bulk helpers for ScalarPrng recommendations. |
| Default `fillNormal(f32)` via vector Box-Muller | About 125M samples/s, slower than scalar ziggurat bulk around 196M samples/s | Rejected as default. Keep explicit vector normal prototype for experimentation. |
| Paired `fillVectorNormal(f32)` vector generation | `vectorbench` improved from about 74M to about 130M lanes/s | Adopted for vector-slice normal fills; still not a default scalar replacement. |
| `fillVectorNormal(f64)` vector Box-Muller kernel | `vectorbench` reports about 93M lanes/s, slower than scalar bulk normal | Keep as experimental vector API coverage only; do not use as default scalar replacement. |
| `fillVectorExponential(f64)` vector log kernel | `vectorbench` reports about 119M lanes/s, slower than scalar bulk exponential | Keep as experimental vector API coverage only; do not use as default scalar replacement. |
| Default `fillExponential(f32)` via vector log kernel | About 183M samples/s, slower than scalar ziggurat bulk around 320M samples/s | Rejected as default. Keep explicit vector exponential prototype for experimentation. |
| Full benchmark row for vector-slice range fill | Caused anomalously long full benchmark runs | Deferred. API remains tested; design a smaller isolated microbench before re-adding to the full benchmark. |

## Next Candidate

Continue performance triage on the remaining large gaps:

- normal `f64` facade still trails local `rand_distr`,
- scalar-heavy workloads should be benchmarked with `wyhash64` / scalar-fast profile,
- weighted dynamic update+sample is close but still trails local `rand_distr`,
- SIMD/vector distribution kernels need stronger default-path wins before they
  can replace scalar ziggurat paths.
