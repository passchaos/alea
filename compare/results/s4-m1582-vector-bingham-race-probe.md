# S4-M1582 Vector Bingham Exponential-Race Probe (Rejected)

Date: 2026-11-15

## Hypothesis

The vector Bingham kernel evaluates `log(u)` per lane for the acceptance
test (`log_u <= lower − log_envelope` and the exact-ratio fallback). Watson
and Kent already use the mathematically equivalent Exp(1) race
(`E >= log_envelope − log_ratio`), which replaces the vector log with the
fast vector exponential kernel. Applying the same substitution to Bingham
was expected to remove four per-lane scalar logs from the acceptance loop.

## Probe

Replaced `Rng.vectorOpenFrom` + `@log(u)` with
`vectorStandardExponentialFrom` and flipped the two comparisons. Same host,
16MiB `alea vector bingham f64x4 3d`, best of three runs:

| Variant | Throughput | Checksum |
| --- | --- | --- |
| log acceptance (baseline) | 7.4-7.5 M vectors/s | `7858544676074727599` |
| exponential race | 7.1-7.2 M vectors/s | `13061316062112371244` |

The race is 3-4% slower and changes the stream, so the vector exponential
kernel plus the extra draw costs more than the vector log in this kernel.

## Decision

Rejected and reverted; the log-based acceptance stays. The change is
recorded in `performance-triage.md` so the substitution is not retried
without a different exponential kernel or a cheaper race formulation.

## Validation

- `git diff` after the revert is empty for `src/distributions.zig`; the
  rebuilt benchmark reproduces the baseline checksum
  `7858544676074727599` at 7.5M vectors/s.
- No code, stream, or public API changed by this milestone (docs-only).
