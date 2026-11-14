# S4-M1404 — Explicit exp/log transform in the LogLogistic sampler

## Goal

Replace `std.math.pow` in the `LogLogistic` sampler methods and the free
`logLogisticFrom` function with the explicit `exp(log(x) · 1/shape)` form,
matching the vectorized fill transform and removing the generic power routine
from the single-sample path.

## Implementation

- `LogLogistic.sample`, `LogLogistic.sampleFrom`, and `logLogisticFrom` now
  evaluate `scale · exp(log(u/(1−u)) · inverse_shape)`; the shape-one ratio
  path is unchanged.
- The earlier S4-M1357 probe only changed the free function, which the sampler
  methods do not call, so it looked neutral; the sampler carried its own
  `std.math.pow` copy. The bulk fill already used the vector exp/log form,
  which is why `fillLogLogistic` was about twice as fast per element as the
  single-sample row.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-period A/B with the change stashed:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea log-logistic` | 53.5-55.7M samples/s | 70.8-72.1M samples/s | +30% |
| `alea fillLogLogistic` | 107.7M samples/s | 107.6-108.2M samples/s | unchanged |

The sampled law is unchanged; the printed checksums stay `315803.761` and
`315463.132`.

## Validation

- All LogLogistic tests pass, including the fill-vs-loop iterator check.
- `zig build test` passes 901/901 (882 library tests plus 19 tool gates),
  including `apicheck` and `roadmapcheck`.
- `zig build distcheck` passes and `zig build statcheck` passes.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners, the same sampler-versus-free-function audit for
other inverse-CDF transforms, or newly discovered core gaps.
