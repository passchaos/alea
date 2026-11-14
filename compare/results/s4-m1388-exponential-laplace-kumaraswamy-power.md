# S4-M1388 — Exponential forms for Laplace, Kumaraswamy, and PowerFunction

## Goal

Extend the `E = −log(U) ~ Exp(1)` substitution to the remaining inverse-CDF
transforms, and unify the scalar fill paths on the same transform so
`fillFrom` matches repeated `sampleFrom` exactly.

## Implementation

- Laplace: the magnitude `−log(1 − 2|U − 1/2|)` is `Exp(1)` and independent of
  the fair sign, so the sampler draws `location + scale · sign · E` with a
  Rademacher sign from `Rng.booleanFrom`.
- Kumaraswamy: `U^{1/α} = exp(−E/α)` and `(1−U)^{1/β} = exp(−E/β)`; the
  general branch becomes `exp(log(1 − exp(−E/β))/α)`.
- PowerFunction: `U^{1/shape} = exp(−E/shape)`.
- Beta `(α, 1)` shortcut: `U^{1/α} = exp(−E/α)`.
- The `Rayleigh`, `Pareto`, `Weibull`, `Fréchet`, `Laplace`, `Kumaraswamy`,
  and `PowerFunction` facade `sample`/`fill` methods now delegate to the
  shared functions, and the scalar fill paths draw one exponential per element
  with the formula inlined at the fill site. This keeps the existing
  `fillFrom == repeated sampleFrom` invariant and is also faster than the
  vectorized uniform-log fills.
- The `infinite-scale pareto and weibull helpers preserve transform stream
  shape` test reference now consumes the exponential transform, matching the
  new stream shape.
- The log-logistic `distcheck` gate moves to 100,000 samples with bounds
  `[2.36, 2.46]`: the shifted stream's 20,000-sample mean was 2.4757, while a
  2,000,000-sample probe confirms the sampler mean `2.4184` against the
  theoretical `2.4184`.
- The Gamma `shape < 1` boosted path was probed with the exponential form and
  reverted: it cost `alea gamma` about 18% through layout with unchanged
  checksums. The boosted path keeps its `pow` transform.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea laplace` | 222.6M samples/s | 901.4M samples/s | +305% |
| `alea power-function` | 104.7M samples/s | 385.9M samples/s | +269% |
| `alea kumaraswamy` | 88.3M samples/s | 143.0M samples/s | +62% |
| `alea fillLaplace` | 230.1M samples/s | 536.4M samples/s | +133% |
| `alea fillPareto` | 183.1M samples/s | 332.9M samples/s | +82% |
| `alea fillKumaraswamy` | 76.8M samples/s | 129.5M samples/s | +69% |
| `alea fillGumbel` | 126.1M samples/s | 174.1M samples/s | +38% |
| `alea fillPowerFunction` | 162.0M samples/s | 217.7M samples/s | +34% |
| `alea fillRayleigh` | 258.5M samples/s | 327.8M samples/s | +27% |
| `alea fillWeibull` | 83.4M samples/s | 73.4M samples/s | −12% |
| `alea fillFrechet` | 85.7M samples/s | 82.7M samples/s | −3% |

The Weibull and Fréchet transforms still need `log(E)` plus `exp`, so the
exponential draw costs slightly more than the uniform draw they replaced; the
single-sample rows still improve (+54% and +52% in S4-M1387). `alea gamma`,
`alea beta`, and the standard-geometric rows keep their throughput and
checksums.

Changed-row checksums shift and are stable, for example `laplace` `137.473` →
`162.156`, `kumaraswamy` `48450.582` → `48436.815`, `power-function`
`163463.422` → `164057.456`, `fillLaplace` `549.040` → `359.265`, and
`fillRayleigh` `328896.423` → `328488.163`.

## Validation

- `zig build test` passes 899/899, including `apicheck` and `roadmapcheck`,
  and the fill-vs-loop iterator test now covers the unified exponential
  paths.
- `zig build distcheck` passes with the strengthened log-logistic gate;
  `zig build statcheck` passes.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig tools/distcheck.zig` is clean.

## Next bar

Broader platform runners, further inverse-CDF transform tuning, or newly
discovered core gaps.
