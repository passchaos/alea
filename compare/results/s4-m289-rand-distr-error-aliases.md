# S4-M289 `rand_distr` Error Alias Names

Date: 2026-07-06

## Local Rust Baseline

The cached local `rand_distr 0.6.0` crate re-exports distribution-specific
constructor error names from its root:

- `BetaError`, `BinomialError`, `CauchyError`, `ChiSquaredError`, `ExpError`,
  `FisherFError`, `FrechetError`, `GammaError`, `GeoError`, `GumbelError`,
  `HyperGeoError`, `InverseGaussianError`, `NormalError`,
  `NormalInverseGaussianError`, `ParetoError`, `PertError`, `PoissonError`,
  `SkewNormalError`, `TriangularError`, `WeibullError`, `ZetaError`, and
  `ZipfError`.
- `StudentT::new` returns `ChiSquaredError` in local `rand_distr`, so no
  separate `StudentTError` is exposed.

Alea already reports invalid distribution parameters through the shared
`distributions.Error` set (`InvalidParameter`, `InvalidProbability`,
`InvalidLength`, and related diagnostics). The missing piece was the
Rust-discoverable alias names for users porting local `rand_distr` constructor
code.

## Alea Change

Alea now exposes each local `rand_distr` root error discovery name as an alias
over the shared distribution error set:

```zig
pub const NormalError = Error;
pub const ExpError = Error;
pub const GammaError = Error;
pub const BetaError = Error;
pub const BinomialError = Error;
pub const CauchyError = Error;
pub const ChiSquaredError = Error;
pub const FisherFError = Error;
pub const FrechetError = Error;
pub const GeoError = Error;
pub const GumbelError = Error;
pub const HyperGeoError = Error;
pub const InverseGaussianError = Error;
pub const NormalInverseGaussianError = Error;
pub const ParetoError = Error;
pub const PertError = Error;
pub const PoissonError = Error;
pub const SkewNormalError = Error;
pub const TriangularError = Error;
pub const WeibullError = Error;
pub const ZetaError = Error;
pub const ZipfError = Error;
```

These aliases intentionally do not copy Rust's per-distribution enum variant
matrices. Alea keeps a compact Zig-native error vocabulary while preserving the
public discovery names and constructor error-set assignability.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `rand_distr error aliases mirror distribution Error` verifies type equality
  for all aliases, representative assignability, and representative constructor
  error-set shapes for normal, exponential, gamma, beta, binomial,
  hypergeometric, and poisson samplers.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `compare/results/distribution-parity-matrix.md` document the aliases.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M290.

Validation commands for this milestone:

```sh
zig fmt src/distributions.zig tools/roadmapcheck.zig
zig test src/distributions.zig --test-filter "rand_distr error aliases"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This milestone closes a local `rand_distr` discovery-name side gap only. It does
not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
