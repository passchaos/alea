# S4-M1628 exp2/log2 Transforms for the Log+Exp Samplers

Date: 2026-11-15

## Probe

Weibull, Fréchet, generalized extreme value, and log-logistic sampling each
compute one `exp(c·ln x)` transform per sample. On this host `@exp2`/`@log2`
are measurably cheaper than `@exp`/`@log`, and the identity
`exp(c·ln x) = exp2(c·log2 x)` holds exactly in real arithmetic. Replaced:

- `weibullFrom`: `scale * @exp2((1 / shape) * @log2(e))`;
- `frechetFrom`: `location + scale * @exp2((-1 / shape) * @log2(e))`;
- `generalizedExtremeValuePointFrom`:
  `(@exp2(-xi * @log2(e)) - 1)` (the scalar GEV sampler);
- `LogLogistic.sample` / `sampleFrom`:
  `scale * @exp2(@log2(u / (1 - u)) * inverse_shape)`.

## Bracketed A/B

| Row | `exp`/`log` baseline | `exp2`/`log2` | Change |
| --- | --- | --- | --- |
| `alea weibull` | 78.3-80.4 M | 134.8-139.9 M | +68-79% |
| `alea frechet` | 76.6-79.3 M | 139.0-139.9 M | +75-83% |
| `alea generalized extreme value` | 81.7-83.3 M | 140.4-140.9 M | +69-72% |
| `alea log-logistic` | 70.7-71.1 M | 174.9-177.2 M | +147-149% |

The printed checksums are unchanged (`236542.767`, `177234.872`,
`393793.141`, `315803.761`); the streams change at the ulp level because the
two forms round differently.

## Accuracy

Against the `exp`/`log` forms over `E ∈ [1e-60, 1e40]` and shapes
`{0.05, 0.3, 1.5, 3, 10}`:

- Weibull/Fréchet transform: max relative difference `1.2e-13` (at
  `shape = 0.05`, `E ≈ 1.3e-11`), typically `~1e-15`;
- GEV `expm1`-term: max relative difference `8.5e-14` over
  `xi ∈ {±0.01, ±0.3, 0.9}`.

The change is versioned in `reproducibility-matrix.md`.

## Kept As-Is

The same rewrite was measured and reverted for the single-transcendental
paths, where the extra constant multiply offsets the cheaper function:
logistic 239.9 -> 246.1 M (+2.6%), gumbel 175.6 -> 182.4 M (+3.9%), Pareto
369.1 -> 387.0 M (+4.9%), and Kumaraswamy 142.7 -> 146.5 M (+2.7%), all
within the run-to-run band.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950).

## Changed Files

- `src/distributions.zig`: the four `exp2`/`log2` transforms.
- `compare/results/performance-triage.md`: records the adoption and the
  reverted single-transcendental probes.
- `compare/results/reproducibility-matrix.md`: versions the four scalar
  stream changes.
