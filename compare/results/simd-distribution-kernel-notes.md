# SIMD Distribution Kernel Notes

This note captures the current design constraints for future Zig-native
SIMD/vector distribution kernels. It exists to prevent repeating probe shapes
that have already failed to beat the scalar ziggurat lane-fill defaults. The
S4-M3 vector API/prototype milestone is closed; this note now tracks the S4-M4
performance watch item for genuinely dense SIMD distribution kernels.

## Current Baseline

The production vector normal/exponential APIs currently fill vector lanes by
calling the scalar ziggurat kernels lane-by-lane. This is not a true dense SIMD
distribution kernel, but it is the default because it is fast, stable, and keeps
the scalar draw/repair policy simple.

Latest `vectorbench` evidence is tracked in `performance-triage.md` and
`core-rand-coverage.md`. A refreshed 2026-07-03 focused run of the minimum
real-harness set reports representative direct rows of roughly:

- normal f32x8 / f64x4 direct: about 477M / 454M lanes/s,
- standard normal f32x8 / f64x4 direct: about 477M / 454M lanes/s,
- exponential f32x8 / f64x4 direct: about 470M / 467M lanes/s,
- standard exponential f32x8 / f64x4 direct: about 471M / 467M lanes/s.

Same-run rejected candidates still trail: f32x8 repair/all-accepted/block-fallback
rows remain below the direct rows, and f64x4 same-candidate/all-accepted/block
fallback rows likewise remain below direct scalar lane-fill.

These rows are host/load sensitive, so production decisions should compare
candidates in the same `vectorbench` run rather than against stale absolute
numbers.

For targeted checks, `vectorbench` now accepts an optional lane count and
substring filter: `zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench --
<lanes> <filter>`. For example, `-- 65536 "StandardNormal f32x8"` runs only
the matching standard-normal f32x8 rows in the real vector-slice harness. A
short same-host smoke run produced about 191-193M facade, 249-250M direct, and
226M repair-candidate lanes/s at this small lane count, confirming the filter
works but not replacing the full-run baseline above.

The isolated `ziggurat-probe` also accepts `<count> <filter>` for candidate
discovery. For example, `zig build -Doptimize=ReleaseFast -Dcpu=native
ziggurat-probe -- 1048576 "f32x8 correct"` runs only the correct f32x8
repair rows before a real `vectorbench` follow-up.

## Rejected Or Deferred Shapes

- Vector Box-Muller normal kernels are too slow for default use.
- Vectorized Marsaglia polar normal kernels are also too slow for default use.
  A real `vectorbench -- 16777216 "StandardNormal f32x8"` / `"StandardNormal
  f64x4"` run showed f32x8/f64x4 Marsaglia-polar candidates around 159M/149M
  lanes/s versus same-run direct scalar lane-fill around 479M/455M. The
  rejection sampling plus `log`/`sqrt` transform cost is far above ziggurat
  lane-fill, so this is not a dense SIMD direction.
- Vector-log exponential kernels are too slow for default use.
- Platform libmvec vector-log inverse-transform exponential is also not a
  production direction. A scratch x86_64-linux-gnu probe using `_ZGVcN8v_logf`
  / `_ZGVcN4v_log` reached about 427M f32 and 216M f64 lanes/s for
  `-log(open01)`, below same-host ziggurat vectorbench direct rows around 470M
  f32x8 and 467M f64x4. It also changes output mapping and requires libc/libmvec.
- Native f32 scalar ziggurat candidates are adopted only as explicit opt-in
  output profiles. A focused `ziggurat-probe -- 4194304 "f32"` run shows native
  f32 normal around 680M and native f32 exponential around 656M samples/s versus
  current f64-cast f32 rows around 571M and 566M, but checksums/output mappings
  differ. `StandardNormalNativeF32` / `NormalNativeF32` and
  `StandardExponentialNativeF32` / `ExponentialNativeF32`, including their
  vector sampler variants, expose the faster profile without changing current
  f32 default reproducibility contracts.
- f64x4 ziggurat fast-path plus scalar repair loses to scalar lane-fill.
  A later real-harness same-candidate f64x4 repair check confirms the
  isolated-probe result: focused 64Mi-lane `vectorbench` rows are about
  349M standard-normal, 347M normal, 316M standard-exponential, and 314M
  exponential lanes/s, below same-run direct rows around 454M/454M normal and
  468M/468M exponential.
- Driving f64x4 ziggurat candidates from Alea4x64's four independent lanes does
  not rescue the repair shape. A focused `ziggurat-probe -- 4194304
  "alea4x64-lane"` run with lane-local repair and matching checksums shows
  vector repair about 318M normal and 320M exponential lanes/s versus
  lane-scalar Alea4x64 rows around 450M and 493M.
- The same lane-local Alea4x64 repair shape also fails for f32x8. In the
  focused 4Mi-lane probe, f32x8 repair reaches about 368M normal and 265M
  exponential lanes/s versus lane-scalar Alea4x64 rows around 506M and 482M,
  with matching checksums.
- A fill-specific lane-local Alea4x64 f32 standard normal/exponential probe
  also fails to close the FastPrng bulk gap. `ziggurat-probe -- 4194304
  "f32 fill"` reports current FastPrng f32 standard fill around 376.5M normal
  and 386.3M exponential, while the stream-versioned lane-local fill shape is
  only about 298.4M and 288.5M and changes checksums. Cycling all four engine
  lanes is therefore not a production direction for standard f32 fills.
- f32x8 repair probes are useful evidence in isolated `ziggurat-probe` rows,
  but the advantage does not survive the real vector-slice fill harness:
  standard repair rows can be close to current direct rows in a given run, but
  do not provide a durable standard/parameterized no-regression win. The
  2026-07-03 full `vectorbench` run shows f32x8 repair about 476M
  standard-normal, 476M normal, 450M standard-exponential, and 449M exponential
  lanes/s versus matching direct rows around 501M, 496M, 471M, and 470M.
  A later long filtered rerun with
  `vectorbench -- 268435456 "StandardNormal f32x8"` /
  `"fillVectorNormal f32x8"` / `"StandardExponential f32x8"` /
  `"fillVectorExponential f32x8"` kept the same same-harness ordering even
  though absolute rates were lower on that host pass: repair reached about
  395M standard-normal, 395M normal, 375M standard-exponential, and 377M
  exponential lanes/s versus matching direct core rows around 415M, 414M,
  391M, and 390M.
  FastPrng repair rows likewise lose in the real vector-slice harness: a
  focused `vectorbench -- 268435456 "f32x8 fast"` run showed FastPrng repair
  about 376M standard-normal, 375M normal, 368M standard-exponential, and 366M
  exponential lanes/s versus matching FastPrng direct rows around 409M, 407M,
  388M, and 385M. FastPrng repair probe rows therefore also trail or only match
  current production rows once correct stream-shape repair is required.
- A same-candidate f32x8 repair shape also loses in the real vector-slice
  harness. This candidate repairs each rejected lane using the lane's first
  rejected ziggurat candidate before drawing another candidate, avoiding the
  optimistic stream-shape caveat. A focused 64Mi-lane `vectorbench` run showed
  ScalarPrng same-candidate repair around 333M standard-normal, 329M normal,
  294M standard-exponential, and 294M exponential lanes/s versus direct rows
  around 497-498M normal and 470-471M exponential. FastPrng same-candidate
  repair was lower still around 307M/307M normal and 274M/272M exponential.
  Preserving the rejected candidate is therefore correct but too expensive for
  production.
- A block-fallback vector ziggurat policy also loses in the real vector-slice
  harness. This stream-versioned candidate accepts a whole vector only when all
  lanes hit the ziggurat fast path, otherwise discards the candidate block and
  falls back to scalar lane-fill for that output vector. A focused 64Mi-lane
  `vectorbench` run showed f32x8 ScalarPrng block-fallback around 430M/421M
  standard/parameterized normal and 393M/394M standard/parameterized
  exponential lanes/s versus direct rows around 499M/500M normal and
  472M/471M exponential. f64x4 block-fallback was about 432M/430M normal and
  403M/398M exponential versus direct rows around 454M/454M and 469M/468M.
  FastPrng f32x8 block-fallback likewise trailed direct rows at about
  423M/420M normal and 380M/377M exponential.
- An all-accepted fast-return variant of same-candidate repair also loses. It
  returns the vector immediately when every lane hits the ziggurat fast path,
  then falls back to per-lane same-candidate repair only for rejected lanes. A
  focused 64Mi-lane `vectorbench` run showed f32x8 ScalarPrng all-accepted
  repair around 370M/370M standard/parameterized normal and 330M/330M
  standard/parameterized exponential lanes/s versus direct rows around
  499M/499M normal and 472M/471M exponential. f64x4 all-accepted repair was
  about 362M/354M normal and 332M/328M exponential versus direct rows around
  455M/455M and 469M/466M. FastPrng f32x8 all-accepted rows likewise trailed
  direct defaults at about 338M/336M normal and 315M/312M exponential.
- Raw-buffer prefetch repair is invalid without a stream-shape design for
  rejected lanes: prefetching candidates changes how repair consumes randomness.
- Reinterpreting packed f64 vector slices as scalar slices and routing them
  through the scalar bulk fills is also not a durable default. It can improve
  some facade/distribution rows in a same-host `vectorbench` run, but it
  regressed direct standard/parameterized f64 vector rows while checksums
  matched, so scalar lane-fill remains the baseline.
- The same flat-slice routing check also loses for f32x8 in the real harness.
  A focused 64Mi-lane `vectorbench` run preserves checksums but reports about
  464M/463M standard/parameterized normal lanes/s versus direct rows around
  498M/498M, and about 448M/444M standard/parameterized exponential lanes/s
  versus direct rows around 470M/469M.
- Forcing `Rng.next` itself inline does not solve the vector facade/context
  gap: a same-host 2026-07-03 full `vectorbench` run with that probe tied or
  regressed the target facade normal/exponential rows while direct rows stayed
  essentially unchanged, so the call-boundary hint was reverted.
- A later small isolated `ziggurat-probe -- 1048576` rerun again showed why
  probe-only wins are not enough: scalar raw rows were about 641M standard
  normal and 511M standard exponential; f32x8 correct repair reached about
  629M normal and 599M exponential lanes/s in isolation, while FastPrng correct
  repair remained around 490M/480M lanes/s. These rows are useful for candidate
  discovery, but they do not override the full vector-slice harness evidence
  above because previous real `vectorbench` runs showed the same repair shapes
  trailing or tying production lane-fill once all facade/direct workflows and
  stream-shape constraints are included. No production change follows from this
  isolated probe.
- A filtered `ziggurat-probe -- 1048576 "f32x8 correct"` smoke run after the
  probe filter landed produced ScalarPrng correct repair around 530M normal and
  605M exponential lanes/s, FastPrng correct repair around 490M/483M, and
  same-host scalar f32 raw rows around 583M normal and 556M exponential. The
  filtered rows confirm the filter works and keep the same conclusion: isolated
  repair rows are candidate-discovery evidence only, not a production switch.
- A later native-f32 repair probe checked whether explicit f32 ziggurat tables
  give dense repair a new direction. `ziggurat-probe -- 4194304
  "native vector-repair"` reports about 588.9M normal and 580.2M exponential
  lanes/s for ScalarPrng, and about 481.1M/477.5M for FastPrng. The matching
  real `vectorbench -- 268435456 "NativeF32 f32x8"` rows remain the relevant
  production evidence: native standard-normal f32x8 direct is about 512.9M,
  native normal f32x8 direct about 514.1M, native standard-exponential f32x8
  direct about 503.1M, and native exponential f32x8 direct about 459.8M. The
  candidate has now been moved into the real vector-slice harness. A focused
  `vectorbench -- 268435456 "NativeF32 f32x8"` run with matching checksums
  reports repair-candidate rows of about 464.9M standard-normal, 462.9M normal,
  450.8M standard-exponential, and 445.0M exponential lanes/s versus same-run
  direct rows around 513.4M, 511.5M, 499.2M, and 462.5M. The native-f32 repair
  shape is therefore rejected as a vector-slice default/opt-in kernel; keep the
  existing native-f32 scalar lane-fill profile.

## Requirements For The Next Candidate

A future production candidate should satisfy all of the following before it can
replace scalar lane-fill:

1. Run inside the real vector-slice fill harness, not only an isolated probe.
2. Preserve or explicitly version the random stream shape for accepted and
   rejected lanes.
3. Handle rejected lanes without resampling a different candidate under the
   same output lane unless that stream mapping is intentionally versioned.
   Prefetching raw candidates across lanes is not sufficient by itself because
   rejected lanes need a deterministic repair-consumption policy.
4. Beat current direct `vectorbench` rows for both standard and parameterized
   workflows, or be narrowly scoped to a clearly named opt-in API.
5. Pass the existing vector checked-fill stream-shape tests and normal
   distribution statistical smoke checks.

### Minimum Real-Harness Benchmark Set

A future dense candidate should be measured with the following focused rows
before any production switch is considered:

```sh
zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 268435456 "StandardNormal f32x8"
zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 268435456 "fillVectorNormal f32x8"
zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 268435456 "StandardExponential f32x8"
zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 268435456 "fillVectorExponential f32x8"
zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 268435456 "StandardNormal f64x4"
zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 268435456 "fillVectorNormal f64x4"
zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 268435456 "StandardExponential f64x4"
zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 268435456 "fillVectorExponential f64x4"
```

For each row, compare same-run facade/direct/reusable rows where they exist and
record checksums. A candidate that only wins `ziggurat-probe` but loses any of
these real vector-slice rows is evidence only, not a production default. If the
stream shape changes, document the versioned mapping and add snapshot/statistical
evidence before exposing it as a named opt-in API.

Until a candidate meets those requirements, keep scalar ziggurat lane-fill as
the production default.
