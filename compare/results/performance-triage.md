# Performance Triage

This document tracks benchmark-driven follow-up work for the long-term product
goal. It records both successful optimizations and rejected changes so the
project does not repeat unproductive work.

## Current High-Value Gaps

| Area | Local Rust evidence | Current Alea evidence | Status |
| --- | --- | --- | --- |
| Poisson `lambda = 20` | `rand_distr poisson`: about 69M samples/s | `alea poisson`: about 26M samples/s | Open: needs a better medium-lambda algorithm |
| Normal `f64` facade | `rand_distr normal`: about 462M samples/s | `alea normal`: about 216-224M samples/s | Open: stdlib ziggurat helped, but Alea still trails |
| Exponential `f64` facade | `rand_distr exponential`: about 446M samples/s | `alea exponential`: about 372-380M samples/s | Watch: close but still trails |
| Weighted dynamic update+sample | `rand_distr weighted tree`: about 52M ops/s | `alea weighted tree`: about 46M ops/s | Watch: close, possible data-structure tuning later |

## Rejected Or Deferred Attempts

| Attempt | Result | Decision |
| --- | --- | --- |
| Lower Poisson PTRS threshold from `lambda >= 30` to `lambda >= 12` | `lambda = 20` benchmark dropped from about 26M samples/s to about 23M samples/s, while `distcheck` still passed | Rejected. Keep current threshold and implement a dedicated medium-lambda algorithm instead. |
| Default `fillNormal(f32)` via vector Box-Muller | About 125M samples/s, slower than scalar ziggurat bulk around 196M samples/s | Rejected as default. Keep explicit vector normal prototype for experimentation. |
| Default `fillExponential(f32)` via vector log kernel | About 183M samples/s, slower than scalar ziggurat bulk around 320M samples/s | Rejected as default. Keep explicit vector exponential prototype for experimentation. |
| Full benchmark row for vector-slice range fill | Caused anomalously long full benchmark runs | Deferred. API remains tested; design a smaller isolated microbench before re-adding to the full benchmark. |

## Next Candidate

Implement and benchmark a medium-lambda Poisson sampler comparable to the local
`rand_distr` Ahrens-Dieter rejection path. Completion requires:

- unit tests and `distcheck` still pass,
- `poisson(lambda=20)` improves materially over the current about 26M samples/s,
- no regression for small-lambda product method or large-lambda PTRS evidence.
