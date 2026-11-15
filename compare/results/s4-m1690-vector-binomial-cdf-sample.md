# S4-M1690 Vector Binomial CDF Sample Path

Date: 2026-11-16

## Change

S4-M1684 extended the hoisted-CDF fill to `129..1024` trials but left
`VectorBinomial.sample`/`sampleFrom` on the per-lane sampler for that range.
The single-vector path now builds the same deterministic CDF table per call
and uses the same branchless scan (width <= 128) or binary search (width >
128), so `fill` matches repeated `sampleFrom` again for `129..1024` trials. A
new `(200, 0.4)` fill-vs-loop test pins that contract.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea vector binomial large-nondyadic f64x4` (200, 0.4, 128 MiB) | 4.2 M vectors/s | 5.4 M vectors/s | +29% |
| `alea vector binomial mid f64x4` (100, 0.4) | 8.2 M vectors/s | 8.2 M vectors/s | unchanged |
| `alea vector binomial non-dyadic f64x4` (40, 0.4) | 21.4 M vectors/s | 21.4 M vectors/s | unchanged |
| `alea vector binomial large f64x4` (dyadic 256/0.25) | 28.1 M vectors/s | 28.1 M vectors/s | unchanged |

The checksum changes because the `129..1024` vector sample stream is
versioned; the fill rows stay at about 90M lanes/s. The per-call table build
limits the single-vector gain compared with the hoisted fill.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native 950/950), including the new `(200, 0.4)` fill-vs-loop test and
  the existing `(200, 0.4)` and `(128, 0.999)` CDF gates.

## Changed Files

- `src/distributions.zig`: the `VectorBinomial.sampleFrom` CDF extension and
  the `(200, 0.4)` fill-vs-loop test.
- `compare/results/reproducibility-matrix.md`: updates the binomial CDF stream
  note so `129..1024` trials share the CDF stream across sample and fill.
- `compare/results/performance-triage.md`: records the adoption.
