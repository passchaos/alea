# Core RNG Roadmap

This document tracks `alea` against the long-term product goal in `AGENTS.md`:
surpass Rust `rand` / `rand_distr` in core random-number functionality using
Zig-native designs.

It is a living roadmap, not a completion certificate. When all milestones in one
stage are closed, define the next stricter stage instead of declaring the
broader product goal permanently finished.

The active product focus is the current Linux environment. The goal for each
stage is to drive this platform to no known core RNG gaps against locally
available Rust `rand` / `rand_distr` evidence before expanding to broader
platform and longer-run requirements.

## Covered

| Area | Alea artifact | Evidence |
| --- | --- | --- |
| Deterministic engines | `Alea4x64`, `Wyhash64`, `Xoshiro256`, `Xoshiro256PlusPlus`, `Pcg64`, `SplitMix64` | Engine unit tests and `zig build test` |
| Secure-style stream | `ChaCha12` engine and `secure(io)` | `src/engines/chacha.zig`, `src/root.zig` |
| System entropy | `Seed.secure`, `defaultSecure`, `fastSecure`, `reproducibleSecure`, `secureBytes` | `src/seed.zig`, `src/root.zig` |
| `std.Random` interop | Engine `random()` methods and `Rng.random()` | `src/root.zig`, `src/rng.zig` |
| Scalar sampling | integers, floats, booleans, ranges, ratio/chance, chance/ratio fill and vector sampling, bytes | `src/rng.zig` tests |
| Structured sampling | arrays, tuples, enums | `Rng.value(T)` tests |
| Repeated sampling | `valueIter`, `randomIter`, `sampleIter` | `src/rng.zig` tests |
| Unicode and strings | ASCII charsets, custom `Charset`, Unicode scalar UTF-8 strings | `src/ascii.zig` tests |
| Uniform samplers | `Uniform(T)`, `Open01`, `OpenClosed01` | `src/distributions.zig` tests |
| Bernoulli/binomial | `Bernoulli`, `Binomial`, direct-source reusable sampling | Moment and parameter tests |
| Continuous distributions | normal, log-normal, half-normal, exponential, gamma, chi-squared, chi, erlang, beta, Fisher F, Student t, triangular, arcsine, cauchy, laplace, logistic, log-logistic, kumaraswamy, power-function, rayleigh, maxwell, pareto, weibull, dirichlet, standard/derived distribution fill APIs, unit geometry fill APIs | Sampler tests and moment smoke tests |
| Poisson | small-lambda exact product method and large-lambda PTRS method | Large-lambda moment test |
| Sequence sampling | compact `IndexVec`, `sampleIndices`, `sampleArray`, iterator sampling | `src/seq.zig` tests |
| Collection sampling | choose, choose iterators, shuffle, partial shuffle, reservoir sampling | `src/rng.zig` and `src/seq.zig` tests |
| Weighted sampling | weighted index, updateable alias table, weighted choice, direct-source static and dynamic weighted sampling, weighted no-replacement sampling | `src/distributions.zig`, `src/seq.zig` tests |
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
| S2-M3 | Parameter-grid distribution validation | For each public distribution family, add deterministic mean/variance or support checks across multiple parameter regimes, not just one representative case. | Closed: `zig build distcheck` covers scalar, discrete, continuous, bounded-support, and vector distribution families across multiple parameter regimes |
| S2-M4 | Benchmark parity matrix | Add Rust-side benchmark rows for comparable distribution and sequence workloads where `rand`/`rand_distr` exposes matching functionality, and keep Zig/Rust native CPU flags aligned. | Closed: Rust rows cover default-`rand` bytes/range/float/open-float/sequence/bool/string/weighted-index plus `rand_distr` normal, exponential, poisson, binomial, gamma, and beta |
| S2-M5 | Cross-platform reproducibility | Validate and document stable outputs on at least two architectures or OS targets, or document why the current environment cannot provide this evidence. | Closed for local environment: x86_64 Linux snapshot exists and second architecture/OS blocker is documented in `compare/results/cross-platform-repro-blocker.md` |
| S2-M6 | API reference completeness | Add public API reference docs or generated documentation covering all exported modules and examples. | Closed: `docs/api-reference.md` lists the public API surface and tooling |

## Stage 3 Required Milestones

Stage 3 raises the Linux-first bar from broad parity-plus coverage to a stricter
local `rand_distr` 0.6.0 audit. The target is no known core RNG functionality
gap on the current Linux platform against the locally available `rand`,
`rand_distr`, and checked-in comparison evidence.

| ID | Milestone | Completion gate | Status |
| --- | --- | --- | --- |
| S3-M1 | Local `rand_distr` gap closure | Audit local `rand_distr` 0.6.0 source and implement or explicitly exclude each remaining core distribution/geometric sampler in Zig-native form. | Closed for known local distribution gaps: Gumbel, Frechet, SkewNormal, PERT, UnitCircle, UnitDisc, UnitSphere, UnitBall, inverse Gaussian, normal inverse Gaussian, Zipf, and Zeta are implemented |
| S3-M2 | Stage 3 validation grid | Extend `distcheck` and unit tests for all Stage 3 distributions with support checks, deterministic parameter grids, and mean/CDF-style smoke gates where moments exist. | Closed for Stage 3 distribution additions: unit tests and `distcheck` cover support and mean checks for the added families |
| S3-M3 | Stage 3 benchmark parity | Add Zig benchmark rows and Rust `rand_distr` rows for comparable Stage 3 workloads, using native CPU flags on both sides. | Closed for Stage 3 distribution additions: Zig and Rust rows cover comparable scalar and unit-geometry workloads |
| S3-M4 | Weighted dynamic sampling parity | Compare `AliasTable.update`, sequence weighted sampling, and local `rand_distr` weighted alias/tree APIs; add a Zig-native dynamic weighted sampler if alias rebuilds leave a real core gap. | Closed: `WeightedTree(Weight)` adds generic O(log n) sample/update/push/pop parity and `WeightedIntTree(Weight)` adds a faster unsigned-integer path comparable to local `rand_distr::weighted::WeightedTreeIndex`; Zig/Rust update+sample benchmark rows exist |
| S3-M5 | Linux no-known-gaps audit report | Replace informal coverage claims with a checked-in audit listing local Rust evidence, Alea status, remaining gaps, exclusions, and next Linux-first actions. | Closed: `compare/results/linux-no-known-gaps-audit.md` records the local Linux evidence, scope, exclusions, and current no-known-gaps finding |
| S3-M6 | Documentation and API reference refresh | Keep README, core guide, API reference, and parity matrix synchronized with every newly exported Stage 3 API. | Closed for Stage 3: README, core guide, API reference, parity matrix, Zig benchmark rows, and Rust benchmark rows are synchronized |

## Stage 4 Required Milestones

Stage 4 raises the bar after the local Linux no-known-gaps audit. The next focus
is broader evidence, longer validation, and Zig-native advantages beyond local
Rust parity.

| ID | Milestone | Completion gate | Status |
| --- | --- | --- | --- |
| S4-M1 | Broader platform reproducibility | Validate reproducibility snapshots and core distribution checks on at least one additional OS or architecture, or add a stronger blocker with exact missing infrastructure. | Blocked locally: `compare/results/cross-platform-repro-blocker.md` now records the missing second-platform runners and revalidated x86_64 Linux baseline |
| S4-M2 | Longer external statistical validation | Run and check in longer PractRand/TestU01-compatible evidence beyond the current local 64GiB engine reports for the primary Linux engines. | Closed for 128GiB Linux stage: all primary engines have 128GiB PractRand reports; `default` / `Xoshiro256` and `pcg64` each have one default-seed `unusual` plus a clean alternate-seed rerun, summarized in `compare/results/2026-06-28-practrand-128gib-summary.md` |
| S4-M3 | SIMD/vector sampling design | Design and prototype Zig-native vector/SIMD sampling APIs for high-volume scalar distributions without copying Rust `std::simd` surface shapes. | In progress: `Rng` now has Zig-native vector APIs, direct/static vector helpers, direct/static vector fill helpers, packed-lane prototypes for bool/integer/`f32` vectors, vectorized `f32` and `f64` uniform/open/open-closed helpers and bulk fills, exponent-bit f64 uniform/range generation, direct-source scalar/vector bulk `fillFrom` / `fillRangeFrom`, single-pass vector-scaled float range fills, vector-slice fill, vector range/chance/ratio/normal/exponential fills, vector chance/ratio/range/normal/exponential APIs, vector-slice chance/ratio fill APIs, vector-math `f32` normal/exponential kernels, experimental `f64` vector normal/exponential kernels, scalar-ziggurat vector-slice normal/exponential fills, and a dedicated `vectorbench` step; deeper SIMD-optimized distribution kernels are still open |
| S4-M4 | Performance follow-up from parity benchmarks | Use the completed feature matrix to choose targeted performance work where Alea trails local Rust in comparable core workloads. | In progress: `ScalarPrng` reaches about 426-430M standard normal/exponential, 76M Poisson, 172M cached Gamma, and 119M direct LogNormal samples/s for scalar-heavy distribution workloads; `fillSampleFrom` improves direct reusable bulk sampling; cached ChiSquared/Beta/Fisher/StudentT and inverse-Gaussian-family sampler paths are faster than their single-shot equivalents; alphanumeric generation exceeds current local Rust evidence; `compare/results/performance-triage.md` tracks remaining gaps and rejected attempts |

## Current Rule

Continue feature-first work on the earliest open stage milestone. Use
`zig build statcheck` after changes that affect engines, distributions, ranges,
or sampling internals. Use `zig build stream -- ...` to feed raw engine output
into external statistical tools when validating engine changes. Defer pure
micro-optimization until feature, correctness, and validation milestones are in
place, except where performance is part of a feature's viability.

## Long-Term Product Tracks

These tracks exist beyond any single roadmap stage. Closing a stage means the
current evidence bar was met, not that Alea has finished surpassing Rust
`rand` / `rand_distr` as a product.

| Track | Product target | Current next pressure |
| --- | --- | --- |
| Feature breadth | Core random workflows should be available in one Zig-native library without forcing users into companion packages. | Bulk range, strict-interval float, standard normal/exponential, normal, log-normal, half-normal, inverse-Gaussian-family, skew-normal, unit geometry, and reusable-sampler fill APIs exist; Laplace, Logistic, Rayleigh, HalfNormal, Maxwell, Chi, Erlang, LogLogistic, Kumaraswamy, Arcsine, and PowerFunction extend continuous distribution breadth beyond the local Rust list; continue adding specialized bulk paths only where they materially improve throughput or ergonomics. |
| Statistical confidence | Engine and distribution evidence should keep getting longer, broader, and easier to reproduce. | Follow `compare/results/practrand-observation-followup.md` for `default` and `pcg64`; add second-platform execution when infrastructure exists. |
| Performance | Fast paths should be competitive with or faster than local Rust evidence for comparable workloads, with facade/direct overhead separated. | Follow `compare/results/performance-triage.md`; distinguish bulk-fast, scalar-fast, and allocation-free direct-source profiles when choosing defaults or recommendations. |
| Ergonomics | APIs should feel natural in Zig, including allocation-free and comptime-friendly workflows. | `fillSample` gives reusable samplers an allocation-free bulk path; continue reducing boilerplate for high-volume workflows. |
| Portability | Stable-output expectations should be clear across targets, and blockers should be exact. | Close S4-M1 once another OS/architecture runner is available. |
