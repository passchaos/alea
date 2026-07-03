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
`core-rand-coverage.md`. The 2026-07-03 native full `vectorbench` run has
representative direct rows of roughly:

- normal f32x8 / f64x4 direct: about 496M / 413M lanes/s,
- standard normal f32x8 / f64x4 direct: about 501M / 454M lanes/s,
- exponential f32x8 / f64x4 direct: about 470M / 466M lanes/s,
- standard exponential f32x8 / f64x4 direct: about 471M / 468M lanes/s.

These rows are host/load sensitive, so production decisions should compare
candidates in the same `vectorbench` run rather than against stale absolute
numbers.

## Rejected Or Deferred Shapes

- Vector Box-Muller normal kernels are too slow for default use.
- Vector-log exponential kernels are too slow for default use.
- f64x4 ziggurat fast-path plus scalar repair loses to scalar lane-fill.
- f32x8 repair probes are useful evidence in isolated `ziggurat-probe` rows,
  but the advantage does not survive the real vector-slice fill harness:
  standard repair rows can be close to current direct rows in a given run, but
  do not provide a durable standard/parameterized no-regression win. The
  2026-07-03 full `vectorbench` run shows f32x8 repair about 476M
  standard-normal, 476M normal, 450M standard-exponential, and 449M exponential
  lanes/s versus matching direct rows around 501M, 496M, 471M, and 470M.
  FastPrng repair probe rows
  likewise trail or only match current production rows once correct stream-shape
  repair is required.
- Raw-buffer prefetch repair is invalid without a stream-shape design for
  rejected lanes: prefetching candidates changes how repair consumes randomness.
- Reinterpreting packed f64 vector slices as scalar slices and routing them
  through the scalar bulk fills is also not a durable default. It can improve
  some facade/distribution rows in a same-host `vectorbench` run, but it
  regressed direct standard/parameterized f64 vector rows while checksums
  matched, so scalar lane-fill remains the baseline.
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

Until a candidate meets those requirements, keep scalar ziggurat lane-fill as
the production default.
