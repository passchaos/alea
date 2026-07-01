# SIMD Distribution Kernel Notes

This note captures the current design constraints for future Zig-native
SIMD/vector distribution kernels. It exists to prevent repeating probe shapes
that have already failed to beat the scalar ziggurat lane-fill defaults.

## Current Baseline

The production vector normal/exponential APIs currently fill vector lanes by
calling the scalar ziggurat kernels lane-by-lane. This is not a true dense SIMD
distribution kernel, but it is the default because it is fast, stable, and keeps
the scalar draw/repair policy simple.

Latest `vectorbench` evidence is tracked in `performance-triage.md` and
`core-rand-coverage.md`. Representative rows are roughly:

- normal f32x8 / f64x4 direct: about 498M / 497M lanes/s,
- standard normal f32x8 / f64x4: about 499M / 502M lanes/s,
- exponential f32x8 / f64x4 direct: about 471M / 468M lanes/s,
- standard exponential f32x8 / f64x4: about 473M / 472M lanes/s.

## Rejected Or Deferred Shapes

- Vector Box-Muller normal kernels are too slow for default use.
- Vector-log exponential kernels are too slow for default use.
- f64x4 ziggurat fast-path plus scalar repair loses to scalar lane-fill.
- f32x8 repair probes are promising in isolated `ziggurat-probe` rows, but
  the advantage does not survive the real vector-slice fill harness:
  standard repair rows match but do not beat the current direct rows, and
  parameterized repair rows trail the current parameterized defaults.
- Raw-buffer prefetch repair is invalid without a stream-shape design for
  rejected lanes: prefetching candidates changes how repair consumes randomness.

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
