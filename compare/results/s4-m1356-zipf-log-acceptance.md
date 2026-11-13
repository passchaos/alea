# S4-M1356 — Log-space rejection acceptance for Zipf

## Goal

Remove the two `pow` calls from the Zipf rejection-inversion acceptance test,
which dominated `Zipf.sampleFrom` after the CDF/quantile work.

## Implementation

- Added `Zipf.nextSampleFrom`, shared by `sample`, `sampleFrom`, `fill`, and
  `fillFrom`.
- The acceptance test `u2 < x^-s * inv_b^s` is now evaluated in log space with
  the exponential race
  `E >= s * (log(x) - log(inv_b))`,
  where `E = -log(u2)` comes from the standard exponential kernel. This
  replaces two `pow` calls per iteration with two logs and one exponential.
- For `x = 1` the threshold is zero, matching the original `ratio = 1`
  always-accept case.
- The sampling law is unchanged; only the acceptance mechanism and therefore
  the raw RNG consumption order change.

## Benchmarks (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-host focused A/B runs at the previous commit and with the change:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea zipf` | 32.0M samples/s | 46.0M samples/s | +44% |
| `alea zipf direct` | 33.0M samples/s | 49.7M samples/s | +51% |
| `alea Zipf.fillFrom direct` | 32.8M samples/s | 49.2M samples/s | +50% |

The checksums change (`zipf` `329178` → `329448`, direct/fill `331333` →
`330159`) because the acceptance decision now consumes an exponential draw
instead of a uniform draw; they are stable across runs.

## Validation

- All Zipf tests pass, including the CDF/quantile round-trips and moment
  gates.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further discrete rejection kernels, or newly discovered core gaps.
