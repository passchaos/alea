# S4-M292 `rand_distr` `new` Constructor Aliases

Date: 2026-07-06

## Local Rust Baseline

The cached local `rand_distr 0.6.0` crate uses `new(...)` as its primary
constructor spelling for reusable scalar samplers, including `Normal`,
`LogNormal`, `Exp`, `Gamma`, `Beta`, `Binomial`, `ChiSquared`, `FisherF`,
`StudentT`, `Triangular`, `Cauchy`, `Pareto`, `Weibull`, `Gumbel`, `Frechet`,
`SkewNormal`, `Pert`, `InverseGaussian`, `NormalInverseGaussian`, `Zipf`,
`Zeta`, `Hypergeometric`, and `multi::Dirichlet`.

Alea's canonical Zig-native spelling for reusable sampler construction is
`init(...)`. Earlier S4 work already added `new` aliases for Bernoulli, Uniform,
Choice, weighted samplers, and static alias tables. The remaining local
`rand_distr` constructor spelling gap was for scalar distribution samplers whose
constructor shape maps to Alea's existing constructors.

## Alea Change

Alea now exposes `new(...)` aliases over existing `init(...)` constructors for:

- `Binomial`
- `Hypergeometric`
- `Normal(T)`
- `Exponential(T)` / `Exp(T)`
- `LogNormal(T)`
- `Poisson`
- `GeometricFailures`
- `Gamma(T)`
- `ChiSquared(T)`
- `Beta(T)`
- `FisherF(T)`
- `StudentT(T)`
- `Triangular(T)`
- `Cauchy(T)`
- `Pareto(T)`
- `Weibull(T)`
- `Gumbel(T)`
- `Frechet(T)`
- `SkewNormal(T)`
- `InverseGaussian(T)`
- `NormalInverseGaussian(T)`
- `Zipf(T)`
- `Zeta(T)`
- `Dirichlet(T)`

The aliases preserve Alea's existing Zig-native validation and degenerate-case
extensions rather than copying every Rust per-distribution constructor edge case
(for example, Alea rejects negative normal standard deviations and allows
documented point-mass parameters where supported).

`Pert(T).new(min, max)` mirrors local `rand_distr::Pert::new(min, max)` by
returning the existing range-first `PertBuilder(T)`, so callers can write
`Pert(T).new(min, max).withShape(...).withMode(...)` or `.withMean(...)`.

`Geometric` is intentionally excluded from this alias batch: in local
`rand_distr`, `Geometric::new(p)` samples failure counts, while Alea's
`Geometric` samples one-based trial counts. The matching local `rand_distr`
failure-count workflow is `GeometricFailures.new(p)`.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `rand_distr new aliases mirror init constructors` checks representative
  `new` aliases against their canonical `init` constructors and verifies the
  PERT builder alias.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `compare/results/distribution-parity-matrix.md` document the aliases and the
  Geometric semantic exception.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M293.

Validation commands for this milestone:

```sh
zig fmt src/distributions.zig tools/roadmapcheck.zig
zig test src/distributions.zig --test-filter "new aliases mirror init"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This milestone closes a local `rand_distr` constructor-discovery side gap only.
It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
