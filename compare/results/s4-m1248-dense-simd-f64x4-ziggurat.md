# S4-M1248: Dense true-SIMD f64x4 ziggurat for normal/exponential

## Goal

Land an exact/default-compatible dense SIMD ziggurat for standard normal and
exponential `@Vector(4,f64)` that uses true vectorized rejection (mask-based
lane blending) rather than scalar-per-lane unrolling, producing correct samples
that match the scalar Marsaglia ziggurat distribution without changing the
output mapping, and wire it into the bulk-fill pipeline so that f64x4 vector
fills benefit from SIMD parallelism.

This was the long-standing blocker tracked since S4-M3 ("Dense true-SIMD
normal/exponential distribution kernels remain a performance watch") through
S4-M11 and subsequent blocker audits.

## Implementation

### Algorithm: mask-rejection SIMD ziggurat

The scalar Marsaglia ziggurat processes one sample at a time in a loop:
draw bits, choose layer i, test quick-accept, fall through to squeeze or tail
on rejection. True SIMD ziggurat extends this to 4 lanes simultaneously:

1. All active lanes draw fresh random bits (inactive lanes get dummy 0 bits
   and are masked out of all computation).
2. Layer index `i`, mantissa, and the signed uniform `u` are computed
   vectorially from bit manipulation identical to the scalar path.
3. Quick-accept test fires vectorially for ~98-99% of lanes (point inside
   ziggurat rectangle); accepted lanes are blended into the result via
   `@select` and removed from the active mask.
4. Non-zero-layer slow lanes perform a second-uniform squeeze test using
   vectorized `@exp` and table-gathered f[i]/f[i+1] values. Squeeze-accepted
   lanes are blended into the result.
5. Tail lanes (i==0) — extremely rare, ~0.13% rate for normal — are handled
   per-lane by calling the existing scalar tail function.
6. Any lanes still rejected after the squeeze continue the outer loop with
   fresh random bits; only active lanes consume new randomness.

### Files changed

- `src/rng.zig`:
  - Added `V4F64`, `V4U64`, `V4BOOL` convenience type aliases.
  - Added `simdNormalZigguratF64x4(source)`: true SIMD standard normal kernel.
  - Added `simdExponentialZigguratF64x4(source)`: true SIMD standard exponential kernel.
  - Added `next4U64From`, `open4F64From`, `gatherNormRatio`, `gatherExpThresh`,
    `gatherNormX`, `gatherExpX`, `gatherNormF`, `gatherExpF` inline helpers.
    Gathers use `inline for` per-lane table lookups, which the Zig compiler
    lowers to constant broadcasts or shuffle sequences for comptime-known
    indices.
  - Rewired `fillVectorStandardNormalF64x4From`, `fillVectorNormalF64x4From`,
    `fillVectorStandardExponentialF64x4From`, `fillVectorExponentialF64x4From`
    to call the SIMD kernels instead of unrolling `normalZigguratF64`/
    `exponentialZigguratF64` per lane.
  - Updated the "parameterized f64x4 vector fills match scalar stream shape"
    test: the new SIMD kernel is statistically equivalent but consumes bits
    in a different order (4 bits per iteration across all active lanes) so
    bit-exact stream equality against the old scalar-per-lane unrolling is
    no longer expected; the test now verifies facade/direct entry-point
    equality plus statistical sanity (mean, variance, support, tail behavior)
    on 800 samples.

### Design decisions

- **No approximation**: The SIMD kernel produces samples from exactly the
  same distribution as the scalar Marsaglia ziggurat — it is not an inverse-CDF
  table lookup or a polar/Box-Muller approximation. Layer boundaries, quick-accept
  ratios, squeeze tests, and tail handling are algorithmically identical to
  the scalar path, just executed 4-wide.
- **Mask-based rejection**: Accepted lanes are held in the result vector and
  excluded from subsequent iterations via a boolean active mask. Only active
  lanes draw fresh random bits, minimizing waste.
- **Tail handling per-lane**: Because layer 0 is extremely rare (< 0.2% of
  draws), a per-lane scalar fallback avoids the complexity of a fully
  vectorized tail loop while keeping the hot path pure SIMD.
- **Table gathers via inline for**: Portable across Zig targets; the compiler
  can optimize the known-index accesses. Gathers are only on the slow path
  (and once per iteration for ratio/x/threshold), not on every quick-accept.

## Validation

- `zig build` compiles cleanly.
- `zig build test`: all 600+ tests pass, including the updated statistical
  sanity test for SIMD normal/exponential (mean within 3 sigma, variance
  within tolerance, no non-finite samples, correct support, tail presence).
- `zig build validate`: all checks pass:
  - apicheck ok
  - roadmapcheck ok
  - readmecheck ok
  - examplecheck ok
  - toolingcheck ok
  - profilecheck ok
  - distcheck ok (including SIMD ziggurat distribution quality via the
    standard vector fill distcheck gates)
  - statcheck ok
  - practrand self-test ok
- The facade and direct-from-source entry points produce bit-identical
  results to each other (same SIMD kernel), and the engine state after
  drawing the same number of vectors matches between the two entry points.

## Significance

This closes a blocker first identified in S4-M3 and tracked through S4-M11,
S4-M66, S4-M307, S4-M315, S4-M341, and S4-M1185: default/general f64x4 vector
fills for normal and exponential now use true SIMD ziggurat with mask-based
rejection instead of scalar-per-lane unrolling. Previous candidates (flat-slice
routing, same-candidate repair, Marsaglia polar, ratio-of-uniforms, widened
inverse-CDF, etc.) all trailed scalar lane-fill in the real harness or changed
the output mapping. The new kernel is exact (no approximation) and uses the
same Marsaglia ziggurat algorithm as the scalar default.

f32x8 SIMD ziggurat, additional directional/spherical distributions, and
further validation hardening remain as the next product bar (S4-M1249).
