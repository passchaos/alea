# S4-M1775 Vector Beta/PERT Free-Function Routing

Date: 2026-11-20

## Change

`vectorBetaFrom` now evaluates the scalar `betaFrom` free function per lane
instead of constructing a `VectorBeta` sampler per call. The sampler's
`sampleFrom` is also a per-lane beta draw, so the streams are identical (the
`vector beta` and `vector pert` benchmark checksums are unchanged), but the
free path avoids the per-call `Beta`/`Gamma` sampler construction and inherits
the inlined gamma kernel. `VectorPert.sampleFrom` uses `vectorBetaFrom`, so the
PERT row benefits too.

The same per-lane routing was tested for `vectorFisherFFrom` and rejected: the
`vector fisher-f f64x4` row moved from 21.9M to 21.2M vectors/s with an
unchanged checksum, so the sampler-construction path stays.

## Measurements

Same host, `ReleaseFast -Dcpu=native`,
`bench -- 16777216 "<filter>"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea vector beta f64x4` | 21.0M vectors/s | 21.3M vectors/s | +1.4% |
| `alea vector pert f64x4` | 16.4M vectors/s | 17.6M vectors/s | +7.3% |
| `alea vector fisher-f f64x4` | 21.9M | 21.2M (rejected variant) | reverted |

Checksums are unchanged: vector beta `599395.076`, vector pert `1048720.135`.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- No reproducibility-matrix mapping change is needed because the outputs are
  identical.

## Next Bar

Continue the remaining Alea-only slow rows (wrapped skew-normal quantile,
vector-directional samplers) and keep the no-known-gaps comparison current.
