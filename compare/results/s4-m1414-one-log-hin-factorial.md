# S4-M1414 — One-log large log-factorial in the HIN acceptance loop

## Goal

Remove one libm `log` per HIN acceptance candidate for `trials >= 513`. The
general `binomialLogFactorial` fell back to the shifted `lnOfFactorial`,
which evaluates `log((v+3)(v+2)(v+1))` and `log(v+3)` — two logs — for every
candidate whose complement is outside the 513-entry table.

## Change

`binomialLogFactorial` now calls a new `lnOfFactorialLarge` for `x >= 513`:

```
log(x!) = (x + 0.5)·log(x) − x + ½·log(2π) + 1/(12x)
```

The shifted form exists so that the same helper stays accurate for small
arguments (the hypergeometric code calls it with values near zero). Both
forms truncate the Stirling series at the same `1/(360x³)` term: at `x = 513`
the absolute log-space error is about `2e-11` for either form, far below the
`~5e-13` f64 resolution of `log(513!) ≈ 2611`. The direct form needs one
`log` instead of two and applies only inside the binomial HIN path.

## Results

Interleaved same-period A/B with two saved binaries (4 alternating pairs,
64 MiB per run, medians):

- `alea binomial large` (10000, 0.01): 27.4-28.4M -> 29.5-30.5M samples/s
  (+9.5%), checksum unchanged (`26212932` at 64 MiB, `6553076` at 16 MiB).

Shorter 16 MiB runs show the same direction (33.7-33.8M -> 35.0-36.1M).
Every other binomial-family row keeps its checksum and throughput within
noise: `alea binomial` `2623275`, `3/8` `3930958`, `1/16` `656003`,
`mean-12` `785832`, `poisson approx` `6556077`, `negative-binomial`
`982200`, `beta binomial` `2097245`. The identical checksums confirm that no
acceptance decision flipped across the measured streams.

## Rejected probe

Caching the HIN setup in the reusable `Binomial` sampler was probed and
rejected: literal benchmark parameters already constant-fold the facade
setup, so the larger sampler value costs about 8-10% on a new sampler row,
while runtime-parameter callers would need a dedicated cached sampler type.
The probe is recorded in `performance-triage.md`.

## Validation

- `zig build test --summary all` passes 902/902,
- `zig build distcheck` and `zig build statcheck` pass,
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Next bar

Broader platform runners, BTPE-style central binomial rejection, or newly
discovered core gaps.
