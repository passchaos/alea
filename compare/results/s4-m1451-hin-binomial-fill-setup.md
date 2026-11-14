# S4-M1451 One-Setup HIN Fill for the Binomial Facade

Date: 2026-11-14

## Gap

`Binomial.fill` (and the `fillBinomial` facade) loops `binomialFrom` per
element. Through the type-erased `Rng` facade that call cannot be inlined, so
the HIN envelope setup is rebuilt for every element. With runtime parameters
this measured about 17M samples/s, while the direct-source `fillBinomialFrom`
monomorphizes over the concrete engine and lets the compiler hoist the setup
(about 44M).

## Change

- `Binomial.fill` now calls an out-of-line `binomialFillHinFrom` helper that
  builds `binomialHinSetup` once and loops `binomialHinDrawFrom` with the flip
  applied, when the parameters hit the HIN region (`trials > 64`,
  `mean >= 16`). The helper sits at the end of the production declarations:
  the first inlined version shifted `BufferedLogNormal f32 stddev=1 scalar
  direct` by about 32% consistently, while the out-of-line placement restores
  parity (387.9-404.6M baseline against 389.3-402.9M over four interleaved
  rounds).
- The setup is deterministic, so the fill stream is bit-identical to repeated
  `binomialFrom` draws. A new `binomial HIN fill matches repeated sampling`
  test compares both paths for `(10000, 0.01)` and the flipped `(1000, 0.9)`,
  for the facade and direct-source fills.
- `fillFrom` keeps the existing per-element loop: the generic source
  monomorphizes, and an explicit cache measured about 14% slower there because
  the compiler already hoists the setup.

## Benchmark

Runtime parameters `(10000, 0.01)`, 16Mi samples, interleaved A/B rounds:

| Row | Baseline | One-setup fill | Delta |
| --- | --- | --- | --- |
| `alea fillBinomial large` | 16.9-17.2M samples/s | 35.8-36.8M | +108-114% |
| `alea fillBinomial large scalar direct` | 51.3-52.0M | 50.1-53.3M | parity |

Both keep checksum `6556211`.

## Validation

- `zig build test --summary all` passes 909/909 tests (native `alea-tests`
  890/890), including the new fill-parity test.
- `distcheck`, `statcheck`, and the 10M long run
  (`distlongcheck ok (10000000 samples)`) pass.
- The full 16MiB benchmark suite adds the two large-fill rows and keeps every
  pre-existing checksum identical.
