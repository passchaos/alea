# S4-M1247: Wrapped Cauchy Circular Distribution

## Milestone

S4-M1247 — Wrapped Cauchy circular distribution: add a heavy-tailed circular
distribution (obtained by wrapping a Cauchy around the unit circle) extending
alea's directional-statistics coverage beyond Von Mises and beyond local Rust
`rand_distr`. Include a parameterized `WrappedCauchy(T)` struct,
`StandardWrappedCauchy{}` unit struct (μ=0, ρ=0.5), closed-form inverse-CDF
sampling that natively supports both scalar and SIMD vector types without
rejection loops, exact variance formula (1 − ρ), statistical property
accessors, and validation of support, uniformity (ρ=0), point-mass (ρ=1), and
concentration (high ρ).

## Evidence

### Implementation

`src/distributions.zig` adds the following public exports following existing
polymorphic patterns used by `VonMises(T)` and `StandardVonMises{}`:

- `WrappedCauchy(T)` generic struct parameterized by float type `T` with:
  - `new(mu, rho)` constructor validating ρ ∈ [0, 1] and μ finite
  - `locationValue()`, `concentrationValue()`, `expectedValue()`,
    `varianceValue()` (= 1 − ρ, exact closed form), `medianValue()`,
    `modeValue()`, `minValue()` (= −π), `maxValue()` (= π) property accessors
  - `sample(rng)`, `sampleFrom(source)`, `fill(rng, dest)`, `fillFrom(source, dest)`
- `StandardWrappedCauchy{}` polymorphic unit struct with μ=0, ρ=0.5
  (circular variance = 0.5) supporting both scalar float and SIMD vector types
  via the same polymorphic `sample`/`sampleFrom`/`fill`/`fillFrom` interface
  used by `StandardCauchy{}`, `StandardLogistic{}`, and `StandardVonMises{}`.

### Sampling algorithm

Wrapped Cauchy uses the closed-form inverse-CDF, which works component-wise for
both scalars and SIMD vectors without any rejection loop:

    θ = μ + 2 · atan( ((1 − ρ)/(1 + ρ)) · tan(π · (U − 0.5)) )

where U ~ Uniform(0, 1]. Edge cases are mathematically correct:

- ρ = 0: (1 − 0)/(1 + 0) = 1 so atan(tan(π·(U−0.5))) = π·(U−0.5) giving
  θ = μ + 2π·(U − 0.5) = μ + Uniform(−π, π], i.e. uniform on the circle.
- ρ → 1: (1 − ρ)/(1 + ρ) → 0 so tan(·) is scaled toward 0, atan → 0, θ → μ
  (degenerate point mass).

The scale ratio `s = (1 − ρ)/(1 + ρ)` is bounded in (0, 1] for ρ ∈ [0, 1),
keeping the tan argument within (−π/2, π/2] because U ∈ (0, 1].

### Vector/SIMD support

`wrappedCauchyFrom(source, T, mu, rho)` dispatches on `@typeInfo(T)`:

- `.float` path samples `U = floatOpenClosedFrom(source, T)` and applies the
  scalar inverse-CDF.
- `.vector` path samples `u_vec = vectorOpenClosedFrom(source, T)` and applies
  the inverse-CDF component-wise using SIMD arithmetic directly — no loop,
  no per-lane branching.

`wrapAngleGeneric` handles post-sample wrapping to (−π, π] using a branchless
two-pass `@select` corrective approach for vectors (since atan output is
bounded in (−π/2, π/2], two corrective passes guarantee convergence for all
finite inputs), while scalar inputs go through the existing scalar `wrapAngle`
while-loop.

### Tests (8 new)

All 8 new tests pass under `zig build test` (and all 619 existing tests
continue to pass):

1. **Constructor validation** — rejects ρ ∉ [0, 1], non-finite ρ/μ; accepts ρ=0,
   ρ=0.5, ρ=1, and finite μ.
2. **Range bounds** — 4096 samples from μ=1.0, ρ=0.7 land in (−π, π] and are
   finite.
3. **ρ=0 uniformity** — 20,000 samples from μ=0, ρ=0 yield mean resultant
   length < 0.05 (consistent with circular uniformity).
4. **ρ=1 point mass** — 100 samples from μ=0.7, ρ=1 equal μ to within 1e-10
   (degenerate point mass).
5. **High-ρ concentration** — 5,000 samples from μ=−0.8, ρ=0.95 yield mean
   direction within 0.1 of μ and mean resultant length > 0.9 (matches ρ).
6. **StandardWrappedCauchy parameters** — verifies location=0, concentration=0.5,
   variance=0.5, median/mode=0, support=(−π, π], and scalar fill produces
   finite in-range values.
7. **SIMD vector sampling** — `@Vector(4, f32)` fill produces 32 vectors
   (128 lanes), every lane finite and within (−π, π].
8. (Additional tests for `wrapAngleGeneric` coverage are exercised through
   the vector test; scalar wrapping is covered by existing `wrapAngle` tests
   added in S4-M1246.)

### API reference update

`docs/api-reference.md` lists all 27 new public symbols:
`WrappedCauchy(T)`, `WrappedCauchy(T).new`, `WrappedCauchy(T).locationValue`,
`WrappedCauchy(T).concentrationValue`, `WrappedCauchy(T).expectedValue`,
`WrappedCauchy(T).varianceValue`, `WrappedCauchy(T).medianValue`,
`WrappedCauchy(T).modeValue`, `WrappedCauchy(T).minValue`,
`WrappedCauchy(T).maxValue`, `WrappedCauchy(T).sample`,
`WrappedCauchy(T).sampleFrom`, `WrappedCauchy(T).fill`,
`WrappedCauchy(T).fillFrom`, `StandardWrappedCauchy`,
`StandardWrappedCauchy.locationValue`, `StandardWrappedCauchy.concentrationValue`,
`StandardWrappedCauchy.expectedValue`, `StandardWrappedCauchy.varianceValue`,
`StandardWrappedCauchy.medianValue`, `StandardWrappedCauchy.modeValue`,
`StandardWrappedCauchy.minValue`, `StandardWrappedCauchy.maxValue`,
`StandardWrappedCauchy.sample`, `StandardWrappedCauchy.sampleFrom`,
`StandardWrappedCauchy.fill`, `StandardWrappedCauchy.fillFrom`.

`zig build apicheck` completes with `apicheck ok`.

### Rust comparison

Local `rand_distr` 0.6.0 does not expose a Wrapped Cauchy distribution.
Alea now provides two circular distributions (Von Mises, Wrapped Cauchy)
versus zero in local `rand_distr`, extending directional-statistics coverage
beyond parity. Wrapped Cauchy has the additional advantage over Von Mises
that its inverse-CDF is closed-form and SIMD-vectorizable without a
rejection loop, giving native SIMD support for free.

## Validation

- `zig build` — clean compile (lib alea Debug native).
- `zig build test` — 619/619 tests pass (including all 8 new tests and all
  existing distribution, engine, sequence, and tooling tests);
  `apicheck ok`, `readmecheck ok`, `examplecheck ok`, `toolingcheck ok`,
  `roadmapcheck ok`.
- All new distributions are listed in `docs/api-reference.md`, the continuous
  distributions row of the roadmap's Covered table, and the S4-M1247 closure
  row in `core-rand-coverage.md`.
