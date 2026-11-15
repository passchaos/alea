# S4-M1631 exp2/log2 Fill Transforms

Date: 2026-11-15

## Change

The bulk fill paths for the same log+exp families still used `@exp`/`@log`:

- `fillWeibullFrom` / `fillFrechetFrom` per-element loops,
- `weibullFromOpenUniformsVector` / `frechetFromOpenClosedUniformsVector`
  vector-lane helpers (including their scalar tails),
- `logLogisticFromOpenUniformsVector` and its scalar tail.

Converted them to the same exact `exp2`/`log2` forms as S4-M1628, with the
`ln 2` constant folded into the exponent for the Weibull/Fréchet helpers
(`log(-log u) = log2(-log2(u)·ln2)·ln2`).

## Measurements

| Row | `exp`/`log` baseline | `exp2`/`log2` | Change |
| --- | --- | --- | --- |
| `alea fillWeibull` | 77.3 M | 102.0-129.2 M | +32-67% |
| `alea fillFrechet` | 77.6 M | 121.3-128.2 M | +56-65% |
| `alea fillLogLogistic` | 102.0 M | 146.4-184.3 M | +44-81% |

The printed checksums are unchanged (`236542.767`, `177234.872`,
`315463.132`); the fill streams change at the ulp level and are versioned in
`reproducibility-matrix.md`.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950); the "distribution vector lane helpers
  preserve scalar slice transforms" references were updated to the `exp2`/
  `log2` forms.

## Changed Files

- `src/distributions.zig`: the fill loops/helpers and the test references.
- `compare/results/performance-triage.md`: records the adoption.
- `compare/results/reproducibility-matrix.md`: versions the fill streams.
