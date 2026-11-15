# S4-M1640 Vector Binomial Large-Trial Dyadic Path

Date: 2026-11-15

## Change

The S4-M1636 vectorized dyadic kernel was gated at `trials <= 64`, leaving
larger dyadic-`p` vectors on the per-lane scalar fallback. Added a
`trials > 64` branch that calls the same word-per-lane kernel through a
`noinline vectorBinomialDyadicLarge` helper, so the small-trial codegen stays
unchanged.

## Measurements (same-period A/B)

| Row | Per-lane fallback | Large-trial dyadic path | Change |
| --- | --- | --- | --- |
| `alea vector binomial large f64x4` (256, 0.25) | 4.0 M vectors/s | 27.5-28.5 M | ~6.9-7.1x |
| `alea vector binomial f64x4` (40, 0.25) | 96.5-108.2 M | 108.8-109.0 M | unchanged (noise) |

The large-row checksum changes `134209193.000` -> `134225536.000` (packed
word draws instead of per-lane scalar draws) and is versioned in
`reproducibility-matrix.md`; the small-row checksum is unchanged
(`20963148.000`).

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950).

## Changed Files

- `src/distributions.zig`: `vectorBinomialDyadicLarge` and the `else` branch.
- `bench/throughput.zig`: the `alea vector binomial large f64x4` row.
- `compare/results/performance-triage.md`: records the adoption.
- `compare/results/reproducibility-matrix.md`: versions the large-trial
  vector stream.
