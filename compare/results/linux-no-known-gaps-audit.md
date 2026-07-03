# Linux No-Known-Gaps Audit

This audit records the current Linux-first evidence for Stage 4 of
`core-rand-coverage.md`.

It is not a claim that the long-term product goal is permanently complete. It
means that, on the current x86_64 Linux environment and against the locally
available Rust evidence listed below, there are no known remaining core RNG
functionality gaps in Alea's current roadmap stage. S4-M4 performance follow-up
is still active: LogNormal performance is covered by explicit opt-ins while exact
defaults remain a stable-output tradeoff, and genuinely dense SIMD
normal/exponential kernels remain the known hard performance watch item.

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
- `compare/results/performance-triage.md`
- `compare/results/simd-distribution-kernel-notes.md`
- `compare/results/lognormal-transform-notes.md`
- `compare/results/lognormal-codegen-audit.md`
- `compare/results/s4-m4-remaining-gaps.md`
- `compare/results/rust-benchmark-coverage-audit.md`
- `compare/results/2026-07-03-repro-wasm32-wasi-node.md`

Out of scope for this Linux-first audit:

- Rust ecosystem mechanisms that are not core RNG functionality in Zig, such as
  Rust traits, serde integration, and crate feature matrices
- cross-platform reproducibility beyond the documented x86_64 Linux evidence
- broader platform claims beyond the local Linux runner
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
| Normal, LogNormal, Exp | `normal`, `Normal`, `logNormal`, `LogNormal`, `BufferedLogNormal`, `LogNormalDlsymExp`, `LogNormalLibmvec`, `exponential`, `Exponential`, plus explicit bounded/native f32 LogNormal opt-ins, vector-only table-quantile f32 Normal opt-ins, and vector-only approximate-log f32 Exponential opt-ins | unit tests, `distcheck`, `distcheck-libc` for f64/f32 libmvec/dlsym availability, vector `distcheck`, benchmark rows |
| Gamma, ChiSquared, Beta | `gamma`, `Gamma`, `chiSquared`, `ChiSquared`, `beta`, `Beta` | unit tests, `distcheck`, benchmark rows |
| FisherF, StudentT | `fisherF`, `FisherF`, `studentT`, `StudentT` | unit tests, `distcheck`, benchmark rows |
| Poisson, Binomial | `poisson`, `Poisson`, `binomial`, `Binomial` | unit tests, `distcheck`, benchmark rows |
| Geometric, Hypergeometric | `geometric`, `Geometric`, `hypergeometric`, `Hypergeometric` | unit tests, `distcheck`, benchmark rows including HIN, balanced large H2PE, and skewed large H2PE parameters |
| Triangular, Cauchy, Pareto, Weibull | `triangular`, `Triangular`, `cauchy`, `Cauchy`, `pareto`, `Pareto`, `weibull`, `Weibull` | unit tests, `distcheck`, benchmark rows |
| Gumbel, Frechet, SkewNormal, PERT | `gumbel`, `Gumbel`, `frechet`, `Frechet`, `skewNormal`, `SkewNormal`, `pert`, `Pert` | unit tests, `distcheck`, benchmark rows |
| InverseGaussian, NormalInverseGaussian | `inverseGaussian`, `InverseGaussian`, `normalInverseGaussian`, `NormalInverseGaussian` | unit tests, `distcheck`, benchmark rows |
| Zipf, Zeta | `zipf`, `Zipf`, `zeta`, `Zeta` | unit tests, `distcheck`, benchmark rows |
| UnitCircle, UnitDisc, UnitSphere, UnitBall | `unitCircle`, `UnitCircle`, `unitDisc`, `UnitDisc`, `unitSphere`, `UnitSphere`, `unitBall`, `UnitBall` | unit tests, `distcheck`, benchmark rows |
| Dirichlet | `Dirichlet(T)` | unit tests, `distcheck`, benchmark row |
| WeightedAliasIndex | `AliasTable(Weight)` | unit tests, benchmark rows for weighted index paths; f32, f64, and u32 `WeightedAliasIndex` rows are exceeded by `AliasTable` evidence |
| WeightedTreeIndex | `WeightedTree(Weight)`, `WeightedIntTree(Weight)` | unit tests, Zig/Rust update+sample benchmark rows for integer and f64 weights |

## Current Stage 4 Performance Watch Items

These are not functionality gaps, but they remain active S4-M4 work. The
current blocker audit is `s4-m4-remaining-gaps.md`. In short:

- `LogNormal` exact defaults remain intentionally stable on Zig `@exp` output
  mapping and still trail local Rust single-sample rows, but the S4-M4
  performance gap is now covered by explicit opt-ins: `BufferedLogNormal`,
  `LogNormalDlsymExp`, `LogNormalLibmvec`, and the bounded/native f32 profiles.
  Current evidence and rejected exact transform shapes are recorded in
  `lognormal-transform-notes.md`, `performance-triage.md`, and
  `s4-m4-remaining-gaps.md`.
- vector normal/exponential APIs have broad Zig-native coverage and strong
  scalar-lane-fill rows, but no genuinely dense SIMD distribution kernel has
  beaten scalar ziggurat lane-fill in the real `vectorbench` harness; the
  repair, block-fallback, all-accepted, mask-redraw, flat-slice, lane-local,
  Marsaglia polar, approximate-log polar, ratio-of-uniforms, inverse-CDF
  variants, libmvec vector-log, f64 approximate-log, and cached-Rng attempts are
  recorded in `simd-distribution-kernel-notes.md`; the new f32 vector
  table-quantile normal and approximate-log exponential opt-ins narrow the f32
  vector side for users who accept explicit approximation/output-mapping
  contracts, but do not close f64/default dense-kernel requirements. Current
  evidence is recorded in
  `simd-distribution-kernel-notes.md`,
  `performance-triage.md`, and `s4-m4-remaining-gaps.md`.

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

The following validation gates are used for the current Linux-first stage:

```sh
zig build test
zig build -Doptimize=ReleaseFast distcheck
zig build -Doptimize=ReleaseFast distcheck-libc
zig build -Doptimize=ReleaseFast statcheck
# zig build validate now includes distcheck-libc on native builds
zig build -Doptimize=ReleaseFast -Dcpu=native bench
zig build -Doptimize=ReleaseFast -Dcpu=native bench-libc
zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench
zig build crosscheck
zig build validate-all
RUSTFLAGS='-C target-cpu=native' cargo run --release --manifest-path compare/rand_bench/Cargo.toml
```

Prior Linux engine validation is recorded in the PractRand reports under
`compare/results/`, including 128GiB reports for the current primary-engine
stage.

## Current Finding

Within this audit's local Linux scope, no known core RNG functionality gap
remains against the locally available `rand` / `rand_distr` evidence.

This does not close the long-term product goal. Stage 4 remains active for the
performance watch items above, and later stages should raise the bar to broader
platforms and longer validation rather than declaring the product permanently
finished.
