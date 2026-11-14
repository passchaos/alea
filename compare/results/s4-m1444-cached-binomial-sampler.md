# S4-M1444 Cached Binomial Sampler

Date: 2026-11-14

## Gap

S4-M1412 recorded that the reusable `Binomial` sampler keeps only
`(trials, p)` and rebuilds the HIN envelope or the waiting-time rate on every
draw. Growing `Binomial` with a cached setup regressed the literal-parameter
sampler row by 8-10% because of the larger value copy, while runtime-parameter
callers measured the hoisted setup about twice as fast (58-79 ns against
26-47 ns across a parameter grid). The documented next step was a dedicated
cached sampler type.

## Change

- `distributions.CachedBinomial` stores `(trials, p, flip)` plus one
  precomputed method selected in `init`: constant, fair (`p = 1/2`), packed
  dyadic fields (`trials <= 64`), per-trial threshold (`trials <= 64`),
  exponential waiting-time rate (`mean < 16`), or the full HIN envelope
  (`mean >= 16`).
- The receivers are `*const Self` because the cached HIN setup is about
  128 bytes; a value receiver would copy it on every draw and erase the gain.
- `sample`/`sampleFrom`/`fill`/`fillFrom`, `cdf`/`quantile`, and the same
  moment/support accessors as `Binomial` are provided.
- Every method maps to the exact dispatch and stream of
  `Binomial`/`binomialFrom` for the same parameters.
- The type sits at the end of the production declarations. The first placement
  directly after `Binomial` cost `alea negative-binomial` about 6-9% through
  code layout in three interleaved A/B rounds; after moving it, the row is at
  parity (169-173M both sides).

## Benchmark

Two new runtime-parameter rows read `(10000, 0.01)` through volatile pointers
so the compiler cannot fold the per-draw setup:

| Row | Throughput | Checksum |
| --- | --- | --- |
| `alea binomial runtime sampler` | 17.1-17.2M samples/s | 6552418 |
| `alea binomial runtime cached` | 37.1-39.3M samples/s | 6552418 |

The identical checksum confirms stream parity. The cached row also edges the
literal-parameter `alea binomial large` facade row (35.6-36.2M) because it
hoists setup out of the draw loop, while `binomial large` and
`binomial mean-12` themselves stay at 36.2M and 32.4M with unchanged
checksums (`6553076`, `785832`).

## Validation

- New `cached binomial matches the plain sampler stream` test: constant, fair,
  dyadic, per-trial, waiting, HIN, and flipped cases; 256 direct draws,
  16-element fills, facade draws, accessors, and invalid probabilities all
  match `Binomial`.
- `zig build test --summary all` passes 907/907 tests, including native
  `alea-tests` 888/888.
- `distcheck`, `statcheck`, and the 10M long run
  (`distlongcheck ok (10000000 samples)`) pass.
- Sensitive-row A/B checks against the S4-M1442 binary show parity for
  `skew-normal`, `multinomial`, `student-t`, `beta`, `gamma`, `hypergeometric`,
  and `negative-binomial`, with unchanged checksums.
- The full 16MiB benchmark suite keeps every existing checksum identical.
