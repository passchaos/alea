# S4-M1372 — Multinomial batch HIN setup cache

## Goal

Stop recomputing the HIN envelope constants for the second multinomial
conditional on every batch sample; its normalized probability is fixed and
only the remaining trial count varies.

## Implementation

- `Multinomial.sampleManyIntoFrom` now runs its own sampling loop and keeps a
  16-entry local cache of `(n, setup, flip)` for the second conditional.
- `sampleCachedSecondBinomialFrom` looks up the remaining trial count, samples
  with the cached `BinomialHinSetup`, and stores the setup on a miss with a
  round-robin replacement policy.
- When the HIN path does not apply (small `n`, mean below 8, or `p ≥ 0.5`),
  the helper falls back to `binomialFrom` with the original probability.
- The single-sample `sampleIntoFrom` path is unchanged; the cache lives only
  inside one batch call.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-host A/B, five runs each:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea multinomial many direct` | 8.8M samples/s | 11.8M samples/s | +33% |

The checksums are unchanged (`545062` for the batch/direct rows and `545523`
for the facade row), confirming the sampled stream is preserved. Single-sample
rows stay within run-to-run noise.

## Validation

- All multinomial, binomial, and negative-binomial tests pass.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further batch-sampling specializations, or newly discovered core gaps.
