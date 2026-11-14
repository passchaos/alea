# S4-M1558 One-Setup HIN Fill for `fillFrom`

Date: 2026-11-15

## Gap

S4-M1451 gave the facade `Binomial.fill` a one-setup HIN path, but the
direct-source `Binomial.fillFrom` still looped `binomialFrom`, rebuilding the
HIN envelope for every element. On `alea fillBinomial large`
(`binomial(10000, 0.01)`) the facade row measured 34.5M samples/s while the
scalar-direct row measured 16.2M with the same checksum. S4-M1451 had
dropped an earlier `fillFrom` attempt as 14% slower; the current helper is
already out of line at the end of the production declarations, so the earlier
layout concern no longer applies.

## Change

- `Binomial.fillFrom` now calls the existing out-of-line
  `binomialFillHinFrom(self, source, dest)` before the per-element loop,
  matching `Binomial.fill`.
- The helper builds the same deterministic HIN setup and draws in the same
  order, so the fill stream is unchanged.

## Probe

`zig build bench -Doptimize=ReleaseFast -- 16777216 "fillBinomial"`, same
host, best of three trials per row:

| Row | Before | After | Delta | Checksum |
| --- | --- | --- | --- | --- |
| `alea fillBinomial large` (facade) | 34.5 M/s | 34.4 M/s | parity | `6553977` |
| `alea fillBinomial large scalar direct` | 16.2 M/s | 33.9 M/s | +109% | `6553977` |
| `alea fillBinomial scalar direct` | 995.6 M/s | 1005.5 M/s | noise | `2619332` |

## Validation

- Identical checksums on all three rows confirm the stream-preserving claim.
- `zig build test distcheck --summary all` passes 957/957 tests (native
  `alea-tests` 936/936), including the one-setup HIN fill tests and the
  multinomial/beta-binomial gates.
- No public symbol or stream contract changed; only the internal fill loop.

The aggregate `validate-all` refresh is tracked as the following milestone.
