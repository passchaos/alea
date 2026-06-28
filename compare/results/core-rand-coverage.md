# Core RNG Roadmap

This document tracks `alea` against the long-term product goal in `AGENTS.md`:
surpass Rust `rand` / `rand_distr` in core random-number functionality using
Zig-native designs.

It is a living roadmap, not a completion certificate. When all milestones in one
stage are closed, define the next stricter stage instead of declaring the
broader product goal permanently finished.

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

## Stage 1 Required Milestones

| ID | Milestone | Completion gate | Status |
| --- | --- | --- | --- |
| M1 | External statistical validation | PractRand 0.96 `stdin64` at 16GiB or larger for `fast`, `default`, `wyhash64`, `pcg64`, `xoshiro256++`, and `chacha12`, with checked-in reports. Any anomaly must be investigated or explicitly accepted with rationale. | Closed: all listed engines have 16GiB passes |
| M2 | Distribution algorithm maturity | Replace correctness-first slow paths where mature algorithms are known: ziggurat-style normal/exponential or documented faster alternatives, and benchmarked exact large-n binomial. Keep exact semantics separate from approximation helpers. | Closed: single-shot normal/exponential use Zig stdlib ziggurat, reusable normal caches pairs, exponential precomputes inverse rate, and binomial has exact small-n/p=0.5/large-n rejection paths |
| M3 | Distribution benchmark matrix | Add benchmark rows for every public distribution family across at least one representative parameter set, including tail/derived/multivariate distributions. | Closed: `zig build bench` covers scalar, Bernoulli/binomial, Poisson, continuous, tail, derived, and multivariate distribution families |
| M4 | Fallible API surface | Provide checked/error-returning variants for public single-shot APIs where invalid input is realistically user-supplied, while preserving assert-based fast paths. | Closed: checked probability/range, weighted-index, sample-without-replacement, sequence-index, and charset constructors exist |
| M5 | Reproducibility matrix | Document deterministic output stability expectations for each reproducible engine and seed/stream derivation API, including what may vary by architecture or version. | Closed: `compare/results/reproducibility-matrix.md` defines stable, versioned-stable, and non-stable outputs |
| M6 | Core docs | Expand README or dedicated docs to cover engines, seeding, distributions, sequence sampling, statistical validation, and benchmark interpretation without relying only on tests and examples. | Closed: `docs/core-guide.md` covers core APIs, validation, and benchmarks |

## Stage 2 Required Milestones

| ID | Milestone | Completion gate | Status |
| --- | --- | --- | --- |
| S2-M1 | Extended statistical validation | PractRand 0.96 `stdin64` at 64GiB or larger for `fast`, `default`, `wyhash64`, `pcg64`, `xoshiro256++`, and `chacha12`, plus at least one TestU01-compatible report or a documented local blocker. | Closed: all listed engines have 64GiB PractRand passes |
| S2-M2 | Distribution parity-plus matrix | Compare the public distribution list against locally available `rand_distr`/historical `rand` distribution families and add any still-missing core families or explicitly document why they are out of scope for Zig-native `alea`. | Closed: `compare/results/distribution-parity-matrix.md` covers local `rand`, historical `rand`, Alea extras, and explicit out-of-scope items |
| S2-M3 | Parameter-grid distribution validation | For each public distribution family, add deterministic mean/variance or support checks across multiple parameter regimes, not just one representative case. | Not started |
| S2-M4 | Benchmark parity matrix | Add Rust-side benchmark rows for comparable distribution and sequence workloads where `rand`/`rand_distr` exposes matching functionality, and keep Zig/Rust native CPU flags aligned. | Not started |
| S2-M5 | Cross-platform reproducibility | Validate and document stable outputs on at least two architectures or OS targets, or document why the current environment cannot provide this evidence. | Not started |
| S2-M6 | API reference completeness | Add public API reference docs or generated documentation covering all exported modules and examples. | Not started |

## Current Rule

Continue feature-first work on the earliest open stage milestone. Use
`zig build statcheck` after changes that affect engines, distributions, ranges,
or sampling internals. Use `zig build stream -- ...` to feed raw engine output
into external statistical tools when validating engine changes. Defer pure
micro-optimization until feature, correctness, and validation milestones are in
place, except where performance is part of a feature's viability.
