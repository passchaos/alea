# S4-M294 Local `rand_distr` Public Surface Manifest

Date: 2026-07-06

## Purpose

S4-M289 through S4-M293 closed several local `rand_distr 0.6.0` discovery-name
side gaps after the earlier distribution parity work. This manifest records the
currently scanned `rand_distr` public surface and maps it to Alea APIs,
evidence, or intentional Zig-native exclusions, preventing repeated rediscovery
of already closed names.

## Scanned Sources

Cached local crate:

- `~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src`

The scan focused on public declarations and root re-exports:

- `lib.rs` root `pub use` names and `pub mod multi` / `pub mod weighted`;
- scalar distribution files exposing `pub struct`, `pub enum Error`, and
  `new(...)` constructors;
- `multi/mod.rs` and `multi/dirichlet.rs`;
- `weighted/mod.rs`, `weighted_alias.rs`, and `weighted_tree.rs`.
- `ziggurat_tables.rs` for public implementation-table type names.

## Root Distribution Re-Exports

| Local `rand_distr` surface | Alea status |
| --- | --- |
| `StandardUniform`, `Uniform`, `uniform`, `Open01`, `OpenClosed01`, `Alphanumeric`, `Bernoulli`, `BernoulliError`, `Distribution`, `Iter` | Covered by Alea distribution/root APIs and earlier local `rand` parity milestones; see `distribution-parity-matrix.md`, S4-M262, S4-M264, S4-M270, S4-M282, and S4-M288. |
| `Normal`, `StandardNormal`, `LogNormal`; constructors/accessors `new`, `from_mean_cv`, `from_zscore`, `mean`, and `std_dev` | Covered by `Normal(T)`, `StandardNormal(T)`, `LogNormal(T)`, vector/opt-in profiles, `new`, `fromMeanCv`, `fromZScore`, `meanValue` / `stddevValue`, and `meanParameter` / `stddevParameter` / `stdDevParameter`; see S4-M289, S4-M292, S4-M293, S4-M300, and `distribution-parity-matrix.md`. |
| `Exp`, `Exp1` | Covered by `Exp(T)` / `Exp1(T)` aliases over `Exponential(T)` / `StandardExponential(T)`; see S4-M290. |
| `Beta`, `Binomial`, `Cauchy`, `ChiSquared`, `FisherF`, `Frechet`, `Gamma`, `Geometric`, `StandardGeometric`, `Gumbel`, `Hypergeometric`, `InverseGaussian`, `NormalInverseGaussian`, `Pareto`, `Pert`, `PertBuilder`, `Poisson`, `SkewNormal`, `StudentT`, `Triangular`, `Weibull`, `Zeta`, `Zipf` | Covered by concrete Alea samplers and docs. Local `new(...)` discovery is covered where semantics match; `PertBuilder` maps to Alea's range-first `PertBuilder(T)` with `with_shape` / `withShape`, `with_mean` / `withMean`, and `with_mode` / `withMode` workflows; `SkewNormal` location/scale/shape accessors map to Alea `locationValue` / `scaleValue` / `shapeValue` and `locationParameter` / `scaleParameter` / `shapeParameter` aliases because exact Rust method names would collide with Zig public fields; `Geometric` failure-count semantics map to `GeometricFailures`; see S4-M292, S4-M298, and `distribution-parity-matrix.md`. |
| `*Error` aliases such as `BetaError`, `BinomialError`, `CauchyError`, `ChiSquaredError`, `ExpError`, `FisherFError`, `FrechetError`, `GammaError`, `GeoError`, `GumbelError`, `HyperGeoError`, `InverseGaussianError`, `NormalError`, `NormalInverseGaussianError`, `ParetoError`, `PertError`, `PoissonError`, `SkewNormalError`, `TriangularError`, `WeibullError`, `ZetaError`, and `ZipfError` | Covered by aliases over `distributions.Error`; see S4-M289. |
| `UnitBall`, `UnitCircle`, `UnitDisc`, `UnitSphere` | Covered by unit geometry samplers and examples; see Stage 3 distribution additions, S4-M20, and `distribution-parity-matrix.md`. |
| `num_traits` root re-export | Rust ecosystem dependency convenience, not a core RNG workflow; intentionally not copied. |

## `multi` Module

| Local `rand_distr` surface | Alea status |
| --- | --- |
| `multi::Dirichlet` | Covered by `multi.Dirichlet(T)` alias over `Dirichlet(T)`; see S4-M291. |
| `MultiDistribution<T>`, `ConstMultiDistribution<T>` | Rust trait machinery. Alea exposes concrete `sample`, `sampleFrom`, `sampleInto`, `sampleIntoFrom`, `sampleManyInto`, and checked variants instead; intentionally not copied. |

## `weighted` Module

| Local `rand_distr` surface | Alea status |
| --- | --- |
| `weighted::WeightedIndex` and weighted `Error` re-export from `rand::distr::weighted` | Covered by `WeightedIndex`, `AliasTable`, `distributions.weighted.WeightedIndex`, typed weight/total diagnostics matching local Rust `WeightedIndex::weight`, `weights`, and `total_weight`, and weighted error aliases/variants; see S4-M265, S4-M271, S4-M281, S4-M284, S4-M1180, and S4-M1182. |
| `WeightedAliasIndex` and `weights` | Covered by `AliasTable(Weight)` for O(1) repeated weighted sampling and diagnostics, including `weights` / `weightIter` export, typed `weightsValue*` / `typedWeights*` preservation of the original `Weight`, typed iterator diagnostics, iterator clone/format diagnostics, weighted error messages, and root/prelude weighted error discovery; see S3-M4, S4-M1172, S4-M1174, S4-M1176, S4-M1180, S4-M1182, and `distribution-parity-matrix.md`. |
| `WeightedTreeIndex`, `new`, `Default`, `Clone`, `Debug`, `PartialEq`, `is_empty`, `len`, `is_valid`, `get`, `pop`, `push`, `update`, and `try_sample` | Covered by `WeightedTree(Weight)` and `WeightedIntTree(Weight)` dynamic weighted samplers; `new`, `initEmpty` / `default`, `clone`, `eql`, `{f}` formatting, `isEmpty`, `len`, `isValid`, `get`, typed `getValue` / `weightValue`, typed weight iterators/exports, `pop` plus typed `popValue`, `push`, `update`, and `trySample` / checked sample methods expose the corresponding local dynamic-tree workflows; see S3-M4, S4-M1167-S4-M1172, S4-M1187, and `distribution-parity-matrix.md`. |
| `AliasableWeight` trait | Rust trait bound for weighted alias implementation. Alea uses comptime numeric conversion and concrete sampler APIs; intentionally not copied. |

## Utility/Internal Surface

| Local `rand_distr` surface | Alea status |
| --- | --- |
| `ziggurat_tables::{ZIG_NORM_R, ZIG_EXP_R, ZigTable}` and private utility modules | Implementation scaffolding for Rust distributions. Alea has its own exact/default and opt-in vector/table profiles with documented validation; not a public Zig-native gap. |
| `Distribution<T>` trait implementations across samplers | Rust trait integration. Alea uses concrete sampler methods plus `Rng.sample`, `sampleIter`, and fill/batch helpers; intentionally not copied. |
| Serde/feature-gated derives and `num_traits` bounds | Rust ecosystem integration details; intentionally not copied. |

## Result

No new unblocked local `rand_distr 0.6.0` public-surface gap is identified by
this manifest. The remaining names are either already mapped to Alea APIs and
evidence, are Rust trait/ecosystem/implementation machinery, or are intentionally
handled by Zig-native alternatives.

Future local `rand_distr` work should start from this manifest and only open a
new milestone when it identifies a concrete missing Zig-native workflow or a
safe discovery alias not already covered by S4-M289 through S4-M293.

## Validation

This is documentation/evidence only. Relevant validation:

```sh
zig fmt tools/roadmapcheck.zig
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This manifest does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
