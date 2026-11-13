# S4-M1331 — Exp(1) race for directional rejection loops

## Goal

Cut the per-round `log(u)` cost out of the scalar and SIMD directional
rejection samplers (von Mises-Fisher, Watson, Kent) without changing the
accepted-sample distribution, and retune the SIMD Watson/Bingham scalar-tail
cutoff.

## Implementation

### Exact Exp(1) race

Every rejection test of the form `A ≥ log(u)` with `u ~ Uniform(0,1)` is
equivalent to `A + E ≥ 0` with `E = −log(u) ~ Exp(1)`. The exponential variate
is drawn from the existing fast ziggurat kernel (scalar
`standardExponentialFrom`, SIMD `vectorStandardExponentialFrom`), which is
cheaper than a libm/vector `log`. The test is exactly distribution-preserving;
only the RNG consumption order changes.

Sites converted:

- `vmfSampleWWithConstantsFrom` — scalar vMF Wood marginal.
- `vectorVmfPointFrom` — f64x4/f32x8 vMF Wood marginal.
- `watsonSampleWFrom` — scalar Watson bipolar and girdle branches for every
  dimension.
- `vectorWatsonPointFrom` — SIMD Watson marginal.
- `kentPointFrom` — scalar Kent Wood proposal and I₀-weighted marginal.
- `vectorKentPointFrom` — SIMD Kent I₀-weighted marginal.

### Scalar-tail cutoff

`vectorWatsonPointFrom` and `vectorBinghamPointFrom` now finish remaining lanes
with the scalar sampler as soon as `active_count ≤ 4` instead of `≤ 3`. For
f64x4 this means one vector round followed by scalar completion; for f32x8 the
vector loop keeps running while more than four lanes remain.

### Probed and rejected

- Bingham `@log(u)` → Exp(1) race: scalar Bingham dropped from 21.8-22.1M to
  19.0M samples/s and vector Bingham from 6.1-6.2M to 5.6-5.8M, because the
  three-normal proposal dominates and the exponential call does not inline as
  well as the log. Reverted.
- SIMD Kent Wood-proposal race (`vectorWoodW`): 4.0M → 3.9M vectors/s.
  Reverted; the scalar Kent Wood race is kept (part of the 17.3M result).

## Benchmarks (ReleaseFast, `-Dcpu=native`, 16,777,216 samples)

Same-session A/B comparisons:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea watson 3d` | 14.9-15.0M | 21.6M | +44% |
| `alea vector watson f64x4 3d` | 3.5-3.7M | 7.2M | ~2× |
| `alea kent 3d` | 15.5-15.9M | 17.3-17.4M | +9-12% |
| `alea vector kent f64x4 3d` | 3.8-3.9M | 3.9M | +2-3% |
| `alea von mises-fisher 3d` | 42.2-42.3M | 46.2-46.3M | +9-10% |
| `alea vector von mises-fisher f64x4 3d` | 8.5-8.6M | 9.9-10.0M | +16-18% |
| `alea vector bingham f64x4 3d` | 6.0M | 6.1-6.2M | +2-3% |

## Tests and validation

- `zig build test` passes 886/886 with all doc gates.
- `zig build distcheck` passes, including the vector vMF/Watson/Bingham/Kent
  unit-norm and moment gates.
- `zig build wasi-report` passes, ending `profilelongcheck ok`.
- Fixed-seed benchmark checksums change because the RNG consumption order
  changes; no stable-output snapshot covers these distributions, and the
  moment/statistical gates remain green.

## Next bar

Broader platform runners (blocked locally without QEMU/Wasmtime), further
long-run goodness-of-fit checks, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
