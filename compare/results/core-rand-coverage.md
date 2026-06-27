# Core RNG Coverage Matrix

This matrix tracks `alea` against the repository goal in `AGENTS.md`: surpass
Rust `rand` in core random-number functionality using Zig-native designs.

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
| Weighted sampling | weighted index, alias table, weighted choice, weighted no-replacement sampling | `src/distributions.zig`, `src/seq.zig` tests |
| Statistical smoke tests | engine bit balance, range buckets, normal/exponential means | `src/quality.zig` |
| Native benchmark evidence | Zig and Rust native CPU commands; facade/direct split | `compare/results/2026-06-27-rand-comparison.md` |

## Known Gaps

| Area | Gap | Priority |
| --- | --- | --- |
| Full statistical validation | `zig build statcheck` adds a longer in-repo statistical smoke harness, and `zig build stream` exports raw bytes for PractRand/TestU01-style external testing. Stream exporter smoke evidence is checked in; a long-run external PractRand/TestU01 report is still pending. | Medium |
| Distribution benchmarks | `zig build bench` includes representative rows for scalar, tail, derived, and multivariate distributions; exhaustive per-distribution benchmark reporting is still optional future work. | Closed |
| Distribution algorithms | Normal samplers cache paired Box-Muller output, exponential samplers precompute inverse rate, and binomial has a p=0.5 popcount fast path; general binomial and ziggurat-style normal/exponential algorithms remain future work. | Medium |
| Error-returning scalar APIs | Checked variants exist for probabilities and scalar ranges; some older assertion-based helpers remain as fast-path APIs. | Low |
| Iterator ergonomics | `chooseIterator`, `sampleIterator`, `chooseIteratorWeighted`, and `sampleIteratorWeighted` use Zig iterator shape directly. | Closed |
| Documentation examples | README and `examples/basic.zig` demonstrate expanded distribution, Unicode, iterator, and sequence helpers. | Closed |

## Current Rule

Continue feature-first work until the high-priority core functionality gaps are
closed. Use `zig build statcheck` after changes that affect engines,
distributions, ranges, or sampling internals. Use `zig build stream -- ...` to
feed raw engine output into external statistical tools when validating engine
changes. Defer performance tuning except where a feature is unusable without it
or where benchmark evidence is needed to compare against Rust `rand`.
