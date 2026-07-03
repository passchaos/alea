# LogNormal Transform Notes

This note captures the current evidence for LogNormal performance work. The
remaining gap is not in normal generation or sampler dispatch; it is in the
floating-point transform from log-space normal samples to output samples.

## Current Baseline

Production LogNormal sampling uses the exact conceptual shape:

- generate a normal sample in log space,
- apply `@exp`.

Bulk fills stage normal samples into the destination slice and apply the
transform in place. Current evidence shows:

- fresh 1GiB focused f64 fill after the mean-zero standard-normal staging
  specialization is around 132M samples/s for facade/FastPrng direct and
  around 139M for ScalarPrng direct, versus local Rust around 146M,
- fresh 1GiB focused f32 fill after the same specialization is around 136-137M
  for facade/FastPrng direct and around 143M for ScalarPrng direct, versus
  local Rust around 155M,
- normal-only fill is much faster, so the bottleneck is the transform.

Local `rand_distr 0.6.0` uses the same high-level algorithm:
`Normal.sample(rng).exp()`.

## Rejected Or Deferred Transform Shapes

- Wrapper inlining does not close the gap.
- Direct field storage in the reusable sampler does not close the gap.
- Normal generation is not the bottleneck.
- `@mulAdd` in the single-sample expression does not win.
- `exp2(x * log2e)` regresses.
- `std.math.exp` is tied with `@exp`.
- libc `exp` / `expf` can help one engine/type profile in the probe but
  regresses another and requires linking libc, so it is not a generic default.
- Manual unrolling of the exact `@exp` transform loop is mixed: it can provide
  small isolated wins in one profile while regressing or tying others.
- Vector-lane exact `@exp` transform loops can look good in the isolated probe
  but regress the real production `fillLogNormal` harness. Vector2 previously
  regressed the 1GiB harness badly, and a later f64 vector4 production retry
  based on fresh 1Mi probe wins dropped the focused 256Mi f64 ScalarPrng direct
  fill row to about 117M versus surrounding scalar-loop baseline rows around
  136-141M. Keep the scalar f64 transform loop as the default.
- Indexing through the destination slice in a `while` loop is mixed and
  regresses the FastPrng f64 profile, so pointer iteration remains the default.
- Out-of-place exact transforms using a temporary normal buffer are mixed in the
  isolated probe and only produce small wins in some ScalarPrng rows while tying
  or trailing current rows elsewhere; the added copy/buffer shape is not a
  durable production default.
- Prefetching ahead in the exact `@exp` transform loop is mixed in the isolated
  probe and does not survive a production `fillLogNormal` retry as a durable
  no-regression win, so no prefetching is used in the default transform loops.
- `@setFloatMode(.optimized)` is tied/mixed and not a no-regression win.
- f32 vector width changes do not produce a durable win.
- Widening the exact f32 transform to f64 `@exp` and casting back to f32 keeps
  max error to 1 ULP across the checked spreads, but it is slower than the
  exact f32 transform in the staged fill probe, so it is not a production win.
- f32 `expm1(x) + 1` can be faster for narrow `stddev = 0.25`, but changes
  output rounding; max error is 1 ULP for the narrow benchmark and grows
  substantially for wider spreads. It is therefore exposed only through the
  opt-in `LogNormalApproxF32` / `logNormalApproxF32*` APIs with bounded
  `|mean| <= 0.25` and `stddev <= 0.25`, not as the exact default.
- A branchy f32 hybrid can keep wider-parameter error near 1 ULP, but the
  branch cost is too high for the measured fill workload.
- Filling standard normal samples and then applying scale before exact `@exp`
  wins in the real production fill path for the common `mean == 0` case, so
  `fillLogNormalFrom` now specializes that shape. Fusing the affine transform
  directly with exact `@exp` / `std.math.exp` in one pass still regresses or is
  mixed versus the staged transform.
- A production retry that changed only f64 `scaleInPlace` from vector4 scaling
  to scalar pointer scaling regressed the real focused `bench -- 268435456
  "fillLogNormal"` harness: exact f64 facade/FastPrng-direct/ScalarPrng-direct
  fell to about 106M/102M/121M versus the immediately reverted vector-scale
  baseline around 121M/119M/144M. Keep vector scaling for the mean-zero staging
  path.

## Adopted Opt-In Approximation

`LogNormalApproxF32` and the matching `logNormalApproxF32*` /
`fillLogNormalApproxF32*` helpers intentionally use `expm1(x) + 1` for the
final transform. They are limited to `|mean| <= 0.25` and `stddev <= 0.25` so
callers must explicitly choose the narrow f32 profile measured in the probe.
The exact `LogNormal(f32)` and `fillLogNormal` paths remain unchanged and keep
`@exp` output semantics.

Fresh local evidence:

- Fresh 1GiB filtered parity rows with native CPU flags: local Rust
  `rand_distr log-normal` is about 146.2M f64 and 155.3M f32 samples/s.
  Matching Alea scalar rows are about 117.7M facade, 118.5M raw FastPrng,
  134.0M ScalarPrng direct, and 134.2M raw ScalarPrng for exact f64, plus
  139.0M ScalarPrng direct and 139.8M raw ScalarPrng for exact f32. Fresh
  `bench -- 1073741824 "fillLogNormal"` rows are about 136.6M
  facade, 135.6M FastPrng direct, and 144.3M ScalarPrng direct for exact f64,
  and about 133.9M/133.2M/140.9M for exact f32. The bounded f32 approximation
  fill reaches about 142.4M/142.5M/150.4M in the same run, but remains opt-in
  because it changes exact rounding.
- `log-normal-probe` now accepts the same focused shape as the throughput
  harness: `zig build -Doptimize=ReleaseFast -Dcpu=native log-normal-probe --
  <count> <filter>`. A same-host 1Mi filtered smoke run verified the filter and
  rechecked the main exact production shapes without running every rejected
  candidate: `current fill` was about 125M/134M f64 FastPrng/ScalarPrng and
  about 140M/146M f32, `standard scale then exp` was about 124M/136M f64 and
  137M/142M f32, and `staged scalar exp` was about 120M/130M f64 and
  138M/145M f32. These rows are small-count/noisy, but they preserve the
  existing conclusion: no filtered exact transform shape is a new
  no-regression default.
- `zig build -Doptimize=ReleaseFast -Dcpu=native log-normal-probe -- 1048576`
  on 2026-07-03 still does not reveal a portable exact default replacement.
  Exact f64 current/staged-scalar fill is about 133M/133M FastPrng and
  139M/141M ScalarPrng, with out-of-place/index/prefetch/unroll/vector
  variants mixed and not a no-regression default. libc `exp` peaks higher in
  this isolated probe for f64 at about 140M FastPrng and 145M ScalarPrng, but
  it would require libc linkage and remains outside the generic exact default.
  Exact f32 current/staged-scalar fill is about 140M/138M FastPrng and
  145M/145M ScalarPrng; libc `expf` and `expm1(x)+1` peak around
  148M ScalarPrng but are profile-specific or non-exact-default shapes, while
  widened f64 `@exp` remains slower. Normal-only rows are much faster
  (about 409M/473M f64 and 391M/449M f32), reconfirming the transform
  bottleneck.
- `cargo run --release --manifest-path compare/rand_bench/Cargo.toml --
  268435456 log-normal` with native CPU flags: Rust exact f64 about 146M and
  exact f32 about 154M samples/s. Matching Alea scalar rows are about 135M f64
  ScalarPrng direct/raw and about 139M f32 ScalarPrng direct/raw; FastPrng raw
  remains around 118M.
- `bench -- 268435456 fillLogNormal`: exact f64 facade/FastPrng-direct/
  ScalarPrng-direct about 136M/135M/144M; exact f32 about 133M/132M/141M.
  The opt-in bounded approximation reaches about 143M FastPrng direct and
  about 150M ScalarPrng direct in this run, but exact f32 remains on `@exp`.
- Earlier 1GiB focused rows after the mean-zero standard-normal staging
  specialization were exact f64 facade/FastPrng-direct/ScalarPrng-direct about
  132M/131M/139M versus local Rust log-normal about 146M, and exact f32 about
  137M/137M/146M versus local Rust f32 about 155M. Reusable
  `LogNormal.fillFrom` routes through the same optimized helper.
- `log-normal-probe -- 1048576`: f32 current/approx fill remains sensitive to
  probe shape, with recent rows around 134M/139M FastPrng and 140M/130M
  ScalarPrng; older focused rows showed approx peaks around 143M/150M. A later
  exact widened f64-`@exp` probe row was slower than exact f32 `@exp`: about
  124M versus 138M FastPrng and about 130M versus 144M ScalarPrng in the same
  run, despite max 1 ULP difference at `stddev=0.25`, `1.0`, and `2.0`. The
  same 1Mi probe's out-of-place temporary-buffer exact transform was mixed:
  f64 FastPrng tied staged scalar around 134M, f64 ScalarPrng moved about
  140M to 142M, f32 FastPrng moved about 138M to 139M, and f32 ScalarPrng moved
  about 145M to 146M; this is not enough to justify replacing the simpler
  in-place production transform without a real-harness no-regression result.
- The same probe reports max 1 ULP at `stddev=0.25`, but max 51 ULP at
  `stddev=1.0` and 8028 ULP at `stddev=2.0`, which is why the public
  approximation is parameter-bounded.
- The public approximation is therefore still an opt-in narrow-profile path,
  not a replacement for exact `LogNormal(f32)`.
- A smaller same-host `log-normal-probe -- 262144` rerun after the point-mass
  cleanup sweep again failed to produce a safe exact default. The short run was
  noisy enough that current production f64 fill rows appeared low in isolation,
  but the candidate ordering still matched earlier conclusions: libc `exp` /
  `expf` and exact out-of-place or vector-lane transforms can win isolated
  rows, while requiring libc or showing profile-specific regressions; f32
  `expm1(x)+1` / public approximation remain faster only in the bounded narrow
  profile and keep the same wider-spread ULP growth (`expm1+1` around 51 ULP at
  `stddev=1` and thousands at `stddev=2`). The widened f64 exact f32 transform
  stayed 1 ULP across the checked spreads but remained slower than the exact
  f32 default in relevant rows. This rerun therefore adds no production change
  and reinforces keeping exact LogNormal on `@exp` plus the existing opt-in f32
  approximation.

## Requirements For A Future Default Change

A future LogNormal transform change should satisfy at least one of:

1. It is bit-identical or demonstrably distribution-equivalent with an explicit
   versioned-output note.
2. It is exposed as an opt-in sampler/fill variant with clearly documented
   accuracy and reproducibility tradeoffs. This is the current status for the
   bounded f32 approximation.
3. It improves both f32 and f64, or is narrowly scoped to f32 with parameter
   bounds that prevent the wider-`stddev` error growth observed in probes.

Any candidate should be measured in both `log-normal-probe` and the main
throughput harness before replacing production behavior.
