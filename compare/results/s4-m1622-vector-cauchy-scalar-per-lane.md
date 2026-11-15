# S4-M1622 Vector Cauchy Scalar-Per-Lane Sampling

Date: 2026-11-15

## New Rows

Added three vector rows with the scalar benchmark parameters:

- `alea vector cauchy f64x4` (`VectorCauchy(V4).init(0, 1)`): 36.3 M
  vectors/s packed;
- `alea vector logistic f64x4` (`VectorLogistic(V4).init(0, 1)`): 61.6 M;
- `alea vector log-logistic f64x4` (`VectorLogLogistic(V4).init(2, 3)`):
  24.0-25.1 M.

## Cauchy Adoption

The scalar Cauchy sampler is the S4-M1390 ratio of two standard normals
(520-539 M samples/s), while the vector path paid a per-lane
`tan(π(u − 1/2))` (36.3 M vectors/s = 145 M samples/s). Replaced
`VectorCauchy.sampleFrom` with four scalar `cauchyFrom` calls per vector, made
`sample`/`fill`/`fillFrom` delegate, and removed the dead
`cauchyFromOpenUniformVector` helper.

| Row | Packed uniform | Scalar per lane | Vector checksum |
| --- | --- | --- | --- |
| `alea vector cauchy f64x4` | 36.3 M | 124.9-128.9 M (+244-255%) | `-14114506.884` -> `-1186149.279` |

The scalar rows stay in the run-to-run band (cauchy 492-539 M, direct 486-545 M)
with unchanged checksums. The nonfinite-parameter stream-shape test reference
now consumes two scalar normals per lane.

## Logistic And LogLogistic: Measured, Unchanged

Both packed vector paths already exceed scalar per-sample throughput, so they
keep the packed uniform transform:

| Row | Scalar | Packed vector | Per-sample |
| --- | --- | --- | --- |
| `alea vector logistic f64x4` | 234.6-245.1 M | 61.6-62.0 M | 246-248 M samples/s |
| `alea vector log-logistic f64x4` | 66.4-71.1 M | 24.0-25.1 M | 96-100 M samples/s |

Scalar-per-lane would cap at about 58.7 M and 17 M vectors/s respectively, so
the rows stay as coverage without a code change. Their checksums are
unchanged (`1997.575`, `5075812.185`).

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950), including the updated nonfinite-Cauchy
  stream-shape test.

## Changed Files

- `bench/throughput.zig`: three vector rows.
- `src/distributions.zig`: scalar-per-lane `VectorCauchy`; dead packed helper
  removed; nonfinite stream-shape test reference updated.
- `compare/results/performance-triage.md`: records the adoption and the
  logistic/log-logistic measurement.
- `compare/results/reproducibility-matrix.md`: versions the vector Cauchy
  stream change.
