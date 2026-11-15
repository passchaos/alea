# S4-M1718 Vector Poisson Cached CDF

Date: 2026-11-16

## Change

S4-M1682 made the `lambda < 12` `VectorPoisson.sampleFrom` build the small
CDF table per call. The sampler now builds the 64-entry table once in `init`
and reuses it in `sample`/`sampleFrom`/`fill`/`fillFrom`; the methods take
`*const Self` so the table is not copied. The Ahrens-Dieter and zero methods
are unchanged.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea vector poisson small f64x4` (lambda=4) | 24.8 M vectors/s | 30.4 M vectors/s | +23% |
| `alea vector poisson f64x4` (lambda=20, AD) | 24.9 M vectors/s | 24.9 M vectors/s | unchanged |

The small-row checksum is unchanged (`8385890.000`), confirming the cached
table returns the same values as the per-call build.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 974/974
  tests (native 951/951).

## Changed Files

- `src/distributions.zig`: the `VectorPoisson` cached table and `*const Self`
  receivers.
- `compare/results/reproducibility-matrix.md`: records the stream-preserving
  speedup.
