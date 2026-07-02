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
`core-rand-coverage.md`. Representative rows are roughly:

- normal f32x8 / f64x4 direct: about 497M / 413M lanes/s,
- standard normal f32x8 / f64x4 direct: about 499M / 456M lanes/s,
- exponential f32x8 / f64x4 direct: about 471M / 469M lanes/s,
- standard exponential f32x8 / f64x4 direct: about 473M / 471M lanes/s.

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
  do not provide a durable standard/parameterized no-regression win. Recent
  vectorbench rows show f32x8 repair about 473M standard-normal, 477M normal,
  451M standard-exponential, and 450M exponential lanes/s versus matching
  direct rows around 499M, 497M, 473M, and 471M. FastPrng repair probe rows
  likewise trail or only match current production rows once correct stream-shape
  repair is required.
- Raw-buffer prefetch repair is invalid without a stream-shape design for
  rejected lanes: prefetching candidates changes how repair consumes randomness.
- Reinterpreting packed f64 vector slices as scalar slices and routing them
  through the scalar bulk fills is also not a durable default. It can improve
  some facade/distribution rows in a same-host `vectorbench` run, but it
  regressed direct standard/parameterized f64 vector rows while checksums
  matched, so scalar lane-fill remains the baseline.

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
