# S4-M1548 Noncentral-t CDF and Quantile

Date: 2026-11-15

## Feature Gap

`NoncentralT` was the only univariate continuous family with a sampler,
moments, and support accessors but no CDF/quantile helpers. The S4-M1544
milestone documented it as the remaining diagnostics gap. Unlike the
chi-squared/F noncentral families, its CDF is not a finite Poisson mixture of
central-t CDFs, so it needs a separate series/integral treatment.

## Change

- `noncentralTCdf` / `noncentralTQuantile` and `NoncentralT(T).cdf` /
  `.quantile`.
- CDF derivation: for `t ≥ 0`,
  `F(t) = Φ(−μ) + ∫₀^∞ φ(w−μ)·Q(ν/2, νw²/(2t²)) dw`, and expanding
  `φ(w−μ) = φ(w)e^{μw−μ²/2}` gives the positive-term series
  `Φ(−μ) + e^{−μ²/2}·Σ_j μ^j/j!·A_j` with
  `A_j = E[m_j(t√(V/ν))]`, `m_j(c) = ∫₀^c r^j φ(r) dr`,
  `m_j(c) = (j−1)m_{j−2}(c) − c^{j−1}φ(c)`, `A₀ = ½·I_x(½, ν/2)` and
  `x = t²/(t²+ν)`. All terms are nonnegative, so there is no cancellation;
  the series is used for `μ ≤ 10`, `t ≥ 0` (terms peak near `j ≈ μ²`).
- The remaining quadrants evaluate the exact mixture
  `F(t) = E_V[Φ(t√(V/ν) − μ)]`, `V ~ χ²_ν`, with adaptive Simpson in the chi
  scale `s = √(V/ν)`. Below one degree of freedom the substitution `r = s^ν`
  removes the `s^{ν−1}` endpoint singularity. For `t < 0` the integrand is
  bounded by `Φ(−μ)` and is scaled by it so lower-tail probabilities keep
  relative accuracy.
- Symmetry `F_μ(t) = 1 − F_{−μ}(−t)` reduces negative noncentrality to the
  `μ ≥ 0` paths; `μ = 0` delegates to `studentTCdf`; `dof = ∞` reduces to
  `Φ(t − μ)`; `dof > 1e6` uses the normal limit (matching `studentTCdf`).
- Quantile: deterministic geometric bracketing around `μ` followed by
  bisection; `p = 0 → −∞`, `p = 1 → +∞`, invalid parameters return NaN.

## Validation

- `noncentral t CDF matches central, normal limits, and reference values`
  checks the `μ = 0` central reduction (1e-12), the `t = 0` atom `Φ(−μ)`,
  symmetry, the infinite-dof normal limit, and 19 reference values from an
  independent adaptive quadrature of the χ² mixture covering the series
  quadrant, the large-μ integral quadrant, negative `μ`, `t < 0`, and
  `dof < 1` (absolute tolerance 1e-6; observed agreement is ~1e-7 and is
  dominated by the existing `normCdf` erf approximation).
- `noncentral t quantile round-trips and matches the sampler` checks
  `cdf(quantile(p))` round-trips at `p ∈ {1e-6, 0.3, 0.7, 1−1e-6}` for
  `(ν, μ) = (10, 1)` and `p ∈ {0.05, 0.5, 0.95}` for `(5, −2)`, the
  empirical median from 50k samples (`0.5 ± 0.01`), quantile edges, invalid
  parameters, the infinite-dof normal quantile, and f32.
- `distcheck` adds noncentral-t quantile round-trips for positive and
  negative `μ` to the continuous diagnostics block.
- `zig build test --summary all` passes 954/954 (native `alea-tests`
  935/935); `zig build distcheck` and `zig build doccheck` (including
  `apicheck` for the four new symbols) pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
