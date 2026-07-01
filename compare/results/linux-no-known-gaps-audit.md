# Linux No-Known-Gaps Audit

This audit records the current Linux-first evidence for Stage 3 of
`core-rand-coverage.md`.

It is not a claim that the long-term product goal is permanently complete. It
means that, on the current x86_64 Linux environment and against the locally
available Rust evidence listed below, there are no known remaining core RNG
functionality gaps in Alea's current roadmap stage.

## Scope

Local Rust evidence:

- `~/Work/rand`, used by `compare/rand_bench`
- cached `rand_distr 0.6.0` under `~/.cargo/registry/src`
- local `rand_distr` weighted APIs: `WeightedAliasIndex` and `WeightedTreeIndex`

Local Alea evidence:

- `src/distributions.zig`
- `src/rng.zig`
- `src/seq.zig`
- `src/ascii.zig`
- `tools/distcheck.zig`
- `bench/throughput.zig`
- `compare/rand_bench/src/main.rs`
- `docs/api-reference.md`
- `compare/results/distribution-parity-matrix.md`

Out of scope for this Linux-first audit:

- Rust ecosystem mechanisms that are not core RNG functionality in Zig, such as
  Rust traits, serde integration, and crate feature matrices
- cross-platform reproducibility beyond the documented x86_64 Linux evidence
- SIMD/vector distribution designs, which should be a later Zig-native milestone
- claims about future `rand` / `rand_distr` releases that are not locally
  available in this environment

## Rust `rand` Default-Crate Surface

| Rust area | Alea status | Evidence |
| --- | --- | --- |
| integer, float, bool, range, ratio/chance, bytes | Covered | `Rng`, unit tests, Zig/Rust benchmark rows |
| arrays, tuples, enums | Covered | `Rng.value(T)` tests |
| Unicode scalar / char-like sampling | Covered in Zig form | `Rng.unicodeScalar`, `ascii.unicodeUtf8Alloc`, `ascii.unicodeUtf8Into` |
| durations | Covered in Zig form | `durationRangeLessThan`, `durationRangeAtMost` |
| strings / alphanumeric | Covered | `ascii` module, Rust alphanumeric benchmark row |
| choose, shuffle, sample indices | Covered | `seq` module, Rust sequence benchmark row |
| weighted index | Covered | `Rng.weightedIndex`, `AliasTable`, `WeightedTree`, benchmark rows |

## `rand_distr` 0.6.0 Distribution Surface

| Local Rust family | Alea API | Validation |
| --- | --- | --- |
| Normal, LogNormal, Exp | `normal`, `Normal`, `logNormal`, `LogNormal`, `exponential`, `Exponential` | unit tests, `distcheck`, benchmark rows |
| Gamma, ChiSquared, Beta | `gamma`, `Gamma`, `chiSquared`, `ChiSquared`, `beta`, `Beta` | unit tests, `distcheck`, benchmark rows |
| FisherF, StudentT | `fisherF`, `FisherF`, `studentT`, `StudentT` | unit tests, `distcheck`, benchmark rows |
| Poisson, Binomial | `poisson`, `Poisson`, `binomial`, `Binomial` | unit tests, `distcheck`, benchmark rows |
| Geometric, Hypergeometric | `geometric`, `Geometric`, `hypergeometric`, `Hypergeometric` | unit tests, `distcheck` |
| Triangular, Cauchy, Pareto, Weibull | `triangular`, `Triangular`, `cauchy`, `Cauchy`, `pareto`, `Pareto`, `weibull`, `Weibull` | unit tests, `distcheck`, benchmark rows |
| Gumbel, Frechet, SkewNormal, PERT | `gumbel`, `Gumbel`, `frechet`, `Frechet`, `skewNormal`, `SkewNormal`, `pert`, `Pert` | unit tests, `distcheck`, benchmark rows |
| InverseGaussian, NormalInverseGaussian | `inverseGaussian`, `InverseGaussian`, `normalInverseGaussian`, `NormalInverseGaussian` | unit tests, `distcheck`, benchmark rows |
| Zipf, Zeta | `zipf`, `Zipf`, `zeta`, `Zeta` | unit tests, `distcheck`, benchmark rows |
| UnitCircle, UnitDisc, UnitSphere, UnitBall | `unitCircle`, `UnitCircle`, `unitDisc`, `UnitDisc`, `unitSphere`, `UnitSphere`, `unitBall`, `UnitBall` | unit tests, `distcheck`, benchmark rows |
| Dirichlet | `Dirichlet(T)` | unit tests, `distcheck`, benchmark row |
| WeightedAliasIndex | `AliasTable(Weight)` | unit tests, benchmark rows for weighted index paths |
| WeightedTreeIndex | `WeightedTree(Weight)` | unit tests, Zig/Rust update+sample benchmark rows |

## Alea Extras Beyond The Local Rust Surface

These are retained as product advantages rather than parity requirements:

- `Multinomial`
- `NegativeBinomial`
- direct weighted no-replacement sampling
- iterator and weighted-iterator sampling with and without replacement
- compact index sampling APIs
- system-entropy constructors aligned with Zig 0.16 `std.Io`
- reproducibility snapshot tooling
- raw stream exporter and PractRand helper tooling

## Validation Commands

The following validation gates were used during Stage 3 work:

```sh
zig build test
zig build -Doptimize=ReleaseFast distcheck
zig build -Doptimize=ReleaseFast statcheck
zig build -Doptimize=ReleaseFast -Dcpu=native bench
RUSTFLAGS='-C target-cpu=native' cargo run --release --manifest-path compare/rand_bench/Cargo.toml
```

Prior Linux engine validation is recorded in the PractRand reports under
`compare/results/`, including 64GiB runs for the Stage 2 engine set.

## Current Finding

Within this audit's local Linux scope, no known core RNG functionality gap
remains against the locally available `rand` / `rand_distr` evidence.

This closes the current Stage 3 Linux-first audit bar. The next roadmap stage
should raise the bar again rather than declaring the product goal permanently
finished.
