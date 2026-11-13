# S4-M1365 — Ziggurat exponentials in HIN binomial sampling

## Goal

Replace the `-log(1-u)` exponential variates in the HIN small-p binomial
rejection loop and its waiting-time tail with the standard exponential
kernel, which produces the same Exp(1) law at lower cost.

## Implementation

- `binomialHinSampleFrom` and `binomialWaitingFrom` now draw their `e`, `e1`,
  and `e2` values with `standardExponentialFrom(source, f64)` instead of
  `-@log(1.0 - Rng.floatFrom(source, f64))`.
- The HIN algorithm only requires independent Exp(1) variates, so the
  distribution is unchanged; the raw RNG consumption and therefore the
  sampled stream change.
- Seven call sites were updated; the proposal, acceptance inequalities,
  log-factorial acceptance term, and waiting tail logic are unchanged.

## Benchmarks (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-host A/B, five runs each:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea multinomial` | 7.3M samples/s | 8.1M samples/s | +11% |
| `alea binomial large` (`n = 10000`) | 26.9M samples/s | 28.9M samples/s | +7% |

`multinomial direct` and `multinomial many direct` move by a similar amount
(about 7.7M → 8.6M and 8.2M → 8.8M). The checksums change to `545523` /
`545062` / `6551812` and are stable across runs.

## Validation

- All binomial, multinomial, negative-binomial, hypergeometric, and
  beta-binomial tests pass.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further discrete rejection-kernel tuning, or newly discovered core gaps.
