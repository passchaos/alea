# S4-M1652 Vector Binomial Inverse-CDF Mid Trials

Date: 2026-11-15

## Change

The S4-M1650 inverse-CDF kernel was gated at `trials <= 64`, so non-dyadic
`p` with 65..128 trials fell back to per-lane scalar draws (3.9 M vectors/s
for trials=100, p=0.4). Raised the guard to `trials <= 128` and enlarged the
CDF scratch table to 128 entries.

## Measurements (same-period A/B)

| Row | Per-lane scalar draws | Inverse-CDF kernel | Change |
| --- | --- | --- | --- |
| `alea vector binomial mid f64x4` (100, 0.4) | 3.9 M | 8.5-8.6 M | +118% |
| `alea vector binomial non-dyadic f64x4` (40, 0.4) | 22.6-23.2 M | 22.6-23.2 M | unchanged |
| `alea vector binomial f64x4` (40, 0.25) | 103.4-106.0 M | 103.4-106.0 M | unchanged |
| `alea vector binomial fair f64x4` (40, 0.5) | 219.2-232.2 M | 219.2-232.2 M | unchanged |
| `alea vector binomial large f64x4` (256, 0.25) | 28.5-29.3 M | 28.5-29.3 M | unchanged |

The mid-row checksum changes `83885056.000` -> `83891169.000` (inverse-CDF
stream) and is versioned in `reproducibility-matrix.md`.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950).

## Changed Files

- `src/distributions.zig`: the inverse-CDF guard and CDF scratch size.
- `bench/throughput.zig`: the `alea vector binomial mid f64x4` row.
- `compare/results/performance-triage.md`: records the adoption.
- `compare/results/reproducibility-matrix.md`: versions the stream.
