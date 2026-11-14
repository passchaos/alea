# S4-M1418 — Padé acceptance squeeze in the Bingham ACG loop

## Goal

Skip the envelope logarithm in the Bingham angular-central-Gaussian
acceptance loop for the common accepted candidate. The loop tested

```
log(u) <= -t + (n/2)·log1p(2t/ν) − log_envelope
```

and evaluated `log1p` on every iteration.

## Bound

For `x >= 0`, `log1p(x) >= 2x/(2+x)`. The difference
`f(x) = log1p(x) − 2x/(2+x)` has `f(0) = 0` and
`f'(x) = x² / ((1+x)(2+x)²) >= 0`, so the Padé form is a true lower bound.
Replacing `log1p(x)` with it can only accept candidates the exact test would
also accept, so the sampled values and the random stream are unchanged.

## Change

- Scalar `Bingham.sampleFromPtr`: test the Padé lower bound first; only when
  it fails evaluate `log1p` and run the exact test.
- Vector `vectorBinghamPointFrom`: compute the bound for all lanes, and only
  when some still-pending lane fails the squeeze evaluate the vector
  `log1p` and combine the exact test for those lanes.

For the benchmark matrix `diag(0, −5, −5)` the construction picks `ν = 1`,
and about 89% of candidates clear the squeeze, so the envelope log is
skipped on nearly every iteration.

## Results

Interleaved same-period A/B with two saved binaries (16 MiB, three rounds):

- `alea bingham 3d`: 26.8-27.1M -> 30.2-30.6M samples/s (+13%),
- `alea matrix fisher so3`: 30.4-30.6M -> 32.0-32.7M (+6%),
- `alea matrix fisher o3`: 24.2-24.4M -> 27.0-27.4M (+12%),
- `alea vector bingham f64x4 3d`: 6.6-6.7M -> 7.4M vectors/s (+10-12%).

Every checksum is unchanged (`3229607846008164661`, `7170305455237416037`,
`250858534088675283`, `7858544676074727599`), confirming that the squeeze
does not alter any acceptance decision. Layout-sensitive rows stay in range:
`alea kent 3d` 26.1-26.6M, `alea watson 3d` 31.8-31.9M, `alea skew-normal`
573.7-579.4M.

## Validation

- `zig build test --summary all` passes 903/903,
- `zig build distcheck` and `zig build statcheck` pass,
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Next bar

Broader platform runners, a similar squeeze for the Kent/Wood acceptance
loop, or newly discovered core gaps.
