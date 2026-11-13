# S4-M1357 — exp/log inverse-power transforms

## Goal

Replace the `std.math.pow` calls in the hot single-sample inverse-power
distribution transforms with direct `exp(c * log(x))` forms, which are faster
than the generic power routine on this platform.

## Implementation

- `weibullFrom`: `pow(-log(u), 1/shape)` becomes
  `exp((1/shape) * log(-log(u)))`.
- `frechetFrom`: `pow(-log(u), -1/shape)` becomes
  `exp((-1/shape) * log(-log(u)))`.
- `paretoFrom`: `scale / pow(u, 1/shape)` becomes
  `scale * exp((-1/shape) * log(u))`.
- Endpoint behavior is preserved: the zero/infinity cases still produce the
  same limits as the power forms.
- `fillWeibull` / `fillFrechet` / `fillPareto` use their existing staged bulk
  paths and are unchanged.

## Benchmarks (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-host focused A/B runs at the previous commit and with the change:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea weibull` | 39.3M samples/s | 53.2M samples/s | +35% |
| `alea frechet` | 42.6M samples/s | 51.8M samples/s | +21% |
| `alea pareto` | 98.2M samples/s | 163.9M samples/s | +67% |

The checksums are identical before and after (`weibull` `236938.497`,
`frechet` `177964.774`, `pareto` `392416.900`), so the sampled values are
bit-identical for the benchmarked parameters.

## Rejected probes

The same rewrite was tried for `logLogisticFrom`, `kumaraswamyFrom`, and
`powerFunctionFrom`. Focused runs were neutral (log-logistic 55.1M vs 55.2M,
kumaraswamy 86.8M vs 87.6M, power-function 102.3M vs 102.5M), so those
changes were reverted to keep this milestone focused on measured wins.

## Validation

- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further transcendental-transform tuning, or newly discovered core gaps.
