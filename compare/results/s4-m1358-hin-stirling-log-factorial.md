# S4-M1358 — Stirling log-factorial fallback for HIN

## Goal

Remove the remaining `std.math.lgamma` calls from large-`n` HIN binomial
sampling by reusing the cheap Stirling-series `lnOfFactorial` helper already
used by the hypergeometric sampler.

## Implementation

- `binomialLogFactorial(x)` still serves `x < 513` from the comptime table and
  now evaluates larger arguments with `lnOfFactorial(x)` instead of
  `std.math.lgamma(f64, x + 1)`.
- `lnOfFactorial` shifts the argument by three, applies the Stirling series
  with the `1/(12v)` correction, and subtracts the three shifted factors. Its
  truncation error at the table boundary is about `2e-11` in log-acceptance
  and falls rapidly for larger arguments; that is far below Monte Carlo noise
  for the HIN acceptance test.
- No change to proposals, acceptance inequalities, waiting tail, or draw
  order.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-host focused A/B runs at the previous commit and with the change:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea binomial large` (`n = 10000`) | 19.7M samples/s | 26.6M samples/s | +35% |

The benchmark checksum is unchanged (`6551447`), so the acceptance decisions
did not flip for this parameter set. `multinomial` and `beta binomial` are
unaffected because their conditional trial counts stay inside the table or use
the `n ≤ 64` Bernoulli path.

## Rejected probes recorded in `performance-triage.md`

- Zeta exp/log transform: about 82.6-87.5M → 43.4-46.8M samples/s, reverted.
- Bingham Exp(1) acceptance race: scalar 22.0M → 21.1-21.4M and vector
  6.2M → 5.8-6.0M vectors/s, reverted.
- Zipf `invCdf` exp/log: within noise, reverted.

## Validation

- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
a validate-all refresh for the S4-M1355..M1358 batch, or newly discovered core
gaps.
