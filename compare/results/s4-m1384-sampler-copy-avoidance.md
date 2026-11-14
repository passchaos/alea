# S4-M1384 — Avoid sampler-state copies in Bingham and HIN hot paths

## Goal

Stop copying large precomputed sampler state on every draw in the
Bingham-backed samplers and in the HIN binomial path, where the state is
read-only for the whole draw.

## Implementation

- `Bingham(T, n).sampleFrom` keeps its public value receiver but now delegates
  to a private `sampleFromPtr(self: *const Self, source)` body. The public
  `sampleFrom` is `inline`, so the scalar path pays no extra call level.
- `MatrixFisherO3.sampleFrom` selects its component sampler as a
  `*const Bingham(T, 4)` and calls `sampleFromPtr` directly, so a draw no
  longer copies the roughly 430-byte Bingham state.
- `binomialHinSampleFrom` and `binomialHinDrawFrom` take
  `*const BinomialHinSetup` instead of the struct by value.
  `Multinomial.sampleFirstBinomialFrom` takes `*const Multinomial` and borrows
  `&self.first_hin.?` rather than copying the optional payload; the
  rejection, batch-cache, and cached-first call sites pass pointers to their
  local or cached setups.
- All benchmark checksums are unchanged: the sampled values and draw order are
  identical, only the copies are gone.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Bracketed A/B runs (current, stashed baseline, current) with the warm runs
compared:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea matrix fisher o3` | 22.2M samples/s | 24.8-24.9M samples/s | +11.7% |
| `alea matrix fisher so3` | 29.8-30.0M samples/s | 30.4-31.2M samples/s | +2-4% |
| `alea multinomial` | 8.1M samples/s | 8.3-8.5M samples/s | +2-5% |
| `alea multinomial direct` | 9.1M samples/s | 9.2-9.3M samples/s | +1-2% |
| `alea multinomial many direct` | 11.7M samples/s | 11.6M samples/s | flat |
| `alea bingham 3d` | 26.8M samples/s | 26.9M samples/s | unchanged |
| `alea vector bingham f64x4 3d` | 6.7M samples/s | 6.7-6.8M samples/s | unchanged |

Layout-sensitive rows were screened and stayed in their current bands:
`skew-normal` 580-582M, `watson 3d` 31.9-32.0M, `vector watson f64x4 3d`
8.0-8.1M, `matrix von mises-fisher 3x1` 44.9-45.2M, and
`matrix von mises-fisher 3x2` 37.9-39.0M.

## Rejected probes

- A full value-to-pointer receiver swap for `Bingham.sample`/`sampleFrom`/`fill`/
  `fillFrom` improved `matrix fisher o3` and `vector bingham` but regressed
  `matrix fisher so3` from about 30M to 26.5M through layout. The split body
  keeps the O(3) win without the SO(3) regression.
- Pointer receivers on the public `Multinomial.sample*` methods removed the
  outer struct copy but moved the rows only about 2%, inside the run-to-run
  band, so the public signatures were left unchanged.

## Validation

- All Bingham, matrix Fisher, binomial-family, and multinomial tests pass.
- `zig build test` passes 899/899, including `apicheck` and `roadmapcheck`.
- `zig build distcheck` passes and `zig build statcheck` passes.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners, `Rng` facade-overhead reduction for the facade
binomial/multinomial rows, or newly discovered core gaps.
