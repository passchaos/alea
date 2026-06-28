# Core RNG Roadmap

This document tracks `alea` against the repository goal in `AGENTS.md`: surpass
Rust `rand` in core random-number functionality using Zig-native designs.

It is a roadmap, not a completion certificate. Items in **Required Milestones**
must be completed before the long-term goal is considered fully achieved.

## Covered

| Area | Alea artifact | Evidence |
| --- | --- | --- |
| Deterministic engines | `Alea4x64`, `Wyhash64`, `Xoshiro256`, `Xoshiro256PlusPlus`, `Pcg64`, `SplitMix64` | Engine unit tests and `zig build test` |
| Secure-style stream | `ChaCha12` engine and `secure(io)` | `src/engines/chacha.zig`, `src/root.zig` |
| System entropy | `Seed.secure`, `defaultSecure`, `fastSecure`, `reproducibleSecure`, `secureBytes` | `src/seed.zig`, `src/root.zig` |
| `std.Random` interop | Engine `random()` methods and `Rng.random()` | `src/root.zig`, `src/rng.zig` |
| Scalar sampling | integers, floats, booleans, ranges, ratio/chance, bytes | `src/rng.zig` tests |
| Structured sampling | arrays, tuples, enums | `Rng.value(T)` tests |
| Repeated sampling | `valueIter`, `randomIter`, `sampleIter` | `src/rng.zig` tests |
| Unicode and strings | ASCII charsets, custom `Charset`, Unicode scalar UTF-8 strings | `src/ascii.zig` tests |
| Uniform samplers | `Uniform(T)`, `Open01`, `OpenClosed01` | `src/distributions.zig` tests |
| Bernoulli/binomial | `Bernoulli`, `Binomial` | Moment and parameter tests |
| Continuous distributions | normal, log-normal, exponential, gamma, chi-squared, beta, Fisher F, Student t, triangular, cauchy, pareto, weibull, dirichlet | Sampler tests and moment smoke tests |
| Poisson | small-lambda exact product method and large-lambda PTRS method | Large-lambda moment test |
| Sequence sampling | compact `IndexVec`, `sampleIndices`, `sampleArray`, iterator sampling | `src/seq.zig` tests |
| Collection sampling | choose, choose iterators, shuffle, partial shuffle, reservoir sampling | `src/rng.zig` and `src/seq.zig` tests |
| Weighted sampling | weighted index, updateable alias table, weighted choice, weighted no-replacement sampling | `src/distributions.zig`, `src/seq.zig` tests |
| Statistical smoke tests | engine bit balance, range buckets, normal/exponential means | `src/quality.zig` |
| Native benchmark evidence | Zig and Rust native CPU commands; facade/direct split | `compare/results/2026-06-27-rand-comparison.md` |

## Required Milestones

| ID | Milestone | Completion gate | Status |
| --- | --- | --- | --- |
| M1 | External statistical validation | PractRand 0.96 `stdin64` at 16GiB or larger for `fast`, `default`, `wyhash64`, `pcg64`, `xoshiro256++`, and `chacha12`, with checked-in reports. Any anomaly must be investigated or explicitly accepted with rationale. | Closed: all listed engines have 16GiB passes |
| M2 | Distribution algorithm maturity | Replace correctness-first slow paths where mature algorithms are known: ziggurat-style normal/exponential or documented faster alternatives, and benchmarked exact large-n binomial. Keep exact semantics separate from approximation helpers. | Closed: single-shot normal/exponential use Zig stdlib ziggurat, reusable normal caches pairs, exponential precomputes inverse rate, and binomial has exact small-n/p=0.5/large-n rejection paths |
| M3 | Distribution benchmark matrix | Add benchmark rows for every public distribution family across at least one representative parameter set, including tail/derived/multivariate distributions. | Closed: `zig build bench` covers scalar, Bernoulli/binomial, Poisson, continuous, tail, derived, and multivariate distribution families |
| M4 | Fallible API surface | Provide checked/error-returning variants for public single-shot APIs where invalid input is realistically user-supplied, while preserving assert-based fast paths. | In progress |
| M5 | Reproducibility matrix | Document deterministic output stability expectations for each reproducible engine and seed/stream derivation API, including what may vary by architecture or version. | Closed: `compare/results/reproducibility-matrix.md` defines stable, versioned-stable, and non-stable outputs |
| M6 | Core docs | Expand README or dedicated docs to cover engines, seeding, distributions, sequence sampling, statistical validation, and benchmark interpretation without relying only on tests and examples. | In progress |

## Current Rule

Continue feature-first work until all required milestones are closed. Use
`zig build statcheck` after changes that affect engines, distributions, ranges,
or sampling internals. Use `zig build stream -- ...` to feed raw engine output
into external statistical tools when validating engine changes. Defer pure
micro-optimization until feature, correctness, and validation milestones are in
place, except where performance is part of a feature's viability.
