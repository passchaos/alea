# S4-M1580 Vector Kent `log I₀` Series

Date: 2026-11-15

## Gap

`vectorLogBesselI0` evaluated `log I₀(a)` with four per-lane scalar calls to
the branchy A&S `besselI0` + `log` helper. The A&S `log I₀` error on the
Kent acceptance range `a = ovalness·s² ∈ [0, 1.5]` is up to `3.3e-8`, and the
scalar calls dominate part of the `vector kent f64x4 3d` row (about 4.5M
vectors/s).

## Change

- `vectorLogBesselI0` now evaluates the entire series
  `log I₀(a) = Σ d_k a^{2k}` with vector FMAs when every lane has
  `a <= 1.5` (22 coefficients; truncation below `1.2e-11` on the range),
  and keeps the scalar per-lane fallback otherwise.
- `a > 1.5` lanes (large `ovalness`) still use the exact existing path.
- A unit test compares the series against the scalar helper on
  `a ∈ {0, 0.1, 0.5, 1, 1.5}` and the fallback at `a = 2`.
- No scalar Kent, sampler stream outside the vector Kent acceptance, or
  public API changed.

## Probe

`alea vector kent f64x4 3d` (16MiB, `VectorKent(f64x4)` with
`kappa = 5, ovalness = 1.5`), best of three runs: 4.5 -> 4.6 M vectors/s
(+2%, within the machine's noise band), checksum unchanged
`7297499978426234569` (no accept/reject decision changed in the benchmark
run). The acceptance `log I₀` error drops from `3.3e-8` to `1.2e-11`, so
the sampled distribution is closer to exact; the vector Kent acceptance is
a versioned stream for `a <= 1.5` lanes even though this benchmark run did
not change.

## Validation

- `zig build test -Dtest-filter=vector` passes 56/56.
- `zig build test distcheck --summary all` passes 961/961 tests (native
  `alea-tests` 940/940).
- `compare/results/reproducibility-matrix.md` records the versioned vector
  Kent acceptance change.
