# S4-M1337 — Bernoulli CDF and quantile diagnostics

## Goal

Close the final discrete-sampler diagnostics gap with Bernoulli CDF and
quantile support:

- `bernoulliCdf(k, p)` / `bernoulliQuantile(q, p)`,
- `Bernoulli.cdf(k)` / `Bernoulli.quantile(q)`.

Together with S4-M1276 through S4-M1335 this gives every discrete sampler in
the library a `cdf` / `quantile` surface.

## Implementation

- `bernoulliCdf`: `0` for `k < 0`, `1 − p` for `0 ≤ k < 1`, `1` for `k ≥ 1`;
  invalid `p` or NaN `k` returns NaN.
- `bernoulliQuantile`: `0` for `q = 0` or `q ≤ 1 − p`, otherwise `1`;
  endpoints follow the usual conventions (`p = 0` is the point mass at 0 and
  `p = 1` at 1).
- The sampler methods use `Bernoulli.probability()`, i.e. the same 64-bit
  probability grid the sampler uses, so diagnostics and sampling agree even
  when the caller passed a non-grid `f64`.

## Tests added (1 new, total 891)

`bernoulliCdf and bernoulliQuantile match the two-point law` covers the
`0 / 1 − p / 1` steps, fractional `k`, `k = +∞`, quantile boundaries
(`q = 0`, `q = 1 − p`, `q > 1 − p`, `q = 1`), the `p = 0` and `p = 1` point
masses, invalid parameters, f32 support, and sampler-method delegation.

## Distcheck and long-run gates

- `checkConstructorErgonomics` adds a Bernoulli(0.3) quantile round-trip.
- The long-run discrete block adds a 10,000,000-sample empirical CDF gate for
  `Bernoulli(0.3).cdf(0)`: observed `0.699993` vs expected `0.700000`.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Validation

- `zig build test` passes 891/891 with all doc gates.
- `zig build distcheck` passes; `zig build wasi-report` ends
  `profilelongcheck ok`.
- `zig fmt --check` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further performance work, or newly discovered core gaps.
