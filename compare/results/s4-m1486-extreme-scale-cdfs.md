# S4-M1486 Extreme-Scale Closed-Form CDFs

Date: 2026-11-14

## Change

Four closed-form CDF paths computed `x²` or `shape·(mode−min)` before
normalizing, so extreme scales overflowed to NaN or returned the wrong
probability:

- `rayleighCdf` now evaluates `−expm1(−(x/scale)²/2)` instead of
  `1 − exp(−x²/(2·scale²))`; the old form produced `inf/inf = NaN` for
  `x = scale = 1e300`, and `expm1` keeps the small-`x` tail accurate
  (`rayleighCdf(1e-9, 1) = 5e-19`).
- The PERT diagnostic parameters (shared by `pertCdf` and `pertQuantile`)
  normalize `(mode−min)/range` and `(max−mode)/range` before multiplying by
  the shape, so `shape·(mode−min)` cannot overflow; `pertCdf` at the mode and
  the quantile round-trip now work at 1e300 scales.
- `nakagamiCdf` passes `(x/Ω)·x·m` to the incomplete gamma instead of
  `m·x²/Ω`, so the argument stays finite when `m·x²` would overflow
  (`nakagamiCdf(1e150, 1e300, 1e300) = 0.5` at the mean).
- The Hoyt `q = 1` Rayleigh branch uses `−expm1(−(x/√Ω)²)`.

No RNG stream changed: these are deterministic CDF/quantile helpers.

## Before/After

| call | before | after | reference |
| --- | --- | --- | --- |
| `rayleighCdf(1e300, 1e300)` | NaN | 0.3934693402873666 | `1 − e^-0.5` |
| `rayleighCdf(1e-9, 1)` | 5e-19 | 5e-19 | `1 − e^-5e-19` |
| `pertCdf(1e300, 0, 1e300, 1e300, 1e300)` | NaN | 1 | point at max |
| `pertCdf(5e299, 0, 5e299, 1e300, 1e300)` | NaN | 0.5 | mode of a symmetric PERT |
| `pertQuantile(0.5, 0, 1e300, 1e300, 1e300)` | NaN | 1e300 | point at max |
| `nakagamiCdf(1e150, 1e300, 1e300)` | 1 | 0.5 | mean of the huge-shape law |
| `hoytCdf(1e300, 1, 1e300)` | NaN | 1 | Rayleigh tail at 1e300 |

The moderate-parameter tests for `rayleighCdf`, `pertCdf`/`pertQuantile`,
`nakagamiCdf`, and `hoytCdf` pass unchanged.

## Validation

- `zig build test --summary all` passes 922/922 (native `alea-tests` 903/903).
- `zig build statcheck` and `zig build distcheck` pass.
- `zig build roadmapcheck` and the doc checks pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
