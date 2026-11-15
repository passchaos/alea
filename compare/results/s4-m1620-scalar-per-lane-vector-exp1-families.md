# S4-M1620 Scalar-Per-Lane Vector Exp(1)-Kernel Families

Date: 2026-11-15

## New Rows

The scalar `Exp(1)`-kernel families still had packed-uniform vector samplers
and mostly no benchmark coverage. Added:

- `alea generalized pareto` (`GeneralizedPareto(f64).new(1, 2, 0.3)`): first
  scalar row, 368.4-373.6 M samples/s;
- `alea vector generalized pareto f64x4`: 42.9 M vectors/s packed;
- `alea vector rayleigh f64x4` (`VectorRayleigh(V4).init(2)`): 60.8 M;
- `alea vector laplace f64x4` (`VectorLaplace(V4).init(0, 1)`): 52.9 M;
- `alea vector kumaraswamy f64x4` (`VectorKumaraswamy(V4).init(2, 5)`): 23.7 M;
- `alea vector power-function f64x4` (`VectorPowerFunction(V4).init(-1, 2, 3)`):
  43.7 M.

The scalar rows use the same parameters as the existing scalar benchmark
functions (Rayleigh 2, Laplace 0/1, Kumaraswamy 2/5, PowerFunction -1/2/3).

## Probe And Adoption

S4-M1387/S4-M1388 moved the scalar Rayleigh, Laplace, Kumaraswamy,
PowerFunction, and generalized Pareto samplers to the `Exp(1)` kernel, but the
vector samplers still drew a packed uniform and paid per-lane `log`/`exp`/
`sqrt` transforms. Replaced each `Vector*.sampleFrom` with the scalar point
function once per lane (the S4-M1586/S4-M1616/S4-M1618 pattern), made
`sample`/`fill`/`fillFrom` delegate, and removed the seven now-unused packed
helpers (`rayleighFromOpenUniformVector`, `laplaceFromOpenUniformVector`,
`kumaraswamyFromOpenUniformVector`, `kumaraswamyBetaOneFromOpenUniformVector`,
`kumaraswamyAlphaOneFromOpenUniformVector`,
`powerFunctionFromOpenUniformVector`, `generalizedParetoFromUniformVector`).

| Row | Packed uniform | Scalar per lane | Vector checksum |
| --- | --- | --- | --- |
| `alea vector rayleigh f64x4` | 60.8 M | 218.0-220.7 M (+259-263%) | `5258948.371` -> `5256345.070` |
| `alea vector laplace f64x4` | 52.9 M | 172.2-181.4 M (+226-243%) | `-3179.540` -> `914.467` |
| `alea vector kumaraswamy f64x4` | 23.7 M | 24.6-26.4 M (+4-11%) | `774431.250` -> `774355.282` |
| `alea vector power-function f64x4` | 43.7 M | 81.9-92.8 M (+87-112%) | `2622827.263` -> `2620001.090` |
| `alea vector generalized pareto f64x4` | 42.9 M | 92.5-94.3 M (+116-120%) | `8089916.407` -> `8082912.320` |

The scalar rows stay in the run-to-run band (Rayleigh 964.9-995.5 M, Laplace
775-799 M, Kumaraswamy 139.6-147.4 M, PowerFunction 382.5-392.2 M, generalized
Pareto 368.4-373.6 M) and their checksums are unchanged (`328553.185`,
`162.156`, `48436.815`, `164057.456`, `505712.902`).

## Stream Shape

The five vector samplers now consume the scalar draw shape per lane
(`Exp(1)`/open-uniform draws depending on the scalar branch) instead of one
packed uniform per vector. The Kumaraswamy method dispatch collapses into the
scalar point function's own `alpha`/`beta` branches. The change is versioned in
`reproducibility-matrix.md`.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950).

## Changed Files

- `bench/throughput.zig`: five vector rows, one scalar GPD row, and the shared
  `benchScalarDistribution` helper.
- `src/distributions.zig`: scalar-per-lane `VectorRayleigh`, `VectorLaplace`,
  `VectorKumaraswamy`, `VectorPowerFunction`, and `VectorGeneralizedPareto`;
  seven dead packed helpers removed.
- `compare/results/performance-triage.md`: records the adoption.
- `compare/results/reproducibility-matrix.md`: versions the vector stream
  changes.
