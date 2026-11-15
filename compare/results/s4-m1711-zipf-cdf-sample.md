# S4-M1711 Zipf CDF Sample Path

Date: 2026-11-16

## Change

S4-M1692 gave finite-support `Zipf.fill`/`fillFrom` a hoisted CDF table but
left `sample`/`sampleFrom` on the rejection-inversion kernel. For finite
integer supports up to 32 the single-sample path now builds the same
cumulative pmf per call (the build is cheap for small supports) and draws
with one uniform plus a binary search; larger, infinite, or non-integer
supports keep rejection-inversion.

The fill and sample paths now share the CDF mapping for `n <= 32`, so the
fill-vs-sample equality assertions are restored in the iterator test.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"alea zipf"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea zipf direct` | 74.6 M samples/s | 213.1 M samples/s | 2.9x |
| `alea zipf` (facade) | 69.4 M samples/s | 78.3 M samples/s | +13% |
| `alea Zipf.fillFrom direct` | 202.1 M samples/s | 202.6 M samples/s | unchanged |

The sample-row checksum changes (`329448` -> `329152`) because the `n <= 32`
sample stream is versioned; the fill checksum (`330202`) is unchanged.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 974/974
  tests (native 951/951), including the restored Zipf fill-vs-sample equality
  assertions for `(10, 1.5)` and `(10, 1)`.

## Changed Files

- `src/distributions.zig`: `zipfCdfTable`, the `Zipf.sampleFrom` CDF path, and
  the restored equality assertions.
- `compare/results/reproducibility-matrix.md`: records the versioned sample
  stream and the shared mapping.
