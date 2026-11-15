# S4-M1656 Fair Negative Binomial clz Sum

Date: 2026-11-15

## Change

`NegativeBinomial(5, 0.5)` used the exponential geometric loop at
148.3-148.6 M samples/s even after S4-M1654 made `geometricFailuresFrom(0.5)`
count leading zeros. Added `negativeBinomialFairFrom`, which sums
`successes` `geometricFailuresFrom(source, 0.5)` calls, and dispatched it in
`negativeBinomialFrom` and both reusable `fill`/`fillFrom` loops for
`p == 0.5` with `successes < 2^20` (the mixture path still handles larger
successes).

## Measurements (same-period A/B)

| Row | Exponential geometric loop | clz sum | Change |
| --- | --- | --- | --- |
| `alea negative-binomial fair` (5, 0.5) | 148.3-148.6 M | 219.7-306.3 M | +48-106% |
| `alea negative-binomial` (5, 0.4) | 140.8-153.3 M | 142.9-151.1 M | unchanged |

The fair-row checksum changes `654466` -> `655723` (clz stream) and is
versioned in `reproducibility-matrix.md`.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950).

## Changed Files

- `src/distributions.zig`: `negativeBinomialFairFrom` and the dispatches.
- `bench/throughput.zig`: the `alea negative-binomial fair` row.
- `compare/results/performance-triage.md`: records the adoption.
- `compare/results/reproducibility-matrix.md`: versions the stream.
