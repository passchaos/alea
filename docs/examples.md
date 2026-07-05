# Alea Examples Catalog

All examples are runnable through `zig build examples`; each row also has a
focused `zig build run-*` step for quick adoption checks.

| Build step | Source | Use when you want to learn |
| --- | --- | --- |
| `zig build run-basic` | `examples/basic.zig` | A broad first tour: engines, `Rng`, owned byte/value/bounded-uint/sample/scalar-and-vector-probability/standard-and-parameterized normal/exponential batches, distributions, strings, one-shot and repeated index/value/const/mutable-pointer choice, sequence helpers, and child streams. |
| `zig build run-reproducible-streams` | `examples/reproducible_streams.zig` | Stable named seeds, substreams, engine aliases, split/jump, and PCG stream selection. |
| `zig build run-range-sampling` | `examples/range_sampling.zig` | Integer half-open/inclusive ranges, strict float endpoint semantics, duration ranges, owned duration/range/inclusive-range/vector-range/vector-inclusive-range and scalar/vector strict-interval batches, reusable `Uniform`, vector ranges, point masses, and checked errors. |
| `zig build run-discrete-distributions` | `examples/discrete_distributions.zig` | Bernoulli, Binomial, NegativeBinomial, Poisson, Geometric trial/failure semantics, Hypergeometric, vector discrete samplers, and checked errors. |
| `zig build run-continuous-distributions` | `examples/continuous_distributions.zig` | Core continuous reusable samplers and diagnostics: Gamma, Beta, FisherF, StudentT, Triangular, Arcsine, Cauchy, Laplace, Logistic, Rayleigh, Pareto, and Weibull. |
| `zig build run-advanced-continuous-distributions` | `examples/advanced_continuous_distributions.zig` | Advanced continuous shape/tail families: HalfNormal, ChiSquared, Chi, Erlang, Maxwell, LogLogistic, Kumaraswamy, PowerFunction, Gumbel, Frechet, SkewNormal, InverseGaussian, and NormalInverseGaussian. |
| `zig build run-rank-distributions` | `examples/rank_distributions.zig` | Finite Zipf, unbounded Zeta, vector rank samplers, infinite-exponent rank-one degeneracy, and checked invalid parameters. |
| `zig build run-distribution-diagnostics` | `examples/distribution_diagnostics.zig` | Constructor/accessor diagnostics: moments, support, mean/CV constructors, z-score conversion, and PERT range-first builders. |
| `zig build run-vector-profiles` | `examples/vector_profiles.zig` | Exact/default vector normal/exponential versus explicit throughput-first `Table` and `ApproxLog` opt-ins. |
| `zig build run-native-f32-profiles` | `examples/native_f32_profiles.zig` | Exact/default f64-backed f32 outputs versus f32-native normal/exponential throughput profiles. |
| `zig build run-lognormal-profiles` | `examples/lognormal_profiles.zig` | Exact LogNormal, buffered exact, native-f32, exp2, native-exp2, and libc-backed platform opt-ins when available. |
| `zig build run-weighted-sampling` | `examples/weighted_sampling.zig` | One-shot and repeated f64/generic weighted indexes, generic weighted values, f64 weighted values, fixed-size f64/generic/item-accessor/index-weight-accessor weighted index/u32-index/value/const-pointer/mutable-pointer arrays, and generic/f64 const plus f64 mutable pointers, static alias tables, dynamic weighted trees, weighted choices with value/pointer/index samples, fills, owned value/pointer/usize/u32-index batches, repeated weighted pointer streams including item-accessor streams, fixed-size and streaming usize/u32 index outputs, allocation-returning weighted no-replacement item/usize-index/u32-index/pointer outputs, compact weighted IndexVec samples, fixed-size weighted item/usize-index/u32-index/pointer arrays, and caller-owned weighted usize/u32 index/value/const-pointer/pointer buffers. |
| `zig build run-sequence-sampling` | `examples/sequence_sampling.zig` | Index sampling, compact fixed-size u32 index arrays, IndexVec owned-backing adoption, deep clone, consuming index iteration, lazy/caller-owned/allocation-returning/consuming value, pointer, mutable-pointer, u32 export mapping, and cross-backing equality, caller-owned usize/u32 index buffers, fixed-size repeated value/pointer choice arrays, fixed-size no-replacement value/pointer arrays, allocation-returning and caller-owned item/value/pointer subset buffers, item subsets, partial shuffle selected/rest splits, allocated/caller-owned value and pointer reservoir sampling, reusable choices with value/pointer/index samples, fills, owned value/pointer/index batches, fixed-size index arrays, usize/u32 index streams, and fixed-size/allocation-returning/caller-owned streaming iterator helpers, and fixed-size/caller-owned weighted iterator helpers. |
| `zig build run-caller-owned-sampling` | `examples/caller_owned_sampling.zig` | Caller-owned index/item/pointer/iterator buffers, weighted scratch buffers, and allocation-predictable sampling workflows. |
| `zig build run-multivariate-sampling` | `examples/multivariate_sampling.zig` | Multinomial and Dirichlet allocation-returning samples, caller-owned buffers, flat batched outputs, and degenerate vertices. |
| `zig build run-string-generation` | `examples/string_generation.zig` | Predefined ASCII charsets, custom `Charset` diagnostics, allocation-returning strings, Unicode scalar fill/owned/range batches, and caller-owned UTF-8 buffers. |
| `zig build run-unit-geometry` | `examples/unit_geometry.zig` | Unit circle/disc/sphere/ball scalar points, fills, reusable diagnostics, and vector-lane batches. |

## Validation

`zig build validate` depends on `zig build examples`, so these examples are part
of the normal local validation gate. `zig build examplecheck` verifies that this
catalog mentions every checked-in example source and focused run step, and that key adoption examples still contain their expected demonstration output tokens. Keep
example output deterministic and small; use benchmarks or profile checks for
large throughput/statistical evidence.
