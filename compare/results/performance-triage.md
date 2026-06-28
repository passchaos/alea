# Performance Triage

This document tracks benchmark-driven follow-up work for the long-term product
goal. It records both successful optimizations and rejected changes so the
project does not repeat unproductive work.

## Current High-Value Gaps

| Area | Local Rust evidence | Current Alea evidence | Status |
| --- | --- | --- | --- |
| Poisson `lambda = 20` | `rand_distr poisson`: about 69M samples/s | `alea poisson`: about 52M samples/s after Ahrens-Dieter adoption | Watch: materially improved from about 26M; still trails Rust |
| Normal `f64` facade | `rand_distr normal`: about 462M samples/s | `alea normal`: about 386-390M samples/s with direct ziggurat path | Watch: materially improved from the old 210-224M; still trails Rust |
| Exponential `f64` facade | `rand_distr exponential`: about 446M samples/s | `alea exponential`: about 383M samples/s after direct ziggurat path | Watch: close but still trails |
| Weighted dynamic update+sample | `rand_distr weighted tree`: about 52M ops/s | `alea weighted int tree`: about 52M ops/s; generic float tree about 46M ops/s | Closed for unsigned integer weights; generic float-weight tree remains watch |
| Scalar engine choice | Rust `SmallRng` is the baseline scalar engine | `wyhash64 next`: about 2530M next/s; `normal` on `wyhash64`: about 427M samples/s; `exponential` on `wyhash64`: about 422M samples/s; `poisson` on `wyhash64`: about 57M samples/s | Use `ScalarPrng` for scalar-heavy distribution workloads; `FastPrng` remains best for bulk fill |

## Rejected Or Deferred Attempts

| Attempt | Result | Decision |
| --- | --- | --- |
| Lower Poisson PTRS threshold from `lambda >= 30` to `lambda >= 12` | `lambda = 20` benchmark dropped from about 26M samples/s to about 23M samples/s, while `distcheck` still passed | Rejected. Dedicated medium-lambda Ahrens-Dieter path was adopted instead. |
| Cache Poisson Ahrens-Dieter constants in reusable `Poisson` sampler | `alea poisson cached`: about 52M samples/s, essentially same as single-shot after adoption | Kept for API quality and avoiding recomputation, but not enough to close the remaining Rust performance gap. |
| Direct `normalFrom` helper wrapping `std.Random.floatNorm` | About 208M samples/s, essentially same as facade/direct `std.Random` and still far below `rand_distr` | Rejected as public API. Normal gap needs a faster normal kernel, not another wrapper. |
| Direct ziggurat normal using engine `next()` instead of `std.Random.int` | About 386-390M samples/s; repeated runs showed `std.Random.floatNorm` can also fall back near 210M | Adopted as default. Still trails `rand_distr`, so keep optimizing. |
| Direct ziggurat exponential using engine `next()` instead of `std.Random.int` | About 383M samples/s, essentially same as previous stdlib-backed path | Adopted internally for consistency with normal; not enough to close the Rust performance gap. |
| Default `fillNormal(f32)` via vector Box-Muller | About 125M samples/s, slower than scalar ziggurat bulk around 196M samples/s | Rejected as default. Keep explicit vector normal prototype for experimentation. |
| Default `fillExponential(f32)` via vector log kernel | About 183M samples/s, slower than scalar ziggurat bulk around 320M samples/s | Rejected as default. Keep explicit vector exponential prototype for experimentation. |
| Full benchmark row for vector-slice range fill | Caused anomalously long full benchmark runs | Deferred. API remains tested; design a smaller isolated microbench before re-adding to the full benchmark. |

## Next Candidate

Continue performance triage on the remaining large gaps:

- normal `f64` facade still trails local `rand_distr`,
- scalar-heavy workloads should be benchmarked with `wyhash64` / scalar-fast profile,
- weighted dynamic update+sample is close but still trails local `rand_distr`,
- SIMD/vector distribution kernels need stronger default-path wins before they
  can replace scalar ziggurat paths.
