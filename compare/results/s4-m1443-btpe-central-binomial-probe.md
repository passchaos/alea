# S4-M1443 BTPE Central Binomial Probe

Date: 2026-11-14

## Question

`performance-triage.md` listed a full BTPE (Kachitvichyanukul & Schmeiser,
CACM 1988) envelope as the remaining candidate for the central binomial
region: HIN holds `mean >= 16` at about 28 ns per draw and the exponential
waiting-time race holds `mean = 12` at about 31 ns. Does replacing either path
with BTPE raise throughput without changing the sampled law?

## Reference

The local `~/Work/rand` checkout is absent on this host, so the reference was
the published `rand_distr 0.5.1` crate source (`src/binomial.rs`, the same
five-region envelope as upstream `master`) fetched into a temporary Cargo
project, plus a line-by-line Python port of that source for statistical
cross-checking. Rust's released `Binomial` caches only `n`, `p`, the mode `m`,
and the triangle radius `p1`; the remaining envelope constants are rebuilt per
draw, which matches the function-level Alea API shape.

## Probe

A temporary patch added `BinomialBtpeSetup`, `binomialBtpeSetup`,
`binomialBtpeFrom`, and `binomial_btpe_min_mean = 12.0` to
`src/distributions.zig`, and `binomialSmallPFrom` routed `mean >= 12` through
BTPE. The envelope includes the five proposal regions (central triangle,
parallelograms, two exponential tails), the recursive `f(y)` acceptance ratio,
the log-parabola squeeze for `k > 20`, and the Stirling-corrected final test.
The patch was not committed.

## Correctness Findings

The first port applied the acceptance test to region 1. The reference accepts
the central triangle unconditionally (`goto Step60` in numpy,
`break` inside the region-1 branch in `rand_distr`); testing it again biases
the law upward:

| Port | `binomial large` checksum | Implied mean | `binomial mean-12` checksum | Implied mean |
| --- | --- | --- | --- | --- |
| First port (region-1 test applied) | 6641218 / 65536 | 101.34 | 791636 / 65536 | 12.08 |
| Corrected port (region-1 accepts) | 6554710 / 65536 | 100.03 | 786931 / 65536 | 12.01 |

The corrected port is statistically exact. A 200,000-draw Python port of the
same source gives mean/variance `100.0237/99.10` for `(10000, 0.01)`,
`12.0104/11.95` for `(1000, 0.012)`, and `20.0090/18.13` for `(200, 0.1)`,
against expected `100/99`, `12/11.856`, and `20/18`. The released
`rand_distr 0.5.1` over 200,000 draws gives `100.0294/99.3963`,
`11.9973/11.8412`, and `19.9992/18.0376`. The existing `distcheck` binomial
gate at `(10000, 0.01)` passes with the corrected port.

## Throughput

Interleaved A/B runs of saved binaries, 16Mi samples, two rounds each:

| Row | Baseline (HIN / waiting) | BTPE | Delta |
| --- | --- | --- | --- |
| `alea binomial large` | 35.9M, 35.6M | 27.9M, 27.3M | -22-24% |
| `alea binomial mean-12` | 31.9M, 31.8M | 17.2M, 17.4M | -45-46% |

The first (biased) port was slower still: 18.9M and 17.0M. The baseline
checksums (`6553076`, `785832`) match the committed S4-M1442 rows, confirming
the revert restored the exact current stream.

Rust `rand_distr 0.5.1` with cached setup, same-host comparison:

| Parameters | `SmallRng` (xoshiro256++) | `StdRng` (ChaCha12) |
| --- | --- | --- |
| `(10000, 0.01)` | 33.2M samples/s | 22.8M samples/s |
| `(1000, 0.012)` | 21.1M samples/s | 14.8M samples/s |
| `(200, 0.1)` | 22.5M samples/s | 15.9M samples/s |
| `(1000, 0.25)` | 42.4M samples/s | 27.6M samples/s |
| `(40, 0.25)` | 20.9M samples/s | - |

Even with the setup cached, Rust's BTPE stays below Alea's current HIN and
waiting-time rows at both watch points.

## Decision

Not adopted. BTPE is exact but the division-heavy envelope plus the recursive
acceptance ratio costs more than the HIN table loop and the exponential
waiting-time race on this host. Alea's existing paths already exceed the local
Rust evidence at both parameters. The rejection is recorded in
`performance-triage.md`; the next binomial pressure is the `Rng` facade
overhead, the small-mean inverse-CDF layout problem, or a newly discovered
core gap.
